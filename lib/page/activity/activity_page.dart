import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'package:amap_location_muka/amap_location_muka.dart';
import 'package:app_settings/app_settings.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:menu_button/menu_button.dart';
import 'package:mirror/api/activity/activity_api.dart';
import 'package:mirror/api/amap/amap.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/dto/region_dto.dart';
import 'package:mirror/data/model/activity/activity_model.dart';
import 'package:mirror/data/model/activity/avtivity_type_data.dart';
import 'package:mirror/data/model/data_response_model.dart';
import 'package:mirror/data/model/peripheral_information_entity/peripheral_information_entify.dart';
import 'package:mirror/data/notifier/token_notifier.dart';
import 'package:mirror/page/activity/util/activity_default_map.dart';
import 'package:mirror/page/activity/util/activity_loading.dart';
import 'package:mirror/page/message/widget/dragball.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/date_util.dart';
import 'package:mirror/util/event_bus.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/Clip_util.dart';
import 'package:mirror/widget/address_picker.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/dialog.dart';
import 'package:mirror/widget/icon.dart';
import 'package:mirror/widget/smart_refressher_head_footer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:provider/provider.dart';

/// activity_page
/// Created by yangjiayi on 2021/8/25.
enum ActivityFilter {
  //已参加
  HaveParticipated,
  // 召集中
  Convene,
  // 召集满
  CalledFull,
  //活动中
  Active,
  //已结束
  over,
}

class ActivityPage extends StatefulWidget {
  @override
  _ActivityState createState() => _ActivityState();
}

