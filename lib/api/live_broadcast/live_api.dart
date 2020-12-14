import 'package:flutter/cupertino.dart';
import 'package:mirror/api/api.dart';
import 'package:mirror/data/model/base_response_model.dart';

// 根据日期获取直播课程列表
const String GETLIVECOURSES = "/sport/course/getLiveCourses";
// 获取今日可回放直播课程
const String GETTODAYPLAYBACKCOURSE = "/sport/course/getTodayPlaybackCourse";
// 直播课程详情
const String LIVECOURSEDETAIL = "/sport/course/liveCourseDetail";
// 预约直播课程
const String BOOKLIVECOURSE = "/sport/course/bookLiveCourse";
// 获取视频课程标签库
const String GETALLTAGS = "/sport/course/getAllTags";

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

///直播课程详情
///请求参数
///courseId:1
Future<Map> liveCourseDetail({@required int courseId}) async {
  Map<String, dynamic> params = {};
  params["courseId"] = courseId.toString();
  BaseResponseModel responseModel = await requestApi(LIVECOURSEDETAIL, params);
  if (responseModel.isSuccess) {
    return responseModel.data;
  } else {
    return null;
  }
}

///直播课程详情
///请求参数
///courseId:1
///isBook:true
Future<Map> bookLiveCourse(
    {@required int courseId, @required bool isBook}) async {
  Map<String, dynamic> params = {};
  params["courseId"] = courseId;
  params["isBook"] = isBook ? 1 : 0;
  BaseResponseModel responseModel = await requestApi(BOOKLIVECOURSE, params);
  if (responseModel.isSuccess) {
    return responseModel.data;
  } else {
    return null;
  }
}

///获取视频课程标签库
///请求参数
Future<Map> getAllTags() async {
  Map<String, dynamic> params = {};
  BaseResponseModel responseModel = await requestApi(GETALLTAGS, params);
  if (responseModel.isSuccess) {
    return responseModel.data;
  } else {
    return null;
  }
}
