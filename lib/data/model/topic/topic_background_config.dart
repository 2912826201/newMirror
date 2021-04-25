class TopicBackgroundConfigModel {
  int id;
  String backgroundColor;

  TopicBackgroundConfigModel({this.id, this.backgroundColor});

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["id"] = id;
    map["backgroundColor"] = backgroundColor;
    return map;
  }

  TopicBackgroundConfigModel.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    backgroundColor = json["backgroundColor"];
  }

  @override
  String toString() {
    return toJson().toString();
  }
}
