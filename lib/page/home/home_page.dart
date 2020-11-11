import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget{
  HomePage({Key key}) : super(key: key);
  HomePageState createState() => HomePageState();
}
class HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      // 设置背景色
      decoration: BoxDecoration(color: Colors.white),
      child: Container(),
    );
  }
}
