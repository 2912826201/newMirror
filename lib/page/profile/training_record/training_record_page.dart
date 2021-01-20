import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mirror/api/profile_page/training_record_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/data/model/profile/training_record_model.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/date_util.dart';
import 'package:mirror/widget/no_blue_effect_behavior.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class TrainingRecordPage extends StatefulWidget {
  @override
  _TrainingRecordPageState createState() => _TrainingRecordPageState();
}

class _TrainingRecordPageState extends State<TrainingRecordPage> with SingleTickerProviderStateMixin {
  TabController tabController;
  LoadingStatus loadingStatus = LoadingStatus.STATUS_IDEL;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  int itemCountListView = 10;

  List<TrainingRecordModel> dayModelList = <TrainingRecordModel>[];
  List<TrainingRecordWeekModel> weekModelList = <TrainingRecordWeekModel>[];
  List<TrainingRecordMonthModel> monthModelList = <TrainingRecordMonthModel>[];
  int monthSelectPosition = 0;
  int daySelectPosition = 0;
  int weekSelectPosition = 0;
  int monthMaxValue = 0;
  int dayMaxValue = 0;
  int weekMaxValue = 0;
  Map<String, int> weekModelMap = Map();
  Map<String, int> monthModelMap = Map();

  int pageIndex = 0;
  int startTime = 0;
  int endTime = 0;

  //每次获取三个月的数据
  int pageSize = 3;


  @override
  void initState() {
    super.initState();
    tabController = new TabController(length: 4, vsync: this);
    loadingStatus = LoadingStatus.STATUS_IDEL;
    onLoadData();
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
        trainingRecordPageItem("日"),
        trainingRecordPageItem("周"),
        trainingRecordPageItem("月"),
        trainingRecordPageItem("总"),
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


  //判断加载什么界面
  Widget trainingRecordPageItem(String typeString) {
    bool isHaveData = false;

    if (typeString == "日") {
      isHaveData = dayModelList != null && dayModelList.length > 0;
    } else if (typeString == "周") {
      isHaveData = weekModelList != null && weekModelList.length > 0;
    } else if (typeString == "月") {
      isHaveData = monthModelList != null && monthModelList.length > 0;
    } else {
      isHaveData = true;
    }
    if (loadingStatus == LoadingStatus.STATUS_COMPLETED && isHaveData) {
      return getHaveDataUi(typeString);
    } else if (loadingStatus == LoadingStatus.STATUS_LOADING) {
      return getLoadUi();
    } else {
      return getNoDataUi();
    }
  }

  //有数据的ui
  Widget getHaveDataUi(String typeString) {
    List<Widget> slivers = <Widget>[];

    if (typeString == "总") {
      slivers.add(getTopUi(typeString));
      slivers.add(getAllTrainingUi());
      slivers.add(getSpec(12));
      slivers.add(getLineView());
    } else {
      slivers.add(getTopUi(typeString));
      slivers.add(getHorizontalListView(typeString));
      slivers.add(getTrainAllCountUi(typeString));
      slivers.add(getLineView());
      slivers.add(getSpec(12));
      slivers.add(getVerticalListView(typeString));
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
                AppRouter.navigateToTrainingRecordAllPage(context);
              },
            ),
          ],
        ),
      ),
    );
  }

//获取竖向的listView
  Widget getVerticalListView(String typeString) {
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
  Widget getTrainAllCountUi(String typeString) {
    String title = "训练次数";
    String subTitle = "训练时间";
    String time = "时长";
    String calorie = "千卡";

    if (typeString == "日") {
      title = "训练共" + dayModelList[daySelectPosition].courseModelList.length.toString() + "次";
      subTitle = dayModelList[daySelectPosition].finishTime;
      time = dayModelList[daySelectPosition].dmsecondsCount.toString() + "分钟";
      calorie = dayModelList[daySelectPosition].dcalorieCount.toString() + "千卡";
    } else if (typeString == "周") {
      title = "训练共" + weekModelList[daySelectPosition].allCount.toString() + "次";
      subTitle = weekModelList[daySelectPosition].dateString;
      time = weekModelList[daySelectPosition].dmsecondsCount.toString() + "分钟";
      calorie = weekModelList[daySelectPosition].dcalorieCount.toString() + "千卡";
    } else {
      title = "训练共" + monthModelList[daySelectPosition].allCount.toString() + "次";
      subTitle = monthModelList[daySelectPosition].dateString;
      time = monthModelList[daySelectPosition].dmsecondsCount.toString() + "分钟";
      calorie = monthModelList[daySelectPosition].dcalorieCount.toString() + "千卡";
    }


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
                      Text(title,
                          style: TextStyle(fontSize: 16, color: AppColor.textPrimary1, fontWeight: FontWeight.bold)),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(subTitle, style: TextStyle(fontSize: 14, color: AppColor.textPrimary3)),
                          Expanded(child: SizedBox()),
                          Icon(Icons.access_time_sharp, size: 16, color: AppColor.textHint),
                          SizedBox(width: 2),
                          Text(time, style: TextStyle(fontSize: 12, color: AppColor.textPrimary3)),
                          SizedBox(width: 15),
                          Icon(Icons.local_fire_department, size: 16, color: AppColor.textHint),
                          SizedBox(width: 2),
                          Text(calorie, style: TextStyle(fontSize: 12, color: AppColor.textPrimary3)),
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
  Widget getHorizontalListView(String typeString) {
    int itemCount;
    if (typeString == "月") {
      itemCount = monthModelList.length + 2;
    } else if (typeString == "周") {
      itemCount = weekModelList.length + 2;
    } else {
      itemCount = dayModelList.length + 3;
    }


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
          onLoading: onLoadData,
          scrollDirection: Axis.horizontal,
          child: ListView.builder(
            reverse: true,
            scrollDirection: Axis.horizontal,
            itemCount: itemCount,
            itemBuilder: (context, index) {
              return getHorizontalListViewItem(context, index, typeString);
            },
          ),
        ),
      ),
    );
  }

