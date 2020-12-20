import 'package:flutter/material.dart';
import 'package:mirror/data/notifier/rongcloud_connection_notifier.dart';
import 'package:provider/provider.dart';

class RongCloudStatusManager{
  BuildContext _context;
  static RongCloudStatusManager _manager;

  static RongCloudStatusManager init(BuildContext context){
    if(_manager == null){
      _manager = RongCloudStatusManager();
      _manager._context = context;
    }
    return _manager;
  }

  //响应融云连接状态的变化方法
  onConnectionStatusChange (int connectionStatus) {
    print("RongCloudStatus $connectionStatus");
    //使用Notifier进行通知
    _context.read<RongCloudStatusNotifier>().setStatus(connectionStatus);
  }
}