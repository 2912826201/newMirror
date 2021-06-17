
class AddRemarksModel{
  UserRemarkKey userRemarkKey;
  String remark;
  AddRemarksModel({this.userRemarkKey,this.remark});
  AddRemarksModel.fromJson(Map<String, dynamic> json) {
    if(json['userRemarkKey'] != null){
      if(json['userRemarkKey'] is UserRemarkKey){
        userRemarkKey=json['userRemarkKey'];
      }else{
        userRemarkKey=UserRemarkKey.fromJson(json['userRemarkKey']);
      }
    }else{
      userRemarkKey =null;
    }
    remark = json["remark"];
  }
  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["userRemarkKey"] = userRemarkKey;
    if (userRemarkKey != null) {
      map["userRemarkKey"] = userRemarkKey.toJson();
    }
    map["remark"] = remark;
    return map;
  }
}
class UserRemarkKey{
  int uid;
  int toUid;
  UserRemarkKey({this.uid,this.toUid});
  UserRemarkKey.fromJson(Map<String, dynamic> json) {
    uid = json["uid"];
    toUid = json["toUid"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["uid"] = uid;
    map["toUid"] = toUid;
    return map;
  }
}