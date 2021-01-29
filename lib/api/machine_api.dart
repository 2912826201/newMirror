import 'package:mirror/data/model/base_response_model.dart';
import 'package:mirror/data/model/machine_model.dart';

import 'api.dart';

/// machine_api
/// Created by yangjiayi on 2021/1/29.

//登录机器
const String LOGINMACHINE = "/appuser/web/machine/login";
//获取机器状态信息
const String GETMACHINESTATUSINFO = "/appuser/web/machine/getStatusInfo";

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
Future<MachineModel> getMachineStatusInfo() async {
  Map<String, dynamic> params = {};
  BaseResponseModel responseModel = await requestApi(GETMACHINESTATUSINFO, params);
  if (responseModel.isSuccess) {
    MachineModel machine = MachineModel.fromJson(responseModel.data);
    return machine;
  } else {
    return null;
  }
}