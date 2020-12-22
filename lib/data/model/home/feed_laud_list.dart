class FeedLaudListModel {
  int uid;
  String avatarUrl;
  int feedId;
  int laudTime;
  FeedLaudListModel({ this.uid,this.feedId,this.avatarUrl,this.laudTime});
  FeedLaudListModel.fromJson(Map<String, dynamic> json) {
    uid = json["uid"];
    avatarUrl = json["avatarUrl"];
    feedId = json["feedId"];
    laudTime = json["laudTime"];
  }
  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["uid"] = uid;
    map["avatarUrl"] = avatarUrl;
    map["feedId"] = feedId;
    map["laudTime"] = laudTime;
    return map;
  }
}