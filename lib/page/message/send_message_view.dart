import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/data/dto/conversation_dto.dart';
import 'package:mirror/data/dto/group_chat_user_information_dto.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/message/chat_system_message_model.dart';
import 'package:mirror/data/model/training/course_model.dart';
import 'package:mirror/data/model/media_file_model.dart';
import 'package:mirror/data/model/message/chat_data_model.dart';
import 'package:mirror/data/model/message/chat_type_model.dart';
import 'package:mirror/data/model/message/chat_voice_model.dart';
import 'package:mirror/data/model/user_model.dart';
import 'package:mirror/page/message/item/chat_page_ui.dart';
import 'package:mirror/page/message/message_view/alert_msg.dart';
import 'package:mirror/page/message/message_view/feed_msg.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/util/string_util.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

import 'item/currency_msg.dart';
import 'message_view/img_video_msg.dart';
import 'message_view/live_video_course_msg.dart';
import 'message_view/select_msg.dart';
import 'message_view/system_common_msg.dart';
import 'message_view/text_msg.dart';
import 'message_view/user_msg.dart';
import 'message_view/voice_msg.dart';

// ignore: must_be_immutable
class SendMessageView extends StatefulWidget {
  final ChatDataModel model;
  final VoidMessageClickCallBack voidMessageClickCallBack;
  final VoidItemLongClickCallBack voidItemLongClickCallBack;
  final int position;
  final String chatUserName;
  final String chatId;
  final int conversationDtoType;
  final bool isShowChatUserName;
  final Function(void Function(), String longClickString) setCallRemoveLongPanel;

  SendMessageView(
    this.model,
    this.chatId,
    this.position,
    this.voidMessageClickCallBack,
    this.voidItemLongClickCallBack,
    this.chatUserName,
    this.isShowChatUserName,
    this.conversationDtoType,
    this.setCallRemoveLongPanel,
  );

  @override
  State<StatefulWidget> createState() {
    return SendMessageViewState();
  }
}

///聊天-筛选这个消息的是哪一种消息
// ignore: must_be_immutable
class SendMessageViewState extends State<SendMessageView> {
  bool isMyself;
  String userUrl;
  String name;
  int status;
  int sendTime;
  String sendChatUserId;

  @override
  Widget build(BuildContext context) {
    setSettingData();

    //判断是不是临时的消息
    if (widget.model.isTemporary) {
      return temporaryData();
    } else {
      return notTemporaryData();
    }
  }

  //设置一些基础信息
  void setSettingData() {
    userUrl = getChatUserUrl(sendChatUserId, Application.profile.avatarUri);
    sendChatUserId = Application.profile.uid.toString();
    name = getChatUserName(sendChatUserId, Application.profile.nickName);

    if (widget.model.isTemporary) {
      //print("临时的");
      isMyself = true;
      status = widget.model.status;
      sendTime = new DateTime.now().add(new Duration(days: -1)).millisecondsSinceEpoch;
    } else if (Application.profile.uid.toString() == widget.model.msg.senderUserId) {
      isMyself = true;
      sendTime = widget.model.msg.sentTime;
      status = widget.model.msg.sentStatus;
    } else {
      sendTime = widget.model.msg.sentTime;
      isMyself = false;
      status = widget.model.msg.sentStatus;
      sendChatUserId = widget.model.msg.senderUserId;

      if (widget.conversationDtoType == OFFICIAL_TYPE) {
        userUrl = "http://devpic.aimymusic.com/app/system_message_avatar.png";
        name = "系统通知";
      } else {
        try {
          userUrl = getChatUserUrl(sendChatUserId, widget.model.msg.content.sendUserInfo?.portraitUri);
          name = getChatUserName(sendChatUserId, widget.model.msg.content.sendUserInfo?.name);
        } catch (e) {}
      }

      // if (widget.conversationDtoType == OFFICIAL_TYPE) {
      //   userUrl = "http://devpic.aimymusic.com/app/system_message_avatar.png";
      //   userUrl = AppIcon.avatar_system;
      // } else if (widget.conversationDtoType == LIVE_TYPE) {
      //   userUrl = "http://devpic.aimymusic.com/app/group_notification_avatar.png";
      //   name = "官方直播";
      // } else if (widget.conversationDtoType == TRAINING_TYPE) {
      //   userUrl = "http://devpic.aimymusic.com/app/stranger_message_avatar.png";
      //   name = "运动数据";
      // } else {
      //   try {
      //     userUrl = getChatUserUrl(sendChatUserId, widget.model.msg.content.sendUserInfo?.portraitUri);
      //     name = getChatUserName(sendChatUserId, widget.model.msg.content.sendUserInfo?.name);
      //   } catch (e) {}
      // }
    }

    userUrl = FileUtil.getSmallImage(userUrl);
  }

