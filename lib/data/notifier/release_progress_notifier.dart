import 'package:flutter/cupertino.dart';
import 'package:mirror/data/model/feed/post_feed.dart';

class ReleaseProgressNotifier extends ChangeNotifier {
  ReleaseProgressNotifier({this.plannedSpeed = 0.0, this.isPublish = true});

// 发布动态进度
  double plannedSpeed;

  // 是否可以发布动态
  bool isPublish;

  // 发布动态需要的model
  PostFeedModel postFeedModel;

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
  setPublish(bool b) {
    this.isPublish = b;
    notifyListeners();
  }
}
