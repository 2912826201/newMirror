import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/media_file_model.dart';
import 'package:mirror/data/model/message/chat_data_model.dart';
import 'package:mirror/data/model/message/chat_system_message_model.dart';
import 'package:mirror/data/model/message/chat_type_model.dart';
import 'package:mirror/util/image_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/string_util.dart';
import 'package:mirror/util/text_util.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

class MessageItemHeightUtil {
  static MessageItemHeightUtil _itemHeightUtil;

  static MessageItemHeightUtil init() {
    if (_itemHeightUtil == null) {
      _itemHeightUtil = MessageItemHeightUtil();
    }
    return _itemHeightUtil;
  }

  List<dynamic> getMessageHeightInformation(List<ChatDataModel> chatDataList, bool isShowChatUserName) {
    List<dynamic> informationList = [];
    double chatListPageHeight = ScreenUtil.instance.height - ScreenUtil.instance.statusBarHeight - 44.0 - 50.0;
    double messageHeight = _judgeMessageItemHeight(chatDataList, isShowChatUserName, chatListPageHeight);
    informationList.add(messageHeight >= chatListPageHeight);
    informationList.add(chatListPageHeight - messageHeight);
    return informationList;
  }

  //判断获取消息的高度是否大于等于展示区域的高度
  bool judgeMessageItemHeightIsThenScreenHeight(List<ChatDataModel> chatDataList, bool isShowChatUserName) {
    if (chatDataList.length < 1) {
      return false;
    }
    double chatListPageHeight = ScreenUtil.instance.height - ScreenUtil.instance.statusBarHeight - 44.0;
    return _judgeMessageItemHeight(chatDataList, isShowChatUserName, chatListPageHeight) >= chatListPageHeight;
  }

  //获取消息的高度
  double getMessageHeight(List<ChatDataModel> chatDataList, bool isShowChatUserName) {
    if (chatDataList.length < 1) {
      return 0.0;
    }
    return _getMessageItemHeight(chatDataList, isShowChatUserName);
  }

  //获取消息的高度
  double _judgeMessageItemHeight(List<ChatDataModel> chatDataList, bool isShowChatUserName, double chatListPageHeight) {
    double itemHeight = 0.0;
    if (chatDataList != null && chatDataList.length > 0) {
      chatDataList.forEach((element) {
        itemHeight += _judgeTemporaryData(element, isShowChatUserName);
        if (itemHeight >= chatListPageHeight) {
          return itemHeight;
        }
      });
    }
    return itemHeight;
  }

  //获取消息的高度
  double _getMessageItemHeight(List<ChatDataModel> chatDataList, bool isShowChatUserName) {
    double itemHeight = 0.0;
    if (chatDataList != null && chatDataList.length > 0) {
      chatDataList.forEach((element) {
        itemHeight += _judgeTemporaryData(element, isShowChatUserName);
      });
    }
    return itemHeight;
  }

  double _judgeTemporaryData(ChatDataModel model, bool isShowName) {
    if (model.isTemporary) {
      return _temporaryData(model, isShowName);
    } else {
      return _notTemporaryData(model, isShowName);
    }
  }

  //临时消息
  double _temporaryData(ChatDataModel model, bool isShowName) {
    //普通消息
    if (model.type == ChatTypeModel.MESSAGE_TYPE_TEXT) {
      // -----------------------------------------------文字消息-临时----------------------------------------------
      return getTextMsgHeight(model.content, isShowName);
    } else if (model.type == ChatTypeModel.MESSAGE_TYPE_IMAGE) {
      // -----------------------------------------------图片消息-临时----------------------------------------------
      return getImgVideoMsgHeight(isTemporary: true, isShowName: isShowName, mediaFileModel: model.mediaFileModel);
    } else if (model.type == ChatTypeModel.MESSAGE_TYPE_VIDEO) {
      // -----------------------------------------------视频消息-临时----------------------------------------------
      return getImgVideoMsgHeight(isTemporary: true, isShowName: isShowName, mediaFileModel: model.mediaFileModel);
    } else if (model.type == ChatTypeModel.MESSAGE_TYPE_VOICE) {
      // -----------------------------------------------语音消息-临时----------------------------------------------
      return getVoiceMsgDataHeight(isShowName);
    } else if (model.type == ChatTypeModel.MESSAGE_TYPE_SELECT) {
      // -----------------------------------------------可选择的列表-临时----------------------------------------------
      return getSelectMsgDataHeight(model.content, isShowName);
    } else {
      return getTextMsgHeight("版本过低请升级版本!", isShowName);
    }
  }