  //临时消息
  Widget temporaryData() {
    //普通消息
    if (widget.model.type == ChatTypeModel.MESSAGE_TYPE_TEXT) {
      // -----------------------------------------------文字消息-临时----------------------------------------------
      return getTextMsg(text: widget.model.content, mentionedInfo: widget.model.mentionedInfo);
    } else if (widget.model.type == ChatTypeModel.MESSAGE_TYPE_IMAGE) {
      // -----------------------------------------------图片消息-临时----------------------------------------------
      return getImgVideoMsg(
          isTemporary: true, isImg: true, mediaFileModel: widget.model.mediaFileModel, heroId: widget.model.id);
    } else if (widget.model.type == ChatTypeModel.MESSAGE_TYPE_VIDEO) {
      // -----------------------------------------------视频消息-临时----------------------------------------------
      return getImgVideoMsg(
          isTemporary: true, isImg: false, mediaFileModel: widget.model.mediaFileModel, heroId: widget.model.id);
    } else if (widget.model.type == ChatTypeModel.MESSAGE_TYPE_VOICE) {
      // -----------------------------------------------语音消息-临时----------------------------------------------
      String playMd5String = StringUtil.generateMd5(widget.model.chatVoiceModel.filePath);
      return getVoiceMsgData(null, widget.model.chatVoiceModel.toJson(), true, playMd5String);
    } else if (widget.model.type == ChatTypeModel.MESSAGE_TYPE_SELECT) {
      // -----------------------------------------------可选择的列表-临时----------------------------------------------
      return getSelectMsgData(widget.model.content);
    } else {
      // print("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++chatId:${widget.chatId}");
      return getTextMsg(text: "版本过低请升级版本!");
    }
  }

  //显示正式消息
  Widget notTemporaryData() {
    Message msg = widget.model.msg;
    if (msg == null) {
      //print(msg.toString() + "为空");
      return Container();
    }
    String msgType = msg.objectName;

    if (msgType == ChatTypeModel.MESSAGE_TYPE_TEXT) {
      // -----------------------------------------------自定义的-消息类型----------------------------------------------
      return getTextMessage(msg);
    } else if (msgType == VoiceMessage.objectName) {
      // -----------------------------------------------语音-消息----------------------------------------------

      return getVoiceMessage(msg);
    } else if (msgType == RecallNotificationMessage.objectName) {
      // -----------------------------------------------撤回-消息-----------------------------------------------
      return getAlertMsg(recallNotificationMessage: ((msg.content) as RecallNotificationMessage));
    } else if (msgType == ChatTypeModel.MESSAGE_TYPE_GRPNTF) {
      // -----------------------------------------------群通知-群聊-第一种---------------------------------------------
      Map<String, dynamic> map = Map();
      map["subObjectName"] = ChatTypeModel.MESSAGE_TYPE_ALERT_GROUP;
      map["data"] = msg.originContentMap;
      return getAlertMsg(map: map);
    } else if (msgType == ChatTypeModel.MESSAGE_TYPE_CMD) {
      // -----------------------------------------------通知-私聊-----------------------------------------------
      Map<String, dynamic> map = Map();
      map["subObjectName"] = ChatTypeModel.MESSAGE_TYPE_ALERT_GROUP;
      map["data"] = msg.originContentMap;
      return getAlertMsg(map: map);
    }

    //-------------------------------------------------消息类型未知--------------------------------------------
    if (msg.content == null || msg.content.mentionedInfo == null) {
      return getTextMsg(text: "版本过低请升级版本!");
    } else {
      return getTextMsg(text: "版本过低请升级版本!", mentionedInfo: msg.content.mentionedInfo ?? null);
    }
  }

