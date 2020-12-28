
import 'package:mirror/data/model/base_response_model.dart';
import 'package:mirror/data/model/profile/black_list_model.dart';
import '../api.dart';

///黑名单列表
const String BLACK_LIST ="/appuser/web/black/queryList";
Future<List<BlackListModel>> SettingBlackList()async{
  BaseResponseModel responseModel = await requestApi(BLACK_LIST,{});
  if(responseModel.isSuccess){
    List<BlackListModel> list;
    responseModel.data.forEach((key, value) {
      list.add(BlackListModel.fromJson(value));
    });
    return list;
  }else{
    return null;
  }
}

