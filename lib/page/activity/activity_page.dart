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
import 'package:mirror/util/check_phone_system_util.dart';
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
  //?????????
  HaveParticipated,
  // ?????????
  Convene,
  // ?????????
  CalledFull,
  //?????????
  Active,
  //?????????
  over,
}

class ActivityPage extends StatefulWidget {
  @override
  _ActivityState createState() => _ActivityState();
}

class _ActivityState extends State<ActivityPage> with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  @override
  bool get wantKeepAlive => true; //????????????
  // ??????
  PermissionStatus permissions;
  Location currentAddressInfo; //?????????????????????

  // ????????????
  StreamController<String> streamAddress = StreamController<String>();

  // ?????? ??????
  String citycode;

  //  ???????????????
  ActivityFilter selectedKey;

  // ??????
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

  // ?????????
  String longitude;
  String latitude;
  RefreshController _refreshController = RefreshController(); // ?????????????????????
  // ?????????????????????
  bool isShowDefaultMap;

  // ???????????????????????????????????????
  StreamController<int> streamActiviityUnread = StreamController<int>();

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    EventBus.init().unRegister(pageName: EVENTBUS_ACTIVITY_LIST_PAGE, registerName: ACTIVITY_LIST_RESET);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    locationPermissions();
    EventBus.init().registerSingleParameter(_applyListUnread, EVENTBUS_ACTIVITY_HOME_PAGE,
        registerName: ACTIVITY_PAGE_GET_APPLYLISTUNREAD);
    EventBus.init().registerNoParameter(_resetPage, EVENTBUS_ACTIVITY_LIST_PAGE, registerName: ACTIVITY_LIST_RESET);
    WidgetsBinding.instance.addObserver(this);
  }

  ///??????????????????app
  /// // ??????????????????
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      locationPermissions(isDidChangeAppLifecycle: true);
    }
  }

  // ??????????????????
  locationPermissions({bool isDidChangeAppLifecycle = false}) async {
    // ??????????????????
    permissions = await Permission.locationWhenInUse.status;
    print("????????????permissions????????????$permissions");
    // ???????????????????????????
    if (permissions.isGranted) {
      print("flutter????????????????????????????????????");
      try {
        currentAddressInfo = await AmapLocation.fetch(iosAccuracy: AmapLocationAccuracy.HUNDREE_METERS);
        print("currentAddressInfo::::::${currentAddressInfo.toJson()}");
        latitude = currentAddressInfo.latitude.toString();
        longitude = currentAddressInfo.longitude.toString();
        citycode = null;
        reverseGeocoding();
      } catch (error) {}
      requestActivity(isRefresh: true);
    } else if (isDidChangeAppLifecycle == false) {
      print("???????????????");
      // ??????????????????
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
        // ????????????
        citycode = "028";
        latitude = null;
        longitude = null;
        requestActivity(isRefresh: true);
      }
    }
  }

  // ???????????????
  reverseGeocoding() async {
    PeripheralInformationEntity locationInformationEntity =
        await reverseGeographyHttp(currentAddressInfo.longitude, currentAddressInfo.latitude);
    if (locationInformationEntity.status == "1") {
      print('????????????');
      citycode = locationInformationEntity.regeocode.cityDetails.citycode;
      streamAddress.sink.add(locationInformationEntity.regeocode.cityDetails.city);
    } else {
      // ????????????
    }
  }

  //
  _applyListUnread(int unread) {
    streamActiviityUnread.sink.add(unread);
  }

  //????????????
  _resetPage() {
    requestActivity(isRefresh: true);
  }

  // ????????????????????????
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
        print("?????????");
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

  // ??????????????????
  enumerateParsedText(ActivityFilter ctivityEnum) {
    ActivityFilter activity = ctivityEnum;
    String activityText;
    switch (activity) {
      case ActivityFilter.HaveParticipated:
        activityText = "?????????";
        break;
      case ActivityFilter.Convene:
        activityText = "?????????";
        break;
      case ActivityFilter.CalledFull:
        activityText = "?????????";
        break;
      case ActivityFilter.Active:
        activityText = "?????????";
        break;
      case ActivityFilter.over:
        activityText = "?????????";
        break;
      default:
        activityText = "??????";
    }
    return activityText;
  }

  // ??????????????????
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

  // ??????????????????
  _locationFailPopUps() {
    return showAppDialog(context,
        title: "????????????",
        info: "???????????????????????????????????????????????????\"??????\"??????????????????",
        confirmColor: AppColor.white,
        cancel: AppDialogButton("??????", () {
          return true;
        }),
        confirm: AppDialogButton("?????????", () {
          AppSettings.openLocationSettings();
          return true;
        }));
  }

  // ??????View
  Widget headView() {
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () async {
          print("????????????");
          if (Platform.isAndroid) {
            print("??????????????????$permissions");
            if (permissions != PermissionStatus.granted) {
              print("1111111111111");
              // ??????
              _locationFailPopUps();
            }
          } else if (Platform.isIOS) {
            if (permissions == PermissionStatus.denied) {
              print("00000000");
              // // ??????????????????
              permissions = await Permission.locationWhenInUse.request();
              print("permissions::::$permissions");
              if (permissions.isGranted) {
                currentAddressInfo = await AmapLocation.fetch(iosAccuracy: AmapLocationAccuracy.HUNDREE_METERS);
                reverseGeocoding();
              }
            } else if (permissions != PermissionStatus.granted) {
              print("1111111111111");
              // ??????
              _locationFailPopUps();
            }
          }
          if (permissions == PermissionStatus.granted) {
            print("222222222");
            // ????????????????????????
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
                    initialData: "??????",
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

  // ?????????????????????
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
          // print('?????????????????????');
          if (!(mounted && context.read<TokenNotifier>().isLoggedIn)) {
            ToastShow.show(msg: "????????????app!", context: context);
            AppRouter.navigateToLoginPage(context);
            return;
          } else {
            // ??????????????????
            AppRouter.navigateCreateActivityPage(context);
          }
        },
        child: Scaffold(
          backgroundColor: AppColor.mainBlack,
          appBar: CustomAppBar(
            titleString: "??????",
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
                        // IgnorePointer(
                        // // ???false???????????????
                        // ignoring: false,
                        // child:TextButton(child:Text("???"),autofocus:true,onPressed: (){
                        //       print("aaaaa");
                        //     },)),
                        AppIcon.getAppIcon(AppIcon.activity_unread, 16, color: AppColor.white),
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
    print("?????????${widget.activityModel.activityTitle1} :::: ${widget.activityModel.activityTitle}");
  }

  // ??????????????????????????????
  NumberParsedText(int ctivityEnum) {
    int activity = ctivityEnum;
    String activityText;
    switch (activity) {
      case 0:
        activityText = "?????????";
        break;
      case 1:
        activityText = "?????????";
        break;
      case 2:
        activityText = "?????????";
        break;
      case 3:
        activityText = "????????????";
        break;
    }
    return activityText;
  }

  // ??????????????????????????????
  tagParsedText(int tag) {
    String activityTag;
    switch (tag) {
      case 0:
        activityTag = "??????";
        break;
      case 1:
        activityTag = "??????";
        break;
      case 2:
        activityTag = "?????????";
        break;
      case 3:
        activityTag = "?????????";
        break;
    }
    return activityTag;
  }

  // ??????????????????
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

// ??????????????????
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

  // ????????????
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

  //  ????????????????????????
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
              // ????????????
              Container(
                margin: EdgeInsets.only(
                  left: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // ??????????????????
                    Container(
                      constraints: BoxConstraints(
                        minHeight: 47.0,
                        minWidth: ScreenUtil.instance.width * 0.49,
                      ),
                      alignment: Alignment.topLeft,
                      child:
                          widget.activityModel.activityTitle1 != null ? titleVerticalLayout() : titleHorizontalLayout(),
                    ),

                    // ????????????
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
                    // ????????????
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
                    // ????????????
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
                          "${widget.activityModel.joinAmount ?? 0}/${widget.activityModel.count}",
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
              // ????????????
              ClipPath(
                clipper: ShapeBorderClipper(
                  shape: ClipImageLeftCorner(),
                ),
                child: Stack(
                  children: [
                    CachedNetworkImage(
                      /// imageUrl?????????????????????????????????
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
