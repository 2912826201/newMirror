import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/data/dto/conversation_dto.dart';
import 'package:mirror/data/model/media_file_model.dart';
import 'package:mirror/data/model/message/chat_data_model.dart';
import 'package:mirror/data/model/message/chat_type_model.dart';
import 'package:mirror/data/model/message/chat_voice_model.dart';
import 'package:mirror/data/model/upload/upload_result_model.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

//融云每一秒支持发送5条消息
int imPostSecondNumber = 5;

// typedef VoidCallback = void Function();

//分享跳转界面
void jumpShareMessage(Map<String, dynamic> map, String chatType, String name,
    BuildContext context) async {
  ConversationDto conversation = new ConversationDto();
  conversation.name = name;
  if (Application.profile.uid.toString() == "1018240") {
    conversation.conversationId = "1019293";
  } else {
    conversation.conversationId = "1018240";
  }
  conversation.uid = Application.profile.uid;
  //todo 目前这里是私聊--写死
  conversation.type = RCConversationType.Private;

  Message message;
  if (chatType == ChatTypeModel.MESSAGE_TYPE_FEED) {
    ToastShow.show(msg: "给$name分享了动态", context: context);
    message = await postMessageManagerFeed(conversation.conversationId, map);
  } else if (chatType == ChatTypeModel.MESSAGE_TYPE_USER) {
    ToastShow.show(msg: "给$name分享了名片", context: context);
    message = await postMessageManagerUser(conversation.conversationId, map);
  } else if (chatType == ChatTypeModel.MESSAGE_TYPE_LIVE_COURSE) {
    ToastShow.show(msg: "给$name分享了直播课程", context: context);
    message =
        await postMessageManagerLiveCourse(conversation.conversationId, map);
  } else if (chatType == ChatTypeModel.MESSAGE_TYPE_VIDEO_COURSE) {
    ToastShow.show(msg: "给$name分享了视频课程", context: context);
    message =
        await postMessageManagerVideoCourse(conversation.conversationId, map);
  } else {
    chatType = ChatTypeModel.NULL_COMMENT;
    ToastShow.show(msg: "给$name分享了未知消息", context: context);
  }
  if (chatType == ChatTypeModel.NULL_COMMENT) {
    return;
  }
  if (message == null) {
    message = await postMessageManagerText(
        conversation.conversationId, map.toString());
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
  msg.sendUserInfo = getUserInfo();
  // msg.content = text;
  Map<String, dynamic> feedMap = Map();
  feedMap["type"] = ChatTypeModel.MESSAGE_TYPE_TEXT;
  feedMap["content"] = text;
  msg.content = jsonEncode(feedMap);
  return await postMessageManager1(targetId, msg);
}

//发送可选择的消息
Future<Message> postMessageManagerSelect(String targetId, String text) async {
  TextMessage msg = TextMessage();
  msg.sendUserInfo = getUserInfo();
  // msg.content = text;
  Map<String, dynamic> feedMap = Map();
  feedMap["type"] = ChatTypeModel.MESSAGE_TYPE_SELECT;
  feedMap["content"] = text;
  msg.content = jsonEncode(feedMap);
  return await postMessageManager1(targetId, msg);
}

//发送动态
Future<Message> postMessageManagerFeed(
    String targetId, Map<String, dynamic> map) async {
  TextMessage msg = TextMessage();
  msg.sendUserInfo = getUserInfo();
  Map<String, dynamic> feedMap = Map();
  feedMap["type"] = ChatTypeModel.MESSAGE_TYPE_FEED;
  feedMap["content"] = jsonEncode(map);
  msg.content = jsonEncode(feedMap);
  return await postMessageManager1(targetId, msg);
}

//发送图片视频---一般不用
Future<Message> postMessageManagerImgOrVideo1(
    String targetId,
    bool isImgOrVideo,
    MediaFileModel mediaFileModel,
    UploadResultModel uploadResultModel) async {
  ImageMessage msg = new ImageMessage();
  mediaFileModel.sizeInfo.type =
      isImgOrVideo ? mediaTypeKeyImage : mediaTypeKeyVideo;
  msg.localPath = uploadResultModel.filePath;
  msg.extra = jsonEncode(mediaFileModel.sizeInfo.toJson());
  msg.imageUri = uploadResultModel.url;
  msg.mThumbUri = uploadResultModel.url;
  msg.sendUserInfo = getUserInfo();
  return await postMessageManager1(targetId, msg);
}

//发送图片视频--目前在使用这个--但是要更改
Future<Message> postMessageManagerImgOrVideo(String targetId, bool isImgOrVideo,
    MediaFileModel mediaFileModel, UploadResultModel uploadResultModel) async {
  mediaFileModel.sizeInfo.type =
      isImgOrVideo ? mediaTypeKeyImage : mediaTypeKeyVideo;
  mediaFileModel.sizeInfo.showImageUrl = uploadResultModel.url;
  TextMessage msg = TextMessage();
  msg.sendUserInfo = getUserInfo();
  Map<String, dynamic> feedMap = Map();
  feedMap["type"] = isImgOrVideo
      ? ChatTypeModel.MESSAGE_TYPE_IMAGE
      : ChatTypeModel.MESSAGE_TYPE_VIDEO;
  feedMap["content"] = jsonEncode(mediaFileModel.sizeInfo.toJson());
  msg.content = jsonEncode(feedMap);
  return await postMessageManager1(targetId, msg);
}

//发送音频
Future<Message> postMessageManagerVoice(
    String targetId, ChatVoiceModel chatVoiceModel) async {
  VoiceMessage msg = new VoiceMessage();
  msg.localPath = chatVoiceModel.filePath;
  msg.extra = jsonEncode(chatVoiceModel.toJson());
  msg.duration = chatVoiceModel.longTime;
  msg.sendUserInfo = getUserInfo();
  return await postMessageManager1(targetId, msg);
}

//发送用户名片
Future<Message> postMessageManagerUser(
    String targetId, Map<String, dynamic> map) async {
  TextMessage msg = TextMessage();
  msg.sendUserInfo = getUserInfo();
  Map<String, dynamic> feedMap = Map();
  feedMap["type"] = ChatTypeModel.MESSAGE_TYPE_USER;
  feedMap["content"] = jsonEncode(map);
  msg.content = jsonEncode(feedMap);
  return await postMessageManager1(targetId, msg);
}

//发送直播课程
Future<Message> postMessageManagerLiveCourse(
    String targetId, Map<String, dynamic> map) async {
  TextMessage msg = TextMessage();
  msg.sendUserInfo = getUserInfo();
  Map<String, dynamic> feedMap = Map();
  feedMap["type"] = ChatTypeModel.MESSAGE_TYPE_LIVE_COURSE;
  feedMap["content"] = jsonEncode(map);
  msg.content = jsonEncode(feedMap);
  return await postMessageManager1(targetId, msg);
}

//发送视频课程
Future<Message> postMessageManagerVideoCourse(
    String targetId, Map<String, dynamic> map) async {
  TextMessage msg = TextMessage();
  msg.sendUserInfo = getUserInfo();
  Map<String, dynamic> feedMap = Map();
  feedMap["type"] = ChatTypeModel.MESSAGE_TYPE_VIDEO_COURSE;
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

//发送消息提示间隔
void postMessageManagerAlertTime(
    String chatTypeModel,
    String content,
    String targetId,
    int conversationType,
    Function(Message msg, int code) finished) {
  TextMessage msg = TextMessage();
  msg.sendUserInfo = getUserInfo();
  Map<String, dynamic> feedMap = Map();
  feedMap["type"] = chatTypeModel;
  feedMap["content"] = content;
  msg.content = jsonEncode(feedMap);
  Application.rongCloud
      .insertOutgoingMessage(conversationType, targetId, msg, finished);
}

//获取用户数据
UserInfo getUserInfo() {
  UserInfo userInfo = UserInfo();
  userInfo.userId = Application.profile.uid.toString();
  userInfo.name = Application.profile.nickName;
  userInfo.portraitUri = Application.profile.avatarUri;
  return userInfo;
}

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

//发送字符串的model
void postText(ChatDataModel chatDataModel, String targetId,
    VoidCallback voidCallback) async {
  chatDataModel.msg =
      await postMessageManagerText(targetId, chatDataModel.content);
  chatDataModel.isTemporary = false;
  // print(chatDataModel.msg.toString());
  voidCallback();
}

//生成消息的model
ChatDataModel getMessage(Message message, {bool isHaveAnimation = true}) {
  ChatDataModel chatDataModel = new ChatDataModel();
  chatDataModel.isHaveAnimation = isHaveAnimation;
  chatDataModel.msg = message;
  return chatDataModel;
}

//获取时间间隔的消息
void getTimeChatDataModel(
    {String targetId, int conversationType, Function(Message msg, int code) finished}) async {
  postMessageManagerAlertTime(ChatTypeModel.MESSAGE_TYPE_ALERT_TIME,
      new DateTime.now().millisecondsSinceEpoch.toString(), targetId,
      conversationType, finished);
}

//voice 的更新
void updateMessage(ChatDataModel chatDataModel, Function(int code) finished) {
  VoiceMessage voiceMessage = ((chatDataModel.msg.content) as VoiceMessage);
  Map<String, dynamic> mapModel = json.decode(voiceMessage.extra);
  mapModel["read"] = 1;
  voiceMessage.extra = json.encode(mapModel);
  chatDataModel.msg.content = voiceMessage;
  Map<String, dynamic> expansionDic = Map();
  expansionDic["extra"] = voiceMessage.extra;
  Application.rongCloud.updateMessage(
      expansionDic, chatDataModel.msg.messageUId, finished);
}

//发送可选择的model
void postSelectMessage(ChatDataModel chatDataModel, String targetId,
    VoidCallback voidCallback) async {
  chatDataModel.msg =
  await postMessageManagerSelect(targetId, chatDataModel.content);
  chatDataModel.isTemporary = false;
  voidCallback();
}


//发送图片或者视频
void postImgOrVideo(List<ChatDataModel> modelList, String targetId, String type,
    VoidCallback voidCallback) async {
  List<UploadResultModel> uploadResultModelList =
  await onPostImgOrVideo(modelList, type);
  for (int i = 0; i < modelList.length; i++) {
    int uploadResultModelIndex = -1;
    for (int j = 0; j < uploadResultModelList.length; j++) {
      if (uploadResultModelList[j].filePath ==
          modelList[i].mediaFileModel.file.path) {
        uploadResultModelIndex = j;
        break;
      }
    }
    if (uploadResultModelIndex >= 0) {
      modelList[i].msg = await postMessageManagerImgOrVideo(
          targetId,
          type == mediaTypeKeyImage,
          modelList[i].mediaFileModel,
          uploadResultModelList[uploadResultModelIndex]);
      modelList[i].isTemporary = false;
      print("----------成功：modelList[i].msg：${modelList[i].msg.toString()}");
    } else {
      print("--------------上传图片失败");
    }
  }
  voidCallback();
}

//发送语音
void postVoice(ChatDataModel chatDataModel, String targetId,
    VoidCallback voidCallback) async {
  chatDataModel.msg =
      await postMessageManagerVoice(targetId, chatDataModel.chatVoiceModel);
  chatDataModel.isTemporary = false;
  voidCallback();
}

//上传图片和视频
Future<List<UploadResultModel>> onPostImgOrVideo(
    List<ChatDataModel> modelList, String type) async {
  List<File> fileList = [];
  List<UploadResultModel> uploadResultModelList = <UploadResultModel>[];
  UploadResults results;
  if (type == mediaTypeKeyImage) {
    String timeStr = DateTime.now().millisecondsSinceEpoch.toString();
    int i = 0;
    modelList.forEach((element) async {
      if (element.mediaFileModel.croppedImageData == null) {
        fileList.add(element.mediaFileModel.file);
      } else {
        i++;
        File imageFile = await FileUtil().writeImageDataToFile(
            element.mediaFileModel.croppedImageData, timeStr + i.toString());
        fileList.add(imageFile);
      }
    });
    results = await FileUtil().uploadPics(fileList, (percent) {});
  } else if (type == mediaTypeKeyVideo) {
    modelList.forEach((element) {
      fileList.add(element.mediaFileModel.file);
    });
    results = await FileUtil().uploadMedias(fileList, (percent) {});
  }
  print(results.isSuccess);
  for (int i = 0; i < results.resultMap.length; i++) {
    UploadResultModel model = results.resultMap.values.elementAt(i);
    uploadResultModelList.add(model);
    print("第${i + 1}个上传文件");
    print(model.isSuccess);
    print(model.error);
    print(model.filePath);
    print(model.url);
  }
  return uploadResultModelList;
}
