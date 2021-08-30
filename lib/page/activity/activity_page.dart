import 'package:amap_location_muka/amap_location_muka.dart';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:menu_button/menu_button.dart';
import 'package:mirror/api/amap/amap.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/peripheral_information_entity/peripheral_information_entify.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/text_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/custom_button.dart';
import 'package:mirror/widget/dialog.dart';
import 'package:mirror/widget/icon.dart';
import 'package:permission_handler/permission_handler.dart';

/// activity_page
/// Created by yangjiayi on 2021/8/25.

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
  String location_address;

  // 菜单Key
  String selectedKey;

  // 菜单
  List<String> keys = <String>[
    '已参加',
    '召集中',
    '召集满',
    '活动中',
    '已结束',
  ];

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    locationPermissions();
    WidgetsBinding.instance.addObserver(this);
  }

  ///监听用户回到app
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      backToBack();
    }
  }

  // 获取定位权限
  locationPermissions() async {
    // 获取定位权限
    permissions = await Permission.locationWhenInUse.status;
    // 已经获取了定位权限
    if (permissions.isGranted) {
      print("flutter定位只能获取到经纬度信息");
      currentAddressInfo = await AmapLocation.fetch(iosAccuracy: AmapLocationAccuracy.HUNDREE_METERS);
      print("currentAddressInfo::::::${currentAddressInfo.toJson()}");
      reverseGeocoding();
    } else {
      // 请求定位权限
      permissions = await Permission.locationWhenInUse.request();
      if (permissions.isGranted) {
        currentAddressInfo = await AmapLocation.fetch(iosAccuracy: AmapLocationAccuracy.HUNDREE_METERS);
        reverseGeocoding();
      }
    }
  }

  // 逆地理编码
  reverseGeocoding() async {
    PeripheralInformationEntity locationInformationEntity =
        await reverseGeographyHttp(currentAddressInfo.longitude, currentAddressInfo.latitude);
    if (locationInformationEntity.status == "1") {
      print('请求成功');
      location_address = locationInformationEntity.regeocode.cityDetails.city;
      setState(() {});
      print(location_address);
    } else {
      // 请求失败
    }
  }

  // 前台回到后台
  backToBack() async {
    var status = await Permission.locationWhenInUse.status;
    if (permissions != null && permissions != PermissionStatus.granted && status == PermissionStatus.granted) {
      //flutter定位只能获取到经纬度信息
      currentAddressInfo = await AmapLocation.fetch(iosAccuracy: AmapLocationAccuracy.HUNDREE_METERS);
      // 调用周边
      locationPermissions();
    }
  }

  // 请求活动接口数据
  requestActivity() async {}

  // 定位失败弹窗
  _locationFailPopUps() {
    return showAppDialog(context,
        title: "位置信息",
        info: "你没有开通位置权限，您可以通过系统\"设置\"进行权限管理",
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
    return Container(
      width: 70,
      height: 44,
      margin: EdgeInsets.only(left: 8),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_on_rounded,
            color: AppColor.white,
            size: 16,
          ),
          SizedBox(
            width: 3,
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (permissions != PermissionStatus.granted) {
                // 弹窗
                _locationFailPopUps();
              } else {
                // 地址选择下拉列表
              }
            },
            child: Container(
              child: Text(
                location_address ?? "北京",
                style: AppStyle.whiteRegular12,
              ),
            ),
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
    );
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
              Text(selectedKey ?? "筛选", style: AppStyle.whiteRegular12, overflow: TextOverflow.ellipsis),
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
    return Scaffold(
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
            divider: Container(),
            items: keys,
            itemBuilder: (String value) => Container(
                color: AppColor.layoutBgGrey,
                height: 22,
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      value,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w400, color: AppColor.white),
                    ),
                  ],
                )),
            toggledChild: Container(
              child: normalChildButton(),
            ),
            onItemSelected: (String value) {
              setState(() {
                selectedKey = value;
              });
            },
            // onMenuButtonToggle: (bool isToggle) {
            //   print(isToggle);
            // },
          ),
        ],
      ),
      body: ListView.builder(
          itemCount: 10,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return ActivityListItem(
              index: index,
            );
          }),
      floatingActionButton: new Builder(builder: (BuildContext context) {
        return new FloatingActionButton(
          child: const Icon(Icons.add),
          foregroundColor: AppColor.mainBlack,
          backgroundColor: AppColor.white,
          heroTag: null,
          elevation: 7.0,
          highlightElevation: 14.0,
          onPressed: () {},
          mini: false,
          shape: new CircleBorder(),
          isExtended: false,
        );
      }),
      backgroundColor: AppColor.mainBlack,
    );
  }
}

class ActivityListItem extends StatefulWidget {
  int index;

  ActivityListItem({this.index});

  @override
  _ActivityListItem createState() => _ActivityListItem();
}

class _ActivityListItem extends State<ActivityListItem> {
  String serverReturnsTitle = "3V3篮球正在进行中!速速报名参加哦！";
  String activityTitle = "";
  String activityTitle1 = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    interceptText();
  }

  // 截取文本
  interceptText() {
    // 剩余宽度
    double remainingWidth = ScreenUtil.instance.width * 0.49 - 56;
    // 文本总宽度
    double totalTextWidth = 0.0;
    for (int i = 0; i < serverReturnsTitle.length; i++) {
      // 文本宽度
      double textWidth = getTextSize(serverReturnsTitle[i], AppStyle.whiteMedium17, 1).width;
      totalTextWidth += textWidth;
      if (totalTextWidth > remainingWidth) {
        activityTitle1 += serverReturnsTitle[i];
      } else {
        activityTitle += serverReturnsTitle[i];
      }
    }
    setState(() {});
  }

  // 标题横向布局
  titleHorizontalLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 50,
          child: CustomYellowButton(
            "准备中",
            0,
            () {},
            width: 50,
            height: 18,
          ),
        ),
        SizedBox(
          width: 6,
        ),
        Container(
          width: ScreenUtil.instance.width * 0.49 - 56,
          child: Text(
            activityTitle,
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
        Text(
          activityTitle1,
          style: AppStyle.whiteMedium17,
          maxLines: 1,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      color: AppColor.layoutBgGrey,
      margin: EdgeInsets.only(left: 16, right: 16, top: widget.index == 0 ? 18 : 12),
      child: Container(
        width: ScreenUtil.instance.width - 32,
        height: 140,
        child: Row(
          children: [
            // 右边布局
            Container(
              margin: EdgeInsets.only(left: 12, top: 13.5, bottom: 13.5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 活动标题布局
                  Container(
                      width: ScreenUtil.instance.width * 0.49,
                      child: activityTitle1.length > 0 ? titleVerticalLayout() : titleHorizontalLayout()),
                  // 地址布局
                  Container(
                    padding: EdgeInsets.only(top: 6),
                    child: Text(
                      "天府三街福年广场",
                      style: AppStyle.text1Regular12,
                    ),
                  ),
                  // 时间布局
                  Container(
                    padding: EdgeInsets.only(top: 2),
                    child: Text(
                      "18:30 8月18日 周六",
                      style: AppStyle.text1Regular12,
                    ),
                  ),
                  // 底部布局

                ],
              ),
            ),
            // 头像布局
            // http://devpic.aimymusic.com/ifcms/ca4d089cc7e57ac75666187ae40fe2bb.jpeg
             ClipPath(
               clipper: ShapeBorderClipper(
                 // shape: ClipImageLeftCorner(),
               ),
             )
          ],
        ),
      ),
    );
  }
}
