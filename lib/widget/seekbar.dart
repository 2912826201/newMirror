import 'package:flutter/material.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:mirror/constant/color.dart';

/// seekbar
/// Created by yangjiayi on 2021/1/4.

class AppSeekBar extends StatelessWidget {
  AppSeekBar(
    this.max,
    this.min,
    this.value,
    this.disabled,
    this.onDragging,
    this.onDragCompleted, {
    Key key,
    this.activeTrackBarColor = AppColor.imageBgGrey,
    this.inactiveTrackBarColor = AppColor.bgWhite,
    this.activeDisabledTrackBarColor = AppColor.textHint,
    this.inactiveDisabledTrackBarColor = AppColor.bgWhite,
    this.handler1Color = AppColor.textHint,
    this.handler2Color = AppColor.imageBgGrey,
  }) : super(key: key);

  final double max;
  final double min;
  final double value;
  final bool disabled;
  final Function(int handlerIndex, dynamic lowerValue, dynamic upperValue) onDragging;
  final Function(int handlerIndex, dynamic lowerValue, dynamic upperValue) onDragCompleted;
  final Color activeTrackBarColor;
  final Color inactiveTrackBarColor;
  final Color activeDisabledTrackBarColor;
  final Color inactiveDisabledTrackBarColor;
  final Color handler1Color;
  final Color handler2Color;

  @override
  Widget build(BuildContext context) {
    return FlutterSlider(
      disabled: disabled,
      values: [value],
      max: 100,
      min: 0,
      trackBar: FlutterSliderTrackBar(
        activeTrackBar: BoxDecoration(
          color: activeTrackBarColor,
        ),
        inactiveTrackBar: BoxDecoration(
          color: inactiveTrackBarColor,
        ),
        activeTrackBarHeight: 2,
        inactiveTrackBarHeight: 2,
        activeDisabledTrackBarColor: activeDisabledTrackBarColor,
        inactiveDisabledTrackBarColor: inactiveDisabledTrackBarColor,
      ),
      handlerAnimation: FlutterSliderHandlerAnimation(scale: 1),
      handler: FlutterSliderHandler(
          child: Container(),
          decoration: BoxDecoration(
              color: AppColor.white,
              shape: BoxShape.circle,
              border: Border.all(width: 2, color: disabled ? handler1Color : handler2Color))),
      handlerHeight: 12,
      handlerWidth: 12,
      tooltip: FlutterSliderTooltip(
        disabled: true,
      ),
      onDragCompleted: onDragCompleted,
      onDragging: onDragging,
    );
  }
}
