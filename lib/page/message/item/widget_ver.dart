import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';

//竖条动画
class WidgetVer extends StatefulWidget {
  @override
  _WidgetVerState createState() => _WidgetVerState();
}

class _WidgetVerState extends State<WidgetVer> {
  Duration duration;
  Timer timer;
  List<double> intLenArray = [8.0, 10.0, 6.0];

  @override
  void initState() {
    super.initState();
    _initTimeDuration();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: getWidgetArray(),
    );
  }

  Widget getWidgetArray() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        getWidget(intLenArray[0], 2),
        SizedBox(
          width: 2,
        ),
        getWidget(intLenArray[1], 2),
        SizedBox(
          width: 2,
        ),
        getWidget(intLenArray[2], 2),
      ],
    );
  }

  //每一个条
  Widget getWidget(double height, double width) {
    return AnimatedContainer(
      height: height,
      duration: Duration(milliseconds: 200),
      child: Container(
        height: height,
        width: width,
        color: AppColor.white,
      ),
    );
  }

  //监听动画是否开始
  void _initTimeDuration() {
    duration = Duration(milliseconds: 200);
    Timer.periodic(duration, (timer) {
      try {
        double temp;
        temp = intLenArray[0];
        intLenArray[0] = intLenArray[1];
        intLenArray[1] = intLenArray[2];
        intLenArray[2] = temp;
        setState(() {});
      } catch (e) {
        if (timer != null) {
          timer.cancel();
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (timer != null) {
      timer.cancel();
    }
  }
}
