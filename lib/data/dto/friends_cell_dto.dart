//创建群聊好友显示cell的model
class FriendCellDto{
  FriendCellDto();
  //头像的路径
  String portraitUrl ;
  //昵称
  String nickName;
  //用户id
  String uid;

  String toString(){
    return " portraiturl is $portraitUrl - nickName is $nickName - uid  is $uid";
  }
  //
  FriendCellDto.fromJson(Map<String,dynamic> map){
    this.portraitUrl = map["portrait"];
    this.nickName = map["nickName"];
    this.uid = map["uid"];
  }
  //
  Map<String,dynamic> toJson(){
    Map<String,dynamic> map = Map<String,dynamic>();
    this.portraitUrl = map["portrait"];
    this.nickName = map["nickName"];
    this.uid = map["uid"];
    return map;
  }
}