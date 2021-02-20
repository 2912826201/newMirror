//群聊的model
class GroupChatModel {
  int id;
  String name;
  String coverUrl;
  int creatorId;
  String modifiedName;
  int dataState;
  int createTime;
  int updateTime;

  GroupChatModel({this.id, this.name, this.coverUrl, this.creatorId, this.dataState, this.createTime, this.updateTime});

  GroupChatModel.fromJson(Map<String, dynamic> json) {
    this.id = json["id"];
    this.name = json["name"];
    this.coverUrl = json["coverUrl"];
    this.creatorId = json["creatorId"];
    this.modifiedName = json["modifiedName"];
    this.dataState = json["dataState"];
    this.createTime = json["createTime"];
    this.updateTime = json["updateTime"];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = Map();
    map["id"] = this.id;
    map["name"] = this.name;
    map["coverUrl"] = this.coverUrl;
    map["creatorId"] = this.creatorId;
    map["modifiedName"] = this.modifiedName;
    map["dataState"] = this.dataState;
    map["updateTime"] = this.updateTime;
    map["createTime"] = this.createTime;
    return map;
  }
}
