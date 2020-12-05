import 'package:flutter/material.dart';
import 'package:mirror/api/api.dart';
import 'package:mirror/data/model/base_response_model.dart';
// 获取动态列表
const String  PULLLIST = "/appuser/web/feed/pullList";
const String  LAUD ="/appuser/web/feed/laud";
//获取动态列表
Future <Map> getPullList({@required int type, @required int size , int targetId , int lastTime}) async{
  Map<String, dynamic> params = {};
  params["type"] = type;
  params["size"] = size;
  if (targetId != null) {
    params["targetId"] = targetId;
  }
  params["lastTime"] = lastTime;
  BaseResponseModel responseModel = await requestApi(PULLLIST, params);
  if (responseModel.isSuccess) {
    return responseModel.data;
  } else {
    return null;
  }
}
// 点赞/取消点赞
Future <Map> laud({@required int id, @required int laud}) async {
  Map<String, dynamic> params = {};
  params["id"] = id;
  params["laud"] = laud;
  BaseResponseModel responseModel = await requestApi(LAUD, params);
  if (responseModel.isSuccess) {
    return responseModel.data;
  } else {
    return null;
  }
}