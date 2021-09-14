import 'package:flutter/material.dart';
import 'package:mirror/api/api.dart';
import 'package:mirror/data/model/activity/activity_evaluate_model.dart';
import 'package:mirror/data/model/activity/activity_model.dart';
import 'package:mirror/data/model/base_response_model.dart';
import 'package:mirror/data/model/data_response_model.dart';
import 'package:mirror/data/model/user_model.dart';

//获取推荐一起活动的用户列表
const String GETRECOMMENDUSERLIST = "/appuser/web/activity/getRecommendUserList";
//创建活动
const String CREATEACTIVITY = "/appuser/web/activity/create";
//获取活动详情
const String GETACTIVITYDETAIL = "/appuser/web/activity/detail";
// 获取我参加过的活动列表
const String GETMYJOINACTIVITYLIST = "/appuser/web/activity/getMyJoinActivityList";
// 获取推荐活动列表
const String GETRECOMMENDACTIVITY = "/appuser/web/activity/getRecommendActivity";
// 移除活动成员
const String REMOVEMEMBER = "/appuser/web/activity/removeMember";
// 解散活动
const String DELETEACTIVITY = "/appuser/web/activity/delete";

// 申请加入活动
const String APPLYJOIN = "/appuser/web/activity/applyJoin";

// 申请列表
const String APPLYLIST = "/appuser/web/activity/applyList";

// 获取活动成员
const String GETACTIVITYMEMBERLIST = "/appuser/web/activity/getActivityMemberList";

// 获取活动用户申请列表
const String GETACTIVITYAPPLYLIST = "/appuser/web/activity/applyList";

// 同意申请
const String AUDITAPPLY = "/appuser/web/activity/auditApply";

// 邀请加入活动
const String INVITEACTIVITY = "/appuser/web/activity/invite";

// 通过邀请链接加入活动
const String JOINBYINVITATION = "/appuser/web/activity/JoinByInvitation";

// 发布评价
const String PUBLISHEVALUATE = "/appuser/web/activity/publishEvaluate";

// 活动签到
const String SIGNINACTIVITY = "/appuser/web/activity/signIn";

// 获取评价列表
const String GETEVALUATELIST = "/appuser/web/activity/getEvaluateList";

// 获取评价列表
const String UPDATEACTIVITY = "/appuser/web/activity/update";

// 退出活动
const String QUITACTIVITY = "/appuser/web/activity/quit";
// 获取活动用户申请列表未读数
const String APPLYLISTUNREAD = "/appuser/web/activity/applyListUnread";
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

