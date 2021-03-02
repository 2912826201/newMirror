
/// download_course_video_dto
/// Created by shipk on 2021/3/2

const String TABLE_NAME_GROUP_CHAT_USER_INFORMATION = "group_chat_user_information";
const String GROUP_CHAT_USER_INFORMATION_ID = 'group_chat_id';
const String GROUP_CHAT_USER_INFORMATION_USER_ID = 'group_chat_user_id';
const String GROUP_CHAT_USER_INFORMATION_USER_IMAGE = 'group_chat_user_image';
const String GROUP_CHAT_USER_INFORMATION_GROUP_ID = 'group_chat_group_id';
const String GROUP_CHAT_USER_INFORMATION_USER_NAME = 'group_chat_user_name';
const String GROUP_CHAT_USER_INFORMATION_GROUP_USER_NAME = 'group_chat_group_user_name';


class GroupChatUserInformationDto {

  String groupChatId;
  String groupChatUserId;
  String groupChatUserImage;
  String groupChatGroupId;
  String groupChatUserName;
  String groupChatGroupUserName;



  GroupChatUserInformationDto();

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      GROUP_CHAT_USER_INFORMATION_ID: groupChatId,
      GROUP_CHAT_USER_INFORMATION_USER_ID: groupChatUserId,
      GROUP_CHAT_USER_INFORMATION_USER_IMAGE: groupChatUserImage,
      GROUP_CHAT_USER_INFORMATION_GROUP_ID: groupChatGroupId,
      GROUP_CHAT_USER_INFORMATION_USER_NAME: groupChatUserName,
      GROUP_CHAT_USER_INFORMATION_GROUP_USER_NAME: groupChatGroupUserName,
    };
    return map;
  }

  GroupChatUserInformationDto.fromMap(Map<String, dynamic> map) {
    groupChatId = map[GROUP_CHAT_USER_INFORMATION_ID];
    groupChatUserId = map[GROUP_CHAT_USER_INFORMATION_USER_ID];
    groupChatUserImage = map[GROUP_CHAT_USER_INFORMATION_USER_IMAGE];
    groupChatGroupId = map[GROUP_CHAT_USER_INFORMATION_GROUP_ID];
    groupChatUserName = map[GROUP_CHAT_USER_INFORMATION_USER_NAME];
    groupChatGroupUserName = map[GROUP_CHAT_USER_INFORMATION_GROUP_USER_NAME];
  }


  bool isEqualMap(Map<String, dynamic> map){
    return groupChatId == map[GROUP_CHAT_USER_INFORMATION_ID]&&
        groupChatUserId == map[GROUP_CHAT_USER_INFORMATION_USER_ID]&&
        groupChatUserImage == map[GROUP_CHAT_USER_INFORMATION_USER_IMAGE]&&
        groupChatGroupId == map[GROUP_CHAT_USER_INFORMATION_GROUP_ID]&&
        groupChatUserName == map[GROUP_CHAT_USER_INFORMATION_USER_NAME]&&
        groupChatGroupUserName == map[GROUP_CHAT_USER_INFORMATION_GROUP_USER_NAME];
  }
}
