import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/data/dto/conversation_dto.dart';
import 'package:mirror/data/model/message/chat_data_model.dart';
import 'package:mirror/data/model/message/chat_type_model.dart';
import 'package:mirror/data/model/user_model.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

//分享跳转界面
void jumpShareMessage(Map<String, dynamic> map, String chatType, String name,
    BuildContext context) async {
  ConversationDto conversation = new ConversationDto();
  conversation.name = name;
  if (Application.profile.uid.toString() == "1009312") {
    conversation.uid = 1009312;
  } else {
    conversation.uid = 1018240;
  }
  conversation.type = PRIVATE_TYPE;

  Message message;
  if (chatType == ChatTypeModel.MESSAGE_TYPE_FEED) {
    ToastShow.show(msg: "给$name分享了动态", context: context);
    // print("====动态:"+map.toString());
    message = await postMessageManagerFeed(conversation.uid.toString(), map);
  } else if (chatType == ChatTypeModel.MESSAGE_TYPE_USER) {
    ToastShow.show(msg: "给$name分享了名片", context: context);
  } else {
    chatType = ChatTypeModel.NULL_COMMENT;
    ToastShow.show(msg: "给$name分享了未知消息", context: context);
  }
  if (chatType == ChatTypeModel.NULL_COMMENT) {
    return;
  }
  if (message == null) {
    message = await postMessageManagerText(
        conversation.uid.toString(), map.toString());
  }
  print(message.toString());
  _jumpChatPage(
      context: context, conversation: conversation, shareMessage: message);
}

//去聊天界面
void jumpChatPageConversationDto(
    BuildContext context, ConversationDto conversation) {
  _jumpChatPage(
      context: context, conversation: conversation, shareMessage: null);
}

//去测试界面
void jumpChatPageTest(BuildContext context) {
  _jumpChatPage(
      context: context, conversation: getConversationDto(), shareMessage: null);
}

//跳转界面-去聊天界面
void _jumpChatPage(
    {BuildContext context,
    ConversationDto conversation,
    Message shareMessage}) {
  AppRouter.navigateToChatPage(
      context: context, conversation: conversation, shareMessage: shareMessage);
}

//
// //todo 发送消息 不依赖于 chat_page界面
// //发送消息
// Future<Message> postMessageManager({Map<String, dynamic> map, String chatType, String name, BuildContext context})async{
//
//   Message message = await Application.rongCloud.sendPrivateMessage(controller.text, msg);
//
//
//   //判断发送的是什么消息
//   if(chatType==ChatTypeModel.USER_INFORMATION){
//     print("名片信息");
//   }else if(chatType==ChatTypeModel.FEED){
//     print("动态信息");
//   }else if(chatType==ChatTypeModel.COMMENT_TEXT){
//     print("普通文字信息");
//   }else{
//     print("未知消息,不发送");
//   }
//   return true;
// }

//todo 目前没有自定义的所以差不多都是使用的是TextMessage 等有了自定义再改

//发送文本消息
Future<Message> postMessageManagerText(String targetId, String text) async {
  TextMessage msg = TextMessage();
  UserInfo userInfo = UserInfo();
  userInfo.userId = Application.profile.uid.toString();
  userInfo.name = Application.profile.nickName;
  userInfo.portraitUri = Application.profile.avatarUri;
  msg.sendUserInfo = userInfo;
  // msg.content = text;
  Map<String, dynamic> feedMap = Map();
  feedMap["type"] = ChatTypeModel.MESSAGE_TYPE_TEXT;
  feedMap["content"] = text;
  msg.content = jsonEncode(feedMap);
  return await postMessageManager1(targetId, msg);
}

//发送动态
Future<Message> postMessageManagerFeed(
    String targetId, Map<String, dynamic> map) async {
  TextMessage msg = TextMessage();
  UserInfo userInfo = UserInfo();
  userInfo.userId = Application.profile.uid.toString();
  userInfo.name = Application.profile.nickName;
  userInfo.portraitUri = Application.profile.avatarUri;
  msg.sendUserInfo = userInfo;
  Map<String, dynamic> feedMap = Map();
  feedMap["type"] = ChatTypeModel.MESSAGE_TYPE_FEED;
  feedMap["content"] = jsonEncode(map);
  msg.content = jsonEncode(feedMap);
  return await postMessageManager1(targetId, msg);
}

