import 'dart:async';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/setting_api/setting_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/user_notice_model.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/custom_button.dart';
import 'package:mirror/widget/dialog.dart';
import 'package:mirror/widget/icon.dart';
import 'package:notification_permissions/notification_permissions.dart';
import 'package:provider/provider.dart';

///通知设置
class NoticeSettingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _NoticeSettingState();
  }
}

class _NoticeSettingState extends State<NoticeSettingPage> with WidgetsBindingObserver {
  Future<String> permissionStatusFuture;
  var permGranted = "granted";
  var permDenied = "denied";
  var permUnknown = "unknown";
  var permProvisional = "provisional";
  StreamController<SettingNotifileModel> streamController = StreamController<SettingNotifileModel>();
  SettingNotifileModel settingNotifileModel = SettingNotifileModel(

  );

  //设置用户通知设置
  Future<bool> _setUserNotice(int type, int isOpen) async {
    var noticeState = await setUserNotice(type, isOpen);
    return noticeState;
  }

  //获取用户通知设置
  _getUserNotice() async {
    UserNoticeModel model = await getUserNotice();
    if (model != null) {
      model.list.forEach((element) {
        switch (element.type + 1) {
          case 1:
            settingNotifileModel.notFollow = element.isOpen == 0 ? false : true;
            break;
          case 2:
            settingNotifileModel.followBuddy = element.isOpen == 0 ? false : true;
            break;
          case 3:
            settingNotifileModel.mentionedMe = element.isOpen == 0 ? false : true;
            break;
          case 4:
            settingNotifileModel.comment = element.isOpen == 0 ? false : true;
            break;
          case 5:
            settingNotifileModel.laud = element.isOpen == 0 ? false : true;
            break;
        }
        streamController.sink.add(settingNotifileModel);
      });
    }
  }

  ///获取系统通知状态
  Future<String> getCheckNotificationPermStatus(bool isFirst) {
    return NotificationPermissions.getNotificationPermissionStatus().then((status) {
      switch (status) {
        case PermissionStatus.denied:
          settingNotifileModel.permisionIsOpen = false;
          if (isFirst) {
            _showDialog();
          }
          streamController.sink.add(settingNotifileModel);
          return permDenied;
        case PermissionStatus.granted:
          settingNotifileModel.permisionIsOpen = true;
          streamController.sink.add(settingNotifileModel);
          return permGranted;
        case PermissionStatus.unknown:
          settingNotifileModel.permisionIsOpen = false;
          if (isFirst) {
            _showDialog();
          }
          streamController.sink.add(settingNotifileModel);
          return permUnknown;
        case PermissionStatus.provisional:
          settingNotifileModel.permisionIsOpen = false;
          if (isFirst) {
            _showDialog();
          }
          streamController.sink.add(settingNotifileModel);
          return permProvisional;
        default:
          return null;
      }
    });
  }

  @override

