/// user_model
/// Created by yangjiayi on 2020/10/29.

//动作的model
class ActionModel {
  int id; //Id
  String title; //title
  int count; //次数
  String longTime; // 时长

  ActionModel({
    this.id = 0, //默认给个uid为0
    this.title,
    this.count = 0,
    this.longTime,
  });

  ActionModel.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    title = json["title"];
    count = json["count"];
    longTime = json["longTime"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["id"] = id;
    map["title"] = title;
    map["count"] = count;
    map["longTime"] = longTime;
    return map;
  }
}
