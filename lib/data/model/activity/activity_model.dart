import 'package:mirror/data/model/user_model.dart';

class ActivityModel {
  int id;
  String title;
  int type;
  int count;
  int status;// 0-筹集中 1-筹集满 2-进行中 3-已结束
  int tag;        // 0-官方 1-好友 2-未签到 3-已签到
  int times;
  String cityCode;
  String address;
  double longitude;
  double latitude;
  int equipment;
  int auth;
  String pic;
  String description;
  int startTime;
  int endTime;
  int groupChatId;
  int masterId;
  List<UserModel> members;
  List<String> pics;

  ActivityModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    type = json['type'];
    count = json['count'];
    status = json['status'];
    tag = json['tag'];
    times = json['times'];
    cityCode = json['cityCode'];
    address = json['address'];
    longitude = json['longitude'];
    latitude = json['latitude'];
    equipment = json['equipment'];
    auth = json['auth'];
    pic = json['pic'];
    description = json['description'];
    startTime = json['startTime'];
    endTime = json['endTime'];
    groupChatId = json['groupChatId'];
    masterId = json['masterId'];
    if (json["members"] != null) {
      members = [];
      json["members"].forEach((v) {
        if (v is UserModel) {
          members.add(v);
        } else {
          members.add(UserModel.fromJson(v));
        }
      });
    }
    if (json["pics"] != null) {
      pics = [];
      json["pics"].forEach((v) {
        pics.add(v);
      });
    }
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map['id'] = id;
    map['title'] = title;
    map['type'] = type;
    map['count'] = count;
    map['status'] = status;
    map['tag'] = tag;
    map['times'] = times;
    map['cityCode'] = cityCode;
    map['address'] = address;
    map['longitude'] = longitude;
    map['latitude'] = latitude;
    map['equipment'] = equipment;
    map['auth'] = auth;
    map['pic'] = pic;
    map['description'] = description;
    map['startTime'] = startTime;
    map['endTime'] = endTime;
    map['members'] = members;
    map['masterId'] = masterId;
    map['groupChatId'] = groupChatId;
    map['pics'] = pics;
    return map;
  }
}
