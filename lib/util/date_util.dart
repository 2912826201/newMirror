
import 'package:intl/intl.dart';

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
    var stringWeekDayArray = ["一", "二", "三", "四", "五", "六", "日"];
    if (weekday < 0 || weekday >= stringWeekDayArray.length) {
      return stringWeekDayArray[0];
    } else {
      return stringWeekDayArray[weekday];
    }
  }

  //获取日期-今天返回今
  static String getDateDayStringJin(DateTime dateTime) {
    if (DateUtil.isToday(dateTime)) {
      return "今日";
    } else {
      return dateTime.day.toString();
    }
  }

  //获取今日的日期
  //列如：2020-12-10
  static String formatToDayDateString() {
    DateTime dateTime = new DateTime.now();
    return formatDateString(dateTime);
  }

  //获取提供日期的时间
  //列如：13:23
  static String formatTimeString(DateTime dateTime) {
    var formatter = new DateFormat('HH:mm');
    String formatted = formatter.format(dateTime);
    return formatted;
  }

  //获取提供日期的日期时间
  //列如：2020-12-10 13:23
  static String formatDateTimeString(DateTime dateTime) {
    var formatter = new DateFormat('yyyy-MM-dd HH:mm');
    String formatted = formatter.format(dateTime);
    return formatted;
  }

  //获取提供日期的日期
  //列如：2020-12-10
  static String formatDateString(DateTime dateTime) {
    var formatter = new DateFormat('yyyy-MM-dd');
    String formatted = formatter.format(dateTime);
    return formatted;
  }

  //获取提供日期的日期
  //列如：12月10日
  static String formatDateNoYearString(DateTime dateTime) {
    var formatter = new DateFormat('MM月dd日');
    String formatted = formatter.format(dateTime);
    return formatted;
  }

  //比较两个日期谁大
  //第一个大返回 true
  //第二个大返回 false
  static bool aDateCompareBDate(DateTime aDate, DateTime bDate) {
    return aDate.isAfter(bDate);
  }

  //传入时间与现在时间进行比较 看谁大
  //传入的时间大 返回true
  //传入的时间小 返回false
  static bool compareNowDate(DateTime value) {
    DateTime dateTime = new DateTime.now();
    return value.isAfter(dateTime);
  }

  //将字符串的时间转为dateTime
  static DateTime stringToDateTime(String dateString) {
    DateTime dateTime = DateTime.tryParse(dateString);
    return dateTime;
  }

  ///获取当前时间的毫秒级
  static int getNowDateMs() {
    return DateTime
        .now()
        .millisecondsSinceEpoch;
  }

  /// get DateTime By Milliseconds.
  static DateTime getDateTimeByMs(int ms, {bool isUtc = false}) {
    return ms == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(ms, isUtc: isUtc);
  }
}