  //显示正式消息
  double _notTemporaryData(ChatDataModel model, bool isShowName) {
    Message msg = model.msg;
    if (msg == null) {
      return 0.0;
    }
    String msgType = msg.objectName;

    if (msgType == ChatTypeModel.MESSAGE_TYPE_TEXT) {
      // -----------------------------------------------自定义的-消息类型----------------------------------------------

      return _getTextMessageHeight(msg, isShowName, model);
    } else if (msgType == VoiceMessage.objectName) {
      // -----------------------------------------------语音-消息----------------------------------------------

      return getVoiceMsgDataHeight(isShowName);
    } else if (msgType == RecallNotificationMessage.objectName) {
      // -----------------------------------------------撤回-消息-----------------------------------------------

      return getAlertMsgHeight();
    } else if (msgType == ChatTypeModel.MESSAGE_TYPE_GRPNTF) {
      // -----------------------------------------------群通知-群聊-第一种---------------------------------------------

      return getAlertMsgHeight();
    } else if (msgType == ChatTypeModel.MESSAGE_TYPE_CMD) {
      // -----------------------------------------------通知-私聊-----------------------------------------------

      return getAlertMsgHeight();
    }

    //-------------------------------------------------消息类型未知--------------------------------------------
    return getTextMsgHeight("版本过低请升级版本!", isShowName);
  }

