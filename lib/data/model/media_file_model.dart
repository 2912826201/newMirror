import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:photo_manager/photo_manager.dart';

/// media_file_model
/// Created by yangjiayi on 2020/11/21.

const mediaTypeKeyImage = "image";
const mediaTypeKeyVideo = "video";

//选的图片视频等信息 根据开发进度不断完善
class MediaFileModel {
  File file;
  String type;
  Image croppedImage;
  Uint8List thumb;
  Uint8List croppedImageData;

  MediaFileModel();

  SizeInfo sizeInfo = SizeInfo();

  String toString() {
    return "file:${file.path},sizeInfo:{${sizeInfo.toString()}}";
  }

  String filePath;

  MediaFileModel.fromJson(Map<String, dynamic> json) {
    type = json["type"];
    filePath = json["filePath"];
    sizeInfo = json["sizeInfo"] != null ? SizeInfo.fromJson(json["sizeInfo"]) : null;
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["type"] = type;
    map["filePath"] = file.path;
    if (sizeInfo != null) {
      map["sizeInfo"] = sizeInfo.toJson();
    }
    return map;
  }
}

class SelectedMediaFiles {
  String type;
  List<MediaFileModel> list;

  SelectedMediaFiles();

  SelectedMediaFiles.fromJson(Map<String, dynamic> json) {
    type = json["type"];
    if (json["list"] != null) {
      list = [];
      json["list"].forEach((v) {
        list.add(MediaFileModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["type"] = type;
    if (list != null) {
      map["list"] = list.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class SizeInfo {
  int height = 0;
  int width = 0;
  double videoCroppedRatio; // 当视频不需要裁剪时 此值为null
  double offsetRatioX = 0.0;
  double offsetRatioY = 0.0;
  int duration = 0; //时长，只有音视频有用，图片此值为0，单位秒

  SizeInfo();

  String toString() {
    return "height:${height},width:${width},offsetRatioX:${offsetRatioX},offsetRatioY:${offsetRatioY},duration:${duration},videoCroppedRatio:${videoCroppedRatio},";
  }

  SizeInfo.fromJson(Map<String, dynamic> json) {
    height = json["height"];
    width = json["width"];
    offsetRatioX = json["offsetRatioX"];
    offsetRatioY = json["offsetRatioY"];
    duration = json["duration"];
    videoCroppedRatio = json["videoCroppedRatio"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["height"] = height;
    map["width"] = width;
    map["offsetRatioX"] = offsetRatioX;
    map["offsetRatioY"] = offsetRatioY;
    map["duration"] = duration;
    map["videoCroppedRatio"] = videoCroppedRatio;
    return map;
  }
}
