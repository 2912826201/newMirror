//融云消息接收管理者
import 'package:flutter/material.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

class RongCloudReceiveManager {
  BuildContext _context;
  static RongCloudReceiveManager _manager;

  static RongCloudReceiveManager init(BuildContext context) {
    if (_manager == null) {
      _manager = RongCloudReceiveManager();
      _manager._context = context;
    }
    return _manager;
  }

  //第二个参数表示的是还剩下的未取的消息数量，第三个参数表示是否是按照包的形势拉取的信息，第四个参数表示的是是否是离线消息
  onMessageReceivedWrapper(Message msg, int left, bool hasPackage, bool offline) {
    print("收到了融云消息：" + msg.toString());
    switch (offline) {
      case true:
        // _processOffLineRawMsg(msg, left, hasPackage);
        break;
      default:
      // _processCurrentRawMsg(msg,left);
    }
  }

  //发送消息结果的回调
  onMessageSend(int messageId, int status, int code) {
    //将发送的消息插入记录

// RCSentStatus
// static const int Sending = 10; //发送中
//   static const int Failed = 20; //发送失败
//   static const int Sent = 30; //发送成功
//   static const int Received = 40; //对方已接收
//   static const int Read = 50; //对方已阅读
  }
}
