import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide Scaffold;
import 'package:mirror/api/api.dart';
import 'package:mirror/api/machine_api.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/page/message/util/chat_message_profile_util.dart';
import 'package:mirror/data/model/training/course_model.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/data/model/message/chat_type_model.dart';
import 'package:mirror/data/notifier/machine_notifier.dart';
import 'package:mirror/data/notifier/token_notifier.dart';
import 'package:mirror/data/notifier/user_interactive_notifier.dart';
import 'package:mirror/page/profile/profile_detail_page.dart';
import 'package:mirror/page/profile/vip/vip_not_open_page.dart';
import 'package:mirror/page/scan_code/scan_code_page.dart';
import 'package:mirror/page/search/sub_page/should_build.dart';
import 'package:mirror/page/training/common/common_comment_page.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/date_util.dart';
import 'package:mirror/util/event_bus.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/ScaffoldChatPage.dart';
import 'package:mirror/widget/dialog.dart';
import 'package:mirror/widget/feed/feed_share_popups.dart';
import 'package:mirror/widget/icon.dart';
import 'package:mirror/widget/no_blue_effect_behavior.dart';
import 'package:mirror/api/training/course_api.dart';
import 'package:mirror/widget/smart_refressher_head_footer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mirror/page/training/common/common_course_page.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';


import '../../../widget/sliver_custom_header_delegate.dart';
import 'package:provider/provider.dart';

import 'live_room_page_common.dart';
import 'live_room_video_page.dart';
import 'live_room_video_operation_page.dart';

/// ???????????????
class LiveDetailPage extends StatefulWidget {
  const LiveDetailPage(
      {Key key,
      @required this.liveCourseId,
      this.heroTag,
      this.commentDtoModel,
      this.fatherComment,
      this.liveModel,
      this.isHaveStartTime,
      this.isInteractive})
      : super(key: key);

  final String heroTag;
  final int liveCourseId;
  final CourseModel liveModel;
  final bool isHaveStartTime;
  final CommentDtoModel commentDtoModel;
  final CommentDtoModel fatherComment;
  final bool isInteractive;

  @override
  createState() {
    return LiveDetailPageState(
        liveModel: liveModel,
        heroTag: heroTag,
        liveCourseId: liveCourseId,
        commentDtoModel: commentDtoModel,
        fatherComment: fatherComment,
        isHaveStartTime: isHaveStartTime,
        isInteractive: isInteractive);
  }
}

class LiveDetailPageState extends XCState {
  LiveDetailPageState(
      {Key key,
      this.liveModel,
      this.heroTag,
      this.liveCourseId,
      this.isHaveStartTime,
      this.commentDtoModel,
      this.fatherComment,
      this.isInteractive});

  String heroTag;
  int liveCourseId;
  bool isHaveStartTime;
  CommentDtoModel commentDtoModel;
  CommentDtoModel fatherComment;
  bool isInteractive;

  //???????????????model
  CourseModel liveModel;

  //????????????
  LoadingStatus loadingStatus;
  LoadingStatus recommendLoadingStatus;

  //??????????????????
  RefreshController _refreshController = RefreshController(initialRefresh: false);

  //??????????????????
  bool isBouncingScrollPhysics = false;

  //??????????????????---15??????
  var howEarlyToRemind = 15;

  //???????????????????????????
  ScrollController scrollController = ScrollController();

  //???????????????????????????
  GlobalKey<CommonCommentPageState> childKey = GlobalKey();

  //????????????????????????????????????????????????
  List<GlobalKey> globalKeyList = <GlobalKey>[];

  //???????????????????????????item
  bool isShowAllItemAction = false;

  //????????????????????????
  bool isLoggedIn;

  //???????????????????????????
  bool bindingTerminal;

