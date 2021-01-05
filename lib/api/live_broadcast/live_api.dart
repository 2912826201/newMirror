import 'package:flutter/cupertino.dart';
import 'package:mirror/api/api.dart';
import 'package:mirror/data/model/base_response_model.dart';

// 根据日期获取直播课程列表
const String GETLIVECOURSES = "/sport/course/getLiveCourses";
// 根据日期获取直播课程列表
const String GETLIVECOURSESBYDATE =
    "/sport/web/liveCourse/getLiveCoursesByDate";
// 获取今日可回放直播课程
const String GETTODAYPLAYBACKCOURSE = "/sport/course/getTodayPlaybackCourse";
// 直播课程详情
const String LIVECOURSEDETAIL = "/sport/course/liveCourseDetail";
// 预约直播课程
const String BOOKLIVECOURSE = "/sport/course/bookLiveCourse";
// 获取视频课程标签库
const String GETALLTAGS = "/sport/course/getAllTags";
// 获取视频课程库列表
const String GETVIDEOCOURSELIST = "/sport/course/getVideoCourseList";
// TA们也完成该视频课程的接口
const String GETFINISHEDVIDEOCOURSE = "/sport/course/getFinishedVideoCourse";

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

///根据日期获取直播课程列表
///请求参数
///date:2020-12-10
///type:0-待直播/正在直播，1-可回放
Future<Map> getLiveCoursesByDate(
    {@required String date, @required int type}) async {
  Map<String, dynamic> params = {};
  params["date"] = date;
  params["type"] = type;
  BaseResponseModel responseModel = await requestApi(
      GETLIVECOURSESBYDATE, params);
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

///获取视频课程库列表
///请求参数
///size:1
///target:[1,2,3]
///part:[1,2,3]
///level:[1,2,3]
///lastId:上一页的值
Future<Map> getVideoCourseList(
    {@required int size,
    @required List<int> target,
    @required List<int> part,
    @required List<int> level,
    int lastId}) async {
  Map<String, dynamic> params = {};
  params["size"] = size;
  if (target != null && target.length > 0) {
    params["target"] = target.toString();
  }
  if (part != null && part.length > 0) {
    params["part"] = part.toString();
  }
  if (level != null && level.length > 0) {
    params["level"] = level.toString();
  }
  if (lastId != null && lastId > 0) {
    params["lastId"] = lastId;
  }
  BaseResponseModel responseModel =
      await requestApi(GETVIDEOCOURSELIST, params);
  if (responseModel.isSuccess) {
    return responseModel.data;
  } else {
    return null;
  }
}

///TA们也完成该视频课程的接口
///请求参数
Future<Map> getFinishedVideoCourse(int videoCourseId, int size,
    {int lastId}) async {
  Map<String, dynamic> params = {};
  params["videoCourseId"] = videoCourseId;
  params["size"] = size;
  if (lastId != null && lastId > 0) {
    params["lastId"] = lastId;
  }
  BaseResponseModel responseModel =
      await requestApi(GETFINISHEDVIDEOCOURSE, params);
  if (responseModel.isSuccess) {
    return responseModel.data;
  } else {
    return null;
  }
}