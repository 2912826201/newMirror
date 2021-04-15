import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/data/database/group_chat_user_information_helper.dart';
import 'package:mirror/util/event_bus.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

import 'chat_type_model.dart';

class ChatMessageProfileNotifier extends ChangeNotifier {
  ChatMessageProfileNotifier() {
    clear();
  }

  ///这是什么类型的对话--融云的分类-数字
  ///[chatTypeId] 会话类型，参见枚举 [RCConversationType]
  int chatTypeId;

  ///对话用户id
  String chatUserId;

  //设置数据
  setData(int chatTypeId, String chatUserId) {
    this.chatTypeId = chatTypeId;
    this.chatUserId = chatUserId;
  }

  clear() {
    chatTypeId = -1;
    chatUserId = "";
  }

  //移除群聊
  removeGroup(Message message){
    Map<String, dynamic> mapGroupModel = json.decode(message.originContentMap["data"]);
    print("value:${mapGroupModel["groupChatId"].toString() == this.chatUserId
        && RCConversationType.Group == chatTypeId}");
    if (mapGroupModel["groupChatId"].toString() == this.chatUserId && RCConversationType.Group == chatTypeId) {
      List<dynamic> users = mapGroupModel["users"];
      for (dynamic d in users) {
        if (d["uid"] == Application.profile.uid) {
          EventBus.getDefault().post(msg: message,registerName: CHAT_JOIN_EXIT);
          break;
        }
      }
    }else{
      insertExitGroupMsg(message, mapGroupModel["groupChatId"].toString());
    }
  }

  //加入群聊
  entryGroup(Message message){
    Map<String, dynamic> mapGroupModel = json.decode(message.originContentMap["data"]);
    print("value:${mapGroupModel["groupChatId"].toString() == this.chatUserId
        && RCConversationType.Group == chatTypeId}");
    print("value:${message.originContentMap.toString()}");
    if (mapGroupModel["groupChatId"].toString() == this.chatUserId && RCConversationType.Group == chatTypeId) {
      List<dynamic> users = mapGroupModel["users"];
      for (dynamic d in users) {
        if (d["uid"] == Application.profile.uid) {
          EventBus.getDefault().post(msg: message,registerName: CHAT_JOIN_EXIT);
          break;
        }
      }
    }else{
      insertExitGroupMsg(message, mapGroupModel["groupChatId"].toString());
    }
  }


  //插入被移除群聊或者加入群聊的消息
  void insertExitGroupMsg(Message message, String targetId) {
    TextMessage msg = TextMessage();
    msg.sendUserInfo = getChatUserInfo();
    Map<String, dynamic> alertMap = Map();
    alertMap["subObjectName"] = ChatTypeModel.MESSAGE_TYPE_GRPNTF;
    alertMap["name"] = ChatTypeModel.MESSAGE_TYPE_GRPNTF_NAME;
    alertMap["data"] = jsonEncode(message.originContentMap);
    msg.content = jsonEncode(alertMap);
    Application.rongCloud.insertOutgoingMessage(RCConversationType.Group, targetId, msg, (msg, code){},
        sendTime: new DateTime.now().millisecondsSinceEpoch);
  }

  //获取用户数据
  UserInfo getChatUserInfo() {
    UserInfo userInfo = UserInfo();
    userInfo.userId = Application.profile.uid.toString();
    userInfo.name = Application.profile.nickName;
    userInfo.portraitUri = Application.profile.avatarUri;
    return userInfo;
  }
}
