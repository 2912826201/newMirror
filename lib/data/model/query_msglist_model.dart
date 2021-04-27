
import 'package:mirror/data/model/home/home_feed.dart';

class QueryListModel{
  int hasNext;
  int lastTime;
  int lastId;
  int lastScore;
  List<QueryModel> list;
  QueryListModel({this.lastScore,this.lastTime,this.hasNext,this.lastId,this.list});
  QueryListModel.fromJson(dynamic json) {
    hasNext = json["hasNext"];
    lastTime = json["lastTime"];
    lastId = json["lastId"];
    lastScore = json["lastScore"];
    if (json["list"] != null) {
      list = [];
      json["list"].forEach((v) {
        if(v is QueryModel){
          list.add(v);
        }else{
          list.add(QueryModel.fromJson(v));
        }
      });
    }
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["hasNext"] = hasNext;
    map["lastTime"] = lastTime;
    if (list != null) {
      map["list"] = list.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

class QueryModel{
  int id;
  int senderId;//发送人
  int receiverId;//接收者
  int mentionType;//
  int commentId;
  String refId;
  int refType;
  int isRead;
  int createTime;
  int atType;
  CommentDtoModel commentData;
  Map<String ,dynamic> refData;
  String senderName;
  String senderAvatarUrl;
  TopicPicModel coverUrl;
  QueryModel();
  QueryModel.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    senderId = json["senderId"];
    receiverId = json["receiverId"];
    mentionType = json["mentionType"];
    commentId = json["commentId"];
    refId = json["refId"];
    refType = json["refType"];
    isRead = json["isRead"];
    createTime = json["createTime"];
    atType = json["atType"];
    commentData = json["commentData"] != null ? CommentDtoModel.fromJson(json["commentData"]) : null;
    refData = json["refData"];
    senderName = json["senderName"];
    senderAvatarUrl = json["senderAvatarUrl"];

    if(json["coverUrl"] != null ) {
      if(json["coverUrl"] is TopicPicModel) {
        coverUrl = json["coverUrl"];
      } else {
        coverUrl = TopicPicModel.fromJson(json["coverUrl"]);
      }
    }
  }
  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["id"] = id;
    map["senderId"] = senderId;
    map["receiverId"] = receiverId;
    map["mentionType"] = mentionType;
    map["commentId"] = commentId;
    map["refId"] = refId;
    map["refType"] = refType;
    map["isRead"] = isRead;
    map["createTime"] = createTime;
    map["atType"] = atType;
    if (commentData != null) {
      map["commentData"] = CommentDtoModel().toJson();
    }
    map["refData"] = refData;
    map["senderName"] = senderName;
    map["senderAvatarUrl"] = senderAvatarUrl;
    return map;
  }
}