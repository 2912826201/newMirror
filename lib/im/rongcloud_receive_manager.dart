//融云消息接收管理者
import 'package:flutter/material.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/config/shared_preferences.dart';
import 'package:mirror/data/model/message/chat_message_profile_notifier.dart';
import 'package:mirror/data/model/message/chat_type_model.dart';
import 'package:mirror/im/message_manager.dart';
import 'package:mirror/util/badger_util.dart';
import 'package:mirror/util/event_bus.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:provider/provider.dart';

class RongCloudReceiveManager {
  BuildContext _context;
  static RongCloudReceiveManager _manager;
  List<Message> _receivedMsgList = [];

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
    try {
      String msgStr = msg.toString();
      print("收到了融云消息1：$msgStr");
    } catch (e) {
      print("收到了融云消息2：${msg.originContentMap}");
    }

    //发信时间在用户注册时期之前的要舍弃掉 融云会保留一段时间 所以会查到用户注册前的消息
    if (msg.sentTime < Application.profile.createTime) {
      return;
    }


    if(MessageManager.judgeChatRoomNotice(msg)){
      print("聊天室的通知消息：${msg.originContentMap}");
      //分析消息是什么类型
      MessageManager.splitChatRoomMessage(msg);
      return;
    }else if(MessageManager.judgeBarrageMessage(msg)){
      print("收到了弹幕消息：${msg.content.encode()}");
      EventBus.getDefault().post(registerName: EVENTBUS_ROOM_RECEIVE_BARRAGE,msg: msg);
      return;
    }


    //分析消息是什么类型
    MessageManager.splitMessage(msg);

    //存在list中
    _manager._receivedMsgList.add(msg);

    //当剩余消息量为0时 统一进行处理会话
    //有的消息的left是-1...需要处理下
    if (left <= 0) {
      List<Message> list = [];
      list.addAll(_manager._receivedMsgList);
      _manager._receivedMsgList.clear();

      MessageManager.updateConversationByMessageList(_context, list);
    }
  }

  //发送消息结果的回调
  onMessageSend(int messageId, int status, int code) {
    //   RCSentStatus
    //   static const int Sending = 10; //发送中
    //   static const int Failed = 20; //发送失败
    //   static const int Sent = 30; //发送成功
    //   static const int Received = 40; //对方已接收
    //   static const int Read = 50; //对方已阅读
    //将发送的消息插入记录
    print("发送了融云消息：messageId:${messageId},status:${status},code:${code}");
    if (code == -1) {
      return;
    }
    // 需要更新会话
    Application.rongCloud.getMessageById(messageId).then((msg) {

      if(msg.conversationType == RCConversationType.ChatRoom){
        //聊天室的消息
        if(code==23408){
          print("聊天室的消息:被禁言了");
          AppPrefs.setLiveRoomMuteMessage(int.parse(msg.targetId));
        }
      }else{

        //系统消息和群聊消息和私聊消息
        List<int> list=[];
        list.add(messageId);
        list.add(status);
        EventBus.getDefault().post(msg: list,registerName: RESET_MSG_STATUS);
        MessageManager.updateConversationByMessageList(_context, [msg]);
      }

    }).catchError((e) {
      print("未查到融云消息：messageId:${messageId}");
    });
  }

  //消息撤回监听
  onRecallMessageReceived(Message message) {
    print("撤回消息====${message.objectName}");
    EventBus.getDefault().post(msg: message, registerName: CHAT_WITHDRAW_MSG);
    Application.appContext.read<ChatMessageProfileNotifier>().judgeWithdrawIsAtMsg(message);
    MessageManager.updateConversationByMessageList(_context, [message]);
  }
}
