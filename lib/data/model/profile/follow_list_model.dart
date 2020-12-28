
class FollowLsitModel{
  List<FollowModel> list;

  FollowLsitModel({this.list});

  FollowLsitModel.fromJson(dynamic json) {
    if (json["list"] != null) {
      list = [];
      json["list"].forEach((v) {
        list.add(FollowModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    if (list != null) {
      map["list"] = list.map((v) => v.toJson()).toList();
    }
    return map;
  }
}


class FollowModel{
  int uid;
  String avatarUri;
  String nickName;
  String description;
  String  isFallow;
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