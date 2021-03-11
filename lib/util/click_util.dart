class ClickUtil {
  static int clickTime = 0;
  static int firstEndCallbackListViewClickTime = 0;
  static int clickIntervalTime = 500;

  //判断是不是快速点击
  static bool isFastClick({int time = 500}) {
    var clickNewTime = new DateTime.now().millisecondsSinceEpoch;
    if (clickNewTime - clickTime >= time) {
      clickTime = clickNewTime;
      return false;
    }
    return true;
  }
  //判断是不是快速点击聊天界面返回的显示个数间隔
  static bool isFastClickFirstEndCallbackListView({int time = 500}) {
    var clickNewTime = new DateTime.now().millisecondsSinceEpoch;
    if (clickNewTime - firstEndCallbackListViewClickTime >= time) {
      firstEndCallbackListViewClickTime = clickNewTime;
      return false;
    }
    return true;
  }
}
