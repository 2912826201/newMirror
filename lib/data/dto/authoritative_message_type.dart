//官方消息的model
import 'dart:convert';
import 'dart:core';

import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

class AuthoritativeMessageDto extends  MessageContent{
  static const  AuthoritativeMessageDtoIdentifier = "AuthoritativeMessageDtoIdentifier";
   String title;       // 标题
   String text;        // 文字
   String atUsers;     // 文字中@用户的详细信息
   String picUrl;      // 图片url
   String linkUrl;     // 跳转链接 可为外部链接也可为内部页面链接
   String linkText;    // 提示点击跳转链接的文字
   int type;       // 类型
   int subType;    // 子类型
   int groupId;       // 圈子ID
   String groupChatId;   // 圈子群聊ID
   int entryApplyId;  //申请id
   int source;     // 来源
   int invitationId;      // 圈子邀请id
   int followApplyId;     // 申请关注圈子的申请id

   String operatorName;  //处理人名称
   int operatorUid;   //处理人ID
//    private List<GroupMemberDto> groupMemberList;   //圈子成员列表
//    private GroupMemberDto inviterInfo; //邀请人信息
   String groupCoverUrl; // 圈子封面
   String groupName;  // 圈子名称
   String data;       // 扩充字段（邀请加入圈子相关信息、禁言相关信息）
   String groupChatName;   //圈子群聊名称

   int isMute;     // 0，解除禁言；1，禁言
   int minutes;    // 单个禁言时禁言的时长，单位：分钟

   AuthoritativeMessageDto.fromJson(Map<String,dynamic> map){
    this.title= map["title"] ;
    this.text = map["text"] ;
    this.atUsers = map["atUsers"];
    this.picUrl = map["picUrl"] ;
    this.linkUrl = map["linkUrl"] ;
    this.linkText = map["linkText"] ;
    this.type = map["type"];
    this.subType = map["subType"];
    this.groupId = map["groupId"];
    this.groupChatId = map["groupChatId"];
    this.entryApplyId = map["entryApplyId"];
    this.source = map["source"];
    this.invitationId = map["invitationId"];
    this.followApplyId = map["followApplyId"];
    this.operatorUid = map["operatorUid"];
    this.groupCoverUrl = map["groupCoverUrl"] ;
    this.groupName = map["groupName"];
    this.data = map["data"];
    this.groupChatName = map["groupChatName"];
    this.isMute = map["isMute"];
    this.minutes = map["minutes"];
  }
   Map<String,dynamic> toJson(){
    Map<String,dynamic> map = Map();
    map["title"] = this.title;
    map["text"] = this.text;
    map["atUsers"] = this.atUsers;
    map["picUrl"] = this.picUrl;
    map["linkUrl"] = this.linkUrl;
    map["linkText"] = this.linkText;
    map["type"] = this.type;
    map["subType"] = this.subType;
    map["groupId"] = this.groupId;
    map["groupChatId"] = this.groupChatId;
    map["entryApplyId"] = this.entryApplyId;
    map["source"] = this.source;
    map["invitationId"] = this.invitationId;
    map["followApplyId"] = this.followApplyId;
    map["operatorUid"] =this.operatorUid;
    map["groupCoverUrl"] = this.groupCoverUrl;
    map["groupName"]=this.groupName;
    map["data"]= this.data;
    map["groupChatName"]=this.groupChatName;
    map["isMute"]=this.isMute;
    map["minutes"] = this.minutes;
    return map;
  }
  //转成json
   String encode() {
    Map<String,dynamic> map = Map<String,dynamic>();
    map["title"] = this.title;
    map["text"] = this.text;
    map["atUsers"] = this.atUsers;
    map["picUrl"] = this.picUrl;
    map["linkUrl"] = this.linkUrl;
    map["linkText"] = this.linkText;
    map["type"] = this.type;
    map["subType"] = this.subType;
    map["groupId"] = this.groupId;
    map["groupChatId"] = this.groupChatId;
    map["entryApplyId"] = this.entryApplyId;
    map["source"] = this.source;
    map["invitationId"] = this.invitationId;
    map["followApplyId"] = this.followApplyId;
    map["operatorUid"] =this.operatorUid;
    map["groupCoverUrl"] = this.groupCoverUrl;
    map["groupName"]=this.groupName;
    map["data"]= this.data;
    map["groupChatName"]=this.groupChatName;
    map["isMute"]=this.isMute;
    map["minutes"] = this.minutes;
    return json.encode(map);
  }
  //由json转化为byte[]
   void decode(String jsonStr) {
    return json.decode(this.toString());
   }




   @override
   String getObjectName(){
     return AuthoritativeMessageDtoIdentifier;
   }
}