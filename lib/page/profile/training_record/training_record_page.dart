import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/widget/no_blue_effect_behavior.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'training_record_page_item.dart';

class TrainingRecordPage extends StatefulWidget {
  @override
  _TrainingRecordPageState createState() => _TrainingRecordPageState();
}

class _TrainingRecordPageState extends State<TrainingRecordPage> with SingleTickerProviderStateMixin {
  TabController tabController;
  LoadingStatus loadingStatus = LoadingStatus.STATUS_COMPLETED;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  int itemCountListView = 10;

  @override
  void initState() {
    super.initState();
    tabController = new TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildNestedScrollView(),
    );
  }

  ///构建滑动布局
  Widget buildNestedScrollView() {
    return ScrollConfiguration(
      behavior: NoBlueEffectBehavior(),
      child: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool b) {
          return [
            SliverAppBar(
              leading: Container(),
              pinned: true,
              floating: true,
              elevation: 0.5,
              brightness: Brightness.light,
              backgroundColor: AppColor.white,
              expandedHeight: 114,
              flexibleSpace: buildFlexibleSpaceBar(),
              bottom: buildTabBar(),
            ),
          ];
        },

        ///主体部分
        body: buildTabBarView(),
      ),
    );
  }

  TabBarView buildTabBarView() {
    loadingStatus = LoadingStatus.STATUS_COMPLETED;

    return TabBarView(
      controller: tabController,
      children: <Widget>[
        trainingRecordPageItem(context, "日", onLoadData, _refreshController, itemCountListView, loadingStatus),
        trainingRecordPageItem(context, "周", onLoadData, _refreshController, itemCountListView, loadingStatus),
        trainingRecordPageItem(context, "月", onLoadData, _refreshController, itemCountListView, loadingStatus),
        trainingRecordPageItem(context, "总", onLoadData, _refreshController, itemCountListView, loadingStatus),
      ],
    );
  }

  PreferredSize buildTabBar() {
    double itemWidth = (MediaQuery.of(context).size.width - 32);
    double itemHeight = 36.0;
    return PreferredSize(
      preferredSize: Size(itemWidth, itemHeight + 18),
      child: Container(
        width: itemWidth,
        height: itemHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColor.black, width: 1),
          borderRadius: BorderRadius.circular(itemHeight / 2),
        ),
        margin: const EdgeInsets.only(bottom: 8, top: 10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(itemHeight / 2),
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: [
              Container(
                width: itemWidth - 2,
                height: itemHeight,
                child: TabBar(
                    indicatorWeight: itemHeight,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(itemHeight / 2),
                      color: AppColor.black,
                    ),
                    labelPadding: const EdgeInsets.all(0),
                    controller: tabController,
                    tabs: <Widget>[
                      Container(),
                      Container(),
                      Container(),
                      Container(),
                    ]),
              ),
              Container(
                width: itemWidth - 2,
                height: itemHeight,
                child: TabBar(
                  indicatorWeight: 0.1,
                  labelPadding: const EdgeInsets.all(0),
                  controller: tabController,
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColor.black,
                  tabs: <Widget>[
                    Tab(text: "日"),
                    Tab(text: "周"),
                    Tab(text: "月"),
                    Tab(text: "总"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  FlexibleSpaceBar buildFlexibleSpaceBar() {
    return FlexibleSpaceBar(
      centerTitle: true,
      background: Container(
        color: AppColor.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              height: 100,
              width: MediaQuery.of(context).size.width,
              child: Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  Container(
                    child: Text(
                      "训练记录",
                      style: TextStyle(fontSize: 18, color: AppColor.black, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Positioned(
                    child: GestureDetector(
                      child: Container(
                        height: 50,
                        width: 50,
                        color: Colors.transparent,
                        child: Icon(
                          Icons.chevron_left,
                          size: 30,
                          color: AppColor.black,
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    left: 0,
                  ),
                  Positioned(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 1,
                      color: AppColor.bgWhite,
                    ),
                    bottom: 20,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onLoadData() {
    itemCountListView += 10;
    _refreshController.loadComplete();
    setState(() {
      print("itemCountListView,:$itemCountListView");
    });
  }
}
