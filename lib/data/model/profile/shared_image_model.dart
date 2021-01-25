
import 'dart:io';

class SharedImageModel{
  String url;
  File file;
  int height;
  int width;
  SharedImageModel({this.file,this.url,this.height,this.width});

  SharedImageModel.fromJson(Map<String, dynamic> json) {
    url = json["url"];
    file = json["file"];
    height = json["height"];
    width = json["width"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["url"] = url;
    map["file"] = file;
    map["height"] = height;
    map["width"] = width;
    return map;
  }
}