  //自定义的消息类型解析
  Widget getTextMessage(Message msg) {
    TextMessage textMessage = ((msg.content) as TextMessage);
    try {
      Map<String, dynamic> mapModel = json.decode(textMessage.content);
      // print("mapModel：${mapModel.toString()}");
      if (mapModel["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_TEXT) {
        //-------------------------------------------------文字消息--------------------------------------------
        return getTextMsg(text: mapModel["data"], mentionedInfo: msg.content.mentionedInfo);
      } else if (mapModel["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_FEED) {
        //-------------------------------------------------动态消息--------------------------------------------
        return getFeedMsgData(json.decode(mapModel["data"]));
      } else if (mapModel["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_USER) {
        //-------------------------------------------------名片消息--------------------------------------------
        return getUserMsgData(json.decode(mapModel["data"]));
      } else if (mapModel["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_IMAGE) {
        //-------------------------------------------------图片消息--------------------------------------------
        Map<String, dynamic> map = json.decode(mapModel["data"]);
        map["isTemporary"] = mapModel["isTemporary"] ?? false;
        map["messageId"] = msg.messageId;
        return getImgVideoMsg(
            isTemporary: false,
            isImg: true,
            mediaFileModel: widget.model.mediaFileModel,
            sizeInfoMap: map,
            heroId: msg.messageId.toString());
      } else if (mapModel["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_VIDEO) {
        //-------------------------------------------------视频消息--------------------------------------------
        Map<String, dynamic> map = json.decode(mapModel["data"]);
        map["isTemporary"] = mapModel["isTemporary"] ?? false;
        map["messageId"] = msg.messageId;
        return getImgVideoMsg(
            isTemporary: false,
            isImg: false,
            mediaFileModel: widget.model.mediaFileModel,
            sizeInfoMap: map,
            heroId: msg.messageId.toString());
      } else if (mapModel["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_LIVE_COURSE) {
        //-------------------------------------------------直播课程消息--------------------------------------------
        Map<String, dynamic> liveVideoModelMap = json.decode(mapModel["data"]);
        return getLiveVideoCourseMsg(liveVideoModelMap, true, msg.messageUId);
      } else if (mapModel["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_VIDEO_COURSE) {
        //-------------------------------------------------视频课程消息--------------------------------------------
        Map<String, dynamic> liveVideoModelMap = json.decode(mapModel["data"]);
        return getLiveVideoCourseMsg(liveVideoModelMap, false, msg.messageUId);
      } else if (getIsAlertMessage(mapModel["subObjectName"])) {
        //-------------------------------------------------提示消息--------------------------------------------
        return getAlertMsg(map: mapModel);
      } else if (mapModel["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_SELECT) {
        //-------------------------------------------------可选择的列表--------------------------------------------
        return getSelectMsgData(mapModel["data"]);
      } else if (mapModel["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_GRPNTF) {
        //-------------------------------------------------群通知消息-第二种-------------------------------------------
        Map<String, dynamic> map = Map();
        map["subObjectName"] = ChatTypeModel.MESSAGE_TYPE_ALERT_GROUP;
        map["data"] = json.decode(mapModel["data"]);
        return getAlertMsg(map: map);
      } else if (mapModel["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_SYSTEM_COMMON) {
        //-------------------------------------------------系统消息-普通模板-------------------------------------------
        try{
          ChatSystemMessageSubModel subModel = ChatSystemMessageSubModel.fromJson(json.decode(mapModel["data"]));
          return getSystemCommonMsg(subModel,msg.messageUId);
        }catch (e){}
      } else if (mapModel["name"] != null) {
        //-------------------------------------------------未知消息-------------------------------------------
        return getTextMsg(text: mapModel["name"], mentionedInfo: msg.content.mentionedInfo);
      }
    } catch (e) {
      //-------------------------------------------------消息解析失败-------------------------------------------
      return getTextMsg(text: "版本过低请升级版本!", mentionedInfo: msg.content.mentionedInfo);
    }

    //-------------------------------------------------消息类型未知--------------------------------------------
    if (msg.content == null || msg.content.mentionedInfo == null) {
      return getTextMsg(text: "版本过低请升级版本!");
    } else {
      return getTextMsg(text: "版本过低请升级版本!", mentionedInfo: msg.content.mentionedInfo ?? null);
    }
  }

  //判断这个消息是不是提示消息
  bool getIsAlertMessage(String chatTypeModel) {
    if (chatTypeModel == ChatTypeModel.MESSAGE_TYPE_ALERT_TIME) {
      return true;
    } else if (chatTypeModel == ChatTypeModel.MESSAGE_TYPE_ALERT_INVITE) {
      return true;
    } else if (chatTypeModel == ChatTypeModel.MESSAGE_TYPE_ALERT_NEW) {
      return true;
    } else if (chatTypeModel == ChatTypeModel.MESSAGE_TYPE_ALERT) {
      return true;
    } else if (chatTypeModel == ChatTypeModel.MESSAGE_TYPE_ALERT_UPDATE_GROUP_NAME) {
      return true;
    } else if (chatTypeModel == ChatTypeModel.MESSAGE_TYPE_ALERT_REMOVE) {
      return true;
    }
    return false;
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
    //print("mapModel[read]" + mapModel["read"].toString());
    return getVoiceMsgData(msg.messageUId, mapModel, false,
        StringUtil.generateMd5(voiceMessage.remoteUrl != null ? voiceMessage.remoteUrl : mapModel["filePath"]));
  }

  String getChatUserName(String uId, String name) {
    if (widget.isShowChatUserName) {
      String userName = ((Application.chatGroupUserInformationMap["${widget.chatId}_$uId"] ??
          Map())[GROUP_CHAT_USER_INFORMATION_GROUP_USER_NAME]);
      if (userName == null || userName.length < 1) {
        userName = (Application.chatGroupUserInformationMap["${widget.chatId}_$uId"] ??
            Map())[GROUP_CHAT_USER_INFORMATION_USER_NAME];
      }
      if (userName == null || userName.length < 1) {
        return name;
      } else {
        return userName;
      }
    }
    return name;
  }

  String getChatUserUrl(String uId, String url) {
    String userUrl = (Application.chatGroupUserInformationMap["${widget.chatId}_$uId"] ??
        Map())[GROUP_CHAT_USER_INFORMATION_USER_IMAGE];
    if (userUrl == null) {
      return url;
    } else {
      return userUrl;
    }
  }

  bool isCanLongClick() {
    return widget.conversationDtoType != LIVE_TYPE &&
        widget.conversationDtoType != OFFICIAL_TYPE &&
        widget.conversationDtoType != TRAINING_TYPE;
  }

  //************************获取消息模块的方法 ----end

  //***************************************获取每一个消息的模块-----start

  //获取普通文本模块
  Widget getTextMsg({String text, MentionedInfo mentionedInfo}) {
    return TextMsg(
        text: text.toString(),
        isMyself: isMyself,
        userUrl: userUrl,
        name: name,
        sendTime: sendTime,
        sendChatUserId: sendChatUserId,
        isCanLongClick: isCanLongClick(),
        isShowChatUserName: widget.isShowChatUserName,
        mentionedInfo: mentionedInfo,
        voidMessageClickCallBack: widget.voidMessageClickCallBack,
        voidItemLongClickCallBack: widget.voidItemLongClickCallBack,
        position: widget.position,
        setCallRemoveOverlay: widget.setCallRemoveLongPanel,
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
        sendTime: sendTime,
        sendChatUserId: sendChatUserId,
        isCanLongClick: isCanLongClick(),
        isShowChatUserName: widget.isShowChatUserName,
        voidMessageClickCallBack: widget.voidMessageClickCallBack,
        voidItemLongClickCallBack: widget.voidItemLongClickCallBack,
        position: widget.position,
        setCallRemoveOverlay: widget.setCallRemoveLongPanel,
        status: status);
  }

  //获取选项列表
  Widget getSelectMsgData(String selectListString) {
    return SelectMsg(
        selectListString: selectListString,
        isMyself: isMyself,
        userUrl: userUrl,
        name: name,
        sendTime: sendTime,
        sendChatUserId: sendChatUserId,
        isCanLongClick: isCanLongClick(),
        isShowChatUserName: widget.isShowChatUserName,
        voidMessageClickCallBack: widget.voidMessageClickCallBack,
        voidItemLongClickCallBack: widget.voidItemLongClickCallBack,
        position: widget.position,
        setCallRemoveOverlay: widget.setCallRemoveLongPanel,
        status: status);
  }

  //获取语音
  Widget getVoiceMsgData(
      String messageUId, Map<String, dynamic> chatVoiceModelMap, bool isTemporary, String playMd5String) {
    ChatVoiceModel chatVoiceModel = ChatVoiceModel.fromJson(chatVoiceModelMap);
    // chatVoiceModel.read = 1;
    return VoiceMsg(
        messageUId: messageUId,
        chatVoiceModel: chatVoiceModel,
        isMyself: isMyself,
        isTemporary: isTemporary,
        userUrl: userUrl,
        name: name,
        sendTime: sendTime,
        sendChatUserId: sendChatUserId,
        isCanLongClick: isCanLongClick(),
        isShowChatUserName: widget.isShowChatUserName,
        voidMessageClickCallBack: widget.voidMessageClickCallBack,
        voidItemLongClickCallBack: widget.voidItemLongClickCallBack,
        position: widget.position,
        setCallRemoveOverlay: widget.setCallRemoveLongPanel,
        status: status);
  }

  //获取直播和视频的模块
  Widget getLiveVideoCourseMsg(Map<String, dynamic> liveVideoModelMap, bool isLiveOrVideo, String msgId) {
    CourseModel liveVideoModel = CourseModel.fromJson(liveVideoModelMap);
    return LiveVideoCourseMsg(
        liveVideoModel: liveVideoModel,
        isLiveOrVideo: isLiveOrVideo,
        isMyself: isMyself,
        userUrl: userUrl,
        name: name,
        msgId: msgId,
        sendTime: sendTime,
        sendChatUserId: sendChatUserId,
        isCanLongClick: isCanLongClick(),
        isShowChatUserName: widget.isShowChatUserName,
        voidMessageClickCallBack: widget.voidMessageClickCallBack,
        voidItemLongClickCallBack: widget.voidItemLongClickCallBack,
        position: widget.position,
        setCallRemoveOverlay: widget.setCallRemoveLongPanel,
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
        sendTime: sendTime,
        sendChatUserId: sendChatUserId,
        isCanLongClick: isCanLongClick(),
        isShowChatUserName: widget.isShowChatUserName,
        voidMessageClickCallBack: widget.voidMessageClickCallBack,
        voidItemLongClickCallBack: widget.voidItemLongClickCallBack,
        position: widget.position,
        setCallRemoveOverlay: widget.setCallRemoveLongPanel,
        status: status);
  }

  //获取图片和视频的模块
  Widget getImgVideoMsg(
      {bool isTemporary,
      bool isImg,
      MediaFileModel mediaFileModel,
      ImageMessage imageMessage,
      String heroId,
      Map<String, dynamic> sizeInfoMap}) {
    return ImgVideoMsg(
      isMyself: isMyself,
      userUrl: userUrl,
      name: name,
      heroId: heroId,
      status: status,
      sendTime: sendTime,
      sendChatUserId: sendChatUserId,
      isCanLongClick: isCanLongClick(),
      isTemporary: isTemporary,
      isImgOrVideo: isImg,
      mediaFileModel: mediaFileModel,
      imageMessage: imageMessage,
      sizeInfoMap: sizeInfoMap,
      isShowChatUserName: widget.isShowChatUserName,
      voidMessageClickCallBack: widget.voidMessageClickCallBack,
      voidItemLongClickCallBack: widget.voidItemLongClickCallBack,
      position: widget.position,
      setCallRemoveOverlay: widget.setCallRemoveLongPanel,
    );
  }

  //提示消息
  Widget getAlertMsg({Map<String, dynamic> map, RecallNotificationMessage recallNotificationMessage}) {
    return AlertMsg(
      position: widget.position,
      chatUserName: name,
      isShowChatUserName: widget.isShowChatUserName,
      voidMessageClickCallBack: widget.voidMessageClickCallBack,
      voidItemLongClickCallBack: widget.voidItemLongClickCallBack,
      map: map,
      recallNotificationMessage: recallNotificationMessage,
    );
  }

  //系统消息的普通item
  Widget getSystemCommonMsg(ChatSystemMessageSubModel subModel,String heroId) {
    return SystemCommonMsg(
        subModel: subModel,
        isMyself: false,
        userUrl: userUrl,
        name: name,
        sendTime: sendTime,
        heroId: heroId,
        sendChatUserId: sendChatUserId,
        isCanLongClick: true,
        isShowChatUserName: true,
        voidMessageClickCallBack: widget.voidMessageClickCallBack,
        voidItemLongClickCallBack: widget.voidItemLongClickCallBack,
        position: widget.position,
        setCallRemoveOverlay: widget.setCallRemoveLongPanel,
        status: status);
  }

//***************************************获取每一个消息的模块-----end
}
