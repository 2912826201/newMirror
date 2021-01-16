// 搜索动态列表
import 'package:flutter/cupertino.dart';
import 'package:mirror/data/model/base_response_model.dart';
import 'package:mirror/data/model/data_response_model.dart';

import '../api.dart';
// 搜索课程
const String SRARCHCOURSE = "/sport/course/searchCourse";
// 搜索动态
const String SEARCHFEED = "/appuser/web/feed/searchFeed";
//获取搜索动态列表
Future<DataResponseModel> searchFeed({@required String key, @required int size, int lastTime}) async {
  Map<String, dynamic> params = {};
  params["key"] = key;
  params["size"] = size;
  params["lastTime"] = lastTime;
  BaseResponseModel responseModel = await requestApi(SEARCHFEED, params);
  if (responseModel.isSuccess) {
    DataResponseModel  dataResponseModel;
    if (responseModel.data != null) {
      dataResponseModel = DataResponseModel.fromJson(responseModel.data);
    }
    return dataResponseModel;
  } else {
    return null;
  }
}
// 获取搜索课程列表

Future<DataResponseModel> searchCourse({@required String key, @required int size, int lastTime}) async {
  Map<String, dynamic> params = {};
  params["key"] = key;
  params["size"] = size;
  params["lastTime"] = lastTime;
  BaseResponseModel responseModel = await requestApi(SRARCHCOURSE, params);
  if (responseModel.isSuccess) {
    DataResponseModel  dataResponseModel;
    if (responseModel.data != null) {
      dataResponseModel = DataResponseModel.fromJson(responseModel.data);
    }
    return dataResponseModel;
  } else {
    return null;
  }
}