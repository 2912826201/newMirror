import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

abstract class BasePageBehavior {
  //ui的初始化
  uiInitialization();
  //数据的初始化
  dataInitialization();
}

abstract class SteeringPageCapabilities extends BasePageBehavior {
  //返回
  back();
  //下一步
  then();
 //跳过
  skip();
}

class LoginBasePageState extends State<StatefulWidget> implements SteeringPageCapabilities {
  //回退按钮
  FlatButton popBtn;
  //跳过按钮
  FlatButton skipBtn;
  int popBtnOpaque = 0;
  int skitBtnOpaque = 0;

  @override
  void initState() {
    super.initState();
    dataInitialization();
    uiInitialization();
  }

  @mustCallSuper
  uiInitialization() {
    popBtn = FlatButton(onPressed: back, child: null);
    skipBtn = FlatButton(onPressed: skip, child: null);
  }

  @mustCallSuper
  dataInitialization() {}

  @override
  Widget build(BuildContext context) {}

  @override
  @mustCallSuper
  back() {
    Navigator.pop(context);
  }

  @override
  skip() {}

  @override
  then() {}
}
