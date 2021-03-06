import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/data/dto/conversation_dto.dart';
import 'package:mirror/data/dto/group_chat_user_information_dto.dart';
import 'package:mirror/data/model/activity/activity_model.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/message/chat_system_message_model.dart';
import 'package:mirror/data/model/training/course_model.dart';
import 'package:mirror/data/model/media_file_model.dart';
import 'package:mirror/data/model/message/chat_data_model.dart';
import 'package:mirror/data/model/message/chat_type_model.dart';
import 'package:mirror/data/model/message/chat_voice_model.dart';
import 'package:mirror/data/model/user_model.dart';
import 'package:mirror/im/message_manager.dart';
import 'package:mirror/page/message/message_item_view/alert_msg.dart';
import 'package:mirror/page/message/message_item_view/feed_msg.dart';
import 'package:mirror/page/message/util/chat_page_util.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/util/string_util.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

import 'message_item_view/activity_invite_msg.dart';
import 'message_item_view/new_msg_alert_msg.dart';
import 'widget/currency_msg.dart';
import 'message_item_view/img_video_msg.dart';
import 'message_item_view/live_video_course_msg.dart';
import 'message_item_view/select_msg.dart';
import 'message_item_view/system_common_msg.dart';
import 'message_item_view/text_msg.dart';
import 'message_item_view/user_msg.dart';
import 'message_item_view/voice_msg.dart';

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

