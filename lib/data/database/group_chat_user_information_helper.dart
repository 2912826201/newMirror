import 'dart:convert';

import 'package:mirror/data/database/db_helper.dart';
import 'package:mirror/data/dto/group_chat_user_information_dto.dart';
import 'package:mirror/data/model/message/chat_group_user_model.dart';
import 'package:mirror/data/model/message/chat_type_model.dart';
import 'package:mirror/im/message_manager.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

/// group_chat_user_information_helper
/// Created by shipk on 2021/3/2.

class GroupChatUserInformationDBHelper {
  
  Future<bool> update({Message message,ChatGroupUserModel chatGroupUserModel,String groupId}) async {
    if (message != null&&message.conversationType!=RCConversationType.Group&&
        message.objectName==ChatTypeModel.MESSAGE_TYPE_GRPNTF) {
      return false;
    }
    if((message==null||message.content==null||message.content.sendUserInfo==null)&&
        (chatGroupUserModel==null||groupId==null)){
      return false;
    }


    GroupChatUserInformationDto informationDto=_getDto(message, chatGroupUserModel, groupId);

    if(_isHaveEqualMap(informationDto)){
      return true;
    }else{
      if(await _updateJudge(informationDto)){
        MessageManager.chatGroupUserInformationMap[informationDto.groupChatId]=informationDto.toMap();
        return true;
      }else{
        return false;
      }
    }
  }

  Future<List<GroupChatUserInformationDto>> queryAll() async {
    List<GroupChatUserInformationDto> list = [];
    List<Map<String, dynamic>> result =await DBHelper.instance.db.query(TABLE_NAME_GROUP_CHAT_USER_INFORMATION);

    print("result:${result.length}， result1:${result.toString()}");

    for (Map<String, dynamic> map in result) {
      list.add(GroupChatUserInformationDto.fromMap(map));
    }
    return list;
  }


  Future<Map<String, Map<String, dynamic>>> queryAllMap() async {
    Map<String, Map<String, dynamic>> dataMap=Map();
    List<Map<String, dynamic>> result =await DBHelper.instance.db.query(TABLE_NAME_GROUP_CHAT_USER_INFORMATION);

    print("result:${result.length}， result1:${result.toString()}");

    if(result!=null&&result.length>0){
      for (Map<String, dynamic> map in result) {
        dataMap[map[GROUP_CHAT_USER_INFORMATION_ID]] = map;
      }
    }
    return dataMap;
  }

  Future<void> clearAll() async {
    MessageManager.chatGroupUserInformationMap.clear();
    await DBHelper.instance.db.delete(TABLE_NAME_GROUP_CHAT_USER_INFORMATION);
  }

  Future<void> clearGroupUser(String groupChatId) async {
    List<String> removeKey = [];
    MessageManager.chatGroupUserInformationMap.forEach((key, value) {
      if (key.contains("${groupChatId}_")) {
        removeKey.add(key);
      }
    });
    removeKey.forEach((element) {
      MessageManager.chatGroupUserInformationMap.remove(element);
    });
    await DBHelper.instance.db.delete(TABLE_NAME_GROUP_CHAT_USER_INFORMATION,
        where: "$GROUP_CHAT_USER_INFORMATION_GROUP_ID = '$groupChatId'");
  }

  Future<Map<String, GroupChatUserInformationDto>> queryGroupListMap(String chatGroupId) async {
    Map<String, GroupChatUserInformationDto> mapList = Map();
    List<Map<String, dynamic>> result = await DBHelper.instance.db
        .query(TABLE_NAME_GROUP_CHAT_USER_INFORMATION, where: "$GROUP_CHAT_USER_INFORMATION_GROUP_ID = '$chatGroupId'");

    print("result:${result.length}， result1:${result.toString()}");

    for (Map<String, dynamic> map in result) {
      mapList[map[GROUP_CHAT_USER_INFORMATION_ID]]=GroupChatUserInformationDto.fromMap(map);
    }
    return mapList;
  }



  //移除某一个或者某几个 被移除群成员信息
  void removeMessageGroup(Message message){
    // print("移除好友");
    if(message!=null||message.objectName==ChatTypeModel.MESSAGE_TYPE_GRPNTF) {
      Map<String, dynamic> mapGroupModel;

      try {
        if (message.originContentMap != null && message.originContentMap["data"] != null) {
          mapGroupModel = json.decode(message.originContentMap["data"]);
        } else if (message.content is GroupNotificationMessage) {
          GroupNotificationMessage msg = message.content as GroupNotificationMessage;
          mapGroupModel = jsonDecode(msg.data);
        }
      } catch (e) {
        mapGroupModel = Map();
      }
      //移除
      if (mapGroupModel["subType"] == 2 || mapGroupModel["subType"] == 1) {
        List<dynamic> users = mapGroupModel["users"];
        if (users == null || users.length < 1) {
          return;
        }
        for (dynamic d in users) {
          try {
            if (d != null && d["uid"] != null) {
              _remove(message.targetId, d["uid"].toString());
            }
          } catch (e) {
            break;
          }
        }
      }
    }
  }

