/// user_model
/// Created by yangjiayi on 2020/10/29.

//用户评论的model
class UserCommentModel {
  int id; //Id
  String userName; //用户名字
  String userUrl; //用户头像
  String userId; // 用户id
  int praiseCount; // 点赞数量
  String createTime; // 评论时间
  int subCommentCount; //有多少条回复
  String content; //评论内容
  bool userIsPraise; //本用户对这个评论点赞没有

  String replyName; //回复的谁的评论，，没有表示本身就是一则品论，而不是子评论
  List<UserCommentModel> subCommentList; //子评论

  UserCommentModel({
    this.id = 0, //默认给个uid为0
    this.userName,
    this.userUrl,
    this.userId,
    this.praiseCount,
    this.createTime,
    this.subCommentCount,
    this.content,
    this.userIsPraise,
    this.replyName,
    this.subCommentList,
  });

  UserCommentModel.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    userName = json["userName"];
    userUrl = json["userUrl"];
    userId = json["userId"];
    praiseCount = json["praiseCount"];
    createTime = json["createTime"];
    subCommentCount = json["subCommentCount"];
    content = json["content"];
    userIsPraise = json["userIsPraise"];
    replyName = json["replyName"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["id"] = id;
    map["userName"] = userName;
    map["userUrl"] = userUrl;
    map["userId"] = userId;
    map["praiseCount"] = praiseCount;
    map["createTime"] = createTime;
    map["subCommentCount"] = subCommentCount;
    map["content"] = content;
    map["userIsPraise"] = userIsPraise;
    map["replyName"] = replyName;

    return map;
  }
}
