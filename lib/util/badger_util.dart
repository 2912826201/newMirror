import 'package:flutter/services.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/config/shared_preferences.dart';
import 'package:mirror/im/message_manager.dart';
import 'package:mirror/util/check_phone_system_util.dart';
import 'package:permission_handler/permission_handler.dart';

class BadgerUtil {
  static final String _badgerChannel = "com.aimymusic.mirror/app_badger";

  static MethodChannel _channel;

  static BadgerUtil _util;

  static BadgerUtil init() {
    if (_util == null) {
      _util = BadgerUtil();
    }
    if (_channel == null) {
      _channel = MethodChannel(_badgerChannel);
    }
    return _util;
  }

  //更新显示个数
  updateBadgeCount(int badgeCount) async {
    if (CheckPhoneSystemUtil.init().isAndroid()) {
      Permission.notification.request().then((value) async {
        if (value.isGranted) {
          if (await CheckPhoneSystemUtil.init().isHuawei()) {
            //判断是不是华为手机
            Application.jpush.setBadge(badgeCount);
          } else {
            _channel.invokeMethod('updateBadgeCount', badgeCount);
          }
        } else if (value.isPermanentlyDenied) {
          print("没有通知权限");
        }
      });
    }
  }

  //移除个数
  removeBadge() {
    if (CheckPhoneSystemUtil.init().isAndroid()) {
      _channel.invokeMethod('removeBadge');
    }
  }

  //判断是不是支持设置badger
  Future<bool> isAppBadgeSupported() async {
    if (CheckPhoneSystemUtil.init().isAndroid()) {
      bool appBadgeSupported = await _channel.invokeMethod('isAppBadgeSupported');
      return appBadgeSupported ?? false;
    }
  }

  setBadgeCount() {
    int number = MessageManager.unreadNoticeNumber + MessageManager.unreadMessageNumber;
    updateBadgeCount(number);
    AppPrefs.setFlutterAppBadgerCount(number);
  }
}
