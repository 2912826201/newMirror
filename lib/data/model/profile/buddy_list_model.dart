
class BuddyListModel{
  int hasNext;
  int lastTime;
  int lastId;
  int lastScore;
  List<BuddyModel> list = [];
  BuddyListModel({this.list,this.lastTime,this.hasNext,this.lastId,this.lastScore});
  BuddyListModel.fromJson(dynamic json) {
    hasNext = json["hasNext"];
    lastTime = json["lastTime"];
    lastId = json["lastId"];
    lastScore = json["lastScore"];
    if (json["list"] != null) {
      list = [];
      json["list"].forEach((v) {
        list.add(BuddyModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["hasNext"] = hasNext;
    map["lastTime"] = lastTime;
    if (list != null) {
      map["list"] = list.map((v) => v.toJson()).toList();
    }
    return map;
  }
}
class BuddyModel{
  int uid;
  String avatarUri;
  String nickName;
  String description;
  int relation;
  BuddyModel({this.uid,this.avatarUri,this.nickName,this.description,this.relation});

  BuddyModel.fromJson(Map<String, dynamic> json) {
    uid = json["uid"];
    avatarUri = json["avatarUri"];
    nickName = json["nickName"];
    description = json["description"];
    relation = json["relation"];
  }
  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["uid"] = uid;
    map["avatarUri"] = avatarUri;
    map["nickName"] = nickName;
    map["description"] = description;
    map["relation"] = relation;
    return map;
  }
}