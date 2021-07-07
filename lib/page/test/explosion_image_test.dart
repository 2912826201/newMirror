import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';

import 'explode_view/explode_view.dart';

class ExplosionImageTest extends StatefulWidget {
  @override
  _explosionImageTestState createState() => _explosionImageTestState();
}

class _explosionImageTestState extends State<ExplosionImageTest> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColor.white,
        body: Container(
            child: Stack(
          children: <Widget>[
            ExplodeView(imagePath: 'images/test/yxlm1.jpeg', imagePosFromLeft: 50.0, imagePosFromTop: 100.0),
            ExplodeView(imagePath: 'images/test/yxlm9.jpeg', imagePosFromLeft: 50, imagePosFromTop: 200.0),
            ExplodeView(imagePath: 'images/test/yxlm1.jpeg', imagePosFromLeft: 50.0, imagePosFromTop: 300.0)
          ],
        )));
  }
}
