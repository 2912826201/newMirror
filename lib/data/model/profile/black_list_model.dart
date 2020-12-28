
class BlackListModel{
  int uid;
  String nickName;
  String avatarUri;
  int sex;
  BlackListModel({this.uid,this.nickName,this.avatarUri,this.sex});

  BlackListModel.fromJson(Map<String, dynamic> json) {
    uid = json["uid"];
    nickName = json["nickName"];
    avatarUri = json["avatarUri"];
    sex = json["sex"];
  }
  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["uid"] = uid;
    map["nickName"] = nickName;
    map["avatarUri"] = avatarUri;
    map["sex"] = sex;
    return map;
  }

}