  @override
  void initState() {
    super.initState();
    isLoggedIn = context.read<TokenNotifier>().isLoggedIn;
    bindingTerminal = context.read<MachineNotifier>().machine != null;

    EventBus.init().registerSingleParameter(_liveCourseStatus, EVENTBUS_LIVE_COURSE_PAGE,
        registerName: LIVE_COURSE_LIVE_START_OR_END);
    EventBus.init()
        .registerSingleParameter(_judgeLiveBook, EVENTBUS_LIVE_COURSE_PAGE, registerName: LIVE_COURSE_BOOK_LIVE);

    if (liveModel == null) {
      loadingStatus = LoadingStatus.STATUS_LOADING;
    } else {
      loadingStatus = LoadingStatus.STATUS_COMPLETED;
      //???????????????????????????????????? ?????????????????????????????????
      if (isLoggedIn && Application.machine != null) {
        openLiveCourseDetailPage(Application.machine.machineId, liveCourseId, liveModel.startTime);
      }
    }
    recommendLoadingStatus = LoadingStatus.STATUS_LOADING;
    getDataAction(openLiveCourse: liveModel == null);
  }

  @override
  void dispose() {
    super.dispose();
    EventBus.init().unRegister(pageName: EVENTBUS_LIVE_COURSE_PAGE, registerName: LIVE_COURSE_LIVE_START_OR_END);
    EventBus.init().unRegister(pageName: EVENTBUS_LIVE_COURSE_PAGE, registerName: LIVE_COURSE_BOOK_LIVE);
  }

  void _liveCourseStatus(List list) {
    if (list != null && liveModel != null && list[1] == liveModel.id) {
      switch (list[0]) {
        case 0:
          //0-????????????
          print("????????????");
          getDataAction();
          break;
        case 3:
          //0-????????????
          print("????????????");
          getDataAction();
          break;
        default:
          break;
      }
    }
  }

