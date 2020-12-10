import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/live_broadcast/live_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/live_model.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/ToastShow.dart';
import 'package:mirror/util/date_util.dart';
import 'package:mirror/widget/no_blue_effect_behavior.dart';
import 'package:permission_handler/permission_handler.dart';

enum LoadingStatus {
  //正在加载中
  STATUS_LOADING,
  //数据加载完成
  STATUS_COMPLETED,
  //空闲状态
  STATUS_IDEL,
}

/// 直播日程页
class LiveBroadcastItemPage extends StatefulWidget {
  DateTime dataDate;

  LiveBroadcastItemPage({
    Key key,
    @required this.dataDate,
  }) : super(key: key);

  @override
  createState() => new LiveBroadcastItemPageState(dataDate: dataDate);
}

class LiveBroadcastItemPageState extends State<LiveBroadcastItemPage>
    with AutomaticKeepAliveClientMixin {
  DateTime dataDate;

  LiveBroadcastItemPageState({
    Key key,
    @required this.dataDate,
  });

  //提前多久提醒---15分钟
  var howEarlyToRemind = 15;

  //当前显示的直播课程的list
  var liveModelArray = <LiveModel>[];

  //当前显示的直播课程的list
  var liveModelOldArray = <LiveModel>[];

  //日历内有多少个提醒计划
  var calendarEvents = <Event>[];

  //hero动画的标签
  var heroTagArray = <String>[];

  //状态
  LoadingStatus loadingStatus;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    //获取本地日历已经预约的课程
    print("====initState-${dataDate}");
    loadingStatus = LoadingStatus.STATUS_LOADING;
    getLiveModelData();
    _retrieveCalendarEvents();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _buildSuggestions();
  }

  //判断是否获取网络数据
  Widget _buildSuggestions() {
    if (liveModelArray != null && liveModelArray.length > 0) {
      setDataCalendar();
      return _getUi();
    } else {
      if (loadingStatus == LoadingStatus.STATUS_LOADING) {
        return UnconstrainedBox(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      } else {
        return UnconstrainedBox(
          child: Center(
            child: GestureDetector(
              child: nullDataUi(),
              onTap: () {
                loadingStatus = LoadingStatus.STATUS_LOADING;
                setState(() {});
                getLiveModelData();
              },
            ),
          ),
        );
      }
    }
  }

  Widget _getUi() {
    var widgetArray = <Widget>[];
    //不能回放的直播课程
    if (liveModelArray != null && liveModelArray.length > 0) {
      widgetArray.add(_getLiveBroadcastUI(liveModelArray, false));
    }

    if (DateUtil.isToday(dataDate)) {
      //回放的直播课程
      if (liveModelOldArray != null && liveModelOldArray.length > 0) {
        widgetArray.add(_getOldDataTitle());
        widgetArray.add(
          SizedBox(
            height: 10,
          ),
        );
        widgetArray.add(_getLiveBroadcastUI(liveModelOldArray, true));
      }
    }

    widgetArray.add(SizedBox(
      height: 65,
    ));
    return Column(
      children: [
        SizedBox(
          height: 32,
        ),
        Expanded(
            child: SizedBox(
          child: ScrollConfiguration(
            behavior: NoBlueEffectBehavior(),
            child: SingleChildScrollView(
              child: Column(
                children: widgetArray,
              ),
            ),
          ),
        ))
      ],
    );
  }

  Widget _getOldDataTitle() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(left: 16, right: 16, top: 22),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            child: Text(
              "今日可回放课程",
              style: TextStyle(
                  fontSize: 18,
                  color: AppColor.textPrimary1,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  //获取列表ui
  Widget _getLiveBroadcastUI(List<LiveModel> liveList, bool isOld) {
    var imageWidth = 120;
    var imageHeight = 90;
    var columnArray = <Widget>[];
    var i = 0;
    heroTagArray.clear();
    for (var value in liveList) {
      columnArray.add(Container(
        height: imageHeight.toDouble(),
        width: MediaQuery.of(context).size.width,
        margin: const EdgeInsets.only(left: 16, right: 16, top: 6, bottom: 6),
        child: Row(
          children: [
            _getItemLeftImageUi(value, imageWidth, imageHeight, i),
            _getRightDataUi(value, imageWidth, imageHeight, isOld, i),
          ],
        ),
      ));
      i++;
    }

    return Container(
      child: Column(
        children: columnArray,
      ),
    );
  }

  //获取left的图片
  Widget _getItemLeftImageUi(
      LiveModel value, int imageWidth, int imageHeight, int index) {
    return Container(
      width: imageWidth.toDouble(),
      child: Stack(
        children: [
          Positioned(
            child: Hero(
              child: Image.asset(
                "images/test/bg.png",
                width: imageWidth.toDouble(),
                height: imageHeight.toDouble(),
                fit: BoxFit.cover,
              ),
              tag: getHeroTag(value, index),
            ),
            left: 0,
            top: 0,
          ),
          Positioned(
            left: 0,
            top: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: imageHeight.toDouble(),
              width: imageWidth.toDouble(),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColor.black.withOpacity(0),
                    AppColor.black.withOpacity(0.25),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            child: Container(
              width: imageWidth.toDouble(),
              padding: const EdgeInsets.only(top: 3, bottom: 3),
              child: Text(
                "${DateUtil.formatTimeString(DateUtil.stringToDateTime(value.startTime))}"
                "-"
                "${DateUtil.formatTimeString(DateUtil.stringToDateTime(value.endTime))}",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColor.white,
                  fontSize: 12,
                ),
              ),
            ),
            left: 0,
            bottom: 0,
          ),
        ],
      ),
    );
  }

  //获取右边数据的ui
  Widget _getRightDataUi(
      LiveModel value, int imageWidth, int imageHeight, bool isOld, int index) {
    return Expanded(
        child: SizedBox(
      child: Container(
        margin: const EdgeInsets.only(left: 12),
        height: imageHeight.toDouble(),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              child: Text(
                value.name,
                style: TextStyle(
                  fontSize: 15,
                  color: AppColor.textPrimary1,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
                child: SizedBox(
              child: Container(
                width: double.infinity,
                child: Row(
                  children: [
                    //数据
                    Expanded(
                        child: SizedBox(
                      child: Container(
                        padding: const EdgeInsets.only(top: 6),
                        width: double.infinity,
                        height: double.infinity,
                        child: Stack(
                          children: [
                            Positioned(
                              child: Row(
                                children: [
                                  Container(
                                    //类型
                                    child: Text(
                                      value.coursewareDto?.targetDto?.name,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: AppColor.textPrimary1,
                                      ),
                                    ),
                                    padding: const EdgeInsets.only(
                                        top: 1, bottom: 1, left: 5, right: 5),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(1),
                                      color:
                                          AppColor.textHint.withOpacity(0.34),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Container(
                                    child: Text(
                                      "${value.coursewareDto?.calories}千卡",
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: AppColor.textPrimary1,
                                      ),
                                    ),
                                    padding: const EdgeInsets.only(
                                        top: 1, bottom: 1, left: 5, right: 5),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(1),
                                      color:
                                          AppColor.textHint.withOpacity(0.34),
                                    ),
                                  ),
                                ],
                              ),
                              top: 0,
                              left: 0,
                            ),
                            Positioned(
                              child: Text(
                                value.coachDto?.nickName,
                                style: TextStyle(
                                    fontSize: 12, color: AppColor.textPrimary2),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              bottom: 0,
                              left: 0,
                              right: 8,
                            )
                          ],
                        ),
                      ),
                    )),
                    //按钮
                    Container(
                      height: double.infinity,
                      child: Stack(
                        alignment: AlignmentDirectional.bottomStart,
                        children: [
                          _getButton(value, isOld, index),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )),
          ],
        ),
      ),
    ));
  }

  //按钮 去上课 预约 已预约 回放
  Widget _getButton(LiveModel value, bool isOld, index) {
    var alreadyOrderBgColor = AppColor.white;
    var noAlreadyOrderBgColor = AppColor.textPrimary1;
    if (isOld) {
      value.playType = 3;
    }
    print("${value.playType}----${value.getGetPlayType()}---${isOld}");
    return GestureDetector(
      child: Container(
        width: 72,
        child: Text(
          value.getGetPlayType(),
          style: TextStyle(
              color: value.playType == 4
                  ? noAlreadyOrderBgColor
                  : alreadyOrderBgColor,
              fontSize: 12),
          textAlign: TextAlign.center,
        ),
        decoration: BoxDecoration(
          color:
              value.playType == 4 ? alreadyOrderBgColor : noAlreadyOrderBgColor,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(width: 0.5, color: noAlreadyOrderBgColor),
        ),
        padding: const EdgeInsets.only(top: 5, bottom: 5),
      ),
      onTap: () {
        onClickItem(value, index);
      },
    );
  }

//空布局
  Widget nullDataUi() {
    var string = "今日";
    if (!DateUtil.isToday(dataDate)) {
      string = "";
    }
    return Container(
      child: Column(
        children: [
          Container(
            width: 224,
            height: 224,
            child: Image.asset(
              "images/test/bg.png",
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(
            height: 14,
          ),
          Text(
            "${string}暂无直播课程，去看看其他的吧~",
            style: TextStyle(
              fontSize: 14,
              color: AppColor.textSecondary,
            ),
          ),
          SizedBox(
            height: 100,
          ),
        ],
      ),
    );
  }

  ///以上ui-------------------------------------------------------

  //设置数据
  //应该要判断一下时间，以免 id相同 时间不同导致错误的预约
  void setDataCalendar() {
    if (calendarEvents == null || calendarEvents.length < 1) {
      return;
    } else {
      for (int i = 0; i < calendarEvents.length; i++) {
        for (int j = 0; j < liveModelArray.length; j++) {
          print(
              "---${liveModelArray[j].startTime}----${DateUtil.formatDateTimeString(calendarEvents[i].start)}");
          if (liveModelArray[j].name == calendarEvents[i].title &&
              liveModelArray[j].coursewareDto?.name ==
                  calendarEvents[i].description &&
              liveModelArray[j].startTime ==
                  DateUtil.formatDateTimeString(calendarEvents[i].start)) {
            liveModelArray[j].playType = 4;
            break;
          }
        }
      }
    }
  }

  //点击item按钮判断怎么响应
  void onClickItem(LiveModel value, index) {
    if (value.playType == 2) {
      //todo android 添加日历提醒 测试没有问题-虽然没有全机型测试------ios还未测试
      onClickMakeAnAppointment(value);
    } else if (value.playType == 1) {
      ToastShow.show("点击-去上课-应该直接去直播间", context);
      AppRouter.navigateToLiveDetail(context, heroTagArray[index]);
    } else {
      ToastShow.show("去直播详情页", context);
      AppRouter.navigateToLiveDetail(context, heroTagArray[index]);
    }
  }

  //点击预约后-查询是否有创建提醒的空间id
  void onClickMakeAnAppointment(LiveModel value) async {
    await [Permission.calendar].request();
    DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();
    List<Calendar> _calendars;
    final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
    _calendars = calendarsResult?.data;
    if (_calendars == null || _calendars.length < 1) {
      var result = await _deviceCalendarPlugin.createCalendar(
        "mirror",
        localAccountName: "mirror——1",
      );
      if (result.isSuccess) {
        createEvent(result.data, _deviceCalendarPlugin, value);
      } else {
        ToastShow.show("添加日历预约错误", context);
      }
    } else {
      createEvent(_calendars[0].id, _deviceCalendarPlugin, value);
    }
  }

  //创建提醒
  void createEvent(String id, DeviceCalendarPlugin _deviceCalendarPlugin,
      LiveModel value) async {
    Event _event = new Event(id);
    DateTime startTime = DateUtil.stringToDateTime(value.startTime);
    _event.start = startTime;
    var endTime = DateUtil.stringToDateTime(value.endTime);
    List<Reminder> _reminders = <Reminder>[];
    _reminders.add(new Reminder(minutes: howEarlyToRemind));
    _event.end = endTime;
    _event.title = value.name;
    _event.description = value.coursewareDto?.name;
    _event.reminders = _reminders;
    var createEventResult =
        await _deviceCalendarPlugin.createOrUpdateEvent(_event);
    if (createEventResult.isSuccess) {
      ToastShow.show("添加提醒成功", context);
      _retrieveCalendarEvents();
    } else {
      ToastShow.show("添加提醒失败", context);
    }
  }

  //获取所有的记录
  Future _retrieveCalendarEvents() async {
    DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();
    final startDate = DateTime.now().add(Duration(days: -30));
    final endDate = DateTime.now().add(Duration(days: 30));
    List<Calendar> _calendars;
    final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
    _calendars = calendarsResult?.data;
    if (_calendars != null && _calendars.length > 0) {
      var calendarEventsResult = await _deviceCalendarPlugin.retrieveEvents(
          _calendars[0].id,
          RetrieveEventsParams(startDate: startDate, endDate: endDate));
      calendarEvents = calendarEventsResult?.data;
      setState(() {});
    }
  }

// 获取指定日期的直播日程
  getLiveModelData() async {
    //获取今天可回放的数据
    if (DateUtil.isToday(dataDate)) {
      Map<String, dynamic> model = await getTodayPlaybackCourse();
      if (model != null && model["list"] != null) {
        model["list"].forEach((v) {
          liveModelOldArray.add(LiveModel.fromJson(v));
        });
      }
    }
    //todo 这里应该是获取对应的日期 但是现在其他日期没有数据
    // Map<String, dynamic> model = await getLiveCourses(date: DateUtil.formatDateString(dataDate));
    Map<String, dynamic> model = await getLiveCourses(date: "2020-11-16");
    if (model != null && model["list"] != null) {
      model["list"].forEach((v) {
        liveModelArray.add(LiveModel.fromJson(v));
      });
    }

    print("直播当日的的数量：${liveModelArray.length}");
    if (liveModelArray.length > 0) {
      loadingStatus = LoadingStatus.STATUS_COMPLETED;
      setState(() {});
    } else {
      loadingStatus = LoadingStatus.STATUS_IDEL;
      Future.delayed(Duration(seconds: 1), () {
        setState(() {});
      });
    }
  }

  //给hero的tag设置唯一的值
  Object getHeroTag(LiveModel liveModel, index) {
    String string =
        "heroTag_${DateUtil.getNowDateMs()}_${Random().nextInt(100000)}_${liveModel.id}_${index}";
    heroTagArray.add(string);
    return string;
  }
}