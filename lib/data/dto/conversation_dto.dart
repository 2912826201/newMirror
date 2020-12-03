import 'package:mirror/data/model/token_model.dart';

/// conversation_dto
/// Created by yangjiayi on 2020/11/30.

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

// 这个表是用来存放当前用户的会话列表信息

class ConversationDto {
  ConversationDto();

  String conversationId;
  int uid;
  int type;
  String avatarUri;
  String name;
  String content;
  int updateTime;
  int createTime;
  int isTop;

  String get id => "${uid}_${conversationId}";

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
  }
  String toStirng(){
    return "${this.updateTime}";
  }
// TokenModel toTokenModel() {
  //   var model = TokenModel(
  //     accessToken: accessToken,
  //     tokenType: tokenType,
  //     refreshToken: refreshToken,
  //     expiresIn: expiresIn,
  //     scope: scope,
  //     isPerfect: isPerfect,
  //     uid: uid,
  //     anonymous: anonymous,
  //     isPhone: isPhone,
  //     jti: jti,
  //   );
  //   return model;
  // }
  //
  // TokenDto.fromTokenModel(TokenModel model) {
  //   accessToken = model.accessToken;
  //   tokenType = model.tokenType;
  //   refreshToken = model.refreshToken;
  //   expiresIn = model.expiresIn;
  //   scope = model.scope;
  //   isPerfect = model.isPerfect;
  //   uid = model.uid;
  //   anonymous = model.anonymous;
  //   isPhone = model.isPhone;
  //   jti = model.jti;
  //   //一般来说从服务端取到token后就直接存了 所以当前时间基本可以认为是token发下来的时间
  //   createTime = DateTime.now().millisecondsSinceEpoch;
  // }

}
