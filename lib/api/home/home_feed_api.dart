import 'package:flutter/material.dart';
import 'package:mirror/api/api.dart';
import 'package:mirror/data/model/base_response_model.dart';

const String  PULLLIST = "/appuser/web/feed/pullList";
//获取动态列表
Future <Map> getPullList({@required int type, @required int size , int targetId , int lastTime}) async{
  Map<String, dynamic> params = {};
  params["type"] = type;
  params["size"] = size;
  if (targetId != null) {
    params["targetId"] = targetId;
  }
  if (lastTime != null) {
    params["lastTime"] = lastTime;
  }
  BaseResponseModel responseModel = await requestApi(PULLLIST, params);
  if (responseModel.isSuccess) {
    return responseModel.data;
  } else {
    return null;
  }
}