import 'package:flutter/cupertino.dart';
import 'package:mirror/api/api.dart';
import 'package:mirror/data/model/message/group_chat_model.dart';
import 'package:mirror/data/model/base_response_model.dart';
import 'package:mirror/data/model/message/message_model.dart';

const String GET_UNREAD_COUNT = "/appuser/web/message/getUnreadMsgCount";
const String CREATE_GROUP_CHAT = "/appuser/web/groupChat/create";

//获取群成员列表
const String GETMEMBERS = "/appuser/web/groupChat/member/getMembers";
//根据群聊id获取群聊信息
const String GETGROUPCHATBYIDS = "/appuser/web/groupChat/getGroupChatByIds";
//修改群名
const String MODIFY = "/appuser/web/groupChat/modify";
//修改群昵称
const String MODIFYNICKNAME = "/appuser/web/groupChat/member/modifyNickName";
//退出群聊
const String EXITGROUPCHAT = "/appuser/web/groupChat/exitGroupChat";
//群聊列表
const String GETGROUPCHATLIST = "/appuser/web/groupChat/getGroupChatList";
//踢出群聊
const String KICKEDGROUPCHAT = "/appuser/web/groupChat/kickedGroupChat";
//邀请加入
const String INVITEJOIN = "/appuser/web/groupChat/inviteJoin";
//置顶聊天
const String STICKCHAT = "/appuser/web/groupChat/stickChat";
//获取置顶聊天列表
const String GETTOPCHATLIST = "/appuser/web/groupChat/getTopChatList";
//取消置顶
const String CANCELTOPCHAT = "/appuser/web/groupChat/cancelTopChat";
//添加消息免打扰
const String ADDNOPROMPT = "/appuser/web/black/addNoPrompt";
//取消消息免打扰
const String REMOVENOPROMPT = "/appuser/web/black/removeNoPrompt";
//查询是否免打扰
const String QUERYISNOPROMPT = "/appuser/web/black/queryIsNoPrompt";
//查询免打扰列表
const String QUERYNOPROMPTUIDLIST = "/appuser/web/black/queryNoPromptUidList";
//更新未读消息为已读
const String REFREASHMSGUNREAD = "/appuser/web/message/updateUnreadMsgToRead";

//获取系统消息
const String QUERYSYSMSGLIST = "/appuser/web/message/querySysMsgList";

Future<Unreads> getUnReads() async {
  BaseResponseModel responseModel = await requestApi(GET_UNREAD_COUNT, {});
  if (responseModel.isSuccess) {
    //TODO 这里实际需要将请求结果处理为具体的业务数据
    return Unreads.fromJson(responseModel.data);
  } else {
    //TODO 这里实际需要处理失败
    return null;
  }
}

//请求创建群聊
Future<GroupChatModel> createGroupChat(List<String> members) async {
  print("createGroupChat");
  final String parameterName = "uids";
  print("members is $members");
  Map<String, dynamic> parameters = Map();
  String membersStringPre = "[";
  String membersStringSuffix = "]";
  members.forEach((element) {
    membersStringPre = membersStringPre + "$element,";
  });
  membersStringPre = membersStringPre.substring(0, membersStringPre.length - 1);
  parameters[parameterName] = membersStringPre + membersStringSuffix;
  print("final parameters: ${parameters.toString()}");
  BaseResponseModel responseModel = await requestApi(CREATE_GROUP_CHAT, parameters);
  if (responseModel.isSuccess) {
    print("request success");
    print(responseModel.data);
    return GroupChatModel.fromJson(responseModel.data);
  } else {
    print("失败");
    return null;
  }
}

///获取群成员列表
///请求参数
///groupChatId:群id
Future<Map> getMembers({@required int groupChatId}) async {
  Map<String, dynamic> params = {};
  params["groupChatId"] = groupChatId;
  BaseResponseModel responseModel = await requestApi(GETMEMBERS, params);
  if (responseModel.isSuccess) {
    return responseModel.data;
  } else {
    return null;
  }
}

///根据群聊id获取群聊信息
///请求参数
///groupChatId:群id
Future<Map> getGroupChatByIds({@required int id}) async {
  Map<String, dynamic> params = {};
  params["ids"] = id;
  BaseResponseModel responseModel = await requestApi(GETGROUPCHATBYIDS, params);
  if (responseModel.isSuccess) {
    return responseModel.data;
  } else {
    return null;
  }
}

///修改群名
///请求参数
///groupChatId:群id
///newName:新群名
Future<Map> modify(
    {@required int groupChatId, @required String newName}) async {
  Map<String, dynamic> params = {};
  params["groupChatId"] = groupChatId;
  params["newName"] = newName;
  BaseResponseModel responseModel = await requestApi(MODIFY, params);
  if (responseModel.isSuccess) {
    return responseModel.data;
  } else {
    return null;
  }
}

///修改群名
///请求参数
///groupChatId:群id
///newName:新群昵称
Future<Map> modifyNickName({@required int groupChatId, @required String newName}) async {
  Map<String, dynamic> params = {};
  params["groupChatId"] = groupChatId;
  params["newName"] = newName;
  BaseResponseModel responseModel = await requestApi(MODIFYNICKNAME, params);
  if (responseModel.isSuccess) {
    return responseModel.data;
  } else {
    return null;
  }
}