class _ActivityState extends State<ActivityPage> with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  @override
  bool get wantKeepAlive => true; //必须重写
  // 权限
  PermissionStatus permissions;
  Location currentAddressInfo; //当前位置的信息

  // 定位地址
  StreamController<String> streamAddress = StreamController<String>();

  // 城市 编码
  String citycode;

  //  选择菜单值
  ActivityFilter selectedKey;

  // 菜单
  List<ActivityFilter> keys = <ActivityFilter>[
    ActivityFilter.HaveParticipated,
    ActivityFilter.Convene,
    ActivityFilter.CalledFull,
    ActivityFilter.Active,
    ActivityFilter.over,
  ];
  LinkedHashMap<int, RegionDto> provinceMap = Application.provinceMap;
  Map<int, List<RegionDto>> cityMap = Application.cityMap;

  List<ActivityModel> activityList = [];
  double lastScore;
  int activityHasNext;

  // 经纬度
  String longitude;
  String latitude;
  RefreshController _refreshController = RefreshController(); // 刷新控件控制器
  // 是否显示缺省图
  bool isShowDefaultMap;

  // 获取活动用户申请列表未读数
  StreamController<int> streamActiviityUnread = StreamController<int>();

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    locationPermissions();
    EventBus.getDefault().registerSingleParameter(_applyListUnread, EVENTBUS_ACTIVITY_HOME_PAGE,
        registerName: ACTIVITY_PAGE_GET_APPLYLISTUNREAD);
    WidgetsBinding.instance.addObserver(this);
  }

  ///监听用户回到app
  /// // 前台回到后台
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      locationPermissions(isDidChangeAppLifecycle: true);
    }
  }

  // 获取定位权限
  locationPermissions({bool isDidChangeAppLifecycle = false}) async {
    // 获取定位权限
    permissions = await Permission.locationWhenInUse.status;
    print("下次寻问permissions：：：：$permissions");
    // 已经获取了定位权限
    if (permissions.isGranted) {
      print("flutter定位只能获取到经纬度信息");
      currentAddressInfo = await AmapLocation.fetch(iosAccuracy: AmapLocationAccuracy.HUNDREE_METERS);
      print("currentAddressInfo::::::${currentAddressInfo.toJson()}");
      latitude = currentAddressInfo.latitude.toString();
      longitude = currentAddressInfo.longitude.toString();
      citycode = null;
      requestActivity(isRefresh: true);
      reverseGeocoding();
    } else if (isDidChangeAppLifecycle == false) {
      print("嘻嘻嘻嘻嘻");
      // 请求定位权限
      permissions = await Permission.locationWhenInUse.request();
      print("permissions::::$permissions");
      if (permissions.isGranted) {
        currentAddressInfo = await AmapLocation.fetch(iosAccuracy: AmapLocationAccuracy.HUNDREE_METERS);
        latitude = currentAddressInfo.latitude.toString();
        longitude = currentAddressInfo.longitude.toString();
        citycode = null;
        requestActivity(isRefresh: true);
        reverseGeocoding();
      } else {
        // 默认成都
        citycode = "028";
        latitude = null;
        longitude = null;
        requestActivity(isRefresh: true);
      }
    }
  }

  // 逆地理编码
  reverseGeocoding() async {
    PeripheralInformationEntity locationInformationEntity =
        await reverseGeographyHttp(currentAddressInfo.longitude, currentAddressInfo.latitude);
    if (locationInformationEntity.status == "1") {
      print('请求成功');
      citycode = locationInformationEntity.regeocode.cityDetails.citycode;
      streamAddress.sink.add(locationInformationEntity.regeocode.cityDetails.city);
    } else {
      // 请求失败
    }
  }

  //
  _applyListUnread(int unread) {
    streamActiviityUnread.sink.add(unread);
  }

  // 请求活动接口数据
  requestActivity({bool isRefresh = false}) async {
    if (isRefresh) {
      activityHasNext = null;
      _refreshController.loadComplete();
      lastScore = null;
    }
    if (activityHasNext != 0) {
      DataResponseModel model = await getRecommendActivity(
          lastScore: lastScore,
          type: enumerateParsedNumber(selectedKey),
          cityCode: citycode,
          longitude: longitude,
          latitude: latitude);
      if (isRefresh) {
        activityList.clear();
      }
      if (model != null) {
        print("00000000");
        lastScore = model.lastScore;
        activityHasNext = model.hasNext;
        if (model.list.isNotEmpty) {
          model.list.forEach((v) {
            activityList.add(ActivityModel.fromJson(v));
          });
          if (isRefresh) {
            _refreshController.refreshCompleted();
            PrimaryScrollController.of(context).jumpTo(0);
          } else {
            _refreshController.loadComplete();
          }
        }
      } else {
        print("111111111");
        if (isRefresh) {
          _refreshController.refreshCompleted();
          PrimaryScrollController.of(context).jumpTo(0);
        } else {
          _refreshController.loadComplete();
        }
      }
    } else {
      print("2222222222");
      if (isRefresh) {
        _refreshController.refreshCompleted();
        PrimaryScrollController.of(context).jumpTo(0);
      } else {
        _refreshController.loadFailed();
      }
    }
    if (activityHasNext == 0) {
      print("3333333333");
      if (isRefresh) {
        _refreshController.refreshCompleted();
        _refreshController.loadComplete();
        PrimaryScrollController.of(context).jumpTo(0);
      } else {
        print("不会经");
        _refreshController.loadNoData();
      }
    }
    if (activityList.length > 0) {
      isShowDefaultMap = false;
    } else {
      isShowDefaultMap = true;
    }
    print("activityList::::${activityList.length}");
    if (mounted) {
      setState(() {});
    }
  }

  // 枚举解析文字
  enumerateParsedText(ActivityFilter ctivityEnum) {
    ActivityFilter activity = ctivityEnum;
    String activityText;
    switch (activity) {
      case ActivityFilter.HaveParticipated:
        activityText = "已参加";
        break;
      case ActivityFilter.Convene:
        activityText = "召集中";
        break;
      case ActivityFilter.CalledFull:
        activityText = "召集满";
        break;
      case ActivityFilter.Active:
        activityText = "活动中";
        break;
      case ActivityFilter.over:
        activityText = "已结束";
        break;
      default:
        activityText = "筛选";
    }
    return activityText;
  }

  // 枚举解析数字
  enumerateParsedNumber(ActivityFilter ctivityEnum) {
    ActivityFilter activity = ctivityEnum;
    int activityNumber;
    switch (activity) {
      case ActivityFilter.HaveParticipated:
        activityNumber = 0;
        break;
      case ActivityFilter.Convene:
        activityNumber = 1;
        break;
      case ActivityFilter.CalledFull:
        activityNumber = 2;
        break;
      case ActivityFilter.Active:
        activityNumber = 3;
        break;
      case ActivityFilter.over:
        activityNumber = 4;
        break;
      default:
        activityNumber = null;
    }
    return activityNumber;
  }

  // 定位失败弹窗
  _locationFailPopUps() {
    return showAppDialog(context,
        title: "位置信息",
        info: "你没有开通位置权限，您可以通过系统\"设置\"进行权限管理",
        confirmColor: AppColor.white,
        cancel: AppDialogButton("返回", () {
          return true;
        }),
        confirm: AppDialogButton("去设置", () {
          AppSettings.openLocationSettings();
          return true;
        }));
  }

  // 头部View
  Widget headView() {
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () async {
          print("点击城市");
          if (Platform.isAndroid) {
            print("安卓拒绝好后$permissions");
            if (permissions != PermissionStatus.granted) {
              print("1111111111111");
              // 弹窗
              _locationFailPopUps();
            }
          } else if (Platform.isIOS) {
            if (permissions == PermissionStatus.denied) {
              print("00000000");
              // // 请求定位权限
              permissions = await Permission.locationWhenInUse.request();
              print("permissions::::$permissions");
              if (permissions.isGranted) {
                currentAddressInfo = await AmapLocation.fetch(iosAccuracy: AmapLocationAccuracy.HUNDREE_METERS);
                reverseGeocoding();
              }
            } else if (permissions != PermissionStatus.granted) {
              print("1111111111111");
              // 弹窗
              _locationFailPopUps();
            }
          }
          if (permissions == PermissionStatus.granted) {
            print("222222222");
            // 地址选择下拉列表
            openaddressPickerBottomSheet(
                context: context,
                provinceMap: provinceMap,
                cityMap: cityMap,
                initCityCode: citycode,
                bottomSheetHeight: ScreenUtil.instance.height * 0.46,
                onConfirm: (provinceCity, cityCode, longitude, latitude) {
                  List<String> provinceCityList = provinceCity.split(" ");
                  streamAddress.sink.add(provinceCityList.last);
                  citycode = cityCode;
                  selectedKey = null;
                  requestActivity(isRefresh: true);
                  // PrimaryScrollController.of(context).jumpTo(0);
                });
          }
        },
        child: Container(
          height: 44,
          margin: EdgeInsets.only(left: 8),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppIcon.getAppIcon(
                AppIcon.tag_location,
                16,
                color: AppColor.white,
              ),
              SizedBox(
                width: 3,
              ),
              Container(
                child: StreamBuilder<String>(
                    initialData: "成都",
                    stream: streamAddress.stream,
                    builder: (BuildContext stramContext, AsyncSnapshot<String> snapshot) {
                      return Text(
                        snapshot.data,
                        style: AppStyle.whiteRegular12,
                      );
                    }),
              ),
              SizedBox(
                width: 5,
              ),
              AppIcon.getAppIcon(
                AppIcon.arrow_right_18,
                12,
                color: AppColor.textWhite60,
              ),
            ],
          ),
        ));
  }

  // 菜单打开的按钮
  Widget normalChildButton() {
    return SizedBox(
        width: 64,
        height: 22,
        child: Container(
          decoration: BoxDecoration(
            color: AppColor.mainBlack,
            border: Border.all(color: AppColor.transparent),
          ),
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 8,
              ),
              Text(enumerateParsedText(selectedKey), style: AppStyle.whiteRegular12, overflow: TextOverflow.ellipsis),
              const Spacer(),
              RotatedBox(
                quarterTurns: 1,
                child: AppIcon.getAppIcon(
                  AppIcon.arrow_right_18,
                  16,
                  color: AppColor.textWhite60,
                ),
              ),
              SizedBox(
                width: 2,
              )
            ],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Dragball(
        withIcon: false,
        ball: Container(
          margin: EdgeInsets.only(right: 14),
          child: FloatingActionButton(
            child: const Icon(
              Icons.add,
              size: 25,
            ),
            foregroundColor: AppColor.mainBlack,
            backgroundColor: AppColor.white,
            elevation: 0,
            // highlightElevation: 14.0,
            isExtended: false,
            onPressed: () {
              AppRouter.navigateCreateActivityPage(context);
            },
            mini: true,
          ),
        ),
        ballSize: 50,
        startFromRight: true,
        initialTop: MediaQuery.of(context).size.height * 0.75,
        onTap: () {
          // print('点击了悬浮图标');
          if (!(mounted && context.read<TokenNotifier>().isLoggedIn)) {
            ToastShow.show(msg: "请先登录app!", context: context);
            AppRouter.navigateToLoginPage(context);
            return;
          } else {
            // 跳转创建活动
            AppRouter.navigateCreateActivityPage(context);
          }
        },
        child: Scaffold(
          backgroundColor: AppColor.mainBlack,
          appBar: CustomAppBar(
            titleString: "活动",
            leading: headView(),
            actions: [
              MenuButton(
                menuButtonBackgroundColor: AppColor.mainBlack,
                itemBackgroundColor: AppColor.mainBlack,
                child: normalChildButton(),
                topDivider: false,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColor.dividerWhite8),
                  borderRadius: new BorderRadius.all(new Radius.circular(2.0)),
                ),
                divider: const Divider(
                  height: 0.5,
                  color: AppColor.dividerWhite8,
                ),
                // Container(),
                items: keys,
                itemBuilder: (ActivityFilter value) => Container(
                    color: AppColor.layoutBgGrey,
                    height: 22,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 8,
                        ),
                        Text(
                          enumerateParsedText(value),
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColor.white),
                        ),
                      ],
                    )),
                toggledChild: Container(
                  child: normalChildButton(),
                ),
                onItemSelected: (ActivityFilter value) {
                  selectedKey = value;
                  requestActivity(isRefresh: true);
                  // setState(() {});
                },
                // onMenuButtonToggle: (bool isToggle) {
                //   print(isToggle);
                // },
              ),
              SizedBox(
                width: 10,
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  AppRouter.navigateActivityUserPage(context, type: 5);
                },
                child: Container(
                    width: 32,
                    alignment: Alignment.center,
                    // color: AppColor.mainRed,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Image.asset("assets/png/activity_application.webp", width: 16, height: 16),
                        StreamBuilder<int>(
                            initialData: 0,
                            stream: streamActiviityUnread.stream,
                            builder: (BuildContext stramContext, AsyncSnapshot<int> snapshot) {
                              return snapshot.data > 0
                                  ? Positioned(
                                      top: -3,
                                      right: 0,
                                      child: Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                            color: AppColor.mainRed, borderRadius: BorderRadius.circular(3)),
                                      ))
                                  : Container();
                            })
                      ],
                    )),
              ),
              SizedBox(
                width: 8,
              )
            ],
          ),
          body: isShowDefaultMap == null
              ? ActivityLoading()
              : SmartRefresher(
                  enablePullUp: true,
                  enablePullDown: true,
                  footer: SmartRefresherHeadFooter.init().getFooter(),
                  header: SmartRefresherHeadFooter.init().getHeader(),
                  controller: _refreshController,
                  onLoading: () {
                    requestActivity(isRefresh: false);
                  },
                  onRefresh: () {
                    requestActivity(isRefresh: true);
                  },
                  child: isShowDefaultMap
                      ? ActivityDefaultMap()
                      : ListView.builder(
                          itemCount: activityList.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            interceptText(activityList[index]);
                            return ActivityListItem(
                              activityModel: activityList[index],
                              index: index,
                            );
                          })),
        ));
  }
}

