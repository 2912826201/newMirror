import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/util/badger_util.dart';

class BadgerTestPage extends StatefulWidget {
  @override
  _BadgerTestPageState createState() => _BadgerTestPageState();
}

class _BadgerTestPageState extends State<BadgerTestPage> {
  int updateBadgeCount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("测试badger"),
      ),
      body: Container(
        child: Column(
          children: [
            SizedBox(height: 20),
            GestureDetector(
              child: Container(
                height: 50,
                width: 100,
                color: Colors.deepOrangeAccent,
                child: Text("updateBadgeCount"),
              ),
              onTap: () {
                BadgerUtil.init().updateBadgeCount(updateBadgeCount++);
              },
            ),
            SizedBox(height: 20),
            GestureDetector(
              child: Container(
                height: 50,
                width: 100,
                color: Colors.deepOrangeAccent,
                child: Text("removeBadge"),
              ),
              onTap: () {
                BadgerUtil.init().removeBadge();
              },
            ),
            SizedBox(height: 20),
            GestureDetector(
              child: Container(
                height: 50,
                width: 100,
                color: Colors.deepOrangeAccent,
                child: Text("isAppBadgeSupported"),
              ),
              onTap: () async {
                bool isAppBadgeSupported = await BadgerUtil.init().isAppBadgeSupported();
                print("isAppBadgeSupported:$isAppBadgeSupported");
              },
            ),
          ],
        ),
      ),
    );
  }
}
