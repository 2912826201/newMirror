class ClickUtil {
  static int clickTime = 0;
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
}
