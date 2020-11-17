import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

abstract class LoginBasePageState extends State<StatefulWidget> {
  var backButton;

  var skipButton;

  var hiddenSkip = true;
  var backBtnImage;

  final _backBtnImage = "images/test/back.png";

  @override
  void initState() {
    super.initState();
    backBtnImage ??= _backBtnImage;
    backButton = FlatButton(
      onPressed: reverseAction,
      child: Image.asset(backBtnImage),
      padding: EdgeInsets.all(0),
    );
    var skip = FlatButton(onPressed: skipAction, child: null);
    var opacity = hiddenSkip == true ? 0.0 : 1.0;
    skipButton = Opacity(
      opacity: opacity,
      child: skip,
    );
  }

  //构建头部导航栏
  navigationBar() {
    var leftbackBtn;
    leftbackBtn = SizedBox(
      child: backButton,
      height: 28,
      width: 28,
    );
    var bag = Row(
      children: [leftbackBtn],
    );
    return Container(
      child: bag,
      height: 48,
      padding: EdgeInsets.only(left: 16, top: 10, bottom: 10),
    );
  }

  //上一步
  @mustCallSuper
  reverseAction() {
    Navigator.pop(context);
  }

  //"跳过"触发函数
  skipAction() {}

  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
}
