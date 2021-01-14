
class FansListModel{
  int hasNext;
  int lastTime;
  int lastId;
  int lastScore;
  List<FansModel> list;
  FansListModel({this.list,this.lastTime,this.hasNext,this.lastId,this.lastScore});
  FansListModel.fromJson(dynamic json) {
    hasNext = json["hasNext"];
    lastTime = json["lastTime"];
    lastId = json["lastId"];
    lastScore = json["lastScore"];
    if (json["list"] != null) {
      list = [];
      json["list"].forEach((v) {
        list.add(FansModel.fromJson(v));
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
class FansModel{
  int uid;
  String avatarUri;
  String nickName;
  String remarkName;
  String description;
  int isFallow;
  FansModel({this.uid,this.avatarUri,this.nickName,this.description,this.isFallow,this.remarkName});

  FansModel.fromJson(Map<String, dynamic> json) {
    uid = json["uid"];
    avatarUri = json["avatarUri"];
    nickName = json["nickName"];
    remarkName = json["remarkName"];
    description = json["description"];
    isFallow = json["isFallow"];

  }
  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["uid"] = uid;
    map["avatarUri"] = avatarUri;
    map["nickName"] = nickName;
    map["remarkName"] = remarkName;
    map["description"] = description;
    map["isFallow"] = isFallow;
    return map;
  }
}
