import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';

class ChatSystemBottomBar extends StatelessWidget {
  List<String> alertList = [
    "获取个人数据",
    "获取食谱",
    "获取今日课件",
    "其他操作",
    "其他操作",
    "其他操作",
    "其他操作"
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 48,
      // color: Colors.lightGreen,
      child: getBody(),
    );
  }

  Widget getBody() {
    return Container(
      width: double.infinity,
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: alertList.length,
        physics: BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          return getItem(alertList[index], index, alertList.length - 1);
        },
      ),
    );
  }

  Widget getItem(String text, int index, int len) {
    var firstMargin =
        const EdgeInsets.only(left: 15.5, top: 8, bottom: 8, right: 4);
    var commandMargin =
        const EdgeInsets.only(left: 4, top: 8, bottom: 8, right: 4);
    var endMargin =
        const EdgeInsets.only(left: 4, top: 8, bottom: 8, right: 15.5);
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: AppColor.white,
        ),
        margin: index == 0
            ? firstMargin
            : (index == len ? endMargin : commandMargin),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        height: 32,
        child: Center(
          child: Text(
            text,
            style: TextStyle(fontSize: 14, color: AppColor.black),
          ),
        ),
      ),
    );
  }
}
