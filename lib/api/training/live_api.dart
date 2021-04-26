import 'package:flutter/cupertino.dart';
import 'package:mirror/api/api.dart';
import 'package:mirror/data/model/base_response_model.dart';
import 'package:mirror/data/model/list_model.dart';
import 'package:mirror/data/model/training/live_video_mode.dart';
import 'package:mirror/data/model/training/live_video_model.dart';

// 根据日期获取直播课程列表
const String GETLIVECOURSESBYDATE = "/sport/web/liveCourse/getLiveCoursesByDate";

// 直播课程详情
const String LIVECOURSEDETAIL = "/sport/web/liveCourse/detail";

// 视频课程详情
const String GETVIDEOCOURSEDETAIL = "/sport/web/videoCourse/getVideoCourseDetail";

// 预约直播课程
const String BOOKLIVECOURSE = "/sport/web/liveCourse/bookLiveCourse";

// 报名终端训练
const String APPLYTERMINALTRAINING = "/sport/web/liveCourse/applyTerminalTraining";

// 获取视频课程标签库
const String GETALLTAGS = "/sport/web/tag/getAllTags";

// 获取视频课程库列表
const String GETVIDEOCOURSELIST = "/sport/web/videoCourse/getVideoCourseList";

// TA们也完成该视频课程的接口
const String GETFINISHEDVIDEOCOURSE = "/sport/course/getFinishedVideoCourse";

//获取最近直播
const String GETLATESTLIVE = "/sport/web/liveCourse/getLatestLive";

//获取学过的课程列表
const String GETLEARNEDCOURSE = "/sport/web/videoCourse/getLearnedCourse";

//添加我的课程
const String ADDTOMYCOURSE = "/sport/web/videoCourse/addToMyCourse";
//从我的课程移除
const String DELETEFROMMYCOURSE = "/sport/web/videoCourse/deleteFromMyCourse";

//获取我的课程列表
const String GETMYCOURSE = "/sport/web/videoCourse/getMyCourse";

//获取我在终端训练过的列表
const String GETTERMINALLEARNEDCOURSE = "/sport/web/videoCourse/getTerminalLearnedCourse";

//获取直播地址
const String GETPULLSTREAMURL = "/third/web/tencentcloud/getPullStreamUrl";
//获取直播课的回放地址
const String GETPLAYBACKURL = "/sport/web/liveCourse/getPlaybackUrl";
//获取直播间信息
const String ROOMINFO = "/sport/web/liveCourse/roomInfo";

//反馈直播训练感受
const String FEELING = "/sport/web/liveCourse/feeling";


//查询禁言时间
const String QUERYMUTE = "/sport/web/liveMute/queryMute";




///根据日期获取直播课程列表
///请求参数
///date:2020-12-10
///type:0-待直播/正在直播，1-可回放
Future<Map> getLiveCoursesByDate({@required String date, @required int type}) async {
  Map<String, dynamic> params = {};
  params["date"] = date;
  params["type"] = type;
  BaseResponseModel responseModel = await requestApi(GETLIVECOURSESBYDATE, params);
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
  params["code"]=responseModel.code;
  params["dataMap"]=responseModel.data;
  return params;
}



///视频课程详情
///请求参数
///courseId:1
Future<Map> getVideoCourseDetail({@required int courseId}) async {
  Map<String, dynamic> params = {};
  params["courseId"] = courseId.toString();
  BaseResponseModel responseModel = await requestApi(GETVIDEOCOURSEDETAIL, params);
  params["code"]=responseModel.code;
  params["dataMap"]=responseModel.data;
  return params;
}

///courseId：课程id,直播课程id或者视频课程的id
///modeTye:类型,[liveVideoMode]
Future<LiveVideoModel> getLiveVideoModel({@required int courseId,String type=mode_null})async{
  if(type==mode_null){
    return null;
  }
  LiveVideoModel videoModel;
  Map<String, dynamic> model = await (type==mode_video?getVideoCourseDetail:liveCourseDetail)(courseId: courseId);
  if (model["code"] != null && model["code"] == CODE_SUCCESS && model["dataMap"] != null) {
    videoModel = LiveVideoModel.fromJson(model["dataMap"]);
  }
  return videoModel;
}


