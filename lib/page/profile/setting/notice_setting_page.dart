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
  //设置用户通知设置
  _setUserNotice(int type, int isOpen) async {
    var noticeState = await setUserNotice(type, isOpen);
    if (noticeState != null) {
      if (noticeState) {
        context.read<SettingNotifile>().changeSwitchButton(type + 1);
        return;
      }
    }
    print('---------###################################################---');
    context.read<SettingNotifile>().changeSwitchButton(type + 1, breakToBefore: true);
  }

  //获取用户通知设置
  _getUserNotice() async {
    UserNoticeModel model = await getUserNotice();
    if (model != null) {
      model.list.forEach((element) {
        context.read<SettingNotifile>().setSwitchButton(element.type + 1, element.isOpen == 0 ? false : true);
      });
    }
  }

  ///获取系统通知状态
  Future<String> getCheckNotificationPermStatus(bool isFirst) {
    return NotificationPermissions.getNotificationPermissionStatus().then((status) {
      switch (status) {
        case PermissionStatus.denied:
          context.read<SettingNotifile>().changePermision(false);
          if (isFirst) {
            _showDialog();
          }
          return permDenied;
        case PermissionStatus.granted:
          context.read<SettingNotifile>().changePermision(true);
          return permGranted;
        case PermissionStatus.unknown:
          context.read<SettingNotifile>().changePermision(false);
          if (isFirst) {
            _showDialog();
          }
          return permUnknown;
        case PermissionStatus.provisional:
          context.read<SettingNotifile>().changePermision(false);
          if (isFirst) {
            _showDialog();
          }
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
        body: Consumer<SettingNotifile>(builder: (context, notifier, child) {
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
                  child: _getNotice(notifier),
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
                _switchRow(width, 0, notifier.notFollow, "未关注私信人",notifier),
                _switchRow(width, 1, notifier.followBuddy, "我关注及好友私信",notifier),
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
                _switchRow(width, 2, notifier.mentionedMe, "@我",notifier),
                _switchRow(width, 3, notifier.comment, "评论",notifier),
                _switchRow(width, 4, notifier.laud, "赞",notifier),
              ],
            ),
          );
        }));
  }

  ///接收通知设置
  Widget _getNotice(SettingNotifile notifile) {
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
                Icon(Icons.arrow_forward_ios)
              ],
            ),
          )
    );
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

  Widget _switchRow(double width, int type, bool isOpen, String title,SettingNotifile notifile) {
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
              Expanded(child: SizedBox()),
              SelectButton(
                isOpen,
                canOnClick: notifile.permisionIsOpen ? true : false,
                changeCallBack: (value) {
                  switch (type) {
                    case 0:
                      _setUserNotice(0, notifile.notFollow ? 0 : 1);
                      break;
                    case 1:
                      _setUserNotice(1, notifile.followBuddy ? 0 : 1);
                      break;
                    case 2:
                      _setUserNotice(2, notifile.mentionedMe ? 0 : 1);
                      break;
                    case 3:
                      _setUserNotice(3, notifile.comment ? 0 : 1);
                      break;
                    case 4:
                      _setUserNotice(4, notifile.laud ? 0 : 1);
                      break;
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

class SettingNotifile extends ChangeNotifier {
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

  SettingNotifile(
      {this.laud = false,
      this.comment = false,
      this.permisionIsOpen = false,
      this.notFollow = false,
      this.followBuddy = false,
      this.mentionedMe = false});

  void changePermision(bool result) {
    permisionIsOpen = result;
    notifyListeners();
  }

  void setSwitchButton(int type, bool result) {
    switch (type) {
      case 1:
        notFollow = result;
        break;
      case 2:
        followBuddy = result;
        break;
      case 3:
        mentionedMe = result;
        break;
      case 4:
        comment = result;
        break;
      case 5:
        laud = result;
        break;
    }
    notifyListeners();
  }

  void changeSwitchButton(int type, {bool breakToBefore = false}) {
    switch (type) {
      case 1:
        notFollow = breakToBefore ? notFollow : !notFollow;
        break;
      case 2:
        followBuddy = breakToBefore ? followBuddy : !followBuddy;
        break;
      case 3:
        mentionedMe = breakToBefore ? mentionedMe : !mentionedMe;
        break;
      case 4:
        comment = breakToBefore ? comment : !comment;
        break;
      case 5:
        laud = breakToBefore ? laud : !laud;
        break;
    }
    notifyListeners();
  }
}
