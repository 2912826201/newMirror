import 'package:dough/dough.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mirror/constant/color.dart';
import 'dart:math' as math;

import 'package:mirror/page/activity/activity_page.dart';
import 'package:mirror/page/message/widget/dragball.dart';
import 'package:mirror/route/router.dart';

class FloatingBottonTestPage extends StatefulWidget {
  FloatingBottonTestPage({Key key}) : super(key: key);

  @override
  _FloatingBottonTestPageState createState() => new _FloatingBottonTestPageState();
}

class _FloatingBottonTestPageState extends State<FloatingBottonTestPage> {
  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dragball(
      withIcon: false,
      ball: Container(
        child: PressableDough(
            child: FloatingActionButton(
          child: const Icon(
            Icons.add,
            size: 25,
          ),
          foregroundColor: AppColor.mainBlack,
          backgroundColor: AppColor.white,
          elevation: 7.0,
          highlightElevation: 14.0,
          isExtended: false,
          onPressed: () {
            AppRouter.navigateCreateActivityPage(context);
          },
          mini: true,
        )),
      ),
      ballSize: 50,
      startFromRight: true,
      initialTop: MediaQuery.of(context).size.height * 0.75,
      onTap: () {
        print('点击了悬浮图标');
        Navigator.of(context).push(new MaterialPageRoute(builder: (context) {
          return ActivityPage();
        }));
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Dragball Example'),
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemBuilder: (BuildContext context, int index) {
            return Container(
              height: 200,
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
            );
          },
          itemCount: 15,
        ),
      ),
    );
  }
}
