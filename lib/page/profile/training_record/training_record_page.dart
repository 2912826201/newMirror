import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mirror/api/profile_page/training_record_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/data/model/profile/training_record_model.dart';
import 'package:mirror/data/model/training/training_record_all_model.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/date_util.dart';
import 'package:mirror/util/event_bus.dart';
import 'package:mirror/util/integer_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/icon.dart';
import 'package:mirror/widget/no_blue_effect_behavior.dart';
import 'package:mirror/widget/smart_refressher_head_footer.dart';
import 'package:mirror/widget/pull_to_refresh/pull_to_refresh.dart';

/// 训练记录页
class TrainingRecordPage extends StatefulWidget {
  @override
  _TrainingRecordPageState createState() => _TrainingRecordPageState();
}

class _TrainingRecordPageState extends State<TrainingRecordPage> with SingleTickerProviderStateMixin {
  //滑动控制
  TabController tabController;

  //数据是否在加载中
  LoadingStatus loadingStatus = LoadingStatus.STATUS_IDEL;

  //数据是否在加载中
  RefreshController _refreshController = RefreshController(initialRefresh: false);

  //每一天的数据
  List<TrainingRecordModel> dayModelList = <TrainingRecordModel>[];

  //每一周的数据--没有具体的数据--有每一天的列表的index索引
  List<TrainingRecordWeekModel> weekModelList = <TrainingRecordWeekModel>[];

  //每一月的数据--没有具体的数据--有每一天的列表的index索引
  List<TrainingRecordMonthModel> monthModelList = <TrainingRecordMonthModel>[];

  //当前选中的的是第几个月
  int monthSelectPosition = 0;

  //当前选中的是第几天
  int daySelectPosition = 0;

  //当前选中的是第几周
  int weekSelectPosition = 0;

  //每一个月中最大的值-卡路里
  int monthMaxValue = 0;

  //每一个天中最大的值-卡路里
  int dayMaxValue = 0;

  //每一个周中最大的值-卡路里
  int weekMaxValue = 0;

  //有拿些周
  Map<String, int> weekModelMap = Map();

  //有哪些月
  Map<String, int> monthModelMap = Map();

  //总共训练的时长-训练的数据
  TrainingRecordAllModel allDataModel;

  //当前是第几页数据
  int pageIndex = 0;

  //当前数据的起始时间
  int startTime = 0;

  //当前数据的结束时间
  int endTime = 0;

  //每次获取三个月的数据
  int pageSize = 3;

