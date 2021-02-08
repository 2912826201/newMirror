import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';

/// custom_appbar
/// Created by yangjiayi on 2021/2/2.

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  static const double appBarHeight = 44.0;
  static const double appBarIconPadding = 16.0;
  static const double appBarIconSize = 28.0;
  static const double appBarButtonWidth = 44.0;

  CustomAppBar(
      {Key key,
      this.titleWidget,
      this.titleString = "",
      this.actions = const [],
      this.backgroundColor = AppColor.mainBlue,
      this.brightness = Brightness.light,
      this.hasLeading = true,
      this.leading,
      this.leadingWidth,
      this.leadingOnTap,
      this.hasDivider = true})
      : super(key: key);

  final Widget titleWidget;
  final String titleString;
  final List<Widget> actions;
  final Color backgroundColor;
  final Brightness brightness;
  final bool hasLeading;
  final Widget leading;
  final double leadingWidth;
  final Function() leadingOnTap;
  final bool hasDivider;

  @override
  Size get preferredSize => Size.fromHeight(appBarHeight);

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      child: AppBar(
        title: titleWidget == null
            ? Text(
                titleString,
                style: AppStyle.textMedium18,
              )
            : titleWidget,
        actions: actions,
        elevation: hasDivider ? 0.5 : 0,
        backgroundColor: backgroundColor,
        brightness: brightness,
        centerTitle: true,
        leading: hasLeading
            ? leading == null
                ? CustomAppBarIconButton(
                    Icons.arrow_back_ios_outlined,
                    AppColor.black,
                    true,
                    leadingOnTap == null
                        ? () {
                            Navigator.pop(context);
                          }
                        : leadingOnTap)
                : leading
            : null,
        leadingWidth: leadingWidth == null ? appBarButtonWidth : leadingWidth,
        automaticallyImplyLeading: false,
      ),
      preferredSize: preferredSize,
    );
  }
}

class CustomAppBarIconButton extends StatefulWidget {
  CustomAppBarIconButton(this.icon, this.iconColor, this.isLeading, this.onTap, {Key key}) : super(key: key);

  final IconData icon;
  final Color iconColor;
  final bool isLeading;
  final Function() onTap;

  @override
  _CustomAppBarIconButtonState createState() => _CustomAppBarIconButtonState();
}

class _CustomAppBarIconButtonState extends State<CustomAppBarIconButton> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: CustomAppBar.appBarButtonWidth,
      //高度填充满整个AppBar
      height: CustomAppBar.appBarHeight,
      alignment: widget.isLeading ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        child: Icon(
          widget.icon,
          color: isPressed ? widget.iconColor.withOpacity(0.5) : widget.iconColor,
          size: CustomAppBar.appBarIconSize,
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
      ),
    );
  }
}

class CustomAppBarTextButton extends StatefulWidget {
  CustomAppBarTextButton(this.text, this.iconColor, this.isLeading, this.onTap, {Key key}) : super(key: key);

  final String text;
  final Color iconColor;
  final bool isLeading;
  final Function() onTap;

  @override
  _CustomAppBarTextButtonState createState() => _CustomAppBarTextButtonState();
}

class _CustomAppBarTextButtonState extends State<CustomAppBarTextButton> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      //高度填充满整个AppBar
      height: CustomAppBar.appBarHeight,
      alignment: Alignment.center,
      padding: widget.isLeading
          ? EdgeInsets.only(left: CustomAppBar.appBarIconPadding)
          : EdgeInsets.only(right: CustomAppBar.appBarIconPadding),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        child: Text(
          widget.text,
          style: TextStyle(
            fontSize: 16,
            color: isPressed ? widget.iconColor.withOpacity(0.5) : widget.iconColor,
          ),
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
      ),
    );
  }
}