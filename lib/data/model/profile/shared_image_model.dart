
import 'dart:io';

class SharedImageModel{
  File file;
  int height;
  int width;
  SharedImageModel({this.file,this.height,this.width});

  SharedImageModel.fromJson(Map<String, dynamic> json) {
    file = json["file"];
    height = json["height"];
    width = json["width"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["file"] = file;
    map["height"] = height;
    map["width"] = width;
    return map;
  }
}