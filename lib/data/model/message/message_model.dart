import 'dart:convert';
import 'dart:core';
/*
* msgUID: ff21e826-ce73-42fc-bb4b-c73dd67a6a87,
 fromUserId: null,
toUserId: null,
objectName: IF:ExtendMessage,
content:
{
"data":"测试测试消息哇哈哈哈哈哈"
},
channelType: null,
 msgTimestamp: 1606793986080, sensitiveType: 0,
source: null,
 groupUserIds: null
*/

//系统消息的model
class MessageModel{
   String msgUID;              //主键、消息唯一id
   String fromUserId;          //发送用户id
   String toUserId;            //接收用户id        发给所有人则为-1
   String objectName;          //消息类型 文本消息 RC:TxtMsg
   Map<String,dynamic> content;             //消息内容 json
   String channelType;         //会话类型 二人会话是 PERSON
   String msgTimestamp;        //消息发送时间戳
   int sensitiveType;          //消息中敏感词标识 0 为不含有敏感词，1 为含有屏蔽敏感词，2 为含有替换敏感词String source;              //消息发送源头 iOS、Android、Websocket
   String groupUserIds;        //[表情]annelType 为 GROUP 时此参数有效，群组

  MessageModel.fromJson(Map<String,dynamic> jsons){
   this.msgUID = jsons["msgUID"];
   this.fromUserId = jsons["fromUserId"];
   this.toUserId = jsons["toUserId"];
   print("objectName字段的类型 ${jsons["objectName"].runtimeType} 为 ${jsons["objectName"]}");
   this.objectName = jsons["objectName"];
   print("content字段的类型 ${jsons["content"].runtimeType} 为 ${jsons["content"]}");
   this.content = json.decode(jsons["content"]);
   this.channelType = jsons["channelType"];
   this.msgTimestamp = jsons["msgTimestamp"];
   this.sensitiveType = jsons["sensitiveType"];
   this.groupUserIds = jsons["groupUserIds"];
  }

  Map<String,dynamic> toJson(){
   Map<String,dynamic> map = Map<String,dynamic>();
   map["msgUID"] = this.msgUID;
   map["fromUserId"] = this.fromUserId;
   map["toUserId"] = this.toUserId;
   map["objectName"] = this.objectName;
   map["content"] = this.content;
   map["channelType"] = this.channelType;
   map["msgTimestamp"] = this.msgTimestamp;
   map["sensitiveType"] = this.sensitiveType;
   map["groupUserIds"] = this.groupUserIds;
 }
}

 //未读消息
 class Unreads{
  List<MessageModel> exerciseMsgList;
  List<MessageModel> sysMsgList;
  List<MessageModel> liveMsgList;
  UnreadInterCourses interCourses;
  Unreads.fromJson(Map<String,dynamic> json){
    this.exerciseMsgList = List<MessageModel>();
    print(json["exerciseMsgList"].runtimeType);
    print(json["exerciseMsgList"]);
    json["exerciseMsgList"].forEach((element){
      print(element.runtimeType);
     this.exerciseMsgList.add(MessageModel.fromJson(element));
    });
    this.liveMsgList = List<MessageModel>();
    json["liveMsgList"].forEach((element){
      this.liveMsgList.add(MessageModel.fromJson(element));
    });
    this.sysMsgList = List<MessageModel>();
    json["sysMsgList"].forEach((element){
      this.sysMsgList.add(MessageModel.fromJson(element));
    });
    this.interCourses = UnreadInterCourses.fromJson(json);
  }
  Map<String,dynamic> toJson(){
    var map = Map<String,dynamic>();
    map["interCourses"] = this.interCourses.toJson();
    map["exerciseMsgList"] = this.exerciseMsgList;
    map["sysMsgList"] = this.sysMsgList;
    map["liveMsgList"] = this.liveMsgList;
    return map;
  }
}
//未读社交消息
class UnreadInterCourses {
  int at;
  int laud;
  int comment;
  UnreadInterCourses({
    this.at,
    this.laud,
    this.comment,
  });
   //由json转为相应的model
   UnreadInterCourses.fromJson(Map<String,dynamic> json){
    this.at = json["at"];
    this.laud = json["laud"];
    this.comment = json["comment"];
  }
  //转化为jsonModel
  Map<String,dynamic> toJson(){
   var map = Map<String,dynamic>();
   map["at"] = at;
   map["laud"] = laud;
   map["comment"] = comment;
   return map;
  }
  String  toString(){
     return "$at+ $laud +$comment+ ${this.hashCode}";
  }
}