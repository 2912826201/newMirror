import 'package:mirror/data/model/home/home_feed.dart';

import '../media_file_model.dart';

class PostFeedModel {
  SelectedMediaFiles selectedMediaFiles;
  String content;
  List<AtUsersModel> atUsersModel;
  String address;
  String cityCode;
  String longitude;
  String latitude;
  List<TopicDtoModel> topics;
  // 当前时间戳
  int currentTimestamp;
  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["selectedMediaFiles"] = selectedMediaFiles;
    map["content"] = content;
    map["atUsersModel"] = atUsersModel;
    map["address"] = address;
    map["cityCode"] = cityCode;
    map["longitude"] = longitude;
    map["latitude"] = latitude;
    map["topics"] = topics;
    map["currentTimestamp"] = currentTimestamp;
    return map;
  }
  @override
  String toString() {
    return toJson().toString();
  }
}