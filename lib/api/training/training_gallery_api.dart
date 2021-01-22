import 'dart:convert';

import 'package:mirror/api/api.dart';
import 'package:mirror/data/model/base_response_model.dart';
import 'package:mirror/data/model/list_model.dart';
import 'package:mirror/data/model/training/training_gallery_model.dart';

const String GETALBUM = "/appuser/web/user/getAlbum";
const String SAVEALBUM = "/appuser/web/user/saveAlbum";
const String DELETEALBUM = "/appuser/web/user/deleteAlbum";

Future<ListModel<TrainingGalleryDayModel>> getAlbum(int size, {int lastTime}) async {
  BaseResponseModel responseModel = lastTime == null
      ? await requestApi(GETALBUM, {"size": size})
      : await requestApi(GETALBUM, {"lastTime": lastTime, "size": size});
  if (responseModel.isSuccess) {
    //TODO 这里实际需要将请求结果处理为具体的业务数据
    ListModel<TrainingGalleryDayModel> listModel = ListModel<TrainingGalleryDayModel>();
    listModel.hasNext = responseModel.data["hasNext"];
    listModel.lastTime = responseModel.data["lastTime"];
    if (responseModel.data["list"] != null) {
      listModel.list = [];
      responseModel.data["list"].forEach((v) {
        listModel.list.add(TrainingGalleryDayModel.fromJson(v));
      });
    }
    return listModel;
  } else {
    //TODO 这里实际需要处理失败
    return null;
  }
}

Future<List<TrainingGalleryImageModel>> saveAlbum(List<Map<String, dynamic>> imageList) async {
  BaseResponseModel responseModel = await requestApi(SAVEALBUM, {"albums": json.encode(imageList)});
  if (responseModel.isSuccess) {
    //TODO 这里实际需要将请求结果处理为具体的业务数据
    List<TrainingGalleryImageModel> resultList;
    if (responseModel.data["list"] != null) {
      resultList = [];
      responseModel.data["list"].forEach((v) {
        resultList.add(TrainingGalleryImageModel.fromJson(v));
      });
    }
    return resultList;
  } else {
    //TODO 这里实际需要处理失败
    return null;
  }
}

Future<bool> deleteAlbum(List<int> ids) async {
  BaseResponseModel responseModel = await requestApi(DELETEALBUM, {"ids": json.encode(ids)});
  if (responseModel.isSuccess) {
    //TODO 这里实际需要将请求结果处理为具体的业务数据
    bool result = false;
    if(responseModel.data["state"] == true){
      result = true;
    }
    return result;
  } else {
    //TODO 这里实际需要处理失败
    return null;
  }
}
