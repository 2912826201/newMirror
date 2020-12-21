import 'package:flutter/material.dart';
import 'package:mirror/data/database/conversation_db_helper.dart';
import 'package:mirror/data/dto/conversation_dto.dart';
import 'package:mirror/data/notifier/conversation_notifier.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:provider/provider.dart';

/// message_manager
/// Created by yangjiayi on 2020/12/21.

//用于提供各种增删改查更新状态的方法

class MessageManager {
  //登出时清掉所有和用户相关的消息数据
  static clearUserMessage(BuildContext context) {
    //会话信息
    context.read<ConversationNotifier>().clearAllData();
    //TODO 应该还会有其他信息需要清
  }

  //从数据库读取已存数据 当启动时已登录 或完成登录时调用
  static loadConversationListFromDatabase(BuildContext context) async {
    int uid = context.read<ProfileNotifier>().profile.uid;
    List<ConversationDto> topConversationList = await ConversationDBHelper().queryConversation(uid, 1);
    List<ConversationDto> commonConversationList = await ConversationDBHelper().queryConversation(uid, 0);

    context.read<ConversationNotifier>().setTopList(topConversationList);
    context.read<ConversationNotifier>().setCommonList(commonConversationList);
  }

}