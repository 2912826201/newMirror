import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/util/screen_util.dart';

import 'icon.dart';

/// custom_appbar
/// Created by yangjiayi on 2021/2/2.

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  static const double appBarHeight = 44.0;
  static const double appBarHorizontalPadding = 8.0;
  static const double appBarIconPadding = 16.0;
  static const double appBarIconSize = 28.0;
  static const double appBarButtonWidth = 44.0;

  CustomAppBar(
      {Key key,
      this.titleWidget,
      this.titleString = "",
      this.subtitleString,
      this.actions = const [],
      this.backgroundColor = AppColor.white,
      this.brightness = Brightness.light,
      this.hasLeading = true,
      this.leading,
      this.leadingOnTap,
      this.hasDivider = true})
      : super(key: key);

  final Widget titleWidget;
  final String titleString;
  final String subtitleString;
  final List<Widget> actions;
  final Color backgroundColor;
  final Brightness brightness;
  final bool hasLeading;
  final Widget leading;
  final Function() leadingOnTap;
  final bool hasDivider;

  @override
  Size get preferredSize => Size.fromHeight(appBarHeight);

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      child: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  hasLeading
                      ? leading == null
                          ? CustomAppBarIconButton(
                              // icon: Icons.arrow_back_ios_outlined,
                              svgName: AppIcon.nav_return,
                              iconColor: brightness == Brightness.light ? AppColor.black : AppColor.white,
                              onTap: leadingOnTap == null
                                  ? () {
                                      Navigator.pop(context);
                                    }
                                  : leadingOnTap)
                          : leading
                      : Container(),
                ],
              ),
            ),
            Container(
              child: Row(
                children: [
                  Container(
                    constraints: BoxConstraints(
                      //82是红色按钮最大宽度
                      maxWidth: ScreenUtil.instance.width-(appBarIconPadding + 82)*2.0,
                    ),
                    child: titleWidget == null
                        ? Text(
                      titleString,
                      style: brightness == Brightness.light ? AppStyle.textMedium18 : AppStyle.whiteMedium18,
                    )
                        : titleWidget,
                  ),
                  Visibility(
                    visible: subtitleString!=null,
                    child: Text(
                      subtitleString??"",
                      style: brightness == Brightness.light ? AppStyle.textMedium18 : AppStyle.whiteMedium18,
                    ),
                  ),
                ],
              )
            ),
            Expanded(
              flex: 1,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: actions == null ? [] : actions,
              ),
            ),
          ],
        ),
        elevation: hasDivider ? 0.5 : 0,
        backgroundColor: backgroundColor,
        brightness: brightness,
        centerTitle: true,
        leading: null,
        titleSpacing: appBarHorizontalPadding,
        automaticallyImplyLeading: false,
      ),
      preferredSize: preferredSize,
    );
  }
}

class CustomAppBarIconButton extends StatelessWidget {
  CustomAppBarIconButton({
    Key key,
    this.icon,
    this.svgName,
    this.iconColor = AppColor.black,
    this.onTap,
  })  : assert(iconColor != null || svgName != null),
        super(key: key);

  final IconData icon;
  final String svgName;
  final Color iconColor;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return AppIconButton(
      icon: icon,
      svgName: svgName,
      iconSize: CustomAppBar.appBarIconSize,
      iconColor: iconColor,
      buttonHeight: CustomAppBar.appBarHeight,
      buttonWidth: CustomAppBar.appBarButtonWidth,
      onTap: onTap,
    );
  }
}

class CustomAppBarTextButton extends StatefulWidget {
  CustomAppBarTextButton(this.text, this.textColor, this.onTap, {Key key}) : super(key: key);

  final String text;
  final Color textColor;
  final Function() onTap;

  @override
  _CustomAppBarTextButtonState createState() => _CustomAppBarTextButtonState();
}

class _CustomAppBarTextButtonState extends State<CustomAppBarTextButton> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Container(
        //高度填充满整个AppBar
        height: CustomAppBar.appBarHeight,
        alignment: Alignment.center,
        padding: const EdgeInsets.only(
            left: CustomAppBar.appBarHorizontalPadding, right: CustomAppBar.appBarHorizontalPadding),
        child: Text(
          widget.text,
          style: TextStyle(
            fontSize: 16,
            color: isPressed ? widget.textColor.withOpacity(0.5) : widget.textColor,
          ),
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
    );
  }
}
