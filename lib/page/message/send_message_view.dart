import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/data/dto/conversation_dto.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/training/live_video_model.dart';
import 'package:mirror/data/model/media_file_model.dart';
import 'package:mirror/data/model/message/chat_data_model.dart';
import 'package:mirror/data/model/message/chat_type_model.dart';
import 'package:mirror/data/model/message/chat_voice_model.dart';
import 'package:mirror/data/model/user_model.dart';
import 'package:mirror/page/message/message_view/alert_msg.dart';
import 'package:mirror/page/message/message_view/feed_msg.dart';
import 'package:mirror/util/string_util.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

import 'message_view/currency_msg.dart';
import 'message_view/img_video_msg.dart';
import 'message_view/live_video_course_msg.dart';
import 'message_view/select_msg.dart';
import 'message_view/text_msg.dart';
import 'message_view/user_msg.dart';
import 'message_view/voice_msg.dart';

///聊天-筛选这个消息的是哪一种消息
// ignore: must_be_immutable
class SendMessageView extends StatelessWidget {
  final ChatDataModel model;
  final VoidMessageClickCallBack voidMessageClickCallBack;
  final VoidItemLongClickCallBack voidItemLongClickCallBack;
  final int position;
  final String chatUserName;
  final int conversationDtoType;
  final bool isShowChatUserName;

  SendMessageView(this.model, this.position, this.voidMessageClickCallBack, this.voidItemLongClickCallBack,
      this.chatUserName, this.isShowChatUserName, this.conversationDtoType);

  bool isMyself;
  String userUrl;
  String name;
  int status;
  String sendChatUserId;

  @override
  Widget build(BuildContext context) {
    userUrl = Application.profile.avatarUri;
    sendChatUserId = Application.profile.uid.toString();
    name = getChatUserName(sendChatUserId, Application.profile.nickName);

    if (model.isTemporary) {
      print("临时的");
      isMyself = true;
      status = RCSentStatus.Sending;
      return temporaryData();
    } else if (Application.profile.uid.toString() == model.msg.senderUserId) {
      isMyself = true;
      status = model.msg.sentStatus;
      return notTemporaryData();
    } else {
      isMyself = false;
      status = model.msg.sentStatus;
      sendChatUserId = model.msg.senderUserId;
      if (conversationDtoType == OFFICIAL_TYPE) {
        userUrl = "http://devpic.aimymusic.com/app/system_message_avatar.png";
        name = "系统消息";
      } else if (conversationDtoType == LIVE_TYPE) {
        userUrl = "http://devpic.aimymusic.com/app/group_notification_avatar.png";
        name = "官方直播";
      } else if (conversationDtoType == TRAINING_TYPE) {
        userUrl = "http://devpic.aimymusic.com/app/stranger_message_avatar.png";
        name = "运动数据";
      } else {
        try {
          userUrl = model.msg.content.sendUserInfo?.portraitUri;
          name = getChatUserName(sendChatUserId, model.msg.content.sendUserInfo?.name);
        } catch (e) {
        }
      }
      return notTemporaryData();
    }
  }

  //临时消息
  Widget temporaryData() {
    //普通消息
    if (model.type == ChatTypeModel.MESSAGE_TYPE_TEXT) {
      //文字消息
      return getTextMsg(text: model.content, mentionedInfo: model.mentionedInfo);
    } else if (model.type == ChatTypeModel.MESSAGE_TYPE_IMAGE) {
      //图片消息
      return getImgVideoMsg(
          isTemporary: true,
          isImgOrVideo: true,
          mediaFileModel: model.mediaFileModel);
    } else if (model.type == ChatTypeModel.MESSAGE_TYPE_VIDEO) {
      //视频消息
      return getImgVideoMsg(
          isTemporary: true,
          isImgOrVideo: false,
          mediaFileModel: model.mediaFileModel);
    } else if (model.type == ChatTypeModel.MESSAGE_TYPE_VOICE) {
      //语音消息
      // return new Text('语音消息');
      return getVoiceMsgData(null, model.chatVoiceModel.toJson(), true,
          StringUtil.generateMd5(model.chatVoiceModel.filePath));
    } else if (model.type == ChatTypeModel.MESSAGE_TYPE_SELECT) {
      //可选择的列表
      return getSelectMsgData(model.content);
    } else {
      return new Text('未知消息');
    }
  }

