class ProfileModel{
  int uid;
  int followingCount = 0;
  int followerCount = 0;
  int feedCount = 0;
  int laudedCount = 0;
  ProfileModel();
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