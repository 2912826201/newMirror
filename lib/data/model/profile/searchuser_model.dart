

import 'package:mirror/data/model/user_model.dart';

class SearchUserModel{
  int lastTime;
  int hasNext;
  List<UserModel> list = [];
  SearchUserModel({this.list,this.hasNext,this.lastTime});
  SearchUserModel.fromJson(dynamic json) {
    hasNext = json["hasNext"];
    lastTime = json["lastTime"];
    if (json["list"] != null) {
      list = [];
      json["list"].forEach((v) {
        if(v is UserModel){
          list.add(v);
        }else{
          list.add(UserModel.fromJson(v));
        }
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