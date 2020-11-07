import 'dart:convert';

import 'package:mirror/data/model/base_response_model.dart';

import 'api.dart';

/// user_api
/// Created by yangjiayi on 2020/10/26.

const String USER_SEARCH = "/app/web/user/search";

Future<String> requestUserSearch(String key, int size, bool requestNext) async {
  BaseResponseModel responseModel = await requestApi(USER_SEARCH, {"key": key, "size": size, "requestNext": requestNext ? 1 : 0});
  if(responseModel.isSuccess){
    //TODO 这里实际需要将请求结果处理为具体的业务数据
    return json.encode(responseModel.data);
  }else {
    //TODO 这里实际需要处理失败
    return null;
  }
}
