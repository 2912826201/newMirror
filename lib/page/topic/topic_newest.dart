import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';

class TopicNewest extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Container(
        color: AppColor.bgWhite,
        child: Text(
        "最新",
        style: TextStyle(color: Colors.white, fontSize: 20),
        )
    );
  }

}