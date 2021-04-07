import 'home/home_feed.dart';

/// hasNext : 1
/// lastTime : null
/// lastId : null
/// lastScore : null
/// list : [{"id":450721505458813630,"targetId":1,"type":1,"content":"我在评论课程","picUrls":null,"createTime":1606298780904,"atUsers":null,"uid":1013036,"name":"bigfish测试小号","avatarUrl":"http://devpic.aimymusic.com/app/default_avatar01.png","replys":[{"id":450763525506235100,"targetId":450721505458813630,"type":2,"content":"hello world!!!!!!","picUrls":null,"createTime":1606308799263,"atUsers":null,"uid":1013036,"name":"bigfish测试小号","avatarUrl":"http://devpic.aimymusic.com/app/default_avatar01.png","replys":[{"id":450992876965362370,"targetId":450763525506235100,"type":2,"content":"good morning","picUrls":null,"createTime":1606363480912,"atUsers":null,"uid":1013036,"name":"bigfish测试小号","avatarUrl":"http://devpic.aimymusic.com/app/default_avatar01.png","replys":[],"replyCount":0,"laudCount":0,"isLaud":0,"top":null,"replyId":null,"replyName":null,"delete":null},{"id":450992757125708500,"targetId":450763525506235100,"type":2,"content":"hello world!!!!!!","picUrls":null,"createTime":1606363452343,"atUsers":null,"uid":1013036,"name":"bigfish测试小号","avatarUrl":"http://devpic.aimymusic.com/app/default_avatar01.png","replys":[],"replyCount":0,"laudCount":0,"isLaud":0,"top":null,"replyId":null,"replyName":null,"delete":null}],"replyCount":4,"laudCount":0,"isLaud":0,"top":null,"replyId":null,"replyName":null,"delete":null},{"id":450764844413516500,"targetId":450721505458813630,"type":2,"content":"hello world!!!!!!","picUrls":null,"createTime":1606309113717,"atUsers":null,"uid":1013036,"name":"bigfish测试小号","avatarUrl":"http://devpic.aimymusic.com/app/default_avatar01.png","replys":[],"replyCount":0,"laudCount":0,"isLaud":0,"top":null,"replyId":null,"replyName":null,"delete":null}],"replyCount":14,"laudCount":0,"isLaud":0,"top":null,"replyId":null,"replyName":null,"delete":null},{"id":451052317958045700,"targetId":1,"type":1,"content":"我又来了","picUrls":null,"createTime":1606377652751,"atUsers":null,"uid":1000111,"name":"bigfish","avatarUrl":"http://devpic.aimymusic.com/app/default_avatar01.png","replys":[],"replyCount":0,"laudCount":1,"isLaud":0,"top":null,"replyId":null,"replyName":null,"delete":null},{"id":451112464067690500,"targetId":1,"type":1,"content":"我又来了le 啊啊啊","picUrls":null,"createTime":1606391992702,"atUsers":null,"uid":1000111,"name":"bigfish","avatarUrl":"http://devpic.aimymusic.com/app/default_avatar01.png","replys":[],"replyCount":0,"laudCount":0,"isLaud":0,"top":null,"replyId":null,"replyName":null,"delete":null},{"id":451058859914657800,"targetId":1,"type":1,"content":"我又来了le 乐乐乐","picUrls":null,"createTime":1606379212473,"atUsers":[{"uid":1000000413,"index":0,"len":7,"type":null},{"uid":1000000405,"index":0,"len":8,"type":null},{"uid":1000000405,"index":0,"len":8,"type":null}],"uid":1000111,"name":"bigfish","avatarUrl":"http://devpic.aimymusic.com/app/default_avatar01.png","replys":[],"replyCount":0,"laudCount":0,"isLaud":0,"top":null,"replyId":null,"replyName":null,"delete":null},{"id":451040533687597760,"targetId":1,"type":1,"content":"评论一下课程","picUrls":null,"createTime":1606374843161,"atUsers":null,"uid":1013036,"name":"bigfish测试小号","avatarUrl":"http://devpic.aimymusic.com/app/default_avatar01.png","replys":[],"replyCount":0,"laudCount":0,"isLaud":0,"top":null,"replyId":null,"replyName":null,"delete":null}]
/// totalPage : null
/// totalCount : 6

class CommentModel {
  int hasNext;
  dynamic lastTime;
  dynamic lastId;
  dynamic lastScore;
  List<CommentDtoModel> list;
  dynamic totalPage;
  int totalCount;

  CommentModel(
      {int hasNext,
      dynamic lastTime,
      dynamic lastId,
      dynamic lastScore,
      List<CommentDtoModel> list,
      dynamic totalPage,
      int totalCount}) {
    this.hasNext = hasNext;
    this.lastTime = lastTime;
    this.lastId = lastId;
    this.lastScore = lastScore;
    this.list = list;
    this.totalPage = totalPage;
    this.totalCount = totalCount;
  }

  CommentModel.fromJson(dynamic json) {
    this.hasNext = json["hasNext"];
    this.lastTime = json["lastTime"];
    this.lastId = json["lastId"];
    this.lastScore = json["lastScore"];
    this.list = [];
    if (json["list"] != null) {
      json["list"].forEach((v) {
        if(v is CommentDtoModel){
          this.list.add(v);
        }else{
          this.list.add(CommentDtoModel.fromJson(v));
        }
      });
    }
    this.totalPage = json["totalPage"];
    this.totalCount = json["totalCount"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["hasNext"] = this.hasNext;
    map["lastTime"] = this.lastTime;
    map["lastId"] = this.lastId;
    map["lastScore"] = this.lastScore;
    if (this.list != null) {
      map["list"] = this.list.map((v) => v.toJson()).toList();
    }
    map["totalPage"] = this.totalPage;
    map["totalCount"] = this.totalCount;
    return map;
  }

  @override
  String toString() {
    return toJson().toString();
  }
}
