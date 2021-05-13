// 搜索动态列表
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:mirror/data/model/base_response_model.dart';
import 'package:mirror/data/model/data_response_model.dart';
import 'package:mirror/data/model/training/course_model.dart';

import '../api.dart';
// 搜索课程
const String SRARCHCOURSE = "/sport/web/videoCourse/searchCourse";

// 搜索动态
const String SEARCHFEED = "/appuser/web/feed/searchFeed";

// 推荐视频课程
const String RECOMMENDCOURSE = "/sport/web/videoCourse/recommendCourse";
//获取搜索动态列表
Future<DataResponseModel> searchFeed({@required String key, @required int size, int lastTime, CancelToken token}) async {
  Map<String, dynamic> params = {};
  params["key"] = key;
  params["size"] = size;
  params["lastTime"] = lastTime;
  BaseResponseModel responseModel = await requestApi(SEARCHFEED, params,token: token);
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

Future<DataResponseModel> searchCourse({@required String key, @required int size, int lastTime, CancelToken token}) async {
  Map<String, dynamic> params = {};
  params["key"] = key;
  params["size"] = size;
  params["lastTime"] = lastTime;
  BaseResponseModel responseModel = await requestApi(SRARCHCOURSE, params,token: token);
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

// 获取推荐课程
Future<List<CourseModel>> recommendCourse(CancelToken token) async {
  Map<String, dynamic> params = {};
  BaseResponseModel responseModel = await requestApi(RECOMMENDCOURSE, params,token: token);
  if (responseModel.isSuccess) {
    List<CourseModel> list = [];
    if (responseModel.data["list"] != null) {
      responseModel.data["list"].forEach((e) {
        list.add(CourseModel.fromJson(e));
      });
    }
    return list;
  } else {
    return null;
  }
}