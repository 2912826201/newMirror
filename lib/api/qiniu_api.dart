import 'dart:convert';

import 'package:mirror/data/model/base_response_model.dart';

import 'api.dart';

/// qiniu_api
/// Created by yangjiayi on 2020/11/13.

const String QINIU_GETTOKEN = "/resource/qiniu/getQiniuUpToken";

//0-文件 1-音视频 2-图片
Future<String> requestQiniuToken(int bucketType) async {
  BaseResponseModel responseModel = await requestApi(QINIU_GETTOKEN, {"bucketType": bucketType});
  if(responseModel.isSuccess){
    //TODO 这里实际需要将请求结果处理为具体的业务数据
    return json.encode(responseModel.data);
  }else {
    //TODO 这里实际需要处理失败
    return null;
  }
}
