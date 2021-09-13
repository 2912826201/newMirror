import 'dart:convert';

import 'package:mirror/config/application.dart';
import 'package:mirror/data/dto/conversation_dto.dart';
import 'package:mirror/data/model/message/at_mes_group_model.dart';
import 'package:mirror/data/model/message/chat_type_model.dart';
import 'package:mirror/data/notifier/conversation_notifier.dart';
import 'package:mirror/im/message_manager.dart';
import 'package:mirror/util/event_bus.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:provider/provider.dart';

class ChatMessageProfileUtil {
  static ChatMessageProfileUtil _util;

  static ChatMessageProfileUtil init() {
    if (_util == null) {
      _util = ChatMessageProfileUtil();
    }
    return _util;
  }

  ///这是什么类型的对话--融云的分类-数字
  ///[chatTypeId] 会话类型，参见枚举 [RCConversationType]
  int chatTypeId;

  String id;

  ///对话用户id
  String chatUserId;

  ConversationDto conversation;

  //这个对话的未读数
  static int unreadCount = 0;

  //当未读数之后接受的消息的数量+未读数
  static int unreadCountNew = 0;

  getConversation(String chatId) {
    if (chatUserId != null && chatId == this.chatUserId) {
      return conversation;
    } else {
      return null;
    }
  }

  //设置数据
  setData(ConversationDto conversation, {bool isSetUnreadCount = false}) {
    if (conversation != null) {
      this.chatTypeId = conversation.getType();
      this.chatUserId = conversation.conversationId;
      this.id = conversation.id;
      this.conversation = conversation;
      if (isSetUnreadCount) {
        unreadCount = unreadCount;
        unreadCount = 0;
        unreadCountNew = 0;
        setUnreadCount();
      }
    } else {
      clear();
    }
  }

  clear() {
    chatTypeId = -1;
    chatUserId = "";
    unreadCount = 0;
    unreadCountNew = 0;
    conversation = null;
  }

  setUnreadCount() {
    ConversationDto dto = Application.appContext.read<ConversationNotifier>().getConversationById(id);
    if (dto != null && dto.unreadCount != null && dto.unreadCount is int) {
      unreadCount = dto.unreadCount;
      unreadCountNew = unreadCount;
    }
  }

  //判断这个消息是不是at的消息
  //并且判断加不加在数据库中
  judgeIsHaveAtUserMsg(Message msg) {
    if (msg != null &&
        msg.content != null &&
        msg.content.mentionedInfo != null &&
        msg.content.mentionedInfo.userIdList != null &&
        msg.content.mentionedInfo.userIdList.length > 0) {
      bool isNowMsg = msg.targetId == this.chatUserId && msg.conversationType == chatTypeId;
      if (!isNowMsg) {
        for (int i = 0; i < msg.content.mentionedInfo.userIdList.length; i++) {
          if (msg.content.mentionedInfo.userIdList[i] == Application.profile.uid.toString()) {
            AtMsg atMsg =
                new AtMsg(groupId: int.parse(msg.targetId), sendTime: msg.sentTime, messageUId: msg.messageUId);
            MessageManager.atMesGroupModel.add(atMsg);
            break;
          }
        }
      }
    }
  }

  //撤回
  judgeWithdrawIsAtMsg(Message msg) {
    // print("MessageManager.atMesGroupModel:${MessageManager.atMesGroupModel.atMsgMap.length}");
    // print("111111111111111111111111111");
    AtMsg atMsg = MessageManager.atMesGroupModel.getAtMsg(msg.targetId);
    if (atMsg != null && atMsg.messageUId == msg.messageUId) {
      MessageManager.atMesGroupModel.remove(atMsg);
    }
  }

  //移除群聊
  removeGroup(Message message) {
    Map<String, dynamic> mapGroupModel = json.decode(message.originContentMap["data"]);
    print(
        "value:${mapGroupModel["groupChatId"].toString() == this.chatUserId && RCConversationType.Group == chatTypeId}");
    if (mapGroupModel["groupChatId"].toString() == this.chatUserId && RCConversationType.Group == chatTypeId) {
      print("111111移除群聊");
      EventBus.init().post(msg: message, registerName: CHAT_JOIN_EXIT);
    }else{
      insertExitGroupMsg(message, mapGroupModel["groupChatId"].toString());
    }
  }

  //是否是当前聊天界面
  bool isCurrentChatGroupId(Message message){
    bool a=message.targetId == this.chatUserId && message.conversationType == chatTypeId;
    print("value:${message.targetId},${this.chatUserId},${message.conversationType},$chatTypeId,$a");
    return message.targetId == this.chatUserId && message.conversationType == chatTypeId;
  }


  //加入群聊
  entryGroup(Message message){
    Map<String, dynamic> mapGroupModel = json.decode(message.originContentMap["data"]);
    print("value:${mapGroupModel["groupChatId"].toString() == this.chatUserId
        && RCConversationType.Group == chatTypeId}");
    print("value:${message.originContentMap.toString()}");
    if (mapGroupModel["groupChatId"].toString() == this.chatUserId && RCConversationType.Group == chatTypeId) {
      print("1111111111111加入群聊");
      EventBus.init().post(msg: message, registerName: CHAT_JOIN_EXIT);
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
