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
Future<Map> modifyNickName(
    {@required int groupChatId, @required String newName}) async {
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