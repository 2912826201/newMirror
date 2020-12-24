
import 'package:mirror/data/model/add_remarks_model.dart';
import 'package:mirror/data/model/base_response_model.dart';
import 'package:mirror/data/model/black_model.dart';
import 'package:mirror/data/model/user_extrainfo_model.dart';
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
///添加备注，取消备注
const String ADD_REMARKS = "/appuser/web/user/addRemark";
///拉黑
const String ADD_BLACK = "/appuser/web/black/addBlack";
///取消拉黑
const String CANCEL_BLACK = "/appuser/web/black/removeBlack";
///检测拉黑关系
const String CHECK_BLACK = "/appuser/web/black/checkBlack";
///黑名单
const String QUERY_BLACKLIST = "/appuser/web/black/queryList";
///举报
const String DENOUNCE ="/appuser/web/user/denounce";
///更新用户信息
const String UPDATA_USERINFO = "/ucenter/web/user/updateUserInfo";
///关注
Future<int> ProfileAddFollow(int id)async{
  BaseResponseModel responseModel = await requestApi(ATTENTION,{"targetId":id});
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
///取消关注
Future<int> ProfileCancelFollow(int id)async{
  BaseResponseModel responseModel = await requestApi(CANCEL_ATTENTION, {"targetId":id});
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
///获取关注、粉丝、动态数
Future<ProfileModel> ProfileFollowCount({int id})async {
  Map<String,dynamic> parmas ={};
  if(id!=null){
    parmas["uid"] = id;
  }
  BaseResponseModel responseModel = await requestApi(GET_FOLLOWCOUNT, parmas);
  if (responseModel.isSuccess) {
    return ProfileModel.fromJson(responseModel.data);
  } else {
    return null;
  }
}
///获取用户训练信息
Future<UserExtraInfoModel> ProfileGetExtraInfo()async {
  BaseResponseModel responseModel = await requestApi(GET_EXTRAINFO,{});
  if (responseModel.isSuccess) {
    return UserExtraInfoModel.fromJson(responseModel.data);
  } else {
    return null;
  }
}
///修改删除备注
Future<AddRemarksModel> ChangeAddRemarks(int toUid,{String remark})async{
  Map<String,dynamic> parmas = {};
  if(remark!=null){
    parmas["remark"] = remark;
  }
  parmas["toUid"] = toUid;
  BaseResponseModel responseModel = await requestApi(ADD_REMARKS,parmas);
  if(responseModel.isSuccess){
    return AddRemarksModel.fromJson(responseModel.data);
  }else{
    return null;
  }
}

///添加黑名单
Future<bool> ProfileAddBlack(int blackId)async{
  BaseResponseModel responseModel = await requestApi(ADD_BLACK,{"blackId":blackId});
    bool backResult;
    if(responseModel.isSuccess){
      Map<String,dynamic> parmas = responseModel.data;
      backResult = parmas["state"];
      return backResult;
    }else{
      return null;
    }
}
///取消拉黑
Future<bool> ProfileCancelBlack(int blackId)async{
  BaseResponseModel responseModel = await requestApi(CANCEL_BLACK,{"blackId":blackId});
  bool backResult;
  if(responseModel.isSuccess){
    Map<String,dynamic> parmas = responseModel.data;
    backResult = parmas["state"];
    return backResult;
  }else{
    return null;
  }
}
///检测黑名单关系
Future<BlackModel> ProfileCheckBlack(int checkId)async {
  BaseResponseModel responseModel = await requestApi(CHECK_BLACK,{"checkId":checkId});
  if (responseModel.isSuccess) {
    return BlackModel.fromJson(responseModel.data);
  } else {
    return null;
  }
}
Future<bool> ProfileMoreDenounce(int targetId,int targetType)async{
  BaseResponseModel responseModel = await requestApi(CHECK_BLACK,{"targetId":targetId,"targetType":targetType,});
    if(responseModel.isSuccess){
      return true;
    }else{
      return false;
    }
}
Future<UserModel> ProfileUpdataUserInfo(String nickName,String avatarUri,{String description,int sex,String birthday,String cityCode,double longitude,String latitude})async {
  Map<String,dynamic> map = Map();
  map["nickName"] =nickName ;
  map["avatarUri"] = avatarUri;
  if(description!=null){
    map["description"] = description;
  }if(sex!=null){
    map["sex"] = sex;
  }if(birthday!=null){
    map["birthday"] = birthday;
  }if(cityCode!=null){
    map["cityCode"] = cityCode;
  }if(longitude!=null){
    map["longitude"] = longitude;
  }if(latitude!=null){
    map["latitude"] = latitude;
  }
  BaseResponseModel responseModel = await requestApi(UPDATA_USERINFO,map);
  if (responseModel.isSuccess) {
    UserModel model = UserModel.fromJson(responseModel.data);
    return model;
  } else {
    return null;
  }
}
