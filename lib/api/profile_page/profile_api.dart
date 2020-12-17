
import 'package:mirror/data/model/base_response_model.dart';
import 'package:mirror/data/model/getExtrainfo_model.dart';
import 'package:mirror/data/model/profile_model.dart';
import 'package:mirror/data/model/user_model.dart';

import '../api.dart';

///关注接口
const String  ATTENTION= "/appuser/web/user/follow/addFollow";
///取消关注
const String CANCEL_ATTENTION = "/appuser/web/user/follow/removeFollow";
///获取用户关注相关【粉丝数、关注数、动态数】
const String GET_FOLLOWCOUNT = "/appuser/web/user/getFollowCount";
///获取用户训练记录
const String GET_EXTRAINFO = "/appuser/web/user/getExtraInfo";
///获取用户基础信息
const String GET_USERBASEINFO = "/ucenter/web/user/getUserBaseInfo";

Future<int> ProfileAttention(int id)async{
  BaseResponseModel responseModel = await requestApi(ATTENTION,{"id":id});
  int backCode;
  if (responseModel.isSuccess) {
    Map<String,dynamic> result = responseModel.data;
    if(result.isNotEmpty){
      backCode = result["relation"];
      return backCode;
    }
  } else {
    return null;
  }
}
Future<int> ProfileCancelAttention(int id)async{
  BaseResponseModel responseModel = await requestApi(CANCEL_ATTENTION, {"id":id});
  Map<String,dynamic> result = responseModel.data;
  int backCode;
  if (responseModel.isSuccess) {
    if(result.isNotEmpty){
     backCode = result["relation"];
      return backCode;
    }
  } else {
    return null;
  }
}
Future<ProfileModel> ProfileFollowCount({int id})async {
  Map<String,dynamic> parmas ={};
  if(id!=null){
    parmas["id"] = id;
  }
  BaseResponseModel responseModel = await requestApi(GET_FOLLOWCOUNT, parmas);
  if (responseModel.isSuccess) {
    return ProfileModel.fromJson(responseModel.data);
  } else {
    return null;
  }
}
Future<GetExtraInfoModel> ProfileGetExtraInfo()async {
  BaseResponseModel responseModel = await requestApi(GET_EXTRAINFO,{});
  if (responseModel.isSuccess) {
    return GetExtraInfoModel.fromJson(responseModel.data);
  } else {
    return null;
  }
}