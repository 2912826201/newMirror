import 'dart:math';

import 'package:intl/intl.dart';

class DateUtil {
  /// 将秒转换为中文
  /// return 时-分-秒
  static String formatSecondToStringCn(int ms) {
    if (ms < 60) {
      return ms.toString() + "秒";
    } else {
      int hour = ms ~/ 3600;
      int minute = ms % 3600 ~/ 60;
      int second = ms % 60;
      if (hour > 0) {
        return "$hour时$minute分$second秒";
      } else if (minute > 0) {
        return "$minute分$second秒";
      } else {
        return "$second秒";
      }
    }
  }

  // MARK: - 把毫秒数转换成
  /*
   1分钟之类都显示刚刚

   1小时之内的动态，显示 2分钟前，59分钟前；

   在1-24小时期间的显示 n小时前。

   超过24小时则显示“昨天 时分 ”，如 昨天 14:21 ；

   超过48小时则显示为月日 时分 ，如07-08  7:21；

   往年的显示 年-月-⽇ 如 16-5-21 12:12
   */
  static String getGenerateFormatDate(int timeInterval, bool showText) {
    var result = "";
    if (timeInterval == 0) {
      return result;
    }
    var time = timeInterval;
    // 当前时间戳
    var currentDate = DateTime.now();
    // 传入时间戳转DateTime
    var date = getDateTimeByMs(time);
    // 当传入时间大于当前时间时的容错处理
    if (DateUtil.compareNowDate(date)) {
      date = currentDate;
    }
    String alertString = "";
    String yearFull = "yyyy-MM-dd";
    String hourFull = "H:mm";
    String monthFull = "M-d";
    if (showText) {
      yearFull = "yyyy年MM月dd日";
      hourFull = "HH时mm分";
      monthFull = "MM月dd日";
    }
    if (isBefor(date)) {
      alertString += "刚刚";
    }else if(twoDateTimeMinutes(date, new DateTime.now()) < 60){
      alertString += "${twoDateTimeMinutes(date, new DateTime.now())}分钟前";
    } else if(twoDateTimeHours(date, new DateTime.now())<24){
      alertString += "${twoDateTimeHours(date, new DateTime.now())}小时前";
    }else if (isYesterday(date)) {
      alertString += "昨天";
      alertString += " ${formatDateV(date, format: hourFull)}";
    } else if (isToYear(date)) {
      alertString += formatDateV(date, format: monthFull);
      alertString += " ${formatDateV(date, format: hourFull)}";
    }else{
      alertString += formatDateV(date, format: yearFull);
      alertString += " ${formatDateV(date, format: hourFull)}";
    }
    return alertString;
  }

  //将秒数转换为天数
  static String formatSecondToDay(int ms) {
    if (ms == null) {
      return "今天";
    }
    int daySecond = 60 * 60 * 24;
    int day = ms % daySecond > 0 ? ms ~/ daySecond + 1 : ms ~/ daySecond;
    if (day <= 1) {
      return "今天";
    }
    return "${day}天";
  }

  /// 将秒转换为数字 01:12
  /// 显示分-00:01-----没有小时
  static String formatSecondToStringNumShowMinute1(int ms) {
    if (ms < 60) {
      if (ms < 10) {
        return "00:0" + ms.toString();
      }
      return "00:" + ms.toString();
    } else {
      int hour = ms ~/ 3600;
      int minute = ms % 3600 ~/ 60 + hour * 60;
      int second = ms % 60;
      if (minute > 0) {
        return "${minute > 10 ? minute : "0" + minute.toString()}:${second > 10 ? second : "0" + second.toString()}";
      } else {
        return "00:${second > 10 ? second : "0" + second.toString()}";
      }
    }
  }

  /// 将秒转换为数字 01:12
  /// 显示分-00:01--有小时
  static String formatSecondToStringNumShowMinute(int ms) {
    if (ms < 60) {
      if (ms < 10) {
        return "00:0" + ms.toString();
      }
      return "00:" + ms.toString();
    } else {
      int hour = ms ~/ 3600;
      int minute = ms % 3600 ~/ 60;
      int second = ms % 60;
      if (hour > 0) {
        return "${hour > 10 ? hour : "0" + hour.toString()}:"
            "${minute > 10 ? minute : "0" + minute.toString()}:"
            "${second > 10 ? second : "0" + second.toString()}";
      } else if (minute > 0) {
        return "${minute > 10 ? minute : "0" + minute.toString()}:${second > 10 ? second : "0" + second.toString()}";
      } else {
        return "00:${second > 10 ? second : "0" + second.toString()}";
      }
    }
  }

