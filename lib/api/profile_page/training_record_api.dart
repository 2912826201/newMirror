import 'package:flutter/cupertino.dart';
import 'package:mirror/data/model/base_response_model.dart';
import 'package:mirror/data/model/profile/training_record_model.dart';
import '../api.dart';

// 获取训练记录列表
const String GETTRAININGRECORDSLIST = "/appuser/web/training/getTrainingRecordsList";
// 获取训练记录总体信息
const String GETTRAININGRECORDS = "/appuser/web/training/getTrainingRecords";

// 获取训练记录列表
Future<List<TrainingRecordModel>> getTrainingRecordsList({@required String startTime, @required String endTime}) async {
  List<TrainingRecordModel> recordModelList = <TrainingRecordModel>[];
  Map<String, dynamic> params = {};
  params["startTime"] = startTime;
  params["endTime"] = endTime;
  BaseResponseModel responseModel = await requestApi(GETTRAININGRECORDSLIST, params);
  if (responseModel.isSuccess) {
    if (responseModel.data != null && responseModel.data["list"] != null) {
      responseModel.data["list"].forEach((v) {
        recordModelList.add(TrainingRecordModel.fromJson(v));
      });
    }
    return recordModelList;
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
