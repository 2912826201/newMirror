import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';

class LiveLabelWidget extends StatelessWidget {
  // 是否需要白边
  bool isWhiteBorder;

  LiveLabelWidget({this.isWhiteBorder = false});

  @override
  Widget build(BuildContext context) {
    Widget item = Container(
        alignment: Alignment.center,
        height: isWhiteBorder ? 15 : 13,
        width: isWhiteBorder ? 43 : 41,
        decoration: BoxDecoration(
            // 渐变色
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.topRight,
              colors: [
                Color.fromRGBO(0xFD, 0x86, 0x8A, 1.0),
                Color.fromRGBO(0xFE, 0x56, 0x68, 1.0),
                AppColor.mainRed,
              ],
            ),
            borderRadius: new BorderRadius.circular((8.5))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: 16,
              color: AppColor.white,
            ),
            Container(
              height: 10,
              child: const Text(
                "LIVE",
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColor.white),
              ),
            )
          ],
        ));
    if (isWhiteBorder) {
      return Container(
          height: 18,
          width: 46,
          decoration: BoxDecoration(color: AppColor.white, borderRadius: BorderRadius.circular((8.5))),
          child: Center(
            child: item,
          ));
    } else {
      return item;
    }
  }
}
