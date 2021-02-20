import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mirror/api/machine_api.dart';
import 'package:mirror/api/message_api.dart';
import 'package:mirror/api/user_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/data/database/conversation_db_helper.dart';
import 'package:mirror/data/dto/conversation_dto.dart';
import 'package:mirror/data/model/machine_model.dart';
import 'package:mirror/data/model/message/chat_message_profile_notifier.dart';
import 'package:mirror/data/model/message/chat_type_model.dart';
import 'package:mirror/data/model/message/group_chat_model.dart';
import 'package:mirror/data/model/training/training_complete_result_model.dart';
import 'package:mirror/data/notifier/conversation_notifier.dart';
import 'package:mirror/data/notifier/machine_notifier.dart';
import 'package:provider/provider.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:mirror/data/model/message/at_mes_group_model.dart';

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

  static updateConversationByMessageList(BuildContext context, List<Message> msgList) async {
    //TODO 需要对list进行一次处理 各会话只保留最新的一条 但需要计算未读数
    for (Message msg in msgList) {
      await updateConversationByMessage(context, msg);
    }
  }

  //TODO 这里应该解析转一下格式 暂时先用融云原数据 先处理数据库再更新通知器
  static updateConversationByMessage(BuildContext context, Message msg) async {
    ConversationDto dto = _convertMsgToConversation(msg);
    if (dto == null) {
      //没有返回dto 则无需处理
      return;
    }

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
      //处理名字 新的没有值 旧的有值则用旧的
      if (dto.name == "" && exist.name != "") {
        dto.name = exist.name;
      }
      //处理头像 新的没有值 旧的有值则用旧的
      if (dto.avatarUri == "" && exist.avatarUri != "") {
        dto.avatarUri = exist.avatarUri;
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
    //FIXME 如果名字头像等信息缺失 需要去接口获取 最好支持批量 需要解决并发同时请求同一数据的问题
    if (dto.name == "" || dto.avatarUri == "") {
      //根据私聊或者群聊类型取信息 异步
      switch (dto.type) {
        case PRIVATE_TYPE:
          getUserBaseInfo(uid: int.parse(dto.conversationId)).then((user) async {
            if (user != null) {
              dto.name = user.nickName;
              dto.avatarUri = user.avatarUri;
              result = await ConversationDBHelper().updateConversation(dto);
              if (result) {
                if (dto.isTop == 0) {
                  context.read<ConversationNotifier>().insertCommonList([dto]);
                } else {
                  context.read<ConversationNotifier>().insertTopList([dto]);
                }
              }
            }
          });
          break;
        case GROUP_TYPE:
          //暂时只获取一个群
          getGroupChatByIds(id: int.parse(dto.conversationId)).then((list) async {
            if (list != null && list.isNotEmpty) {
              GroupChatModel groupChatModel = list.first;
              dto.name = groupChatModel.modifiedName == null ? groupChatModel.name : groupChatModel.modifiedName;
              dto.avatarUri = groupChatModel.coverUrl;
              result = await ConversationDBHelper().updateConversation(dto);
              if (result) {
                if (dto.isTop == 0) {
                  context.read<ConversationNotifier>().insertCommonList([dto]);
                } else {
                  context.read<ConversationNotifier>().insertTopList([dto]);
                }
              }
            }
          });
          break;
        default:
          break;
      }
    }
  }

  static ConversationDto _convertMsgToConversation(Message msg) {
    //只处理以下几个ObjectName的消息
    if (msg.objectName != ChatTypeModel.MESSAGE_TYPE_TEXT &&
        msg.objectName != ChatTypeModel.MESSAGE_TYPE_VOICE &&
        msg.objectName != ChatTypeModel.MESSAGE_TYPE_RECALL_MSG1 &&
        msg.objectName != ChatTypeModel.MESSAGE_TYPE_RECALL_MSG2) {
      return null;
    }

    ConversationDto dto = ConversationDto();
    //私聊群聊 收信和发信的情况 targetId是否表示会话id需要测试 测试结果为是
    dto.conversationId = msg.targetId;
    dto.uid = Application.profile.uid;
    //TODO 会话内容需要转化
    dto.content = _convertMsgContent(msg);
    dto.avatarUri = "";
    dto.name = "";
    switch (msg.conversationType) {
      case RCConversationType.Private:
        //FIXME 这里需要处理管家消息
        dto.type = PRIVATE_TYPE;
        if (msg.senderUserId == Application.profile.uid.toString()) {
          //如果发信人是自己。。。要从其他途径更新会话名字和头像
        } else if (msg.content?.sendUserInfo != null) {
          dto.avatarUri = msg.content.sendUserInfo.portraitUri;
          dto.name = msg.content.sendUserInfo.name;
        } else {
        }
        break;
      case RCConversationType.Group:
        dto.type = GROUP_TYPE;
        break;
      case RCConversationType.System:
        if (msg.senderUserId == "1") {
          dto.type = OFFICIAL_TYPE;
          dto.avatarUri = "http://devpic.aimymusic.com/app/system_message_avatar.png";
          dto.name = "系统消息";
        } else if (msg.senderUserId == "2") {
          dto.type = LIVE_TYPE;
          dto.avatarUri = "http://devpic.aimymusic.com/app/group_notification_avatar.png";
          dto.name = "官方直播";
        } else if (msg.senderUserId == "3") {
          dto.type = TRAINING_TYPE;
          dto.avatarUri = "http://devpic.aimymusic.com/app/stranger_message_avatar.png";
          dto.name = "运动数据";
        }
        break;
      default:
        //其他情况暂时不处理
        return null;
    }
    //需要额外获取的信息
    dto.isTop = 0;
    //暂时将时间写一样
    dto.createTime = msg.sentTime;
    dto.updateTime = msg.sentTime;

    //撤回消息和已读的其他类型消息不计未读数，其他为未读计未读数1
    if (msg.objectName == ChatTypeModel.MESSAGE_TYPE_RECALL_MSG1 ||
        msg.objectName == ChatTypeModel.MESSAGE_TYPE_RECALL_MSG2 ||
        msg.receivedStatus != RCReceivedStatus.Unread) {
      dto.unreadCount = 0;
    } else {
      dto.unreadCount = 1;
    }

    return dto;
  }

  //判断有没有at我的消息
  static void judgeIsHaveAtUserMes(Message msg) {
    if (msg != null &&
        msg.content != null &&
        msg.content.mentionedInfo != null &&
        msg.content.mentionedInfo.userIdList != null &&
        msg.content.mentionedInfo.userIdList.length > 0) {
      for (int i = 0; i < msg.content.mentionedInfo.userIdList.length; i++) {
        if (msg.content.mentionedInfo.userIdList[i] == Application.profile.uid.toString()) {
          AtMsg atMsg = new AtMsg(groupId: int.parse(msg.targetId), sendTime: msg.sentTime, messageUId: msg.messageUId);
          Application.atMesGroupModel.add(atMsg);
          break;
        }
      }
    }
  }

  //移除指定一条会话信息 type是ConversationDto的type 不是Message的
  static removeConversation(BuildContext context, String conversationId, int uid, int type) async {
    print("44444444444444444444444444444444444444444444444444444");
    ConversationDto dto = ConversationDto();
    dto.conversationId = conversationId;
    dto.uid = uid;
    dto.type = type;
    await ConversationDBHelper().removeConversation(dto.id);
    context.read<ConversationNotifier>().removeConversation([dto]);
  }

  //清零未读数 type是ConversationDto的type 不是Message的
  static clearUnreadCount(BuildContext context, String conversationId, int uid, int type) async {
    ConversationDto dto = ConversationDto();
    dto.conversationId = conversationId;
    dto.uid = uid;
    dto.type = type;
    dto = context.read<ConversationNotifier>().getConversationById(dto.id);
    if (dto != null) {
      dto.unreadCount = 0;
      await ConversationDBHelper().updateConversation(dto);
      context.read<ConversationNotifier>().updateConversation(dto);
    }
  }

  //分为两类 一类通知（私聊通知、群聊通知） 一类消息
  static splitMessage(Message message) async {
    if (message.objectName == ChatTypeModel.MESSAGE_TYPE_CMD) {
      //私聊通知
      Map<String, dynamic> dataMap = json.decode(message.originContentMap["data"]);
      switch (dataMap["subType"]) {
        case 0:
          //0-加入群聊
          Application.appContext.read<ChatMessageProfileNotifier>().entryGroup(message);
          break;
        case 1:
          //1-退出群聊
          break;
        case 2:
          //2-移除群聊
          Application.appContext.read<ChatMessageProfileNotifier>().removeGroup(message);
          break;
        case 3:
          //3-登陆机器
          int machineId = dataMap["machineId"];
          //如果已经关联了该机器，则无需操作；否则需要更新机器信息
          if (Application.machine == null || Application.machine.machineId != machineId) {
            getMachineStatusInfo().then((list) {
              if (list != null && list.isNotEmpty) {
                Application.appContext.read<MachineNotifier>().setMachine(list.first);
              }
            });
          }
          break;
        case 4:
          //4-机器登出
          int machineId = dataMap["machineId"];
          //如果已关联机器与通知中一致则清空，否则无需操作
          if (Application.machine != null && Application.machine.machineId == machineId) {
            Application.appContext.read<MachineNotifier>().setMachine(null);
          }
          break;
        case 5:
          //5-扫码加入群聊
          break;
        case 6:
          //6-机器状态改变
          MachineModel machine = MachineModel.fromJson(dataMap);
          //当关联机器为空或者本地记录的关联机器与通知中的不一致时，重新从接口获取一次机器信息；一致则直接修改状态
          if (Application.machine == null || Application.machine.machineId != machine.machineId) {
            getMachineStatusInfo().then((list) {
              if (list != null && list.isNotEmpty) {
                Application.appContext.read<MachineNotifier>().setMachine(list.first);
              }
            });
          } else {
            //有变化再更新
            if (Application.machine.status != machine.status) {
              Application.appContext.read<MachineNotifier>().setMachine(Application.machine..status = machine.status);
            }
          }
          break;
        case 7:
          //7-预约直播
          Application.appContext.read<ChatMessageProfileNotifier>().bookLive(message);
          break;
        case 8:
          //8-遥控器变化
          MachineModel machine = MachineModel.fromJson(dataMap);
          //当关联机器为空或者本地记录的关联机器与通知中的不一致时，重新从接口获取一次机器信息；一致则直接修改状态
          if (Application.machine == null || Application.machine.machineId != machine.machineId) {
            getMachineStatusInfo().then((list) {
              if (list != null && list.isNotEmpty) {
                Application.appContext.read<MachineNotifier>().setMachine(list.first);
              }
            });
          } else {
            //有变化再更新
            bool hasChanged = false;
            if (machine.volume != null && machine.volume != Application.machine.volume) {
              Application.machine.volume = machine.volume;
              hasChanged = true;
            }
            if (machine.luminance != null && machine.luminance != Application.machine.luminance) {
              Application.machine.luminance = machine.luminance;
              hasChanged = true;
            }
            if (hasChanged) {
              Application.appContext.read<MachineNotifier>().setMachine(Application.machine);
            }
          }
          break;
        case 9:
          //9-训练结束
          TrainingCompleteResultModel trainingResult = TrainingCompleteResultModel.fromJson(dataMap["cmd"]);
          //TODO 处理训练结束事件
          //TODO 如果有结果则打开训练结果页面
          if (trainingResult.hasResult == 1) {}
          break;
        default:
          break;
      }
    } else if (message.objectName == ChatTypeModel.MESSAGE_TYPE_GRPNTF) {
      //群聊通知
      Application.appContext.read<ChatMessageProfileNotifier>().judgeConversationMessage(message);
    } else {
      //普通消息
      judgeIsHaveAtUserMes(message);
      Application.appContext.read<ChatMessageProfileNotifier>().judgeConversationMessage(message);
    }
  }

  //根据类型区分转化内容文字
  static String _convertMsgContent(Message msg) {
    switch (msg.objectName) {
      case ChatTypeModel.MESSAGE_TYPE_TEXT:
        Map<String, dynamic> contentMap = json.decode((msg.content as TextMessage).content);
        if (contentMap != null) {
          switch (contentMap["subObjectName"]) {
            case ChatTypeModel.MESSAGE_TYPE_TEXT:
              return contentMap["data"];
            case ChatTypeModel.MESSAGE_TYPE_IMAGE:
              return "[图片]";
            case ChatTypeModel.MESSAGE_TYPE_VIDEO:
              return "[视频]";
            case ChatTypeModel.MESSAGE_TYPE_FEED:
              return "[动态]";
            case ChatTypeModel.MESSAGE_TYPE_USER:
              return "[用户名片]";
            case ChatTypeModel.MESSAGE_TYPE_LIVE_COURSE:
              return "[直播课程]";
            case ChatTypeModel.MESSAGE_TYPE_VIDEO_COURSE:
              return "[视频课程]";
            default:
              return msg.content.encode();
          }
        } else {
          return msg.content.encode();
        }
        break;
      case ChatTypeModel.MESSAGE_TYPE_VOICE:
        return "[语音]";
      case ChatTypeModel.MESSAGE_TYPE_RECALL_MSG1:
      case ChatTypeModel.MESSAGE_TYPE_RECALL_MSG2:
        return "撤回了一条消息";
      case ChatTypeModel.MESSAGE_TYPE_GRPNTF:
        return "群聊通知";
      case ChatTypeModel.MESSAGE_TYPE_CMD:
        return "私聊通知";
      default:
        return msg.content.encode();
    }
  }
}
