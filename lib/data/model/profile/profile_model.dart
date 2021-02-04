


import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:mirror/constant/color.dart';

class ProfileModel{
  int uid ;
  int followingCount;
  int followerCount;
  int feedCount ;
  int laudedCount;
  Color titleColor;
  ProfileModel(
    {this.uid = 0,
      this.followingCount = 0,
      this.followerCount = 0,
      this.feedCount = 0,
      this.laudedCount = 0,
      });

  ProfileModel.fromJson(Map<String, dynamic> json) {
    uid = json["uid"];
    followingCount = json["followingCount"];
    followerCount = json["followerCount"];
    feedCount = json["feedCount"];
    laudedCount = json["laudedCount"];

  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["uid"] = uid;
    map["followingCount"] = followingCount;
    map["followerCount"] = followerCount;
    map["feedCount"] = feedCount;
    map["laudedCount"] = laudedCount;
    return map;
  }
}