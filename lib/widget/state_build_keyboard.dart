import 'dart:async';
import 'dart:math';

import 'package:flutter/widgets.dart';

abstract class StateKeyboard<T extends StatefulWidget> extends State<T> {
  //键盘的最大高度
  double _keyboardMaxHeight = 0;

  //键盘当前的高度
  double _currentKeyboardHeight = 0;

  //计时器 计算什么时候停止改变键盘的高度
  Timer _timerKeyBoard;

  //用计时器去计算键盘的高度
  double _timeKeyboardHeight = 0;

  //计时器计算的键盘高度与计时器当前的键盘高度保持一致的时间
  int _keyboardHeightKeepCurrentTime = 0;

  //是不是打开键盘  true-打开键盘  false-关闭键盘
  bool isOpenKeyboard = false;

  //是不是有一次结束了键盘的改变-证明有一次完整的打开了键盘
  bool _isHaveEndChangeKeyBoardHeight = false;

  //键盘的改变的状态
  ChangeKeyBoardHeightType _changeKeyBoardHeightType = ChangeKeyBoardHeightType.STATUS_CHANGE_COMPLETED;

  @override
  void initState() {
    super.initState();
  }

  @mustCallSuper
  @override
  Widget build(BuildContext context) {
    if (_currentKeyboardHeight < _getKeyboardHeight()) {
      //打开键盘中

      //设置当前键盘的高度
      _currentKeyboardHeight = _getKeyboardHeight();

      //设置键盘将要变成的状态--将要打开键盘-true
      isOpenKeyboard = true;

      //设置最大的键盘高度
      _setKeyboardMaxHeight();

      //当之前键盘的状态时改变完成-证明这是这次改变键盘高度的开始
      if (_changeKeyBoardHeightType == ChangeKeyBoardHeightType.STATUS_CHANGE_COMPLETED) {
        _startChangeKeyBoardHeight(isOpenKeyboard: true);
      }

      //设置键盘的状态
      _changeKeyBoardHeightType = ChangeKeyBoardHeightType.STATUS_CHANGE_LOADING;

      //当有一次结束改变键盘高度时-证明有了键盘最大高度
      //判断当前键盘高度是不是最大高度-是-发送结束键盘高度
      if (_currentKeyboardHeight == _keyboardMaxHeight && _isHaveEndChangeKeyBoardHeight) {
        _endChangeKeyBoardHeight(isOpenKeyboard: true);
      }
    } else if (_currentKeyboardHeight > _getKeyboardHeight()) {
      //关闭键盘中

      //设置当前键盘的高度
      _currentKeyboardHeight = _getKeyboardHeight();

      //设置键盘将要变成的状态--将要关闭键盘-false
      isOpenKeyboard = false;

      //当之前键盘的状态时改变完成-证明这是这次改变键盘高度的开始
      if (_changeKeyBoardHeightType == ChangeKeyBoardHeightType.STATUS_CHANGE_COMPLETED) {
        _startChangeKeyBoardHeight(isOpenKeyboard: false);
      }

      //设置键盘的状态
      _changeKeyBoardHeightType = ChangeKeyBoardHeightType.STATUS_CHANGE_LOADING;

      //当前键盘的高度是0时-证明是完成了关闭键盘-发送结束键盘高度
      if (_currentKeyboardHeight == 0) {
        _endChangeKeyBoardHeight(isOpenKeyboard: false);
      }
    }
    return const _NullWidget();
  }

  @override
  void dispose() {
    super.dispose();
    _closeTime();
  }

  //计时
  _initTime() {
    if (_timerKeyBoard != null) {
      return;
    }
    _timerKeyBoard = Timer.periodic(Duration(milliseconds: 1), (timer) {
      if (this.context != null && this.mounted) {
        if (_timeKeyboardHeight == _getKeyboardHeight()) {
          _keyboardHeightKeepCurrentTime++;
          if (_keyboardHeightKeepCurrentTime > 200) {
            _keyboardHeightKeepCurrentTime = 0;
            _endChangeKeyBoardHeight(isOpenKeyboard: isOpenKeyboard);
          }
        } else {
          _keyboardHeightKeepCurrentTime = 0;
        }
        _timeKeyboardHeight = _getKeyboardHeight();
      } else {
        _keyboardHeightKeepCurrentTime = 0;
      }
    });
  }

  double _getKeyboardHeight() => MediaQuery.of(this.context).viewInsets.bottom;

  _setKeyboardMaxHeight() => _keyboardMaxHeight = max(_keyboardMaxHeight, _getKeyboardHeight());

  _closeTime() {
    // print("关闭时间");
    if (_timerKeyBoard != null) {
      _timerKeyBoard.cancel();
      _timerKeyBoard = null;
      // print("关闭完毕");
    }
    // print("关闭完毕111111");
  }

  //开始改变键盘的高度
  void _startChangeKeyBoardHeight({@required bool isOpenKeyboard}) {
    _initTime();
    startChangeKeyBoardHeight(isOpenKeyboard);
    // print("开始改变键盘的高度isOpenKeyboard：$isOpenKeyboard,height:${_getKeyboardHeight()},keyboardMaxHeight:$_keyboardMaxHeight");
  }

  //结束改变键盘的高度
  void _endChangeKeyBoardHeight({@required bool isOpenKeyboard}) {
    _isHaveEndChangeKeyBoardHeight = true;
    _keyboardHeightKeepCurrentTime = 0;
    _closeTime();
    if (_getKeyboardHeight() != 0) {
      _keyboardMaxHeight = _getKeyboardHeight();
    }
    _changeKeyBoardHeightType = ChangeKeyBoardHeightType.STATUS_CHANGE_COMPLETED;
    // print("结束改变键盘的高度isOpenKeyboard：$isOpenKeyboard,height:${_getKeyboardHeight()},keyboardMaxHeight:$_keyboardMaxHeight");
    endChangeKeyBoardHeight(isOpenKeyboard);
  }

  //开始改变键盘的高度
  void startChangeKeyBoardHeight(bool isOpenKeyboard);

  //结束改变键盘的高度
  void endChangeKeyBoardHeight(bool isOpenKeyboard);
}

enum ChangeKeyBoardHeightType {
  //正在改变高度
  STATUS_CHANGE_LOADING,
  //改变完成
  STATUS_CHANGE_COMPLETED,
}

class _NullWidget extends StatelessWidget {
  const _NullWidget();

  @override
  Widget build(BuildContext context) {
    throw FlutterError(
      'Widgets that mix AutomaticKeepAliveClientMixin into their State must '
      'call super.build() but must ignore the return value of the superclass.',
    );
  }
}
