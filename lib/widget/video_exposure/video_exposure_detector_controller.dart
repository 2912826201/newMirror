import 'package:flutter/foundation.dart';
import 'package:mirror/widget/video_exposure/video_exposure_layer.dart';
import 'package:mirror/widget/video_exposure/video_lru_list.dart';

class VideoExposureDetectorController {
  static final _instance = VideoExposureDetectorController();

  static VideoExposureDetectorController get instance => _instance;

  Duration updateInterval = const Duration(milliseconds: 10);

  // list 元素曝光的比例
  double exposureFraction = 0.5;

  // 存储显示过的list元素key值
  VideoLruList<Key> _filterKeyList = VideoLruList(maxLength: 1000);

  bool filterKeysContains(Key key) {
    return _filterKeyList.contains(key);
  }

  void forget(Key key) {
    _filterKeyList.add(key);
    VideoExposureLayer.forget(key);
  }

  // SL添加 退出登录清除记录
  void signOutClearHistory() {
    _filterKeyList.clear();
    print("清空listKey值记录");
  }

  // 设置过滤列表长度
  void setFilterList(int length) {
    assert(length != null);
    _filterKeyList = VideoLruList(maxLength: length);
  }
}