
import 'package:flutter/cupertino.dart';
import 'package:mirror/data/model/base_response_model.dart';
import 'package:mirror/data/model/data_response_model.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/profile/topic_list_model.dart';
import 'package:mirror/page/feed/release_page.dart';

import '../api.dart';
//获取搜索话题列表
const String SEARCHTOPIC = "/appuser/web/topic/searchTopic";
// //获取推荐话题列表
const String GETRECOMMENDTOPIC = "/appuser/web/topic/getRecommendTopic";
// // 话题详情
const String GETTOPICINFO = "/appuser/web/topic/getTopicInfo";
// 关注话题
const String FOLLOWTOPIC = "/appuser/web/topic/follow";
//获取话题动态列表
const String PULLTOPICLIST = "/appuser/web/feed/pullTopicList";
// 取消关注话题
const String CANCELFOLLOWTOPIC = "/appuser/web/topic/cancelFollow";
//获取搜索话题列表
Future<DataResponseModel> searchTopic({@required String key, @required int size, double lastScore}) async {
  Map<String, dynamic> params = {};
  params["key"] = key;
  params["size"] = size;
  params["lastScore"] = lastScore;
  BaseResponseModel responseModel = await requestApi(SEARCHTOPIC, params);
  if (responseModel.isSuccess) {
    DataResponseModel  dataResponseModel;
    if (responseModel.data != null ) {
      dataResponseModel = DataResponseModel.fromJson(responseModel.data);
    }
    return dataResponseModel;
  } else {
    return null;
  }
}
//获取推荐话题列表
Future<DataResponseModel> getRecommendTopic({@required int size}) async {
  Map<String, dynamic> params = {};
  params["size"] = size;
  BaseResponseModel responseModel = await requestApi(GETRECOMMENDTOPIC, params);
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
// 获取话题详情 GETTOPICINFO
Future<TopicDtoModel> getTopicInfo({@required int topicId}) async {
  Map<String, dynamic> params = {};
  params["topicId"] = topicId;
  BaseResponseModel responseModel = await requestApi(GETTOPICINFO, params);
  if (responseModel.isSuccess) {
    TopicDtoModel model;
    if (responseModel.data != null ) {
      model = TopicDtoModel.fromJson(responseModel.data);
    }
    return model;
  } else {
    return null;
  }
}
// 关注话题 FOLLOWTOPIC
Future<Map> followTopic({@required int topicId,}) async {
  Map<String, dynamic> params = {};
  params["topicId"] = topicId;
  BaseResponseModel responseModel = await requestApi(FOLLOWTOPIC, params);
  if (responseModel.isSuccess) {
    return responseModel.data;
  } else {
    return null;
  }
}
// 取消关注话题 CANCELFOLLOWTOPIC
Future<Map> cancelFollowTopic({@required int topicId}) async {
  Map<String, dynamic> params = {};
  params["topicId"] = topicId;
  BaseResponseModel responseModel = await requestApi(CANCELFOLLOWTOPIC, params);
  if (responseModel.isSuccess) {
    return responseModel.data;
  } else {
    return null;
  }
}

//   PULLTOPICLIST
Future<DataResponseModel> pullTopicList({@required int type,@required int size, int targetId,int lastTime}) async {
  Map<String, dynamic> params = {};
  params["type"] = type;
  params["size"] = size;
  if (targetId != null) {
    params["targetId"] = targetId;
  }
  if(lastTime!=null) {
    params["lastTime"] = lastTime;
  }
  BaseResponseModel responseModel = await requestApi(PULLTOPICLIST, params);
  if (responseModel.isSuccess) {
    DataResponseModel dataResponseModel = DataResponseModel();
    if (responseModel.data != null) {
      dataResponseModel = DataResponseModel.fromJson(responseModel.data);
    }
    return dataResponseModel;
  } else {
    return null;
  }
}