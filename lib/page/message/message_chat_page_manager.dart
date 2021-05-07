import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:mirror/widget/input_formatter/release_feed_input_formatter.dart';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/api.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/api/message_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/database/group_chat_user_information_helper.dart';
import 'package:mirror/data/dto/conversation_dto.dart';
import 'package:mirror/data/dto/group_chat_user_information_dto.dart';
import 'package:mirror/data/model/base_response_model.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/media_file_model.dart';
import 'package:mirror/data/model/message/chat_data_model.dart';
import 'package:mirror/data/model/message/chat_group_user_model.dart';
import 'package:mirror/data/model/message/chat_type_model.dart';
import 'package:mirror/data/model/message/chat_voice_model.dart';
import 'package:mirror/data/model/message/group_user_model.dart';
import 'package:mirror/data/model/upload/upload_result_model.dart';
import 'package:mirror/data/model/user_model.dart';
import 'package:mirror/data/notifier/conversation_notifier.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/im/message_manager.dart';
import 'package:mirror/im/rongcloud.dart';
import 'package:mirror/page/message/item/chat_page_ui.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/click_util.dart';
import 'package:mirror/util/event_bus.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/text_span_field/range_style.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:provider/provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import 'more_page/group_more_page.dart';
import 'more_page/private_more_page.dart';

///几乎所有的消息发送添加转发页

//融云每一秒支持发送5条消息
int imPostSecondNumber = 5;

//去对应的聊天界面
//目前是从用户详情页的私聊过来的
void jumpChatPageUser(
  BuildContext context,
  UserModel userModel,
{String textContent}
) {
  ConversationDto conversation = new ConversationDto();
  conversation.conversationId = userModel.uid.toString();
  conversation.uid = Application.profile.uid;
  conversation.name = userModel.nickName;
  conversation.avatarUri = userModel.avatarUri;
  conversation.type = PRIVATE_TYPE;
  jumpChatPageConversationDto(context, conversation,textContent: textContent);
}

//分享跳转界面
Future<bool> jumpShareMessage(
    Map<String, dynamic> map, String chatType, String name, int userId, int type, BuildContext context) async {
  ConversationDto conversation = new ConversationDto();
  conversation.name = name;
  conversation.conversationId = userId.toString();
  conversation.uid = Application.profile.uid;
  conversation.type = type == RCConversationType.Private ? PRIVATE_TYPE : GROUP_TYPE;

  Message message;
  if (chatType == ChatTypeModel.MESSAGE_TYPE_FEED) {
    print("给$name分享了动态");
    message = await postMessageManagerFeed(
        conversation.conversationId, map, conversation.getType() == RCConversationType.Private);
  } else if (chatType == ChatTypeModel.MESSAGE_TYPE_USER) {
    print("给$name分享了名片");
    message = await postMessageManagerUser(
        conversation.conversationId, map, conversation.getType() == RCConversationType.Private);
  } else if (chatType == ChatTypeModel.MESSAGE_TYPE_LIVE_COURSE) {
    print("给$name分享了直播课程");
    message = await postMessageManagerLiveCourse(
        conversation.conversationId, map, conversation.getType() == RCConversationType.Private);
  } else if (chatType == ChatTypeModel.MESSAGE_TYPE_VIDEO_COURSE) {
    print("给$name分享了视频课程");
    message = await postMessageManagerVideoCourse(
        conversation.conversationId, map, conversation.getType() == RCConversationType.Private);
  } else if (chatType == ChatTypeModel.MESSAGE_TYPE_IMAGE) {
    print("给$name分享了图片");
    MediaFileModel mediaFileModel = new MediaFileModel();
    SizeInfo sizeInfo = new SizeInfo();
    sizeInfo.height = map["height"];
    sizeInfo.width = map["width"];
    mediaFileModel.sizeInfo = sizeInfo;
    UploadResultModel uploadResultModel = await onPostImgOrVideoSinge(new File(map["file"]));
    message = await postMessageManagerImgOrVideo(
      conversation.conversationId,
      true,
      mediaFileModel,
      uploadResultModel,
      conversation.getType() == RCConversationType.Private,
    );
  } else {
    chatType = ChatTypeModel.NULL_COMMENT;
    print("给$name分享了未知消息");
    return false;
  }
  if (chatType == ChatTypeModel.NULL_COMMENT) {
    return false;
  }
  if (message == null) {
    message = await postMessageManagerText(
        conversation.conversationId, map.toString(), null, conversation.type == RCConversationType.Private);
  }
  print(message.toString());
  EventBus.getDefault().post(msg: message,registerName: CHAT_GET_MSG);
  return true;
  // _jumpChatPage(context: context, conversation: conversation, shareMessage: message);
}

