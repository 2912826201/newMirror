import 'package:flutter/material.dart';
import 'package:mirror/api/api.dart';
import 'package:mirror/data/model/base_response_model.dart';
import 'package:mirror/data/model/data_response_model.dart';
import 'package:mirror/data/model/home/home_feed.dart';

// 获取动态列表
const String PULLLISTFEED = "/appuser/web/feed/pullList";
// 获取推荐动态列表
const String PULLHOTLIST = "/appuser/web/feed/pullHotList";
//  发布动态
const String PUBLISHFEED = "/appuser/web/feed/publish";
// 动态点赞or取消赞
const String LAUDFEED = "/appuser/web/feed/laud";
// 动态点赞列表
const String GETFEEDLAUDLIST = "/appuser/web/feed/getLaudList";

// 发布/回复评论
const String PUBLISHCOMMENT = "/appuser/web/comment/publish";
// 获取评论列表热度
const String QUERYLISTBYHOT = "/appuser/web/comment/queryListByHot";
// 获取评论列表时间
const String QUERYLISTBYTIME = "/appuser/web/comment/queryListByTime";
// 删除评论
const String DELETECOMMENT = "/appuser/web/comment/delete";
// 评论点赞or取消赞
const String LAUDCOMMENT = "/appuser/web/comment/laud";
// 文本检测
const String TEXTSCAN = "/third/green/textScan";
// 图片检测
const String IMAGESCAN = "/third/green/imageScan";
// 视频检测
const String VIDEOSCAN = "/third/green/videoScan";
// 首页推荐教练
const String RECOMMENDCOACH = "/sport/course/RecommendCoach";
//获取动态列表
Future<DataResponseModel> getPullList({@required int type, @required int size, int targetId, int lastTime}) async {
  Map<String, dynamic> params = {};
  params["type"] = type;
  params["size"] = size;
  if (targetId != null) {
    params["targetId"] = targetId;
  }
  params["lastTime"] = lastTime;
  BaseResponseModel responseModel = await requestApi(PULLLISTFEED, params);
  if (responseModel.isSuccess) {
    DataResponseModel dataResponseModel;
    if (responseModel.data != null) {
      dataResponseModel = DataResponseModel.fromJson(responseModel.data);
    }
    return dataResponseModel;
  } else {
    return null;
  }
}

// 获取推荐动态列表
Future<List> getHotList({@required size}) async {
  Map<String, dynamic> params = {};
  params["size"] = size;
  BaseResponseModel responseModel = await requestApi(PULLHOTLIST, params);
  if (responseModel.isSuccess) {
    Map<String, dynamic> model = responseModel.data;
    List<HomeFeedModel> feedModelList = [];
    if (responseModel.data != null) {
      if (model["list"] != null) {
        model["list"].forEach((v) {
          feedModelList.add(HomeFeedModel.fromJson(v));
        });
      }
    }
    return feedModelList;
  } else {
    return null;
  }
}

// 文本检测
Future<Map> feedTextScan({@required String text}) async {
  Map<String, dynamic> params = {};
  params["text"] = text;
  BaseResponseModel responseModel = await requestApi(TEXTSCAN, params);
  if (responseModel.isSuccess) {
    return responseModel.data;
  } else {
    return null;
  }
}

// 图片检测
Future<Map> feedImageScan({@required String url}) async {
  Map<String, dynamic> params = {};
  params["url"] = url;
  BaseResponseModel responseModel = await requestApi(IMAGESCAN, params);
  if (responseModel.isSuccess) {
    return responseModel.data;
  } else {
    return null;
  }
}

// 视频检测
Future<Map> feedVideoScan({@required String url}) async {
  Map<String, dynamic> params = {};
  params["url"] = url;
  BaseResponseModel responseModel = await requestApi(VIDEOSCAN, params);
  if (responseModel.isSuccess) {
    return responseModel.data;
  } else {
    return null;
  }
}

// 发布动态
Future<Map> publishFeed(
    {@required int type,
    @required String content,
    String picUrls,
    String videos,
    String atUsers,
    String cityCode,
    String longitude,
    String latitude,
    String address,
    String topics}) async {
  Map<String, dynamic> params = {};
  params["type"] = type;
  params["content"] = content;
  if (picUrls != "[]") {
    params["picUrls"] = picUrls;
  }
  if (videos != "[]") {
    params["videos"] = videos;
  }
  if (atUsers != null) {
    params["atUsers"] = atUsers;
  }
  if (cityCode != null) {
    params["cityCode"] = cityCode;
  }
  if (longitude != null) {
    params["longitude"] = longitude;
  }
  if (latitude != null) {
    params["latitude"] = latitude;
  }
  if (address != null) {
    params["address"] = address;
  }
  if (topics != null) {
    params["topics"] = topics;
  }
  BaseResponseModel responseModel = await requestApi(PUBLISHFEED, params);
  if (responseModel.isSuccess) {
    return responseModel.data;
  } else {
    return null;
  }
}

