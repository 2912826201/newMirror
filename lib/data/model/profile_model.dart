


class ProfileModel{
  int uid;
  int followingCount;
  int followerCount;
  int feedCount;

  ProfileModel(
    {this.uid,
      this.followingCount,
      this.followerCount,
      this.feedCount,
      });

  ProfileModel.fromJson(Map<String, dynamic> json) {
    uid = json["uid"];
    followingCount = json["followingCount"];
    followerCount = json["followerCount"];
    feedCount = json["feedCount"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["uid"] = uid;
    map["followingCount"] = followingCount;
    map["followerCount"] = followerCount;
    map["feedCount"] = feedCount;
    return map;
  }
}