import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/util/screen_util.dart';

import 'bottom_sheet.dart';

typedef OnStartAndEndTimeChoseCallBack = void Function(DateTime, DateTime);

Future openActivityTimePickerBottomSheet(
    {@required BuildContext context,
    @required DateTime firstTime,
    OnStartAndEndTimeChoseCallBack onStartAndEndTimeChoseCallBack}) async {
  await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: AppColor.layoutBgGrey,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      builder: (BuildContext context) {
        return ActivityTimeBottomSheet(
          choseDateTime: firstTime,
          onStartAndEndTimeChoseCallBack: onStartAndEndTimeChoseCallBack,
        );
      });
}

class ActivityTimeBottomSheet extends StatefulWidget {
  DateTime choseDateTime;
  OnStartAndEndTimeChoseCallBack onStartAndEndTimeChoseCallBack;

  ActivityTimeBottomSheet({this.choseDateTime, this.onStartAndEndTimeChoseCallBack});

  @override
  State<StatefulWidget> createState() => _ActivityTimeBottomSheetState();
}

class _ActivityTimeBottomSheetState extends State<ActivityTimeBottomSheet> {
  List<FixedExtentScrollController> fixedContrlList = [];
  List<SwiperController> swiperContrlList = [];
  List<int> startMinuteList = [];
  List<int> endMinuteList = [];
  List<DateTime> startDateTimeList = [];
  List<DateTime> endDateTimeList = [];
  int selectStartIndex = 0;

  @override
  void initState() {
    super.initState();
    _initDate();
  }

