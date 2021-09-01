import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/util/date_util.dart';

typedef OnTapChoseCallBack = void Function(DateTime);

class WeekPopWindow extends StatefulWidget {
  DateTime initDateTime;
  OnTapChoseCallBack onTapChoseCallBack;
  WeekPopWindow({this.initDateTime,this.onTapChoseCallBack});

  @override
  _WeekPopWindown createState() => _WeekPopWindown();
}

class _WeekPopWindown extends State<WeekPopWindow> {
  String _timeTitle = "";
  int choseIndex;
  DateTime choseDateTime;

  @override
  void initState() {
    super.initState();
    choseDateTime = widget.initDateTime;
    choseDateTime!=null?choseIndex = 0:choseIndex = -1;
  }

  _titleTimeInitData(DateTime firstDateTime) {
    //七天跨度，跨年显示两个年月时间戳，跨月前面显示年月后面显示月,当月内显示年月
    var sevenDayBefor = firstDateTime.add(Duration(days: 6));
    if (firstDateTime.year != sevenDayBefor.year) {
      _timeTitle = "${firstDateTime.year}年${firstDateTime.month}月-${sevenDayBefor.year}${sevenDayBefor.month}月";
    } else if (sevenDayBefor.month != firstDateTime.month) {
      _timeTitle = "${firstDateTime.year}年${firstDateTime.month}月-${sevenDayBefor.month}月";
    } else {
      _timeTitle = "${firstDateTime.year}年${firstDateTime.month}月";
    }
  }

  List<Widget> _weekListDataInit() {
    List<Widget> weekWidget = [];
    DateTime nowTime;
    //超过6点从明天开始算
    bool isToday = DateTime.now().hour <= 18;
    if (isToday) {
      nowTime = DateTime.now();
    } else {
      nowTime = DateTime.now().add(Duration(days: 1));
    }
    _titleTimeInitData(nowTime);
    weekWidget.add(
        _weekBox(isToday ? "今天" : "明天", "周" + DateUtil.getStringWeekDayStartZero(nowTime.weekday - 1), 0, nowTime));
    weekWidget.add(SizedBox(
      width: 8,
    ));
    for (int i = 1; i <= 6; i++) {
      DateTime dateTime = nowTime.add(Duration(days: i));
      if(choseDateTime!=null&&choseDateTime.day == dateTime.day) {
        choseIndex = i;
      }
      weekWidget.add(_weekBox(
          dateTime.day.toString(), "周" + DateUtil.getStringWeekDayStartZero(dateTime.weekday - 1), i, dateTime));
      if (i < 6) {
        weekWidget.add(SizedBox(
          width: 8,
        ));
      }
    }
    return weekWidget;
  }

  Widget _weekBox(String title, String week, int index, DateTime dateTime) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          choseIndex = index;
          choseDateTime = dateTime;
          setState(() {});
          widget.onTapChoseCallBack(dateTime);
          if(mounted)Navigator.pop(context);
        },
        child: Container(
            height: 51,
            padding: EdgeInsets.only(top: 6, bottom: 6),
            decoration: BoxDecoration(
                border:
                    Border.all(color: choseIndex == index ? AppColor.mainYellow : AppColor.transparent, width: 0.5)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: choseIndex == index?AppStyle.whiteRegular12:AppStyle.text1Regular12,
                ),
                Spacer(),
                Text(
                  week,
                  style: choseIndex == index?AppStyle.whiteRegular12:AppStyle.text1Regular12,
                ),
              ],
            )),
      ) /**/,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 113,
      width: double.infinity,
      margin: EdgeInsets.only(right: 16),
      padding: EdgeInsets.only(top: 6, left: 8, right: 8),
      decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(12)), color: AppColor.layoutBgGrey),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            _timeTitle,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColor.white,decoration:
            TextDecoration.none),
          ),
          SizedBox(
            height: 12,
          ),
          Row(
            children: _weekListDataInit(),
            crossAxisAlignment: CrossAxisAlignment.center,
          )
        ],
      ),
    );
  }
}
