import 'package:flutter/material.dart';

/// test_page
/// Created by yangjiayi on 2020/10/27.

class TestPage extends StatefulWidget {
  @override
  _TestState createState() => _TestState();
}

class _TestState extends State<TestPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("测试页"),
      ),
      body: Center(
        child: Text("测试用页面，可随意添加组件"),
      ),
    );
  }
}
