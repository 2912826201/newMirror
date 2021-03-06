import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/util/check_phone_system_util.dart';

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
          //NOTE Android上垂直居中会偏上一点。。。所以单独处理一下 加个margin
          Container(
            height: CheckPhoneSystemUtil.init().isAndroid() ? 15 : 16,
            alignment: Alignment.center,
            margin: EdgeInsets.only(top: CheckPhoneSystemUtil.init().isAndroid() ? 1 : 0),
            child: Text(
              "LIVE",
              style: AppStyle.whiteMedium10,
            ),
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

  StreamController<int> _streamController = StreamController<int>();

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
      child: StreamBuilder<int>(
          initialData: 0,
          stream: _streamController.stream,
          builder: (BuildContext stramContext, AsyncSnapshot<int> snapshot) {
            return getWidgetArray(snapshot.data);
          }),
    );
  }

  Widget getWidgetArray(int tick) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        getWidget(intLenArray[(0 + tick) % 3], 2),
        SizedBox(
          width: 2,
        ),
        getWidget(intLenArray[(1 + tick) % 3], 2),
        SizedBox(
          width: 2,
        ),
        getWidget(intLenArray[(2 + tick) % 3], 2),
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
        _streamController.sink.add(timer.tick);
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
