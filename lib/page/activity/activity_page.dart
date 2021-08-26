import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/widget/custom_appbar.dart';

/// activity_page
/// Created by yangjiayi on 2021/8/25.

class ActivityPage extends StatefulWidget {
  @override
  _ActivityState createState() => _ActivityState();
}

class _ActivityState extends State<ActivityPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        hasLeading: false,
        titleString: "活动",
      ),
      body: Container(),
      backgroundColor: AppColor.mainBlack,
    );
  }
}
