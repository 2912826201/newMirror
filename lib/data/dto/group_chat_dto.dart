
//创建群聊回来的dto
class GroupChatDto{
  int id ;
  String name;
  String coverUrl;
  int creatorId;
  int dataState;
  int createTime;
  int updateTime;

  GroupChatDto.fromJson(Map<String,dynamic> json){
    print("json is ${json.toString()}");
   this.id = json["id"];
   this.name = json["name"];
   this.coverUrl = json["coverUrl"];
   this.creatorId = json["creatorId"];
   this.dataState = json["dataState"];
   this.createTime = json["createTime"];
   this.updateTime = json["updateTime"];
  }

  Map<String,dynamic> toJson(){
    Map<String,dynamic> map = Map();
    map["id"] = this.id;
    map["name"] = this.name;
    map["coverUrl"] = this.coverUrl;
    map["creatorId"] = this.creatorId;
    map["updateTime"] = this.updateTime;
    map["createTime"] = this.createTime;
    return map;
  }

  String toString(){
    return "id :$id - name:$name - coverUrl:$coverUrl - creatorId:$creatorId - dataState:$dataState - createTime:$createTime - updateTime:$updateTime";
  }

}