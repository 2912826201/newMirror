import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mirror/constant/color.dart';

/// icon
/// Created by yangjiayi on 2021/2/23.

class AppIcon {
  static const String nav_return = "assets/svg/nav_return.svg";

  static Widget getAppIcon(String svgName, double iconSize,
      {double containerHeight, double containerWidth, Color color}) {
    if (containerHeight == null) {
      containerHeight = iconSize;
    }
    if (containerWidth == null) {
      containerWidth = iconSize;
    }
    if (color == null) {
      color = AppColor.black;
    }
    return Container(
      height: containerHeight,
      width: containerWidth,
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

class AppIconButton extends StatefulWidget {
  AppIconButton({
    Key key,
    this.icon,
    this.svgName,
    @required this.iconSize,
    this.buttonHeight,
    this.buttonWidth,
    this.iconColor = AppColor.black,
    this.onTap,
  })  : assert(iconColor != null || svgName != null),
        assert(iconSize != null),
        super(key: key);

  final IconData icon;
  final String svgName;
  final Color iconColor;
  final Function() onTap;
  final double iconSize;
  final double buttonHeight;
  final double buttonWidth;

  @override
  _AppIconButtonState createState() => _AppIconButtonState();
}

class _AppIconButtonState extends State<AppIconButton> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: widget.icon != null
          ? Container(
        width: widget.buttonWidth == null? widget.iconSize : widget.buttonWidth,
        height: widget.buttonHeight == null? widget.iconSize : widget.buttonHeight,
        alignment: Alignment.center,
        child: Icon(
          widget.icon,
          color: isPressed ? widget.iconColor.withOpacity(0.5) : widget.iconColor,
          size: widget.iconSize,
        ),
      )
          : AppIcon.getAppIcon(
        widget.svgName,
        widget.iconSize,
        containerHeight: widget.buttonHeight == null? widget.iconSize : widget.buttonHeight,
        containerWidth: widget.buttonWidth == null? widget.iconSize : widget.buttonWidth,
        color: isPressed ? widget.iconColor.withOpacity(0.5) : widget.iconColor,
      ),
      onTapDown: (details) {
        setState(() {
          isPressed = true;
        });
      },
      onTapUp: (details) {
        setState(() {
          isPressed = false;
        });
      },
      onTapCancel: () {
        setState(() {
          isPressed = false;
        });
      },
      onTap: widget.onTap,
    );
  }
}