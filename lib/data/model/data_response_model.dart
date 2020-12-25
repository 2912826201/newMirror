class  DataResponseModel {
  List list;
  int hasNext;
  int lastTime;
  int lastId;
  double lastScore;
  DataResponseModel({this.list,this.hasNext, this.lastTime, this.lastId,this.lastScore});

  DataResponseModel.fromJson(Map<String, dynamic> json) {
    list = json["list"];
    hasNext = json["hasNext"];
    lastTime = json["lastTime"];
    lastId = json["lastId"];
    lastScore = json["lastScore"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["list"] = list;
    map["hasNext"] = hasNext;
    map["lastTime"] = lastTime;
    map["lastId"] = lastId;
    map["lastScore"] = lastScore;
    return map;
  }
}