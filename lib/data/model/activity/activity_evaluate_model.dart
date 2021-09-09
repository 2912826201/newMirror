import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/user_model.dart';

class ActivityEvaluateModel {
  int id;
  int activityId;
  int uid;
  double score;
  String content;
  int dataState;
  int createTime;
  int updateTime;
  int commentCount;
  UserModel userInfo;
  List<CommentDtoModel> commentList;

  //额外加的字段
  int pullNumber = 0;
  List<int> screenOutIds = <int>[];

  ActivityEvaluateModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    activityId = json['activityId'];
    uid = json['uid'];
    score = json['score'];
    content = json['content'];
    dataState = json['dataState'];
    createTime = json['createTime'];
    commentCount = json['commentCount'];
    updateTime = json['updateTime'];
    if (json["userInfo"] != null) {
      if (json["userInfo"] is Map<String, dynamic>) {
        userInfo = UserModel.fromJson(json["userInfo"]);
      } else if (json["userInfo"] is UserModel) {
        userInfo = json["userInfo"];
      }
    }
    if (json["commentList"] != null) {
      commentList = [];
      json["commentList"].forEach((v) {
        if (v is CommentDtoModel) {
          commentList.add(v);
        } else {
          commentList.add(CommentDtoModel.fromJson(v));
        }
      });
    }
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map['id'] = id;
    map['activityId'] = activityId;
    map['uid'] = uid;
    map['score'] = score;
    map['content'] = content;
    map['dataState'] = dataState;
    map['createTime'] = createTime;
    map['updateTime'] = updateTime;
    map['userInfo'] = userInfo;
    map['commentCount'] = commentCount;
    map['commentList'] = commentList;
    return map;
  }
}
