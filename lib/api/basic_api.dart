import 'package:mirror/data/model/base_response_model.dart';
import 'package:mirror/data/model/token_model.dart';

import 'api.dart';

/// basic_api
/// Created by yangjiayi on 2020/11/16.

const String LOGIN = "/uaa/oauth/login";
const String SENDSMS = "/uaa/oauth/authentication/sms/send";

//登录以及刷新token
//grant_type说明 sms：验证码登录、qq：QQ登录、wechat：微信登录、apple：苹果登录、refresh_token：刷新token、anonymous：获取匿名token
Future<TokenModel> login(String grant_type, String username, String code, String refresh_token) async {
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
    return TokenModel.fromJson(responseModel.data);
  } else {
    //TODO 这里实际需要处理失败
    return null;
  }
}

//发送短信验证码
//type说明 0-登录验证码
Future<bool> sendSms(String phoneNumber, int type) async {
  BaseResponseModel responseModel =
      await requestApi(SENDSMS, {"phoneNumber": phoneNumber, "type": type}, authType: AUTH_TYPE_NONE);
  if (responseModel.isSuccess) {
    //TODO 这里实际需要将请求结果处理为具体的业务数据
    return responseModel.code == CODE_SUCCESS;
  } else {
    //TODO 这里实际需要处理失败
    return false;
  }
}
