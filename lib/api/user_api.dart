import 'package:mirror/data/model/base_response_model.dart';

import 'api.dart';

/// user_api
/// Created by yangjiayi on 2020/10/26.

const String PERFECT_USERINFO = "/ucenter/web/user/perfectUserInfo";
const String GET_USERINFO = "/appuser/web/user/getUserInfo";

//完善用户信息
Future<bool> perfectUserInfo(String nickName, String avatarUri) async {
  BaseResponseModel responseModel =
      await requestApi(PERFECT_USERINFO, {"nickName": nickName, "avatarUri": avatarUri}, authType: AUTH_TYPE_TEMP);
  if (responseModel.isSuccess) {
    //TODO 这里实际需要将请求结果处理为具体的业务数据
    return responseModel.code == CODE_SUCCESS;
  } else {
    //TODO 这里实际需要处理失败
    return false;
  }
}

//获取用户信息 当获取自己的信息时uid可以不传
Future<Map> getUserInfo({int uid}) async {
  Map<String, dynamic> params = {};
  if (uid != null) {
    params["uid"] = uid;
  }
  BaseResponseModel responseModel = await requestApi(GET_USERINFO, params);
  if (responseModel.isSuccess) {
    //TODO 这里实际需要将请求结果处理为具体的业务数据
    return responseModel.data;
  } else {
    //TODO 这里实际需要处理失败
    return null;
  }
}