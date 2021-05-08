import 'package:flutter/cupertino.dart';
import 'package:mirror/util/image_cached_observer_util.dart';

class MyWidgetsBindingObserver extends WidgetsBindingObserver {
  // 当内存不足时调用
  @override
  void didHaveMemoryPressure() {
    // TODO: implement didHaveMemoryPressure
    super.didHaveMemoryPressure();
    try {
      print("main文件图片清除缓存");
      ImageCachedObserverUtil.clearPendingCacheImage();
    } catch (e) {
      print("内存不足清除失败");
    }
  }
}
