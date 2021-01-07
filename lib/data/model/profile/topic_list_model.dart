
class TopicListModel{
  int hasNext;
  int lastTime;
  int lastId;
  double lastScore;
  List<topicModel> list;
  TopicListModel({this.hasNext,this.lastTime,this.lastId,this.lastScore,this.list});
  TopicListModel.fromJson(dynamic json) {
    hasNext = json["hasNext"];
    lastTime = json["lastTime"];
    lastId = json["lastId"];
    lastScore = json["lastScore"];
    if (json["list"] != null) {
      list = [];
      json["list"].forEach((v) {
        list.add(topicModel.fromJson(v));
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
class topicModel{
  int id;
  String name;
  int creatorId;
  int isNew;
  int feedCount;
  int memberCount;
  int backgroundColorId;
  int patternId;
  String backgroundColor;
  int dataState;
  int createTime;
  int updateTime;
  int isFollow;
  String pics;
  String description;
  String avatarUrl;
  topicModel({
    this.id,
    this.name,
    this.creatorId,
    this.isNew,
    this.feedCount,
    this.memberCount,
    this.backgroundColorId,
    this.patternId,
    this.backgroundColor,
    this.dataState,
    this.createTime,
    this.updateTime,
    this.isFollow,
    this.pics,
    this.description,
    this.avatarUrl,
  });

  topicModel.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    name = json["name"];
    creatorId = json["creatorId"];
    isNew = json["isNew"];
    feedCount = json["feedCount"];
    memberCount = json["memberCount"];
    backgroundColorId = json["backgroundColorId"];
    patternId = json["patternId"];
    backgroundColor = json["backgroundColor"];
    dataState = json["dataState"];
    createTime = json["createTime"];
    updateTime = json["updateTime"];
    isFollow = json["isFollow"];
    pics = json["pics"];
    description = json["description"];
    avatarUrl = json["avatarUrl"];
  }
  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["id"] = id;
    map["name"] = name;
    map["creatorId"] = creatorId;
    map["isNew"] = isNew;
    map["feedCount"] = feedCount;
    map["memberCount"] = memberCount;
    map["backgroundColorId"] = backgroundColorId;
    map["patternId"] = patternId;
    map["backgroundColor"] = backgroundColor;
    map["dataState"] = dataState;
    map["createTime"] = createTime;
    map["updateTime"] = updateTime;
    map["isFollow"] = isFollow;
    map["pics"] = pics;
    map["description"] = description;
    map["avatarUrl"] = avatarUrl;
    return map;
  }
  @override
  String toString() {
    toString().toString();
  }
}