  @override
  void initState() {
    super.initState();
    tabController = new TabController(length: 4, vsync: this);
    loadingStatus = LoadingStatus.STATUS_LOADING;
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
              expandedHeight: CustomAppBar.appBarHeight + 36.0 + 16.0,
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

  //主体可滑动部分
  TabBarView buildTabBarView() {
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

  //顶部tab滑动位置
  PreferredSize buildTabBar() {
    double itemWidth = (MediaQuery.of(context).size.width - 32);
    double itemHeight = 36.0;
    return PreferredSize(
      preferredSize: Size(itemWidth, CustomAppBar.appBarHeight),
      child: Container(
        width: itemWidth,
        height: itemHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColor.black, width: 1),
          borderRadius: BorderRadius.circular(itemHeight / 2),
        ),
        margin: const EdgeInsets.only(bottom: (CustomAppBar.appBarHeight - 36.0) / 2),
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

  //头部 折叠部分--状态栏
  FlexibleSpaceBar buildFlexibleSpaceBar() {
    return FlexibleSpaceBar(
      centerTitle: true,
      background: Container(
        color: AppColor.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: ScreenUtil.instance.statusBarHeight,
            ),
            Container(
              height: CustomAppBar.appBarHeight,
              width: MediaQuery.of(context).size.width,
              child: Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  Container(
                    child: Text(
                      "训练记录",
                      style: AppStyle.textMedium18,
                    ),
                  ),
                  Positioned(
                    child: CustomAppBarIconButton(
                        svgName: AppIcon.nav_return,
                        iconColor: AppColor.black,
                        onTap: () {
                          Navigator.pop(context);
                        }),
                    left: CustomAppBar.appBarHorizontalPadding,
                  ),
                  Positioned(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 0.5,
                      color: AppColor.bgWhite,
                    ),
                    bottom: 0,
                  ),
                ],
              ),
            ),
            Container(
              height: 12,
            )
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

  //总-全部数据页
  Widget getAllTrainingUi() {
    String countString;
    if (allDataModel == null || allDataModel.timesCount == null) {
      countString = "0";
    } else {
      countString = (allDataModel.timesCount).toString();
    }

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.only(top: 32, left: 16, right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("训练共 $countString 次", style: TextStyle(color: AppColor.textPrimary3, fontSize: 16)),
            SizedBox(height: 21),
            GestureDetector(
              child: Container(
                color: AppColor.transparent,
                child: Row(
                  children: [
                    Text("查看所有训练", style: TextStyle(color: AppColor.textPrimary1, fontSize: 16)),
                    Expanded(child: SizedBox()),
                    AppIcon.getAppIcon(AppIcon.arrow_right_18, 18, color: AppColor.textHint),
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
    int childCount = 0;
    if (typeString == "日") {
      childCount = dayModelList[daySelectPosition].courseModelList.length;
    } else if (typeString == "周") {
      childCount = weekModelList[weekSelectPosition].dayListIndex.length;
    } else {
      childCount = monthModelList[monthSelectPosition].dayListIndex.length;
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((content, index) {
        return getVerticalListViewItem(index, typeString);
      }, childCount: childCount),
    );
  }

//获取竖向的listViewItem
  Widget getVerticalListViewItem(int index, String typeString) {
    var widgetArray = <Widget>[];
    if (typeString == "日") {
      return getItem(dayModelList[daySelectPosition].courseModelList[index]);
    } else if (typeString == "周") {
      for (int i = 0;
          i < dayModelList[weekModelList[weekSelectPosition].dayListIndex[index]].courseModelList.length;
          i++) {
        CourseModelList courseModel =
            dayModelList[weekModelList[weekSelectPosition].dayListIndex[index]].courseModelList[i];
        DateTime dateTime = DateUtil.getDateTimeByMs(courseModel.createTime);
        String date = "${dateTime.month}月${dateTime.day}日";
        int time = dayModelList[weekModelList[weekSelectPosition].dayListIndex[index]].dmsecondsCount;
        int calorie = dayModelList[weekModelList[weekSelectPosition].dayListIndex[index]].dcalorieCount;
        widgetArray.add(getItem(courseModel, date: date, time: time, calorie: calorie, isShowDate: i == 0));
      }
    } else {
      for (int i = 0;
          i < dayModelList[monthModelList[monthSelectPosition].dayListIndex[index]].courseModelList.length;
          i++) {
        CourseModelList courseModel =
            dayModelList[monthModelList[monthSelectPosition].dayListIndex[index]].courseModelList[i];
        DateTime dateTime = DateUtil.getDateTimeByMs(courseModel.createTime);
        String date = "${dateTime.month}月${dateTime.day}日";
        int time = dayModelList[monthModelList[monthSelectPosition].dayListIndex[index]].dmsecondsCount;
        int calorie = dayModelList[monthModelList[monthSelectPosition].dayListIndex[index]].dcalorieCount;
        widgetArray.add(getItem(courseModel, date: date, time: time, calorie: calorie, isShowDate: i == 0));
      }
    }
    return Container(
      child: Column(
        children: widgetArray,
      ),
    );
  }

  //每一个列表的item
  Widget getItem(CourseModelList courseModel,
      {bool isShowDate = false, String date = "", int time = 0, int calorie = 0}) {
    String showTime =
        DateUtil.formatDateV(DateUtil.getDateTimeByMs(courseModel.createTime), format: "yyyy-MM-dd HH:mm");

    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, top: 6, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Visibility(
            visible: isShowDate,
            child: Container(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AppIcon.getAppIcon(AppIcon.time_filled_16, 16),
                  SizedBox(width: 6),
                  Text(date, style: TextStyle(fontSize: 14, color: AppColor.textPrimary2)),
                  Spacer(),
                  AppIcon.getAppIcon(AppIcon.time_16, 16, color: AppColor.textPrimary2),
                  SizedBox(width: 2),
                  Text("${time ~/ 1000 ~/ 60}分钟", style: TextStyle(fontSize: 12, color: AppColor.textPrimary2)),
                  SizedBox(width: 12),
                  AppIcon.getAppIcon(AppIcon.calorie_16, 16, color: AppColor.textPrimary2),
                  SizedBox(width: 2),
                  Text(IntegerUtil.formationCalorie(calorie),
                      style: TextStyle(fontSize: 12, color: AppColor.textPrimary2)),
                ],
              ),
            ),
          ),
          Visibility(
            visible: isShowDate,
            child: SizedBox(height: 18),
          ),
          Text(showTime, style: TextStyle(fontSize: 12, color: AppColor.textPrimary3)),
          SizedBox(height: 11),
          Text(courseModel.title, style: TextStyle(fontSize: 16, color: AppColor.textPrimary1)),
          SizedBox(height: 6),
          Text(
              "第${courseModel.no}次  ${courseModel.mseconds ~/ 1000 ~/ 60}分钟  ${IntegerUtil.formationCalorie(courseModel.calorie)}",
              style: TextStyle(fontSize: 12, color: AppColor.textSecondary)),
          SizedBox(height: 12),
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
      title = "训练共${dayModelList[daySelectPosition].courseModelList.length}次";
      DateTime dateTime = DateUtil.stringToDateTime(dayModelList[daySelectPosition].finishTime);
      subTitle = "${dateTime.month}月${dateTime.day}日";
      time = (dayModelList[daySelectPosition].dmsecondsCount ~/ 1000 ~/ 60).toString() + "分钟";
      calorie = IntegerUtil.formationCalorie(dayModelList[daySelectPosition].dcalorieCount);
    } else if (typeString == "周") {
      title = "训练共${weekModelList[weekSelectPosition].allCount}次";
      subTitle = weekModelList[weekSelectPosition].dateCompleteString;
      time = (weekModelList[weekSelectPosition].dmsecondsCount ~/ 1000 ~/ 60).toString() + "分钟";
      calorie = IntegerUtil.formationCalorie(weekModelList[weekSelectPosition].dcalorieCount);
    } else {
      title = "训练共${monthModelList[monthSelectPosition].allCount}次";
      subTitle = monthModelList[monthSelectPosition].dateCompleteString1;
      time = (monthModelList[monthSelectPosition].dmsecondsCount ~/ 1000 ~/ 60).toString() + "分钟";
      calorie = IntegerUtil.formationCalorie(monthModelList[monthSelectPosition].dcalorieCount);
    }

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.only(left: 16, right: 16, top: 32, bottom: 0),
        padding: const EdgeInsets.symmetric(vertical: 12),
        height: 71.0,
        child: Row(
          children: [
            AppIcon.getAppIcon(AppIcon.dumbbell, 24),
            SizedBox(width: 12),
            Expanded(
                child: SizedBox(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppStyle.textMedium16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(subTitle, style: TextStyle(fontSize: 14, color: AppColor.textPrimary3)),
                      Expanded(child: SizedBox()),
                      Container(
                        margin: const EdgeInsets.only(top: 3),
                        child: AppIcon.getAppIcon(AppIcon.time_16, 16, color: AppColor.textHint),
                      ),
                      SizedBox(width: 2),
                      Text(time, style: TextStyle(fontSize: 12, color: AppColor.textPrimary3)),
                      SizedBox(width: 15),
                      Container(
                        margin: const EdgeInsets.only(top: 3),
                        child: AppIcon.getAppIcon(AppIcon.calorie_16, 16, color: AppColor.textHint),
                      ),
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
      if (itemCount < 5) {
        itemCount = 5;
      }
    } else if (typeString == "周") {
      itemCount = weekModelList.length + 2;
      if (itemCount < 5) {
        itemCount = 5;
      }
    } else {
      itemCount = dayModelList.length + 3;
      if (itemCount < 7) {
        itemCount = 7;
      }
    }

    return SliverToBoxAdapter(
      child: Container(
        height: 180.0,
        child: SmartRefresher(
          enablePullDown: false,
          enablePullUp: true,
          footer: SmartRefresherHeadFooter.init().getFooterContainer(),
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
    bool isNowTime = false;

    if (typeString == "日") {
      maxValue = dayMaxValue;
      if (index > 2 && index < dayModelList.length + 3) {
        newValue = dayModelList[index - 3].dmsecondsCount;
        DateTime dateTime = DateUtil.stringToDateTime(dayModelList[index - 3].finishTime);
        isNowTime = (index - 3) == daySelectPosition;
        if (DateUtil.isToday(dateTime)) {
          title = "今日";
        } else {
          title = "${dateTime.month}.${dateTime.day}";
        }
      } else {
        newValue = 0;
        title = "";
        isNowTime = false;
      }
      count = 7;
    } else if (typeString == "周") {
      maxValue = weekMaxValue;
      count = 5;
      if (index > 1 && index < weekModelList.length + 2) {
        newValue = weekModelList[index - 2].dmsecondsCount;
        isNowTime = weekModelList[index - 2].dateString == getWeekString(DateUtil.formatDateString(new DateTime.now()));
        if (isNowTime) {
          title = "本周";
        } else {
          title = weekModelList[index - 2].dateString;
        }
        isNowTime = (index - 2) == weekSelectPosition;
      } else {
        newValue = 0;
        title = "";
        isNowTime = false;
      }
    } else {
      maxValue = monthMaxValue;
      count = 5;
      if (index > 1 && index < monthModelList.length + 2) {
        newValue = monthModelList[index - 2].dmsecondsCount;
        isNowTime =
            monthModelList[index - 2].dateString == getMonthString(DateUtil.formatDateString(new DateTime.now()));
        if (isNowTime) {
          title = "本月";
        } else {
          title = monthModelList[index - 2].dateCompleteString;
        }
        isNowTime = (index - 2) == monthSelectPosition;
      } else {
        newValue = 0;
        title = "";
        isNowTime = false;
      }
    }

    return GestureDetector(
      child: Container(
        width: MediaQuery.of(context).size.width / count,
        color: Colors.transparent,
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
                        color: isNowTime ? AppColor.textPrimary2 : AppColor.bgWhite,
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
              style: TextStyle(color: isNowTime ? AppColor.textPrimary1 : AppColor.textSecondary, fontSize: 12),
            ),
          ],
        ),
      ),
      onTap: () {
        if (typeString == "日") {
          if (index < 3 || index >= dayModelList.length + 3) {
            return;
          }
          daySelectPosition = index - 3;
          if (mounted) {
            setState(() {});
          }
        } else if (typeString == "周") {
          if (index < 2 || index >= weekModelList.length + 2) {
            return;
          }
          weekSelectPosition = index - 2;
          if (mounted) {
            setState(() {});
          }
        } else {
          if (index < 2 || index >= monthModelList.length + 2) {
            return;
          }
          monthSelectPosition = index - 2;
          if (mounted) {
            setState(() {});
          }
        }
      },
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
            style: AppStyle.textMedium36,
          ),
          SizedBox(height: 26),
          Row(
            children: [
              Expanded(
                  child: SizedBox(
                child: Column(
                  children: [
                    Text(getTopCheckInCount(typeString), style: AppStyle.textPrimary2Medium23),
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
                      Text(getTopTrainingDay(typeString), style: AppStyle.textPrimary2Medium23),
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
                    Text(getTopCalorie(typeString), style: AppStyle.textPrimary2Medium23),
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
      return monthModelList[monthSelectPosition].dateCompleteString + " 训练时长";
    } else if (typeString == "周") {
      return weekModelList[weekSelectPosition].dateCompleteString + " 训练时长";
    } else {
      return DateUtil.formatDateNoYearString1(DateUtil.stringToDateTime(dayModelList[daySelectPosition].finishTime)) +
          " 训练时长";
    }
  }

  //获取头部--总共学了多少分钟
  String getTopLearnTime(String typeString) {
    if (typeString == "总") {
      if (allDataModel == null || allDataModel.msecondsCount == null) {
        return "0";
      } else {
        print("allDataMap[msecondsCount]：${allDataModel.msecondsCount}");
        return (allDataModel.msecondsCount ~/ 1000 ~/ 60).toString();
      }
    } else if (typeString == "月") {
      return (monthModelList[monthSelectPosition].dmsecondsCount ~/ 1000 ~/ 60).toString();
    } else if (typeString == "周") {
      return (weekModelList[weekSelectPosition].dmsecondsCount ~/ 1000 ~/ 60).toString();
    } else {
      return (dayModelList[daySelectPosition].dmsecondsCount ~/ 1000 ~/ 60).toString();
    }
  }

  //获取头部--共打卡次数
  String getTopCheckInCount(String typeString) {
    if (typeString == "总") {
      if (allDataModel == null || allDataModel.clockCount == null) {
        return "0";
      } else {
        return (allDataModel.clockCount).toString();
      }
    } else if (typeString == "月") {
      return monthModelList[monthSelectPosition].clockCount.toString();
    } else if (typeString == "周") {
      return weekModelList[weekSelectPosition].clockCount.toString();
    } else {
      return dayModelList[daySelectPosition].clockCount.toString();
    }
  }

  //获取头部--训练天数
  String getTopTrainingDay(String typeString) {
    if (typeString == "总") {
      if (allDataModel == null || allDataModel.dayCount == null) {
        return "0";
      } else {
        return (allDataModel.dayCount).toString();
      }
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
      if (allDataModel == null || allDataModel.calorieCount == null) {
        return "0";
      } else {
        return IntegerUtil.formationCalorie(allDataModel.calorieCount, isHaveCompany: false);
      }
    } else if (typeString == "月") {
      return IntegerUtil.formationCalorie(monthModelList[monthSelectPosition].dcalorieCount, isHaveCompany: false);
    } else if (typeString == "周") {
      return IntegerUtil.formationCalorie(weekModelList[weekSelectPosition].dcalorieCount, isHaveCompany: false);
    } else {
      return IntegerUtil.formationCalorie(dayModelList[daySelectPosition].dcalorieCount, isHaveCompany: false);
    }
  }

//加载动画
  Widget getLoadUi() {
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
  Widget getNoDataUi() {
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
              child: Image.asset("assets/png/default_no_data.png", fit: BoxFit.cover),
            ),
          ),
          Positioned(
            child: GestureDetector(
              child: Container(
                height: 48 + ScreenUtil.instance.bottomBarHeight,
                width: MediaQuery.of(context).size.width,
                color: AppColor.textPrimary2,
                alignment: Alignment.topCenter,
                child: Container(
                  height: 48,
                  alignment: Alignment.center,
                  child: Text(
                    "立即开始训练",
                    style: TextStyle(color: AppColor.white, fontSize: 16),
                  ),
                ),
              ),
              onTap: (){
                EventBus.getDefault().post(msg: 1,registerName: MAIN_PAGE_JUMP_PAGE);
                Navigator.of(context).pop();
              },
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

    allDataModel = await getTrainingRecords();
    if (mounted) {
      setState(() {
        if (null != dayModelList && dayModelList.length > 0) {
          loadingStatus = LoadingStatus.STATUS_COMPLETED;
        } else {
          loadingStatus = LoadingStatus.STATUS_IDEL;
        }
      });
    }
  }

//获取周数据和月数据
  void getWeekModelList(List<TrainingRecordModel> dayModelList) {
    for (int i = 0; i < dayModelList.length; i++) {
      TrainingRecordModel recordModel = dayModelList[i];

      int clockCount = getClockCount(recordModel);
      recordModel.clockCount = clockCount;

      int position = judgeAddDayModelList(recordModel);

      if (dayMaxValue < recordModel.dmsecondsCount) {
        dayMaxValue = recordModel.dmsecondsCount;
      }

      //把数据加到每一周中
      if (weekModelMap[getWeekString(recordModel.finishTime)] == null) {
        TrainingRecordWeekModel weekModel = new TrainingRecordWeekModel();
        weekModel.dateString = getWeekString(recordModel.finishTime);
        weekModel.dateCompleteString = getWeekStringComplete(recordModel.finishTime);
        weekModel.dataStringList.add(recordModel.finishTime);
        weekModel.dayListIndex.add(position);
        weekModel.dcalorieCount = recordModel.dcalorieCount;
        weekModel.dmsecondsCount = recordModel.dmsecondsCount;
        weekModel.allCount = recordModel.courseModelList.length;
        weekModel.clockCount = clockCount;
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
        weekModel.clockCount += clockCount;
        if (weekMaxValue < weekModel.dmsecondsCount) {
          weekMaxValue = weekModel.dmsecondsCount;
        }
      }

      //把数据加到每一月中
      if (monthModelMap[getMonthString(recordModel.finishTime)] == null) {
        TrainingRecordMonthModel monthModel = new TrainingRecordMonthModel();
        monthModel.dateString = getMonthString(recordModel.finishTime);
        monthModel.dateCompleteString = getMonthStringComplete(recordModel.finishTime);
        monthModel.dateCompleteString1 = getMonthStringComplete1(recordModel.finishTime);
        monthModel.dataStringList.add(recordModel.finishTime);
        monthModel.dayListIndex.add(position);
        monthModel.dcalorieCount = recordModel.dcalorieCount;
        monthModel.dmsecondsCount = recordModel.dmsecondsCount;
        monthModel.allCount = recordModel.courseModelList.length;
        monthModel.clockCount = clockCount;
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
        monthModel.clockCount += clockCount;
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

      return position;
    }

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
          List<CourseModelList> courseModelList = <CourseModelList>[];
          model.courseModelList = courseModelList;
          model.dmsecondsCount = 0;
          model.dcalorieCount = 0;
          dayModelList.add(model);
          i++;
        }
        if (i > 100) {
          break;
        }
      }
    }
    return position;
  }

  int getClockCount(TrainingRecordModel recordModel) {
    if (recordModel == null || recordModel.courseModelList == null || recordModel.courseModelList.length < 1) {
      return 0;
    } else {
      int count = 0;
      for (int i = 0; i < recordModel.courseModelList.length; i++) {
        if (!(recordModel.courseModelList[i].isClock == null || recordModel.courseModelList[i].isClock == 0)) {
          count++;
        }
      }
      return count;
    }
  }
}

//获取月的string 2021/12
String getMonthString(String finishTime) {
  DateTime dateTime = DateUtil.stringToDateTime(finishTime);
  return "${dateTime.year}/${dateTime.month}";
}

//获取月的string 1月
String getMonthStringComplete(String finishTime) {
  DateTime dateTime = DateUtil.stringToDateTime(finishTime);
  return "${dateTime.month}月";
}

//获取月的string 2021年1月
String getMonthStringComplete1(String finishTime) {
  DateTime dateTime = DateUtil.stringToDateTime(finishTime);
  return "${dateTime.year}年${dateTime.month}月";
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

//获取周的string 1月4日-1月10日
String getWeekStringComplete(String finishTime) {
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

  return "${startDateTime.month}月${startDateTime.day}日-${endDateTime.month}月${endDateTime.day}日";
}

//获取开始时间
//列如：2020-12结束 2021-1开始
int getStartTime(int pageIndex, int pageSize, int endTime) {
  if (pageIndex == 0) {
    return new DateTime.now().millisecondsSinceEpoch;
  } else {
    return DateUtil.getDateTimeByMs(endTime).add(new Duration(days: -1)).millisecondsSinceEpoch;
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
