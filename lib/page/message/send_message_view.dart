import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/live_model.dart';
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

// ignore: must_be_immutable
class SendMessageView extends StatelessWidget {
  final ChatDataModel model;
  final VoidMessageClickCallBack voidMessageClickCallBack;
  final VoidItemLongClickCallBack voidItemLongClickCallBack;
  final int position;
  final String chatUserName;

  SendMessageView(this.model, this.position, this.voidMessageClickCallBack,
      this.voidItemLongClickCallBack, this.chatUserName);

  bool isMyself;
  String userUrl;
  String name;
  int status;

  @override
  Widget build(BuildContext context) {
    if (model.isTemporary) {
      print("临时的");
      isMyself = true;
      userUrl = Application.profile.avatarUri;
      name = Application.profile.nickName;
      status = RCSentStatus.Sending;
      return temporaryData();
    } else {
      isMyself = Application.profile.uid.toString() == model.msg.senderUserId;
      userUrl = model.msg.content.sendUserInfo.portraitUri;
      name = model.msg.content.sendUserInfo.name;
      status = model.status;
      return notTemporaryData();
    }
  }

  //临时消息
  Widget temporaryData() {
    //普通消息
    if (model.type == ChatTypeModel.MESSAGE_TYPE_TEXT) {
      //文字消息
      return getTextMsg(text: model.content);
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
        if (mapModel["type"] == ChatTypeModel.MESSAGE_TYPE_TEXT) {
          //文字消息
          return getTextMsg(text: mapModel["content"]);
        } else if (mapModel["type"] == ChatTypeModel.MESSAGE_TYPE_FEED) {
          //动态消息
          return getFeedMsgData(json.decode(mapModel["content"]));
        } else if (mapModel["type"] == ChatTypeModel.MESSAGE_TYPE_USER) {
          //名片消息
          return getUserMsgData(json.decode(mapModel["content"]));
        } else if (mapModel["type"] == ChatTypeModel.MESSAGE_TYPE_IMAGE ||
            mapModel["type"] == ChatTypeModel.MESSAGE_TYPE_VIDEO) {
          //图片视频消息
          Map<String, dynamic> sizeInfoMap = json.decode(mapModel["content"]);
          return getImgVideoMsg(
              isTemporary: false,
              isImgOrVideo:
                  mapModel["type"] == ChatTypeModel.MESSAGE_TYPE_IMAGE,
              mediaFileModel: model.mediaFileModel,
              sizeInfoMap: sizeInfoMap);
        } else if (mapModel["type"] == ChatTypeModel.MESSAGE_TYPE_LIVE_COURSE ||
            mapModel["type"] == ChatTypeModel.MESSAGE_TYPE_VIDEO_COURSE) {
          //直播和视频课程消息
          Map<String, dynamic> liveVideoModelMap =
          json.decode(mapModel["content"]);
          return getLiveVideoCourseMsg(liveVideoModelMap,
              mapModel["type"] == ChatTypeModel.MESSAGE_TYPE_LIVE_COURSE);
        } else if (mapModel["type"] == ChatTypeModel.MESSAGE_TYPE_ALERT_TIME ||
            mapModel["type"] == ChatTypeModel.MESSAGE_TYPE_ALERT_INVITE ||
            mapModel["type"] == ChatTypeModel.MESSAGE_TYPE_ALERT_NEW ||
            mapModel["type"] == ChatTypeModel.MESSAGE_TYPE_ALERT_REMOVE) {
          // return new Text('提示消息');
          return getAlertMsg(map: mapModel);
        } else if (mapModel["type"] == ChatTypeModel.MESSAGE_TYPE_SELECT) {
          // return new Text('可选择的列表');
          return getSelectMsgData(mapModel["content"]);
        }
      } catch (e) {
        return getTextMsg(text: textMessage.content);
      }
    } else if (msgType == ChatTypeModel.MESSAGE_TYPE_IMAGE) {
      //图片--视频消息
      return getImageMessage(msg);
    } else if (msgType == VoiceMessage.objectName) {
      // return new Text('语音消息');
      return getVoiceMessage(msg);
    } else if (msgType == RecallNotificationMessage.objectName) {
      // return new Text('提示消息');
      return getAlertMsg(
          recallNotificationMessage:
          ((msg.content) as RecallNotificationMessage));
    }
    return new Text('未知消息');
  }

  //************************获取消息模块的方法 ----start

  //图片--视频消息
  Widget getImageMessage(Message msg) {
    ImageMessage imageMessage = ((msg.content) as ImageMessage);
    Map<String, dynamic> mapModel = json.decode(imageMessage.extra);
    return getImgVideoMsg(
        isTemporary: false,
        isImgOrVideo: mapModel["type"] == mediaTypeKeyImage,
        mediaFileModel: model.mediaFileModel,
        imageMessage: imageMessage);
  }

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
    return getVoiceMsgData(
        msg.messageUId,
        mapModel,
        false,
        StringUtil.generateMd5(voiceMessage.remoteUrl != null
            ? voiceMessage.remoteUrl
            : mapModel["filePath"]));
  }

  //************************获取消息模块的方法 ----end

  //***************************************获取每一个消息的模块-----start

  //获取普通文本模块
  Widget getTextMsg({String text}) {
    return TextMsg(
        text: text,
        isMyself: isMyself,
        userUrl: userUrl,
        name: name,
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
        voidMessageClickCallBack: voidMessageClickCallBack,
        voidItemLongClickCallBack: voidItemLongClickCallBack,
        position: position,
        status: status);
  }

  //获取直播和视频的模块
  Widget getLiveVideoCourseMsg(
      Map<String, dynamic> liveVideoModelMap, bool isLiveOrVideo) {
    LiveModel liveVideoModel = LiveModel.fromJson(liveVideoModelMap);
    return LiveVideoCourseMsg(
        liveVideoModel: liveVideoModel,
        isLiveOrVideo: isLiveOrVideo,
        isMyself: isMyself,
        userUrl: userUrl,
        name: name,
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
      isTemporary: isTemporary,
      isImgOrVideo: isImgOrVideo,
      mediaFileModel: mediaFileModel,
      imageMessage: imageMessage,
      sizeInfoMap: sizeInfoMap,
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
      voidMessageClickCallBack: voidMessageClickCallBack,
      voidItemLongClickCallBack: voidItemLongClickCallBack,
      map: map,
      recallNotificationMessage: recallNotificationMessage,
    );
  }

//***************************************获取每一个消息的模块-----end
}


