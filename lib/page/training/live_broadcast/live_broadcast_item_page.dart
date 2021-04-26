import 'dart:convert';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/training/live_api.dart';
import 'package:mirror/api/user_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/training/live_video_model.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/data/model/user_model.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/date_util.dart';
import 'package:mirror/util/event_bus.dart';
import 'package:mirror/util/integer_util.dart';
import 'package:mirror/widget/no_blue_effect_behavior.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

/// 直播日程页--每一个item界面
class LiveBroadcastItemPage extends StatefulWidget {
  final DateTime dataDate;

  LiveBroadcastItemPage({
    Key key,
    @required this.dataDate,
  }) : super(key: key);

  @override
  createState() => new LiveBroadcastItemPageState(dataDate: dataDate);
}

class LiveBroadcastItemPageState extends State<LiveBroadcastItemPage> with AutomaticKeepAliveClientMixin {
  DateTime dataDate;

  LiveBroadcastItemPageState({
    Key key,
    @required this.dataDate,
  });

  //提前多久提醒---15分钟
  var howEarlyToRemind = 15;

  //当前显示的直播课程的list
  var liveModelArray = <LiveVideoModel>[];

  //当前显示的直播课程的list--今日回放的直播
  var liveModelOldArray = <LiveVideoModel>[];

  //日历内有多少个提醒计划
  // var calendarEvents = <Event>[];

  //hero动画的标签
  var heroTagArray = <String>[];