  //自定义的消息类型高度
  double _getTextMessageHeight(Message msg, bool isShowName, ChatDataModel model) {
    TextMessage textMessage = ((msg.content) as TextMessage);
    try {
      Map<String, dynamic> mapModel = json.decode(textMessage.content);
      if (mapModel["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_TEXT) {
        //-------------------------------------------------文字消息--------------------------------------------
        return getTextMsgHeight(mapModel["data"], isShowName);
      } else if (mapModel["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_FEED) {
        //-------------------------------------------------动态消息--------------------------------------------
        return getFeedMsgDataHeight(json.decode(mapModel["data"]), isShowName);
      } else if (mapModel["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_USER) {
        //-------------------------------------------------名片消息--------------------------------------------
        return getUserMsgDataHeight(isShowName);
      } else if (mapModel["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_IMAGE) {
        //-------------------------------------------------图片消息--------------------------------------------
        Map<String, dynamic> map = json.decode(mapModel["data"]);
        return getImgVideoMsgHeight(
            isTemporary: false, isShowName: isShowName, mediaFileModel: model.mediaFileModel, sizeInfoMap: map);
      } else if (mapModel["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_VIDEO) {
        //-------------------------------------------------视频消息--------------------------------------------
        Map<String, dynamic> map = json.decode(mapModel["data"]);
        return getImgVideoMsgHeight(
            isTemporary: false, isShowName: isShowName, mediaFileModel: model.mediaFileModel, sizeInfoMap: map);
      } else if (mapModel["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_LIVE_COURSE) {
        //-------------------------------------------------直播课程消息--------------------------------------------
        return getLiveVideoCourseMsgHeight(isShowName);
      } else if (mapModel["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_VIDEO_COURSE) {
        //-------------------------------------------------视频课程消息--------------------------------------------
        return getLiveVideoCourseMsgHeight(isShowName);
      } else if (getIsAlertMessage(mapModel["subObjectName"])) {
        //-------------------------------------------------提示消息--------------------------------------------
        return getAlertMsgHeight();
      } else if (mapModel["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_SELECT) {
        //-------------------------------------------------可选择的列表--------------------------------------------
        return getSelectMsgDataHeight(mapModel["data"], isShowName);
      } else if (mapModel["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_GRPNTF) {
        //-------------------------------------------------群通知消息-第二种-------------------------------------------
        return getAlertMsgHeight();
      } else if (mapModel["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_SYSTEM_COMMON) {
        //-------------------------------------------------系统通知-------------------------------------------
        return _getSystemCommonMsgHeight(mapModel["data"], isShowName);
      } else if (mapModel["name"] != null) {
        //-------------------------------------------------未知消息-------------------------------------------
        return getTextMsgHeight(mapModel["name"], isShowName);
      }
    } catch (e) {
      //-------------------------------------------------消息解析失败-------------------------------------------
      return getTextMsgHeight("版本过低请升级版本!", isShowName);
    }

    //-------------------------------------------------消息类型未知--------------------------------------------
    return getTextMsgHeight("版本过低请升级版本!", isShowName);
  }

  //获取文字消息的高度
  double getTextMsgHeight(String content, bool isShowChatUserName, {bool isOnlyContentHeight = false}) {
    if (content == null) {
      content = "消息为空";
    }
    double itemHeight = 0.0;

    if (!isOnlyContentHeight) {
      //padding-container-vertical-12.0
      itemHeight += 24.0;
    }

    //判断有没有显示名字
    if (isShowChatUserName && !isOnlyContentHeight) {
      itemHeight += 4.0;
      itemHeight += getTextSize("名字", TextStyle(fontSize: 12), 1).height;
    }

    //消息框的padding
    itemHeight += 8.0;

    double textMaxWidth = ScreenUtil.instance.width - (16 + 7 + 38 + 2) * 2;
    itemHeight += getTextSize(content, TextStyle(fontSize: 14), 100, textMaxWidth).height;

    if (isOnlyContentHeight) {
      return itemHeight;
    } else {
      return math.max(itemHeight, 48.0 + 24.0);
    }
  }

  //获取语音消息的高度
  double getVoiceMsgDataHeight(bool isShowChatUserName, {bool isOnlyContentHeight = false}) {
    double itemHeight = 0.0;

    if (!isOnlyContentHeight) {
      //padding-container-vertical-12.0
      itemHeight += 24.0;
    }

    //判断有没有显示名字
    if (isShowChatUserName && !isOnlyContentHeight) {
      itemHeight += 4.0;
      itemHeight += getTextSize("名字", TextStyle(fontSize: 12), 1).height;
    }

    //消息框的padding
    itemHeight += 8.0;

    //动画条的最高值
    itemHeight += 20.0;

    if (isOnlyContentHeight) {
      return itemHeight;
    } else {
      return math.max(itemHeight, 48.0 + 24.0);
    }
  }

  //获取选择列表消息的高度
  double getSelectMsgDataHeight(String content, bool isShowChatUserName, {bool isOnlyContentHeight = false}) {
    double itemHeight = 0.0;

    itemHeight += getTextMsgHeight("选择适合你的难度", isShowChatUserName);

    //选择列表和上面消息的间隔
    itemHeight += 18.0;

    List<String> selectList = content.split(",");

    for (int i = 0; i < selectList.length; i++) {
      itemHeight += 13.0;
      itemHeight += getTextSize(selectList[i], TextStyle(fontSize: 13), 100, 298.0).height;
    }

    if (isOnlyContentHeight) {
      return itemHeight;
    } else {
      return math.max(itemHeight, 48.0 + 24.0);
    }
  }

  //获取图片消息视频消息的高度
  double getImgVideoMsgHeight(
      {bool isTemporary,
      MediaFileModel mediaFileModel,
      ImageMessage imageMessage,
      bool isShowName,
      bool isOnlyContentHeight = false,
      Map<String, dynamic> sizeInfoMap}) {
    double width = 200.0;
    double height = 200.0;

    if (isTemporary) {
      width = mediaFileModel.sizeInfo.width.toDouble();
      height = mediaFileModel.sizeInfo.height.toDouble();
    } else {
      if (imageMessage != null) {
        Map<String, dynamic> mapModel = json.decode(imageMessage.extra);
        width = int.parse(mapModel["width"].toString()).toDouble();
        height = int.parse(mapModel["height"].toString()).toDouble();
      } else {
        width = int.parse(sizeInfoMap["width"].toString()).toDouble();
        height = int.parse(sizeInfoMap["height"].toString()).toDouble();
      }
    }
    if (width == 0) {
      width = 1024.0;
    }
    if (height == 0) {
      height = 1024.0;
    }
    List<double> widthOrHeight = ImageUtil.getImageWidthAndHeight(width, height);
    width = widthOrHeight[0];
    height = widthOrHeight[1];

    if (!isOnlyContentHeight) {
      //padding-container-vertical-12.0
      height += 24.0;
    }

    //判断有没有显示名字
    if (isShowName && !isOnlyContentHeight) {
      height += 4.0;
      height += getTextSize("名字", TextStyle(fontSize: 12), 1).height;
    }

    return height;
  }

  //提示消息的高度
  double getAlertMsgHeight() {
    double itemHeight = 0.0;

    //padding-container-top-8.0
    itemHeight += 8.0;

    //todo 这里目前暂时定提示消息只有一行
    itemHeight += getTextSize("提示消息", TextStyle(fontSize: 10), 1).height;

    return itemHeight;
  }

  //动态的高度
  double getFeedMsgDataHeight(Map<String, dynamic> homeFeedModeMap, bool isShowName,
      {bool isOnlyContentHeight = false}) {
    HomeFeedModel homeFeedMode = HomeFeedModel.fromJson(homeFeedModeMap);

    int isPicOrVideo;
    if (homeFeedMode.picUrls != null && homeFeedMode.picUrls.length > 0) {
      isPicOrVideo = 0;
    } else if (homeFeedMode.videos != null && homeFeedMode.videos.length > 0) {
      isPicOrVideo = 1;
    } else {
      isPicOrVideo = -1;
    }

    double itemHeight = 0.0;

    if (!isOnlyContentHeight) {
      //padding-container-vertical-12.0
      itemHeight += 24.0;
    }

    //判断有没有显示名字
    if (isShowName && !isOnlyContentHeight) {
      itemHeight += 4.0;
      itemHeight += getTextSize("名字", TextStyle(fontSize: 12), 1).height;
    }

    double feedHeight = 0.0;

    if (isPicOrVideo == 0) {
      double value = homeFeedMode.picUrls[0].width / homeFeedMode.picUrls[0].height;
      if (value == 1) {
        feedHeight = 180.0 + 75.0;
      } else if (value == 0.8) {
        feedHeight = 225.0 + 75.0;
      } else {
        feedHeight = 95.0 + 75.0;
      }
    } else if (isPicOrVideo == 1) {
      double value = homeFeedMode.videos[0].width / homeFeedMode.videos[0].height;
      if (value == 1) {
        feedHeight = 180.0 + 75.0;
      } else if (value == 0.8) {
        feedHeight = 225.0 + 75.0;
      } else {
        feedHeight = 95.0 + 75.0;
      }
    } else {
      feedHeight = 75.0;
    }

    itemHeight += 2.0;

    itemHeight += feedHeight;

    return itemHeight;
  }

  //用户名片的高度
  double getUserMsgDataHeight(bool isShowName, {bool isOnlyContentHeight = false}) {
    double itemHeight = 0.0;

    if (!isOnlyContentHeight) {
      //padding-container-vertical-12.0
      itemHeight += 24.0;
    }

    //判断有没有显示名字
    if (isShowName && !isOnlyContentHeight) {
      itemHeight += 4.0;
      itemHeight += getTextSize("名字", TextStyle(fontSize: 12), 1).height;
    }

    itemHeight += 150.0;

    return itemHeight;
  }

  //直播视频课程item的高度
  double getLiveVideoCourseMsgHeight(bool isShowName, {bool isOnlyContentHeight = false}) {
    double itemHeight = 0.0;

    if (!isOnlyContentHeight) {
      //padding-container-vertical-12.0
      itemHeight += 24.0;
    }

    //判断有没有显示名字
    if (isShowName && !isOnlyContentHeight) {
      itemHeight += 4.0;
      itemHeight += getTextSize("名字", TextStyle(fontSize: 12), 1).height;
    }

    itemHeight += 2.0;
    itemHeight += 180.0;
    itemHeight += 68.5;

    return itemHeight;
  }

  //获取系统普通消息的高度
  double _getSystemCommonMsgHeight(String data, bool isShowName,
      {bool isOnlyContentHeight = false}){
    ChatSystemMessageSubModel subModel=ChatSystemMessageSubModel.fromJson(json.decode(data));
    return getSystemCommonMsgHeight(isShowName,
        isOnlyContentHeight:isOnlyContentHeight,
      content:subModel.text,
      url:subModel.linkUrl,
      imageUrl:subModel.picUrl,
    );
  }

  //获取系统普通消息的高度
  double getSystemCommonMsgHeight(
      bool isShowName,
    {bool isOnlyContentHeight = false,String content="",String url="",String imageUrl=""}) {
    double itemHeight = 0.0;

    if (!isOnlyContentHeight) {
      //padding-container-vertical-12.0
      itemHeight += 24.0;
    }

    //判断有没有显示名字
    if (isShowName && !isOnlyContentHeight) {
      itemHeight += 4.0;
      itemHeight += getTextSize("名字", TextStyle(fontSize: 12), 1).height;
    }

    if(url!=null&&url.length>0) {
      itemHeight += 35.0;
    }

    double textMaxWidth;
    int textMaxLine;
    if(StringUtil.isURL(imageUrl)){
      textMaxWidth=200.0-24.0;
      textMaxLine = 100;
      itemHeight += 100.0;
    }else{
      textMaxWidth = ScreenUtil.instance.width - (16 + 7 + 38 + 2) * 2;
      textMaxLine=2;
    }


    if(content!=null&&content.length>0){
      itemHeight += getTextSize(content, AppStyle.textPrimary2Medium12, textMaxLine, textMaxWidth).height;
      itemHeight += 24.0;
    }


    return itemHeight;
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
}
