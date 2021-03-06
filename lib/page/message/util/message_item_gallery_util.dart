import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:mirror/config/application.dart';
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
import 'package:mirror/widget/interactiveviewer/interactiveview_video_or_image_demo.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

import 'chat_page_util.dart';

class MessageItemGalleryUtil {
  static MessageItemGalleryUtil _itemHeightUtil;

  static MessageItemGalleryUtil init() {
    if (_itemHeightUtil == null) {
      _itemHeightUtil = MessageItemGalleryUtil();
    }
    return _itemHeightUtil;
  }

  List<DemoSourceEntity> getMessageGalleryList(List<ChatDataModel> chatDataList) {
    List<DemoSourceEntity> entityList=[];
    if(chatDataList==null||chatDataList.length<1){
      return entityList;
    }

    if (chatDataList != null && chatDataList.length > 0) {
      chatDataList.forEach((element) {
        dynamic data=_judgeTemporaryData(element);
        if(data is DemoSourceEntity){
          entityList.insert(0,data);
        }
      });
    }
    return entityList;
  }

  DemoSourceEntity getMessageGallery(ChatDataModel model) {
    if(model==null){
      return null;
    }

    dynamic data=_judgeTemporaryData(model);

    if(data.runtimeType is DemoSourceEntity){
      return data as DemoSourceEntity;
    }

    return null;
  }

  int getPositionMessageGalleryList(List<DemoSourceEntity> sourceList,ChatDataModel chatDataModel) {
    if(sourceList==null||sourceList.length<1){
      return -1;
    }
    if(chatDataModel==null){
      return -1;
    }

    dynamic data=_judgeTemporaryData(chatDataModel,isGetHeroId:true);

    if(data is String){
      for (int i = sourceList.length - 1; i >= 0; i--) {
        DemoSourceEntity source = sourceList[i];
        if (source.heroId == data) {
          return i;
        }
      }
    }

    return -1;

  }


  dynamic _judgeTemporaryData(ChatDataModel model,{bool isGetHeroId=false}) {
    if (model.isTemporary) {
      // return _temporaryData(model,isGetHeroId);
      return false;
    } else {
      return _notTemporaryData(model,isGetHeroId);
    }
  }

  //????????????
  dynamic _temporaryData(ChatDataModel model,[bool isGetHeroId=false]) {
    //????????????
    if (model.type == ChatTypeModel.MESSAGE_TYPE_TEXT) {
      // -----------------------------------------------????????????-??????----------------------------------------------
      return false;
    } else if (model.type == ChatTypeModel.MESSAGE_TYPE_IMAGE) {
      // -----------------------------------------------????????????-??????----------------------------------------------
      if(isGetHeroId){
        return model.id;
      }else {
        return _getImgVideoMsg(
            isTemporary: true,
            mediaFileModel: model.mediaFileModel,
            heroId: model.id,
            isImageOrVideo: true
        );
      }
    } else if (model.type == ChatTypeModel.MESSAGE_TYPE_VIDEO) {
      // -----------------------------------------------????????????-??????----------------------------------------------

      if(isGetHeroId){
        return model.id;
      }else {
        return _getImgVideoMsg(
            isTemporary: true,
            mediaFileModel: model.mediaFileModel,
            heroId: model.id,
            isImageOrVideo: false);
      }

    } else if (model.type == ChatTypeModel.MESSAGE_TYPE_VOICE) {
      // -----------------------------------------------????????????-??????----------------------------------------------
      return false;
    } else if (model.type == ChatTypeModel.MESSAGE_TYPE_SELECT) {
      // -----------------------------------------------??????????????????-??????----------------------------------------------
      return false;
    } else {
      return false;
    }
  }

  //??????????????????
  dynamic _notTemporaryData(ChatDataModel model,[bool isGetHeroId=false]) {
    Message msg = model.msg;
    if (msg == null) {
      return false;
    }
    String msgType = msg.objectName;

    if (msgType == ChatTypeModel.MESSAGE_TYPE_TEXT) {
      // -----------------------------------------------????????????-????????????----------------------------------------------

      return _getTextMessageHeight(msg,  model,isGetHeroId);
    } else if (msgType == VoiceMessage.objectName) {
      // -----------------------------------------------??????-??????----------------------------------------------

      return false;
    } else if (msgType == RecallNotificationMessage.objectName) {
      // -----------------------------------------------??????-??????-----------------------------------------------

      return false;
    } else if (msgType == ChatTypeModel.MESSAGE_TYPE_GRPNTF) {
      // -----------------------------------------------?????????-??????-?????????---------------------------------------------

      return false;
    } else if (msgType == ChatTypeModel.MESSAGE_TYPE_CMD) {
      // -----------------------------------------------??????-??????-----------------------------------------------

      return false;
    }

    //-------------------------------------------------??????????????????--------------------------------------------
    return false;
  }

