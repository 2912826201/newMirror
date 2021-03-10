import 'package:mirror/config/application.dart';
import 'package:mirror/data/model/base_response_model.dart';
import 'package:mirror/data/model/token_model.dart';

import 'api.dart';

/// basic_api
/// Created by yangjiayi on 2020/11/16.

const String LOGIN = "/uaa/oauth/login";
const String LOGOUT = "/uaa/oauth/logout";
const String SENDSMS = "/uaa/oauth/authentication/sms/send";

//登录以及刷新token
//grant_type说明 sms：验证码登录、qq：QQ登录、wechat：微信登录、apple：苹果登录、refresh_token：刷新token、anonymous：获取匿名token
Future<BaseResponseModel> login(String grant_type, String username, String code, String refresh_token) async {
  Map<String, dynamic> params = {};
  params["grant_type"] = grant_type;
  if (username != null) {
    params["username"] = username;
  }
  if (code != null) {
    params["code"] = code;
  }
  if (refresh_token != null) {
    params["refresh_token"] = refresh_token;
  }
  BaseResponseModel responseModel = await requestApi(LOGIN, params, authType: AUTH_TYPE_NONE);
  if (responseModel.isSuccess) {
    //TODO 这里实际需要将请求结果处理为具体的业务数据
    return responseModel;
  } else {
    //TODO 这里实际需要处理失败
    return null;
  }
}

//发送短信验证码
//type说明 0-登录验证码
Future<BaseResponseModel> sendSms(String phoneNumber, int type) async {
  BaseResponseModel responseModel = await requestApi(
      SENDSMS, {"phoneNumber": phoneNumber, "type": type, "anonymousToken": Application.token.accessToken},
      authType: AUTH_TYPE_NONE);
  if (responseModel.isSuccess) {
    //TODO 这里实际需要将请求结果处理为具体的业务数据
    return responseModel;
  } else {
    //TODO 这里实际需要处理失败
    return null;
  }
}

//登出
//token直接取accessToken不用拼接
Future<bool> logout() async {
  BaseResponseModel responseModel = await requestApi(LOGOUT, {"token": Application.token.accessToken},
      authType: AUTH_TYPE_NONE, autoHandleLogout: false);
  if (responseModel.isSuccess) {
    //TODO 这里实际需要将请求结果处理为具体的业务数据
    return responseModel.code == CODE_SUCCESS;
  } else {
    //TODO 这里实际需要处理失败
    return false;
  }
}