///预约直播
///请求参数
///courseId:1
///startTime:时间
///isBook:true
Future<Map> bookLiveCourse({@required int courseId, @required String startTime, @required bool isBook}) async {
  Map<String, dynamic> params = {};
  params["courseId"] = courseId;
  params["startTime"] = startTime;
  params["type"] = isBook ? 1 : 0;
  BaseResponseModel responseModel = await requestApi(BOOKLIVECOURSE, params);
  if (responseModel.isSuccess) {
    if(responseModel.code==CODE_SUCCESS) {
      params.clear();
      params.addAll(responseModel.data);
      params["code"]=CODE_SUCCESS;
    }else if(responseModel.code==CODE_DATA_EXCEPTION){
      params.clear();
      params["code"]=CODE_DATA_EXCEPTION;
    }
    return params;
  } else {
    return null;
  }
}

///报名终端
///请求参数
///courseId:1
///startTime:时间
///isBook:true
Future<Map> applyTerminalTraining({
  @required int courseId,
  @required String startTime,
}) async {
  Map<String, dynamic> params = {};
  params["courseId"] = courseId;
  params["startTime"] = startTime;
  BaseResponseModel responseModel = await requestApi(APPLYTERMINALTRAINING, params);
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
    print('====================标签请求成功');
    return responseModel.data;
  } else {
    print('===================标签请求失败=');
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
Future<Map> getVideoCourseList({
  @required int size,
  @required int page,
  @required List<int> target,
  @required List<int> part,
  @required List<int> level,
}) async {
  Map<String, dynamic> params = {};
  params["size"] = size;
  params["page"] = page;
  if (target != null && target.length > 0) {
    params["targetIds"] = target.toString();
  }
  if (part != null && part.length > 0) {
    params["partIds"] = part.toString();
  }
  if (level != null && level.length > 0) {
    params["levelIds"] = level.toString();
  }
  BaseResponseModel responseModel = await requestApi(GETVIDEOCOURSELIST, params);
  if (responseModel.isSuccess) {
    return responseModel.data;
  } else {
    return null;
  }
}

///TA们也完成该视频课程的接口
///请求参数
Future<Map> getFinishedVideoCourse(int videoCourseId, int size, {int lastId}) async {
  Map<String, dynamic> params = {};
  params["videoCourseId"] = videoCourseId;
  params["size"] = size;
  if (lastId != null && lastId > 0) {
    params["lastId"] = lastId;
  }
  BaseResponseModel responseModel = await requestApi(GETFINISHEDVIDEOCOURSE, params);
  if (responseModel.isSuccess) {
    return responseModel.data;
  } else {
    return null;
  }
}

//获取最近直播
Future<List<LiveVideoModel>> getLatestLive() async {
  Map<String, dynamic> params = {};
  BaseResponseModel responseModel = await requestApi(GETLATESTLIVE, params);
  if (responseModel.isSuccess) {
    List<LiveVideoModel> list = [];
    if (responseModel.data["list"] != null) {
      responseModel.data["list"].forEach((e) {
        list.add(LiveVideoModel.fromJson(e));
      });
    }
    return list;
  } else {
    return null;
  }
}

//获取学过的课程列表
Future<ListModel<LiveVideoModel>> getLearnedCourse(int size, {int lastTime}) async {
  Map<String, dynamic> params = {};
  params["size"] = size;
  if (lastTime != null) {
    params["lastTime"] = lastTime;
  }
  BaseResponseModel responseModel = await requestApi(GETLEARNEDCOURSE, params);
  if (responseModel.isSuccess) {
    ListModel<LiveVideoModel> listModel = ListModel<LiveVideoModel>();
    List<LiveVideoModel> list = [];
    listModel.hasNext = responseModel.data["hasNext"];
    listModel.lastTime = responseModel.data["lastTime"];
    listModel.totalCount = responseModel.data["totalCount"];
    if (responseModel.data["list"] != null) {
      responseModel.data["list"].forEach((e) {
        list.add(LiveVideoModel.fromJson(e));
      });
    }
    listModel.list = list;
    return listModel;
  } else {
    return null;
  }
}


//获取我的课程列表
Future<ListModel<LiveVideoModel>> getMyCourse(int page, int size, {int lastTime}) async {
  Map<String, dynamic> params = {};
  params["size"] = size;
  params["page"] = page;
  if (lastTime != null) {
    params["lastTime"] = lastTime;
  }
  BaseResponseModel responseModel = await requestApi(GETMYCOURSE, params);
  if (responseModel.isSuccess) {
    ListModel<LiveVideoModel> listModel = ListModel<LiveVideoModel>();
    List<LiveVideoModel> list = [];
    listModel.hasNext = responseModel.data["hasNext"];
    listModel.lastTime = responseModel.data["lastTime"];
    listModel.totalCount = responseModel.data["totalCount"];
    if (responseModel.data["list"] != null) {
      responseModel.data["list"].forEach((e) {
        list.add(LiveVideoModel.fromJson(e));
      });
    }
    listModel.list = list;
    return listModel;
  } else {
    return null;
  }
}


//获取我在终端训练过的列表
Future<ListModel<LiveVideoModel>> getTerminalLearnedCourse(int size, {int lastTime}) async {
  Map<String, dynamic> params = {};
  params["size"] = size;
  if (lastTime != null) {
    params["lastTime"] = lastTime;
  }
  BaseResponseModel responseModel = await requestApi(GETTERMINALLEARNEDCOURSE, params);
  if (responseModel.isSuccess) {
    ListModel<LiveVideoModel> listModel = ListModel<LiveVideoModel>();
    List<LiveVideoModel> list = [];
    listModel.hasNext = responseModel.data["hasNext"];
    listModel.lastTime = responseModel.data["lastTime"];
    listModel.totalCount = responseModel.data["totalCount"];
    if (responseModel.data["list"] != null) {
      responseModel.data["list"].forEach((e) {
        list.add(LiveVideoModel.fromJson(e));
      });
    }
    listModel.list = list;
    return listModel;
  } else {
    return null;
  }
}


///添加我的课程
///请求参数
///视频课程的id
Future<Map> addToMyCourse(int courseId) async {
  Map<String, dynamic> params = {};
  params["courseId"] = courseId;
  BaseResponseModel responseModel = await requestApi(ADDTOMYCOURSE, params);
  if (responseModel.isSuccess) {
    return responseModel.data;
  } else {
    return null;
  }
}


///从我的课程移除
///请求参数
///视频课程的id
Future<Map> deleteFromMyCourse(int courseId) async {
  Map<String, dynamic> params = {};
  params["courseId"] = courseId;
  BaseResponseModel responseModel = await requestApi(DELETEFROMMYCOURSE, params);
  if (responseModel.isSuccess) {
    return responseModel.data;
  } else {
    return null;
  }
}

///获取直播地址
///courseId：课程id
///直播协议类型typr：HTTP_FLV、RTMP、HLS
Future<Map> getPullStreamUrl(int courseId,{String type="HLS"}) async {
  Map<String, dynamic> params = {};
  params["courseId"] = courseId;
  params["type"] = type;
  BaseResponseModel responseModel = await requestApi(GETPULLSTREAMURL, params);
  params["code"]=responseModel.code;
  params["data"]=responseModel.data;
  return params;
}


///获取直播间信息
///liveRoomId：直播间id
///count：一次性获取多少个人数
Future<Map> roomInfo(int liveRoomId,{int count=50}) async {
  Map<String, dynamic> params = {};
  params["liveRoomId"] = liveRoomId;
  params["count"] = count;
  BaseResponseModel responseModel = await requestApi(ROOMINFO, params);
  params["code"]=responseModel.code;
  params["data"]=responseModel.data;
  return params;
}


///反馈直播训练感受
///courseId：课程id
///feel：训练感受id
Future<Map> feeling(int courseId,String feel) async {
  Map<String, dynamic> params = {};
  params["courseId"] = courseId;
  params["feel"] = feel;
  BaseResponseModel responseModel = await requestApi(FEELING, params);
  params["code"]=responseModel.code;
  params["data"]=responseModel.data;
  return params;
}


///反馈直播训练感受
///liveRoomId：直播间id
///uid：用户id不填则为当前用户
Future<Map> queryMute(int liveRoomId) async {
  Map<String, dynamic> params = {};
  params["liveRoomId"] = liveRoomId;
  BaseResponseModel responseModel = await requestApi(QUERYMUTE, params);
  params["code"]=responseModel.code;
  params["data"]=responseModel.data;
  return params;
}
