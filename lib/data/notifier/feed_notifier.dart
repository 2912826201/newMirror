import 'package:flutter/material.dart';
import 'package:mirror/data/model/comment_model.dart';
import 'package:mirror/data/model/feed/post_feed.dart';
import 'package:mirror/data/model/home/home_feed.dart';

class FeedMap {
  Map<int, HomeFeedModel> _feedMap = {};

  Map<int, HomeFeedModel> get feedMap => _feedMap;

  Map<int, HomeFeedModel> _oldFeedMap = {};

  Map<int, HomeFeedModel> get oldFeedMap => _oldFeedMap;

  bool _buildIsOver = false;

  bool get buildIsOver => _buildIsOver;

  // 点击评论图标记录此动态的Id用于请求评论列表
  int _feedId;

  int get feedId => _feedId;

  List<CommentDtoModel> _commentList = [];

  List<CommentDtoModel> get commentList => _commentList;

  CommentDtoModel _childModel;

  CommentDtoModel get childModel => _childModel;

  Map<int, dynamic> _courseCommentHot = {};

  Map<int, dynamic> get courseCommentHot => _courseCommentHot;

  FeedMapNotifier wrapper;
  int _unReadFeedCount = 0;

  int get unReadFeedCount => _unReadFeedCount;

  // 是否可下拉
  bool _isDropDown = true;

  bool get isDropDown => _isDropDown;

  FeedMap(this._feedMap);
}

