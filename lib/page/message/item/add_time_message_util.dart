

import 'dart:convert';

import 'package:mirror/config/application.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/data/model/message/chat_data_model.dart';
import 'package:mirror/data/model/message/chat_group_user_model.dart';
import 'package:mirror/data/model/message/chat_type_model.dart';
import 'package:mirror/data/model/message/group_user_model.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:provider/provider.dart';

class AddTimeMessageUtil{

  static AddTimeMessageUtil _util;

  static AddTimeMessageUtil init(){
    if(_util==null){
      _util=AddTimeMessageUtil();
    }
    return _util;
  }


  bool isCanAddTimeMessage(ChatDataModel model){
    //判断是不是临时的消息
    if (model.isTemporary) {
      return true;
    } else {
      return _notTemporaryData(model);
    }
  }


  //显示正式消息
  bool _notTemporaryData(ChatDataModel model) {
    Message msg = model.msg;
    if (msg == null) {
      return false;
    }
    String msgType = msg.objectName;
    if (msgType == ChatTypeModel.MESSAGE_TYPE_TEXT) {
      // -----------------------------------------------自定义的-消息类型----------------------------------------------
      return _getTextMessage(msg);
    } else if (msgType == ChatTypeModel.MESSAGE_TYPE_GRPNTF) {
      // -----------------------------------------------群通知-群聊-第一种---------------------------------------------
      Map<String, dynamic> map = Map();
      map["subObjectName"] = ChatTypeModel.MESSAGE_TYPE_ALERT_GROUP;
      map["data"] = msg.originContentMap;
      return _getAlertIsAddTimeMsg(map);
    } else if (msgType == ChatTypeModel.MESSAGE_TYPE_CMD) {
      // -----------------------------------------------通知-私聊-----------------------------------------------
      Map<String, dynamic> map = Map();
      map["subObjectName"] = ChatTypeModel.MESSAGE_TYPE_ALERT_GROUP;
      map["data"] = msg.originContentMap;
      return _getAlertIsAddTimeMsg(map);
    }
    return true;
  }


  //自定义的消息类型解析
  bool _getTextMessage(Message msg) {
    TextMessage textMessage = ((msg.content) as TextMessage);
    try {
      Map<String, dynamic> mapModel = json.decode(textMessage.content);
      // print("mapModel：${mapModel.toString()}");
      if (_getIsAlertMessage(mapModel["subObjectName"])) {
        //-------------------------------------------------提示消息--------------------------------------------
        return _getAlertIsAddTimeMsg(mapModel);
      } else if (mapModel["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_GRPNTF) {
        //-------------------------------------------------群通知消息-第二种-------------------------------------------
        Map<String, dynamic> map = Map();
        map["subObjectName"] = ChatTypeModel.MESSAGE_TYPE_ALERT_GROUP;
        map["data"] = json.decode(mapModel["data"]);
        return _getAlertIsAddTimeMsg(map);
      }
    } catch (e) {}
    return true;
  }

  //判断这个消息是不是提示消息
  bool _getIsAlertMessage(String chatTypeModel) {
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




//获取提示消息
  bool _getAlertIsAddTimeMsg(Map<String, dynamic> map) {
    if (map["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_ALERT_GROUP) {
      //0--加入群聊
      //1--退出群聊
      //2--移除群聊
      //3--群主转移
      //4--群名改变
      //5--扫码加入群聊
      //群通知
      Map<String, dynamic> mapGroupModel = json.decode(map["data"]["data"]);
      if (mapGroupModel["subType"] == 5) {
        List<dynamic> users = mapGroupModel["users"];
        if (users == null || users.length < 1) {
          return false;
        }
      } else {
        if (Application.appContext.read<GroupUserProfileNotifier>().loadingStatus == LoadingStatus.STATUS_COMPLETED) {
          ChatGroupUserModel chatGroupUserModel = Application.appContext.read<GroupUserProfileNotifier>().chatGroupUserModelList[0];
          if (mapGroupModel["subType"] == 1 && chatGroupUserModel.uid != Application.profile.uid) {
            return false;
          } else {
            if (mapGroupModel["subType"] == 0 && map["data"]["name"] == "Entry") {
              return false;
            } else {
              List<dynamic> users = mapGroupModel["users"];
              if (users == null || users.length < 1) {
                return false;
              }
            }
          }
        } else {
          if (mapGroupModel["subType"] == 1) {
            return false;
          } else {
            if (mapGroupModel["subType"] == 0 && map["data"]["name"] == "Entry") {
              return false;
            } else {
              List<dynamic> users = mapGroupModel["users"];
              if (users == null || users.length < 1) {
                return false;
              }
            }
          }
        }
      }
    }

    return true;
  }


}