  //状态
  LoadingStatus loadingStatus;


  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    super.dispose();
    EventBus.getDefault().unRegister(pageName: EVENTBUS_LIVE_COURSE_PAGE+"${DateUtil.formatDateString(dataDate)}",
        registerName: LIVE_COURSE_BOOK_LIVE);
  }

  @override
  void initState() {
    super.initState();
    //获取本地日历已经预约的课程
    loadingStatus = LoadingStatus.STATUS_LOADING;
    liveModelArray.clear();
    getLiveModelData();

    EventBus.getDefault()
        .registerSingleParameter(_judgeLiveBook, EVENTBUS_LIVE_COURSE_PAGE+"${DateUtil.formatDateString(dataDate)}",
        registerName: LIVE_COURSE_BOOK_LIVE);
    // _retrieveCalendarEvents();
  }
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _buildSuggestions();
  }

  //判断是否获取网络数据
  Widget _buildSuggestions() {
    if ((liveModelArray != null && liveModelArray.length > 0) ||
        (liveModelOldArray != null && liveModelOldArray.length > 0)) {
      //有数据
      // setDataCalendar();
      return _getUi();
    } else {
      if (loadingStatus == LoadingStatus.STATUS_LOADING) {
        //加载中
        return UnconstrainedBox(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      } else {
        //没有数据
        return UnconstrainedBox(
          child: Center(
            child: GestureDetector(
              child: nullDataUi(),
              onTap: () {
                loadingStatus = LoadingStatus.STATUS_LOADING;
                if (mounted) {
                  setState(() {});
                }
                liveModelArray.clear();
                getLiveModelData();

                // AppRouter.navigateToLiveDetail(context, "0",1);
              },
            ),
          ),
        );
      }
    }
  }

  Widget _getUi() {
    var widgetArray = <Widget>[];
    heroTagArray.clear();
    //不能回放的直播课程
    if (liveModelArray != null && liveModelArray.length > 0) {
      widgetArray.add(
        SizedBox(
          height: 22,
        ),
      );
      widgetArray.add(_getLiveBroadcastUI(liveModelArray, false));
    }

    if (DateUtil.isToday(dataDate)) {
      //回放的直播课程
      if (liveModelOldArray != null && liveModelOldArray.length > 0) {
        widgetArray.add(
          SizedBox(
            height: 10,
          ),
        );
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
      margin: const EdgeInsets.only(left: 16, right: 16),
      child: Column(
        children: [
          Visibility(
            visible: liveModelArray != null && liveModelArray.length > 0,
            child: SizedBox(height: 22),
          ),
          Container(
            width: double.infinity,
            child: Text(
              "今日可回放课程",
              style: AppStyle.textMedium18,
            ),
          ),
        ],
      ),
    );
  }

  //获取列表ui
  Widget _getLiveBroadcastUI(List<LiveVideoModel> liveList, bool isOld) {
    var imageWidth = 120;
    var imageHeight = 90;
    var columnArray = <Widget>[];
    for (int i = 0; i < liveList.length; i++) {
      columnArray.add(GestureDetector(
        child: Container(
          color: AppColor.transparent,
          height: imageHeight.toDouble(),
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.only(left: 16, right: 16, top: 6, bottom: 6),
          child: Row(
            children: [
              _getItemLeftImageUi(liveList[i], imageWidth, imageHeight, isOld, i),
              _getRightDataUi(liveList[i], imageWidth, imageHeight, isOld, i),
            ],
          ),
        ),
        onTap: () {
          onClickItem(liveList[i], i, isOld);
        },
      ));
    }

    return Container(
      child: Column(
        children: columnArray,
      ),
    );
  }

  //获取left的图片
  Widget _getItemLeftImageUi(LiveVideoModel value, int imageWidth, int imageHeight, bool isOld, int index) {
    String imageUrl;
    if (value.picUrl != null) {
      imageUrl = value.picUrl;
    } else if (value.coursewareDto?.picUrl != null) {
      imageUrl = value.coursewareDto?.picUrl;
    } else if (value.coursewareDto?.previewVideoUrl != null) {
      imageUrl = value.coursewareDto?.previewVideoUrl;
    }
    return Container(
      width: imageWidth.toDouble(),
      child: Stack(
        children: [
          Positioned(
            child: Hero(
              child: CachedNetworkImage(
                height: 90,
                width: 120,
                imageUrl: imageUrl == null ? "" : imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppColor.bgWhite,
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppColor.bgWhite,
                ),
              ),
              tag: getHeroTag(value, index, isOld),
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
  Widget _getRightDataUi(LiveVideoModel value, int imageWidth, int imageHeight, bool isOld, int index) {
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
                value.title ?? "",
                style: AppStyle.textMedium15,
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
                                    padding: const EdgeInsets.only(top: 1, bottom: 1, left: 5, right: 5),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(1),
                                      color: AppColor.textHint.withOpacity(0.34),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Container(
                                    child: Text(
                                      "${IntegerUtil.formationCalorie(value.coursewareDto?.calories)}",
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: AppColor.textPrimary1,
                                      ),
                                    ),
                                    padding: const EdgeInsets.only(top: 1, bottom: 1, left: 5, right: 5),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(1),
                                      color: AppColor.textHint.withOpacity(0.34),
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
                                style: TextStyle(fontSize: 12, color: AppColor.textPrimary2),
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
  Widget _getButton(LiveVideoModel value, bool isOld, index) {
    var alreadyOrderBgColor = AppColor.white;
    var noAlreadyOrderBgColor = AppColor.textPrimary1;
    // if (isOld) {
    //   value.playType = 3;
    // }
    return GestureDetector(
      child: Container(
        width: 72,
        child: Text(
          value.getGetPlayType(),
          style: TextStyle(color: value.playType == 4 ? noAlreadyOrderBgColor : alreadyOrderBgColor, fontSize: 12),
          textAlign: TextAlign.center,
        ),
        decoration: BoxDecoration(
          color: value.playType == 4 ? alreadyOrderBgColor : noAlreadyOrderBgColor,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(width: 0.5, color: noAlreadyOrderBgColor),
        ),
        padding: const EdgeInsets.only(top: 5, bottom: 5),
      ),
      onTap: () {
        onClickItem(value, index, isOld);
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
              "assets/png/default_no_data.png",
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(
            height: 14,
          ),
          Text(
            string + "暂无直播课程，去看看其他的吧~",
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
  ///

  //这个直播是否有预约的回调
  void _judgeLiveBook(Message message) {
    if (message != null) {
      Map<String, dynamic> mapGroupModel = json.decode(message.originContentMap["data"]);
      if (mapGroupModel != null &&
          mapGroupModel["courseId"] != null &&
          mapGroupModel["handleType"] != null &&
          mapGroupModel["startTime"] != null &&
          mapGroupModel["startTime"] is String &&
          mapGroupModel["courseId"] is int &&
          mapGroupModel["handleType"] is int) {
        updateBookState(mapGroupModel["courseId"], mapGroupModel["handleType"], mapGroupModel["startTime"]);
      }
    }
  }

  //修改直播课程预约的状态
  void updateBookState(int courseId, int bookState, String startTime) {
    if (liveModelArray == null || liveModelArray.length < 1) {
      return;
    }
    liveModelArray.forEach((element) {
      if (element.id == courseId) {
        if (element.playType == 4 && bookState == 0) {
          element.playType = 2;
          element.isBooked = 0;
          deleteAlertEvents(courseId, startTime);
          Future.delayed(Duration(milliseconds: 100), () {
            if (mounted) {
              setState(() {});
            }
          });
        } else if (element.playType == 2 && bookState == 1) {
          element.playType = 4;
          element.isBooked = 1;
          Future.delayed(Duration(milliseconds: 100), () {
            if (mounted) {
              setState(() {});
            }
          });
        }
        return;
      }
    });
  }

  //删除日历预约提醒
  void deleteAlertEvents(int courseId, String startTime) async {
    await [Permission.calendar].request();
    bool isGranted = (await Permission.calendar.status)?.isGranted;
    if(!isGranted) {
      return;
    }
    DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();
    List<Calendar> _calendars;
    final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
    _calendars = calendarsResult?.data;
    if (_calendars == null || _calendars.length < 1) {
      var result = await _deviceCalendarPlugin.createCalendar(
        "iF",
        localAccountName: "iF——1",
      );
      if (result.isSuccess) {
        _deleteAlertEvents(result.data, startTime);
      }
    } else {
      _deleteAlertEvents(_calendars[0].id, startTime);
    }
  }

//  删除日历提醒
  Future _deleteAlertEvents(String calendarId, String startTimePr) async {
    var calendarEvents = <Event>[];
    DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();
    final startDate = DateTime.now();
    final endDate = DateTime.now().add(Duration(days: 7));
    List<Calendar> _calendars;
    final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
    _calendars = calendarsResult?.data;
    if (_calendars != null && _calendars.length > 0) {
      var calendarEventsResult = await _deviceCalendarPlugin.retrieveEvents(
          _calendars[0].id, RetrieveEventsParams(startDate: startDate, endDate: endDate));
      calendarEvents = calendarEventsResult?.data;
    }
    if (calendarEvents.length > 0) {
      DateTime startTime = DateUtil.stringToDateTime(startTimePr);
      for (Event event in calendarEvents) {
        if (event.calendarId == calendarId && event.start == startTime) {
          await _deviceCalendarPlugin.deleteEvent(calendarId, event.eventId);
          return;
        }
      }
    }
  }

// 获取指定日期的直播日程
  getLiveModelData() async {
    //获取今天可回放的数据
    if (DateUtil.isToday(dataDate)) {
      Map<String, dynamic> model = await getLiveCoursesByDate(date: DateUtil.formatDateString(dataDate), type: 1);
      if (model != null && model["list"] != null) {
        model["list"].forEach((v) {
          liveModelOldArray.add(LiveVideoModel.fromJson(v));
        });
      }
    }
    Map<String, dynamic> model = await getLiveCoursesByDate(date: DateUtil.formatDateString(dataDate), type: 0);
    if (model != null && model["list"] != null) {
      model["list"].forEach((v) {
        liveModelArray.add(LiveVideoModel.fromJson(v));
      });
    }

    print("直播回放的的数量：${liveModelOldArray.length}");
    print("直播当日的的数量：${liveModelArray.length}");
    if (liveModelArray.length > 0) {
      loadingStatus = LoadingStatus.STATUS_COMPLETED;
      if (mounted) {
        setState(() {});
      }
    } else {
      loadingStatus = LoadingStatus.STATUS_IDEL;
      Future.delayed(Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  //给hero的tag设置唯一的值
  Object getHeroTag(LiveVideoModel liveModel, int index, bool isOld) {
    if (isOld) {
      index += liveModelArray?.length;
    }
    if (heroTagArray != null && heroTagArray.length > index) {
      return heroTagArray[index];
    } else {
      String string = "heroTag_live_${DateUtil.getNowDateMs()}_${Random().nextInt(100000)}_${liveModel.id}_$index";
      heroTagArray.add(string);
      return string;
    }
  }

  void getRelation(LiveVideoModel value) async {
    UserModel userModel = await getUserInfo(uid: value.coachId);
    value.coachDto.relation = userModel.relation;
  }

  //点击item按钮判断怎么响应
  void onClickItem(LiveVideoModel value, int index, bool isOld) {
    print("index$index,liveModelArray.length：${liveModelArray.length},isOld:$isOld");
    gotoNavigateToLiveDetail(
        value,
        index +
            (isOld
                ? liveModelArray != null
                    ? liveModelArray.length
                    : 0
                : 0));
    getRelation(value);
  }

  void gotoNavigateToLiveDetail(LiveVideoModel value, int index) {
    AppRouter.navigateToLiveDetail(context, value.id, heroTag: heroTagArray[index], liveModel: value);
  }
}
