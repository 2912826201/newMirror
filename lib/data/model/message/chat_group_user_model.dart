/// data : {"list":[{"uid":1000111,"nickName":"bigfish","avatarUri":"http://devpic.aimymusic.com/app/default_avatar01.png","roleString":null,"role":null},{"uid":1008611,"nickName":"爸爸","avatarUri":"http://devpic.aimymusic.com/app/default_avatar01.png","roleString":null,"role":null},{"uid":1000000,"nickName":"哎呀呀","avatarUri":"http://devpic.aimymusic.com/app/default_avatar01.png","roleString":null,"role":null}]}
/// code : 200
/// uid : 1000111
/// nickName : "bigfish"
/// avatarUri : "http://devpic.aimymusic.com/app/default_avatar01.png"
/// roleString : null
/// role : null

class ChatGroupUserModel {
  int uid;
  String nickName;
  String groupNickName;
  String avatarUri;
  String roleString; // 0-成员 1-群主
  dynamic role;

  //获取是不是群主
  bool isGroupLeader() {
    return roleString != null && roleString == "1";
  }

  ChatGroupUserModel(
      {int uid, String nickName, String groupNickName, String avatarUri, String roleString, dynamic role}) {
    uid = uid;
    nickName = nickName;
    groupNickName = groupNickName;
    avatarUri = avatarUri;
    roleString = roleString;
    role = role;
  }

  ChatGroupUserModel.fromJson(dynamic json) {
    uid = json["uid"];
    nickName = json["nickName"];
    groupNickName = json["groupNickName"];
    avatarUri = json["avatarUri"];
    roleString = json["roleString"];
    role = json["role"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["uid"] = uid;
    map["nickName"] = nickName;
    map["groupNickName"] = groupNickName;
    map["avatarUri"] = avatarUri;
    map["roleString"] = roleString;
    map["role"] = role;
    return map;
  }
}
