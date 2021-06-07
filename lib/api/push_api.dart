import 'package:mirror/data/model/base_response_model.dart';

import 'api.dart';

/// push_api
/// Created by yangjiayi on 2021/6/7.

const String PUSH_UPLOADDEVICEID = "/app/web/push/uploadDeviceId";

Future<bool> uploadDeviceId(String deviceId) async {
  BaseResponseModel responseModel = await requestApi(PUSH_UPLOADDEVICEID, {"deviceId": deviceId});
  if(responseModel.isSuccess && responseModel.code == CODE_SUCCESS){
    return true;
  }else {
    return false;
  }
}