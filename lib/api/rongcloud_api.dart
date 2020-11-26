import 'package:mirror/data/model/base_response_model.dart';

import 'api.dart';

/// rongcloud_api
/// Created by yangjiayi on 2020/11/26.

const String RONGCLOUD_GETTOKEN = "/third/rongcloud/getRongCloudToken";

Future<String> requestRongCloudToken() async {
  BaseResponseModel responseModel = await requestApi(RONGCLOUD_GETTOKEN, {});
  if(responseModel.isSuccess){
    //TODO 这里实际需要将请求结果处理为具体的业务数据
    String token = responseModel.data["token"];
    return token;
  }else {
    //TODO 这里实际需要处理失败
    return null;
  }
}
