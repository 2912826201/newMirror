


class ProfileModel{
  int uid;
  int followingCount;
  int followerCount;
  int feedCount;
  int laudedCount;
  ProfileModel(
    {this.uid,
      this.followingCount,
      this.followerCount,
      this.feedCount,
      this.laudedCount
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