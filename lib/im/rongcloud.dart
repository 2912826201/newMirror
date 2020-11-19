import 'package:mirror/im/rongcloud_receive_manager.dart';
import 'package:mirror/im/rongcloud_status_manager.dart';
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

abstract class RongCloud {
  static RongCloud _me;
  static RongCloud shareInstance(){
    if (_me==null){
      _me = _getCore();
      _me.statusManager = RongCloudStatusManager.shareInstance();
      _me.receiveManager = RongCloudReceiveManager.shareInstance();
    }
    return _me;
  }
  //关联一下融云状态管理和消息接受管理
  RongCloudStatusManager statusManager;
  RongCloudReceiveManager receiveManager;
  //连接融云服务器
  void connect(String token, Function(int code, String userId) finished) {
    _getCore()._connect(token, finished);
  }
  //断开融云服务器
  void disconnect() {
    _getCore()._disconnect();
  }
  void imToken();
}

class _RongCloudCore extends RongCloud{
  void _init() {
    RongIMClient.init(AppConfig.getRCAppKey());

  }
  void _connect(String token, Function(int code, String userId) finished) {
    RongIMClient.connect(token, finished);
  }
  void _disconnect() {
    RongIMClient.disconnect(false);
  }

  @override
  void imToken() {
    // TODO: implement imToken
  }

}