  /// 将秒转换为数字 01:12
  /// 不显示分-01
  static String formatSecondToStringNumNoShowMinute(int ms) {
    if (ms < 60) {
      if (ms < 10) {
        return "0" + ms.toString();
      }
      return ms.toString();
    } else {
      int hour = ms ~/ 3600;
      int minute = ms % 3600 ~/ 60;
      int second = ms % 60;
      if (hour > 0) {
        return "${hour > 10 ? hour : "0" + hour.toString()}:"
            "${minute > 10 ? minute : "0" + minute.toString()}:"
            "${second > 10 ? second : "0" + second.toString()}";
      } else if (minute > 0) {
        return "${minute > 10 ? minute : "0" + minute.toString()}:${second > 10 ? second : "0" + second.toString()}";
      } else {
        return "${second > 10 ? second : "0" + second.toString()}";
      }
    }
  }

  /// 分钟-秒 01'12''
  /// 不显示时 01
  /// ms 毫秒级
  static String formatMinuteSecond(int ms) {
    ms ~/= 1000;
    if (ms < 60) {
      if (ms < 10) {
        return "00'0$ms''";
      }
      return "00'$ms''";
    } else {
      int hour = ms ~/ 3600;
      int minute = ms % 3600 ~/ 60;
      int second = ms % 60;
      if (hour > 0 || minute > 0) {
        int timeMinute = minute + hour * 60;
        return "${timeMinute > 10 ? timeMinute : "0" + timeMinute.toString()}"
            "'${second > 10 ? second : "0" + second.toString()}''";
      } else {
        return "00'${second > 10 ? second : "0" + second.toString()}''";
      }
    }
  }

  //获取聊天框内消息提示的格式
  //---小时数，十位数为0时，不显示十位
  //
  // ---分钟数，十位要显示0
  //
  // ---今日消息显示为：时分 如  8：05
  //
  // ---昨天、前天：x天 + 时分，昨天： 昨天 23:59； 前天： 前天 15:01
  //
  // ---三天以前，7天之内：星期X+时分
  //
  // ---超过7天显示年-月-日+时分  如：  2021年7月7 日 00:00
  static String formatMessageAlertTime(String millisecondsSinceEpoch) {
    DateTime dateTime = getDateTimeByMs(int.parse(millisecondsSinceEpoch));
    String alertString = "";
    String yearFull = "yyyy-M-d";
    String hourFull = "H:mm";
    if (isToday(dateTime)) {
      alertString += "";
    } else if (isYesterday(dateTime)) {
      alertString += "昨天";
    } else if (isTheDayBeforeYesterday(dateTime)) {
      alertString += "前天";
    } else if (judgeDateTimeIsInScanDay(dateTime, 7)) {
      alertString += "星期${getStringWeekDayStartZero(dateTime.weekday - 1)}";
    } else {
      alertString += formatDateV(dateTime, format: yearFull);
    }
    alertString += " ${formatDateV(dateTime, format: hourFull)}";
    return alertString;
  }

  //获取评论的日期显示
  //- 1分钟之类的动态都显示刚刚
  //
  // - 1小时之内的动态，显示 2分钟前，59分钟前；
  //
  // - 在1-24小时期间的显示 n小时前
  //
  // - 超过24小时，7天之内则显示：“1天前，2天前，7天前 ”
  //
  // - 超过7天，日期在今年内，则显示为月+日：如 8月12日
  //
  // - 往年的显示 年-月-日 如 2020年10月5日
  static String getCommentShowData(DateTime dateTime) {
    DateTime time = new DateTime.now();
    String alertString = "";
    if (twoDateTimeMinutes(dateTime, time) <= 1) {
      return "刚刚";
    } else if (twoDateTimeMinutes(dateTime, time) < 60) {
      return "${twoDateTimeMinutes(dateTime, new DateTime.now())}分钟前";
    } else if (isToday(dateTime)) {
      return "${twoDateTimeHours(dateTime, new DateTime.now())}小时前";
    } else if (judgeDateTimeIsInScanDay(dateTime, 7)) {
      return "${twoDateTimeDay(dateTime, time)}天前";
    }
    if (isToYear(dateTime)) {
      alertString += formatDateV(dateTime, format: "M月dd日");
    } else {
      alertString += formatDateV(dateTime, format: "yyyy年MM月dd日");
    }
    // alertString += " ${formatDateV(dateTime, format: "HH:mm")}";
    return alertString;
  }

