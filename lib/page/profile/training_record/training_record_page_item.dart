import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/route/router.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

LoadingStatus _loadingStatus;
int _itemCountListView;
RefreshController _refreshController;
BuildContext _context;
VoidCallback _onLoading;
String _typeString;

//判断加载什么界面
Widget trainingRecordPageItem(BuildContext context, String typeString, VoidCallback onLoading,
    RefreshController refreshController, int itemCountListView, LoadingStatus loadingStatus) {
  _context = context;
  _typeString = typeString;
  _onLoading = onLoading;
  _itemCountListView = itemCountListView;
  _refreshController = refreshController;

  if (loadingStatus == LoadingStatus.STATUS_LOADING) {
    return getLoadUi(context);
  } else if (loadingStatus == LoadingStatus.STATUS_IDEL) {
    return getNoDataUi(context);
  } else {
    return getHaveDataUi();
  }
}

//有数据的ui
Widget getHaveDataUi() {
  List<Widget> slivers = <Widget>[];

  if (_typeString == "总") {
    slivers.add(getTopUi());
    slivers.add(getAllTrainingUi());
    slivers.add(getSpec(12));
    slivers.add(getLineView());
  } else {
    slivers.add(getTopUi());
    slivers.add(getHorizontalListView());
    slivers.add(getTrainAllCountUi());
    slivers.add(getLineView());
    slivers.add(getSpec(12));
    slivers.add(getVerticalListView());
  }

  return CustomScrollView(
    slivers: slivers,
  );
}

Widget getAllTrainingUi() {
  return SliverToBoxAdapter(
    child: Container(
      margin: const EdgeInsets.only(top: 32, left: 16, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("训练共 5 次", style: TextStyle(color: AppColor.textPrimary3, fontSize: 16)),
          SizedBox(height: 21),
          GestureDetector(
            child: Container(
              color: AppColor.transparent,
              child: Row(
                children: [
                  Text("查看所有训练", style: TextStyle(color: AppColor.textPrimary1, fontSize: 16)),
                  Expanded(child: SizedBox()),
                  Icon(Icons.arrow_forward_ios_sharp, size: 18, color: AppColor.textHint),
                ],
              ),
            ),
            onTap: () {
              AppRouter.navigateToTrainingRecordAllPage(_context);
            },
          ),
        ],
      ),
    ),
  );
}

//获取竖向的listView
Widget getVerticalListView() {
  return SliverList(
    delegate: SliverChildBuilderDelegate((content, index) {
      return getVerticalListViewItem(index);
    }, childCount: 10),
  );
}

//获取竖向的listViewItem
Widget getVerticalListViewItem(int index) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("2021/01/06 16:48", style: TextStyle(fontSize: 12, color: AppColor.textPrimary3)),
        SizedBox(height: 11),
        Text("蜜桃臀打造训练"),
        SizedBox(height: 6),
        Text("第33次  13分钟  18千卡", style: TextStyle(fontSize: 12, color: AppColor.textSecondary)),
        Container(
          height: 1,
          color: AppColor.bgWhite,
        ),
      ],
    ),
  );
}

//获取训练次数的ui
Widget getTrainAllCountUi() {
  return SliverToBoxAdapter(
    child: Container(
      margin: const EdgeInsets.only(left: 16, right: 16, top: 32, bottom: 0),
      height: 71.0,
      child: Row(
        children: [
          Container(
            child: Icon(Icons.sports_baseball_sharp, color: AppColor.textPrimary1, size: 24),
          ),
          SizedBox(width: 12),
          Expanded(
              child: SizedBox(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("训练共2次",
                    style: TextStyle(fontSize: 16, color: AppColor.textPrimary1, fontWeight: FontWeight.bold)),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("1月6日", style: TextStyle(fontSize: 14, color: AppColor.textPrimary3)),
                    Expanded(child: SizedBox()),
                    Icon(Icons.access_time_sharp, size: 16, color: AppColor.textHint),
                    SizedBox(width: 2),
                    Text("35分钟", style: TextStyle(fontSize: 12, color: AppColor.textPrimary3)),
                    SizedBox(width: 15),
                    Icon(Icons.local_fire_department, size: 16, color: AppColor.textHint),
                    SizedBox(width: 2),
                    Text("88千卡", style: TextStyle(fontSize: 12, color: AppColor.textPrimary3)),
                  ],
                ),
              ],
            ),
          )),
        ],
      ),
    ),
  );
}

