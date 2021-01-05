
import 'package:mirror/data/model/base_response_model.dart';
import 'package:mirror/data/model/profile/black_list_model.dart';
import '../api.dart';

///黑名单列表
const String BLACK_LIST ="/appuser/web/black/queryList";
Future<BlackListModel> SettingBlackList()async{
  BaseResponseModel responseModel = await requestApi(BLACK_LIST,{});
  if(responseModel.isSuccess){
    BlackListModel model;
    model = BlackListModel.fromJson(responseModel.data);
    return model;
  }else{
    return null;
  }
}