class ActivityListItem extends StatefulWidget {
  int index;
  ActivityModel activityModel;

  ActivityListItem({Key key, this.index, this.activityModel}) : super(key: key);

  @override
  _ActivityListItem createState() => _ActivityListItem();
}

class _ActivityListItem extends State<ActivityListItem> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("卡卡卡${widget.activityModel.activityTitle1} :::: ${widget.activityModel.activityTitle}");
  }

  // 活动状态数字解析文字
  NumberParsedText(int ctivityEnum) {
    int activity = ctivityEnum;
    String activityText;
    switch (activity) {
      case 0:
        activityText = "召集中";
        break;
      case 1:
        activityText = "召集满";
        break;
      case 2:
        activityText = "进行中";
        break;
      case 3:
        activityText = "活动结束";
        break;
    }
    return activityText;
  }

  // 活动标签数字解析文字
  tagParsedText(int tag) {
    String activityTag;
    switch (tag) {
      case 0:
        activityTag = "官方";
        break;
      case 1:
        activityTag = "好友";
        break;
      case 2:
        activityTag = "未签到";
        break;
      case 3:
        activityTag = "已签到";
        break;
    }
    return activityTag;
  }

  // 标题横向布局
  titleHorizontalLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        filterTags(widget.activityModel.status),
        SizedBox(
          width: 6,
        ),
        Container(
          width: (ScreenUtil.instance.width * 0.49 - widget.activityModel.tagWidth).toDouble(),
          child: Text(
            widget.activityModel.activityTitle,
            style: AppStyle.whiteMedium17,
            maxLines: 1,
          ),
        )
      ],
    );
  }

