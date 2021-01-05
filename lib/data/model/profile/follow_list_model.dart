
class FollowLsitModel{
  int lastTime;//": 1606125125965,
  List<FollowModel> list;

  FollowLsitModel({this.list});

  FollowLsitModel.fromJson(dynamic json) {
    if (json["list"] != null) {
      list = [];
      json["list"].forEach((v) {
        list.add(FollowModel.fromJson(v));
      });
    }
    lastTime = json["lastTime"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    if (list != null) {
      map["list"] = list.map((v) => v.toJson()).toList();
    }
    map["lastTime"] = lastTime;
    return map;
  }
}


class FollowModel{
  int uid;
  String avatarUri;
  String nickName;
  String description;
  int  isFallow;
  FollowModel(
    {this.uid,
      this.avatarUri,
      this.nickName,
      this.description,
      this.isFallow,
    });

  FollowModel.fromJson(Map<String, dynamic> json) {
    uid = json["uid"];
    avatarUri = json["avatarUri"];
    description = json["description"];
    nickName = json["nickName"];
    isFallow = json["isFallow"];

  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["uid"] = uid;
    map["avatarUri"] = avatarUri;
    map["description"] = description;
    map["nickName"] = nickName;
    map["isFallow"] = isFallow;
    return map;
  }
}