  ///监听用户回到app
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() {
        permissionStatusFuture = getCheckNotificationPermStatus(false);
      });
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    //解绑监听
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void initState() {
    super.initState();
    //绑定监听
    WidgetsBinding.instance.addObserver(this);
    permissionStatusFuture = getCheckNotificationPermStatus(true);
    _getUserNotice();
  }

  @override
  Widget build(BuildContext context) {
    print('=====================build');
    double width = ScreenUtil.instance.screenWidthDp;
    double height = ScreenUtil.instance.height;
    return Scaffold(
        backgroundColor: AppColor.white,
        appBar: CustomAppBar(
          titleString: "通知设置",
        ),
        body: StreamBuilder<SettingNotifileModel>(
            initialData: settingNotifileModel,
            stream: streamController.stream,
            builder: (BuildContext stramContext, AsyncSnapshot<SettingNotifileModel> snapshot) {
              return Container(
                padding: EdgeInsets.only(left: 16, right: 16),
                width: width,
                height: height,
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        AppSettings.openNotificationSettings();
                      },
                      child: _getNotice(snapshot.data),
                    ),
                    Container(
                      height: 0.5,
                      color: AppColor.bgWhite,
                      width: width,
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Container(
                      height: 32,
                      width: width,
                      child: Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "私信通知",
                          style: AppStyle.textSecondaryRegular14,
                        ),
                      ),
                    ),
                    _switchRow(width, 0, snapshot.data.notFollow, "未关注私信人", snapshot.data),
                    _switchRow(width, 1, snapshot.data.followBuddy, "我关注及好友私信", snapshot.data),
                    SizedBox(
                      height: 12,
                    ),
                    Container(
                      height: 32,
                      width: width,
                      child: Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "互动通知",
                          style: AppStyle.textSecondaryRegular14,
                        ),
                      ),
                    ),
                    _switchRow(width, 2, snapshot.data.mentionedMe, "@我", snapshot.data),
                    _switchRow(width, 3, snapshot.data.comment, "评论", snapshot.data),
                    _switchRow(width, 4, snapshot.data.laud, "赞", snapshot.data),
                  ],
                ),
              );
            }));
  }

  ///接收通知设置
  Widget _getNotice(SettingNotifileModel notifile) {
    return Container(
        height: 48,
        child: Center(
          child: Row(
            children: [
              Text(
                "接收推送通知",
                style: AppStyle.textRegular16,
              ),
              Spacer(),
              Text(
                notifile.permisionIsOpen ? "已开启" : "未开启",
                style: AppStyle.textHintRegular16,
              ),
              SizedBox(
                width: 12,
              ),
              AppIcon.getAppIcon(
                AppIcon.arrow_right_18,
                18,
                color: AppColor.black,
              ),
            ],
          ),
        ));
  }

  Widget _showDialog() {
    return showAppDialog(context,
        title: "获取系统通知设置",
        info: "第一时间获取评论,私信,@,等消息通知",
        cancel: AppDialogButton("取消", () {
          return true;
        }),
        confirm: AppDialogButton(
          "去打开",
          () {
            AppSettings.openNotificationSettings();
            return true;
          },
        ),
        barrierDismissible: false);
  }

  Widget _switchRow(double width, int type, bool isOpen, String title, SettingNotifileModel notifile) {
    return GestureDetector(
      onTap: () {
        if (notifile.permisionIsOpen) {
          return false;
        } else {
          _showDialog();
        }
      },
      child: Container(
        height: 48,
        width: width,
        child: Center(
          child: Row(
            children: [
              Text(
                title,
                style: AppStyle.textRegular16,
              ),
             Spacer(),
              SelectButton(
                isOpen,
                canOnClick: notifile.permisionIsOpen ? true : false,
                changeCallBack: (value) {
                  switch (type) {
                    case 0:
                      return _setUserNotice(0, notifile.notFollow ? 0 : 1);
                      break;
                    case 1:
                      return _setUserNotice(1, notifile.followBuddy ? 0 : 1);
                      break;
                    case 2:
                      return _setUserNotice(2, notifile.mentionedMe ? 0 : 1);
                      break;
                    case 3:
                      return _setUserNotice(3, notifile.comment ? 0 : 1);
                      break;
                    case 4:
                      return _setUserNotice(4, notifile.laud ? 0 : 1);
                      break;
                  }
                  return null;
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

class SettingNotifileModel {
  //未关注私信人  1
  bool notFollow;

  //我关注及好友私信  2
  bool followBuddy;

  //@我  3
  bool mentionedMe;

  //评论  4
  bool comment;

  //赞
  bool laud;

  //是否开启权限
  bool permisionIsOpen;

  SettingNotifileModel(
      {this.laud = false,
      this.comment = false,
      this.permisionIsOpen = false,
      this.notFollow = false,
      this.followBuddy = false,
      this.mentionedMe = false});
}
