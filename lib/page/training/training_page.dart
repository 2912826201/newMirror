import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/util/screen_util.dart';

import '../test_page.dart';

class TrainingPage extends StatefulWidget {
  @override
  _TrainingState createState() => _TrainingState();
}

class _TrainingState extends State<TrainingPage> {
  double _screenWidth = 0.0;

  @override
  void initState() {
    _screenWidth = ScreenUtil.instance.screenWidthDp;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            leading: null,
            title: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("训练"),
              ],
            )
        ),
        body: _buildTopView()
    );
  }

  //我的课程列表上方的所有部分
  Widget _buildTopView() {
    return Column(
      children: [
        _buildBanner(),

      ],
    );
  }

  Widget _buildBanner() {
    return Container(
      height: _screenWidth * 140 / 375,
      color: AppColor.bgBlack,
      child: Center(
        child: RaisedButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return TestPage();
            }));
          },
          child: Text("去测试页"),
        ),
      ),
    );
  }
}
