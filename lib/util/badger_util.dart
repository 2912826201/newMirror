import 'package:flutter/services.dart';

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
    _channel.invokeMethod('updateBadgeCount', badgeCount);
  }

  //移除个数
  removeBadge() {
    _channel.invokeMethod('removeBadge');
  }

  //判断是不是支持设置badger
  Future<bool> isAppBadgeSupported() async {
    bool appBadgeSupported = await _channel.invokeMethod('isAppBadgeSupported');
    return appBadgeSupported ?? false;
  }
}
