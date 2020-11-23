import 'dart:io';

import 'package:flutter/material.dart';

/// no_blue_effect_behavior
/// Created by yangjiayi on 2020/11/17.

// 用来去掉scrollview在安卓系统两端拉动出现的蓝色回弹效果
class NoBlueEffectBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    if (Platform.isAndroid || Platform.isFuchsia) {
      return child;
    } else {
      return super.buildViewportChrome(context, child, axisDirection);
    }
  }
}
