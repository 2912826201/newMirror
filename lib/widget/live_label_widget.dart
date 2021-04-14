import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';

class LiveLabelWidget extends StatelessWidget {
  // 是否需要白边
  final bool isWhiteBorder;

  LiveLabelWidget({this.isWhiteBorder = false});

  @override
  Widget build(BuildContext context) {
    Widget item = Container(
      alignment: Alignment.center,
      height: 16,
      width: 44,
      decoration: ShapeDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.topRight,
          colors: [
            Color.fromRGBO(0xFD, 0x86, 0x8A, 1.0),
            Color.fromRGBO(0xFE, 0x56, 0x68, 1.0),
            AppColor.mainRed,
          ],
        ),
        shape: StadiumBorder(side: BorderSide.none),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 16,
            height: 16,
            alignment: Alignment.center,
            child: _AnimatedBars(),
          ),
          Text(
            "LIVE",
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColor.white),
          ),
          SizedBox(
            width: 2,
          ),
        ],
      ),
    );
    if (isWhiteBorder) {
      return Container(
        height: 19,
        width: 47,
        decoration: ShapeDecoration(color: AppColor.white, shape: StadiumBorder(side: BorderSide.none)),
        child: Center(
          child: item,
        ),
      );
    } else {
      return item;
    }
  }
}

//竖条动画
class _AnimatedBars extends StatefulWidget {
  @override
  _AnimatedBarsState createState() => _AnimatedBarsState();
}

class _AnimatedBarsState extends State<_AnimatedBars> {
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
      height: 10,
      width: 10,
      alignment: Alignment.bottomCenter,
      child: getWidgetArray(),
    );
  }

  Widget getWidgetArray() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
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
    timer = Timer.periodic(duration, (timer) {
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