///??????-???????????????????????????????????????
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

    //??????????????????????????????
    if (widget.model.isTemporary) {
      return temporaryData();
    } else {
      return notTemporaryData();
    }
  }

  //????????????????????????
  void setSettingData() {
    userUrl = getChatUserUrl(sendChatUserId, Application.profile.avatarUri);
    sendChatUserId = Application.profile.uid.toString();
    name = getChatUserName(sendChatUserId, Application.profile.nickName);

    if (widget.model.isTemporary) {
      //print("?????????");
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
        name = "????????????";
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
      //   name = "????????????";
      // } else if (widget.conversationDtoType == TRAINING_TYPE) {
      //   userUrl = "http://devpic.aimymusic.com/app/stranger_message_avatar.png";
      //   name = "????????????";
      // } else {
      //   try {
      //     userUrl = getChatUserUrl(sendChatUserId, widget.model.msg.content.sendUserInfo?.portraitUri);
      //     name = getChatUserName(sendChatUserId, widget.model.msg.content.sendUserInfo?.name);
      //   } catch (e) {}
      // }
    }

    userUrl = FileUtil.getSmallImage(userUrl);
  }

  //????????????
  Widget temporaryData() {
    //????????????
    if (widget.model.type == ChatTypeModel.MESSAGE_TYPE_TEXT) {
      // -----------------------------------------------????????????-??????----------------------------------------------
      return getTextMsg(text: widget.model.content, mentionedInfo: widget.model.mentionedInfo);
    } else if (widget.model.type == ChatTypeModel.MESSAGE_TYPE_IMAGE) {
      // -----------------------------------------------????????????-??????----------------------------------------------
      return getImgVideoMsg(
          isTemporary: true, isImg: true, mediaFileModel: widget.model.mediaFileModel, heroId: widget.model.id);
    } else if (widget.model.type == ChatTypeModel.MESSAGE_TYPE_VIDEO) {
      // -----------------------------------------------????????????-??????----------------------------------------------
      return getImgVideoMsg(
          isTemporary: true, isImg: false, mediaFileModel: widget.model.mediaFileModel, heroId: widget.model.id);
    } else if (widget.model.type == ChatTypeModel.MESSAGE_TYPE_VOICE) {
      // -----------------------------------------------????????????-??????----------------------------------------------
      String playMd5String = StringUtil.generateMd5(widget.model.chatVoiceModel.filePath);
      return getVoiceMsgData(null, widget.model.chatVoiceModel.toJson(), true, playMd5String);
    } else if (widget.model.type == ChatTypeModel.MESSAGE_TYPE_SELECT) {
      // -----------------------------------------------??????????????????-??????----------------------------------------------
      return getSelectMsgData(widget.model.content);
    } else {
      // print("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++chatId:${widget.chatId}");
      return getTextMsg(text: "???????????????????????????!");
    }
  }

  //??????????????????
  Widget notTemporaryData() {
    Message msg = widget.model.msg;
    if (msg == null) {
      //print(msg.toString() + "??????");
      return Container();
    }
    String msgType = msg.objectName;

    if (msgType == ChatTypeModel.MESSAGE_TYPE_TEXT) {
      // -----------------------------------------------????????????-????????????----------------------------------------------
      return getTextMessage(msg);
    } else if (msgType == VoiceMessage.objectName) {
      // -----------------------------------------------??????-??????----------------------------------------------

      return getVoiceMessage(msg);
    } else if (msgType == RecallNotificationMessage.objectName) {
      // -----------------------------------------------??????-??????-----------------------------------------------
      return getAlertMsg(recallNotificationMessage: ((msg.content) as RecallNotificationMessage));
    } else if (msgType == ChatTypeModel.MESSAGE_TYPE_GRPNTF) {
      // -----------------------------------------------?????????-??????-?????????---------------------------------------------
      Map<String, dynamic> map = Map();
      map["subObjectName"] = ChatTypeModel.MESSAGE_TYPE_ALERT_GROUP;
      if(msg.originContentMap!=null){
        map["data"] = msg.originContentMap;
      }else{
        GroupNotificationMessage groupMessage = ((msg.content) as GroupNotificationMessage);
        Map<String, dynamic> map1 = Map();
        if(groupMessage.data!=null){
          map1["data"]=groupMessage.data;
        }else{
          map1["data"]="";
        }
        map["data"]=map1;
      }
      return getAlertMsg(map: map);
    } else if (msgType == ChatTypeModel.MESSAGE_TYPE_CMD) {
      // -----------------------------------------------??????-??????-----------------------------------------------
      Map<String, dynamic> map = Map();
      map["subObjectName"] = ChatTypeModel.MESSAGE_TYPE_ALERT_GROUP;
      if(msg.originContentMap!=null){
        map["data"] = msg.originContentMap;
      }else{
        map["data"] =Map();
      }
      return getAlertMsg(map: map);
    }

    //-------------------------------------------------??????????????????--------------------------------------------
    if (msg.content == null || msg.content.mentionedInfo == null) {
      return getTextMsg(text: "???????????????????????????!");
    } else {
      return getTextMsg(text: "???????????????????????????!", mentionedInfo: msg.content.mentionedInfo ?? null);
    }
  }

  //??????????????????????????????
  Widget getTextMessage(Message msg) {
    TextMessage textMessage = ((msg.content) as TextMessage);
    try {
      Map<String, dynamic> mapModel = json.decode(textMessage.content);
      // print("mapModel???${mapModel.toString()}");
      if (mapModel["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_TEXT) {
        //-------------------------------------------------????????????--------------------------------------------
        return getTextMsg(text: mapModel["data"], mentionedInfo: msg.content.mentionedInfo);
      } else if (mapModel["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_FEED) {
        //-------------------------------------------------????????????--------------------------------------------
        return getFeedMsgData(json.decode(mapModel["data"]));
      } else if (mapModel["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_USER) {
        //-------------------------------------------------????????????--------------------------------------------
        return getUserMsgData(json.decode(mapModel["data"]));
      } else if (mapModel["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_IMAGE) {
        //-------------------------------------------------????????????--------------------------------------------
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
        //-------------------------------------------------????????????--------------------------------------------
        Map<String, dynamic> map = json.decode(mapModel["data"]);
        map["isTemporary"] = mapModel["isTemporary"] ?? false;
        map["messageId"] = msg.messageId;
        return getImgVideoMsg(
            isTemporary: false,
            isImg: false,
            mediaFileModel: widget.model.mediaFileModel,
            sizeInfoMap: map,
            heroId: msg.messageId.toString());
      } else if (mapModel["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_VOICE) {
        //-------------------------------------------------????????????--------------------------------------------
        Map<String, dynamic> map = json.decode(mapModel["data"]);
        map["isTemporary"] = mapModel["isTemporary"] ?? false;
        map["messageId"] = msg.messageId;
        try {
          if (msg.expansionDic != null && msg.expansionDic["read"] != null) {
            if (msg.expansionDic["read"] == "1") {
              map["read"] = 1;
            }
            if (msg.expansionDic["read"] == "0") {
              map["read"] = 0;
            }
          }
        } catch (e) {}

        return getTextVoiceMessage(map, msg.messageUId);
      } else if (mapModel["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_LIVE_COURSE) {
        //-------------------------------------------------??????????????????--------------------------------------------
        Map<String, dynamic> liveVideoModelMap = json.decode(mapModel["data"]);
        return getLiveVideoCourseMsg(liveVideoModelMap, true, msg.messageUId);
      } else if (mapModel["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_VIDEO_COURSE) {
        //-------------------------------------------------??????????????????--------------------------------------------
        Map<String, dynamic> liveVideoModelMap = json.decode(mapModel["data"]);
        return getLiveVideoCourseMsg(liveVideoModelMap, false, msg.messageUId);
      } else if (mapModel["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_NEW_MSG_ALERT) {
        //-------------------------------------------------?????????-????????????--------------------------------------------
        return getNewMsgAlertMsg();
      } else if (ChatPageUtil.init(context).getIsAlertMessage(mapModel["subObjectName"])) {
        //-------------------------------------------------????????????--------------------------------------------
        return getAlertMsg(map: mapModel);
      } else if (mapModel["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_SELECT) {
        //-------------------------------------------------??????????????????--------------------------------------------
        return getSelectMsgData(mapModel["data"]);
      } else if (mapModel["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_GRPNTF) {
        //-------------------------------------------------???????????????-?????????-------------------------------------------
        Map<String, dynamic> map = Map();
        map["subObjectName"] = ChatTypeModel.MESSAGE_TYPE_ALERT_GROUP;
        map["data"] = json.decode(mapModel["data"]);
        return getAlertMsg(map: map);
      } else if (mapModel["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_SYSTEM_COMMON) {
        //-------------------------------------------------????????????-????????????-------------------------------------------
        try {
          ChatSystemMessageSubModel subModel = ChatSystemMessageSubModel.fromJson(json.decode(mapModel["data"]));
          return getSystemCommonMsg(subModel, msg.messageUId);
        } catch (e) {}
      } else if (mapModel["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_ACTIVITY_INVITE) {
        //-------------------------------------------------????????????????????????-------------------------------------------
        try {
          ActivityModel subModel = ActivityModel.fromJson(json.decode(mapModel["data"]));
          return getActivityInviteMsg(subModel, msg.messageUId);
        } catch (e) {}
      } else if (mapModel["name"] != null) {
        //-------------------------------------------------????????????-------------------------------------------
        return getTextMsg(text: mapModel["name"], mentionedInfo: msg.content.mentionedInfo);
      }
    } catch (e) {
      //-------------------------------------------------??????????????????-------------------------------------------
      return getTextMsg(text: "???????????????????????????!", mentionedInfo: msg.content.mentionedInfo);
    }

    //-------------------------------------------------??????????????????--------------------------------------------
    if (msg.content == null || msg.content.mentionedInfo == null) {
      return getTextMsg(text: "???????????????????????????!");
    } else {
      return getTextMsg(text: "???????????????????????????!", mentionedInfo: msg.content.mentionedInfo ?? null);
    }
  }

  //************************??????????????????????????? ----start

  //????????????
  Widget getVoiceMessage(Message msg) {
    // ????????????
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

  //????????????--????????????
  Widget getTextVoiceMessage(Map<String, dynamic> map, String messageUId) {
    // ????????????
    Map<String, dynamic> mapModel = Map();
    mapModel["filePath"] = map["filePath"];
    mapModel["pathUrl"] = map["url"];
    mapModel["longTime"] = map["duration"];
    mapModel["read"] = map["read"];
    return getVoiceMsgData(messageUId, mapModel, false,
        StringUtil.generateMd5(mapModel["pathUrl"] != null ? mapModel["pathUrl"] : mapModel["filePath"]));
  }

  String getChatUserName(String uId, String name) {
    if (widget.isShowChatUserName) {
      String userName = ((MessageManager.chatGroupUserInformationMap["${widget.chatId}_$uId"] ??
          Map())[GROUP_CHAT_USER_INFORMATION_GROUP_USER_NAME]);
      if (userName == null || userName.length < 1) {
        userName = (MessageManager.chatGroupUserInformationMap["${widget.chatId}_$uId"] ??
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
    String userUrl = (MessageManager.chatGroupUserInformationMap["${widget.chatId}_$uId"] ??
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

  //************************??????????????????????????? ----end

  //***************************************??????????????????????????????-----start

  //????????????????????????
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

  //??????????????????
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

  //??????????????????
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

  //????????????
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

  //??????????????????????????????
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

  //????????????????????????
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

  //??????????????????????????????
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

  //????????????
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

  //???????????????
  Widget getNewMsgAlertMsg() {
    return NewMsgAlertMsg();
  }

  //?????????????????????item
  Widget getSystemCommonMsg(ChatSystemMessageSubModel subModel, String heroId) {
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

  //????????????????????????item
  Widget getActivityInviteMsg(ActivityModel subModel, String heroId) {
    return ActivityInviteMsg(
        activityModel: subModel,
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

//***************************************??????????????????????????????-----end
}