//发送消息
Future<Message> postMessageManager1(
    String targetId, MessageContent messageContent) async {
  return await Application.rongCloud
      .sendPrivateMessage(targetId, messageContent);
}

// //发送消息
// Future<Message> postMessageManager2(String targetId,String content)async{
//   // return await Application.rongCloud.sendPrivateMessage(targetId, messageContent);
//   Message message=new Message();
//   message.messageId=Random().nextInt(10000);
//   message.objectName="RC:TxtMsg";
//   message.conversationType=PRIVATE_TYPE;
//   message.targetId=targetId;//给什么人发送
//   message.messageDirection=1;
//   message.senderUserId="1018240";
//   message.receivedStatus=0;
//   message.sentStatus=10;
//   message.sentTime=new DateTime.now().millisecondsSinceEpoch;
//   Map<String, dynamic> map = Map();
//   map["content"]=content;
//   map["extra"]="null";
//   UserModel userModel=new UserModel();
//   userModel.uid=1018240;
//   userModel.nickName="测试用户510";
//   userModel.avatarUri="https://i1.hdslb.com/bfs/archive/eb4d6aed7800003da1c6bdfa1c8476d4b6f567db.jpg";
//   map["user"]=userModel.toJson();
//   message.content=map;
// }

//获取这个消息是什么类型的
String getMessageType(ConversationDto conversation, BuildContext context) {
  String type;
  if (conversation.type == OFFICIAL_TYPE) {
    type = "系统消息的type类型";
    ToastShow.show(msg: type, context: context);
  } else if (conversation.type == LIVE_TYPE) {
    type = "直播消息的type类型";
  } else if (conversation.type == TRAINING_TYPE) {
    type = "运动消息的type类型";
  } else if (conversation.type == MANAGER_TYPE) {
    type = "管家会话的type类型";
  } else if (conversation.type == PRIVATE_TYPE) {
    type = "私聊会话的type类型";
  } else if (conversation.type == GROUP_TYPE) {
    type = "群聊会话的type类型";
  } else {
    type = "未知消息";
  }
  // ToastShow.show(msg: type, context: context);
  print(type);
  return type;
}

//获取一个临时的身份
ConversationDto getConversationDto() {
  ConversationDto conversation = new ConversationDto();
  conversation.name = "系统消息";
  conversation.uid = 0;
  conversation.type = OFFICIAL_TYPE;
  conversation.avatarUri =
      "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1608558159490&di=e16c52c33c6cd52559aae9829aaca4c5&imgtype=0&src=http%3A%2F%2Fcdn.duitang.com%2Fuploads%2Fitem%2F201406%2F03%2F20140603170900_MtE8Q.thumb.600_0.jpeg";
  return conversation;
}

//生成字符串的model
Future<ChatDataModel> postText(String text, String targetId) async {
  ChatDataModel chatDataModel = new ChatDataModel();
  chatDataModel.isHaveAnimation = true;
  chatDataModel.msg = await postMessageManagerText(targetId, text);
  return chatDataModel;
}

//生成消息的model
ChatDataModel postMessage(Message message) {
  ChatDataModel chatDataModel = new ChatDataModel();
  chatDataModel.isHaveAnimation = true;
  chatDataModel.msg = message;
  return chatDataModel;
}

//
// //生成字符串的model
// ChatDataModel postFeed(Map<String, dynamic> shareMap,ConversationDto conversationDto) {
//   ChatDataModel chatDataModel = new ChatDataModel();
//   chatDataModel.id = Random().nextInt(10000000).toString();
//   chatDataModel.nickName = "张三";
//   chatDataModel.time = new DateTime.now().microsecondsSinceEpoch;
//   chatDataModel.avatar =
//   "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1608558159490&di=e16c52c33c6cd52559aae9829aaca4c5&imgtype=0&src=http%3A%2F%2Fcdn.duitang.com%2Fuploads%2Fitem%2F201406%2F03%2F20140603170900_MtE8Q.thumb.600_0.jpeg";
//   var instanceMap = Map();
//   instanceMap["type"] = ChatTypeModel.COMMENT_TEXT;
//   // instanceMap["text"] = text;
//   chatDataModel.msg = instanceMap;
//   chatDataModel.isHaveAnimation = true;
//   return chatDataModel;
// }
