import 'package:flutter/cupertino.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';

class DetailStartTimeUi extends StatefulWidget {
  final int times;
  final int status;

  DetailStartTimeUi(this.times, this.status);

  @override
  _DetailStartTimeUiState createState() => _DetailStartTimeUiState();
}

class _DetailStartTimeUiState extends State<DetailStartTimeUi> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        filterTags(widget.status),
        SizedBox(width: 12),
        Row(
          children: _getTimerUi(),
        )
      ],
    );
  }

  filterTags(int status) {
    Widget cotainer = Container();
    if (status == 0 || status == 1) {
      cotainer = Container(
        width: 50,
        height: 18,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: status == 1 ? AppColor.mainBlue : AppColor.mainGreen,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Text(
          NumberParsedText(status),
          style: AppStyle.whiteRegular10,
        ),
      );
    } else if (status == 3) {
      cotainer = Container(
        width: 55,
        height: 18,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColor.textWhite60,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Text(
          NumberParsedText(status),
          style: AppStyle.whiteRegular10,
        ),
      );
    } else if (status == 2) {
      cotainer = Container(
        width: 53,
        height: 21,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColor.layoutBgGrey,
          border: Border.all(color: AppColor.mainYellow, width: 0.5),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Container(
          width: 50,
          height: 18,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColor.mainYellow,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Text(NumberParsedText(status), style: TextStyle(fontSize: 10, color: AppColor.mainBlack)),
        ),
      );
    }
    return cotainer;
  }

  // 活动状态数字解析文字
  NumberParsedText(int ctivityEnum) {
    int activity = ctivityEnum;
    String activityText;
    switch (activity) {
      case 0:
        activityText = "召集中";
        break;
      case 1:
        activityText = "召集满";
        break;
      case 2:
        activityText = "进行中";
        break;
      case 3:
        activityText = "活动结束";
        break;
    }
    return activityText;
  }

  List<Widget> _getTimerUi() {
    if (widget.times == null || widget.times < 1) {
      return [Container()];
    }
    List<Widget> widgetArray = [];
    int time = widget.times ~/ 1000;
    int day = time ~/ 60 ~/ 60 ~/ 24;
    time = time - day * 24 * 60 * 60;
    int hour = time ~/ 60 ~/ 60;
    time = time - hour * 60 * 60;
    int minute = time ~/ 60;

    if (day == 0 && hour == 0 && minute == 0) {
      return [Container()];
    }

    if (day != 0) {
      widgetArray.add(getBox(day.toString(), AppStyle.yellowRegular16));
      widgetArray.add(getBox("天", AppStyle.whiteRegular14));
    }
    if (hour != 0 || day != 0) {
      widgetArray.add(getBox(hour.toString(), AppStyle.yellowRegular16));
      widgetArray.add(getBox("时", AppStyle.whiteRegular14));
    }
    if ((minute != 0 && day == 0) || (hour != 0 && day == 0)) {
      widgetArray.add(getBox(minute.toString(), AppStyle.yellowRegular16));
      widgetArray.add(getBox("分", AppStyle.whiteRegular14));
    }
    widgetArray.add(SizedBox(width: 1));
    widgetArray.add(getBox("开始", AppStyle.whiteRegular14, null, false));
    return widgetArray;
  }

  Widget getBox(String title, TextStyle textStyle, [double width = 23, bool isDecoration = true]) {
    return Container(
      margin: EdgeInsets.only(left: 1),
      height: 20,
      width: width,
      // decoration: isDecoration
      //     ? BoxDecoration(
      //         color: AppColor.white.withOpacity(0.1),
      //         borderRadius: BorderRadius.circular(4),
      //       )
      //     : null,
      alignment: Alignment.center,
      child: Text(title, style: textStyle),
    );
  }
}
