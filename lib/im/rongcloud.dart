import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

import '../config/config.dart';

/// rongcloud
/// Created by yangjiayi on 2020/11/2.

class RongCloud {
  //初始化融云组件
  void init() {
    RongIMClient.init(AppConfig.getRCAppKey());
  }
  //连接融云服务器
  void connect(String token, Function(int code, String userId) finished) {
    RongIMClient.connect(token, finished);
  }
  //断开融云服务器
  void disconnect() {
    RongIMClient.disconnect(false);
  }
}
