
import 'package:flutter/cupertino.dart';
import 'package:mirror/data/model/base_response_model.dart';
import 'package:mirror/data/model/data_response_model.dart';
import 'package:mirror/data/model/home/home_feed.dart';

import '../api.dart';
//获取搜索话题列表
const String SEARCHTOPIC = "/appuser/web/topic/searchTopic";
//获取推荐话题列表
const String GETRECOMMENDTOPIC = "/appuser/web/topic/getRecommendTopic";
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
Future<List> getRecommendTopic({@required int size}) async {
  Map<String, dynamic> params = {};
  params["size"] = size;
  BaseResponseModel responseModel = await requestApi(GETRECOMMENDTOPIC, params);
  List<TopicDtoModel> topicModelList = [];
  if (responseModel.isSuccess) {
    DataResponseModel  dataResponseModel;
    if (responseModel.data != null) {
      dataResponseModel = DataResponseModel.fromJson(responseModel.data);
      if (dataResponseModel.list.isNotEmpty) {
        dataResponseModel.list.forEach((v) {
          topicModelList.add(TopicDtoModel.fromJson(v));
        });
      }
    }
    return topicModelList;
  } else {
    return null;
  }
}