//去聊天界面
void jumpChatPageConversationDto(BuildContext context, ConversationDto conversation,{String textContent}) {
  _jumpJudgeChatPage(context: context, conversation: conversation, shareMessage: null,textContent: textContent);
}

//去群聊界面
void jumpGroupPage(BuildContext context, String name, int groupId) {
  ConversationDto conversation = new ConversationDto();
  conversation.name = name;
  conversation.conversationId = groupId.toString();
  conversation.uid = Application.profile.uid;
  conversation.type = GROUP_TYPE;
  jumpChatPageConversationDto(context, conversation);
}

//去测试界面
void jumpChatPageTest(BuildContext context) {
  _jumpJudgeChatPage(context: context, conversation: getConversationDto(), shareMessage: null);
}

//跳转界面-去聊天界面-先获取群成员
void _jumpJudgeChatPage({BuildContext context, ConversationDto conversation, Message shareMessage,String textContent}) async {

  if (conversation.type == GROUP_TYPE) {
    textContent=null;
    context.read<GroupUserProfileNotifier>().clearAllUser();
  }

  _jumpChatPage(context: context, conversation: conversation, shareMessage: shareMessage,textContent: textContent);

  if (conversation.type == GROUP_TYPE) {
    int groupManNumber = await getChatGroupUserModelList(conversation.conversationId, context);
    if (null == groupManNumber || groupManNumber < 1) {
      return;
    }
  }
}

//跳转界面-去聊天界面
void _jumpChatPage({BuildContext context, ConversationDto conversation, Message shareMessage,String textContent}) async {
  List<ChatDataModel> chatDataModelList;
  int systemPage = 0;
  String systemLastTime;
  if (conversation.getType() != RCConversationType.System) {
    chatDataModelList = await ChatPageUtil.init(context).getChatMessageList(conversation, shareMessage);
  } else {
    List list = await ChatPageUtil.init(context).getSystemInformationNet(conversation);
    chatDataModelList = list[0];
    systemLastTime = list[1];
    systemPage = list[2];
  }
  AppRouter.navigateToChatPage(
    context: context,
    conversation: conversation,
    chatDataModelList: chatDataModelList,
    shareMessage: shareMessage,
    systemPage: systemPage,
    systemLastTime: systemLastTime,
    textContent: textContent,
  );
}

//todo 目前没有自定义的所以差不多都是使用的是TextMessage 等有了自定义再改

//发送文本消息
Future<Message> postMessageManagerText(
    String targetId, String text, MentionedInfo mentionedInfo, bool isPrivate) async {
  TextMessage msg = TextMessage();
  msg.sendUserInfo = getChatUserInfo(groupId: isPrivate ? null : targetId);
  if (mentionedInfo != null && mentionedInfo.userIdList != null && mentionedInfo.userIdList.length > 0) {
    msg.mentionedInfo = mentionedInfo;
  }
  // msg.content = text;
  Map<String, dynamic> textMap = Map();
  textMap["fromUserId"] = msg.sendUserInfo.userId.toString();
  textMap["toUserId"] = targetId;
  textMap["subObjectName"] = ChatTypeModel.MESSAGE_TYPE_TEXT;
  textMap["name"] = ChatTypeModel.MESSAGE_TYPE_TEXT_NAME;
  textMap["data"] = text;
  msg.content = jsonEncode(textMap);
  return await (isPrivate ? postPrivateMessageManager : postGroupMessageManager)(targetId, msg);
}

//发送可选择的消息
Future<Message> postMessageManagerSelect(String targetId, String text, bool isPrivate) async {
  TextMessage msg = TextMessage();
  msg.sendUserInfo = getChatUserInfo(groupId: isPrivate ? null : targetId);
  // msg.content = text;
  Map<String, dynamic> selectMap = Map();
  selectMap["fromUserId"] = msg.sendUserInfo.userId.toString();
  selectMap["toUserId"] = targetId;
  selectMap["subObjectName"] = ChatTypeModel.MESSAGE_TYPE_SELECT;
  selectMap["name"] = ChatTypeModel.MESSAGE_TYPE_SELECT_NAME;
  selectMap["data"] = text;
  msg.content = jsonEncode(selectMap);
  return await (isPrivate ? postPrivateMessageManager : postGroupMessageManager)(targetId, msg);
}