//获取横向列表Item
  Widget getHorizontalListViewItem(BuildContext context, int index, String typeString) {
    int maxValue = 100;
    int newValue = 0;
    String title = " ";
    int count = 5;

    if (typeString == "日") {
      maxValue = dayMaxValue;
      newValue = dayModelList[index].dmsecondsCount;
      title = dayModelList[index].finishTime;
      count = 7;
    } else if (typeString == "周") {
      maxValue = weekMaxValue;
      newValue = weekModelList[index].dmsecondsCount;
      title = weekModelList[index].dateString;
      count = 5;
    } else {
      maxValue = monthMaxValue;
      newValue = monthModelList[index].dmsecondsCount;
      title = monthModelList[index].dateString;
      count = 5;
    }
    return Container(
      width: MediaQuery
          .of(context)
          .size
          .width / count,
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
            title,
            style: TextStyle(color: index == 3 ? AppColor.textPrimary1 : AppColor.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }


//获取顶部ui样式
  Widget getTopUi(String typeString) {
    var alertTextStyle = const TextStyle(fontSize: 12, color: AppColor.textHint);
    return SliverToBoxAdapter(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            children: [
              Row(
                children: [
                  Text(getTopTitle(typeString), style: alertTextStyle),
                  Expanded(child: SizedBox()),
                  Text("(分钟)", style: alertTextStyle),
                ],
              ),
              SizedBox(height: 6),
              Text(
                getTopLearnTime(typeString),
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColor.textPrimary2),
              ),
              SizedBox(height: 26),
              Row(
                children: [
                  Expanded(
                      child: SizedBox(
                        child: Column(
                          children: [
                            Text("2", style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: AppColor
                                .textPrimary2)),
                            SizedBox(height: 6),
                            Text("打卡次数", style: alertTextStyle),
                          ],
                        ),
                      )),

                  Visibility(
                    visible: typeString != "日",
                    child: Expanded(
                        child: SizedBox(
                          child: Column(
                            children: [
                              Text(getTopTrainingDay(typeString), style: TextStyle(
                                  fontSize: 23, fontWeight: FontWeight.bold, color: AppColor.textPrimary2)),
                              SizedBox(height: 6),
                              Text("训练天数", style: alertTextStyle),
                            ],
                          ),
                        )),
                  ),
                  Expanded(
                      child: SizedBox(
                        child: Column(
                          children: [
                            Text(getTopCalorie(typeString), style: TextStyle(fontSize: 23,
                                fontWeight: FontWeight.bold,
                                color: AppColor.textPrimary2)),
                            SizedBox(height: 6),
                            Text("消耗千卡", style: alertTextStyle),
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

  //获取头部title
  String getTopTitle(String typeString) {
    if (typeString == "总") {
      return "累计训练时长";
    } else if (typeString == "月") {
      return monthModelList[monthSelectPosition].dateString + " 训练时长";
    } else if (typeString == "周") {
      return weekModelList[weekSelectPosition].dateString + " 训练时长";
    } else {
      return dayModelList[daySelectPosition].finishTime + " 训练时长";
    }
  }

  //获取头部--总共学了多少分钟
  String getTopLearnTime(String typeString) {
    if (typeString == "总") {
      return "未知";
    } else if (typeString == "月") {
      return monthModelList[monthSelectPosition].dmsecondsCount.toString();
    } else if (typeString == "周") {
      return weekModelList[weekSelectPosition].dmsecondsCount.toString();
    } else {
      return dayModelList[daySelectPosition].dmsecondsCount.toString();
    }
  }

  //获取头部--训练天数
  String getTopTrainingDay(String typeString) {
    if (typeString == "总") {
      return "未知";
    } else if (typeString == "月") {
      return monthModelList[monthSelectPosition].dayListIndex.length.toString();
    } else if (typeString == "周") {
      return weekModelList[weekSelectPosition].dayListIndex.length.toString();
    } else {
      return "0";
    }
  }

  //获取头部--消耗千卡
  String getTopCalorie(String typeString) {
    if (typeString == "总") {
      return "未知";
    } else if (typeString == "月") {
      return monthModelList[monthSelectPosition].dcalorieCount.toString();
    } else if (typeString == "周") {
      return weekModelList[weekSelectPosition].dcalorieCount.toString();
    } else {
      return dayModelList[daySelectPosition].dcalorieCount.toString();
    }
  }


//加载动画
  Widget getLoadUi() {
    return Container(
      width: MediaQuery
          .of(context)
          .size
          .width,
      height: double.infinity,
      child: UnconstrainedBox(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }

//没有数据
  Widget getNoDataUi() {
    return Container(
      width: MediaQuery
          .of(context)
          .size
          .width,
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
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
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


//加载数据
  void onLoadData() async {
    itemCountListView += 10;
    if (pageIndex != 0 && endTime < Application.profile.createTime) {
      _refreshController.loadComplete();
      return;
    }
    startTime = getStartTime(pageIndex, pageSize, endTime);
    endTime = getEndTime(pageIndex, pageSize, endTime);
    List<TrainingRecordModel> dayModelList = await getTrainingRecordsList(
        startTime: DateUtil.formatDateString(DateUtil.getDateTimeByMs(endTime)),
        endTime: DateUtil.formatDateString(DateUtil.getDateTimeByMs(startTime)));
    if (dayModelList != null && dayModelList.length > 0) {
      pageIndex++;
      // this.dayModelList.addAll(dayModelList);
      getWeekModelList(dayModelList);
    }
    _refreshController.loadComplete();


    setState(() {
      loadingStatus = LoadingStatus.STATUS_COMPLETED;
    });
  }

//获取周数据和月数据
  void getWeekModelList(List<TrainingRecordModel> dayModelList) {
    for (int i = 0; i < dayModelList.length; i++) {
      TrainingRecordModel recordModel = dayModelList[i];


      int position = judgeAddDayModelList(recordModel);

      if (dayMaxValue < recordModel.dmsecondsCount) {
        dayMaxValue = recordModel.dmsecondsCount;
      }

      //把数据加到每一周中
      if (weekModelMap[getWeekString(recordModel.finishTime)] == null) {
        TrainingRecordWeekModel weekModel = new TrainingRecordWeekModel();
        weekModel.dateString = getWeekString(recordModel.finishTime);
        weekModel.dataStringList.add(recordModel.finishTime);
        weekModel.dayListIndex.add(position);
        weekModel.dcalorieCount = recordModel.dcalorieCount;
        weekModel.dmsecondsCount = recordModel.dmsecondsCount;
        weekModel.allCount = recordModel.courseModelList.length;
        if (weekMaxValue < weekModel.dmsecondsCount) {
          weekMaxValue = weekModel.dmsecondsCount;
        }
        weekModelList.add(weekModel);
        weekModelMap[getWeekString(recordModel.finishTime)] = weekModelList.length - 1;
      } else {
        TrainingRecordWeekModel weekModel = weekModelList[weekModelMap[getWeekString(recordModel.finishTime)]];
        weekModel.dataStringList.add(recordModel.finishTime);
        weekModel.dayListIndex.add(position);
        weekModel.dcalorieCount += recordModel.dcalorieCount;
        weekModel.dmsecondsCount += recordModel.dmsecondsCount;
        weekModel.allCount += recordModel.courseModelList.length;
        if (weekMaxValue < weekModel.dmsecondsCount) {
          weekMaxValue = weekModel.dmsecondsCount;
        }
      }

      //把数据加到每一月中
      if (monthModelMap[getMonthString(recordModel.finishTime)] == null) {
        TrainingRecordMonthModel monthModel = new TrainingRecordMonthModel();
        monthModel.dateString = getMonthString(recordModel.finishTime);
        monthModel.dataStringList.add(recordModel.finishTime);
        monthModel.dayListIndex.add(position);
        monthModel.dcalorieCount = recordModel.dcalorieCount;
        monthModel.dmsecondsCount = recordModel.dmsecondsCount;
        monthModel.allCount = recordModel.courseModelList.length;
        if (monthMaxValue < monthModel.dmsecondsCount) {
          monthMaxValue = monthModel.dmsecondsCount;
        }
        monthModelList.add(monthModel);
        monthModelMap[getMonthString(recordModel.finishTime)] = monthModelList.length - 1;
      } else {
        TrainingRecordMonthModel monthModel = monthModelList[monthModelMap[getMonthString(recordModel.finishTime)]];
        monthModel.dataStringList.add(recordModel.finishTime);
        monthModel.dayListIndex.add(position);
        monthModel.dcalorieCount += recordModel.dcalorieCount;
        monthModel.dmsecondsCount += recordModel.dmsecondsCount;
        monthModel.allCount += recordModel.courseModelList.length;
        if (monthMaxValue < monthModel.dmsecondsCount) {
          monthMaxValue = monthModel.dmsecondsCount;
        }
      }
    }
  }


//判断是不是直接加入
  int judgeAddDayModelList(TrainingRecordModel recordModel) {
    int position = 0;
    if (dayModelList.length < 1) {
      dayModelList.add(recordModel);
      position = dayModelList.length - 1;

      print("第一个值--recordModel:${recordModel.finishTime}");
      return position;
    }

    print("第其余值--recordModel:${recordModel.finishTime}");
    DateTime now = DateUtil.stringToDateTime(recordModel.finishTime).add(new Duration(days: 1));
    DateTime old = DateUtil.stringToDateTime(dayModelList[dayModelList.length - 1].finishTime);
    if (old.year == now.year && old.month == now.month && old.day == now.day) {
      dayModelList.add(recordModel);
      position = dayModelList.length - 1;
    } else {
      int i = 1;
      String finishTime = dayModelList[dayModelList.length - 1].finishTime;
      while (true) {
        DateTime dateTime = DateUtil.stringToDateTime(finishTime).add(new Duration(days: -(i)));
        if (dateTime.year == now.year && dateTime.month == now.month && dateTime.day == now.day) {
          dayModelList.add(recordModel);
          position = dayModelList.length - 1;
          break;
        } else {
          TrainingRecordModel model = new TrainingRecordModel();
          model.finishTime = DateUtil.formatDateString(dateTime);
          model.dmsecondsCount = 0;
          model.dcalorieCount = 0;
          dayModelList.add(model);
          i++;
        }
        if (i > 100) {
          print("判断错误--recordModel:${recordModel.finishTime}, dayModelList:${dayModelList[dayModelList.length - 1]
              .finishTime}");
          break;
        }
      }
    }
    return position;
  }


}


//获取月的string 2021/12
String getMonthString(String finishTime) {
  DateTime dateTime = DateUtil.stringToDateTime(finishTime);
  return "${dateTime.year}/${dateTime.month}";
}


//获取周的string 12/21-12/27
String getWeekString(String finishTime) {
  DateTime dateTime = DateUtil.stringToDateTime(finishTime);
  int weekDay = dateTime.weekday;
  DateTime startDateTime;
  DateTime endDateTime;
  if (weekDay == 1) {
    startDateTime = dateTime;
  } else {
    startDateTime = dateTime.add(new Duration(days: -(weekDay - 1)));
  }

  if (weekDay == 7) {
    endDateTime = dateTime;
  } else {
    endDateTime = dateTime.add(new Duration(days: (7 - weekDay)));
  }

  return "${startDateTime.month}/${startDateTime.day}-${endDateTime.month}/${endDateTime.day}";
}


//获取开始时间
//列如：2020-12结束 2021-1开始
int getStartTime(int pageIndex, int pageSize, int endTime) {
  if (pageIndex == 0) {
    return new DateTime.now().millisecondsSinceEpoch;
  } else {
    return DateUtil
        .getDateTimeByMs(endTime)
        .add(new Duration(days: -1))
        .millisecondsSinceEpoch;
  }
}

//获取结束时间
//列如：2020-12结束 2021-1开始
int getEndTime(int pageIndex, int pageSize, int endTime) {
  int monthNew;
  int yearNew;
  DateTime dateTime;
  if (pageIndex == 0) {
    dateTime = new DateTime.now();
  } else {
    dateTime = DateUtil.getDateTimeByMs(endTime);
  }

  monthNew = dateTime.month;
  yearNew = dateTime.year;

  if (monthNew < pageSize) {
    monthNew = (12 - pageSize + 1) + monthNew;
    yearNew--;
  } else {
    monthNew = monthNew - pageSize + 1;
  }

  return new DateTime(yearNew, monthNew, 1).millisecondsSinceEpoch;
}



