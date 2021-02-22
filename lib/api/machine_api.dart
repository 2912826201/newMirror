import 'dart:convert';

import 'package:mirror/data/model/base_response_model.dart';
import 'package:mirror/data/model/machine_model.dart';

import 'api.dart';

/// machine_api
/// Created by yangjiayi on 2021/1/29.

//登录机器
const String LOGINMACHINE = "/appuser/web/machine/login";
//获取机器状态信息
const String GETMACHINESTATUSINFO = "/appuser/web/machine/getStatusInfo";
//与机器断开连接(登出)
const String LOGOUTMACHINE = "/appuser/web/machine/logout";
//给机器发送指令
const String SENDORDER = "/appuser/web/machine/order";

//登陆机器
Future<bool> loginMachine(int mid) async {
  Map<String, dynamic> params = {};
  params["machineId"] = mid;
  BaseResponseModel responseModel = await requestApi(LOGINMACHINE, params);
  if (responseModel.isSuccess) {
    return responseModel.code == CODE_SUCCESS;
  } else {
    return false;
  }
}

//获取机器状态信息
Future<List<MachineModel>> getMachineStatusInfo() async {
  Map<String, dynamic> params = {};
  BaseResponseModel responseModel = await requestApi(GETMACHINESTATUSINFO, params);
  if (responseModel.isSuccess) {
    List<MachineModel> list = [];
    if (responseModel.data["list"] != null) {
      responseModel.data["list"].forEach((element) {
        MachineModel model = MachineModel.fromJson(element);
        if (model != null && model.isConnect == 1) {
          list.add(model);
        }
      });
    }
    return list;
  } else {
    return null;
  }
}

//登出机器
Future<bool> logoutMachine(int mid) async {
  Map<String, dynamic> params = {};
  params["machineId"] = mid;
  BaseResponseModel responseModel = await requestApi(LOGOUTMACHINE, params);
  if (responseModel.isSuccess) {
    return responseModel.code == CODE_SUCCESS;
  } else {
    return false;
  }
}

//向机器发送指令 需要二次封装
Future<bool> _sendOrder(int machineId, String order, Map<String, dynamic> data) async {
  Map<String, dynamic> params = {};
  params["machineId"] = machineId;
  params["order"] = order;
  params["data"] = json.encode(data);

  BaseResponseModel responseModel = await requestApi(SENDORDER, params);
  if (responseModel.isSuccess) {
    return responseModel.code == CODE_SUCCESS;
  } else {
    return false;
  }
}

//设置亮度
Future<bool> setMachineLuminance(int machineId, int luminance) async {
  Map<String, dynamic> data = {};
  data["luminance"] = luminance;
  return _sendOrder(machineId, "Setting", data);
}

//设置音量
Future<bool> setMachineVolume(int machineId, int volume) async {
  Map<String, dynamic> data = {};
  data["volume"] = volume;
  return _sendOrder(machineId, "Setting", data);
}

//跳转到视频课详情页
Future<bool> openVideoCourseDetailPage(int machineId, int courseId) async {
  Map<String, dynamic> data = {};
  data["courseId"] = courseId;
  data["type"] = 1;
  return _sendOrder(machineId, "Detail", data);
}

//跳转到直播课详情页
Future<bool> openLiveCourseDetailPage(int machineId, int courseId, String startTime) async {
  Map<String, dynamic> data = {};
  data["courseId"] = courseId;
  data["type"] = 0;
  data["startTime"] = startTime;
  return _sendOrder(machineId, "Detail", data);
}

//开始视频课
Future<bool> startVideoCourse(int machineId, int courseId) async {
  Map<String, dynamic> data = {};
  data["courseId"] = courseId;
  data["type"] = 1;
  return _sendOrder(machineId, "Training", data);
}
