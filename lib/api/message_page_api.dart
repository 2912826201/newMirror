
import 'package:dio/dio.dart';
import 'package:mirror/api/api.dart';
import 'package:mirror/data/dto/group_chat_dto.dart';
import 'package:mirror/data/model/base_response_model.dart';
import 'package:mirror/data/model/message/intercourse_model.dart';


const String UNREAD_COUNT = "/appuser/web/message/getUnreadMsgCount";
const String CREATE_NEW_CONVERSATION = "/appuser/web/groupChat/create";
Future<Unreads> getUnReads() async {
 BaseResponseModel responseModel = await requestApi(UNREAD_COUNT, {});
 if (responseModel.isSuccess) {
   //TODO 这里实际需要将请求结果处理为具体的业务数据
   return Unreads.fromJson(responseModel.data);
 } else {
   //TODO 这里实际需要处理失败
   return null;
 }
}
//请求创建群聊
Future<GroupChatDto> createNewGroupChat(List<String> members) async{
  print("createNewGroupChat");
  final String parameterName = "uids";
  print("members is $members");
  Map<String,dynamic> parameters = Map();
  String membersStringPre = "[";
  String membersStringSuffix = "]";
  members.forEach((element) {
   membersStringPre = membersStringPre+"$element,";
  });
  membersStringPre = membersStringPre.substring(0,membersStringPre.length -1);
  parameters[parameterName] = membersStringPre+membersStringSuffix;
  print("final parameters: ${parameters.toString()}");
  BaseResponseModel responseModel = await requestApi(CREATE_NEW_CONVERSATION, parameters);
  if(responseModel.isSuccess){
    print("request success");
    print(responseModel.data);
  return GroupChatDto.fromJson(responseModel.data);
  }
  else {
    print("失败");
  return null;
  }

}