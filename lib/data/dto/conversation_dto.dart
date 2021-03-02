import 'package:mirror/config/application.dart';
import 'package:mirror/data/model/message/group_chat_model.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

/// conversation_dto
/// Created by yangjiayi on 2020/11/30.

//系统消息的type类型
const int OFFICIAL_TYPE = 1;
//直播消息的type类型
const int LIVE_TYPE = 2;
//运动消息的type类型
const int TRAINING_TYPE = 3;
//管家会话的type类型
const int MANAGER_TYPE = 10;
//私聊会话的type类型
const int PRIVATE_TYPE = 100;
//群聊会话的type类型
const int GROUP_TYPE = 101;

const String TABLE_NAME_CONVERSATION = "conversation";
const String COLUMN_NAME_CONVERSATION_ID = 'id';
const String COLUMN_NAME_CONVERSATION_CONVERSATIONID = 'conversationId';
const String COLUMN_NAME_CONVERSATION_UID = 'uid';
const String COLUMN_NAME_CONVERSATION_TYPE = 'type';
const String COLUMN_NAME_CONVERSATION_AVATARURI = 'avatarUri';
const String COLUMN_NAME_CONVERSATION_NAME = 'name';
const String COLUMN_NAME_CONVERSATION_CONTENT = 'content';
const String COLUMN_NAME_CONVERSATION_UPDATETIME = 'updateTime';
const String COLUMN_NAME_CONVERSATION_CREATETIME = 'createTime';
const String COLUMN_NAME_CONVERSATION_ISTOP = 'isTop';
const String COLUMN_NAME_CONVERSATION_UNREADCOUNT = 'unreadCount';
const String COLUMN_NAME_CONVERSATION_SENDERUID = 'senderUid';
// 这个表是用来存放当前用户的会话列表信息
class ConversationDto {
  ConversationDto();

  //创建群聊的网络model转换为本地的会话model
  ConversationDto.fromGroupChat(GroupChatModel gdto){
    this.conversationId = "${gdto.id}";
    this.uid = Application.profile.uid;
    this.type = GROUP_TYPE;
    this.avatarUri = gdto.coverUrl;
    this.name = gdto.modifiedName == null? gdto.name : gdto.modifiedName;
    this.content = "";
    this.updateTime = gdto.updateTime;
    this.createTime = gdto.createTime;
    this.isTop = 0;
    this.unreadCount = 0;
    this.senderUid = null;
  }

  String conversationId;
  int uid;
  int type;
  String avatarUri;
  String name;
  String content;
  int updateTime;
  int createTime;
  int isTop;
  int unreadCount;
  int senderUid;

  int getType() {
    switch (this.type) {
      case PRIVATE_TYPE:
      case MANAGER_TYPE:
        return RCConversationType.Private;
      case GROUP_TYPE:
        return RCConversationType.Group;
      default:
        return RCConversationType.System;
    }
  }

  String get id => "${uid}_${type}_$conversationId";

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      COLUMN_NAME_CONVERSATION_ID: id,
      COLUMN_NAME_CONVERSATION_CONVERSATIONID: conversationId,
      COLUMN_NAME_CONVERSATION_UID: uid,
      COLUMN_NAME_CONVERSATION_TYPE: type,
      COLUMN_NAME_CONVERSATION_AVATARURI: avatarUri,
      COLUMN_NAME_CONVERSATION_NAME: name,
      COLUMN_NAME_CONVERSATION_CONTENT: content,
      COLUMN_NAME_CONVERSATION_UPDATETIME: updateTime,
      COLUMN_NAME_CONVERSATION_CREATETIME: createTime,
      COLUMN_NAME_CONVERSATION_ISTOP: isTop,
      COLUMN_NAME_CONVERSATION_UNREADCOUNT:unreadCount,
      COLUMN_NAME_CONVERSATION_SENDERUID:senderUid,
    };
    return map;
  }

  ConversationDto.fromMap(Map<String, dynamic> map) {
    conversationId = map[COLUMN_NAME_CONVERSATION_CONVERSATIONID];
    uid = map[COLUMN_NAME_CONVERSATION_UID];
    type = map[COLUMN_NAME_CONVERSATION_TYPE];
    avatarUri = map[COLUMN_NAME_CONVERSATION_AVATARURI];
    name = map[COLUMN_NAME_CONVERSATION_NAME];
    content = map[COLUMN_NAME_CONVERSATION_CONTENT];
    updateTime = map[COLUMN_NAME_CONVERSATION_UPDATETIME];
    createTime = map[COLUMN_NAME_CONVERSATION_CREATETIME];
    isTop = map[COLUMN_NAME_CONVERSATION_ISTOP];
    unreadCount = map[COLUMN_NAME_CONVERSATION_UNREADCOUNT];
    senderUid = map[COLUMN_NAME_CONVERSATION_SENDERUID];
  }
}
