/// data : {"list":[{"uid":1000111,"nickName":"bigfish","avatarUri":"http://devpic.aimymusic.com/app/default_avatar01.png","roleString":null,"role":null},{"uid":1008611,"nickName":"爸爸","avatarUri":"http://devpic.aimymusic.com/app/default_avatar01.png","roleString":null,"role":null},{"uid":1000000,"nickName":"哎呀呀","avatarUri":"http://devpic.aimymusic.com/app/default_avatar01.png","roleString":null,"role":null}]}
/// code : 200
/// uid : 1000111
/// nickName : "bigfish"
/// avatarUri : "http://devpic.aimymusic.com/app/default_avatar01.png"
/// roleString : null
/// role : null

class ChatGroupUserModel {
  int _uid;
  String _nickName;
  String _groupNickName;
  String _avatarUri;
  dynamic _roleString;
  dynamic _role;

  int get uid => _uid;

  String get nickName => _nickName;

  String get groupNickName => _groupNickName;

  String get avatarUri => _avatarUri;

  dynamic get roleString => _roleString;

  dynamic get role => _role;

  ChatGroupUserModel(
      {int uid,
      String nickName,
      String groupNickName,
      String avatarUri,
      dynamic roleString,
      dynamic role}) {
    _uid = uid;
    _nickName = nickName;
    _groupNickName = groupNickName;
    _avatarUri = avatarUri;
    _roleString = roleString;
    _role = role;
  }

  ChatGroupUserModel.fromJson(dynamic json) {
    _uid = json["uid"];
    _nickName = json["nickName"];
    _groupNickName = json["groupNickName"];
    _avatarUri = json["avatarUri"];
    _roleString = json["roleString"];
    _role = json["role"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["uid"] = _uid;
    map["nickName"] = _nickName;
    map["groupNickName"] = _groupNickName;
    map["avatarUri"] = _avatarUri;
    map["roleString"] = _roleString;
    map["role"] = _role;
    return map;
  }
}