//发送动态
Future<Message> postMessageManagerFeed(String targetId, Map<String, dynamic> map, bool isPrivate) async {
  TextMessage msg = TextMessage();
  msg.sendUserInfo = getChatUserInfo(groupId: isPrivate ? null : targetId);
  Map<String, dynamic> feedMap = Map();
  feedMap["fromUserId"] = msg.sendUserInfo.userId.toString();
  feedMap["toUserId"] = targetId;
  feedMap["subObjectName"] = ChatTypeModel.MESSAGE_TYPE_FEED;
  feedMap["name"] = ChatTypeModel.MESSAGE_TYPE_FEED_NAME;
  feedMap["data"] = jsonEncode(map);
  msg.content = jsonEncode(feedMap);
  return await (isPrivate ? postPrivateMessageManager : postGroupMessageManager)(targetId, msg);
}

//发送图片视频
Future<Message> postMessageManagerImgOrVideo(String targetId, bool isImgOrVideo, MediaFileModel mediaFileModel,
    UploadResultModel uploadResultModel, bool isPrivate) async {
  TextMessage msg = TextMessage();
  msg.sendUserInfo = getChatUserInfo(groupId: isPrivate ? null : targetId);
  Map<String, dynamic> imgOrVideoMap = Map();
  imgOrVideoMap["fromUserId"] = msg.sendUserInfo.userId.toString();
  imgOrVideoMap["toUserId"] = targetId;
  imgOrVideoMap["subObjectName"] = isImgOrVideo ? ChatTypeModel.MESSAGE_TYPE_IMAGE : ChatTypeModel.MESSAGE_TYPE_VIDEO;
  imgOrVideoMap["name"] = isImgOrVideo ? ChatTypeModel.MESSAGE_TYPE_IMAGE_NAME : ChatTypeModel.MESSAGE_TYPE_VIDEO_NAME;
  Map sizeMap = mediaFileModel.sizeInfo.toJson();
  sizeMap["showImageUrl"] = uploadResultModel.url;
  imgOrVideoMap["data"] = jsonEncode(sizeMap);
  msg.content = jsonEncode(imgOrVideoMap);
  return await (isPrivate ? postPrivateMessageManager : postGroupMessageManager)(targetId, msg);
}

//发送音频
Future<Message> postMessageManagerVoice(String targetId, ChatVoiceModel chatVoiceModel, int conversationType) async {
  VoiceMessage msg = new VoiceMessage();
  msg.localPath = chatVoiceModel.filePath;
  msg.extra = jsonEncode(chatVoiceModel.toJson());
  msg.duration = chatVoiceModel.longTime;
  msg.sendUserInfo = getChatUserInfo(groupId: conversationType == RCConversationType.Group ? targetId : null);
  Message message = new Message();
  message.conversationType = conversationType;
  message.senderUserId = Application.profile.uid.toString();
  message.targetId = targetId;
  message.content = msg;
  message.objectName = VoiceMessage.objectName;
  message.sentTime = new DateTime.now().millisecondsSinceEpoch;
  message.canIncludeExpansion = true;
  Map map = Map();
  map["read"] = "0";
  message.expansionDic = map;
  return await Application.rongCloud.sendVoiceMessage(message);
}

//发送用户名片
Future<Message> postMessageManagerUser(String targetId, Map<String, dynamic> map, bool isPrivate) async {
  TextMessage msg = TextMessage();
  msg.sendUserInfo = getChatUserInfo(groupId: isPrivate ? null : targetId);
  Map<String, dynamic> userMap = Map();
  userMap["fromUserId"] = msg.sendUserInfo.userId.toString();
  userMap["toUserId"] = targetId;
  userMap["subObjectName"] = ChatTypeModel.MESSAGE_TYPE_USER;
  userMap["name"] = ChatTypeModel.MESSAGE_TYPE_USER_NAME;
  userMap["data"] = jsonEncode(map);
  msg.content = jsonEncode(userMap);
  return await (isPrivate ? postPrivateMessageManager : postGroupMessageManager)(targetId, msg);
}

//发送直播课程
Future<Message> postMessageManagerLiveCourse(String targetId, Map<String, dynamic> map, bool isPrivate) async {
  TextMessage msg = TextMessage();
  msg.sendUserInfo = getChatUserInfo(groupId: isPrivate ? null : targetId);
  Map<String, dynamic> liveCourseMap = Map();
  liveCourseMap["fromUserId"] = msg.sendUserInfo.userId.toString();
  liveCourseMap["toUserId"] = targetId;
  liveCourseMap["subObjectName"] = ChatTypeModel.MESSAGE_TYPE_LIVE_COURSE;
  liveCourseMap["name"] = ChatTypeModel.MESSAGE_TYPE_LIVE_COURSE_NAME;
  liveCourseMap["data"] = jsonEncode(map);
  msg.content = jsonEncode(liveCourseMap);
  return await (isPrivate ? postPrivateMessageManager : postGroupMessageManager)(targetId, msg);
}

