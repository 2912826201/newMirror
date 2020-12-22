import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

/// id : "12365413584"
/// time : 1608521627
/// nickName : "https://dss3.bdstatic.com/70cFv8ShQ1YnxGkpoWK1HF6hhy/it/u=3155998395,3600507640&fm=26&gp=0.jpg"
/// avatar : "快快快"
/// msg : {"type":1,"content":"江苏苏州"}

class ChatDataModel {
  String id;
  int time;
  String nickName;
  String avatar;
  Map msg;
  bool isHaveAnimation = false;

  ChatDataModel(
      {String id, int time, String nickName, String avatar, Map msg}) {
    this.id = id;
    this.time = time;
    this.nickName = nickName;
    this.avatar = avatar;
    this.msg = msg;
  }

  ChatDataModel.fromJson(dynamic json) {
    id = json["id"];
    time = json["time"];
    nickName = json["nickName"];
    avatar = json["avatar"];
    msg = json["msg"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["id"] = id;
    map["time"] = time;
    map["nickName"] = nickName;
    map["avatar"] = avatar;
    map["msg"] = msg;
    return map;
  }

  String toString() {
    return "id:${id},time:${time},nickName:${nickName},avatar:${avatar},msg:${msg}";
  }
}
