class FeedLaudListModel {
  int uid;
  String avatarUrl;
  int feedId;
  int laudTime;
  String description;
  FeedLaudListModel({ this.uid,this.feedId,this.avatarUrl,this.laudTime,this.description});
  FeedLaudListModel.fromJson(Map<String, dynamic> json) {
    uid = json["uid"];
    avatarUrl = json["avatarUrl"];
    feedId = json["feedId"];
    laudTime = json["laudTime"];
    description = json["description"];
  }
  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["uid"] = uid;
    map["avatarUrl"] = avatarUrl;
    map["feedId"] = feedId;
    map["laudTime"] = laudTime;
    map["description"] = description;
    return map;
  }
}