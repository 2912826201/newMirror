import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mirror/constant/color.dart';

/// icon
/// Created by yangjiayi on 2021/2/23.

class AppIcon {
  static const String nav_return = "assets/svg/nav_return.svg";
  static const String nav_close = "assets/svg/nav_close.svg";
  static const String login_phone = "assets/svg/login_phone.svg";
  static const String login_apple = "assets/svg/login_apple.svg";
  static const String login_qq = "assets/svg/login_qq.svg";
  static const String login_wechat = "assets/svg/login_wechat.svg";
  static const String add_circle_black = "assets/svg/add_circle_black.svg";
  static const String clear_circle_grey = "assets/svg/clear_circle_grey.svg";
  static const String arrow_right = "assets/svg/arrow_right.svg";

  static const String qrcode_scan = "assets/svg/qrcode_scan.svg";
  static const String machine_connected = "assets/svg/machine_connected.svg";
  static const String machine_disconnected = "assets/svg/machine_disconnected.svg";

  static Widget getAppIcon(String svgName, double iconSize,
      {double containerHeight, double containerWidth, Color color, Color bgColor, bool isCircle}) {
    if (containerHeight == null) {
      containerHeight = iconSize;
    }
    if (containerWidth == null) {
      containerWidth = iconSize;
    }
    if (bgColor == null) {
      bgColor = AppColor.transparent;
    }
    if (isCircle == null) {
      isCircle = false;
    }
    return Container(
      height: containerHeight,
      width: containerWidth,
      color: isCircle ? null : bgColor,
      decoration: isCircle
          ? BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            )
          : null,
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
    this.iconColor,
    this.bgColor = AppColor.transparent,
    this.isCircle = false,
    this.onTap,
  })  : assert(icon != null || svgName != null),
        assert(iconSize != null),
        super(key: key);

  final IconData icon;
  final String svgName;
  final Color iconColor;
  final Color bgColor;
  final Function() onTap;
  final double iconSize;
  final double buttonHeight;
  final double buttonWidth;
  final bool isCircle;

  @override
  _AppIconButtonState createState() => _AppIconButtonState();
}

class _AppIconButtonState extends State<AppIconButton> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: isPressed
          ? Opacity(
              opacity: 0.5,
              child: widget.icon != null ? _buildIcon() : _buildAppIcon(),
            )
          : widget.icon != null
              ? _buildIcon()
              : _buildAppIcon(),
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

  Widget _buildIcon() {
    return Container(
      width: widget.buttonWidth == null ? widget.iconSize : widget.buttonWidth,
      height: widget.buttonHeight == null ? widget.iconSize : widget.buttonHeight,
      color: widget.isCircle
          ? null
          : widget.bgColor,
      decoration: widget.isCircle
          ? BoxDecoration(
              color: widget.bgColor,
              shape: BoxShape.circle,
            )
          : null,
      alignment: Alignment.center,
      child: Icon(
        widget.icon,
        color: widget.iconColor,
        size: widget.iconSize,
      ),
    );
  }

  Widget _buildAppIcon() {
    return AppIcon.getAppIcon(
      widget.svgName,
      widget.iconSize,
      containerHeight: widget.buttonHeight == null ? widget.iconSize : widget.buttonHeight,
      containerWidth: widget.buttonWidth == null ? widget.iconSize : widget.buttonWidth,
      color: widget.iconColor,
      bgColor: widget.bgColor,
      isCircle: widget.isCircle,
    );
  }
}