//获取推荐活动列表
Future<DataResponseModel> getRecommendActivity(
    {int size = 20, double lastScore, int type, String cityCode, String longitude, String latitude}) async {
  Map<String, dynamic> params = {};
  params["size"] = size;
  if (lastScore != null) {
    params["lastScore"] = lastScore;
  }
  if (type != null) {
    params["type"] = type;
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
  BaseResponseModel responseModel = await requestApi(GETRECOMMENDACTIVITY, params);
  if (responseModel.isSuccess && responseModel.data != null) {
    DataResponseModel dataResponseModel = DataResponseModel();
    if (responseModel.data != null) {
      dataResponseModel = DataResponseModel.fromJson(responseModel.data);
    }
    return dataResponseModel;
  } else {
    return null;
  }
}

//获取活动详情
Future<ActivityModel> getActivityDetailApi(int activityId) async {
  Map<String, dynamic> params = {};
  params["id"] = activityId;
  BaseResponseModel responseModel = await requestApi(GETACTIVITYDETAIL, params);
  if (responseModel.isSuccess && responseModel.data != null) {
    return ActivityModel.fromJson(responseModel.data);
  } else {
    return null;
  }
}

//移除活动成员
Future<bool> removeMember(int activityId, String uids, String reason) async {
  Map<String, dynamic> params = {};
  params["activityId"] = activityId;
  params["uids"] = uids;
  params["reason"] = reason;
  BaseResponseModel responseModel = await requestApi(REMOVEMEMBER, params);
  if (responseModel.isSuccess && responseModel.data != null) {
    return responseModel.data["state"] ?? false;
  } else {
    return false;
  }
}

//解散活动
Future<List> deleteActivity(int activityId) async {
  Map<String, dynamic> params = {};
  params["activityId"] = activityId;
  BaseResponseModel responseModel = await requestApi(DELETEACTIVITY, params);
  if (responseModel.isSuccess && responseModel.data != null) {
    return [responseModel.data["state"] ?? false, responseModel.message];
  } else if (responseModel != null && responseModel.message != null) {
    return [false, responseModel.message];
  } else {
    return [false, "解散失败"];
  }
}

//申请加入活动
Future<List> applyJoinActivity(int activityId, String message) async {
  Map<String, dynamic> params = {};
  params["id"] = activityId;
  params["message"] = message;
  BaseResponseModel responseModel = await requestApi(APPLYJOIN, params);
  if (responseModel.isSuccess && responseModel.data != null) {
    return [responseModel.data["state"] ?? false, responseModel.message];
  } else if (responseModel != null && responseModel.message != null) {
    return [false, responseModel.message];
  } else {
    return [false, "申请失败"];
  }
}

//获取活动成员
Future<List<UserModel>> getActivityMemberList(int activityId, int size, int lastTime) async {
  Map<String, dynamic> params = {};
  params["activityId"] = activityId;
  params["size"] = size;
  if (lastTime != null) {
    params["lastTime"] = lastTime;
  }
  BaseResponseModel responseModel = await requestApi(GETACTIVITYMEMBERLIST, params);
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

//获取活动用户申请列表
//activityId 不传 是请求全部的活动的申请列表
//activityId 传了 是请求指定活动的申请列表
Future<DataResponseModel> getActivityApplyList(int activityId, int size, int lastId) async {
  Map<String, dynamic> params = {};
  if (activityId != null) {
    params["id"] = activityId;
  }
  params["size"] = size;
  if (lastId != null) {
    params["lastId"] = lastId;
  }
  BaseResponseModel responseModel = await requestApi(GETACTIVITYAPPLYLIST, params);
  if (responseModel.isSuccess && responseModel.data != null) {
    DataResponseModel dataResponseModel = DataResponseModel();
    if (responseModel.data != null) {
      dataResponseModel = DataResponseModel.fromJson(responseModel.data);
    }
    return dataResponseModel;
  } else {
    return null;
  }
}

//同意申请
Future<bool> auditApply(int id) async {
  Map<String, dynamic> params = {};
  params["id"] = id;
  BaseResponseModel responseModel = await requestApi(AUDITAPPLY, params);
  if (responseModel.isSuccess && responseModel.data != null) {
    return responseModel.data["state"] ?? false;
  } else {
    return false;
  }
}

//邀请加入活动
Future<List<String>> inviteActivity(int activityId, String uids) async {
  Map<String, dynamic> params = {};
  params["id"] = activityId;
  params["uids"] = uids;
  BaseResponseModel responseModel = await requestApi(INVITEACTIVITY, params);
  if (responseModel.isSuccess && responseModel.data != null && responseModel.data["list"] != null) {
    List<String> data = [];
    try {
      responseModel.data["list"].forEach((value) {
        data.add(value.toString());
      });
    } catch (e) {}
    return data;
  } else {
    return [];
  }
}

//通过邀请链接加入活动
Future<List> joinByInvitation(int activityId, int inviterId) async {
  Map<String, dynamic> params = {};
  params["id"] = activityId;
  params["inviterId"] = inviterId;
  BaseResponseModel responseModel = await requestApi(JOINBYINVITATION, params);
  if (responseModel.isSuccess && responseModel.data != null) {
    return [responseModel.data["state"] ?? false, responseModel.message];
  } else if (responseModel != null && responseModel.message != null) {
    return [false, responseModel.message];
  } else {
    return [false, "参加失败"];
  }
}

//发布评价
Future<List> publishEvaluate(int activityId, double score, String content) async {
  Map<String, dynamic> params = {};
  params["activityId"] = activityId;
  params["score"] = score;
  params["content"] = content;
  BaseResponseModel responseModel = await requestApi(PUBLISHEVALUATE, params);
  if (responseModel.isSuccess && responseModel.data != null) {
    return [responseModel.data["AVGScore"] ?? -1.0, "", responseModel.message];
  } else if (responseModel != null && responseModel.message != null) {
    return [-1.0, responseModel.message];
  } else {
    return [-1.0, "发布失败"];
  }
}

//活动签到
Future<bool> signInActivity(int activityId, String longitude, String latitude) async {
  Map<String, dynamic> params = {};
  params["activityId"] = activityId;
  params["longitude"] = longitude;
  params["latitude"] = latitude;
  BaseResponseModel responseModel = await requestApi(SIGNINACTIVITY, params);
  if (responseModel.isSuccess && responseModel.data != null) {
    return responseModel.data["state"] ?? false;
  } else {
    return false;
  }
}

//获取评价列表
Future<DataResponseModel> getEvaluateList(int activityId, {int size = 2, int lastTime}) async {
  Map<String, dynamic> params = {};
  params["activityId"] = activityId;
  params["size"] = size;
  if (lastTime != null) {
    params["lastTime"] = lastTime;
  }
  BaseResponseModel responseModel = await requestApi(GETEVALUATELIST, params);
  if (responseModel.isSuccess && responseModel.data != null) {
    DataResponseModel dataResponseModel = DataResponseModel();
    if (responseModel.data != null) {
      dataResponseModel = DataResponseModel.fromJson(responseModel.data);
    }
    return dataResponseModel;
  } else {
    return null;
  }
}

//修改活动
Future<List> updateActivity(
    int activityId, int count, String cityCode, String address, String longitude, String latitude) async {
  Map<String, dynamic> params = {};
  params["id"] = activityId;
  if (count != null) {
    params["count"] = count;
  }
  if (cityCode != null) {
    params["cityCode"] = cityCode;
  }
  if (address != null) {
    params["address"] = address;
  }
  if (longitude != null) {
    params["longitude"] = longitude;
  }
  if (latitude != null) {
    params["latitude"] = latitude;
  }
  BaseResponseModel responseModel = await requestApi(UPDATEACTIVITY, params);
  if (responseModel.isSuccess && responseModel.data != null) {
    try {
      return [true, "修改成功", ActivityModel.fromJson(responseModel.data)];
    } catch (e) {
      return [false, responseModel.message];
    }
  } else if (responseModel != null && responseModel.message != null) {
    return [false, responseModel.message];
  } else {
    return [false, "修改失败"];
  }
}

// 获取我参加过的活动列表
Future<DataResponseModel> getMyJoinActivityList({int size = 20, int lastTime}) async {
  Map<String, dynamic> params = {};
  params["size"] = size;
  if (lastTime != null) {
    params["lastTime"] = lastTime;
  }
  BaseResponseModel responseModel = await requestApi(GETMYJOINACTIVITYLIST, params);
  if (responseModel.isSuccess && responseModel.data != null) {
    DataResponseModel dataResponseModel = DataResponseModel();
    if (responseModel.data != null) {
      dataResponseModel = DataResponseModel.fromJson(responseModel.data);
    }
    return dataResponseModel;
  } else {
    return null;
  }
}

// 获取我参加过的活动列表
Future<bool> quitActivity(int activityId) async {
  Map<String, dynamic> params = {};
  params["activityId"] = activityId;
  BaseResponseModel responseModel = await requestApi(QUITACTIVITY, params);
  if (responseModel.isSuccess && responseModel.data != null) {
    return responseModel.data["state"] ?? false;
  } else {
    return false;
  }
}

// 获取活动用户申请列表未读数
Future<int> applyListUnread() async {
  Map<String, dynamic> params = {};
  int unread = 0;
  BaseResponseModel responseModel = await requestApi(APPLYLISTUNREAD, params);
  if (responseModel.isSuccess && responseModel.data != null) {
    unread = responseModel.data["applyListUnread"];
    return unread;
  } else {
    return unread;
  }
}