//发送视频课程
Future<Message> postMessageManagerVideoCourse(String targetId, Map<String, dynamic> map, bool isPrivate) async {
  TextMessage msg = TextMessage();
  msg.sendUserInfo = getChatUserInfo(groupId: isPrivate ? null : targetId);
  Map<String, dynamic> videoCourseMap = Map();
  videoCourseMap["fromUserId"] = msg.sendUserInfo.userId.toString();
  videoCourseMap["toUserId"] = targetId;
  videoCourseMap["subObjectName"] = ChatTypeModel.MESSAGE_TYPE_VIDEO_COURSE;
  videoCourseMap["name"] = ChatTypeModel.MESSAGE_TYPE_VIDEO_COURSE_NAME;
  videoCourseMap["data"] = jsonEncode(map);
  msg.content = jsonEncode(videoCourseMap);
  return await (isPrivate ? postPrivateMessageManager : postGroupMessageManager)(targetId, msg);
}

//发送消息--私聊
Future<Message> postPrivateMessageManager(String targetId, MessageContent messageContent) async {
  return await Application.rongCloud.sendPrivateMessage(targetId, messageContent);
}

//发送消息--群聊
Future<Message> postGroupMessageManager(String targetId, MessageContent messageContent) async {
  return await Application.rongCloud.sendGroupMessage(targetId, messageContent);
}

//插入撤回的消息
void postMessageManagerReset(String chatTypeModel, String chatTypeModelName, String content, String targetId,
    int conversationType, Function(Message msg, int code) finished,
    {int sendTime = -1}) {
  TextMessage msg = TextMessage();
  msg.sendUserInfo = getChatUserInfo();
  Map<String, dynamic> alertMap = Map();
  alertMap["fromUserId"] = msg.sendUserInfo.userId.toString();
  alertMap["toUserId"] = targetId;
  alertMap["subObjectName"] = chatTypeModel;
  alertMap["name"] = chatTypeModelName;
  alertMap["data"] = content;
  msg.content = jsonEncode(alertMap);
  Application.rongCloud.insertOutgoingMessage(conversationType, targetId, msg, finished, sendTime: sendTime);
}

//插入被移除群和邀请进入群提示
void insertExitGroupMsg(Message message, String targetId, Function(Message msg, int code) finished) {
  TextMessage msg = TextMessage();
  msg.sendUserInfo = getChatUserInfo(groupId: targetId);
  Map<String, dynamic> alertMap = Map();
  alertMap["subObjectName"] = ChatTypeModel.MESSAGE_TYPE_GRPNTF;
  alertMap["name"] = ChatTypeModel.MESSAGE_TYPE_GRPNTF_NAME;
  alertMap["data"] = jsonEncode(message.originContentMap);
  msg.content = jsonEncode(alertMap);
  Application.rongCloud.insertOutgoingMessage(RCConversationType.Group, targetId, msg, finished,
      sendTime: new DateTime.now().millisecondsSinceEpoch);
}

//插入临时的发送失败的图片以及视频
Future<void> insertTemporaryImage(String targetId, bool isPrivate, bool isImgOrVideo, ChatDataModel chatDataModel,
    int position, Function(Message msg, int code) finished) async {
  TextMessage msg = TextMessage();
  msg.sendUserInfo = getChatUserInfo(groupId: isPrivate ? null : targetId);
  Map<String, dynamic> imgOrVideoMap = Map();
  imgOrVideoMap["fromUserId"] = msg.sendUserInfo.userId.toString();
  imgOrVideoMap["isTemporary"] = true;
  imgOrVideoMap["toUserId"] = targetId;
  imgOrVideoMap["subObjectName"] = isImgOrVideo ? ChatTypeModel.MESSAGE_TYPE_IMAGE : ChatTypeModel.MESSAGE_TYPE_VIDEO;
  imgOrVideoMap["name"] = isImgOrVideo ? ChatTypeModel.MESSAGE_TYPE_IMAGE_NAME : ChatTypeModel.MESSAGE_TYPE_VIDEO_NAME;
  Map sizeMap = chatDataModel.mediaFileModel.sizeInfo.toJson();
  sizeMap["showImageUrl"] = chatDataModel.mediaFileModel.file.path;
  if (!isImgOrVideo) {
    Uint8List thumb = await VideoThumbnail.thumbnailData(
        video: chatDataModel.mediaFileModel.file.path, imageFormat: ImageFormat.JPEG, quality: 100);
    File videoFile = await FileUtil()
        .writeImageDataToFile(thumb, DateTime.now().millisecondsSinceEpoch.toString() + position.toString());
    sizeMap["videoFilePath"] = videoFile.path;
  }
  imgOrVideoMap["data"] = jsonEncode(sizeMap);
  msg.content = jsonEncode(imgOrVideoMap);
  Application.rongCloud.insertOutgoingMessage(
      isPrivate ? RCConversationType.Private : RCConversationType.Group, targetId, msg, finished,
      sendTime: new DateTime.now().millisecondsSinceEpoch, sendStatus: RCSentStatus.Failed);
}