  //移除某一个群聊的所有群成员信息
  void removeGroupAllInformation(String groupId){
    if(groupId==null){
      return;
    }
    DBHelper.instance.db
        .delete(TABLE_NAME_GROUP_CHAT_USER_INFORMATION,
        where: "$GROUP_CHAT_USER_INFORMATION_GROUP_ID = '$groupId'");
  }



  Future<bool> _updateJudge(GroupChatUserInformationDto informationDto) async {
    if (await _isHave(informationDto)) {
      return await _update(informationDto);
    } else {
      return await _insert(informationDto);
    }
  }

  Future<bool> _insert(GroupChatUserInformationDto informationDto) async {
    try{
      var result = await DBHelper.instance.db.insert(TABLE_NAME_GROUP_CHAT_USER_INFORMATION, informationDto.toMap());
      return result > 0;
    }catch (e){
      return await _update(informationDto);
    }
  }

  Future<bool> _update(GroupChatUserInformationDto informationDto) async {
    var result = await DBHelper.instance.db.update(TABLE_NAME_GROUP_CHAT_USER_INFORMATION, informationDto.toMap(),
        where: "$GROUP_CHAT_USER_INFORMATION_ID = '${informationDto.groupChatId}'");
    return result > 0;
  }





  Future<bool> _isHave(GroupChatUserInformationDto informationDto) async {
    List<Map<String, dynamic>> result = [];
    result = await DBHelper.instance.db
        .query(TABLE_NAME_GROUP_CHAT_USER_INFORMATION,
        where: "$GROUP_CHAT_USER_INFORMATION_ID = '${informationDto.groupChatId}'");
    return result != null && result.length > 0;
  }



  void _remove(String groupId,String userId) async {
    print("清除群友信息：${MessageManager.chatGroupUserInformationMap["${groupId}_$userId"]}");
    if(groupId==null||userId==null){
      return;
    }
    MessageManager.chatGroupUserInformationMap["${groupId}_$userId"]=null;
    DBHelper.instance.db
        .delete(TABLE_NAME_GROUP_CHAT_USER_INFORMATION,
        where: "$GROUP_CHAT_USER_INFORMATION_ID = '${groupId}_$userId'");
  }




  bool _isHaveEqualMap(GroupChatUserInformationDto informationDto){
    if(MessageManager.chatGroupUserInformationMap[informationDto.groupChatId]!=null){
      return informationDto.isEqualMap(MessageManager.chatGroupUserInformationMap[informationDto.groupChatId]);
    }
    return false;
  }

  GroupChatUserInformationDto _getDto(Message message,ChatGroupUserModel chatGroupUserModel,String groupId){
    if(message!=null){
      return _getDtoInMessage(message);
    }else{
      return getDtoInModel(chatGroupUserModel,groupId);
    }
  }

  GroupChatUserInformationDto _getDtoInMessage(Message message){
    GroupChatUserInformationDto dto = GroupChatUserInformationDto();
    dto..groupChatId="${message.targetId}_${message.content.sendUserInfo.userId}"
      ..groupChatGroupId=message.targetId
      ..groupChatUserId=message.content.sendUserInfo.userId
      ..groupChatUserName=message.content.sendUserInfo.name
      ..groupChatUserImage=message.content.sendUserInfo.portraitUri
      ..groupChatGroupUserName=message.content.sendUserInfo.extra==null?"":
      json.decode(message.content.sendUserInfo.extra)[GROUP_CHAT_USER_INFORMATION_GROUP_USER_NAME];
    return dto;
  }

  GroupChatUserInformationDto getDtoInModel(ChatGroupUserModel chatGroupUserModel,String groupId){
    GroupChatUserInformationDto dto = GroupChatUserInformationDto();
    dto..groupChatId="${groupId}_${chatGroupUserModel.uid}"
      ..groupChatGroupId=groupId
      ..groupChatUserId=chatGroupUserModel.uid.toString()
      ..groupChatUserName=chatGroupUserModel.nickName
      ..groupChatUserImage=chatGroupUserModel.avatarUri
      ..groupChatGroupUserName=chatGroupUserModel.groupNickName;
    return dto;
  }


}
