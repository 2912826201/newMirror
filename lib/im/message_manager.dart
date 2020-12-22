import 'package:flutter/material.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/data/database/conversation_db_helper.dart';
import 'package:mirror/data/dto/conversation_dto.dart';
import 'package:mirror/data/notifier/conversation_notifier.dart';
import 'package:provider/provider.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

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
    List<ConversationDto> topConversationList =
        await ConversationDBHelper().queryConversation(Application.profile.uid, 1);
    List<ConversationDto> commonConversationList =
        await ConversationDBHelper().queryConversation(Application.profile.uid, 0);

    context.read<ConversationNotifier>().insertTopList(topConversationList);
    context.read<ConversationNotifier>().insertCommonList(commonConversationList);
  }

  //TODO 这里应该解析转一下格式 暂时先用融云原数据 先处理数据库再更新通知器
  static updateConversationByMessage(BuildContext context, Message msg) async {
    ConversationDto dto = _convertMsgToConversation(msg);

    ConversationDto exist = context.read<ConversationNotifier>().getConversationById(dto.id);

    bool result = false;
    if (exist != null) {
      //存在已有数据的情况
      if (dto.updateTime <= exist.updateTime) {
        //已有数据比新数据更新 则新数据不更新会话信息
        return;
      } else {
        //将旧数据的创建时间赋值过来
        dto.createTime = exist.createTime;
        //将未读数累加
        dto.unreadCount += exist.unreadCount;
      }
      result = await ConversationDBHelper().updateConversation(dto);
    } else {
      result = await ConversationDBHelper().insertConversation(dto);
    }
    // 写数据库成功后 更新状态
    if (result) {
      if (dto.isTop == 0) {
        context.read<ConversationNotifier>().insertCommonList([dto]);
      } else {
        context.read<ConversationNotifier>().insertTopList([dto]);
      }
    }
  }

  static ConversationDto _convertMsgToConversation(Message msg) {
    ConversationDto dto = ConversationDto();
    //FIXME 这是收信的情况 发信的情况待测试
    dto.conversationId = msg.senderUserId;
    dto.uid = Application.profile.uid;
    dto.content = msg.content.encode();
    switch (msg.conversationType) {
      case RCConversationType.Private:
        //FIXME 这里需要处理管家消息
        dto.type = PRIVATE_TYPE;
        break;
      case RCConversationType.Group:
        dto.type = GROUP_TYPE;
        break;
      case RCConversationType.System:
        if (msg.senderUserId == "1") {
          dto.type = OFFICIAL_TYPE;
        } else if (msg.senderUserId == "2") {
          dto.type = LIVE_TYPE;
        } else if (msg.senderUserId == "3") {
          dto.type = TRAINING_TYPE;
        }
        break;
    }
    //需要额外获取的信息
    dto.isTop = 0;
    dto.avatarUri = "";
    dto.name = "";
    //暂时将时间写一样
    dto.createTime = msg.sentTime;
    dto.updateTime = msg.sentTime;
    //本条未读则未读数为1
    dto.unreadCount = msg.receivedStatus == RCReceivedStatus.Unread ? 1 : 0;

    return dto;
  }
}
