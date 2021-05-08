import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
///list用不显示底部水波纹，解决ios回弹效果 ，可套在刷新控件使用
class OverScrollBehavior extends ScrollBehavior{

  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    switch (getPlatform(context)) {
      case TargetPlatform.iOS:
        return GlowingOverscrollIndicator(
          child: child,
          //不显示头部水波纹
          showLeading: false,
          //不显示尾部水波纹
          showTrailing: false,
          axisDirection: axisDirection,
          color: Theme.of(context).accentColor,
        );
      case TargetPlatform.android:
        return GlowingOverscrollIndicator(
          child: child,
          //不显示头部水波纹
          showLeading: false,
          //不显示尾部水波纹
          showTrailing: false,
          axisDirection: axisDirection,
          color: Theme.of(context).accentColor,
        );
      case TargetPlatform.fuchsia:
        return GlowingOverscrollIndicator(
          child: child,
          //不显示头部水波纹
          showLeading: false,
          //不显示尾部水波纹
          showTrailing: false,
          axisDirection: axisDirection,
          color: Theme.of(context).accentColor,
        );
    }
    return null;
  }
@override//解决ios回弹效果
  ScrollPhysics getScrollPhysics(BuildContext context) {
  switch (getPlatform(context)) {
    case TargetPlatform.iOS:
      return const ClampingScrollPhysics();
    case TargetPlatform.android:
      return const ClampingScrollPhysics();
    case TargetPlatform.fuchsia:
      return const ClampingScrollPhysics();
    case TargetPlatform.linux:
      // TODO: Handle this case.
      break;
    case TargetPlatform.macOS:
      // TODO: Handle this case.
      break;
    case TargetPlatform.windows:
      // TODO: Handle this case.
      break;
  }
  return null;
  }
}