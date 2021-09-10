import 'package:mirror/data/model/user_model.dart';

class ActivityModel {
  int id;
  String title;
  int type;
  int count;
  int status; // 0-筹集中 1-筹集满 2-进行中 3-已结束
  int tag; // 0-官方 1-好友 2-未签到 3-已签到
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
  int joinAmount;
  int signInAmount;
  bool _isSignIn;
  bool _isCanSignIn;
  bool _isEvaluate;
  bool _isJoin;
  double _evaluateAvgScore;
  List<UserModel> members;
  List<String> pics;

  // 附加字段
  String activityTitle;
  String activityTitle1;
  double tagWidth;

  bool get isSignIn => _isSignIn ?? false;

  bool get isCanSignIn => _isCanSignIn ?? false;

  bool get isEvaluate => _isEvaluate ?? false;

  bool get isJoin => _isJoin ?? false;

  double get evaluateAvgScore => _evaluateAvgScore ?? 0.0;

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
    _evaluateAvgScore = json['evaluateAvgScore'];
    joinAmount = json['joinAmount'];
    signInAmount = json['signInAmount'];
    if (json['isJoin'] != null && json['isJoin'] is int && json['isJoin'] == 1) {
      _isJoin = true;
    } else {
      _isJoin = false;
    }
    if (json['isSignIn'] != null && json['isSignIn'] is int && json['isSignIn'] == 1) {
      _isSignIn = true;
    } else {
      _isSignIn = false;
    }
    if (json['isCanSignIn'] != null && json['isCanSignIn'] is int && json['isCanSignIn'] == 1) {
      _isCanSignIn = true;
    } else {
      _isCanSignIn = false;
    }
    if (json['isEvaluate'] != null && json['isEvaluate'] is int && json['isEvaluate'] == 1) {
      _isEvaluate = true;
    } else {
      _isEvaluate = false;
    }
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
        if (v is Map<String, dynamic> && v["coverUrl"] != null) {
          pics.add(v["coverUrl"]);
        } else if (v is String) {
          pics.add(v);
        }
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
    map['isSignIn'] = _isSignIn;
    map['isCanSignIn'] = _isCanSignIn;
    map['isEvaluate'] = _isEvaluate;
    map['evaluateAvgScore'] = _evaluateAvgScore;
    map['isJoin'] = _isJoin;
    map['signInAmount'] = signInAmount;
    map['joinAmount'] = joinAmount;
    return map;
  }
}
