import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mirror/api/machine_api.dart';
import 'package:mirror/api/message_api.dart';
import 'package:mirror/api/user_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/data/database/conversation_db_helper.dart';
import 'package:mirror/data/database/group_chat_user_information_helper.dart';
import 'package:mirror/data/dto/conversation_dto.dart';
import 'package:mirror/data/model/machine_model.dart';
import 'package:mirror/data/model/message/chat_message_profile_notifier.dart';
import 'package:mirror/data/model/message/chat_type_model.dart';
import 'package:mirror/data/model/message/group_chat_model.dart';
import 'package:mirror/data/model/message/no_prompt_uid_model.dart';
import 'package:mirror/data/model/message/top_chat_model.dart';
import 'package:mirror/data/model/training/training_complete_result_model.dart';
import 'package:mirror/data/notifier/conversation_notifier.dart';
import 'package:mirror/data/notifier/machine_notifier.dart';
import 'package:mirror/util/event_bus.dart';
import 'package:provider/provider.dart';
import 'package:qrcode/qrcode.dart';
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
      await judgeIsGroupUpdateUserInformation(msg);
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

  static updateConversationByMessageContent(BuildContext context, String id, {Message msg}) {
    ConversationDto exist = context.read<ConversationNotifier>().getConversationById(id);
    if (msg == null) {
      exist.content = "";
    } else {
      exist.content = convertMsgContent(msg);
    }
    if (exist.isTop == 0) {
      context.read<ConversationNotifier>().insertCommonList([exist]);
    } else {
      context.read<ConversationNotifier>().insertTopList([exist]);
    }
  }

  static ConversationDto _convertMsgToConversation(Message msg) {
    //只处理以下几个ObjectName的消息
    if (msg.objectName != ChatTypeModel.MESSAGE_TYPE_TEXT &&
        msg.objectName != ChatTypeModel.MESSAGE_TYPE_VOICE &&
        msg.objectName != ChatTypeModel.MESSAGE_TYPE_GRPNTF &&
        msg.objectName != ChatTypeModel.MESSAGE_TYPE_RECALL_MSG1 &&
        msg.objectName != ChatTypeModel.MESSAGE_TYPE_RECALL_MSG2) {
      return null;
    }

    ConversationDto dto = ConversationDto();
    //私聊群聊 收信和发信的情况 targetId是否表示会话id需要测试 测试结果为是
    dto.conversationId = msg.targetId;
    dto.uid = Application.profile.uid;
    //TODO 会话内容需要转化
    dto.content = convertMsgContent(msg);
    dto.avatarUri = "";
    dto.name = "";
    switch (msg.conversationType) {
      case RCConversationType.Private:
        //FIXME 这里需要处理管家消息
        dto.type = PRIVATE_TYPE;
        if (msg.senderUserId == Application.profile.uid.toString()) {
          //如果发信人是自己。。。要从其他途径更新会话名字和头像
          dto.senderUid = Application.profile.uid;
        } else if (msg.content?.sendUserInfo != null) {
          dto.avatarUri = msg.content.sendUserInfo.portraitUri;
          dto.name = msg.content.sendUserInfo.name;
          //不用senderUserId而用sendUserInfo的原因是区分系统通知类消息和用户发的消息
          dto.senderUid = msg.content.sendUserInfo.userId == null ? null : int.parse(msg.content.sendUserInfo.userId);
        } else {}
        break;
      case RCConversationType.Group:
        dto.type = GROUP_TYPE;
        if (msg.content?.sendUserInfo != null) {
          //不用senderUserId而用sendUserInfo的原因是区分系统通知类消息和用户发的消息
          dto.senderUid = msg.content.sendUserInfo.userId == null ? null : int.parse(msg.content.sendUserInfo.userId);
          //TODO 去更新群成员的本地数据库
        }
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
    //暂时将时间写一样
    dto.createTime = msg.sentTime;
    dto.updateTime = new DateTime.now().millisecondsSinceEpoch;


    //需要额外获取的信息
    dto.isTop = 0;
    TopChatModel topChatModel = new TopChatModel(type: dto.type==GROUP_TYPE?1:0, chatId: int.parse(dto.conversationId));
    if(TopChatModel.contains(Application.topChatModelList, topChatModel)){
      dto.isTop=1;
    }

    //撤回消息和已读的其他类型消息不计未读数，其他为未读计未读数1
    if (msg.objectName == ChatTypeModel.MESSAGE_TYPE_RECALL_MSG1 ||
        msg.objectName == ChatTypeModel.MESSAGE_TYPE_RECALL_MSG2 ||
        msg.objectName == ChatTypeModel.MESSAGE_TYPE_GRPNTF ||
        msg.receivedStatus != RCReceivedStatus.Unread) {
      dto.unreadCount = 0;
    } else {
      if(msg.objectName==ChatTypeModel.MESSAGE_TYPE_TEXT){
        Map<String, dynamic> contentMap = json.decode((msg.content as TextMessage).content);
        if(contentMap["subObjectName"]==ChatTypeModel.MESSAGE_TYPE_GRPNTF){
          dto.unreadCount = 0;
          return dto;
        }else if(contentMap["subObjectName"]==ChatTypeModel.MESSAGE_TYPE_CMD){
          dto.unreadCount = 0;
          return dto;
        }
      }
      dto.unreadCount = 1;

      //加上全局未读数
      NoPromptUidModel model=NoPromptUidModel(type: dto.type,targetId: int.parse(dto.conversationId));
      if(!NoPromptUidModel.contains(Application.queryNoPromptUidList,model)){
        Application.unreadMessageNumber+=1;
        EventBus.getDefault().post(registerName: EVENTBUS_IF_TAB_BAR_UNREAD);
      }
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

  //判断是不是群聊的消息-更新群成员的信息
  static Future<void> judgeIsGroupUpdateUserInformation(Message msg) async {
    if (msg != null && msg.conversationType == RCConversationType.Group) {
      await GroupChatUserInformationDBHelper().update(message: msg);
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
          // print("1111退出群聊");
          //判断是不是群通知-移除群成员的消息
          GroupChatUserInformationDBHelper().removeGroupAllInformation(message.targetId);
          break;
        case 2:
          //2-移除群聊
          // print("22222移除群聊");
          Application.appContext.read<ChatMessageProfileNotifier>().removeGroup(message);

          //判断是不是群通知-移除群成员的消息
          GroupChatUserInformationDBHelper().removeMessageGroup(message);
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
        case 10:
          //10-直播禁言
          print("直播禁言");
          break;
        default:
          break;
      }
    } else if (message.objectName == ChatTypeModel.MESSAGE_TYPE_GRPNTF) {
      //群聊通知

      Map<String, dynamic> dataMap = json.decode(message.originContentMap["data"]);
      switch (dataMap["subType"]) {
        case 4:
          //修改群名
          print("修改了群名");
          ConversationDto dto = new ConversationDto();
          dto.uid = Application.profile.uid;
          dto.type = GROUP_TYPE;
          dto.conversationId = message.targetId;
          Application.appContext.read<ConversationNotifier>().updateConversationName(dataMap["groupChatName"], dto);
          break;
        default:
          break;
      }
      Application.appContext.read<ChatMessageProfileNotifier>().judgeConversationMessage(message);
    } else {
      //普通消息
      judgeIsHaveAtUserMes(message);
      Application.appContext.read<ChatMessageProfileNotifier>().judgeConversationMessage(message);
    }
  }

  //直播间的通知消息
  static splitChatRoomMessage(Message message) async {
    if(message.conversationType != RCConversationType.ChatRoom){
      return;
    }
    if (message.objectName == ChatTypeModel.MESSAGE_TYPE_CMD) {
      //私聊通知
      Map<String, dynamic> dataMap = json.decode(message.originContentMap["data"]);
      switch (dataMap["subType"]) {
        case 0:
          //0-直播开始
          print("直播开始");
          List list=[];
          list.add(0);
          list.add(dataMap["courseId"]);
          EventBus.getDefault().post(msg:list,registerName: LIVE_COURSE_LIVE_START_OR_END);
          break;
        case 1:
          //1-心跳
          print("心跳");

          break;
        case 2:
          //2-直播禁言
          List list=[];
          list.add(2);
          list.add(dataMap["liveRoomId"].toString());
          list.add(dataMap["users"]);
          list.add(message);
          EventBus.getDefault().post(registerName: EVENTBUS_ROOM_RECEIVE_NOTICE,msg: list);
          break;
        case 3:
        //3-直播结束
          print("直播结束");
          List list=[];
          list.add(3);
          list.add(dataMap["courseId"]);
          EventBus.getDefault().post(msg:list,registerName: LIVE_COURSE_LIVE_START_OR_END);
          break;
        default:
          break;
      }
    } else if (message.objectName == ChatTypeModel.MESSAGE_TYPE_GRPNTF) {
      //群聊通知
    }
  }

  //根据类型区分转化内容文字
  static String convertMsgContent(Message msg) {
    print("根据类型区分转化内容文字");
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
            case ChatTypeModel.MESSAGE_TYPE_GRPNTF:
              return _parseGrpNtf(contentMap);
            case ChatTypeModel.MESSAGE_TYPE_CMD:
              return _parseCmdNtf(contentMap);
            case ChatTypeModel.MESSAGE_TYPE_ALERT:
              return contentMap["data"];
            default:
              return "[未知类型消息]";
          }
        } else {
          return "[未知类型消息]";
        }
        break;
      case ChatTypeModel.MESSAGE_TYPE_VOICE:
        return "[语音]";
      case ChatTypeModel.MESSAGE_TYPE_RECALL_MSG1:
      case ChatTypeModel.MESSAGE_TYPE_RECALL_MSG2:
        return "撤回了一条消息";
      case ChatTypeModel.MESSAGE_TYPE_GRPNTF:
        return _parseGrpNtf(msg.originContentMap,isTextMessageGrpNtf:false);
      case ChatTypeModel.MESSAGE_TYPE_CMD:
        return "私聊通知";
      default:
        return msg.content.encode();
    }
  }

  static String _parseGrpNtf(Map<String, dynamic> content,{bool isTextMessageGrpNtf=true}) {
    Map<String, dynamic> dataMap;
    if(isTextMessageGrpNtf){
      dataMap = json.decode(json.decode(content["data"])["data"]);
    }else{
      dataMap = json.decode(content["data"]);
    }
    print("dataMap:${dataMap.toString()}");
    switch (dataMap["subType"]) {
      case 0:
        String names = "";
        for (int i = 0; i < dataMap["users"].length; i++) {
          if (dataMap["users"][i]["uid"] == Application.profile.uid) {
            names += "你";
          } else {
            names += dataMap["users"][i]["groupNickName"];
          }
          if (i < dataMap["users"].length - 1) {
            names += "、";
          }
        }
        String operatorName = dataMap["operatorName"];
        if (dataMap["operatorUid"] == Application.profile.uid) {
          operatorName = "你";
        }
        return "$operatorName将$names加入了群聊";
      case 1:
        String names = "";
        for (int i = 0; i < dataMap["users"].length; i++) {
          if (dataMap["users"][i]["uid"] == Application.profile.uid) {
            names += "你";
          } else {
            names += dataMap["users"][i]["groupNickName"];
          }
          if (i < dataMap["users"].length - 1) {
            names += "、";
          }
        }
        return "$names退出了群聊";
      case 2:
        String names = "";
        for (int i = 0; i < dataMap["users"].length; i++) {
          if (dataMap["users"][i]["uid"] == Application.profile.uid) {
            names += "你";
          } else {
            names += dataMap["users"][i]["groupNickName"];
          }
          if (i < dataMap["users"].length - 1) {
            names += "、";
          }
        }
        String operatorName = dataMap["operatorName"];
        if (dataMap["operatorUid"] == Application.profile.uid) {
          operatorName = "你";
        }
        return "$operatorName将$names移出了群聊";
      case 3:
        String operatorName = dataMap["operatorName"];
        if (dataMap["operatorUid"] == Application.profile.uid) {
          operatorName = "你";
        }
        return "$operatorName转移了群主";
      case 4:
        String operatorName = dataMap["operatorName"];
        if (dataMap["operatorUid"] == Application.profile.uid) {
          operatorName = "你";
        }
        return "$operatorName修改了群名";
      case 5:
        String names = "";
        for (int i = 0; i < dataMap["users"].length; i++) {
          if (dataMap["users"][i]["uid"] == Application.profile.uid) {
            names += "你";
          } else {
            names += dataMap["users"][i]["groupNickName"];
          }
          if (i < dataMap["users"].length - 1) {
            names += "、";
          }
        }
        return "$names通过扫码加入了群聊";
      default:
        return "[群聊通知]";
    }
  }

  static String _parseCmdNtf(Map<String, dynamic> content) {
    return "[系统通知]";
  }

  //判断消息是不是聊天室弹幕消息
  static bool judgeBarrageMessage(Message message) {
    print("message.objectName：${message.objectName},${ message.conversationType}");
    if (message == null) {
      return false;
    } else if (message.conversationType != RCConversationType.ChatRoom) {
      return false;
    } else if (message.objectName != ChatTypeModel.MESSAGE_TYPE_TEXT) {
      return false;
    } else {
      Map<String, dynamic> contentMap = json.decode((message.content as TextMessage).content);
      if (null != contentMap) {
        switch (contentMap["subObjectName"]) {
          case ChatTypeModel.MESSAGE_TYPE_SYS_BARRAGE:
          case ChatTypeModel.MESSAGE_TYPE_USER_BARRAGE:
            return true;
          default:
            return false;
        }
      }
    }
    return false;
  }

  //判断是不是聊天室的通知
  static bool judgeChatRoomNotice(Message message) {
    print("message.objectName：${message.objectName},${ message.conversationType}");
    if (message == null) {
      return false;
    } else if (message.conversationType == RCConversationType.ChatRoom) {
      if(message.objectName == ChatTypeModel.MESSAGE_TYPE_CMD){
        print("聊天室：私通知");
        return true;
      }else if(message.objectName == ChatTypeModel.MESSAGE_TYPE_GRPNTF){
        print("聊天室：群通知");
        return true;
      }
    }
    return false;
  }
}
