/// token_model
/// Created by yangjiayi on 2020/11/16.

// 用户登录后获取的token
class TokenModel {
  String accessToken;
  String tokenType;
  String refreshToken;
  int expiresIn;
  String scope;
  int isPerfect;
  int uid;
  int anonymous;
  int isPhone;
  String jti;

  TokenModel(
      {this.accessToken,
      this.tokenType,
      this.refreshToken,
      this.expiresIn,
      this.scope,
      this.isPerfect,
      this.uid,
      this.anonymous,
      this.isPhone,
      this.jti});

  TokenModel.fromJson(Map<String, dynamic> json) {
    accessToken = json["access_token"];
    tokenType = json["token_type"];
    refreshToken = json["refresh_token"];
    expiresIn = json["expires_in"];
    scope = json["scope"];
    isPerfect = json["isPerfect"];
    uid = json["uid"];
    anonymous = json["anonymous"];
    isPhone = json["isPhone"];
    jti = json["jti"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["access_token"] = accessToken;
    map["token_type"] = tokenType;
    map["refresh_token"] = refreshToken;
    map["expires_in"] = expiresIn;
    map["scope"] = scope;
    map["isPerfect"] = isPerfect;
    map["uid"] = uid;
    map["anonymous"] = anonymous;
    map["isPhone"] = isPhone;
    map["jti"] = jti;
    return map;
  }
}
