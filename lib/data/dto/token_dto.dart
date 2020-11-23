import 'package:mirror/data/model/token_model.dart';

/// token_dto
/// Created by yangjiayi on 2020/11/23.

const String TABLE_NAME_TOKEN = "token";
const String COLUMN_NAME_TOKEN_ACCESSTOKEN = 'accessToken';
const String COLUMN_NAME_TOKEN_TOKENTYPE = 'tokenType';
const String COLUMN_NAME_TOKEN_REFRESHTOKEN = 'refreshToken';
const String COLUMN_NAME_TOKEN_EXPIRESIN = 'expiresIn';
const String COLUMN_NAME_TOKEN_SCOPE = 'scope';
const String COLUMN_NAME_TOKEN_ISPERFECT = 'isPerfect';
const String COLUMN_NAME_TOKEN_UID = 'uid';
const String COLUMN_NAME_TOKEN_ANONYMOUS = 'anonymous';
const String COLUMN_NAME_TOKEN_ISPHONE = 'isPhone';
const String COLUMN_NAME_TOKEN_JTI = 'jti';
const String COLUMN_NAME_TOKEN_CREATETIME = 'createTime';

// 这个表是用来存放当前已登录用户信息的表

class TokenDto {
  String accessToken;
  String tokenType;
  String refreshToken;
  int expiresIn;
  String scope;
  int isPerfect;
  String uid;
  int anonymous;
  int isPhone;
  String jti;

  int createTime;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      COLUMN_NAME_TOKEN_ACCESSTOKEN: accessToken,
      COLUMN_NAME_TOKEN_TOKENTYPE: tokenType,
      COLUMN_NAME_TOKEN_REFRESHTOKEN: refreshToken,
      COLUMN_NAME_TOKEN_EXPIRESIN: expiresIn,
      COLUMN_NAME_TOKEN_SCOPE: scope,
      COLUMN_NAME_TOKEN_ISPERFECT: isPerfect,
      COLUMN_NAME_TOKEN_UID: uid,
      COLUMN_NAME_TOKEN_ANONYMOUS: anonymous,
      COLUMN_NAME_TOKEN_ISPHONE: isPhone,
      COLUMN_NAME_TOKEN_JTI: jti,
      COLUMN_NAME_TOKEN_CREATETIME: createTime
    };
    return map;
  }

  TokenDto.fromMap(Map<String, dynamic> map) {
    accessToken = map[COLUMN_NAME_TOKEN_ACCESSTOKEN];
    tokenType = map[COLUMN_NAME_TOKEN_TOKENTYPE];
    refreshToken = map[COLUMN_NAME_TOKEN_REFRESHTOKEN];
    expiresIn = map[COLUMN_NAME_TOKEN_EXPIRESIN];
    scope = map[COLUMN_NAME_TOKEN_SCOPE];
    isPerfect = map[COLUMN_NAME_TOKEN_ISPERFECT];
    uid = map[COLUMN_NAME_TOKEN_UID];
    anonymous = map[COLUMN_NAME_TOKEN_ANONYMOUS];
    isPhone = map[COLUMN_NAME_TOKEN_ISPHONE];
    jti = map[COLUMN_NAME_TOKEN_JTI];
    createTime = map[COLUMN_NAME_TOKEN_CREATETIME];
  }

  TokenModel toTokenModel() {
    var model = TokenModel(
      accessToken: accessToken,
      tokenType: tokenType,
      refreshToken: refreshToken,
      expiresIn: expiresIn,
      scope: scope,
      isPerfect: isPerfect,
      uid: uid,
      anonymous: anonymous,
      isPhone: isPhone,
      jti: jti,
    );
    return model;
  }

  TokenDto.fromTokenModel(TokenModel model) {
    accessToken = model.accessToken;
    tokenType = model.tokenType;
    refreshToken = model.refreshToken;
    expiresIn = model.expiresIn;
    scope = model.scope;
    isPerfect = model.isPerfect;
    uid = model.uid;
    anonymous = model.anonymous;
    isPhone = model.isPhone;
    jti = model.jti;
    //一般来说从服务端取到token后就直接存了 所以当前时间基本可以认为是token发下来的时间
    createTime = DateTime.now().millisecondsSinceEpoch;
  }
}
