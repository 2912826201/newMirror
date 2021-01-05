import 'package:flutter/material.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:mirror/constant/color.dart';

/// seekbar
/// Created by yangjiayi on 2021/1/4.

class AppSeekBar extends StatelessWidget {
  AppSeekBar(this.max, this.min, this.value, this.disabled, this.onDragging, this.onDragCompleted, {Key key})
      : super(key: key);

  final double max;
  final double min;
  final double value;
  final bool disabled;
  final Function(int handlerIndex, dynamic lowerValue, dynamic upperValue) onDragging;
  final Function(int handlerIndex, dynamic lowerValue, dynamic upperValue) onDragCompleted;

  @override
  Widget build(BuildContext context) {
    return FlutterSlider(
      disabled: disabled,
      values: [value],
      max: 100,
      min: 0,
      trackBar: FlutterSliderTrackBar(
        activeTrackBar: BoxDecoration(
          color: AppColor.textPrimary2,
        ),
        inactiveTrackBar: BoxDecoration(
          color: AppColor.bgWhite,
        ),
        activeTrackBarHeight: 2,
        inactiveTrackBarHeight: 2,
        activeDisabledTrackBarColor: AppColor.textHint,
        inactiveDisabledTrackBarColor: AppColor.bgWhite,
      ),
      handlerAnimation: FlutterSliderHandlerAnimation(scale: 1),
      handler: FlutterSliderHandler(
          child: Container(),
          decoration: BoxDecoration(
              color: AppColor.white,
              shape: BoxShape.circle,
              border: Border.all(width: 2, color: disabled ? AppColor.textHint : AppColor.textPrimary2))),
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
