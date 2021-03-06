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
      backgroundColor: AppColor.transparent,
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
      height: 379 + ScreenUtil.instance.bottomBarHeight,
      width: ScreenUtil.instance.width,
      padding: EdgeInsets.only(bottom: ScreenUtil.instance.bottomBarHeight),
      decoration: BoxDecoration(
        color: AppColor.layoutBgGrey,
        borderRadius: BorderRadius.only(topRight: Radius.circular(12), topLeft: Radius.circular(12)),
      ),
      child: Column(
        children: [
          Container(
            color: AppColor.layoutBgGrey,
            child: Column(
              children: [
                _titleWidget(),
                Row(
                  children: _timePickerList(),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 8,
          ),
          _bottomButton("??????"),
          _bottomButton("??????"),
        ],
      ),
    );
  }

  Widget _bottomButton(String title) {
    return GestureDetector(
      onTap: () {
        if (title == "??????") {
          endDateTimeList[fixedContrlList[2].selectedItem] = endDateTimeList[fixedContrlList[2].selectedItem]
              .add(Duration(minutes: -endDateTimeList[fixedContrlList[2].selectedItem].minute));
          endDateTimeList[fixedContrlList[2].selectedItem] = endDateTimeList[fixedContrlList[2].selectedItem]
              .add(Duration(minutes: endMinuteList[fixedContrlList[3].selectedItem]));
          widget.onStartAndEndTimeChoseCallBack(
              startDateTimeList[fixedContrlList[0].selectedItem], endDateTimeList[fixedContrlList[2].selectedItem]);
        }
        Navigator.pop(context);
      },
      child: Container(
        height: 44,
        width: ScreenUtil.instance.width,
        child: Center(
          child: Text(
            title,
            style: AppStyle.whiteRegular16,
          ),
        ),
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
                "????????????",
                style: AppStyle.text1Regular17,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                "????????????",
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
    timePickerList.add(_timePickerWidget("???", 0, dateList: startDateTimeList));
    timePickerList.add(_timePickerWidget("???", 1, minuteList: startMinuteList));
    timePickerList.add(_timePickerWidget("???", 2, dateList: endDateTimeList));
    timePickerList.add(_timePickerWidget("???", 3, minuteList: endMinuteList));
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
                fixedContrlList[3].animateToItem(0, duration: Duration(milliseconds: 100), curve: Curves.ease);
                break;
            }
          },
          children: List.generate(unit == "???" ? dateList.length : minuteList.length, (index) {
            return _timeItem(unit == "???" ? dateList[index].hour : minuteList[index], unit);
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
      //???????????????????????????,????????????????????????????????????????????????
      if (isToday) {
        startTime = DateTime.now().add(Duration(hours: 3));
      }
      int startMinute = startTime.minute;
      if (startMinute % 5 != 0) {
        startMinute = startMinute + (5 - startMinute % 5);
      }
      startDateTimeList[selectStartIndex] = startDateTimeList[selectStartIndex].add(Duration(minutes: startMinute));
    }
    _startMinuteListInit(
        startDateTimeList[fixedContrlList[0].selectedItem], endDateTimeList[fixedContrlList[2].selectedItem]);
    _scrollChangeNotify(fixedContrlList[0].selectedItem);
    fixedContrlList[1].jumpToItem(0);
    fixedContrlList[2].jumpToItem(0);
    fixedContrlList[3].jumpToItem(0);

    ///fixme ????????????????????????????????????????????????????????????????????????????????????????????????????????????item ?????????
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

    ///fixme ????????????????????????????????????????????????????????????????????????????????????????????????????????????item ?????????
    fixedContrlList[3].animateTo(0.1, duration: Duration(milliseconds: 100), curve: Curves.ease);
    fixedContrlList[2].animateTo(0.1, duration: Duration(milliseconds: 100), curve: Curves.ease);
  }

  _startHourListInit() {
    bool isTody = false;
    //????????????????????????6?????????22:00???
    int totalHour = 24 - 2;
    DateTime startTime = DateTime(widget.choseDateTime.year, widget.choseDateTime.month, widget.choseDateTime.day);
    if (widget.choseDateTime.day == DateTime.now().day) {
      isTody = true;
    }
    //???????????????????????????,????????????????????????????????????????????????
    if (isTody) {
      startTime = DateTime.now().add(Duration(hours: 3));
    }
    int startMinute = startTime.minute;
    if (startMinute % 5 != 0) {
      startMinute = startMinute + (5 - startMinute % 5);
    }
    int startHour = startTime.hour;
    //?????????????????????????????????????????????????????????????????????????????????????????????
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
    //???????????????????????????????????????????????????
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

  //??????dateTime???????????????????????????
  _startMinuteListInit(DateTime startTime, DateTime endTime) {
    startMinuteList.clear();
    int startMinute = startTime.minute;
    if (startTime.hour != 22) {
      for (int i = 0; i < (60 - startMinute) / 5; i++) {
        startMinuteList.add(startMinute + i * 5);
      }
      //?????????????????????22:00
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
    //?????????????????????11:30
    for (int i = 0; i < (endTime.hour == 23 ? 35 : 60 - endMinute) / 5; i++) {
      endMinuteList.add(endMinute + i * 5);
    }
  }
}
