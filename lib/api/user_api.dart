import 'package:mirror/data/model/base_response_model.dart';
import 'package:mirror/data/model/user_model.dart';

import 'api.dart';

/// user_api
/// Created by yangjiayi on 2020/10/26.


//校验token
const String CHECKTOKEN = "/ucenter/web/user/isEffective";
//完善用户信息
const String PERFECTUSERINFO = "/ucenter/web/user/perfectUserInfo";
//获取用户信息
const String GETUSERINFO = "/appuser/web/user/getUserInfo";
//获取所有备注
const String GETREMARKBYUID = "/appuser/web/user/getRemarkByUid";
//二维码加入群聊
const String JOINGROUPCHATUNRESTRICTED = "/appuser/web/groupChat/joinGroupChatUnrestricted";
//获取用户基本信息
const String GETUSERBASEINFO = "/ucenter/web/user/getUserBaseInfo";
//登录教练端指令
const String LOGINCOACH = "/appuser/web/login/loginCoach";
//登录编辑器指令
const String LOGINEDITOR = "/appuser/web/login/loginEditor";
//校验token
Future<bool> checkToken() async {
  Map<String, dynamic> params = {};
  //无需自动处理未登录状态
  BaseResponseModel responseModel = await requestApi(CHECKTOKEN, params, autoHandleLogout: false);
  if (responseModel.isSuccess) {
    return responseModel.code == CODE_SUCCESS;
  } else {
    return false;
  }
}

///完善用户信息
Future<bool> perfectUserInfo(String nickName, String avatarUri) async {
  print("perfectUserInfo $nickName");
  BaseResponseModel responseModel =
      await requestApi(PERFECTUSERINFO, {"nickName": nickName, "avatarUri": avatarUri}, authType: AUTH_TYPE_TEMP);
  if (responseModel.isSuccess) {
    //TODO 这里实际需要将请求结果处理为具体的业务数据
    return responseModel.code == CODE_SUCCESS;
  } else {
    //TODO 这里实际需要处理失败
    return false;
  }
}

//获取用户信息 当获取自己的信息时uid可以不传
Future<UserModel> getUserInfo({int uid}) async {
  Map<String, dynamic> params = {};
  if (uid != null) {
    params["uid"] = uid;
  }
  BaseResponseModel responseModel = await requestApi(GETUSERINFO, params);
  if (responseModel.isSuccess) {
    //TODO 这里实际需要将请求结果处理为具体的业务数据
    return UserModel.fromJson(responseModel.data);
  } else {
    //TODO 这里实际需要处理失败
    return null;
  }
}


///解析短连接
Future<String> resolveShortUrl(String url) async {
  Map<String, dynamic> params = {};
  BaseResponseModel responseModel = await requestApi(url, params,requestMethod:METHOD_GET);
  if (responseModel.isSuccess) {
    if(responseModel.code == CODE_SUCCESS){
      return responseModel.data["uri"];
    } else {
      return null;
    }
  } else {
    return null;
  }
}

//二维码加入群聊
Future<Map> joinGroupChatUnrestricted(String code) async {
  Map<String, dynamic> params = {};
  params["code"] = code;
  BaseResponseModel responseModel = await requestApi(JOINGROUPCHATUNRESTRICTED, params);
  if (responseModel.isSuccess) {
    return responseModel.data;
  } else {
    return null;
  }
}

//获取用户基本信息 当获取自己的信息时uid可以不传
Future<UserModel> getUserBaseInfo({int uid}) async {
  Map<String, dynamic> params = {};
  if (uid != null) {
    params["uid"] = uid;
  }
  BaseResponseModel responseModel = await requestApi(GETUSERBASEINFO, params);
  if (responseModel.isSuccess) {
    //TODO 这里实际需要将请求结果处理为具体的业务数据
    return UserModel.fromJson(responseModel.data);
  } else {
    //TODO 这里实际需要处理失败
    return null;
  }
}

Future loginCoach(String coach)async{
  Map<String, dynamic> params = {};
  if (coach != null) {
    params["coach"] = coach;
  }
 await requestApi(LOGINCOACH,params);
}

Future loginEditor(String editor)async{
  Map<String, dynamic> params = {};
  if (editor != null) {
    params["editor"] = editor;
  }
  await requestApi(LOGINEDITOR,params);
}