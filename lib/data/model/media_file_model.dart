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
    return "file:${file?.path},sizeInfo:{${sizeInfo.toString()}}";
  }

  String filePath;
  String thumbPath;

  MediaFileModel.fromJson(Map<String, dynamic> json) {
    type = json["type"];
    filePath = json["filePath"];
    thumbPath = json["thumbPath"];
    sizeInfo = json["sizeInfo"] != null ? SizeInfo.fromJson(json["sizeInfo"]) : null;
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["type"] = type;
    if (filePath != null) {
      map["filePath"] = filePath;
    } else if (file != null) {
      map["filePath"] = file.path;
    }
    map["thumbPath"] = thumbPath;
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
        if(v is MediaFileModel){
          list.add(v);
        }else{
          list.add(MediaFileModel.fromJson(v));
        }
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

class MediaBase64Model {
  String mediaBytes;
  String type;

  MediaBase64Model();

  SizeInfo sizeInfo = SizeInfo();

  String toString() {
    return "mediaBytes:${mediaBytes},sizeInfo:{${sizeInfo.toString()}}";
  }

  MediaBase64Model.fromJson(Map<String, dynamic> json) {
    type = json["type"];
    mediaBytes = json["mediaBytes"];
    sizeInfo = json["sizeInfo"] != null ? SizeInfo.fromJson(json["sizeInfo"]) : null;
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["type"] = type;
    map["mediaBytes"] = mediaBytes;
    if (sizeInfo != null) {
      map["sizeInfo"] = sizeInfo.toJson();
    }
    return map;
  }
}

class SelectedMediaBase64 {
  String type;
  List<MediaBase64Model> list = [];

  SelectedMediaBase64();

  SelectedMediaBase64.fromJson(Map<String, dynamic> json) {
    type = json["type"];
    if (json["list"] != null) {
      list = [];
      json["list"].forEach((v) {
        if(v is MediaBase64Model){
          list.add(v);
        }else{
          list.add(MediaBase64Model.fromJson(v));
        }
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
  int createTime = 0; //文件创建时间

  SizeInfo();

  String toString() {
    return "height:$height,width:$width,offsetRatioX:$offsetRatioX,offsetRatioY:$offsetRatioY"
        ",duration:$duration,videoCroppedRatio:$videoCroppedRatio,createTime：$createTime,";
  }

  SizeInfo.fromJson(Map<String, dynamic> json) {
    height = json["height"];
    width = json["width"];
    offsetRatioX = json["offsetRatioX"];
    offsetRatioY = json["offsetRatioY"];
    duration = json["duration"];
    videoCroppedRatio = json["videoCroppedRatio"];
    createTime = json["createTime"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["height"] = height;
    map["width"] = width;
    map["offsetRatioX"] = offsetRatioX;
    map["offsetRatioY"] = offsetRatioY;
    map["duration"] = duration;
    map["videoCroppedRatio"] = videoCroppedRatio;
    map["createTime"] = createTime;
    return map;
  }
}