  @override
  Widget shouldBuild(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: _buildSuggestions(),
      handleStatusBarTap: _animateToIndex,
    );
  }

  //????????????????????????
  Widget _buildSuggestions() {
    var widgetArray = <Widget>[];
    //?????????
    if (loadingStatus == LoadingStatus.STATUS_COMPLETED) {
      return _buildSuggestionsComplete();
    } else {
      widgetArray.add(SizedBox(height: 40));
      widgetArray.add(getNoCompleteTitle(context, "?????????????????????"));
      //????????????
      if (loadingStatus == LoadingStatus.STATUS_LOADING) {
        widgetArray.add(
          Expanded(
            child: SizedBox(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
        );
      } else {
        //????????????
        widgetArray.add(
          Expanded(
            child: SizedBox(
              child: Center(
                child: GestureDetector(
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                          "????????????????????????????????????????????????~",
                          style: AppStyle.text1Regular14,
                        ),
                        SizedBox(
                          height: 100,
                        ),
                      ],
                    ),
                  ),
                  onTap: () {
                    loadingStatus = LoadingStatus.STATUS_LOADING;
                    if (mounted) {
                      reload(() {});
                    }
                    getDataAction();
                  },
                ),
              ),
            ),
          ),
        );
      }
      return Container(
        child: Column(children: widgetArray),
      );
    }
  }

  //??????????????????????????????
  Widget _buildSuggestionsComplete() {
    return SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      child: Container(
        color: AppColor.white,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height - 50 - ScreenUtil.instance.bottomBarHeight,
              child: ScrollConfiguration(
                behavior: NoBlueEffectBehavior(),
                child: NotificationListener<ScrollNotification>(
                  onNotification: _onDragNotification,
                  child: getSmartRefresher(),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              height: 50.0 + ScreenUtil.instance.bottomBarHeight,
              padding: EdgeInsets.only(bottom: ScreenUtil.instance.bottomBarHeight),
              color: AppColor.white,
              child: _getBottomBar(),
            ),
            Offstage(
              offstage: true,
              child: userLoginComplete(),
            ),
            Offstage(
              offstage: true,
              child: userBindingTerminal(),
            ),
          ],
        ),
      ),
    );
  }

  //????????????????????????
  Widget getSmartRefresher() {
    globalKeyList.clear();
    GlobalKey globalKey0 = new GlobalKey();
    GlobalKey globalKey1 = new GlobalKey();
    GlobalKey globalKey2 = new GlobalKey();
    GlobalKey globalKey3 = new GlobalKey();
    GlobalKey globalKey4 = new GlobalKey();
    globalKeyList.add(globalKey0);
    globalKeyList.add(globalKey1);
    globalKeyList.add(globalKey2);
    globalKeyList.add(globalKey3);
    globalKeyList.add(globalKey4);
    return SmartRefresher(
      enablePullDown: false,
      enablePullUp: true,
      footer: SmartRefresherHeadFooter.init().getFooter(isShowNoMore: false, isShowAddMore: false),
      controller: _refreshController,
      onLoading: () {
        if (childKey == null || childKey.currentState == null || childKey.currentState.onLoading == null) {
          return;
        }
        childKey.currentState.onLoading();
      },
      child: CustomScrollView(
        controller:  scrollController,
        physics: isBouncingScrollPhysics ? BouncingScrollPhysics() : ClampingScrollPhysics(),
        slivers: <Widget>[
          // header,
          SliverPersistentHeader(
            pinned: true,
            delegate: SliverCustomHeaderDelegate(
              title: liveModel.title ?? "",
              collapsedHeight: 44,
              expandedHeight: 300,
              paddingTop: MediaQuery.of(context).padding.top,
              coverImgUrl: getCourseShowImage(liveModel),
              heroTag: heroTag,
              startTime: liveModel.startTime,
              endTime: liveModel.endTime,
              shareBtnClick: _shareBtnClick,
              globalKey: globalKeyList[0],
            ),
          ),
          getTitleWidget(liveModel, context, globalKeyList[1]),
          getCoachItem(liveModel, context, onClickAttention, onClickCoach, globalKeyList[2],getDataAction),
          getLineView(),
          getTrainingEquipmentUi(liveModel, context, AppStyle.textMedium18, globalKeyList[3]),
          getActionUiLive(liveModel, context, globalKeyList[4], isShowAllItemAction, onClickShowAllAction),
          getLineView(),
          _getCourseCommentUi(),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 15,
            ),
          )
        ],
      ),
    );
  }

  Widget _getCourseCommentUi() {
    return SliverToBoxAdapter(
      child: Visibility(
        visible: recommendLoadingStatus == LoadingStatus.STATUS_COMPLETED,
        child: CommonCommentPage(
          key: childKey,
          scrollController: scrollController,
          refreshController: _refreshController,
          fatherComment: fatherComment,
          targetId: liveModel.id,
          targetType: 1,
          isInteractiveIn: isInteractive,
          pageCommentSize: 20,
          pageSubCommentSize: 3,
          isShowHotOrTime: true,
          commentDtoModel: commentDtoModel,
          isShowAt: false,
          globalKeyList: globalKeyList,
        ),
      ),
    );
  }

  //??????????????????
  Widget _getBottomBar() {
    //todo ?????????????????????vip????????????vip?????????
    bool isVip=false;

    if(context.read<TokenNotifier>().isLoggedIn&&Application.profile!=null&&Application.profile
        .isVip!=null&&Application.profile
        .isVip == 1){
      isVip=true;
    }

    print("isVip:$isVip");

    var textStyle = const TextStyle(color: AppColor.white, fontSize: 16);
    var textStyleEnd = const TextStyle(color: AppColor.black, fontSize: 16);
    var textStyleVip = const TextStyle(color: AppColor.textVipPrimary1, fontSize: 16);
    var margin_32 = const EdgeInsets.only(left: 32, right: 32);
    var marginLeft32Right16 = const EdgeInsets.only(left: 32, right: 16);
    var marginLeft26Right20 = const EdgeInsets.only(left: 26, right: 20);
    var marginRight32 = const EdgeInsets.only(right: 32);
    var marginRight16 = const EdgeInsets.only(right: 16);

    Widget widget3 = Container(
      width: 60,
      color: AppColor.transparent,
      height: double.infinity,
      margin: marginLeft26Right20,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppIcon.getAppIcon(AppIcon.headset, 24),
          Text((liveModel.playType == 3 ? liveModel.getGetPlayType() : "??????")),
        ],
      ),
    );

    EdgeInsetsGeometry tempEd = (liveModel.getGetPlayType() == "??????" ? marginRight32 : marginRight16);
    Widget widget1 = getBtnUi(false, "??????????????????", textStyle, double.infinity, 40, tempEd);
    Widget widget2 = getBtnUi(false, "??????????????????????????????", textStyle, double.infinity, 40, tempEd);
    Widget widget4 = getBtnUi(false, "??????", textStyle, 94, 40, marginLeft32Right16);
    Widget widget5 = getBtnUi(true, "??????vip??????????????????", textStyleVip, double.infinity, 40, tempEd);
    Widget widget6 = getBtnUi(false, liveModel.getGetPlayType(), textStyle, double.infinity, 40, margin_32);
    Widget widget7 = getBtnUi(false, "?????????", textStyleEnd, double.infinity, 40, margin_32);

    var childrenArray = <Widget>[];

    if (liveModel.endState != null && liveModel.endState == 0 || (liveModel.getGetPlayType() == "?????????")) {
      //?????????
      childrenArray.add(Expanded(
          child: SizedBox(
              child: GestureDetector(
                  child: widget7,
                  onTap: () {
                    print(
                        "liveModel.endState:${liveModel.endState},${liveModel.getGetPlayType()},${liveModel.liveCourseState}");
                    ToastShow.show(msg: "???????????????", context: context);
                  }))));
    } else {
      if (!isLoggedIn) {
        //????????????
        childrenArray.add(Expanded(child: SizedBox(child: GestureDetector(child: widget6, onTap: _login))));
      } else {
        //?????????

        //??????????????????????????????????????????????????????
        if (liveModel.playType == 2 || liveModel.playType == 4) {
          //???????????????????????????
          childrenArray.add(Expanded(
              child: SizedBox(
                  child: GestureDetector(
                      child: widget6,
                      onTap: () => _judgeBookOrCancelBook(bindingTerminal: bindingTerminal, isVip: isVip)))));
        } else {
          if (liveModel.playType == 3) {
            //??????
            childrenArray.add(GestureDetector(child: widget4, onTap: _seeVideo));
          } else {
            //??????
            childrenArray.add(GestureDetector(child: widget3, onTap: _seeVideo));
          }
          //????????????????????????
          if (bindingTerminal) {
            //???????????????

            //??????????????????????????????vip????????????
            //todo ???????????????????????????vip??????
            if (liveModel.priceType == 0) {
              //??????????????????vip
              childrenArray.add(Expanded(child: SizedBox(child: GestureDetector(child: widget1, onTap: _useTerminal))));
            } else if (liveModel.priceType == 1) {
              if (isVip) {
                //??????????????????vip
                childrenArray
                    .add(Expanded(child: SizedBox(child: GestureDetector(child: widget1, onTap: _useTerminal))));
              } else {
                //????????????vip
                childrenArray.add(Expanded(child: SizedBox(child: GestureDetector(child: widget5, onTap: _openVip))));
              }
            } else {
              //todo ????????????--?????????????????????vip
              childrenArray.add(Expanded(child: SizedBox(child: GestureDetector(child: widget5, onTap: _openVip))));
            }
          } else {
            //??????????????????
            childrenArray.add(Expanded(child: SizedBox(child: GestureDetector(child: widget2, onTap: _loginTerminal))));
          }
        }
      }
    }

    return Container(
      width: MediaQuery.of(context).size.width,
      height: 50,
      child: Row(
        children: childrenArray,
      ),
    );
  }

  Widget getBtnUi(bool isVip, String text, var textStyle, double width1, double height1, var marginData) {
    var colors = <Color>[];
    if (isVip) {
      colors.add(AppColor.bgVip1);
      colors.add(AppColor.bgVip2);
    } else if (text == "?????????") {
      colors.add(AppColor.bgWhite);
      colors.add(AppColor.bgWhite);
    } else {
      colors.add(AppColor.textPrimary1);
      colors.add(AppColor.textPrimary1);
    }
    return Container(
      width: width1,
      height: height1,
      margin: marginData,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(height1 / 2),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Center(
        child: Text(
          text == "?????????" ? "??????" : text,
          style: textStyle,
        ),
      ),
    );
  }

  //????????????????????????????????????
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

  //??????????????????????????????????????????
  Widget userLoginComplete() {
    return Consumer<TokenNotifier>(
      builder: (context, notifier, child) {
        if (notifier.isLoggedIn) {
          if (!isLoggedIn) {
            isLoggedIn = true;
            Future.delayed(Duration(milliseconds: 100), () {
              if (mounted) {
                reload(() {});
              }
            });
            getDataAction();

            //???????????????????????????????????? ?????????????????????????????????
            if (Application.machine != null) {
              openLiveCourseDetailPage(Application.machine.machineId, liveCourseId, liveModel.startTime);
            }
          }
        } else {
          if (isLoggedIn) {
            isLoggedIn = false;
            Future.delayed(Duration(milliseconds: 100), () {
              if (mounted) {
                reload(() {});
              }
            });
            getDataAction();

            //???????????????????????????????????? ?????????????????????????????????
            if (Application.machine != null) {
              openLiveCourseDetailPage(Application.machine.machineId, liveCourseId, liveModel.startTime);
            }
          }
        }
        return child;
      },
      child: Container(),
    );
  }

  //????????????????????????
  Widget userBindingTerminal() {
    return Consumer<MachineNotifier>(
      builder: (context, notifier, child) {
        if (notifier.machine != null) {
          if (!bindingTerminal) {
            bindingTerminal = true;
            print("bindingTerminal1:$bindingTerminal");
            Future.delayed(Duration(milliseconds: 300), () {
              if (mounted) {
                reload(() {});
              }
            });
          }
        } else {
          if (bindingTerminal) {
            bindingTerminal = false;
            print("bindingTerminal2:$bindingTerminal");
            Future.delayed(Duration(milliseconds: 300), () {
              if (mounted) {
                reload(() {});
              }
            });
          }
        }
        return child;
      },
      child: Container(),
    );
  }

  //?????????????????????????????????
  void updateBookState(int courseId, int bookState, String startTime) {
    if (liveModel == null || liveModel.id == null) {
      return;
    }
    if (liveModel.id == courseId) {
      if (liveModel.playType == 4 && bookState == 0) {
        liveModel.playType = 2;
        liveModel.isBooked = 0;
        deleteAlertEvents(courseId, startTime);
        Future.delayed(Duration(milliseconds: 50), () {
          if (mounted) {
            reload(() {});
          }
        });
      } else if (liveModel.playType == 2 && bookState == 1) {
        liveModel.playType = 4;
        liveModel.isBooked = 1;
        Future.delayed(Duration(milliseconds: 50), () {
          if (mounted) {
            reload(() {});
          }
        });
      }
      return;
    }
  }

  //???????????????
  bool _onDragNotification(ScrollNotification notification) {
    ScrollMetrics metrics = notification.metrics;
    if (childKey == null || childKey.currentState == null || childKey.currentState.scrollHeightOld == null) {
      return false;
    }
    childKey.currentState.scrollHeightOld = metrics.pixels;
    if (metrics.pixels < 10) {
      if (isBouncingScrollPhysics) {
        isBouncingScrollPhysics = false;
        if (mounted) {
          reload(() {});
        }
      }
    } else {
      if (!isBouncingScrollPhysics) {
        isBouncingScrollPhysics = true;
        if (mounted) {
          reload(() {});
        }
      }
    }
    return false;
  }

  //?????????????????????
  void _shareBtnClick() async {
    if (await isOffline()) {
      ToastShow.show(msg: "???????????????!", context: context);
      return;
    }
    openShareBottomSheet(
        context: context,
        map: liveModel.toJson(),
        chatTypeModel: ChatTypeModel.MESSAGE_TYPE_LIVE_COURSE,
        sharedType: 1);
  }

  ///????????????
  ///

  Future<void> _bookLiveCourse(CourseModel value, int index, bool isAddCalendar,
      {bool bindingTerminal = false}) async {
    int valuePlayType = value.playType;
    print(value.getGetPlayType());
    Map<String, dynamic> mapBook =
        await bookLiveCourse(courseId: value.id, startTime: value.startTime, isBook: valuePlayType == 2);
    if (mapBook != null && mapBook["code"] == 200) {
      if (isAddCalendar) {
        onClickMakeAnAppointment(value, "", valuePlayType == 2);
      }
      if (mapBook["state"] != null && mapBook["state"] && bindingTerminal) {
        showAppDialog(context,
            title: "??????",
            info: "???????????????????????????????????????????????????????????????????????????????????????",
            cancel: AppDialogButton("?????????", () {
              return true;
            }),
            confirm: AppDialogButton("????????????", () {
              applyTerminalTrainingPr();
              return true;
            }));
      }
    } else if (mapBook != null && mapBook["code"] == 321) {
      ToastShow.show(msg: "????????????:-????????????", context: context);
    } else {
      getDataAction();
    }
    return;
  }

  //???????????????-????????????????????????????????????id
  void onClickMakeAnAppointment(CourseModel value, String alert, bool isBook) async {
    //todo android ?????????????????? ??????????????????-???????????????????????????------ios????????????
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
        localAccountName: "iF??????1",
      );
      if (result.isSuccess) {
        if (isBook) {
          createEvent(result.data, _deviceCalendarPlugin, value, alert);
        } else {
          _deleteAlertEvents(result.data, value.startTime);
        }
      }
    } else {
      if (isBook) {
        createEvent(_calendars[0].id, _deviceCalendarPlugin, value, alert);
      } else {
        _deleteAlertEvents(_calendars[0].id, value.startTime);
      }
    }
  }

  //?????????????????????????????????
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
        localAccountName: "iF??????1",
      );
      if (result.isSuccess) {
        _deleteAlertEvents(result.data, startTime);
      }
    } else {
      _deleteAlertEvents(_calendars[0].id, startTime);
    }
  }

  //????????????
  void createEvent(
      String calendarId, DeviceCalendarPlugin _deviceCalendarPlugin, CourseModel value, String alert) async {
    Event _event = new Event(calendarId);
    DateTime startTime = DateUtil.stringToDateTime(value.startTime);
    _event.start = startTime;
    var endTime = DateUtil.stringToDateTime(value.endTime);
    List<Reminder> _reminders = <Reminder>[];
    _reminders.add(new Reminder(minutes: howEarlyToRemind));
    _event.end = endTime;
    _event.title = "IF:${value.title ?? "??????????????????"}";
    _event.description = "?????????????????????${value.title != null ? "${value.title}" : ""}????????????,????????????!";
    _event.reminders = _reminders;
    await _deviceCalendarPlugin.createOrUpdateEvent(_event);
  }

