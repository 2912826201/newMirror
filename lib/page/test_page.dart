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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("测试用页面，可随意添加组件"),
            Image(
              image: AssetImage("images/test.png"),
              color: Colors.redAccent,
              colorBlendMode: BlendMode.darken,
              width: 100.0,
              height: 100.0,
            ),
            Image(
              image: NetworkImage("http://i2.hdslb.com/bfs/face/c2d82a7e6512a85657e997dc8f84ab538e87a8cc.jpg"),
              width: 100.0,
              height: 100.0,
            ),
          ],
        ),
      ),
    );
  }
}
