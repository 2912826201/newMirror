import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

abstract class BasePageBehavior{
  uiInitialization();
  dataInitialization();
}
abstract class SteeringPageCapabilities extends BasePageBehavior{
  back();
  then();
  skip();
}

 class LogRegisterBasePageState extends State<StatefulWidget> implements SteeringPageCapabilities{
  FlatButton popBtn;
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
  uiInitialization(){
    popBtn = FlatButton(onPressed: back, child: null);
    skipBtn = FlatButton(onPressed: skip, child: null);
  }

  @mustCallSuper
  dataInitialization(){

  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }

  @override
  @mustCallSuper
  back() {
    Navigator.pop(context);
  }

  @override
  skip() {
  }

  @override
  then() {
  }



}