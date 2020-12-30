import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';

// 动态详情页
class FeedDetailPage extends StatefulWidget {
  @override
  FeedDetailPageState createState() => FeedDetailPageState();
}

class FeedDetailPageState extends State<FeedDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          title: Text(
            "所在位置",
            style: TextStyle(color: AppColor.textPrimary1, fontSize: 18, fontWeight: FontWeight.w500),
          ),
          centerTitle: true,
          backgroundColor: AppColor.white,
          leading: GestureDetector(
              onTap: () {
                Navigator.of(context).pop(true);
              },
              child: Container(
                margin: EdgeInsets.only(left: 16),
                child: Image.asset(
                  "images/resource/2.0x/return2x.png",
                ),
              )),
          leadingWidth: 44.0,
          elevation: 0.5),
    );
  }
}
