import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:mirror/config/application.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

import 'chat_type_model.dart';

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

  ///消息
  Message resetMessage;

  //消息的id
  int messageId;

  //消息状态
  int status;

  //是否设置消息状态
  bool isSettingStatus = false;

  //是否刷新界面--消息界面
  bool isResetPage = false;

  //是否刷新界面--课程界面
  bool isResetCoursePageItem = false;
  //是否刷新界面--课程界面
  bool isResetCoursePage = false;

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

  //课程预约或者取消预约
  bookLive(Message message){
    Future.delayed(Duration(milliseconds: 100),(){
      this.isResetPage = false;
      this.isResetCoursePageItem = false;
      this.isResetCoursePage = true;
      this.resetMessage = message;
      notifyListeners();
      Future.delayed(Duration(milliseconds: 200),(){
        this.isResetCoursePageItem = true;
        notifyListeners();
      });
    });
  }

  //移除群聊
  removeGroup(Message message){
    Map<String, dynamic> mapGroupModel = json.decode(message.originContentMap["data"]);
    print("value:${mapGroupModel["groupChatId"].toString() == this.chatUserId
        && RCConversationType.Group == chatTypeId}");
    if (mapGroupModel["groupChatId"].toString() == this.chatUserId && RCConversationType.Group == chatTypeId) {
      List<dynamic> users = mapGroupModel["users"];
      for (dynamic d in users) {
        if (d["uid"] == Application.profile.uid) {
          this.isResetPage = true;
          this.isResetCoursePage = false;
          this.resetMessage = message;
          notifyListeners();
          break;
        }
      }
    }else{
      insertExitGroupMsg(message, mapGroupModel["groupChatId"].toString());
    }
  }

  //加入群聊
  entryGroup(Message message){
    Map<String, dynamic> mapGroupModel = json.decode(message.originContentMap["data"]);
    print("value:${mapGroupModel["groupChatId"].toString() == this.chatUserId
        && RCConversationType.Group == chatTypeId}");
    print("value:${message.originContentMap.toString()}");
    if (mapGroupModel["groupChatId"].toString() == this.chatUserId && RCConversationType.Group == chatTypeId) {
      List<dynamic> users = mapGroupModel["users"];
      for (dynamic d in users) {
        if (d["uid"] == Application.profile.uid) {
          this.isResetPage = true;
          this.isResetCoursePage = false;
          this.resetMessage = message;
          notifyListeners();
          break;
        }
      }
    }else{
      insertExitGroupMsg(message, mapGroupModel["groupChatId"].toString());
    }
  }


  //获取新的消息--判断是不是当前会话的消息
  judgeConversationMessage(Message message) {
    if (message.targetId == this.chatUserId && message.conversationType == chatTypeId) {
      if (message.conversationType != RCConversationType.System) {
        this.message = message;
        this.isSettingStatus = false;
        notifyListeners();
      }
    }
  }

  //插入被移除群聊或者加入群聊的消息
  void insertExitGroupMsg(Message message, String targetId) {
    TextMessage msg = TextMessage();
    msg.sendUserInfo = getChatUserInfo();
    Map<String, dynamic> alertMap = Map();
    alertMap["subObjectName"] = ChatTypeModel.MESSAGE_TYPE_GRPNTF;
    alertMap["name"] = ChatTypeModel.MESSAGE_TYPE_GRPNTF_NAME;
    alertMap["data"] = jsonEncode(message.originContentMap);
    msg.content = jsonEncode(alertMap);
    Application.rongCloud.insertOutgoingMessage(RCConversationType.Group, targetId, msg, null,
        sendTime: new DateTime.now().millisecondsSinceEpoch);
  }

  //获取用户数据
  UserInfo getChatUserInfo() {
    UserInfo userInfo = UserInfo();
    userInfo.userId = Application.profile.uid.toString();
    userInfo.name = Application.profile.nickName;
    userInfo.portraitUri = Application.profile.avatarUri;
    return userInfo;
  }
}
