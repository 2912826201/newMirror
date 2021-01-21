import 'package:flutter/material.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/feed/post_feed.dart';

class FeedMapNotifier extends ChangeNotifier {
  FeedMapNotifier({this.feedMap, this.feedId,this.postFeedModel});

  // 动态的id加model组成的Map
  Map<int, HomeFeedModel> feedMap = {};

  Map<int, HomeFeedModel> oldFeedMap = {};
  // 点击评论图标记录此动态的Id用于请求评论列表
  int feedId;
  // 发布动态需要的model
   PostFeedModel postFeedModel;
   // 发布动态进度
  double plannedSpeed = 0.0;


  CommentDtoModel childModel;


  void setOldFeedMap(){
    oldFeedMap = feedMap;
    notifyListeners();
  }
  void setFeedMap(){
    feedMap = oldFeedMap;
    notifyListeners();
  }
  void insertChildModel(CommentDtoModel model){
    childModel = model;
    notifyListeners();
  }
// 更新全局动态map
  void updateFeedMap(List<HomeFeedModel> _feedList) {
    _feedList.forEach((element) {
      feedMap[element.id] = element;
    });
    notifyListeners();
  }
 // 是否可以发布动态
  bool isPublish = true;
  // 删除动态
  void deleteFeed(int id) {
    feedMap.remove(id);
  }
  // 关注or取消关注
  void setIsFollow(int id,int isFollow) {
    if (isFollow == 0) {
      feedMap[id].isFollow = 1;
    }
    if (isFollow == 1) {
      feedMap[id].isFollow = 0;
    }
    notifyListeners();
  }
// //点赞
  void setLaud(int laud, String avatarUrl, int id) {
    if (laud == 0) {
      feedMap[id].laudCount += 1;
      feedMap[id].laudUserInfo.insert(0, avatarUrl);
      laud = 1;
    } else {
      feedMap[id].laudCount -= 1;
      feedMap[id].laudUserInfo.removeAt(0);
      laud = 0;
    }
    feedMap[id].isLaud = laud;
    notifyListeners();
  }
// 父评论点赞
  void mainCommentLaud(int laud, int id,int index) {
    if (laud == 0) {
      feedMap[id].comments[index].laudCount += 1;
      laud = 1;
    } else {
      feedMap[id].comments[index].laudCount -= 1;
      laud = 0;
    }
    feedMap[id].comments[index].isLaud = laud;
    notifyListeners();
  }
  // 子评论点赞
  void subCommentLaud(int laud, int id,int mainIndex ,int subIndex) {
    if (laud == 0) {
      feedMap[id].comments[mainIndex].replys[subIndex].laudCount += 1;
      laud = 1;
    } else {
      feedMap[id].comments[mainIndex].replys[subIndex].laudCount -= 1;
      laud = 0;
    }
    feedMap[id].comments[mainIndex].replys[subIndex].isLaud = laud;
    notifyListeners();
  }
//  发布动态评论
  void feedPublishComment(CommentDtoModel comModel, int id) {
    print("评论model赋值");
    feedMap[id].comments.insert(0, comModel);
    print("评论model成功");
    feedMap[id].commentCount += 1;
    print("评论数量l成功");
    feedMap[id].totalCount += 1;
    notifyListeners();
  }

  // 修改动态Id
  changeFeeId(int id,) {
    this.feedId = id;
    notifyListeners();
  }
  changeItemChose(int id,int index){
    feedMap[id].comments[index].itemChose = false;
    notifyListeners();
  }
  // 动态评论详情页赋值
  void commensAssignment(int id, List<CommentDtoModel> commentList, int totalCount) {
    feedMap[id].comments = commentList;
    feedMap[id].totalCount = totalCount;
    notifyListeners();
  }

  // 动态评论抽屉赋值
  void bootomSheetCommensAssignment(int id, List<CommentDtoModel> commentList, int totalCount) {
    feedMap[id].comments = commentList;
    feedMap[id].totalCount = totalCount;
    notifyListeners();
  }
  // 评论动态的评论
  void commentFeedCom(int id, int index, CommentDtoModel model) {
    feedMap[id].comments[index].replys.insert(0, model);
    feedMap[id].commentCount += 1;
    feedMap[id].totalCount += 1;
    feedMap[id].comments[index].replyCount += 1;
    notifyListeners();
  }
  // // 评论动态子评论
  // void commentFeedSubCom()
  // 关闭抽屉还原评论抽屉内的评论总数
  void clearTotalCount() {
    feedMap[feedId].totalCount = -1;
    notifyListeners();
  }
  // 测试手动插入评论
  void a(CommentDtoModel comModel, int id) {
    print("评论model赋值");
    feedMap[id].comments.insert(0, comModel);
    notifyListeners();
  }
 // 发布插入数据
void PublishInsertData(int id,HomeFeedModel model) {
  feedMap[id] = model;
  notifyListeners();
}
void removeComment(int id,CommentDtoModel model){
    feedMap[id].comments.remove(model);
    notifyListeners();
}
// 发布数据需要的model
  void setPublishFeedModel(PostFeedModel model) {
    this.postFeedModel = model;
    notifyListeners();
  }
  // 更新发布动态进度
  getPostPlannedSpeed(double plannedSpeed) {
    this.plannedSpeed = plannedSpeed;
    notifyListeners();
  }
  // 是否调用发布接口
  setPublish(bool b ) {
    this.isPublish = b;
    notifyListeners();
  }

}
