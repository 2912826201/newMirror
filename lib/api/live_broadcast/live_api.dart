import 'package:flutter/cupertino.dart';
import 'package:mirror/api/api.dart';
import 'package:mirror/data/model/base_response_model.dart';

// 根据日期获取直播课程列表
const String GETLIVECOURSES = "/sport/course/getLiveCourses";
// 获取今日可回放直播课程
const String GETTODAYPLAYBACKCOURSE = "/sport/course/getTodayPlaybackCourse";

///根据日期获取直播课程列表
///请求参数
///date:2020-12-10
Future<Map> getLiveCourses({@required String date}) async {
  Map<String, dynamic> params = {};
  params["date"] = date;
  BaseResponseModel responseModel = await requestApi(GETLIVECOURSES, params);
  if (responseModel.isSuccess) {
    return responseModel.data;
  } else {
    return null;
  }
}

///获取今日可回放直播课程
///请求参数
///date:2020-12-10
Future<Map> getTodayPlaybackCourse() async {
  Map<String, dynamic> params = {};
  BaseResponseModel responseModel =
      await requestApi(GETTODAYPLAYBACKCOURSE, params);
  if (responseModel.isSuccess) {
    return responseModel.data;
  } else {
    return null;
  }
}
