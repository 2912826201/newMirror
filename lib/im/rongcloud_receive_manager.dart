//融云消息接收管理者
import 'package:flutter/material.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/data/model/message/chat_message_profile_notifier.dart';
import 'package:mirror/im/message_manager.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:provider/provider.dart';

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
    //TODO SDK 分批拉取离线消息，当离线消息量巨大的时候，建议当 left == 0 且 hasPackage == false 时刷新会话列表
    print("收到了融云消息：" + msg.toString());

    Application.appContext
        .read<ChatMessageProfileNotifier>()
        .changeCallback(msg);

    //发信时间在用户注册时期之前的要舍弃掉 融云会保留一段时间 所以会查到用户注册前的消息
    if (msg.sentTime < Application.profile.createTime) {
      return;
    }

    MessageManager.updateConversationByMessage(_context, msg);
    MessageManager.judgeIsHaveAtUserMes(msg);

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
    print("messageId:${messageId},status:${status},code:${code}");

//   RCSentStatus
//   static const int Sending = 10; //发送中
//   static const int Failed = 20; //发送失败
//   static const int Sent = 30; //发送成功
//   static const int Received = 40; //对方已接收
//   static const int Read = 50; //对方已阅读
  }

  //消息撤回监听
  onRecallMessageReceived(Message message) {
    print("撤回消息====${message.objectName}");
  }
}
