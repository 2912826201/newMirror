import 'package:flutter/cupertino.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

class ChatMessageProfileNotifier extends ChangeNotifier {
  ChatMessageProfileNotifier() {
    clear();
  }

  ///这是什么类型的对话--融云的分类-数字
  ///[chatTypeId] 会话类型，参见枚举 [RCConversationType]
  int chatTypeId;

  ///对话用户id
  String chatUserId;

  ///消息
  Message message;

  //消息的id
  int messageId;

  //消息状态
  int status;

  //是否设置消息状态
  bool isSettingStatus = false;

  //设置消息发送的状态
  setIsSettingStatus({bool isSettingStatus, int messageId, int status}) {
    this.isSettingStatus = isSettingStatus;
    this.messageId = messageId;
    this.status = status;
    this.message = null;
    notifyListeners();
  }

  //设置消息发送的状态
  setSettingStatus(isSettingStatus) {
    this.isSettingStatus = isSettingStatus;
  }

  //设置数据
  setData(int chatTypeId, String chatUserId) {
    this.chatTypeId = chatTypeId;
    this.chatUserId = chatUserId;
  }

  clear() {
    chatTypeId = -1;
    chatUserId = "";
  }

  clearMessage() {
    this.message = null;
  }

  changeCallback(Message message) {
    if (message.targetId == this.chatUserId &&
        message.conversationType == chatTypeId) {
      this.message = message;
      this.isSettingStatus = false;
      notifyListeners();
    }
  }
}
