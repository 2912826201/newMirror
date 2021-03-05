import 'package:flutter/cupertino.dart';
import 'package:mirror/data/model/feed/post_feed.dart';

class ReleaseProgressNotifier extends ChangeNotifier {
  ReleaseProgressNotifier({this.plannedSpeed = 0.0});

// 发布动态进度
  double plannedSpeed;



// 更新发布动态进度
  getPostPlannedSpeed(double plannedSpeed) {
    this.plannedSpeed = plannedSpeed;
    notifyListeners();
  }
}
