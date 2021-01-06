
class UserNoticeModel{

 List<UserNoticeList> list;

 UserNoticeModel({this.list});

 UserNoticeModel.fromJson(dynamic json) {
   if (json["list"] != null) {
     list = [];
     json["list"].forEach((v) {
       list.add(UserNoticeList.fromJson(v));
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
class UserNoticeList{
  int uid;
  int type;
  int isOpen;
  UserNoticeList({this.type,this.isOpen,this.uid});

  UserNoticeList.fromJson(Map<String, dynamic> json) {
    uid = json["uid"];
    type = json["type"];
    isOpen = json["isOpen"];
  }
  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["uid"] = uid;
    map["type"] = type;
    map["isOpen"] = isOpen;
    return map;
  }
}