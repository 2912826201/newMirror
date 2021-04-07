
import 'package:mirror/data/model/home/home_feed.dart';

class TopicListModel{
  int hasNext;
  int lastTime;
  int lastId;
  double lastScore;
  List<TopicDtoModel> list;
  TopicListModel({this.hasNext,this.lastTime,this.lastId,this.lastScore,this.list});
  TopicListModel.fromJson(dynamic json) {
    hasNext = json["hasNext"];
    lastTime = json["lastTime"];
    lastId = json["lastId"];
    lastScore = json["lastScore"];
    if (json["list"] != null) {
      list = [];
      json["list"].forEach((v) {
        if(v is TopicDtoModel){
          list.add(v);
        }else{
          list.add(TopicDtoModel.fromJson(v));
        }

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