  //会话列表
  //获取消息界面-消息列表的日期展示
  //①今日消息展示时分：15:57
  //
  // ②昨日消息展示：昨天
  //
  // ③前天-7日内消息展示星期几（如今天是周五，最远到上周六）：星期三
  //
  // ④7日前消息展示年月日：2019-10-20
  static String getShowMessageDateString(DateTime dateTime) {
    // DateTime time=new DateTime.now();
    if (isToday(dateTime)) {
      return formatDateV(dateTime, format: "H:mm");
    } else if (isYesterday(dateTime)) {
      return "昨天";
    } else if (isTheDayBeforeYesterday(dateTime)) {
      return "前天";
    } else if (judgeDateTimeIsInScanDay(dateTime, 7)) {
      // return "${dateTime.weekday>time.weekday?"上":""}周${getStringWeekDayStartZero(dateTime.weekday-1)}";
      return "星期${getStringWeekDayStartZero(dateTime.weekday - 1)}";
    } else {
      return formatDateV(dateTime, format: "yyyy-MM-dd");
    }
  }

  //指定时间的相差分秒
  //字符串时间 2021-03-18 10:04:30
  static String getSpecifyDateTimeDifferenceMinutesAndSeconds(String specifDateTime) {
    if (specifDateTime == null) {
      return "0";
    }
    DateTime dateTime = stringToDateTime(specifDateTime);
    DateTime nowDateTime = DateTime.now();
    int seconds = nowDateTime.millisecondsSinceEpoch - dateTime.millisecondsSinceEpoch;
    seconds ~/= 1000;
    if (seconds <= 0) {
      return "0";
    }
    return "${seconds ~/ 60}:${seconds % 60 < 10 ? "0${seconds % 60}" : seconds % 60}";
  }

  //将毫秒秒数格式化为 分数:秒数 的格式 一位数前补0
  static String formatMillisecondToMinuteAndSecond(int time) {
    //这里其实可以用正则补0 先自己判断了
    int minute = (time / 60000).floor();
    int second = (time % 60000 / 1000).floor();
    String minuteStr;
    String secondStr;
    if (minute < 10) {
      minuteStr = "0$minute";
    } else {
      minuteStr = "$minute";
    }
    if (second < 10) {
      secondStr = "0$second";
    } else {
      secondStr = "$second";
    }
    return "$minuteStr:$secondStr";
  }

  ///---------日期时间比较------------start

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

  //比较两个日期是否等于同一天
  //第一个大返回 true
  //第二个大返回 false
  static bool aDateEqualBDate(DateTime aDate, DateTime bDate) {
    return aDate.year == bDate.year && aDate.month == bDate.month && aDate.day == bDate.day;
  }

  //获取两个时间的秒数相差数
  static int twoDateTimeSeconds(DateTime aDate, DateTime bDate) {
    return ((bDate.millisecondsSinceEpoch - aDate.millisecondsSinceEpoch) / 1000) ~/ 1;
  }

  //获取两个时间的分钟相差数
  static int twoDateTimeMinutes(DateTime aDate, DateTime bDate) {
    return ((bDate.millisecondsSinceEpoch - aDate.millisecondsSinceEpoch) / 1000 / 60) ~/ 1;
  }

  //获取两个时间的时钟相差数
  static int twoDateTimeHours(DateTime aDate, DateTime bDate) {
    return ((bDate.millisecondsSinceEpoch - aDate.millisecondsSinceEpoch) / 1000 / 60 / 60) ~/ 1;
  }

  //获取两个时间的天数相差数7天之内的
  static int twoDateTimeDay(DateTime aDate, DateTime bDate) {
    if (aDateEqualBDate(aDate, bDate)) {
      return 0;
    }
    DateTime bigDate;
    DateTime smallDate;
    if (aDateCompareBDate(aDate, bDate)) {
      bigDate = aDate;
      smallDate = bDate;
    } else {
      bigDate = bDate;
      smallDate = aDate;
    }
    int countDay = 0;
    DateTime dateTime = smallDate;
    while (!aDateEqualBDate(bigDate, dateTime)) {
      countDay++;
      dateTime = smallDate.add(Duration(days: countDay));
      if (countDay > 7) {
        print("时间有问题：$bigDate,$smallDate");
        break;
      }
    }
    return min(7, countDay);
  }

  //判断输入的日期是否在今天这个日期的输入天数内
  static bool judgeDateTimeIsInScanDay(DateTime dateTime, int day) {
    DateTime toDayTime = new DateTime.now();
    DateTime time = toDayTime.add(Duration(days: -(day - 1)));
    if (aDateCompareBDate(dateTime, time)) {
      return true;
    } else if (aDateEqualBDate(toDayTime, time)) {
      return true;
    } else {
      return false;
    }
  }

