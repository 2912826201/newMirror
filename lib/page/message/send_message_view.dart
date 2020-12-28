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
import 'package:mirror/page/message/message_view/feed_msg.dart';
import 'package:mirror/util/string_util.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

import 'message_view/currency_msg.dart';
import 'message_view/img_video_msg.dart';
import 'message_view/live_video_course_msg.dart';
import 'message_view/text_msg.dart';
import 'message_view/user_msg.dart';
import 'message_view/voice_msg.dart';

class SendMessageView extends StatefulWidget {
  final ChatDataModel model;
  final VoidMessageClickCallBack voidMessageClickCallBack;
  final VoidItemLongClickCallBack voidItemLongClickCallBack;
  final int position;

  SendMessageView(this.model, this.position, this.voidMessageClickCallBack,
      this.voidItemLongClickCallBack);

  @override
  _SendMessageViewState createState() => _SendMessageViewState();
}

class _SendMessageViewState extends State<SendMessageView> {
  bool isMyself;
  String userUrl;
  String name;
  int status;

  @override
  Widget build(BuildContext context) {
    if (widget.model.isTemporary) {
      print("临时的");
      isMyself = true;
      userUrl = Application.profile.avatarUri;
      name = Application.profile.nickName;
      status = RCSentStatus.Sending;
      return temporaryData();
    } else {
      isMyself =
          Application.profile.uid.toString() == widget.model.msg.senderUserId;
      userUrl = widget.model.msg.content.sendUserInfo.portraitUri;
      name = widget.model.msg.content.sendUserInfo.name;
      status = widget.model.status;
      return notTemporaryData();
    }
  }

  //临时消息
  Widget temporaryData() {
    //普通消息
    if (widget.model.type == ChatTypeModel.MESSAGE_TYPE_TEXT) {
      //文字消息
      return getTextMsg(text: widget.model.content);
    } else if (widget.model.type == ChatTypeModel.MESSAGE_TYPE_IMAGE) {
      //图片消息
      return getImgVideoMsg(
          isTemporary: true,
          isImgOrVideo: true,
          mediaFileModel: widget.model.mediaFileModel);
    } else if (widget.model.type == ChatTypeModel.MESSAGE_TYPE_VIDEO) {
      //视频消息
      return getImgVideoMsg(
          isTemporary: true,
          isImgOrVideo: false,
          mediaFileModel: widget.model.mediaFileModel);
    } else if (widget.model.type == ChatTypeModel.MESSAGE_TYPE_VOICE) {
      //语音消息
      // return new Text('语音消息');
      return getVoiceMsgData(widget.model.chatVoiceModel.toJson(), true,
          StringUtil.generateMd5(widget.model.chatVoiceModel.filePath));
    } else {
      return new Text('未知消息');
    }
  }

  //显示正式消息
  Widget notTemporaryData() {
    Message msg = widget.model.msg;
    if (msg == null) {
      print(msg.toString() + "为空");
      return Container();
    }
    String msgType = msg.objectName;

    //todo 目前是使用的是 TextMessage 等以后有了自定义的 再改
    if (msgType == ChatTypeModel.MESSAGE_TYPE_TEXT) {
      TextMessage textMessage = ((msg.content) as TextMessage);
      // return TextMsg(textMessage.content, widget.model);
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
              mediaFileModel: widget.model.mediaFileModel,
              sizeInfoMap: sizeInfoMap);
        } else if (mapModel["type"] == ChatTypeModel.MESSAGE_TYPE_LIVE_COURSE ||
            mapModel["type"] == ChatTypeModel.MESSAGE_TYPE_VIDEO_COURSE) {
          //直播和视频课程消息
          Map<String, dynamic> liveVideoModelMap =
              json.decode(mapModel["content"]);
          return getLiveVideoCourseMsg(liveVideoModelMap,
              mapModel["type"] == ChatTypeModel.MESSAGE_TYPE_LIVE_COURSE);
        }
      } catch (e) {
        return getTextMsg(text: textMessage.content);
      }
    } else if (msgType == ChatTypeModel.MESSAGE_TYPE_IMAGE) {
      //图片--视频消息
      ImageMessage imageMessage = ((msg.content) as ImageMessage);
      Map<String, dynamic> mapModel = json.decode(imageMessage.extra);
      return getImgVideoMsg(
          isTemporary: false,
          isImgOrVideo: mapModel["type"] == mediaTypeKeyImage,
          mediaFileModel: widget.model.mediaFileModel,
          imageMessage: imageMessage);
    } else if (msgType == VoiceMessage.objectName) {
      // return new Text('语音消息');
      // 语音消息
      VoiceMessage voiceMessage = ((msg.content) as VoiceMessage);
      Map<String, dynamic> mapModel = json.decode(voiceMessage.extra);
      if (voiceMessage.remoteUrl != null) {
        mapModel["pathUrl"] = voiceMessage.remoteUrl;
      }
      return getVoiceMsgData(
          mapModel,
          false,
          StringUtil.generateMd5(voiceMessage.remoteUrl != null
              ? voiceMessage.remoteUrl
              : mapModel["filePath"]));
    }
    return new Text('未知消息');
  }

  //获取普通文本模块
  Widget getTextMsg({String text}) {
    return TextMsg(
        text: text,
        isMyself: isMyself,
        userUrl: userUrl,
        name: name,
        voidMessageClickCallBack: widget.voidMessageClickCallBack,
        voidItemLongClickCallBack: widget.voidItemLongClickCallBack,
        position: widget.position,
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
        voidMessageClickCallBack: widget.voidMessageClickCallBack,
        voidItemLongClickCallBack: widget.voidItemLongClickCallBack,
        position: widget.position,
        status: status);
  }

  //获取语音
  Widget getVoiceMsgData(Map<String, dynamic> chatVoiceModelMap,
      bool isTemporary, String playMd5String) {
    ChatVoiceModel chatVoiceModel = ChatVoiceModel.fromJson(chatVoiceModelMap);
    return VoiceMsg(
        chatVoiceModel: chatVoiceModel,
        isMyself: isMyself,
        isTemporary: isTemporary,
        userUrl: userUrl,
        name: name,
        voidMessageClickCallBack: widget.voidMessageClickCallBack,
        voidItemLongClickCallBack: widget.voidItemLongClickCallBack,
        position: widget.position,
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
        voidMessageClickCallBack: widget.voidMessageClickCallBack,
        voidItemLongClickCallBack: widget.voidItemLongClickCallBack,
        position: widget.position,
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
        voidMessageClickCallBack: widget.voidMessageClickCallBack,
        voidItemLongClickCallBack: widget.voidItemLongClickCallBack,
        position: widget.position,
        status: status);
  }

  //获取图片和视频的模块
  Widget getImgVideoMsg(
      {bool isTemporary,
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
      voidMessageClickCallBack: widget.voidMessageClickCallBack,
      voidItemLongClickCallBack: widget.voidItemLongClickCallBack,
      position: widget.position,
    );
  }
}
