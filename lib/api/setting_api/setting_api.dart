
import 'package:mirror/data/model/base_response_model.dart';
import 'package:mirror/data/model/profile/black_list_model.dart';
import 'package:mirror/data/model/user_notice_model.dart';
import '../api.dart';

///黑名单列表
const String BLACK_LIST ="/appuser/web/black/queryList";
///设置用户通知设置
const String SET_USER_NOTICE = "/appuser/web/user/setUserSetting";
///获取用户通知设置
const String GET_USER_NOTICE = "/appuser/web/user/getUserSetting";
///用户反馈
const String FEED_BACK = "/appuser/web/user/feedback";

///获取黑名单
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
///用户通知设置
Future<bool> setUserNotice(int type,int isOpen)async{
  BaseResponseModel responseModel = await requestApi(SET_USER_NOTICE,{"type":type,"isOpen":isOpen});
  Map<String, dynamic> result = responseModel.data;
  bool state;
    if(responseModel.isSuccess){
        state = result["state"];
        return state;
    }else{
      return null;
    }
}
///获取用户通知设置
Future<UserNoticeModel> getUserNotice()async{
  BaseResponseModel responseModel = await requestApi(GET_USER_NOTICE,{});
  if(responseModel.isSuccess){
    return UserNoticeModel.fromJson(responseModel.data);
  }else{
    return null;
  }
}
//反馈
Future<bool> putFeedBack(String content,String picUrls)async{
  BaseResponseModel responseModel = await requestApi(FEED_BACK,{"description":content,"picUrls":picUrls});
  if(responseModel.isSuccess&&responseModel.data!=null){
    print("==================这是接口请求成功的输出");
    return responseModel.data["state"];
  }else{
    print("==================这是接口请求失败的输出");
    return false;
  }
}

