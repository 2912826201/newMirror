import 'package:mirror/data/model/user_model.dart';

class ActivityModel {
  int id;
  String title;
  int type;
  int count;
  int status;
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
  List<UserModel> members;
  List<String> pics;

  ActivityModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    type = json['type'];
    count = json['count'];
    status = json['status'];
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
    map['pics'] = pics;
    return map;
  }
}
