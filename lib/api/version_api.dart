
import 'package:mirror/api/api.dart';
import 'package:mirror/data/model/base_response_model.dart';
import 'package:mirror/data/model/version_model.dart';

const String GET_NEW_VERSION = "/appuser/web/version/getLatestVersion";

Future<VersionModel> getNewVersion()async{
  BaseResponseModel responseModel =
    await requestApi(GET_NEW_VERSION, {});
  VersionModel model;
  if(responseModel.isSuccess){
    print('==============================版本接口请求成功');
    model = VersionModel.fromJson(responseModel.data);
    return model;
  }else{
    return null;
  }
}