///退出群聊
///请求参数
///groupChatId:群id
///newName:新群昵称
Future<Map> exitGroupChat({@required int groupChatId}) async {
  Map<String, dynamic> params = {};
  params["groupChatId"] = groupChatId;
  BaseResponseModel responseModel = await requestApi(EXITGROUPCHAT, params);
  if (responseModel.isSuccess) {
    return responseModel.data;
  } else {
    return null;
  }
}

///获取群聊列表
///请求参数
///groupChatId:群id
///newName:新群昵称
Future<Map> getGroupChatList() async {
  Map<String, dynamic> params = {};
  BaseResponseModel responseModel = await requestApi(GETGROUPCHATLIST, params);
  if (responseModel.isSuccess) {
    return responseModel.data;
  } else {
    return null;
  }
}

///踢出群聊--只有群主能踢人
///请求参数
///groupChatId:群id
///uid:用户id
Future<Map> kickedGroupChat({int groupChatId, String uids}) async {
  Map<String, dynamic> params = {};
  params["uids"] = uids;
  params["groupChatId"] = groupChatId;
  BaseResponseModel responseModel = await requestApi(KICKEDGROUPCHAT, params);
  if (responseModel.isSuccess) {
    return responseModel.data;
  } else {
    return null;
  }
}

///邀请加入群聊
///请求参数
///groupChatId:群id
///uids:1000000,1013036用户id字符串，以逗号隔开
Future<Map> inviteJoin({int groupChatId, String uids}) async {
  Map<String, dynamic> params = {};
  params["uids"] = uids;
  params["groupChatId"] = groupChatId;
  BaseResponseModel responseModel = await requestApi(INVITEJOIN, params);
  if (responseModel.isSuccess) {
    return responseModel.data;
  } else {
    return null;
  }
}

///置顶聊天
///请求参数
///targetId:群聊id/私聊id
///type:0-私聊 1-群聊
Future<Map> stickChat({int targetId, int type}) async {
  Map<String, dynamic> params = {};
  params["targetId"] = targetId;
  params["type"] = type;
  BaseResponseModel responseModel = await requestApi(STICKCHAT, params);
  if (responseModel.isSuccess) {
    return responseModel.data;
  } else {
    return null;
  }
}

///获取置顶聊天列表
///请求参数
Future<Map> getTopChatList() async {
  Map<String, dynamic> params = {};
  BaseResponseModel responseModel = await requestApi(GETTOPCHATLIST, params);
  if (responseModel.isSuccess) {
    return responseModel.data;
  } else {
    return null;
  }
}

///取消置顶
///请求参数
///targetId:群聊id/私聊id
///type:0-私聊 1-群聊
Future<Map> cancelTopChat({int targetId, int type}) async {
  Map<String, dynamic> params = {};
  params["targetId"] = targetId;
  params["type"] = type;
  BaseResponseModel responseModel = await requestApi(CANCELTOPCHAT, params);
  if (responseModel.isSuccess) {
    return responseModel.data;
  } else {
    return null;
  }
}

///消息免打扰
///请求参数
///targetId:群聊id/私聊id
Future<Map> addNoPrompt({int targetId, int type}) async {
  Map<String, dynamic> params = {};
  params["targetId"] = targetId;
  params["type"] = type;
  BaseResponseModel responseModel = await requestApi(ADDNOPROMPT, params);
  if (responseModel.isSuccess) {
    return responseModel.data;
  } else {
    return null;
  }
}

///取消消息免打扰
///请求参数
///targetId:群聊id/私聊id
Future<Map> removeNoPrompt({int targetId, type}) async {
  Map<String, dynamic> params = {};
  params["targetId"] = targetId;
  params["type"] = type;
  BaseResponseModel responseModel = await requestApi(REMOVENOPROMPT, params);
  if (responseModel.isSuccess) {
    return responseModel.data;
  } else {
    return null;
  }
}

///查询是否免打扰
///请求参数
///targetId:群聊id/私聊id
Future<Map> queryIsNoPrompt({int targetId, int type}) async {
  Map<String, dynamic> params = {};
  params["targetId"] = targetId;
  params["type"] = type;
  BaseResponseModel responseModel = await requestApi(QUERYISNOPROMPT, params);
  if (responseModel.isSuccess) {
    return responseModel.data;
  } else {
    return null;
  }
}

///查询免打扰列表
///请求参数
///targetId:群聊id/私聊id
Future<Map> queryNoPromptUidList() async {
  Map<String, dynamic> params = {};
  BaseResponseModel responseModel = await requestApi(QUERYNOPROMPTUIDLIST, params);
  if (responseModel.isSuccess) {
    return responseModel.data;
  } else {
    return null;
  }
}

Future<bool> refreshUnreadMsg(int type, {int timeStamp})async{
  Map<String,dynamic> map = Map();
  map["type"] = type;
  if(timeStamp != null){
    map["timeStamp"] = timeStamp;
  }
  BaseResponseModel responseModel = await requestApi(REFREASHMSGUNREAD, map);
  Map<String, dynamic> result = responseModel.data;
  bool state;
  if(responseModel.isSuccess){
    state = result["state"];
    return state;
  }else{
    return null;
  }
}


///获取系统消息
///请求参数
///targetId:群聊id/私聊id
Future<Map> querySysMsgList({int type, int size, String lastTime}) async {
  Map<String, dynamic> params = {};
  params["type"] = type;
  params["size"] = size.toString();
  if (lastTime != null) {
    params["lastTime"] = lastTime;
  }
  BaseResponseModel responseModel = await requestApi(QUERYSYSMSGLIST, params);
  if (responseModel.isSuccess) {
    return responseModel.data;
  } else {
    return null;
  }
}
