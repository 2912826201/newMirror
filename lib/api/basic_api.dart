import 'package:mirror/data/model/base_response_model.dart';
import 'package:mirror/data/model/token_model.dart';

import 'api.dart';

/// basic_api
/// Created by yangjiayi on 2020/11/16.

const String LOGIN = "/uaa/oauth/login";

Future<TokenModel> login(String grant_type, String username, String code, String refresh_token) async {
  BaseResponseModel responseModel = await requestApi(
      LOGIN, {"grant_type": grant_type, "username": username, "code": code, "refresh_token": refresh_token});
  if (responseModel.isSuccess) {
    //TODO 这里实际需要将请求结果处理为具体的业务数据
    return TokenModel.fromJson(responseModel.data);
  } else {
    //TODO 这里实际需要处理失败
    return null;
  }
}
