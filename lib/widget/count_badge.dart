import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';

/// count_badge
/// Created by yangjiayi on 2020/12/21.

//计数的小红点

class CountBadge extends StatelessWidget {
  int count;
  double height;
  double fontSize;

  CountBadge(this.count, this.height, this.fontSize);

  @override
  Widget build(BuildContext context) {
    String text = count > 99 ? "99+" : "$count";
    double width = count > 99 ? 32.0 : count > 9 ? 28.0 : 18;
    return count == 0
        ? Container()
        : DecoratedBox(
            decoration: BoxDecoration(
                color: AppColor.mainRed,
                borderRadius: BorderRadius.all(Radius.circular(height / 2)),
                border: Border.all(color: AppColor.white, width: 1)),
            child: Container(
              alignment: Alignment.center,
              width: width,
              height: height,
              child: Text(
                text,
                style: TextStyle(fontSize: fontSize, color: AppColor.white),
              ),
            ),
          );
  }
}
