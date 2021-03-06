import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mirror/api/machine_api.dart';
import 'package:mirror/api/message_api.dart';
import 'package:mirror/api/training/course_api.dart';
import 'package:mirror/api/user_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/data/database/conversation_db_helper.dart';
import 'package:mirror/data/database/group_chat_user_information_helper.dart';
import 'package:mirror/data/dto/conversation_dto.dart';
import 'package:mirror/data/model/activity/activity_model.dart';
import 'package:mirror/data/model/machine_model.dart';
import 'package:mirror/data/model/message/chat_data_model.dart';
import 'package:mirror/page/message/util/chat_message_profile_util.dart';
import 'package:mirror/data/model/message/chat_system_message_model.dart';
import 'package:mirror/data/model/message/chat_type_model.dart';
import 'package:mirror/data/model/message/group_chat_model.dart';
import 'package:mirror/data/model/message/no_prompt_uid_model.dart';
import 'package:mirror/data/model/message/top_chat_model.dart';
import 'package:mirror/data/model/training/course_mode.dart';
import 'package:mirror/data/model/training/training_complete_result_model.dart';
import 'package:mirror/data/model/training/training_schedule_model.dart';
import 'package:mirror/data/model/user_model.dart';
import 'package:mirror/data/notifier/conversation_notifier.dart';
import 'package:mirror/data/notifier/machine_notifier.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/event_bus.dart';
import 'package:provider/provider.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:mirror/data/model/message/at_mes_group_model.dart';

/// message_manager
/// Created by yangjiayi on 2020/12/21.

//用于提供各种增删改查更新状态的方法

class MessageManager {
  //群组at的列表
  static AtMesGroupModel atMesGroupModel = AtMesGroupModel();

  //发送消息的临时列表
  //key是:用户id_会话id_会话类型
  static Map<String, List<ChatDataModel>> postChatDataModelList = Map();

  //未读数-消息
  static int unreadMessageNumber = 0;

  //未读数-通知
  static int unreadNoticeNumber = 0;

  //互动通知未读数时间戳
  static int unreadNoticeTimeStamp = 0;

  //聊天群的群成员信息
  static Map<String, Map<String, dynamic>> chatGroupUserInformationMap = Map();

  //进入聊天界面前先获取的消息列表
  static List<ChatDataModel> chatDataList = <ChatDataModel>[];

  //那些消息是置顶的
  static List<TopChatModel> topChatModelList = [];

  //那些消息是免打扰的
  static List<NoPromptUidModel> queryNoPromptUidList = [];

