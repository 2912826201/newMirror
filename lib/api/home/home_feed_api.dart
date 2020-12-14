import 'package:flutter/material.dart';
import 'package:mirror/api/api.dart';
import 'package:mirror/data/model/base_response_model.dart';

// 获取动态列表
const String PULLLISTFEED = "/appuser/web/feed/pullList";
//  发布动态
const String PUBLISHFEED = "/appuser/web/feed/publish";
// 动态点赞or取消赞
const String LAUDFEED = "/appuser/web/feed/laud";

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
//获取动态列表
Future<Map> getPullList({@required int type, @required int size, int targetId, int lastTime}) async {
  Map<String, dynamic> params = {};
  params["type"] = type;
  params["size"] = size;
  if (targetId != null) {
    params["targetId"] = targetId;
  }
  params["lastTime"] = lastTime;
  BaseResponseModel responseModel = await requestApi(PULLLISTFEED, params);
  if (responseModel.isSuccess) {
    return responseModel.data;
  } else {
    return null;
  }
}
// 文本检测
Future<Map> feedTextScan({@required String text}) async{
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
Future<Map> feedImageScan({@required String url}) async{
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
Future<Map> feedVideoScan({@required String url}) async{
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
    String topicId}) async {
  Map<String, dynamic> params = {};
  params["type"] = type;
  params["content"] = content;
  if (picUrls != "[]") {
    params["picUrls"] = picUrls;
  }
  if (videos != "[]") {
    params["videos"] = videos;
  }
  if (atUsers !=null) {
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
  if (topicId != null) {
    params["topicId"] = topicId;
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
    {@required int targetId,
    @required int targetType,
    @required String content,
    String picUrl,
    String atUsers,
    int replyId,
    int replyCommentId}) async {
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
Future<Map> queryListByHot(
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