Widget getLineView() {
  return SliverToBoxAdapter(
    child: Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      color: AppColor.bgWhite,
    ),
  );
}

Widget getSpec(double height) {
  return SliverToBoxAdapter(
    child: Container(
      height: height,
    ),
  );
}

//获取横向列表
Widget getHorizontalListView() {
  return SliverToBoxAdapter(
    child: Container(
      height: 175.0,
      child: SmartRefresher(
        enablePullDown: false,
        enablePullUp: true,
        footer: CustomFooter(
          builder: (BuildContext context, LoadStatus mode) {
            return Container();
          },
        ),
        controller: _refreshController,
        onLoading: _onLoading,
        scrollDirection: Axis.horizontal,
        child: ListView.builder(
          reverse: true,
          scrollDirection: Axis.horizontal,
          itemCount: _itemCountListView,
          itemBuilder: (context, index) {
            return getHorizontalListViewItem(context, index);
          },
        ),
      ),
    ),
  );
}

//获取横向列表Item
Widget getHorizontalListViewItem(BuildContext context, int index) {
  int maxValue = 100;
  int newValue = Random().nextInt(100);
  return Container(
    width: MediaQuery.of(context).size.width / 7,
    child: Column(
      children: [
        Expanded(
            child: SizedBox(
          child: Stack(
            alignment: AlignmentDirectional.bottomCenter,
            children: [
              Container(
                width: 16,
                height: double.infinity,
              ),
              Container(
                width: 1,
                height: double.infinity,
                color: AppColor.textHint,
              ),
              Positioned(
                child: Container(
                  width: 16,
                  height: newValue / maxValue * (175 - 20),
                  decoration: BoxDecoration(
                    color: index == 3 ? AppColor.textPrimary2 : AppColor.bgWhite,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                bottom: 0,
              ),
            ],
          ),
        )),
        SizedBox(height: 8),
        Text(
          "日期",
          style: TextStyle(color: index == 3 ? AppColor.textPrimary1 : AppColor.textSecondary, fontSize: 12),
        ),
      ],
    ),
  );
}

//获取顶部ui样式
Widget getTopUi() {
  var alertTextStyle = const TextStyle(fontSize: 12, color: AppColor.textHint);
  return SliverToBoxAdapter(
      child: Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
    child: Column(
      children: [
        Row(
          children: [
            Text("1月6日 训练时长", style: alertTextStyle),
            Expanded(child: SizedBox()),
            Text("(分钟)", style: alertTextStyle),
          ],
        ),
        SizedBox(height: 6),
        Text(
          "26",
          style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColor.textPrimary2),
        ),
        SizedBox(height: 26),
        Row(
          children: [
            Expanded(
                child: SizedBox(
              child: Column(
                children: [
                  Text("36", style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: AppColor.textPrimary2)),
                  SizedBox(height: 6),
                  Text("消耗千卡", style: alertTextStyle),
                ],
              ),
            )),
            Expanded(
                child: SizedBox(
              child: Column(
                children: [
                  Text("2", style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: AppColor.textPrimary2)),
                  SizedBox(height: 6),
                  Text("打卡次数", style: alertTextStyle),
                ],
              ),
            )),
          ],
        ),
        SizedBox(height: 20),
        Container(
          height: 12,
          color: AppColor.bgWhite,
        ),
      ],
    ),
  ));
}

//加载动画
Widget getLoadUi(BuildContext context) {
  return Container(
    width: MediaQuery.of(context).size.width,
    height: double.infinity,
    child: UnconstrainedBox(
      alignment: Alignment.center,
      child: CircularProgressIndicator(),
    ),
  );
}

//没有数据
Widget getNoDataUi(BuildContext context) {
  return Container(
    width: MediaQuery.of(context).size.width,
    height: double.infinity,
    child: Stack(
      children: [
        Container(
          alignment: Alignment.topCenter,
          padding: const EdgeInsets.only(top: 140),
          child: Container(
            width: 224.0,
            height: 224.0,
            child: Image.asset("images/test/bg.png", fit: BoxFit.cover),
          ),
        ),
        Positioned(
          child: Container(
            height: 83,
            width: MediaQuery.of(context).size.width,
            color: AppColor.textPrimary2,
            alignment: Alignment.topCenter,
            padding: const EdgeInsets.only(top: 14),
            child: Text(
              "立即开始训练",
              style: TextStyle(color: AppColor.white, fontSize: 16),
            ),
          ),
          bottom: 0,
          left: 0,
        ),
      ],
    ),
  );
}
