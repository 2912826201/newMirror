import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/profile_page/training_record_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/data/model/profile/training_record_model.dart';
import 'package:mirror/util/date_util.dart';
import 'package:mirror/widget/dotted_line.dart';
import 'package:mirror/widget/no_blue_effect_behavior.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'training_record_page.dart';

///
/// 所有训练记录页
class TrainingRecordAllPage extends StatefulWidget {
  @override
  _TrainingRecordAllPageState createState() => _TrainingRecordAllPageState();
}

class _TrainingRecordAllPageState extends State<TrainingRecordAllPage> {
  //加载数据的状态
  LoadingStatus loadingStatus = LoadingStatus.STATUS_LOADING;
  //加载数据的状态
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  //每一天的数据
  List<TrainingRecordModel> dayModelList = <TrainingRecordModel>[];
  //每一个月的数据--没有具体数据-有每一天的索引
  List<TrainingRecordMonthModel> monthModelList = <TrainingRecordMonthModel>[];
  //哪一个月进行了折叠操作
  Map<String, int> monthUnfoldModelMap = Map();
  //哪一个月展示全部的数据
  Map<String, int> monthAllModelMap = Map();
  //总数据的记录
  Map<String, dynamic> allDataMap = Map();

  int pageIndex = 0;
  int startTime = 0;
  int endTime = 0;

  //每次获取一个月的数据
  int pageSize = 1;

  int showCount = 5;