  _initDate() {
    _startHourListInit();
    _endHourListInit(0, 0);
    _startMinuteListInit(startDateTimeList.first, endDateTimeList.first);
    _endMinuteListInit(startDateTimeList.first, endDateTimeList.first);
    fixedContrlList.add(FixedExtentScrollController());
    fixedContrlList.add(FixedExtentScrollController());
    fixedContrlList.add(FixedExtentScrollController());
    fixedContrlList.add(FixedExtentScrollController());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 255 + ScreenUtil.instance.bottomBarHeight,
      width: ScreenUtil.instance.width,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(topRight: Radius.circular(12), topLeft: Radius.circular(12)),
          color: AppColor.layoutBgGrey),
      child: Column(
        children: [
          _titleWidget(),
          Row(
            children: _timePickerList(),
          )
        ],
      ),
    );
  }

  Widget _titleWidget() {
    return Container(
      height: 45,
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                "开始时间",
                style: AppStyle.text1Regular17,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                "结束时间",
                style: TextStyle(fontSize: 17, color: AppColor.mainYellow, fontWeight: FontWeight.w400),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _timePickerList() {
    List<Widget> timePickerList = [];
    timePickerList.add(_timePickerWidget("时", 0, dateList: startDateTimeList));
    timePickerList.add(_timePickerWidget("分", 1, minuteList: startMinuteList));
    timePickerList.add(_timePickerWidget("时", 2, dateList: endDateTimeList));
    timePickerList.add(_timePickerWidget("分", 3, minuteList: endMinuteList));
    return timePickerList;
  }

  Widget _timePickerWidget(
    String unit,
    int concrlindex, {
    List<DateTime> dateList,
    List<int> minuteList,
  }) {
    return Container(
        height: 210,
        width: ScreenUtil.instance.width / 4,
        child: CupertinoPicker(
          backgroundColor: AppColor.layoutBgGrey,
          scrollController: fixedContrlList[concrlindex],
          squeeze: 0.95,
          diameterRatio: 1.5,
          itemExtent: 42,
          looping: false,
          selectionOverlay: null,
          onSelectedItemChanged: (index) {
            switch (concrlindex) {
              case 0:
                _startTimeChangeNotify(index);
                break;
              case 1:
                _startMinuteChangeNotify(index);
                break;
              case 2:
                _scrollChangeNotify(fixedContrlList[0].selectedItem);
                break;
              case 3:
                endDateTimeList[fixedContrlList[2].selectedItem] = endDateTimeList[fixedContrlList[2].selectedItem]
                    .add(Duration(milliseconds: -endDateTimeList[fixedContrlList[2].selectedItem].minute));
                endDateTimeList[fixedContrlList[2].selectedItem] =
                    endDateTimeList[fixedContrlList[2].selectedItem].add(Duration(milliseconds: endMinuteList[index]));
                break;
            }
            endDateTimeList[fixedContrlList[2].selectedItem] = endDateTimeList[fixedContrlList[2].selectedItem]
                .add(Duration(minutes: -endDateTimeList[fixedContrlList[2].selectedItem].minute));
            widget.onStartAndEndTimeChoseCallBack(
                startDateTimeList[fixedContrlList[0].selectedItem],endDateTimeList[fixedContrlList[2].selectedItem]
                .add(Duration(minutes: endMinuteList[fixedContrlList[3].selectedItem])) );
          },
          children: List.generate(unit == "时" ? dateList.length : minuteList.length, (index) {
            return _timeItem(unit == "时" ? dateList[index].hour : minuteList[index], unit);
          }),
        ));
  }

  Widget _timeItem(int time, String unit) {
    return Container(
      height: 42,
      width: ScreenUtil.instance.width / 4,
      child: Center(
        child: Text("$time$unit", style: AppStyle.whiteRegular15),
      ),
    );
  }

  _scrollChangeNotify(int index) {
    _endHourListInit(index, fixedContrlList[2].selectedItem);
    _endMinuteListInit(
      startDateTimeList[fixedContrlList[0].selectedItem],
      endDateTimeList[fixedContrlList[2].selectedItem],
    );
    setState(() {});
  }

  _startTimeChangeNotify(int index) {
    startDateTimeList[selectStartIndex] =
        startDateTimeList[selectStartIndex].add(Duration(minutes: -startDateTimeList[selectStartIndex].minute));
    selectStartIndex = index;
    if (index == 0) {
      bool isToday = false;
      DateTime startTime = DateTime(widget.choseDateTime.year, widget.choseDateTime.month, widget.choseDateTime.day);
      if (widget.choseDateTime.day == DateTime.now().day) {
        isToday = true;
      }
      //如果选择日期是今天,必须比当前时间晚三个小时开始活动
      if (isToday) {
        startTime = DateTime.now().add(Duration(hours: 3));
      }
      int startMinute = startTime.minute;
      if (startMinute % 5 != 0) {
        startMinute = startMinute + (5 - startMinute % 5);
      }
      startDateTimeList[selectStartIndex] = startDateTimeList[selectStartIndex].add(Duration(minutes: startMinute));
    }
    _scrollChangeNotify(fixedContrlList[0].selectedItem);
    _startMinuteListInit(
        startDateTimeList[fixedContrlList[0].selectedItem], endDateTimeList[fixedContrlList[2].selectedItem]);
    fixedContrlList[1].jumpToItem(0);
    fixedContrlList[2].jumpToItem(0);
    fixedContrlList[3].jumpToItem(0);

    ///fixme 这个控件会出现刷新不了显示数据条数的问题，需要手动偏移一点才能出现其余的item 待解决
    fixedContrlList[3].animateTo(0.1, duration: Duration(milliseconds: 100), curve: Curves.ease);
    fixedContrlList[2].animateTo(0.1, duration: Duration(milliseconds: 100), curve: Curves.ease);
    fixedContrlList[1].animateTo(0.1, duration: Duration(milliseconds: 100), curve: Curves.ease);
  }

  _startMinuteChangeNotify(int index) {
    startDateTimeList[fixedContrlList[0].selectedItem] = startDateTimeList[fixedContrlList[0].selectedItem]
        .add(new Duration(minutes: -startDateTimeList[fixedContrlList[0].selectedItem].minute));
    startDateTimeList[fixedContrlList[0].selectedItem] =
        startDateTimeList[fixedContrlList[0].selectedItem].add(new Duration(minutes: startMinuteList[index]));
    _scrollChangeNotify(fixedContrlList[0].selectedItem);

    ///fixme 这个控件会出现刷新不了显示数据条数的问题，需要手动偏移一点才能出现其余的item 待解决
    fixedContrlList[3].animateTo(0.1, duration: Duration(milliseconds: 100), curve: Curves.ease);
    fixedContrlList[2].animateTo(0.1, duration: Duration(milliseconds: 100), curve: Curves.ease);
  }

  _startHourListInit() {
    bool isTody = false;
    //活动开始时间最早6点最晚22:00点
    int totalHour = 24 - 2;
    DateTime startTime = DateTime(widget.choseDateTime.year, widget.choseDateTime.month, widget.choseDateTime.day);
    if (widget.choseDateTime.day == DateTime.now().day) {
      isTody = true;
    }
    //如果选择日期是今天,必须比当前时间晚三个小时开始活动
    if (isTody) {
      startTime = DateTime.now().add(Duration(hours: 3));
    }
    int startMinute = startTime.minute;
    if (startMinute % 5 != 0) {
      startMinute = startMinute + (5 - startMinute % 5);
    }
    int startHour = startTime.hour;
    //如果选择的日期不是今天或者今天但时间不到六点，就让它从六点开始
    if (startHour < 6) {
      startHour = 6;
    }
    for (int i = 0; i <= totalHour - startHour; i++) {
      DateTime dateTime = DateTime(startTime.year, startTime.month, startTime.day, startHour + i);
      if (dateTime.hour == startTime.hour) {
        dateTime = dateTime.add(Duration(minutes: startMinute));
      }
      startDateTimeList.add(dateTime);
    }
  }

  _endHourListInit(int startIndex, int endIndex) {
    endDateTimeList.clear();
    int endTotalHour = 24 - 1;
    int starHour = startDateTimeList[startIndex].hour;
    DateTime startTime = startDateTimeList[startIndex];
    int endStartTime = starHour;
    //结束时间必须比开始时间至少晚半小时
    if (startTime.minute > 30) {
      endStartTime = starHour + 1;
    }
    if (endDateTimeList.isNotEmpty && endDateTimeList[endIndex].hour != startTime.hour) {
      endStartTime = starHour;
    }
    for (int i = 0; i <= endTotalHour - endStartTime; i++) {
      DateTime dateTime = DateTime(startTime.year, startTime.month, startTime.day, endStartTime + i);
      if (dateTime.hour == startTime.hour) {
        dateTime = dateTime.add(Duration(minutes: startTime.minute + 30));
      }
      endDateTimeList.add(dateTime);
    }
  }

  //根据dateTime获取对应的分钟列表
  _startMinuteListInit(DateTime startTime, DateTime endTime) {
    startMinuteList.clear();
    int startMinute = startTime.minute;
    if (startTime.hour != 22) {
      for (int i = 0; i < (60 - startMinute) / 5; i++) {
        startMinuteList.add(startMinute + i * 5);
      }
      //开始时间最晚为22:00
    } else {
      startMinuteList.add(0);
    }
  }

  _endMinuteListInit(DateTime startTime, DateTime endTime) {
    endMinuteList.clear();
    int endMinute;
    if (startTime.minute + 30 > 60 && endTime.hour - startTime.hour == 1) {
      endMinute = (startTime.minute + 30) - 60;
    } else {
      endMinute = endTime.minute;
    }
    //最晚时间为晚上11:30
    for (int i = 0; i < (endTime.hour == 23 ? 35 : 60 - endMinute) / 5; i++) {
      endMinuteList.add(endMinute + i * 5);
    }
  }
}
