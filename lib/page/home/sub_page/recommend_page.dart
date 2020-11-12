import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// 推荐
class RecommendPage extends StatefulWidget {
  RecommendPage({Key key}) : super(key: key);

  RecommendPageState createState() => RecommendPageState();
}

class RecommendPageState extends State<RecommendPage> {
  @override
  Widget build(BuildContext context) {
    double screen_top = MediaQuery.of(context).padding.top;
    return Container(
      margin: EdgeInsets.only(top: screen_top + 44),
      color: Colors.yellow,
    );
  }
}