class ClickUtil {
  static int clickTime = 0;
  static int clickIntervalTime = 500;

  //判断是不是快速点击
  static bool isFastClick() {
    var clickNewTime = new DateTime.now().millisecondsSinceEpoch;
    if (clickNewTime - clickTime >= 500) {
      clickTime = clickNewTime;
      return false;
    }
    return true;
  }
}
