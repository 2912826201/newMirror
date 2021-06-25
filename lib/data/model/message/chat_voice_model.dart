/// type : "类型"
/// filePath : "本地地址"
/// pathUrl : "网络地址"
/// longTime : 60
/// read : 0

class ChatVoiceModel {
  String type;
  String filePath;
  String pathUrl;
  int longTime;
  int read;

  ChatVoiceModel(
      {String type = "",
      String filePath = "",
      String pathUrl = "",
      int longTime = 0,
      int read = 0}) {
    type = type;
    filePath = filePath;
    pathUrl = pathUrl;
    longTime = longTime;
    read = read;
  }

  ChatVoiceModel.fromJson(dynamic json) {
    type = json["type"];
    filePath = json["filePath"];
    pathUrl = json["pathUrl"];
    longTime = json["longTime"];

    if (json["read"] != null && json["read"] is int) {
      read = json["read"];
    } else if (json["read"] != null && json["read"] is String) {
      try {
        int read = int.parse(json["read"]);
        this.read = read;
      } catch (e) {}
    }
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["type"] = type;
    map["filePath"] = filePath;
    map["pathUrl"] = pathUrl;
    map["longTime"] = longTime;
    map["read"] = read;
    return map;
  }
}
