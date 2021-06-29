import 'package:flutter/services.dart';
import 'package:mirror/config/application.dart';
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
  updateBadgeCount(int badgeCount) {
    if (Application.platform == 0) {
      Permission.notification.request().then((value) {
        if (value.isGranted) {
          print("有通知权限");
          _channel.invokeMethod('updateBadgeCount', badgeCount);
        } else if (value.isPermanentlyDenied) {
          print("没有通知权限");
        }
      });
    }
  }

  //移除个数
  removeBadge() {
    if (Application.platform == 0) {
      _channel.invokeMethod('removeBadge');
    }
  }

  //判断是不是支持设置badger
  Future<bool> isAppBadgeSupported() async {
    if (Application.platform == 0) {
      bool appBadgeSupported = await _channel.invokeMethod('isAppBadgeSupported');
      return appBadgeSupported ?? false;
    }
  }
}
