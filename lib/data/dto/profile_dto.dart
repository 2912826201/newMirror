import 'package:mirror/data/model/user_model.dart';

/// profile_dto
/// Created by yangjiayi on 2020/11/3.

const String TABLE_NAME_PROFILE = "profile";
const String COLUMN_NAME_PROFILE_UID = 'uid';
const String COLUMN_NAME_PROFILE_USERNAME = 'userName';
const String COLUMN_NAME_PROFILE_AVATARURI = 'avatarUri';

// 这个表是用来存放当前已登录用户信息的表

class ProfileDto {
  int uid;
  String userName;
  String avatarUri;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      COLUMN_NAME_PROFILE_UID: uid,
      COLUMN_NAME_PROFILE_USERNAME: userName,
      COLUMN_NAME_PROFILE_AVATARURI: avatarUri
    };
    return map;
  }

  ProfileDto.fromMap(Map<String, dynamic> map) {
    uid = map[COLUMN_NAME_PROFILE_UID];
    userName = map[COLUMN_NAME_PROFILE_USERNAME];
    avatarUri = map[COLUMN_NAME_PROFILE_AVATARURI];
  }

  UserModel toUserModel() {
    var model = UserModel(uid: uid, userName: userName, avatarUri: avatarUri);
    return model;
  }

  ProfileDto.fromUserModel(UserModel model) {
    uid = model.uid;
    userName = model.userName;
    avatarUri = model.avatarUri;
  }
}
