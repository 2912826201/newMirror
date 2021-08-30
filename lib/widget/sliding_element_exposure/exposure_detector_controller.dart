import 'package:flutter/foundation.dart';

import './lru_list.dart';
import './exposure_detector_layer.dart';

/// exposure_detector_controller
/// Created by sl on 2021/3/13.
class ExposureDetectorController {
  static final _instance = ExposureDetectorController();

  static ExposureDetectorController get instance => _instance;

  Duration updateInterval = const Duration(milliseconds: 200);

  // 产品需求要等三秒后显示在这里设置;
  int exposureTime = 3000;

  // list 元素曝光的比例
  double exposureFraction = 0.5;


  // 存储显示过的list元素key值
  LruList<Key> _filterKeyList = LruList(maxLength: 1000);

  bool filterKeysContains(Key key) {
    return _filterKeyList.contains(key);
  }

  void forget(Key key) {
    _filterKeyList.add(key);
    ExposureDetectorLayer.forget(key);
  }

  // SL添加 退出登录清除记录
  void signOutClearHistory() {
    _filterKeyList.clear();
    print("清空listKey值记录");
  }

  // 设置过滤列表长度
  void setFilterList(int length) {
    assert(length != null);
    _filterKeyList = LruList(maxLength: length);
  }
}
