

import 'package:mirror/data/model/user_model.dart';

class SearchUserModel{
  int lastTime;
  int hasNext;
  List<UserModel> list = [];

  SearchUserModel.fromJson(dynamic json) {
    hasNext = json["hasNext"];
    lastTime = json["lastTime"];
    if (json["list"] != null) {
      list = [];
      json["list"].forEach((v) {
        list.add(UserModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["hasNext"] = hasNext;
    map["lastTime"] = lastTime;
    if (list != null) {
      map["list"] = list.map((v) => v.toJson()).toList();
    }
    return map;
  }
}