  //登出时清掉所有和用户相关的消息数据
  static clearUserMessage(BuildContext context) {
    //会话信息
    context.read<ConversationNotifier>().clearAllData();
    atMesGroupModel?.atMsgMap?.clear();
    topChatModelList.clear();
    chatDataList.clear();
    postChatDataModelList.clear();
    queryNoPromptUidList.clear();
    chatGroupUserInformationMap.clear();
    postChatDataModelList.clear();
    unreadMessageNumber = 0;
    unreadNoticeNumber = 0;
    unreadNoticeTimeStamp = 0;
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
      if (dto.updateTime < exist.updateTime) {
        //已有数据比新数据更新 则新数据不更新会话信息
        return;
      } else {
        //将旧数据的创建时间赋值过来
        dto.createTime = exist.createTime;

        //将未读数累加
        if (ChatMessageProfileUtil.init().isCurrentChatGroupId(msg)) {
          dto.unreadCount = 0;
        } else {
          dto.unreadCount += exist.unreadCount;
        }
      }
      //处理名字 新的没有值 旧的有值则用旧的
      if (dto.name == "" && exist.name != "") {
        dto.name = exist.name;
      }
      //处理头像 新的没有值 旧的有值则用旧的
      if (dto.avatarUri == "" && exist.avatarUri != "") {
        dto.avatarUri = exist.avatarUri;
      }
      //处理头像 新的没有值 旧的有值则用旧的
      if (exist.groupType != null && exist.activityId != null) {
        dto.groupType = exist.groupType;
        dto.activityId = exist.activityId;
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
    if (dto.name == "" ||
        dto.avatarUri == "" ||
        (dto.type == GROUP_TYPE && (dto.activityId == null || dto.activityId == null))) {
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
              dto.groupType = groupChatModel.type;
              dto.activityId = groupChatModel.targetId;
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
        msg.objectName != ChatTypeModel.MESSAGE_TYPE_SYSTEM_COMMON &&
        msg.objectName != ChatTypeModel.MESSAGE_TYPE_GRPNTF &&
        msg.objectName != ChatTypeModel.MESSAGE_TYPE_RECALL_MSG1 &&
        msg.objectName != ChatTypeModel.MESSAGE_TYPE_RECALL_MSG2) {
      return null;
    }

    //后台处理了 其他群成员不接收 有人加入退出群聊信息
    // if (!ChatPageUtil.init(Application.appContext).isShowNewMessage(msg)) {
    //   return null;
    // }

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
        dto.type = OFFICIAL_TYPE;
        dto.avatarUri = "http://devpic.aimymusic.com/app/system_message_avatar.png";
        dto.name = "系统通知";
        break;
      default:
        //其他情况暂时不处理
        return null;
    }
    //暂时将时间写一样
    dto.createTime = msg.sentTime;
    dto.updateTime = msg.sentTime;

    //需要额外获取的信息
    dto.isTop = 0;
    TopChatModel topChatModel =
        new TopChatModel(type: dto.type == GROUP_TYPE ? 1 : 0, chatId: int.parse(dto.conversationId));
    if (TopChatModel.contains(topChatModelList, topChatModel)) {
      dto.isTop = 1;
    }

    //撤回消息和已读的其他类型消息不计未读数，其他为未读计未读数1
    if (msg.objectName == ChatTypeModel.MESSAGE_TYPE_RECALL_MSG1 ||
        msg.objectName == ChatTypeModel.MESSAGE_TYPE_RECALL_MSG2 ||
        msg.objectName == ChatTypeModel.MESSAGE_TYPE_GRPNTF ||
        msg.receivedStatus != RCReceivedStatus.Unread) {
      dto.unreadCount = 0;
    } else {
      if (ChatMessageProfileUtil.init().isCurrentChatGroupId(msg)) {
        dto.unreadCount = 0;
      } else {
        if (msg.objectName == ChatTypeModel.MESSAGE_TYPE_TEXT) {
          Map<String, dynamic> contentMap = json.decode((msg.content as TextMessage).content);
          if (contentMap["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_GRPNTF) {
            dto.unreadCount = 0;
            return dto;
          } else if (contentMap["subObjectName"] == ChatTypeModel.MESSAGE_TYPE_CMD) {
            dto.unreadCount = 0;
            return dto;
          }
        }
        dto.unreadCount = 1;

        //加上全局未读数
        NoPromptUidModel model = NoPromptUidModel(type: dto.type, targetId: int.parse(dto.conversationId));
        if (!NoPromptUidModel.contains(queryNoPromptUidList, model)) {
          unreadMessageNumber += 1;
          EventBus.init().post(registerName: EVENTBUS_IF_TAB_BAR_UNREAD);
        }
      }
    }
    return dto;
  }

  //判断有没有at我的消息
  static void judgeIsHaveAtUserMes(Message msg) {
    ChatMessageProfileUtil.init().judgeIsHaveAtUserMsg(msg);
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
  static splitMessage(Message message) {
    if (message.objectName == ChatTypeModel.MESSAGE_TYPE_CMD) {
      //私聊通知
      Map<String, dynamic> dataMap = json.decode(message.originContentMap["data"]);
      switch (dataMap["subType"]) {
        case 0:
          //0-加入群聊
          ChatMessageProfileUtil.init().entryGroup(message);
          break;
        case 1:
          //1-退出群聊
          print("1111退出群聊");
          //判断是不是群通知-移除群成员的消息
          GroupChatUserInformationDBHelper().removeGroupAllInformation(message.targetId);
          break;
        case 2:
          //2-移除群聊
          print("22222移除群聊");
          ChatMessageProfileUtil.init().removeGroup(message);

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
          EventBus.init().post(msg: message, registerName: LIVE_COURSE_BOOK_LIVE);
          break;
        case 8:
          //8-遥控器变化---目前只有训练进度
          print("目前只有训练进度");
          TrainingScheduleModel model = TrainingScheduleModel.fromJson(dataMap["cmd"]);
          if (model != null) {
            _trainingSchedule(model);
          }
          break;
        case 9:
          //9-训练结束
          print('训练结束');
          Future.delayed(Duration(seconds: 1),(){
            EventBus.init().post(registerName: END_OF_TRAINING);
          });
          TrainingCompleteResultModel trainingResult = TrainingCompleteResultModel.fromJson(dataMap["cmd"]);
          //TODO 处理训练结束事件
          //TODO 如果有结果则打开训练结果页面
          if (trainingResult.hasResult == 1) {
            switch (trainingResult.type) {
              case 0: // 直播课
                break;
              case 1: // 视频课
                getCourseModel(courseId: trainingResult.courseId, type: mode_video).then((courseModel) {
                  if (courseModel != null) {
                    Future.delayed(Duration.zero).then((value) {
                      AppRouter.navigateToVideoCourseResult(
                          Application.navigatorKey.currentState.overlay.context, trainingResult, courseModel);
                    });
                  }
                });
                break;
              default:
                break;
            }
          }
          break;
        case 10:
          //10-开始训练-StartTraining
          print("开始训练-StartTraining");
          _startTraining(dataMap);
          break;
        case 11:
          //11-音量/亮度变化-MachineSettingChange
          print("11-音量/亮度变化-MachineSettingChange");
          break;
        case 12:
          //12-新用户通知-NewUser
          print("12-新用户通知-NewUser");
          break;
        case 13:
          //13-活动邀请-ActivityInvite
          print("13-活动邀请-ActivityInvite");
          break;
        case 14:
          //14-受邀加入群聊-EntryGroupByInvite
          print("14-受邀加入群聊-EntryGroupByInvite");
          break;
        case 15:
          //15-活动解散-ActivityDissolution
          print("15-活动解散-ActivityDissolution");
          break;
        case 16:
          //16-活动用户移除-ActivityMemberRemove
          print("16-活动用户移除-ActivityMemberRemove");
          break;
        case 17:
          //17-活动人数不足-ActivityMemberNotEnough
          print("17-活动人数不足-ActivityMemberNotEnough");
          break;
        case 18:
          //18-活动申请加入-ActivityApplyJoin
          print("18-活动申请加入-ActivityApplyJoin");
          EventBus.init().post(msg: 1, registerName: ACTIVITY_PAGE_GET_APPLYLISTUNREAD);
          break;
        default:
          break;
      }
    } else if (message.objectName == ChatTypeModel.MESSAGE_TYPE_GRPNTF) {
      //群聊通知
      Map<String, dynamic> dataMap;

      try {
        if (message.originContentMap != null && message.originContentMap["data"] != null) {
          dataMap = json.decode(message.originContentMap["data"]);
        } else if (message.content is GroupNotificationMessage) {
          GroupNotificationMessage msg = message.content as GroupNotificationMessage;
          print("GroupNotificationMessage:${msg.data is String}");
          print("GroupNotificationMessage:${msg.data is Map<String, dynamic>}");
          dataMap = jsonDecode(msg.data);
        }
      } catch (e) {
        dataMap = Map();
      }
      switch (dataMap["subType"]) {
        case 0:
          GroupChatUserInformationDBHelper().update(message: message);
          EventBus.init().post(msg: message, registerName: RESET_CHAR_GROUP_USER_LIST);
          break;
        case 1:
        case 2:
          GroupChatUserInformationDBHelper().removeMessageGroup(message);
          EventBus.init().post(msg: message, registerName: RESET_CHAR_GROUP_USER_LIST);
          break;
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
      EventBus.init().post(msg: message, registerName: CHAT_GET_MSG);
    } else {
      //普通消息
      judgeIsHaveAtUserMes(message);
      EventBus.init().post(msg: message, registerName: CHAT_GET_MSG);
    }
  }

  //直播间的通知消息
  static splitChatRoomMessage(Message message) async {
    if (message.conversationType != RCConversationType.ChatRoom) {
      return;
    }
    if (message.objectName == ChatTypeModel.MESSAGE_TYPE_CMD) {
      //私聊通知
      Map<String, dynamic> dataMap = json.decode(message.originContentMap["data"]);
      switch (dataMap["subType"]) {
        case 0:
          //0-直播开始
          print("直播开始");
          List list = [];
          list.add(0);
          list.add(dataMap["courseId"]);
          EventBus.init().post(msg: list, registerName: LIVE_COURSE_LIVE_START_OR_END);
          break;
        case 1:
          //1-心跳
          print("心跳");

          break;
        case 2:
          //2-直播禁言
          List list = [];
          list.add(2);
          list.add(dataMap["liveRoomId"].toString());
          list.add(dataMap["users"]);
          list.add(message);
          EventBus.init().post(registerName: EVENTBUS_ROOM_RECEIVE_NOTICE, msg: list);
          break;
        case 3:
          //3-直播结束
          print("直播结束");
          List list = [];
          list.add(3);
          list.add(dataMap["courseId"]);
          EventBus.init().post(msg: list, registerName: LIVE_COURSE_LIVE_START_OR_END);
          break;
        case 4:
          //4-课件开始
          print("课件开始");
          List list = [];
          list.add(4);
          list.add(dataMap["liveRoomId"]);
          list.add(dataMap["timestamp"]);
          EventBus.init().post(msg: list, registerName: START_LIVE_COURSE);
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
              return _getUserMessage(contentMap);
            case ChatTypeModel.MESSAGE_TYPE_LIVE_COURSE:
              return "[直播课程]";
            case ChatTypeModel.MESSAGE_TYPE_VIDEO_COURSE:
              return "[视频课程]";
            case ChatTypeModel.MESSAGE_TYPE_VOICE:
              return "[语音]";
            case ChatTypeModel.MESSAGE_TYPE_GRPNTF:
              return _parseGrpNtf(contentMap);
            case ChatTypeModel.MESSAGE_TYPE_CMD:
              return _parseCmdNtf(contentMap);
            case ChatTypeModel.MESSAGE_TYPE_ALERT:
              return contentMap["data"];
            case ChatTypeModel.MESSAGE_TYPE_SYSTEM_COMMON:
              // print("msg.content：${contentMap.toString()}");
              return _getUSystemCommonMessage(contentMap);
            case ChatTypeModel.MESSAGE_TYPE_ACTIVITY_INVITE:
              // print("msg.content：${contentMap.toString()}");
              return "[活动]";
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
        if (msg.originContentMap != null && msg.originContentMap["data"] != null) {
          return _parseGrpNtf(msg.originContentMap, isTextMessageGrpNtf: false);
        } else if (msg.content is GroupNotificationMessage) {
          GroupNotificationMessage message = msg.content as GroupNotificationMessage;
          return _parseGrpNtf(json.decode(message.data), isTextMessageGrpNtf: false);
        }
        return "群聊通知";
      case ChatTypeModel.MESSAGE_TYPE_CMD:
        return "私聊通知";
      case ChatTypeModel.MESSAGE_TYPE_SYSTEM_COMMON:
        print("msg.content：${msg.content.toString()}");
        return "[系统信息]";
      default:
        return msg.content.encode();
    }
  }

  static String _getUserMessage(Map<String, dynamic> contentMap){
    try{
      UserModel userModel = UserModel.fromJson(json.decode(contentMap["data"]));
      return "[用户名片] ${userModel.nickName}";
    }catch (e){
      return "[用户名片]";
    }
  }

  static String _getUSystemCommonMessage(Map<String, dynamic> contentMap){
    try{
      ChatSystemMessageSubModel subModel = ChatSystemMessageSubModel.fromJson(json.decode(contentMap["data"]));
      return subModel.text??"[系统通知]";
    }catch (e){
      return "[系统通知]";
    }
  }


  static String _parseGrpNtf(Map<String, dynamic> content, {bool isTextMessageGrpNtf = true}) {
    Map<String, dynamic> dataMap;
    if (content["subType"] != null && content["data"] == null) {
      dataMap = content;
    } else if (isTextMessageGrpNtf) {
      dataMap = json.decode(json.decode(content["data"])["data"]);
    } else {
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
        if (dataMap["operator"] == Application.profile.uid) {
          operatorName = "你";
        }
        if (operatorName == "你" && names == "你") {
          return "你创建了活动";
        }
        return "$operatorName邀请了$names加入群聊";
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
      case 6:
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
        if (dataMap["operator"] == Application.profile.uid) {
          operatorName = "你";
        }

        if (operatorName == "你" && names == "你") {
          return "你创建了活动";
        }
        return "$operatorName邀请了$names加入活动";
      case 7:
        return "活动即将开始";
      case 8:
        if (dataMap["address"] == null && dataMap["count"] == null) {
          return "活动内容变更";
        }
        if (dataMap["address"] != null) {
          return "活动地址修改为:${dataMap["address"]}";
        } else {
          return "活动人数修改为:${dataMap["count"]}人";
        }
        return "活动内容变更";
      default:
        return "[群聊通知]";
    }
  }

  static String _parseCmdNtf(Map<String, dynamic> content) {
    return "[系统通知]";
  }

  //判断消息是不是聊天室弹幕消息
  static bool judgeBarrageMessage(Message message) {
    print("message.objectName：${message.objectName},${message.conversationType}");
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
    print("message.objectName：${message.objectName},${message.conversationType}");
    if (message == null) {
      return false;
    } else if (message.conversationType == RCConversationType.ChatRoom) {
      if (message.objectName == ChatTypeModel.MESSAGE_TYPE_CMD) {
        print("聊天室：私通知");
        return true;
      } else if (message.objectName == ChatTypeModel.MESSAGE_TYPE_GRPNTF) {
        print("聊天室：群通知");
        return true;
      }
    }
    return false;
  }

  //机器训练开始
  static void _startTraining(Map<String, dynamic> dataMap) {
    if(Application.isBackGround){
      return;
    }
    getMachineStatusInfo().then((list) {
      if (list != null && list.isNotEmpty) {
        MachineModel model = list.first;
        if (model != null && model.isConnect == 1 && model.inGame == 1) {
          if(dataMap["courseType"]==model.type) {
            _startTrainingCourse(dataMap);
          }
          return;
        }
      }
    }).catchError((e) {
    });
  }

  static _startTrainingCourse(Map<String, dynamic> dataMap){
    if (dataMap["courseId"] == null || dataMap["courseType"] == null) {
      print("dataMap[courseType]:${dataMap["courseType"]},courseId：${dataMap["courseId"]}");
      return;
    }
    if (!(dataMap["courseType"] == 0 || dataMap["courseType"] == 1)) {
      print("dataMap[courseType]:${dataMap["courseType"]}");
      return;
    }

    //dataMap["courseType"]==0  直播 1--视频

    if (AppRouter.isHaveMachineRemoteControllerPage()) {
      List list = [];
      String modeType = dataMap["courseType"] == 0 ? mode_live : mode_video;
      list.add(dataMap["courseId"]);
      list.add(modeType);
      EventBus.init().post(msg: list, registerName: START_TRAINING);
    } else {
      if (dataMap["courseType"] == 0) {
        //courseType-0--直播
        BuildContext context = Application.navigatorKey.currentState.overlay.context;
        AppRouter.navigateToMachineRemoteController(context,
            courseId: dataMap["courseId"], liveRoomId: dataMap["liveRoomId"], modeType: mode_live);
      } else {
        //courseType-0--视频
        BuildContext context = Application.navigatorKey.currentState.overlay.context;
        AppRouter.navigateToMachineRemoteController(context,
            courseId: dataMap["courseId"], liveRoomId: dataMap["liveRoomId"], modeType: mode_video);
      }
    }
  }


  //机器训练进度的返回---只有视频课程
  static void _trainingSchedule(TrainingScheduleModel scheduleModel) {
    if (scheduleModel.courseId == null) {
      return;
    }
    if(Application.isBackGround){
      return;
    }
    // print("DateTime.now().millisecondsSinceEpoch-Application.openAppTime:${DateTime.now().millisecondsSinceEpoch-Application.openAppTime}");
    if(DateTime.now().millisecondsSinceEpoch-Application.openAppTime<10000){
      getMachineStatusInfo().then((list) {
        if (list != null && list.isNotEmpty) {
          MachineModel model = list.first;
          if (model != null && model.isConnect == 1 && model.inGame == 1) {
            if (model.type == 1) {
              _openMachineRemoteControllerPage(scheduleModel);
            }
            return;
          }
        }
      }).catchError((e) {
      });
    }else{
      _openMachineRemoteControllerPage(scheduleModel);
    }
  }

  static _openMachineRemoteControllerPage(TrainingScheduleModel model){
    if (AppRouter.isHaveMachineRemoteControllerPage()) {
      EventBus.init().post(msg: model, registerName: SCHEDULE_TRAINING_VIDEO);
    } else {
      BuildContext context = Application.navigatorKey.currentState.overlay.context;
      AppRouter.navigateToMachineRemoteController(context, courseId: model.courseId, modeType: mode_video);
      Future.delayed(Duration(milliseconds: 100), () {
        EventBus.init().post(msg: model, registerName: SCHEDULE_TRAINING_VIDEO);
      });
    }
  }
}