  //显示正式消息
  Widget notTemporaryData() {
    Message msg = model.msg;
    if (msg == null) {
      print(msg.toString() + "为空");
      return Container();
    }
    String msgType = msg.objectName;

    //todo 目前是使用的是 TextMessage 等以后有了自定义的 再改
    if (msgType == ChatTypeModel.MESSAGE_TYPE_TEXT) {
      TextMessage textMessage = ((msg.content) as TextMessage);
      // return TextMsg(textMessage.content, model);
      try {
        Map<String, dynamic> mapModel = json.decode(textMessage.content);
        if (mapModel["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_TEXT) {
          //文字消息
          return getTextMsg(text: mapModel["data"], mentionedInfo: msg.content.mentionedInfo);
        } else if (mapModel["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_FEED) {
          //动态消息
          return getFeedMsgData(json.decode(mapModel["data"]));
        } else if (mapModel["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_USER) {
          //名片消息
          return getUserMsgData(json.decode(mapModel["data"]));
        } else if (mapModel["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_IMAGE ||
            mapModel["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_VIDEO) {
          //图片视频消息
          Map<String, dynamic> sizeInfoMap = json.decode(mapModel["data"]);
          return getImgVideoMsg(
              isTemporary: false,
              isImgOrVideo:
              mapModel["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_IMAGE,
              mediaFileModel: model.mediaFileModel,
              sizeInfoMap: sizeInfoMap);
        } else if (mapModel["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_LIVE_COURSE ||
            mapModel["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_VIDEO_COURSE) {
          //直播和视频课程消息
          Map<String, dynamic> liveVideoModelMap =
          json.decode(mapModel["data"]);
          return getLiveVideoCourseMsg(
              liveVideoModelMap, mapModel["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_LIVE_COURSE, msg.messageUId);
        } else if (mapModel["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_ALERT_TIME ||
            mapModel["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_ALERT_INVITE ||
            mapModel["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_ALERT_NEW ||
            mapModel["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_ALERT ||
            mapModel["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_ALERT_REMOVE) {
          // return new Text('提示消息');
          return getAlertMsg(map: mapModel);
        } else if (mapModel["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_SELECT) {
          // return new Text('可选择的列表');
          return getSelectMsgData(mapModel["data"]);
        } else if (mapModel["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_GRPNTF) {
          print("----------------------------------------------------------------------------");
          // return new Text('群通知消息');
          Map<String, dynamic> map = Map();
          map["subObjectName"] = ChatTypeModel.MESSAGE_TYPE_ALERT_GROUP;
          map["data"] = json.decode(mapModel["data"]);
          return getAlertMsg(map: map);
        } else if (mapModel["name"] != null) {
          //版本过低
          return getTextMsg(text: mapModel["name"], mentionedInfo: msg.content.mentionedInfo);
        }
        print("map:${mapModel.toString()}");
      } catch (e) {
        return getTextMsg(text: "版本过低请升级版本!", mentionedInfo: msg.content.mentionedInfo);
      }
    } else if (msgType == VoiceMessage.objectName) {
      // return new Text('语音消息');
      return getVoiceMessage(msg);
    } else if (msgType == RecallNotificationMessage.objectName) {
      // return new Text('提示消息--撤回');
      return getAlertMsg(recallNotificationMessage: ((msg.content) as RecallNotificationMessage));
    } else if (msgType == ChatTypeModel.MESSAGE_TYPE_GRPNTF) {
      // return new Text('群通知');
      Map<String, dynamic> map = Map();
      map["subObjectName"] = ChatTypeModel.MESSAGE_TYPE_ALERT_GROUP;
      map["data"] = msg.originContentMap;
      return getAlertMsg(map: map);
    } else if (msgType == ChatTypeModel.MESSAGE_TYPE_CMD) {
      print("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
      // return new Text('群通知');
      Map<String, dynamic> map = Map();
      map["subObjectName"] = ChatTypeModel.MESSAGE_TYPE_ALERT_GROUP;
      map["data"] = msg.originContentMap;
      return getAlertMsg(map: map);
    }
    if (msg.content == null || msg.content.mentionedInfo == null) {
      return getTextMsg(text: "版本过低请升级版本!");
    } else {
      return getTextMsg(text: "版本过低请升级版本!", mentionedInfo: msg.content.mentionedInfo ?? null);
    }
  }

  //************************获取消息模块的方法 ----start


  //语音信息
  Widget getVoiceMessage(Message msg) {
    // 语音消息
    VoiceMessage voiceMessage = ((msg.content) as VoiceMessage);
    Map<String, dynamic> mapModel;
    mapModel = json.decode(voiceMessage.extra);
    try {
      if (msg.expansionDic != null && msg.expansionDic["read"] != null) {
        if (msg.expansionDic["read"] == "1") {
          mapModel["read"] = 1;
        }
      }
    } catch (e) {}
    if (voiceMessage.remoteUrl != null) {
      mapModel["pathUrl"] = voiceMessage.remoteUrl;
    }
    print("mapModel[read]" + mapModel["read"].toString());
    return getVoiceMsgData(msg.messageUId, mapModel, false,
        StringUtil.generateMd5(voiceMessage.remoteUrl != null ? voiceMessage.remoteUrl : mapModel["filePath"]));
  }

  String getChatUserName(String uId, String name) {
    if (isShowChatUserName) {
      // print("uId:$uId---Application.chatGroupUserModelMap:${Application.chatGroupUserModelMap.toString()}");
      String userName = Application.chatGroupUserModelMap[uId];
      if (userName == null) {
        return name;
      } else {
        return userName;
      }
    }
    return name;
  }

  bool isCanLongClick() {
    return conversationDtoType != LIVE_TYPE &&
        conversationDtoType != OFFICIAL_TYPE &&
        conversationDtoType != TRAINING_TYPE;
  }

  //************************获取消息模块的方法 ----end

  //***************************************获取每一个消息的模块-----start

  //获取普通文本模块
  Widget getTextMsg({String text, MentionedInfo mentionedInfo}) {
    return TextMsg(
        text: text,
        isMyself: isMyself,
        userUrl: userUrl,
        name: name,
        sendChatUserId: sendChatUserId,
        isCanLongClick: isCanLongClick(),
        isShowChatUserName: isShowChatUserName,
        mentionedInfo: mentionedInfo,
        voidMessageClickCallBack: voidMessageClickCallBack,
        voidItemLongClickCallBack: voidItemLongClickCallBack,
        position: position,
        status: status);
  }

  //获取动态模块
  Widget getFeedMsgData(Map<String, dynamic> homeFeedModeMap) {
    HomeFeedModel homeFeedMode = HomeFeedModel.fromJson(homeFeedModeMap);
    return FeedMsg(
        homeFeedMode: homeFeedMode,
        isMyself: isMyself,
        userUrl: userUrl,
        name: name,
        sendChatUserId: sendChatUserId,
        isCanLongClick: isCanLongClick(),
        isShowChatUserName: isShowChatUserName,
        voidMessageClickCallBack: voidMessageClickCallBack,
        voidItemLongClickCallBack: voidItemLongClickCallBack,
        position: position,
        status: status);
  }

  //获取选项列表
  Widget getSelectMsgData(String selectListString) {
    return SelectMsg(
        selectListString: selectListString,
        isMyself: isMyself,
        userUrl: userUrl,
        name: name,
        sendChatUserId: sendChatUserId,
        isCanLongClick: isCanLongClick(),
        isShowChatUserName: isShowChatUserName,
        voidMessageClickCallBack: voidMessageClickCallBack,
        voidItemLongClickCallBack: voidItemLongClickCallBack,
        position: position,
        status: status);
  }

  //获取语音
  Widget getVoiceMsgData(
      String messageUId,
      Map<String, dynamic> chatVoiceModelMap,
      bool isTemporary,
      String playMd5String) {
    ChatVoiceModel chatVoiceModel = ChatVoiceModel.fromJson(chatVoiceModelMap);
    // chatVoiceModel.read = 1;
    return VoiceMsg(
        messageUId: messageUId,
        chatVoiceModel: chatVoiceModel,
        isMyself: isMyself,
        isTemporary: isTemporary,
        userUrl: userUrl,
        name: name,
        sendChatUserId: sendChatUserId,
        isCanLongClick: isCanLongClick(),
        isShowChatUserName: isShowChatUserName,
        voidMessageClickCallBack: voidMessageClickCallBack,
        voidItemLongClickCallBack: voidItemLongClickCallBack,
        position: position,
        status: status);
  }

  //获取直播和视频的模块
  Widget getLiveVideoCourseMsg(Map<String, dynamic> liveVideoModelMap, bool isLiveOrVideo, String msgId) {
    LiveVideoModel liveVideoModel = LiveVideoModel.fromJson(liveVideoModelMap);
    return LiveVideoCourseMsg(
        liveVideoModel: liveVideoModel,
        isLiveOrVideo: isLiveOrVideo,
        isMyself: isMyself,
        userUrl: userUrl,
        name: name,
        msgId: msgId,
        sendChatUserId: sendChatUserId,
        isCanLongClick: isCanLongClick(),
        isShowChatUserName: isShowChatUserName,
        voidMessageClickCallBack: voidMessageClickCallBack,
        voidItemLongClickCallBack: voidItemLongClickCallBack,
        position: position,
        status: status);
  }

  //获取用户名片模块
  Widget getUserMsgData(Map<String, dynamic> userModelMap) {
    UserModel userModel = UserModel.fromJson(userModelMap);
    return UserMsg(
        userModel: userModel,
        isMyself: isMyself,
        userUrl: userUrl,
        name: name,
        sendChatUserId: sendChatUserId,
        isCanLongClick: isCanLongClick(),
        isShowChatUserName: isShowChatUserName,
        voidMessageClickCallBack: voidMessageClickCallBack,
        voidItemLongClickCallBack: voidItemLongClickCallBack,
        position: position,
        status: status);
  }

  //获取图片和视频的模块
  Widget getImgVideoMsg({bool isTemporary,
    bool isImgOrVideo,
    MediaFileModel mediaFileModel,
    ImageMessage imageMessage,
    Map<String, dynamic> sizeInfoMap}) {
    return ImgVideoMsg(
      isMyself: isMyself,
      userUrl: userUrl,
      name: name,
      status: status,
      sendChatUserId: sendChatUserId,
      isCanLongClick: isCanLongClick(),
      isTemporary: isTemporary,
      isImgOrVideo: isImgOrVideo,
      mediaFileModel: mediaFileModel,
      imageMessage: imageMessage,
      sizeInfoMap: sizeInfoMap,
      isShowChatUserName: isShowChatUserName,
      voidMessageClickCallBack: voidMessageClickCallBack,
      voidItemLongClickCallBack: voidItemLongClickCallBack,
      position: position,
    );
  }


  //提示消息
  Widget getAlertMsg({Map<String,
      dynamic> map, RecallNotificationMessage recallNotificationMessage}) {
    return AlertMsg(
      position: position,
      chatUserName: chatUserName,
      isShowChatUserName: isShowChatUserName,
      voidMessageClickCallBack: voidMessageClickCallBack,
      voidItemLongClickCallBack: voidItemLongClickCallBack,
      map: map,
      recallNotificationMessage: recallNotificationMessage,
    );
  }

//***************************************获取每一个消息的模块-----end
}