  //判断这个时间是不是两分钟内的时间
  static bool judgeTwoMinuteNewDateTime(DateTime dateTime, {int minutes = 2}) {
    if (!compareNowDate(dateTime)) {
      DateTime newDateTime = dateTime.add(new Duration(minutes: minutes));
      if (compareNowDate(newDateTime)) {
        return true;
      }
    }
    return false;
  }

  ///---------日期时间比较------------end

  ///-----------根据日期获取需要的数据---------------start

  //将字符串的时间转为dateTime
  static DateTime stringToDateTime(String dateString) {
    try {
      DateTime dateTime = DateTime.tryParse(dateString);
      return dateTime;
    } catch (e) {
      return new DateTime.now();
    }
  }

  /// get DateTime By Milliseconds.
  static DateTime getDateTimeByMs(int ms, {bool isUtc = false}) {
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms, isUtc: isUtc);
  }

  static DateTime getDataTimeString(int year, int month, int day) {
    //aDate.year == bDate.year && aDate.month == bDate.month && aDate.day == bDate.day;
  }

  ///获取当前时间的毫秒级
  static int getNowDateMs() {
    return DateTime.now().millisecondsSinceEpoch;
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

  //获取日期-是几天前-今日返回今日
  static String getDateDayString(DateTime dateTime) {
    if (DateUtil.isToday(dateTime)) {
      return "今日";
    } else {
      var difference = new DateTime.now().difference(dateTime);
      if (difference.inHours > new DateTime.now().hour) {
        return "${difference.inDays + 1}天前";
      } else {
        return "${difference.inDays}天前";
      }
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

  //获取提供日期的日期
  //列如：12月10日
  static String formatDateNoYearString1(DateTime dateTime) {
    return "${dateTime.month}月${dateTime.day}日";
  }

  ///-----------根据日期获取需要的数据---------------end

  ///-------------------------判断是不是哪一个日期-------------start

  /// 是否是今天.
  static bool isToday(DateTime old) {
    if (old == null) return false;
    DateTime now = DateTime.now().toLocal();
    return aDateEqualBDate(old, now);
  }

  ///是否是刚刚
  static bool isBefor(DateTime old) {
    if (old == null) return false;
    if (twoDateTimeMinutes(old, new DateTime.now()) < 1) {
      return true;
    }
    return false;
  }

  /// 是否是昨天.
  static bool isYesterday(DateTime old) {
    if (old == null) return false;
    DateTime now = DateTime.now().add(Duration(days: -1));
    return aDateEqualBDate(old, now);
  }

  /// 是否是前天.
  static bool isTheDayBeforeYesterday(DateTime old) {
    if (old == null) return false;
    DateTime now = DateTime.now().add(Duration(days: -2));
    return aDateEqualBDate(old, now);
  }

  /// 是否是今年.
  static bool isToYear(DateTime old) {
    if (old == null) return false;
    DateTime now = DateTime.now();
    return old.year == now.year;
  }

  ///-------------------------判断是不是哪一个日期-------------end

  ///------------------------工具

  static String full = "yyyy-MM-dd HH:mm:ss";

  static String formatDateV(DateTime dateTime, {bool isUtc, String format}) {

    if (dateTime == null) return "";
    format = format ?? full;
    if (format.contains("yy")) {
      String year = dateTime.year.toString();
      if (format.contains("yyyy")) {
        format = format.replaceAll("yyyy", year);
      } else {
        format = format.replaceAll("yy", year.substring(year.length - 2, year.length));
      }
    }

    format = _comFormat(dateTime.month, format, 'M', 'MM');
    format = _comFormat(dateTime.day, format, 'd', 'dd');
    format = _comFormat(dateTime.hour, format, 'H', 'HH');
    format = _comFormat(dateTime.minute, format, 'm', 'mm');
    format = _comFormat(dateTime.second, format, 's', 'ss');
    format = _comFormat(dateTime.millisecond, format, 'S', 'SSS');

    return format;
  }

  static String _comFormat(int value, String format, String single, String full) {
    if (format.contains(single)) {
      if (format.contains(full)) {
        format = format.replaceAll(full, value < 10 ? '0$value' : value.toString());
      } else {
        format = format.replaceAll(single, value.toString());
      }
    }
    return format;
  }

  //活动界面时间显示规则实现
  static String activityTimeToString(int timeTemp) {
    String timeString = "";
    DateTime dateTime = getDateTimeByMs(timeTemp);
    timeString = formatTimeString(dateTime);
    timeString += " ";
    timeString += formatDateNoYearString(dateTime);
    timeString += " ";
    timeString += "周${getStringWeekDayStartZero(dateTime.weekday - 1)}";
    return timeString;
  }
}