  @override
  void initState() {
    super.initState();
    loadingStatus = LoadingStatus.STATUS_LOADING;
    onLoadData(isGetAllData: true);
  }

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
    if (loadingStatus == LoadingStatus.STATUS_COMPLETED && monthModelList.length > 0) {
      return getHaveDataUi();
    } else if (loadingStatus == LoadingStatus.STATUS_LOADING) {
      return getLoadUi();
    } else {
      return getNoDataUi();
    }
  }

  //有数据
  Widget getHaveDataUi() {
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
              child: Image.asset("images/test/bg.png", fit: BoxFit.cover),
            ),
          ),
        ],
      ),
    );
  }

  //获取listview
  Widget getListViewUi() {
    return ScrollConfiguration(
      behavior: NoBlueEffectBehavior(),
      child: SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        header: WaterDropHeader(
          complete: Text("刷新完成"),
          failed: Text(" "),
        ),
        footer: CustomFooter(
          builder: (BuildContext context, LoadStatus mode) {
            Widget body;
            if (mode == LoadStatus.idle) {
              body = Text("");
            } else if (mode == LoadStatus.loading) {
              body = Container(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(),
              );
            } else if (mode == LoadStatus.failed) {
              body = Text("");
            } else if (mode == LoadStatus.canLoading) {
              body = Text("");
            } else {
              body = Text("");
            }
            return Container(
              height: 55.0,
              child: Center(child: body),
            );
          },
        ),
        controller: _refreshController,
        onLoading: onLoadData,
        onRefresh: onRefresh,
        child: ListView.builder(
          itemCount: monthModelList.length,
          itemBuilder: (context, index) {
            return getListViewItemUi(index);
          },
        ),
      ),
    );
  }


  //获取item
  Widget getListViewItemUi(int index) {
    return Container(
      child: Column(
        children: [
          getDateUi(index),
          getSubListView(index),
        ],
      ),
    );
  }

  //获取子item
  Widget getSubListView(int index) {
    var widgetArray = <Widget>[];
    int lengthAllCount = 0;
    int firstLength = 0;
    int additionalHeight = 0;
    bool ifShowAllItem = true;
    bool isShowAllItem = monthAllModelMap[monthModelList[index].dateCompleteString1] == null ||
        monthAllModelMap[monthModelList[index].dateCompleteString1] == 0;
    for (int i = 0; i < monthModelList[index].dayListIndex.length; i++) {
      if (lengthAllCount >= showCount && isShowAllItem) {
        ifShowAllItem = false;
        break;
      }
      firstLength++;
      for (int j = 0; j < dayModelList[monthModelList[index].dayListIndex[i]].courseModelList.length; j++) {
        lengthAllCount++;
        if (lengthAllCount >= showCount && isShowAllItem) {
          ifShowAllItem = false;
          if (j < dayModelList[monthModelList[index].dayListIndex[i]].courseModelList.length - 1 ||
              i < monthModelList[index].dayListIndex.length - 1) {
            additionalHeight = 50;
            widgetArray.add(getShowAllDataUi(monthModelList[index].dateCompleteString1));
          }
          break;
        }
        int length = dayModelList[monthModelList[index].dayListIndex[i]].courseModelList.length;
        CourseModelList courseModelList = dayModelList[monthModelList[index].dayListIndex[i]].courseModelList[j];
        int learnTime = dayModelList[monthModelList[index].dayListIndex[i]].dmsecondsCount;
        int calorie = dayModelList[monthModelList[index].dayListIndex[i]].dcalorieCount;
        widgetArray.add(getItem(false, j, length, learnTime, calorie, courseModelList));
      }
    }


    bool isVisible = true;
    if (monthUnfoldModelMap[monthModelList[index].dateCompleteString1] != null &&
        monthUnfoldModelMap[monthModelList[index].dateCompleteString1] != 0) {
      isVisible = false;
    }

    if (!ifShowAllItem) {
      lengthAllCount--;
    }

    widgetArray.add(Container(height: 50,));

    return Visibility(
      visible: isVisible,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Container(
              height: lengthAllCount * 111.0 + 38.0 * firstLength + additionalHeight + 50,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(child: SizedBox(
                    child:
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      width: 1,
                      color: AppColor.textSecondary,
                    ),
                  )),
                  Container(
                    height: 100,
                    child: DottedLine(
                      height: 1,
                      color: AppColor.textSecondary,
                      direction: Axis.vertical,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
                child: SizedBox(
                  child: Column(
                    children: widgetArray,
                  ),
                )),
          ],
        ),
      ),
    );
  }


  //获取查看更多数据
  Widget getShowAllDataUi(String dateCompleteString1) {
    return GestureDetector(
      child: Container(
        height: 50,
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            getLineView(leftWidth: 0, rightWidth: 0),
            Container(
              height: 48,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    child: Icon(Icons.keyboard_arrow_down, size: 16, color: AppColor.textPrimary2),
                  ),
                  SizedBox(width: 6),
                  Text("查看更多"),
                ],
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        bool isShowAllItem = monthAllModelMap[dateCompleteString1] == null ||
            monthAllModelMap[dateCompleteString1] == 0;
        if (isShowAllItem) {
          monthAllModelMap[dateCompleteString1] = 1;
        } else {
          monthAllModelMap[dateCompleteString1] = 0;
        }
        if(mounted){
          setState(() {});
        }
      },
    );
  }

  //获取每一个item
  Widget getItem(bool isShowBottomViewLine, int index, int len, int learnTime, int calorie,
      CourseModelList courseModelList) {
    DateTime dateTime = DateUtil.getDateTimeByMs(courseModelList.createTime);
    String date = "${dateTime.month}月${dateTime.day}日";
    String showTime = DateUtil.formatDateV(dateTime, format: "yyyy-MM-dd HH:mm");

    return Container(
      height: index == 0 ? 148.0 : 111.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          getLineView(leftWidth: 0, rightWidth: 0),

          Visibility(
            visible: index == 0,
            child: SizedBox(height: 22),
          ),

          Visibility(
            visible: index == 0,
            child: Container(
              height: 20,
              child: Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 3),
                    child: Icon(Icons.access_time_sharp, size: 12, color: AppColor.textPrimary2),
                  ),
                  SizedBox(width: 5),
                  Text(date, style: TextStyle(fontSize: 14, color: AppColor.textPrimary2)),
                  Expanded(child: SizedBox()),
                  Container(
                    margin: const EdgeInsets.only(top: 3),
                    child: Icon(Icons.access_time_sharp, size: 12, color: AppColor.textPrimary2),
                  ),
                  SizedBox(width: 4),
                  Text("${learnTime ~/ 1000 ~/ 60}分钟", style: TextStyle(fontSize: 12, color: AppColor.textPrimary2)),
                  SizedBox(width: 10),
                  Container(
                    margin: const EdgeInsets.only(top: 3),
                    child: Icon(Icons.local_fire_department, size: 12, color: AppColor.textPrimary2),
                  ),
                  SizedBox(width: 4),
                  Text("$calorie千卡", style: TextStyle(fontSize: 12, color: AppColor.textPrimary2)),
                ],
              ),
            ),
          ),
          SizedBox(height: 18),
          Text(showTime, style: TextStyle(fontSize: 12, color: AppColor.textPrimary3)),
          SizedBox(height: 11),
          Text(courseModelList.title, style: TextStyle(fontSize: 16, color: AppColor.textPrimary1)),
          SizedBox(height: 6),
          Text("第${courseModelList.no}次  ${courseModelList.mseconds ~/ 1000 ~/ 60}分钟  ${courseModelList.calorie}千卡",
              style: TextStyle(fontSize: 12, color: AppColor.textSecondary)),
          SizedBox(height: 12),
          Visibility(
            visible: isShowBottomViewLine,
            child: getLineView(leftWidth: 0, rightWidth: 0),
          ),
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
                        Text(monthModelList[index].dateCompleteString1,
                            style: TextStyle(fontSize: 16, color: AppColor.textPrimary1)),
                        Expanded(child: SizedBox()),
                        GestureDetector(
                          child: Container(
                            height: 28,
                            width: 50,
                            color: Colors.transparent,
                            child: Icon(Icons.arrow_circle_up, size: 18),
                          ),
                          onTap: () {
                            if (monthUnfoldModelMap[monthModelList[index].dateCompleteString1] == null ||
                                monthUnfoldModelMap[monthModelList[index].dateCompleteString1] == 0) {
                              monthUnfoldModelMap[monthModelList[index].dateCompleteString1] = 1;
                            } else {
                              monthUnfoldModelMap[monthModelList[index].dateCompleteString1] = 0;
                            }
                            if(mounted){
                              setState(() {});
                            }
                          },
                        )
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
    String countString;
    if (allDataMap == null || allDataMap["timesCount"] == null) {
      countString = "0";
    } else {
      countString = (allDataMap["timesCount"]).toString();
    }
    String timeString;
    if (allDataMap == null || allDataMap["msecondsCount"] == null) {
      timeString = "0";
    } else {
      timeString = (allDataMap["msecondsCount"] ~/ 1000 ~/ 60).toString();
    }
    String calorieCount;
    if (allDataMap == null || allDataMap["calorieCount"] == null) {
      calorieCount = "0";
    } else {
      calorieCount = (allDataMap["calorieCount"]).toString();
    }

    return Container(
      color: AppColor.bgWhite,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 48.0,
      alignment: Alignment.center,
      child: Row(
        children: [
          Text("全部", style: TextStyle(fontSize: 16, color: AppColor.textPrimary1)),
          Expanded(child: SizedBox()),
          Container(
            margin: const EdgeInsets.only(top: 3),
            child: Icon(Icons.access_time_sharp, size: 12, color: AppColor.textPrimary3),
          ),
          Text("$countString次", style: TextStyle(fontSize: 12, color: AppColor.textPrimary3)),
          SizedBox(width: 15),
          Container(
            margin: const EdgeInsets.only(top: 3),
            child: Icon(Icons.access_time_sharp, size: 12, color: AppColor.textPrimary3),
          ),
          Text("$timeString分钟", style: TextStyle(fontSize: 12, color: AppColor.textPrimary3)),
          SizedBox(width: 15),
          Container(
            margin: const EdgeInsets.only(top: 3),
            child: Icon(Icons.access_time_sharp, size: 12, color: AppColor.textPrimary3),
          ),
          Text("$calorieCount千卡", style: TextStyle(fontSize: 12, color: AppColor.textPrimary3)),
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


  void onRefresh() {
    pageIndex = 0;
    monthModelList.clear();
    dayModelList.clear();
    monthUnfoldModelMap.clear();
    monthAllModelMap.clear();
    onLoadData(isGetAllData: true);
  }

//加载数据
  void onLoadData({bool isGetAllData = false}) async {
    if (pageIndex != 0 && endTime < Application.profile.createTime) {
      _refreshController.refreshCompleted();
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
      getMonthModelList(dayModelList);
    }
    _refreshController.refreshCompleted();
    _refreshController.loadComplete();

    if (isGetAllData) {
      allDataMap = await getTrainingRecords();
    }
    if(mounted) {
      setState(() {
        if (this.monthUnfoldModelMap.length > 0) {
          loadingStatus = LoadingStatus.STATUS_COMPLETED;
        } else {
          loadingStatus = LoadingStatus.STATUS_IDEL;
        }
      });
    }
  }

//获取月数据
  void getMonthModelList(List<TrainingRecordModel> dayModelList) {
    for (int i = 0; i < dayModelList.length; i++) {
      TrainingRecordModel recordModel = dayModelList[i];

      int position = judgeAddDayModelList(recordModel);

      //把数据加到每一月中
      if (monthUnfoldModelMap[getMonthString(recordModel.finishTime)] == null) {
        TrainingRecordMonthModel monthModel = new TrainingRecordMonthModel();
        monthModel.dateString = getMonthString(recordModel.finishTime);
        monthModel.dateCompleteString = getMonthStringComplete(recordModel.finishTime);
        monthModel.dateCompleteString1 = getMonthStringComplete1(recordModel.finishTime);
        monthModel.dataStringList.add(recordModel.finishTime);
        monthModel.dayListIndex.add(position);
        monthModel.dcalorieCount = recordModel.dcalorieCount;
        monthModel.dmsecondsCount = recordModel.dmsecondsCount;
        monthModel.allCount = recordModel.courseModelList.length;
        monthModelList.add(monthModel);
        monthUnfoldModelMap[getMonthString(recordModel.finishTime)] = monthModelList.length - 1;
      } else {
        TrainingRecordMonthModel monthModel = monthModelList[monthUnfoldModelMap[getMonthString(
            recordModel.finishTime)]];
        monthModel.dataStringList.add(recordModel.finishTime);
        monthModel.dayListIndex.add(position);
        monthModel.dcalorieCount += recordModel.dcalorieCount;
        monthModel.dmsecondsCount += recordModel.dmsecondsCount;
        monthModel.allCount += recordModel.courseModelList.length;
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


}



