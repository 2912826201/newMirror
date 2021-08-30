import 'package:amap_location_muka/amap_location_muka.dart';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:menu_button/menu_button.dart';
import 'package:mirror/api/amap/amap.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/peripheral_information_entity/peripheral_information_entify.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/dialog.dart';
import 'package:mirror/widget/icon.dart';
import 'package:permission_handler/permission_handler.dart';

/// activity_page
/// Created by yangjiayi on 2021/8/25.

class ActivityPage extends StatefulWidget {
  @override
  _ActivityState createState() => _ActivityState();
}

class _ActivityState extends State<ActivityPage> {
  // 权限
  PermissionStatus permissions;
  Location currentAddressInfo; //当前位置的信息
  // 定位地址
  String location_address = "北京";

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
  void initState() {
    super.initState();
    locationPermissions();
  }

  // 获取定位权限
  locationPermissions() async {
    // 获取权限状态
    permissions = await Permission.locationWhenInUse.status;
    switch (permissions) {
      // 用户拒绝访问请求的功能
      case PermissionStatus.denied:
        return 0;
      // 用户授予了对所请求功能的访问权限
      case PermissionStatus.granted:
        //flutter定位只能获取到经纬度信息
        print("flutter定位只能获取到经纬度信息");
        currentAddressInfo = await AmapLocation.fetch(iosAccuracy: AmapLocationAccuracy.HUNDREE_METERS);
        print("currentAddressInfo::::::${currentAddressInfo.toJson()}");
        reverseGeocoding();
        return 1;

      ///操作系统拒绝访问请求的功能。 用户无法更改
      ///此应用程序的状态，可能是由于活动限制（例如父母身份）
      ///控制就位。
      /// *仅在iOS上受支持。*
      case PermissionStatus.restricted:
        return 2;

      ///部分许可 ios14
      case PermissionStatus.limited:
        return 3;

      ///用户拒绝访问请求的功能，并选择从不
      ///再次显示对此权限的请求。 用户仍然可以更改
      ///设置中的权限状态。
      /// *仅在Android上受支持。
      case PermissionStatus.permanentlyDenied:
        return 4;
      default:
        throw UnimplementedError();
    }
  }

  // 逆地理编码
  reverseGeocoding() async {
    PeripheralInformationEntity locationInformationEntity =
        await reverseGeographyHttp(currentAddressInfo.longitude, currentAddressInfo.latitude);
    if (locationInformationEntity.status == "1") {
      print('请求成功');
      location_address = locationInformationEntity.regeocode.cityDetails.city;
      print(location_address);
    } else {
      // 请求失败
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
      width: ScreenUtil.instance.width - 32,
      height: 44,
      margin: EdgeInsets.only(left: 16),
      child: Row(
        children: [
          Text(
            "推荐",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppColor.white),
          ),
          SizedBox(
            width: 8,
          ),
          Icon(
            Icons.location_on_rounded,
            color: AppColor.white,
            size: 16,
          ),
          SizedBox(
            width: 4,
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
              padding: const EdgeInsets.only(left: 4, top: 2, bottom: 2, right: 4),
              decoration: BoxDecoration(border: Border.all(color: AppColor.white)
                  // borderRadius: new BorderRadius.all(new Radius.circular(2.0)),
                  ),
              child: Text(
                location_address,
                style: AppStyle.whiteRegular14,
              ),
            ),
          ),
          const Spacer(),
          MenuButton(
            itemBackgroundColor: AppColor.mainBlack,
            menuButtonBackgroundColor: AppColor.mainBlack,
            child: normalChildButton(),
            items: keys,
            itemBuilder: (String value) => Container(
              height: 30,
              alignment: Alignment.centerLeft,
              // padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 16),
              margin: const EdgeInsets.only(left: 8),
              child: Text(
                value,
                style: AppStyle.whiteRegular12,
              ),
            ),
            toggledChild: Container(
              child: normalChildButton(),
            ),
            onItemSelected: (String value) {
              setState(() {
                selectedKey = value;
              });
            },
            onMenuButtonToggle: (bool isToggle) {
              print(isToggle);
            },
          ),
          SizedBox(
            width: 16,
          )
        ],
      ),
    );
  }

  // 菜单打开的按钮
  Widget normalChildButton() {
    return SizedBox(
        width: 78,
        height: 30,
        child: Container(
          margin: const EdgeInsets.only(left: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Flexible(
                  child: Text(selectedKey ?? "筛选",
                      style: selectedKey != null
                          ? AppStyle.whiteRegular12
                          : TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColor.textWhite60),
                      overflow: TextOverflow.ellipsis)),
              RotatedBox(
                quarterTurns: 1,
                child: AppIcon.getAppIcon(
                  AppIcon.arrow_right_18,
                  18,
                  color: AppColor.textWhite60,
                ),
              ),
            ],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        hasLeading: false,
        titleString: "活动",
      ),
      body: Column(
        children: [
          headView(),
          Expanded(
              child: ListView.builder(
                  itemCount: 10,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return ActivityListItem();
                  }))
        ],
      ),
      floatingActionButton:  new Builder(builder: (BuildContext context) {
        return new FloatingActionButton(
          child: const Icon(Icons.add),
          tooltip: "Hello",
          foregroundColor: AppColor.white,
          backgroundColor: AppColor.mainBlack,
          heroTag: null,
          elevation: 7.0,
          highlightElevation: 14.0,
          onPressed: () {
          },
          mini: false,
          shape: new CircleBorder(),
          isExtended: false,
        );
      }),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      backgroundColor: AppColor.mainBlack,
    );
  }
}

class ActivityListItem extends StatefulWidget {
  @override
  _ActivityListItem createState() => _ActivityListItem();
}

class _ActivityListItem extends State<ActivityListItem> {
  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      color:AppColor.layoutBgGrey,
      child: Container(
        width: ScreenUtil.instance.width,
        height: 90,
        child: Row(

        ),
      ),
    );
  }
}