// 标题纵向布局
  titleVerticalLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        titleHorizontalLayout(),
        Container(
          width: ScreenUtil.instance.width * 0.49,
          child: Text(
            widget.activityModel.activityTitle1,
            style: AppStyle.whiteMedium17,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        )
      ],
    );
  }

  // 筛选标签
  filterTags(int tag) {
    Widget cotainer;
    if (tag == 0 || tag == 1) {
      cotainer = Container(
        width: 50,
        height: 18,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: tag == 1 ? AppColor.mainBlue : AppColor.mainGreen,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Text(
          NumberParsedText(tag),
          style: AppStyle.whiteRegular10,
        ),
      );
    } else if (tag == 3) {
      cotainer = Container(
        width: 55,
        height: 18,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColor.textWhite60,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Text(
          NumberParsedText(tag),
          style: AppStyle.whiteRegular10,
        ),
      );
    } else if (tag == 2) {
      cotainer = Container(
        width: 53,
        height: 21,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColor.layoutBgGrey,
          border: Border.all(color: AppColor.mainYellow, width: 0.5),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Container(
          width: 50,
          height: 18,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColor.mainYellow,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Text(NumberParsedText(tag), style: TextStyle(fontSize: 10, color: AppColor.mainBlack)),
        ),
      );
    }
    return cotainer;
  }

  //  横排活动参与头像
  roundedAvatar(BuildContext context, String url, int index, {double radius = 10.5}) {
    return Positioned(
        left: index * 10.0,
        child: ClipOval(
          child: Container(
            width: 21,
            height: 21,
            color: AppColor.white,
            alignment: Alignment.center,
            child: ClipOval(
                child: CachedNetworkImage(
              height: 19,
              width: 19,
              // useOldImageOnUrlChange: true,
              memCacheWidth: 150,
              memCacheHeight: 150,
              imageUrl: url != null ? FileUtil.getSmallImage(url) : "",
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: AppColor.imageBgGrey,
              ),
              errorWidget: (context, url, e) {
                return Container(
                  color: AppColor.imageBgGrey,
                );
              },
            )),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AppRouter.navigateActivityDetailPage(context, widget.activityModel.id, activityModel: widget.activityModel);
      },
      child: Card(
        clipBehavior: Clip.hardEdge,
        color: AppColor.layoutBgGrey,
        margin: EdgeInsets.only(left: 16, right: 16, top: widget.index == 0 ? 18 : 12),
        child: Container(
          margin: EdgeInsets.only(top: 12, bottom: 12),
          child: Row(
            children: [
              // 右边布局
              Container(
                margin: EdgeInsets.only(
                  left: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // 活动标题布局
                    Container(
                      constraints: BoxConstraints(
                        minHeight: 47.0,
                        minWidth: ScreenUtil.instance.width * 0.49,
                      ),
                      alignment: Alignment.topLeft,
                      child:
                          widget.activityModel.activityTitle1 != null ? titleVerticalLayout() : titleHorizontalLayout(),
                    ),

                    // 地址布局
                    Container(
                      padding: EdgeInsets.only(top: 6),
                      width: ScreenUtil.instance.width * 0.49,
                      child: Text(
                        widget.activityModel.address,
                        style: AppStyle.text1Regular12,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // 时间布局
                    Container(
                      padding: EdgeInsets.only(top: 2),
                      child: Text(
                        DateUtil.activityTimeToString(widget.activityModel.startTime),
                        style: AppStyle.text1Regular12,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    // 底部布局
                    Container(
                        child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 72,
                          height: 21,
                          child: Stack(
                              clipBehavior: Clip.none,
                              alignment: const FractionalOffset(0, 0.5),
                              children: List.generate(
                                  widget.activityModel.members.length,
                                  (index) =>
                                      roundedAvatar(context, widget.activityModel.members[index].avatarUri, index))),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Text(
                          "${widget.activityModel.members.length}/${widget.activityModel.count}",
                          style: AppStyle.text1Regular12,
                        ),
                        SizedBox(
                          width: 4,
                        ),
                        widget.activityModel.tag == null
                            ? Container()
                            : Container(
                                width: 57,
                                height: 23,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    border: Border.all(color: AppColor.mainYellow, width: 0.5),
                                    borderRadius: BorderRadius.all(Radius.circular(12))),
                                child: Text(
                                  tagParsedText(widget.activityModel.tag),
                                  style: AppStyle.whiteRegular10,
                                ),
                              ),
                      ],
                    ))
                  ],
                ),
              ),
              Spacer(),
              // 头像布局
              ClipPath(
                clipper: ShapeBorderClipper(
                  shape: ClipImageLeftCorner(),
                ),
                child: Stack(
                  children: [
                    CachedNetworkImage(
                      /// imageUrl的淡入动画的持续时间。
                      width: 121,
                      height: 121,
                      fadeInDuration: Duration(milliseconds: 0),
                      fit: BoxFit.cover,
                      // useOldImageOnUrlChange: true,
                      imageUrl: FileUtil.getMediumImage(widget.activityModel.pic),
                      placeholder: (context, url) {
                        return Container(
                          color: AppColor.imageBgGrey,
                        );
                      },
                      errorWidget: (context, url, e) {
                        return Container(
                          color: AppColor.imageBgGrey,
                        );
                      },
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColor.mainBlack.withOpacity(0.6),
                          borderRadius: BorderRadius.circular((15.0)),
                        ),
                        child: Image.asset(ActivityTypeData.init().getIconStringIndex(widget.activityModel.type)[1],
                            width: 30, height: 30),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                width: 12,
              )
            ],
          ),
        ),
      ),
    );
  }
}
