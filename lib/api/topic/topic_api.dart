
import 'package:flutter/cupertino.dart';
import 'package:mirror/data/model/base_response_model.dart';
import 'package:mirror/data/model/data_response_model.dart';

import '../api.dart';

const String SEARCHTOPIC = "/appuser/web/topic/searchTopic";
//获取搜索话题列表
Future<DataResponseModel> searchTopic({@required String key, @required int size, double lastScore}) async {
  Map<String, dynamic> params = {};
  params["key"] = key;
  params["size"] = size;
  params["lastScore"] = lastScore;
  BaseResponseModel responseModel = await requestApi(SEARCHTOPIC, params);
  if (responseModel.isSuccess) {
    DataResponseModel  dataResponseModel;
    dataResponseModel = DataResponseModel.fromJson(responseModel.data);
    return dataResponseModel;
  } else {
    return null;
  }
}