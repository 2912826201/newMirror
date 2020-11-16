import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

import '../config/config.dart';

/// rongcloud
/// Created by yangjiayi on 2020/11/2.

_RongCloudCore _core;

//TODO 为了保证使用融云服务时 client被初始化过 暂时采用的方案
_RongCloudCore _getCore() {
  if(_core == null){
    _core = _RongCloudCore();
    _core._init();
  }
  return _core;
}

class RongCloud {
  //连接融云服务器
  void connect(String token, Function(int code, String userId) finished) {
    _getCore()._connect(token, finished);
  }
  //断开融云服务器
  void disconnect() {
    _getCore()._disconnect();
  }
}

class _RongCloudCore {
  void _init() {
    RongIMClient.init(AppConfig.getRCAppKey());
  }

  void _connect(String token, Function(int code, String userId) finished) {
    RongIMClient.connect(token, finished);
  }

  void _disconnect() {
    RongIMClient.disconnect(false);
  }
}
