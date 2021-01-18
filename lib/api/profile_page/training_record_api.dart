import 'package:flutter/cupertino.dart';
import 'package:mirror/data/model/base_response_model.dart';
import '../api.dart';

// 获取训练记录列表
const String GETTRAININGRECORDSLIST = "/appuser/web/training/getTrainingRecordsList";
// 获取训练记录总体信息
const String GETTRAININGRECORDS = "/appuser/web/training/getTrainingRecords";

// 获取训练记录列表
Future<Map> getTrainingRecordsList({@required int startTime, @required int endTime}) async {
  Map<String, dynamic> params = {};
  params["startTime"] = startTime;
  params["endTime"] = endTime;
  BaseResponseModel responseModel = await requestApi(GETTRAININGRECORDSLIST, params);
  if (responseModel.isSuccess) {
    return responseModel.data;
  } else {
    return null;
  }
}

// 获取训练记录总体信息
Future<Map> getTrainingRecords({@required int startTime, @required int endTime}) async {
  Map<String, dynamic> params = {};
  params["startTime"] = startTime;
  params["endTime"] = endTime;
  BaseResponseModel responseModel = await requestApi(GETTRAININGRECORDS, params);
  if (responseModel.isSuccess) {
    return responseModel.data;
  } else {
    return null;
  }
}