class FeedMapNotifier extends ValueNotifier<FeedMap> // ChangeNotifier
    {
  FeedMapNotifier(FeedMap value) : super(value) {value.wrapper = this;}

  // 是否是左滑
  bool isSwipeLeft;
  double metricsPixels;

  storageIsSwipeLeft(bool offset) {
    this.isSwipeLeft = offset;
    notifyListeners();
  }

  storage(double offset) {
    this.metricsPixels = offset;
    notifyListeners();
  }

  setUnReadFeedCount(int count) {
    value._unReadFeedCount = count;
    notifyListeners();
  }

  void interacticeNoticeChange({CommentModel courseCommentHots, int commentId}) {
    value.courseCommentHot[commentId] = courseCommentHots;
  }


  void showInputBox(int id) {
    print("id::${id}");
    value._feedMap[id].isShowInputBox = false;
    // _feedMap[id].isShowInputBox = false;
    notifyListeners();
  }

  void changeCommentList(List<CommentDtoModel> modelList) {
    value.commentList.addAll(modelList);
    notifyListeners();
  }

  void insertChildModel(CommentDtoModel model) {
    value._childModel = model;
    notifyListeners();
  }

// 更新全局动态map
  void updateFeedMap(List<HomeFeedModel> _feedList, {bool needNotify = true}) {
    _feedList.forEach((element) {
      value._feedMap[element.id] = element;
      value._feedMap[element.id].hotComment = [];
      if (element.comments.isNotEmpty && element.comments.length > 1) {
        for (int i = 0; i < 2; i++) {
          value._feedMap[element.id].hotComment.add(element.comments[i]);
        }
      } else if (element.comments.isNotEmpty) {
        value._feedMap[element.id].hotComment.addAll(element.comments);
      }
    });
    if(needNotify){
      notifyListeners();
    }
  }

  // 插入动态Map
  void insertFeedMap(HomeFeedModel model) {
    value._feedMap[model.id] = model;
    notifyListeners();
  }

  void updateHotComment(int feedId, {CommentDtoModel commentDtoModel, bool isDelete}) {
    print('9(((((((((((((((((((((((9updateHotComment');
    if (isDelete) {
      value._feedMap[feedId].hotComment.removeWhere((element) {
        return element.id == commentDtoModel.id || element.targetId == commentDtoModel.id;
      });
      if (value._feedMap[feedId].hotComment.length < 2 && value._feedMap[feedId].comments.length != 0) {
        if (value._feedMap[feedId].comments.length > 1 && value._feedMap[feedId].hotComment.length == 0) {
          for (int i = 0; i < 2; i++) {
            if (value._feedMap[feedId].comments[i].id != commentDtoModel.id) {
              value._feedMap[feedId].hotComment.add(value._feedMap[feedId].comments[i]);
            }
          }
        } else if (value._feedMap[feedId].hotComment.length != 0) {
          if (value._feedMap[feedId].comments.first.id != value._feedMap[feedId].hotComment.first.id) {
            value._feedMap[feedId].hotComment.add(value._feedMap[feedId].comments.first);
          }
        } else {
          if (value._feedMap[feedId].comments.length != 0) {
            value._feedMap[feedId].hotComment.add(value._feedMap[feedId].comments.first);
          }
        }
      }
    } else {
      if (!value._feedMap[feedId].hotComment.contains(commentDtoModel)) {
        print('))))))))))))))))))))))))))))))))))))))))))添加');
        value._feedMap[feedId].hotComment.add(commentDtoModel);
      }
      print('===============hotComment============${value._feedMap[feedId].hotComment.length}');
      print('===============hotComment============${value._feedMap[feedId].hotComment.toString()}');
    }
    notifyListeners();
  }

  void deleteCommentCount(int feedId, CommentDtoModel commentDtoModel) {
    if(commentDtoModel.targetId==feedId){
      value.feedMap[feedId].commentCount -= 1 + commentDtoModel.replyCount;
      value.feedMap[feedId].totalCount -= 1 + commentDtoModel.replyCount;
    }else{
      value.feedMap[feedId].commentCount-=1;
      value.feedMap[feedId].totalCount -= 1;
    }
    notifyListeners();
  }

  // 删除动态
  void deleteFeed(int id) {
    value._feedMap.remove(id);
    notifyListeners();
  }

  // 关注or取消关注
  void setIsFollow(int id, int isFollow) {
    if (isFollow == 0) {
      value._feedMap[id].isFollow = 1;
    }
    if (isFollow == 1) {
      value._feedMap[id].isFollow = 0;
    }
    notifyListeners();
  }

// //点赞
  void setLaud(int laud, String avatarUrl, int id) {
    print("点赞了前：：：：：：：：$laud");
    if (laud == 0) {
      value._feedMap[id].laudCount -= 1;
      value._feedMap[id].laudUserInfo.removeWhere((v) => v == avatarUrl);
    } else {
      value._feedMap[id].laudCount += 1;
      value._feedMap[id].laudUserInfo.insert(0, avatarUrl);
    }
    value._feedMap[id].isLaud = laud;
    print("点赞了后：：：：：：：：$laud");
    notifyListeners();
  }

// 父评论点赞
  void mainCommentLaud(int laud, int id, int index) {
    if (laud == 0) {
      value._feedMap[id].comments[index].laudCount += 1;
      laud = 1;
    } else {
      value._feedMap[id].comments[index].laudCount -= 1;
      laud = 0;
    }
    value._feedMap[id].comments[index].isLaud = laud;
    notifyListeners();
  }

  // 子评论点赞
  void subCommentLaud(int laud, int id, int mainIndex, int subIndex) {
    if (laud == 0) {
      value._feedMap[id].comments[mainIndex].replys[subIndex].laudCount += 1;
      laud = 1;
    } else {
      value._feedMap[id].comments[mainIndex].replys[subIndex].laudCount -= 1;
      laud = 0;
    }
    value._feedMap[id].comments[mainIndex].replys[subIndex].isLaud = laud;
    notifyListeners();
  }

  // 发布动态评论
  void feedPublishComment(CommentDtoModel comModel, int id) {
    print("评论model赋值");
    value._feedMap[id].comments.insert(0, comModel);
    print("评论model成功");
    value._feedMap[id].commentCount += 1;
    print("评论数量l成功");
    value._feedMap[id].totalCount += 1;
    notifyListeners();
  }

  // 更新
  void updateTotalCount(int totalCount, int id) {
    value._feedMap[id].totalCount = totalCount;
    value._feedMap[id].commentCount = totalCount;
    notifyListeners();
  }

  // 修改动态Id
  changeFeeId(int id,) {
    value._feedId = id;
    notifyListeners();
  }

  // 动态评论详情页赋值
  void commensAssignment(int id, List<CommentDtoModel> commentList, int totalCount) {
    List<CommentDtoModel> listComment = <CommentDtoModel>[];
    listComment.addAll(commentList);
    value._feedMap[id].comments = listComment;
    value._feedMap[id].totalCount = totalCount;
    notifyListeners();
  }

  // 同步不同的评论数据
  void commensUpdate(int id, List<CommentDtoModel> commentList, int totalCount) {
    value._feedMap[id].comments.forEach((element) {
      value._feedMap[id].comments.addAll(commentList);
    });
    // feedMap[id].comments = commentList;
    value._feedMap[id].totalCount = totalCount;
    notifyListeners();
  }

  // 评论动态的评论
  void commentFeedCom(int id, int index, CommentDtoModel model) {
    value._feedMap[id].comments[index].replys.insert(0, model);
    print('provider========================${value._feedMap[id].comments[index].replys.toString()}');
    value._feedMap[id].commentCount += 1;
    value._feedMap[id].totalCount += 1;
    value._feedMap[id].comments[index].replyCount += 1;
    notifyListeners();
  }

  // // 评论动态子评论
  // void commentFeedSubCom()
  // 关闭抽屉还原评论抽屉内的评论总数
  void clearTotalCount() {
    value._feedMap[value._feedId].totalCount = -1;
    notifyListeners();
  }

  // 测试手动插入评论
  void a(CommentDtoModel comModel, int id) {
    print("评论model赋值");
    value._feedMap[id].comments.insert(0, comModel);
    notifyListeners();
  }

  // 发布插入数据
  void PublishInsertData(int id, HomeFeedModel model) {
    value._feedMap[id] = model;
    notifyListeners();
  }

  void removeComment(int id, CommentDtoModel model) {
    value._feedMap[id].comments.remove(model);
    notifyListeners();
  }


  setBuildCallBack(bool b) {
    value._buildIsOver = b;
    notifyListeners();
  }

  setDropDown(bool b) {
    value._isDropDown = b;
    notifyListeners();
  }
}