//获取用户数据
UserInfo getChatUserInfo({String groupId}) {
  UserInfo userInfo = UserInfo();
  userInfo.userId = Application.profile.uid.toString();
  userInfo.name = Application.profile.nickName;
  userInfo.portraitUri = Application.profile.avatarUri;
  if (groupId != null) {
    Map<String, dynamic> extraMap = Map();
    extraMap[GROUP_CHAT_USER_INFORMATION_GROUP_USER_NAME] =
        getChatUserName(groupId, Application.profile.uid.toString(), Application.profile.nickName);
    userInfo.extra = jsonEncode(extraMap);
  }
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
void postText(ChatDataModel chatDataModel, String targetId, int chatTypeId, MentionedInfo mentionedInfo,
    VoidCallback voidCallback) async {
  chatDataModel.msg = await postMessageManagerText(
      targetId, chatDataModel.content, mentionedInfo, chatTypeId == RCConversationType.Private);
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

//插入撤回消息
void getReChatDataModel(
    {String targetId,
    int conversationType,
    int chatTypeId,
    int sendTime,
    String text,
    Function(Message msg, int code) finished}) async {
  postMessageManagerReset(ChatTypeModel.MESSAGE_TYPE_ALERT, ChatTypeModel.MESSAGE_TYPE_ALERT_NAME, text, targetId,
      conversationType, finished,
      sendTime: sendTime);
}

//封装时间戳
Message getAlertTimeMsg({int time, int sendTime, String targetId, int conversationType}) {
  TextMessage msg = TextMessage();
  msg.sendUserInfo = getChatUserInfo();
  Map<String, dynamic> timeMap = Map();
  timeMap["fromUserId"] = msg.sendUserInfo.userId.toString();
  timeMap["toUserId"] = targetId;
  timeMap["subObjectName"] = ChatTypeModel.MESSAGE_TYPE_ALERT_TIME;
  timeMap["name"] = ChatTypeModel.MESSAGE_TYPE_ALERT_TIME_NAME;
  timeMap["data"] = time.toString();
  msg.content = jsonEncode(timeMap);
  Message message = new Message();
  message.content = msg;
  message.senderUserId = msg.sendUserInfo.userId;
  message.sentTime = sendTime;
  message.messageId = -1;
  message.messageUId = "-1";
  message.conversationType = conversationType;
  message.targetId = targetId;
  message.objectName = TextMessage.objectName;
  message.sentStatus = RCSentStatus.Sent;
  return message;
}

//封装系统消息
Message getSystemMsg(Map<String, dynamic> dataMap, int targetId) {
  TextMessage msg = TextMessage();
  msg.sendUserInfo = getChatUserInfo();
  msg.content = dataMap["content"];
  Message message = new Message();
  message.content = msg;
  message.senderUserId = targetId.toString();
  message.sentTime = dataMap["msgTimestamp"];
  message.messageId = -1;
  message.messageUId = "-1";
  message.conversationType = RCConversationType.System;
  message.targetId = msg.sendUserInfo.userId.toString();
  message.objectName = TextMessage.objectName;
  message.sentStatus = RCSentStatus.Sent;
  return message;
}

//voice 的更新
void updateMessage(ChatDataModel chatDataModel, Function(int code) finished) {
  VoiceMessage voiceMessage = ((chatDataModel.msg.content) as VoiceMessage);
  Map<String, dynamic> mapModel = json.decode(voiceMessage.extra);
  mapModel["read"] = 1;
  voiceMessage.extra = json.encode(mapModel);
  chatDataModel.msg.content = voiceMessage;
  Map<String, dynamic> expansionDic = Map();
  expansionDic["read"] = "1";
  Application.rongCloud.updateMessage(expansionDic, chatDataModel.msg.messageUId, finished);
}

//发送有选项的model
void postSelectMessage(ChatDataModel chatDataModel, String targetId, int chatTypeId, VoidCallback voidCallback) async {
  chatDataModel.msg =
      await postMessageManagerSelect(targetId, chatDataModel.content, chatTypeId == RCConversationType.Private);
  chatDataModel.isTemporary = false;
  voidCallback();
}

//发送图片或者视频
void postImgOrVideo(
    List<ChatDataModel> modelList, String targetId, String type, int chatTypeId, VoidCallback voidCallback) async {
  modelList = modelList.reversed.toList();
  List<UploadResultModel> uploadResultModelList = await onPostImgOrVideo(modelList, type);

  int count = 0;
  Timer timer = new Timer.periodic(Duration(seconds: 1), (Timer timer) async {
    int end = count + 1;
    if (end > modelList.length) {
      end = modelList.length;
    }
    await postImage(count, end, uploadResultModelList, modelList, targetId, type, chatTypeId, voidCallback);
    count = end;
    if (count >= modelList.length) {
      timer.cancel();
    }
  });
}

Future<void> postImage(int start, int end, List<UploadResultModel> uploadResultModelList, List<ChatDataModel> modelList,
    String targetId, String type, int chatTypeId, VoidCallback voidCallback) async {
  for (int i = start; i < end; i++) {
    print("发送图片：$i");
    int uploadResultModelIndex = -1;
    for (int j = 0; j < uploadResultModelList.length; j++) {
      if (uploadResultModelList[j].filePath == modelList[i].mediaFileModel.file.path) {
        uploadResultModelIndex = j;
        break;
      }
    }
    if (uploadResultModelIndex >= 0) {
      modelList[i].msg = await postMessageManagerImgOrVideo(
          targetId,
          type == mediaTypeKeyImage,
          modelList[i].mediaFileModel,
          uploadResultModelList[uploadResultModelIndex],
          chatTypeId == RCConversationType.Private);
      modelList[i].isTemporary = false;
      modelList[i].status = RCSentStatus.Sent;
      print("----------成功：modelList[i].msg：${modelList[i].msg.toString()}");
    } else {
      //插入临时消息
      await insertTemporaryImage(
          targetId, chatTypeId == RCConversationType.Private, type == mediaTypeKeyImage, modelList[i], i,
          (Message msg, int code) {
        if (msg != null) {
          print("--------------插入成功");
          modelList[i].msg = msg;
          modelList[i].isTemporary = false;
        } else {
          print("--------------插入失败");
        }
        modelList[i].status = RCSentStatus.Failed;
      });
      print("--------------上传图片失败");
    }
  }
  voidCallback();
}

//发送语音
void postVoice(ChatDataModel chatDataModel, String targetId, int conversationType,VoidCallback voidCallback) async {
  chatDataModel.msg = await postMessageManagerVoice(targetId, chatDataModel.chatVoiceModel, conversationType);
  chatDataModel.isTemporary = false;
  voidCallback();
}

//重新发送消息
void resetPostMessage(ChatDataModel chatDataModel, VoidCallback voidCallback) async {
  Message msg = await Application.rongCloud.sendVoiceMessage(chatDataModel.msg);
  if (chatDataModel.msg.messageId != msg.messageId) {
    RongCloud.init().deleteMessageById(chatDataModel.msg, null);
  }
  // print("重新发送消息:${chatDataModel.msg.messageId},${msg.messageId}");
  chatDataModel.msg = msg;
  chatDataModel.isTemporary = false;
  voidCallback();
}

Future<UploadResultModel> onPostImgOrVideoSinge(File file) async {
  List<File> fileList = [];
  fileList.add(file);
  UploadResults results = await FileUtil().uploadPics(fileList, (percent) {});
  List<UploadResultModel> uploadResultModelList = <UploadResultModel>[];
  for (int i = 0; i < results.resultMap.length; i++) {
    UploadResultModel model = results.resultMap.values.elementAt(i);
    uploadResultModelList.add(model);
    print("第${i + 1}个上传文件");
    print(model.isSuccess);
    print(model.error);
    print(model.filePath);
    print(model.url);
  }
  return uploadResultModelList[0];
}

//上传图片和视频
Future<List<UploadResultModel>> onPostImgOrVideo(List<ChatDataModel> modelList, String type) async {
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
        File imageFile =
            await FileUtil().writeImageDataToFile(element.mediaFileModel.croppedImageData, timeStr + i.toString());
        element.mediaFileModel.file = imageFile;
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

//获取at人的名字
String gteAtUserName(List<String> userIdList, List<ChatGroupUserModel> chatGroupUserModelList) {
  String string = "";
  if (userIdList != null && userIdList.length > 0) {
    for (int i = 0; i < userIdList.length; i++) {
      for (int j = 0; j < chatGroupUserModelList.length; j++) {
        if (userIdList[i] == chatGroupUserModelList[j].uid.toString()) {
          string += chatGroupUserModelList[j].nickName + ",";
          break;
        }
      }
    }
    return string;
  } else {
    return string;
  }
}

int getRCConversationType(int type) {
  switch (type) {
    case 100:
    case 10:
      return RCConversationType.Private;
    case 101:
      return RCConversationType.Group;
    default:
      return RCConversationType.System;
  }
}

//获取群成员信息
Future<int> getChatGroupUserModelList(String groupChatId, BuildContext context) async {
  Application.appContext.read<GroupUserProfileNotifier>().clearAllUser();
  List<ChatGroupUserModel> chatGroupUserModelList = [];
  Map<String, dynamic> model = await getMembers(groupChatId: int.parse(groupChatId));
  // print("------model:${model.toString()}");
  if (model != null && model["list"] != null) {
    model["list"].forEach((v) {
      ChatGroupUserModel model = ChatGroupUserModel.fromJson(v);
      chatGroupUserModelList.add(model);
      GroupChatUserInformationDBHelper().update(chatGroupUserModel: model, groupId: groupChatId);
    });
    Future.delayed(Duration(milliseconds: 150), () {
      Application.appContext
          .read<GroupUserProfileNotifier>()
          .addAll(chatGroupUserModelList, chatGroupUserModelList.length);
    });
  } else {
    Future.delayed(Duration(milliseconds: 150), () {
      Application.appContext.read<GroupUserProfileNotifier>().setLen(chatGroupUserModelList.length);
    });
  }
  return chatGroupUserModelList.length;

  // print("------len:${chatGroupUserModelList.length}");
}

//获取群成员信息
Future<void> getChatGroupUserModelList1(String groupChatId, BuildContext context) async {
  context.read<GroupUserProfileNotifier>().clearAllUser();
  List<ChatGroupUserModel> chatGroupUserModelList = [];
  Map<String, dynamic> model = await getMembers(groupChatId: int.parse(groupChatId));
  print("------model:${model.toString()}");
  if (model != null && model["list"] != null) {
    model["list"].forEach((v) {
      ChatGroupUserModel model = ChatGroupUserModel.fromJson(v);
      chatGroupUserModelList.add(model);
      GroupChatUserInformationDBHelper().update(chatGroupUserModel: model, groupId: groupChatId);
    });
    context.read<GroupUserProfileNotifier>().addAll(chatGroupUserModelList, chatGroupUserModelList.length);
  } else {
    context.read<GroupUserProfileNotifier>().setLen(chatGroupUserModelList.length);
  }

  print("------len:${chatGroupUserModelList.length}");
}

String getChatUserName(String groupId, String userId, String name) {
  String userName = ((Application.chatGroupUserInformationMap["${groupId}_$userId"] ??
      Map())[GROUP_CHAT_USER_INFORMATION_GROUP_USER_NAME]);
  if (userName == null || userName.length < 1) {
    userName =
        (Application.chatGroupUserInformationMap["${groupId}_$userId"] ?? Map())[GROUP_CHAT_USER_INFORMATION_USER_NAME];
  }
  if (userName == null || userName.length < 1) {
    return name;
  } else {
    return userName;
  }
}

String getChatTypeModel(ChatDataModel chatDataModel) {
  if (chatDataModel == null) {
    return "";
  } else if (chatDataModel.type != null) {
    return chatDataModel.type;
  } else if (chatDataModel.msg.objectName == ChatTypeModel.MESSAGE_TYPE_TEXT) {
    TextMessage textMessage = ((chatDataModel.msg.content) as TextMessage);
    Map<String, dynamic> mapModel = json.decode(textMessage.content);
    return mapModel["subObjectName"];
  } else {
    return chatDataModel.msg.objectName;
  }
}



//获取时间戳
ChatDataModel getTimeAlertModel(int sentTime, String chatId) {
  ChatDataModel dataModel = new ChatDataModel();
  dataModel.msg = getAlertTimeMsg(
      time: sentTime, sendTime: sentTime, targetId: chatId, conversationType: RCConversationType.Private);
  return dataModel;
}

//将发送的临时消息加入全局
addTemporaryMessage(ChatDataModel chatDataModel, ConversationDto conversation) {
  if (Application.postChatDataModelList[conversation.id] == null) {
    List<ChatDataModel> modelList = <ChatDataModel>[];
    modelList.add(chatDataModel);
    Application.postChatDataModelList[conversation.id] = modelList;
  } else {
    Application.postChatDataModelList[conversation.id].add(chatDataModel);
  }
}

//从全局的临时消息中删除发送完成的消息
deletePostCompleteMessage(ConversationDto conversation) {
  if (Application.postChatDataModelList[conversation.id] == null ||
      Application.postChatDataModelList[conversation.id].length < 1) {
    return;
  } else {
    for (int i = 0; i < Application.postChatDataModelList[conversation.id].length; i++) {
      if (!Application.postChatDataModelList[conversation.id][i].isTemporary) {
        Application.postChatDataModelList[conversation.id].removeAt(i);
      }
    }
  }
}

//当删除消息时，修改外部提示
void updateMessagePageAlert(ConversationDto conversation, BuildContext context) async {
  List msgList = new List();
  msgList = await RongCloud.init().getHistoryMessages(
      conversation.getType(), conversation.conversationId, new DateTime.now().millisecondsSinceEpoch, 1, 0);
  if (msgList != null && msgList.length > 0) {
    MessageManager.updateConversationByMessageContent(context, conversation.id, msg: msgList[0]);
  } else {
    MessageManager.updateConversationByMessageContent(context, conversation.id);
  }
}

/// 获得文本输入框样式
List<RangeStyle> getTextFieldStyle(List<Rule> rules) {
  List<RangeStyle> result = [];
  for (Rule rule in rules) {
    result.add(
      RangeStyle(
        range: TextRange(start: rule.startIndex, end: rule.endIndex),
        style: TextStyle(color: AppColor.mainBlue),
      ),
    );
  }
  return result.length == 0 ? null : result;
}

//是否继续
Future<bool> isContinue(BuildContext context) async {
  if (ClickUtil.isFastClick()) {
    print("快速点击");
    return false;
  }
  if (await isOffline()) {
    ToastShow.show(msg: "请检查网络!", context: context);
    return false;
  }
  return true;
}

Future<bool> isOffline() async {
  ConnectivityResult connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.mobile) {
    return false;
  } else if (connectivityResult == ConnectivityResult.wifi) {
    return false;
  } else {
    return true;
  }
}

// 请求动态详情页数据
getFeedDetail(int feedId, BuildContext context) async {
  BaseResponseModel feedModel = await feedDetail(id: feedId);
  if (feedModel.data != null) {
    List<HomeFeedModel> list = [];
    list.add(HomeFeedModel.fromJson(feedModel.data));
    context.read<FeedMapNotifier>().updateFeedMap(list);
  }
  // print("----------feedModel:${feedModel.toJson().toString()}");
  // 跳转动态详情页
  if (feedModel.code == CODE_SUCCESS || feedModel.code == CODE_NO_DATA) {
    AppRouter.navigateFeedDetailPage(
        context: context,
        model: feedModel.data != null ? HomeFeedModel.fromJson(feedModel.data) : null,
        type: 1,
        errorCode: feedModel.code);
  }
}

ConversationDto _convertMsgToConversation(String conversationDtoId) {
  ConversationDto dto = Application.appContext.read<ConversationNotifier>().getConversationById(conversationDtoId);
  return dto;
}

//判断去拿一个更多界面
void judgeJumpPage(int chatTypeId, String chatUserId, int chatType, BuildContext context, String name, listener,
    exitGroupListener, String conversationDtoId) {
  if (chatTypeId == RCConversationType.Group) {
    jumpPage(
        GroupMorePage(
            chatGroupId: chatUserId,
            chatType: chatType,
            groupName: name,
            listener: listener,
            exitGroupListener: exitGroupListener,
            dto: _convertMsgToConversation(conversationDtoId)),
        false,
        AppRouter.pathGroupMorePage,
        context);
  } else {
    jumpPage(
        PrivateMorePage(
            chatUserId: chatUserId,
            chatType: chatType,
            name: name,
            listener: listener,
            dto: _convertMsgToConversation(conversationDtoId)),
        false,
        AppRouter.pathPrivateMorePage,
        context);
  }
}

void jumpPage(var page, bool isCloseNewPage, String name, BuildContext context) {
  if (isCloseNewPage) {
    //跳转并关闭当前页面
    Navigator.pushAndRemoveUntil(
      context,
      new MaterialPageRoute(builder: (context) => page),
      (route) => route == null,
    );
  } else {
    //跳转不关闭当前页面
    Navigator.of(context).push(
      new MaterialPageRoute(
        settings: RouteSettings(name: name),
        builder: (context) {
          return page;
        },
      ),
    );
  }
}
