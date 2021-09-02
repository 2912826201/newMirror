import 'package:mirror/data/model/home/home_feed.dart';

import '../media_file_model.dart';

class PostprogressModel {
  // 发布动态进度
  double plannedSpeed;

  // 发布动态需要的model
  PostFeedModel postFeedModel;

  // // 是否可以发布动态
  // bool isPublish = true;

  // 是否显示发布进度视图
  bool showPulishView = false;

  PostprogressModel({ this.postFeedModel, this.plannedSpeed, this.showPulishView});

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["plannedSpeed"] = plannedSpeed;
    map["postFeedModel"] = postFeedModel.toJson();
    // map["isPublish"] = isPublish;
    map["showPulishView"] = showPulishView;
    return map;
  }

  PostprogressModel.fromJson(Map<String, dynamic> json) {
    plannedSpeed = json["plannedSpeed"];
    if (json["postFeedModel"] != null) {
      if(json["postFeedModel"] is PostFeedModel) {
        postFeedModel = json["postFeedModel"];
      }else{
        postFeedModel = PostFeedModel.fromJson(json["postFeedModel"]);
      }
    }
    // isPublish = json["isPublish"];
    showPulishView = json["showPulishView"];
  }

  @override
  String toString() {
    return toJson().toString();
  }
}

class PostFeedModel {
  SelectedMediaFiles selectedMediaFiles;
  int uid;
  String content;
  List<PostAtUserModel> atUsersModel = [];
  String address;
  String cityCode;
  String longitude;
  String latitude;
  List<PostTopicModel> topics = [];
  int videoCourseId;
  int liveCourseId;
  // 当前时间戳
  int currentTimestamp;
  // 活动Id
  int activityId;

  PostFeedModel(
      {this.selectedMediaFiles,
      this.uid,
      this.topics,
      this.atUsersModel,
      this.address,
      this.cityCode,
      this.content,
      this.currentTimestamp,
      this.latitude,
      this.longitude,
      this.videoCourseId,
      this.liveCourseId,
      this.activityId});

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["selectedMediaFiles"] = selectedMediaFiles.toJson();
    map["uid"] = uid;
    map["content"] = content;
    // if( map["atUsersModel"] != null) {
    map["atUsersModel"] = atUsersModel;
    // }
    map["address"] = address;
    map["cityCode"] = cityCode;
    map["longitude"] = longitude;
    map["latitude"] = latitude;
    // if( map["topics"] != null) {
    map["topics"] = topics;
    // }
    map["currentTimestamp"] = currentTimestamp;
    map["videoCourseId"] = videoCourseId;
    map["liveCourseId"] = liveCourseId;
    map["activityId"] = activityId;
    return map;
  }

  PostFeedModel.fromJson(Map<String, dynamic> json) {
    if (json["selectedMediaFiles"] != null) {
      if(json["selectedMediaFiles"] is SelectedMediaFiles) {
        selectedMediaFiles = json["selectedMediaFiles"];
      }else{
        selectedMediaFiles = SelectedMediaFiles.fromJson(json["selectedMediaFiles"]);
      }
    }
    print(json["atUsersModel"]);
    if (json["atUsersModel"] != null) {
      json["atUsersModel"].forEach((v) {
        if (v is PostAtUserModel) {
          atUsersModel.add(v);
        } else {
          atUsersModel.add(PostAtUserModel.fromJson(v));
        }
      });
    }
    if (json["topics"] != null) {
      json["topics"].forEach((v) {
        if (v is PostTopicModel) {
          topics.add(v);
        } else {
          topics.add(PostTopicModel.fromJson(v));
        }
      });
    }
    uid = json["uid"];
    content = json["content"];
    address = json["address"];
    cityCode = json["cityCode"];
    longitude = json["longitude"];
    latitude = json["latitude"];
    currentTimestamp = json["currentTimestamp"];
    videoCourseId = json["videoCourseId"];
    liveCourseId = json["liveCourseId"];
    activityId = json["activityId"];
  }

  @override
  String toString() {
    return toJson().toString();
  }
}
//[{"id":11,index:0,len:6},{"name":"这是话题的名字",index:0,len:8
class  PostTopicModel{
  int id;
  int index;
  int len;
  String name;
  PostTopicModel();
  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["id"] = id;
    map["index"] = index;
    map["name"] = name;
    map["len"] = len;
    return map;
  }

  PostTopicModel.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    index = json["index"];
    len = json["len"];
    name = json["name"];
  }
}
class  PostAtUserModel{
  int uid;
  int index;
  int len;
  PostAtUserModel();
  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["uid"] = uid;
    map["index"] = index;
    map["len"] = len;
    return map;
  }

  PostAtUserModel.fromJson(Map<String, dynamic> json) {
    uid = json["uid"];
    index = json["index"];
    len = json["len"];
  }
}