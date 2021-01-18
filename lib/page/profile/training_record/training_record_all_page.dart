import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/widget/no_blue_effect_behavior.dart';

class TrainingRecordAllPage extends StatefulWidget {
  @override
  _TrainingRecordAllPageState createState() => _TrainingRecordAllPageState();
}

class _TrainingRecordAllPageState extends State<TrainingRecordAllPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("所有的训练"),
        centerTitle: true,
      ),
      body: getBodyUi(),
    );
  }

  //获取界面
  Widget getBodyUi() {
    return Container(
      child: Column(
        children: [
          getTopUi(),
          Expanded(
              child: SizedBox(
            child: getListViewUi(),
          ))
        ],
      ),
    );
  }

  //获取listview
  Widget getListViewUi() {
    return ScrollConfiguration(
      behavior: NoBlueEffectBehavior(),
      child: ListView.builder(
        itemCount: 3,
        itemBuilder: (context, index) {
          return getListViewItemUi(index);
        },
      ),
    );
  }

  //获取item
  Widget getListViewItemUi(int index) {
    return Container(
      child: Column(
        children: [
          getDateUi(index),
          getSubListView(),
        ],
      ),
    );
  }

  Widget getSubListView() {
    var widgetArray = <Widget>[];
    int len = 5;
    for (int i = 0; i < len; i++) {
      widgetArray.add(Container(
        height: 147.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            getLineView(leftWidth: 0, rightWidth: 0),
            SizedBox(height: 22),
            Row(
              children: [
                Icon(Icons.access_time_sharp, size: 12, color: AppColor.textPrimary2),
                Text("1月5号"),
                Expanded(child: SizedBox()),
                Icon(Icons.access_time_sharp, size: 12, color: AppColor.textPrimary2),
                SizedBox(width: 4),
                Text("26分钟"),
                SizedBox(width: 10),
                Icon(Icons.access_time_sharp, size: 12, color: AppColor.textPrimary2),
                SizedBox(width: 4),
                Text("36千卡"),
              ],
            ),
            SizedBox(height: 18),
            Text("2021/01/06 16:48"),
            SizedBox(height: 11),
            Text("蜜桃臀打造训练"),
            SizedBox(height: 6),
            Text("第33次  13分钟  18千卡"),
            SizedBox(height: 12),
            Visibility(
              visible: i == len - 1,
              child: getLineView(leftWidth: 0, rightWidth: 0),
            ),
          ],
        ),
      ));
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            width: 1,
            height: len * 147.0,
            color: AppColor.textSecondary,
          ),
          Expanded(
              child: SizedBox(
            child: Column(
              children: widgetArray,
            ),
          )),
        ],
      ),
    );
  }

  //获取日期的item
  Widget getDateUi(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          getMark(index),
          Expanded(
              child: SizedBox(
            child: Column(
              children: [
                SizedBox(height: 28),
                Row(
                  children: [
                    Text("2020-1-1", style: TextStyle(fontSize: 16, color: AppColor.textPrimary1)),
                    Expanded(child: SizedBox()),
                    Icon(Icons.arrow_circle_up, size: 18),
                  ],
                ),
              ],
            ),
          ))
        ],
      ),
    );
  }

  //标识
  Widget getMark(int index) {
    return Container(
      width: 22,
      height: 56,
      child: Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: [
          Positioned(
            child: Visibility(
              visible: index != 0,
              child: Container(
                width: 1.0,
                height: 34,
                color: AppColor.textSecondary,
              ),
            ),
            top: 0,
          ),
          Container(
            width: 1.0,
            height: 25,
            color: AppColor.textSecondary,
          ),
          Positioned(
            child: Container(
              margin: const EdgeInsets.only(top: 31),
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: AppColor.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(width: 1, color: AppColor.textHint),
              ),
            ),
            top: 0,
          ),
        ],
      ),
    );
  }

  //获取顶部显示数据
  Widget getTopUi() {
    return Container(
      color: AppColor.bgWhite,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 48.0,
      alignment: Alignment.center,
      child: Row(
        children: [
          Text("全部", style: TextStyle(fontSize: 16, color: AppColor.textPrimary1)),
          Expanded(child: SizedBox()),
          Icon(Icons.access_time_sharp, size: 12, color: AppColor.textPrimary3),
          Text("99次", style: TextStyle(fontSize: 12, color: AppColor.textPrimary3)),
          SizedBox(width: 15),
          Icon(Icons.access_time_sharp, size: 12, color: AppColor.textPrimary3),
          Text("35分钟", style: TextStyle(fontSize: 12, color: AppColor.textPrimary3)),
          SizedBox(width: 15),
          Icon(Icons.access_time_sharp, size: 12, color: AppColor.textPrimary3),
          Text("1999千卡", style: TextStyle(fontSize: 12, color: AppColor.textPrimary3)),
        ],
      ),
    );
  }

  Widget getLineView({double leftWidth = 16.0, double rightWidth = 16.0}) {
    return Container(
      height: 1,
      margin: EdgeInsets.only(left: leftWidth, right: rightWidth),
      color: AppColor.bgWhite,
    );
  }
}
