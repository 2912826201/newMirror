import 'package:flutter/material.dart';
import 'package:mirror/api/api.dart';
import 'package:mirror/data/model/activity/activity_model.dart';
import 'package:mirror/data/model/base_response_model.dart';
import 'package:mirror/data/model/user_model.dart';

//获取推荐一起活动的用户列表
const String GETRECOMMENDUSERLIST = "/appuser/web/activity/getRecommendUserList";
//创建活动
const String CREATEACTIVITY = "/appuser/web/activity/create";

//创建活动
Future<ActivityModel> createActivity({
  @required String title,
  @required int type,
  @required int count,
  @required int startTime,
  @required int endTime,
  @required String cityCode,
  @required String address,
  @required String longitude,
  @required String latitude,
  @required int equipment,
  @required int auth,
  @required String pic,
  @required String description,
  String uids,
}) async {
  Map<String, dynamic> params = {};
  params["title"] = title;
  params["type"] = type;
  params["count"] = count;
  params["startTime"] = startTime;
  params["endTime"] = endTime;
  params["cityCode"] = cityCode;
  params["address"] = address;
  params["longitude"] = longitude;
  params["latitude"] = latitude;
  params["equipment"] = equipment;
  params["auth"] = auth;
  params["pic"] = pic;
  params["description"] = description;
  params["uids"] = uids;

  BaseResponseModel responseModel = await requestApi(CREATEACTIVITY, params);
  if (responseModel.isSuccess && responseModel.data != null) {
    return ActivityModel.fromJson(responseModel.data);
  } else {
    return null;
  }
}

//创建活动界面-获取推荐一起活动的用户列表
Future<List<UserModel>> getRecommendUserList({int size = 5}) async {
  Map<String, dynamic> params = {};
  params["size"] = size;
  BaseResponseModel responseModel = await requestApi(GETRECOMMENDUSERLIST, params);
  if (responseModel.isSuccess && responseModel.data != null) {
    List<UserModel> list = [];
    if (responseModel.data["list"] != null) {
      responseModel.data["list"].forEach((e) {
        if (e != null) {
          list.add(UserModel.fromJson(e));
        }
      });
    }
    return list;
  } else {
    return [];
  }
}
