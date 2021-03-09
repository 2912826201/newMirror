import 'package:mirror/data/model/home/home_feed.dart';

import '../media_file_model.dart';

class PostFeedModel {
  SelectedMediaFiles selectedMediaFiles;
  int uid;
  String content;
  List<AtUsersModel> atUsersModel = [];
  String address;
  String cityCode;
  String longitude;
  String latitude;
  List<TopicDtoModel> topics = [];
  // 当前时间戳
  int currentTimestamp;
  PostFeedModel({this.selectedMediaFiles,this.uid,this.topics,this.atUsersModel,this.address,this.cityCode,this.content,this.currentTimestamp,this.latitude,this.longitude});
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
    return map;
  }
  PostFeedModel.fromJson(Map<String, dynamic> json) {
    if (json["selectedMediaFiles"] != null) {
      selectedMediaFiles = SelectedMediaFiles.fromJson(json["selectedMediaFiles"]);
    }
    print(json["atUsersModel"]);
    if (json["atUsersModel"] != null) {
      json["atUsersModel"].forEach((v) {
        if(v is AtUsersModel){
          atUsersModel.add(v);
        }else{
          atUsersModel.add(AtUsersModel.fromJson(v));
        }
      });
    }
    if (json["topics"] != null) {
      json["topics"].forEach((v) {
        if(v is TopicDtoModel){
          topics.add(v);
        }else{
          topics.add(TopicDtoModel.fromJson(v));
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
  }
  @override
  String toString() {
    return toJson().toString();
  }
}