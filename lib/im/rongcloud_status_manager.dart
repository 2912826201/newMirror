import 'package:flutter/material.dart';
import 'package:mirror/data/notifier/rongcloud_status_notifier.dart';
import 'package:provider/provider.dart';

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
  }

  //手动更新状态
  setStatus(int connectionStatus) {
    print("RongCloud setStatus $connectionStatus");
    //使用Notifier进行通知
    _context.read<RongCloudStatusNotifier>().setStatus(connectionStatus);
  }
}
