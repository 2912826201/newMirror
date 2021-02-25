import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mirror/constant/color.dart';

/// icon
/// Created by yangjiayi on 2021/2/23.

class AppIcon {
  static const String nav_return = "assets/svg/nav_return.svg";

  static Widget getAppIcon(String svgName, double iconSize, {@required double containerSize, @required Color color}) {
    if (containerSize == null) {
      containerSize = iconSize;
    }
    if (color == null) {
      color = AppColor.black;
    }
    return Container(
      height: containerSize,
      width: containerSize,
      alignment: Alignment.center,
      child: SvgPicture.asset(
        svgName,
        height: iconSize,
        width: iconSize,
        color: color,
      ),
    );
  }
}
