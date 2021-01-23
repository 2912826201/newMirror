import 'package:flutter/cupertino.dart';
import 'package:mirror/data/model/base_response_model.dart';
import 'package:mirror/data/model/profile/training_record_model.dart';
import '../api.dart';

// 获取训练记录列表
const String GETTRAININGRECORDSLIST = "/appuser/web/training/getTrainingRecordsList";
// 获取训练记录总体信息
const String GETTRAININGRECORDS = "/appuser/web/training/getTrainingRecords";

// 保存目标体重
const String SAVETARGETWEIGHT = "/appuser/web/user/saveTargetWeight";

// 记录体重
const String SAVEWEIGHT = "/appuser/web/user/saveWeight";
// 获取体重
const String GETWEIGHTRECORDS = "/appuser/web/user/getWeightRecords";
// 删除体重记录
const String DELWEIGHT = "/appuser/web/user/delWeight";

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
//不传查询全部
Future<Map> getTrainingRecords({String startTime, String endTime}) async {
  Map<String, dynamic> params = {};
  if (startTime != null) {
    params["startTime"] = startTime;
  }
  if (endTime != null) {
    params["endTime"] = endTime;
  }
  BaseResponseModel responseModel = await requestApi(GETTRAININGRECORDS, params);
  if (responseModel.isSuccess) {
    return responseModel.data;
  } else {
    return null;
  }
}

// 保存目标体重
Future<Map> saveTargetWeight(String targetWeight) async {
  Map<String, dynamic> params = {};
  if (targetWeight != null) {
    params["targetWeight"] = targetWeight;
  }
  BaseResponseModel responseModel = await requestApi(SAVETARGETWEIGHT, params);
  if (responseModel.isSuccess) {
    return responseModel.data;
  } else {
    return null;
  }
}

// 记录体重
Future<Map> saveWeight(String weight) async {
  Map<String, dynamic> params = {};
  if (weight != null) {
    params["weight"] = weight;
  }
  BaseResponseModel responseModel = await requestApi(SAVEWEIGHT, params);
  if (responseModel.isSuccess) {
    return responseModel.data;
  } else {
    return null;
  }
}

// 获取体重
Future<Map> getWeightRecords(int page, int size) async {
  Map<String, dynamic> params = {};
  params["page"] = page;
  params["size"] = size;
  BaseResponseModel responseModel = await requestApi(GETWEIGHTRECORDS, params);
  if (responseModel.isSuccess) {
    return responseModel.data;
  } else {
    return null;
  }
}

// 删除体重
Future<Map> delWeight(int id) async {
  Map<String, dynamic> params = {};
  params["id"] = id;
  BaseResponseModel responseModel = await requestApi(DELWEIGHT, params);
  if (responseModel.isSuccess) {
    return responseModel.data;
  } else {
    return null;
  }
}
