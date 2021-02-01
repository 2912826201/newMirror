import 'package:flutter/material.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/data/notifier/rongcloud_status_notifier.dart';
import 'package:provider/provider.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

class RongCloudStatusManager {
  BuildContext _context;
  static RongCloudStatusManager _manager;

  static RongCloudStatusManager init(BuildContext context) {
    if (_manager == null) {
      _manager = RongCloudStatusManager();
      _manager._context = context;
    }
    return _manager;
  }

  //响应融云连接状态的变化方法
  onConnectionStatusChange(int connectionStatus) {
    print("RongCloud onConnectionStatusChange $connectionStatus");
    //使用Notifier进行通知
    _context.read<RongCloudStatusNotifier>().setStatus(connectionStatus);
    //状态2是在其他设备登录的情况 这时要触发本机用户登出 不然可能会重复登录两边反复踢对方下线
    if(connectionStatus == RCConnectionStatus.KickedByOtherClient){
      //这里先断开融云连接再做其他处理
      Application.rongCloud.disconnect();
      Application.appLogout();
    }
  }

  //手动更新状态
  setStatus(int connectionStatus) {
    print("RongCloud setStatus $connectionStatus");
    //使用Notifier进行通知
    _context.read<RongCloudStatusNotifier>().setStatus(connectionStatus);
  }
}
