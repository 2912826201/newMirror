
import 'dart:convert';

class FeedBackModel{
  String content;
  List<String> picList;
  FeedBackModel({this.content,this.picList});
  FeedBackModel.fromJson(dynamic json) {
    content = json["content"];
    if (json["picList"] != null) {
      picList = [];
      json["picList"].forEach((v) {
        picList.add(jsonEncode(v));
      });
    }
  }
  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["content"] = jsonEncode(content);
    if (picList != null) {
      map["picList"] = picList.map((v) => jsonEncode(v)).toList();
    }
    return map;
  }

  @override
  String toString() {
    // TODO: implement toString
    return toJson().toString();
  }
}