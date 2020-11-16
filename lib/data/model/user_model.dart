import 'dart:convert';

/// user_model
/// Created by yangjiayi on 2020/10/29.

//TODO 暂时测试用的数据模型
class UserModel {
  int uid;
  String userName;
  String avatarUri;

  UserModel({this.uid, this.userName, this.avatarUri});

  UserModel.fromJson(Map<String, dynamic> jsonMap) {
    uid = jsonMap["uid"];
    userName = jsonMap["userName"];
    avatarUri = jsonMap["avatarUri"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["uid"] = uid;
    map["userName"] = userName;
    map["avatarUri"] = avatarUri;
    return map;
  }
}