  //??????????????????????????????
  dynamic _getTextMessageHeight(Message msg,  ChatDataModel model,[bool isGetHeroId=false]) {
    TextMessage textMessage = ((msg.content) as TextMessage);
    try {
      Map<String, dynamic> mapModel = json.decode(textMessage.content);
      if (mapModel["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_TEXT) {
        //-------------------------------------------------????????????--------------------------------------------
        return false;
      } else if (mapModel["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_FEED) {
        //-------------------------------------------------????????????--------------------------------------------
        return false;
      } else if (mapModel["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_USER) {
        //-------------------------------------------------????????????--------------------------------------------
        return false;
      } else if (mapModel["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_IMAGE) {
        //-------------------------------------------------????????????--------------------------------------------
        if(isGetHeroId){
          return msg.messageId.toString();
        }else {
          Map<String, dynamic> map = json.decode(mapModel["data"]);
          map["isTemporary"]=mapModel["isTemporary"];
          return _getImgVideoMsg(isTemporary: false,
            mediaFileModel: model.mediaFileModel,
            sizeInfoMap: map,
            isImageOrVideo: true,
            heroId: msg.messageId.toString(),
          );
        }
      } else if (mapModel["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_VIDEO) {
        //-------------------------------------------------????????????--------------------------------------------
        if(isGetHeroId){
          return msg.messageId.toString();
        }else {
          Map<String, dynamic> map = json.decode(mapModel["data"]);
          map["isTemporary"]=mapModel["isTemporary"];
          return _getImgVideoMsg(isTemporary: false,
            mediaFileModel: model.mediaFileModel,
            sizeInfoMap: map,
            isImageOrVideo: false,
            heroId: msg.messageId.toString(),
          );
        }
      } else if (mapModel["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_LIVE_COURSE) {
        //-------------------------------------------------??????????????????--------------------------------------------
        return false;
      } else if (mapModel["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_VIDEO_COURSE) {
        //-------------------------------------------------??????????????????--------------------------------------------
        return false;
      } else if (ChatPageUtil.init(Application.appContext).getIsAlertMessage(mapModel["subObjectName"])) {
        //-------------------------------------------------????????????--------------------------------------------
        return false;
      } else if (mapModel["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_SELECT) {
        //-------------------------------------------------??????????????????--------------------------------------------
        return false;
      } else if (mapModel["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_GRPNTF) {
        //-------------------------------------------------???????????????-?????????-------------------------------------------
        return false;
      } else if (mapModel["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_SYSTEM_COMMON) {
        //-------------------------------------------------????????????-------------------------------------------
        if(isGetHeroId){
          return msg.messageUId;
        }else {
          try{
            ChatSystemMessageSubModel subModel=ChatSystemMessageSubModel.fromJson(json.decode(mapModel["data"]));
            if(subModel!=null) {
              return _getSystemCommonMsg(content: subModel.text,
                url: subModel.linkUrl,
                imageUrl: subModel.picUrl,
                heroId: msg.messageUId,
              );
            } else {
              return false;
            }
          } catch (e) {
            return false;
          }
        }
      } else if (mapModel["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_ACTIVITY_INVITE) {
        //-------------------------------------------------????????????????????????-------------------------------------------
        return false;
      } else if (mapModel["name"] != null) {
        //-------------------------------------------------????????????-------------------------------------------
        return false;
      }
    } catch (e) {
      //-------------------------------------------------??????????????????-------------------------------------------
      return false;
    }

    //-------------------------------------------------??????????????????--------------------------------------------
    return false;
  }

  //???????????????????????????????????????????????????
  dynamic _getImgVideoMsg(
      {bool isTemporary,
      MediaFileModel mediaFileModel,
      bool isImageOrVideo = false,
      String heroId,
      Map<String, dynamic> sizeInfoMap}) {
    DemoSourceEntity demoSourceEntity=DemoSourceEntity(heroId,isImageOrVideo?"image":"video","");
    demoSourceEntity.isTemporary=isTemporary;
    if(isTemporary){
      return false;
    }else{
      if (isImageOrVideo) {
        if (sizeInfoMap["isTemporary"] != null && sizeInfoMap["isTemporary"]) {
          File imageFile = File(sizeInfoMap["showImageUrl"]);
          if (imageFile.existsSync()) {
            demoSourceEntity.imageFilePath=sizeInfoMap["showImageUrl"];
          }else{
            return false;
          }
        }else{
          demoSourceEntity.url=sizeInfoMap["showImageUrl"];
        }
      } else {
        if (sizeInfoMap["isTemporary"] != null && sizeInfoMap["isTemporary"]) {
          File videoImageFile = File(sizeInfoMap["videoFilePath"]);
          File videoFile = File(sizeInfoMap["showImageUrl"]);
          if (videoFile.existsSync()) {
            if (videoImageFile.existsSync()) {
              demoSourceEntity.videoImageFilePath=sizeInfoMap["videoFilePath"];
              demoSourceEntity.videoFilePath=sizeInfoMap["showImageUrl"];
            } else {
              return false;
            }
          } else {
            return false;
          }
        } else {
          demoSourceEntity.url = sizeInfoMap["showImageUrl"];
          demoSourceEntity.videoFilePath = sizeInfoMap["filePath"];
        }
      }
    }
    double width=0.0;
    double height=0.0;
    if (isTemporary) {
      width = mediaFileModel.sizeInfo.width.toDouble();
      height = mediaFileModel.sizeInfo.height.toDouble();
    } else {
      width = int.parse(sizeInfoMap["width"].toString()).toDouble();
      height = int.parse(sizeInfoMap["height"].toString()).toDouble();
    }
    if (width == 0.0) {
      width = 1024.0;
    }
    if (height == 0.0) {
      height = 1024.0;
    }
    demoSourceEntity.width=width;
    demoSourceEntity.height=height;
    return demoSourceEntity;
  }


  //???????????????????????????????????????
  dynamic _getSystemCommonMsg({String content="",String url="",String imageUrl="",String heroId=""}) {

    if(!StringUtil.isURL(imageUrl)){
      return false;
    }
    if(url!=null&&url.length>0){
      return false;
    }
    if(heroId==null||heroId.length<1){
      return false;
    }

    DemoSourceEntity demoSourceEntity=DemoSourceEntity(heroId,"image",imageUrl);

    demoSourceEntity.width=ScreenUtil.instance.width;
    demoSourceEntity.height=ScreenUtil.instance.width/2;

    return demoSourceEntity;
  }
}
