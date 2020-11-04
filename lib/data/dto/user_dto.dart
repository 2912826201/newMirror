import 'package:mirror/data/model/user_model.dart';

/// user_dto
/// Created by yangjiayi on 2020/11/3.

const String TABLE_NAME_USER = "user";
const String COLUMN_NAME_USER_UID = 'uid';
const String COLUMN_NAME_USER_USERNAME = 'userName';
const String COLUMN_NAME_USER_AVATARURI = 'avatarUri';

class UserDto {
  int uid;
  String userName;
  String avatarUri;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      COLUMN_NAME_USER_UID: uid,
      COLUMN_NAME_USER_USERNAME: userName,
      COLUMN_NAME_USER_AVATARURI: avatarUri
    };
    return map;
  }

  UserDto.fromMap(Map<String, dynamic> map) {
    uid = map[COLUMN_NAME_USER_UID];
    userName = map[COLUMN_NAME_USER_USERNAME];
    avatarUri = map[COLUMN_NAME_USER_AVATARURI];
  }

  UserModel toModel() {
    var model = UserModel(uid, userName, avatarUri);
    return model;
  }

  UserDto.fromModel(UserModel model) {
    uid = model.uid;
    userName = model.userName;
    avatarUri = model.avatarUri;
  }
}
