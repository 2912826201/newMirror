
class BlackListModel{
  List<BlackUserModel> list;
  BlackListModel({this.list});

  BlackListModel.fromJson(dynamic json) {
    if (json["list"] != null) {
      list = [];
      json["list"].forEach((v) {
        if(v is BlackUserModel){
          list.add(v);
        }else{
          list.add(BlackUserModel.fromJson(v));
        }

      });
    }
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    if (list != null) {
      map["list"] = list.map((v) => v.toJson()).toList();
    }
    return map;
  }
}
class BlackUserModel{
  int uid;
  String nickName;
  String avatarUri;
  int sex;
  BlackUserModel({this.uid,this.nickName,this.avatarUri,this.sex});

  BlackUserModel.fromJson(Map<String, dynamic> json) {
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