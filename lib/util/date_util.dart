

class DateUtil{


  /// 是否是今天.
  static bool isToday(DateTime old) {
    if (old == null) return false;
    DateTime now = DateTime.now().toLocal();
    return old.year == now.year && old.month == now.month && old.day == now.day;
  }

  /// 返回这个日期是周几
  /// 从零开始的
  static String getStringWeekDayStartZero(int weekday) {
    var stringWeekDayArray=["周一","周二","周三","周四","周五","周六","周日"];
    if(weekday<0||weekday>=stringWeekDayArray.length){
      return stringWeekDayArray[0];
    }else{
      return stringWeekDayArray[weekday];
    }
  }

  //获取日期-今天返回今
  static String getDateDayStringJin(DateTime dateTime){
    if(DateUtil.isToday(dateTime)){
      return "今";
    }else{
      return dateTime.day.toString();
    }
  }
}