//  ??????????????????
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

  ///?????????????????????
  onClickAttention(int attntionResult) async {
    liveModel.coachDto?.relation = attntionResult;
  }


  ///???????????????
  onClickCoach() async {
    if (await isOffline()) {
      ToastShow.show(msg: "???????????????!", context: context);
      return;
    }
    jumpToUserProfilePage(context, liveModel.coachDto?.uid,
        avatarUrl: liveModel.coachDto?.avatarUri, userName: liveModel.coachDto?.nickName, callback: (dynamic r) {
        bool result=context.read<UserInteractiveNotifier>().value.profileUiChangeModel[liveModel.coachDto.uid].isFollow;
      print("result:$result");
      if (null != result && result is bool) {
        liveModel.coachDto.relation = result ? 0 : 1;
        if (mounted) {
          reload(() {});
        }
      }
    });
  }

  ///?????????????????????????????????
  onClickOtherComplete() {
    // AppRouter.navigateToOtherCompleteCoursePage(context,liveModel.id);
  }

  bool isOfflineBool = false;

  Future<bool> isOffline() async {
    ConnectivityResult connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      if (isOfflineBool) {
        isOfflineBool = false;
        getDataAction();
      }
      return false;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      if (isOfflineBool) {
        isOfflineBool = false;
        getDataAction();
      }
      return false;
    } else {
      isOfflineBool = true;
      return true;
    }
  }

  //?????????????????????
  onClickShowAllAction() {
    isShowAllItemAction = true;
    reload(() {});
  }

  //??????????????????
  void getDataAction({bool openLiveCourse = false}) async {
    if (await isOffline()) {
      recommendLoadingStatus = LoadingStatus.STATUS_COMPLETED;
      if (mounted) {
        reload(() {});
      }
      return;
    }
    recommendLoadingStatus = LoadingStatus.STATUS_COMPLETED;
    //????????????
    Map<String, dynamic> model = await liveCourseDetail(courseId: liveCourseId);
    if (model["code"] != null && model["code"] == CODE_SUCCESS && model["dataMap"] != null) {
      liveModel = CourseModel.fromJson(model["dataMap"]);
      if (openLiveCourse) {
        //???????????????????????????????????? ?????????????????????????????????
        if (isLoggedIn && Application.machine != null) {
          openLiveCourseDetailPage(Application.machine.machineId, liveCourseId, liveModel.startTime);
        }
      }
      print("liveCourseState:${liveModel.liveCourseState}");
      loadingStatus = LoadingStatus.STATUS_COMPLETED;
      if (mounted) {
        reload(() {});
      }
    } else {
      loadingStatus = LoadingStatus.STATUS_IDEL;
      Future.delayed(Duration(seconds: 1), () {
        if (mounted) {
          reload(() {});
        }
      });
    }
  }

  //????????????????????????
  void _animateToIndex() async {
    print("???????????????");
    scrollController.animateTo(0, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  ///------------------------------?????????????????????????????????  start --------------------------------------------------------

  //?????????
  void _login() async {
    if (await isOffline()) {
      ToastShow.show(msg: "???????????????!", context: context);
      return;
    }

    ToastShow.show(msg: "????????????app!", context: context);
    // ?????????
    AppRouter.navigateToLoginPage(context);
  }

  //?????????????????????????????????
  void _judgeBookOrCancelBook({bool bindingTerminal, bool isVip}) async {
    if (await isOffline()) {
      ToastShow.show(msg: "???????????????!", context: context);
      return;
    }
    print("---------------------------");
    if (liveModel.playType == 2) {
      _bookLiveCourse(liveModel, 0, true, bindingTerminal: bindingTerminal);
    } else {
      showAppDialog(context,
          title: "????????????",
          info: "????????????????????????",
          barrierDismissible: false,
          cancel: AppDialogButton("??????", () {
            print("????????????");
            return true;
          }),
          confirm: AppDialogButton("??????", () {
            print("???????????????");
            _bookLiveCourse(liveModel, 0, true);
            return true;
          }));
    }
  }

  //???????????????--?????????
  void _seeVideo() async{

    if (await isOffline()) {
      ToastShow.show(msg: "???????????????!", context: context);
      return;
    }
    if (liveModel.playType == 3) {
      ToastShow.show(msg: "??????", context: context);
    } else {
      print("?????????????????????");
      gotoLiveVideoRoomPage();
    }
  }

  //????????????
  void gotoLiveVideoRoomPage() async {
    if (!(judgeIsStart())) {
      ToastShow.show(msg: "??????????????????", context: context);
      return;
    }
    AppRouter.navigateLiveRoomPage(context, liveModel, callback: (int coachRelation) {
      liveModel.coachDto.relation = coachRelation;
      if (mounted) {
        reload(() {});
      }
    });
  }

  //????????????????????????
  void _useTerminal() async {

    if (await isOffline()) {
      ToastShow.show(msg: "???????????????!", context: context);
      return;
    }
    if (!(judgeIsStart())) {
      ToastShow.show(msg: "??????????????????", context: context);
      return;
    }
    ToastShow.show(msg: "????????????????????????", context: context);
    startVideoCourse(Application.machine.machineId, liveCourseId);
    AppRouter.navigateToMachineRemoteController(context);
  }

  //????????????????????????
  void _loginTerminal() async {
    if (await isOffline()) {
      ToastShow.show(msg: "???????????????!", context: context);
      return;
    }
    print("????????????????????????");
    if (Application.token.anonymous == 0) {
      gotoScanCodePage(context);
    } else {
      AppRouter.navigateToLoginPage(context);
    }
  }

  //??????vip
  void _openVip() async{
    if (await isOffline()) {
      ToastShow.show(msg: "???????????????!", context: context);
      return;
    }
    AppRouter.navigateToVipPage(context, VipState.NOTOPEN, openOrNot: false);
  }

  //????????????
  void applyTerminalTrainingPr() async {
    applyTerminalTraining(courseId: liveModel.id, startTime: liveModel.startTime);
    ToastShow.show(msg: "??????????????????????????????????????????", context: context);
  }

  bool judgeIsStart() {
    // //????????????
    // Map<String, dynamic> model = await (isHaveStartTime ? liveCourseDetail : getLatestLiveById)(courseId: liveCourseId);
    // if(model!=null){
    //   LiveVideoModel liveModel = LiveVideoModel.fromJson(model);
    //   return liveModel.liveCourseState==1;
    // }
    return liveModel.liveCourseState == 1;
    // return true;
  }

  ///------------------------------?????????????????????????????????  end --------------------------------------------------------

}
