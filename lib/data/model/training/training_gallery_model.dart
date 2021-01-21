import 'package:azlistview/azlistview.dart';

/// training_gallery_model
/// Created by yangjiayi on 2021/1/21.

// 要继承这个ISuspensionBean
class TrainingGalleryDayModel with ISuspensionBean {
  String month;
  String day;
  String dateTime;
  List<TrainingGalleryImageModel> list;

  TrainingGalleryDayModel({this.dateTime, this.list});

  TrainingGalleryDayModel.fromJson(dynamic json) {
    dateTime = json["dateTime"];
    if (json["list"] != null) {
      list = [];
      json["list"].forEach((v) {
        list.add(TrainingGalleryImageModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["dateTime"] = dateTime;
    if (list != null) {
      map["list"] = list.map((v) => v.toJson()).toList();
    }
    return map;
  }

  @override
  String getSuspensionTag() => month;
}

class TrainingGalleryImageModel {
  int id;
  int uid;
  String url;
  double width;
  double height;
  double size;
  int dataState;
  int createTime;
  int updateTime;
  String dateTime;

  TrainingGalleryImageModel(
      {this.id,
      this.uid,
      this.url,
      this.width,
      this.height,
      this.size,
      this.dataState,
      this.createTime,
      this.updateTime,
      this.dateTime});

  TrainingGalleryImageModel.fromJson(dynamic json) {
    id = json["id"];
    uid = json["uid"];
    url = json["url"];
    width = json["width"];
    height = json["height"];
    size = json["size"];
    dataState = json["dataState"];
    createTime = json["createTime"];
    updateTime = json["updateTime"];
    dateTime = json["dateTime"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["id"] = id;
    map["uid"] = uid;
    map["url"] = url;
    map["width"] = width;
    map["height"] = height;
    map["size"] = size;
    map["dataState"] = dataState;
    map["createTime"] = createTime;
    map["updateTime"] = updateTime;
    map["dateTime"] = dateTime;
    return map;
  }
}
