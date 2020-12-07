
import 'package:dio/dio.dart';
import 'package:mirror/api/api.dart';
import 'package:mirror/data/model/base_response_model.dart';
import 'package:mirror/data/model/message/intercourse_model.dart';


const String UNREADCOUNT = "/appuser/web/message/getUnreadMsgCount";

Future<Unreads> getUnReads() async {
 BaseResponseModel responseModel = await requestApi(UNREADCOUNT, {});
 if (responseModel.isSuccess) {
   //TODO 这里实际需要将请求结果处理为具体的业务数据
   return Unreads.fromJson(responseModel.data);
 } else {
   //TODO 这里实际需要处理失败
   return null;
 }
}