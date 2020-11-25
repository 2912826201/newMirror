import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

class ScreenUtil {
  ScreenUtil._({
    this.width = 1080,
    this.height = 1920,
    this.allowFontScaling = false,
    // dp
    this.maxPhysicalSize = 480,
    this.bottomHeight = 0,
  });

  static void init(
      {double width = 1080,
      double height = 1920,
      bool allowFontScaling = false,
      double maxPhysicalSize = 480,
      double bottomHeight = 0}) {
    _instance = ScreenUtil._(
        width: width,
        height: height,
        allowFontScaling: allowFontScaling,
        maxPhysicalSize: maxPhysicalSize,
        bottomHeight: bottomHeight);
  }

  static ScreenUtil get instance => _instance;
  static ScreenUtil _instance;

  // 设计稿尺寸
  double width;
  double height;
  bool allowFontScaling; // 是否允许字体缩放
  double maxPhysicalSize; // 最高尺寸
  double bottomHeight; // 底部安全距离
  /**
   *  手机屏幕的物理分辨率
   */
  // 宽度
  double get _screenWidth => min(window.physicalSize.width, maxPhysicalSize);

  // 高度
  double get _screenHeight => window.physicalSize.height;

  // 设备像素比
  double get _pixelRatio => window.devicePixelRatio;

  // 状态栏高度 dp 刘海屏会更高
  double get _statusBarHeight => EdgeInsets.fromWindowPadding(window.padding, window.devicePixelRatio).top;

  // 底部安全区距离 dp
  double get _bottomBarHeight => EdgeInsets.fromWindowPadding(window.padding, window.devicePixelRatio).bottom;

  // 字体缩放比例
  double get _textScaleFactor => window.textScaleFactor;

  static MediaQueryData get mediaQueryData => MediaQueryData.fromWindow(window);

  ///每个逻辑像素的字体像素数，字体的缩放比例
  double get textScaleFactory => _textScaleFactor;

  ///设备的像素密度
  double get pixelRatio => _pixelRatio;

  ///当前设备宽度 dp
  double get screenWidthDp => _screenWidth;

  ///当前设备高度 dp
  double get screenHeightDp => _screenHeight;

  ///当前设备宽度 px
  double get screenWidth => _screenWidth * _pixelRatio;

  ///当前设备高度 px
  double get screenHeight => _screenHeight * _pixelRatio;

  ///状态栏高度 dp 刘海屏会更高
  double get statusBarHeight => _statusBarHeight;

  ///底部安全区距离 dp
  double get bottomBarHeight => bottomHeight;

  ///实际的dp与设计稿px的比例
  double get scaleWidth => _screenWidth / instance.width;

  double get scaleHeight => _screenHeight / instance.height;

  /*
  根据设计稿的设备宽度适配
   */
  double setWidth(double width) => width * scaleWidth;

  /*
  根据设计稿的设备高度适配
   */
  double setHeight(double height) => height * scaleHeight;

  ///字体大小适配方法
  ///@param fontSize 传入设计稿上字体的px ,
  ///@param allowFontScaling 控制字体是否要根据系统的“字体大小”辅助选项来进行缩放。默认值为false。
  ///@param allowFontScaling Specifies whether fonts should scale to respect Text Size accessibility settings. The default is false.
  double setSp(double fontSize) => allowFontScaling ? setWidth(fontSize) : setWidth(fontSize) / _textScaleFactor;
}