// 点赞/取消点赞
Future<Map> laud({@required int id, @required int laud}) async {
  Map<String, dynamic> params = {};
  params["id"] = id;
  params["laud"] = laud;
  BaseResponseModel responseModel = await requestApi(LAUDFEED, params);
  if (responseModel.isSuccess) {
    return responseModel.data;
  } else {
    return null;
  }
}

// 发布/回调评论
Future<Map> publish(
    {@required int targetId, // 目标id（动态ID、课程ID、评论ID）
    @required int targetType, // 0=动态、1=课程 2=评论
    @required String content, // 文字内容
    String picUrl, // 评论附加图片json string
    String atUsers, // at用户列表
    int replyId, // 被回复人的id
    int replyCommentId // 被回复评论id
    }) async {
  Map<String, dynamic> params = {};
  params["targetId"] = targetId;
  params["targetType"] = targetType;
  params["content"] = content;
  if (picUrl != null) {
    params["picUrl"] = picUrl;
  }
  if (atUsers != null) {
    params["atUsers"] = atUsers;
  }
  if (replyId != null) {
    params["replyId"] = replyId;
  }
  if (replyCommentId != null) {
    params["replyCommentId"] = replyCommentId;
  }
  BaseResponseModel responseModel = await requestApi(PUBLISHCOMMENT, params);
  if (responseModel.isSuccess) {
    return responseModel.data;
  } else {
    return null;
  }
}

// 获取评论列表热度
Future<Map> queryListByHot2(
    {@required int targetId, @required int targetType, @required int page, @required int size}) async {
  Map<String, dynamic> params = {};
  params["targetId"] = targetId;
  params["targetType"] = targetType;
  params["page"] = page;
  params["size"] = size;
  BaseResponseModel responseModel = await requestApi(QUERYLISTBYHOT, params);
  if (responseModel.isSuccess) {
    return responseModel.data;
  } else {
    return null;
  }
}

// 更新获取评论列表热度接口返回数据方式
Future<List> queryListByHot(
    {@required int targetId, @required int targetType, @required int page, @required int size}) async {
  Map<String, dynamic> params = {};
  params["targetId"] = targetId;
  params["targetType"] = targetType;
  params["page"] = page;
  params["size"] = size;
  BaseResponseModel responseModel = await requestApi(QUERYLISTBYHOT, params);
  if (responseModel.isSuccess) {
    Map<String, dynamic> model = responseModel.data;
    List<CommentDtoModel> commentModelList = [];
    if (responseModel.data != null) {
      if (model["list"] is List && (model["list"] as List).isNotEmpty) {
        model["list"].forEach((v) {
          commentModelList.add(CommentDtoModel.fromJson(v));
        });
      }
      commentModelList.insert(0, CommentDtoModel());
      commentModelList[0].totalCount = model["totalCount"];
    }
    return commentModelList;
  } else {
    return null;
  }
}

// 获取评论列表时间
Future<Map> queryListByTime(
    {@required int targetId, @required int targetType, @required int page, @required int size}) async {
  Map<String, dynamic> params = {};
  params["targetId"] = targetId;
  params["targetType"] = targetType;
  params["page"] = page;
  params["size"] = size;
  BaseResponseModel responseModel = await requestApi(QUERYLISTBYTIME, params);
  if (responseModel.isSuccess) {
    return responseModel.data;
  } else {
    return null;
  }
}

// 删除评论
Future<Map> deleteComment({@required int commentId}) async {
  Map<String, dynamic> params = {};
  params["commentId"] = commentId;
  BaseResponseModel responseModel = await requestApi(DELETECOMMENT, params);
  if (responseModel.isSuccess) {
    return responseModel.data;
  } else {
    return null;
  }
}

// 评论点赞or取消赞
Future<Map> laudComment({@required int commentId, @required int laud}) async {
  Map<String, dynamic> params = {};
  params["commentId"] = commentId;
  params["laud"] = laud;
  BaseResponseModel responseModel = await requestApi(LAUDCOMMENT, params);
  if (responseModel.isSuccess) {
    return responseModel.data;
  } else {
    return null;
  }
}

//   动态点赞列表  GETFEEDLAUDLIST
Future<DataResponseModel> getFeedLaudList({@required int targetId}) async {
  Map<String, dynamic> params = {};
  params["targetId"] = targetId;
  BaseResponseModel responseModel = await requestApi(GETFEEDLAUDLIST, params);
  if (responseModel.isSuccess) {
    DataResponseModel dataResponseModel;
    if (responseModel.data != null) {
      dataResponseModel = DataResponseModel.fromJson(responseModel.data);
    }
    return dataResponseModel;
  } else {
    return null;
  }
}
// 首页推荐教练
Future<List> recommendCoach() async {
  BaseResponseModel responseModel = await requestApi(RECOMMENDCOACH, {});
  List<CourseDtoModel> courseList = [];
  if (responseModel.isSuccess) {
    DataResponseModel dataResponseModel;
    if (responseModel.data != null) {
      dataResponseModel = DataResponseModel.fromJson(responseModel.data);
      if (dataResponseModel.list.isNotEmpty) {
        dataResponseModel.list.forEach((v) {
          courseList.add(CourseDtoModel.fromJson(v));
        });
      }
    }
    return courseList;
  } else {
    return null;
  }
}