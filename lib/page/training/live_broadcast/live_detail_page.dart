
import 'dart:convert';

import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/message/chat_message_profile_notifier.dart';
import 'package:mirror/data/model/training/live_video_model.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/data/model/message/chat_type_model.dart';
import 'package:mirror/data/notifier/machine_notifier.dart';
import 'package:mirror/data/notifier/token_notifier.dart';
import 'package:mirror/page/profile/vip/vip_not_open_page.dart';
import 'package:mirror/page/search/sub_page/should_build.dart';
import 'package:mirror/page/training/common/common_comment_page.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/date_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/dialog.dart';
import 'package:mirror/widget/feed/feed_share_popups.dart';
import 'package:mirror/widget/no_blue_effect_behavior.dart';
import 'package:mirror/api/training/live_api.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:mirror/page/training/common/common_course_page.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

import '../../../widget/sliver_custom_header_delegate.dart';
import 'package:provider/provider.dart';

/// 直播详情页
class LiveDetailPage extends StatefulWidget {
  const LiveDetailPage({
    Key key,
    @required this.liveCourseId,
    this.heroTag,
    this.commentDtoModel,
    this.fatherComment,
    this.liveModel,
    this.isHaveStartTime,
    this.isInteractive}) : super(key: key);

  final String heroTag;
  final int liveCourseId;
  final LiveVideoModel liveModel;
  final bool isHaveStartTime;
  final CommentDtoModel commentDtoModel;
  final CommentDtoModel fatherComment;
  final bool isInteractive;
  @override
  createState() {
    return LiveDetailPageState(liveModel: liveModel,heroTag:heroTag,
        liveCourseId:liveCourseId,commentDtoModel:commentDtoModel,
        fatherComment:fatherComment,isHaveStartTime: isHaveStartTime,isInteractive:isInteractive);
  }
}

class LiveDetailPageState extends XCState {
  LiveDetailPageState({Key key, this.liveModel,this.heroTag,
    this.liveCourseId,this.isHaveStartTime,this.commentDtoModel,this.fatherComment,this.isInteractive});


  String heroTag;
  int liveCourseId;
  bool isHaveStartTime;
  CommentDtoModel commentDtoModel;
  CommentDtoModel fatherComment;
  bool isInteractive;

  //当前直播的model
  LiveVideoModel liveModel;

  //加载状态
  LoadingStatus loadingStatus;
  LoadingStatus recommendLoadingStatus;

  //title文字的样式
  var titleTextStyle = TextStyle(
      fontSize: 18, fontWeight: FontWeight.bold, color: AppColor.textPrimary1);

  //上拉加载数据
  RefreshController _refreshController = RefreshController(initialRefresh: false);


  //是否可以回弹
  bool isBouncingScrollPhysics = false;

  //提前多久提醒---15分钟
  var howEarlyToRemind = 15;

  //粘合剂控件滚动控制
  ScrollController scrollController = ScrollController();

  //控制评论布局的滑动
  GlobalKey<CommonCommentPageState> childKey = GlobalKey();
  //评论子布局用来获取这个界面的高度
  List<GlobalKey> globalKeyList=<GlobalKey>[];
  //是否全部展示动作的item
  bool isShowAllItemAction=false;

  //判断用户登陆没有
  bool isLoggedIn;

  //判断是否绑定了终端
  bool bindingTerminal;


  @override
  void initState() {
    super.initState();

    isLoggedIn=context.read<TokenNotifier>().isLoggedIn;
    bindingTerminal=context.read<MachineNotifier>().machine!=null;

    if(liveModel==null) {
      loadingStatus = LoadingStatus.STATUS_LOADING;
    }else{
      loadingStatus = LoadingStatus.STATUS_COMPLETED;
    }
    recommendLoadingStatus=LoadingStatus.STATUS_LOADING;
    getDataAction();
  }

  @override
  Widget shouldBuild(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: _buildSuggestions(),
    );
  }

  //判断加载什么布局
  Widget _buildSuggestions() {
    var widgetArray = <Widget>[];
    //有数据
    if (loadingStatus == LoadingStatus.STATUS_COMPLETED) {
      return _buildSuggestionsComplete();
    } else {
      widgetArray.add(SizedBox(height: 40));
      widgetArray.add(getNoCompleteTitle(context,"直播课程详情页"));
      //在加载中
      if (loadingStatus == LoadingStatus.STATUS_LOADING) {
        widgetArray.add(Expanded(
            child: SizedBox(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )));
      } else {
        //加载失败
        widgetArray.add(Expanded(
            child: SizedBox(
              child: Center(
                child: GestureDetector(
                  child: Text("加载失败"),
                  onTap: () {
                    loadingStatus = LoadingStatus.STATUS_LOADING;
                    if(mounted){
                      reload(() {});
                    }
                    getDataAction();
                  },
                ),
              ),
            )));
      }
      return Container(
        child: Column(children: widgetArray),
      );
    }
  }

  //加载数据成功时的布局
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
              height: MediaQuery.of(context).size.height - 50-ScreenUtil.instance.bottomBarHeight,
              child: ScrollConfiguration(
                behavior: NoBlueEffectBehavior(),
                child: NotificationListener<ScrollNotification>(
                  onNotification: _onDragNotification,
                  child:getSmartRefresher(),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              height: 50.0+ScreenUtil.instance.bottomBarHeight,
              padding: EdgeInsets.only(bottom: ScreenUtil.instance.bottomBarHeight),
              color: AppColor.white,
              child: _getBottomBar(),
            ),
            Offstage(
              offstage: true,
              child: judgeResetPage(),
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

  //获取上拉下拉加载
  Widget getSmartRefresher(){
    globalKeyList.clear();
    GlobalKey globalKey0=new GlobalKey();
    GlobalKey globalKey1=new GlobalKey();
    GlobalKey globalKey2=new GlobalKey();
    GlobalKey globalKey3=new GlobalKey();
    GlobalKey globalKey4=new GlobalKey();
    globalKeyList.add(globalKey0);
    globalKeyList.add(globalKey1);
    globalKeyList.add(globalKey2);
    globalKeyList.add(globalKey3);
    globalKeyList.add(globalKey4);
    return SmartRefresher(
      enablePullDown: false,
      enablePullUp: true,
      footer: footerWidget(),
      controller: _refreshController,
      onLoading: (){
        childKey.currentState.onLoading();
      },
      child: CustomScrollView(
        controller: scrollController,
        physics: isBouncingScrollPhysics?BouncingScrollPhysics():ClampingScrollPhysics(),
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
          getTitleWidget(liveModel,context,globalKeyList[1]),
          getCoachItem(liveModel,context,onClickAttention,onClickCoach,globalKeyList[2]),
          getLineView(),
          getTrainingEquipmentUi(liveModel, context, titleTextStyle,globalKeyList[3]),
          getActionUiLive(liveModel,context,titleTextStyle,globalKeyList[4],isShowAllItemAction,onClickShowAllAction),
          getLineView(),
          _getCourseCommentUi(),
          SliverToBoxAdapter(
            child: SizedBox(height: 15,),
          )
        ],
      ),
    );
  }

  Widget _getCourseCommentUi(){
    return SliverToBoxAdapter(
      child: Visibility(
        visible: recommendLoadingStatus==LoadingStatus.STATUS_COMPLETED,
        child: CommonCommentPage(
          key:childKey,
          scrollController: scrollController,
          refreshController: _refreshController,
          fatherComment:fatherComment,
          targetId:liveModel.id,
          targetType:1,
          isInteractiveIn:isInteractive,
          pageCommentSize:20,
          pageSubCommentSize:3,
          isShowHotOrTime:true,
          commentDtoModel:commentDtoModel,
          isShowAt:false,
          globalKeyList: globalKeyList,
        ),
      ),
    );
  }

  //获取底部按钮
  Widget _getBottomBar() {

    //todo 判断用户是不是vip缺少开通vip的回调
    bool isVip = Application.profile.isVip==1;

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
          Icon(Icons.headset),
          Text((liveModel.playType == 3 ? liveModel.getGetPlayType() : "试听")),
        ],
      ),
    );

    EdgeInsetsGeometry tempEd = (liveModel.getGetPlayType() == "回放" ? marginRight32 : marginRight16);
    Widget widget1 = getBtnUi(false, "使用终端训练", textStyle, double.infinity, 40, tempEd);
    Widget widget2 = getBtnUi(false, "登陆终端使用终端播放", textStyle, double.infinity, 40, tempEd);
    Widget widget4 = getBtnUi(false, "回放", textStyle, 94, 40, marginLeft32Right16);
    Widget widget5 = getBtnUi(true, "开通vip使用终端播放", textStyleVip, double.infinity, 40, tempEd);
    Widget widget6 = getBtnUi(false, liveModel.getGetPlayType(), textStyle, double.infinity, 40, margin_32);
    Widget widget7 = getBtnUi(false, "已结束", textStyleEnd, double.infinity, 40, margin_32);

    var childrenArray = <Widget>[];

    if(liveModel.endState!=null&&liveModel.endState==0||(liveModel.getGetPlayType()=="已结束")){
      //已结束
      childrenArray.add(Expanded(child: SizedBox(child: GestureDetector(child: widget7, onTap: _login))));
    }else {
      if (!isLoggedIn) {
        //没有登录
        childrenArray.add(Expanded(child: SizedBox(child: GestureDetector(child: widget6, onTap: _login))));
      } else {
        //登录了

        //判断是不是需要预约或者是已预约的课程
        if (liveModel.playType == 2 || liveModel.playType == 4) {
          //判断是不是需要预约
          childrenArray.add(Expanded(child: SizedBox(child: GestureDetector(child: widget6, onTap:
              () => _judgeBookOrCancelBook(bindingTerminal: bindingTerminal, isVip: isVip)))));
        } else {
          if (liveModel.playType == 3) {
            //回放
            childrenArray.add(GestureDetector(child: widget4, onTap: _seeVideo));
          } else {
            //试听
            childrenArray.add(GestureDetector(child: widget3, onTap: _seeVideo));
          }
          //判断绑定设备没有
          if (bindingTerminal) {
            //绑定了终端

            //判断我是不是需要开通vip才能观看
            //todo 判断这个课程是不是vip直播
            if (liveModel.playType == 1) {
              if (isVip) {
                //不再需要开通vip
                childrenArray.add(
                    Expanded(child: SizedBox(child: GestureDetector(child: widget1, onTap: _useTerminal))));
              } else {
                //需要开通vip
                childrenArray.add(Expanded(child: SizedBox(child: GestureDetector(child: widget5, onTap: _openVip))));
              }
            } else if (liveModel.playType == 2) {
              //todo 付费课程--目前写的是开通vip
              childrenArray.add(Expanded(child: SizedBox(child: GestureDetector(child: widget5, onTap: _openVip))));
            } else {
              //不再需要开通vip
              childrenArray.add(Expanded(child: SizedBox(child: GestureDetector(child: widget1, onTap: _useTerminal))));
            }
          } else {
            //没有绑定终端
            childrenArray.add(Expanded(child: SizedBox(child: GestureDetector(child: widget2, onTap: _loginTerminal))));
          }
        }
      }
    }

    return Container(
      width: MediaQuery
          .of(context)
          .size
          .width,
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
    } else if(text=="已结束"){
      colors.add(AppColor.bgWhite);
      colors.add(AppColor.bgWhite);
    }else{
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
        child: Text(text == "去上课" ? "试听" : text, style: textStyle,),
      ),
    );
  }



  //这个直播是否有预约的回调
  Widget judgeResetPage() {
    return Consumer<ChatMessageProfileNotifier>(
      builder: (context, notifier, child) {
        bool isResetCoursePage = context.select((ChatMessageProfileNotifier value) => value.isResetCoursePage);
        if (isResetCoursePage) {
          Message message = context.select((ChatMessageProfileNotifier value) => value.resetMessage);
          context.watch<ChatMessageProfileNotifier>().isResetCoursePage = false;
          if (message != null) {
            Map<String, dynamic> mapGroupModel = json.decode(message.originContentMap["data"]);
            if(mapGroupModel!=null&&mapGroupModel["courseId"]!=null&&mapGroupModel["handleType"]!=null&&
                mapGroupModel["startTime"]!=null&&mapGroupModel["startTime"] is String
                &&mapGroupModel["courseId"] is int&&mapGroupModel["handleType"] is int){
              updateBookState(mapGroupModel["courseId"],mapGroupModel["handleType"],mapGroupModel["startTime"]);
            }
          }
        }
        return Container();
      },
    );
  }


  //当用户登陆成功后需要刷新数据
  Widget userLoginComplete() {
    return Consumer<TokenNotifier>(
      builder: (context, notifier, child) {
        if(!isLoggedIn&&notifier.isLoggedIn){
          Future.delayed(Duration(milliseconds: 100), () {
            if (mounted) {
              reload(() {});
            }
          });
          getDataAction();
        }
        isLoggedIn=notifier.isLoggedIn;
        return child;
      },
      child: Container(),
    );
  }
  //当用户绑定设备后
  Widget userBindingTerminal() {
    return Consumer<MachineNotifier>(
      builder: (context, notifier, child) {
        if(notifier.machine!=null){
          bindingTerminal=true;
          Future.delayed(Duration(milliseconds: 300),(){
            if(mounted){
              reload(() {});
            }
          });
        }else{
          bindingTerminal=false;
        }
        return child;
      },
      child: Container(),
    );
  }

  //修改直播课程预约的状态
  void updateBookState(int courseId,int bookState,String startTime){
    if(liveModel==null||liveModel.id==null){
      return;
    }
    if(liveModel.id==courseId){
      if(liveModel.playType==4&&bookState==0){
        liveModel.playType=2;
        liveModel.isBooked=0;
        deleteAlertEvents(courseId,startTime);
        Future.delayed(Duration(milliseconds: 50),(){
          if(mounted){reload(() {
          });}
        });
      }else if(liveModel.playType==2&&bookState==1){
        liveModel.playType=4;
        liveModel.isBooked=1;
        Future.delayed(Duration(milliseconds: 50),(){
          if(mounted){reload(() {
          });}
        });
      }
      return;
    }
  }


  //滑动的回调
  bool _onDragNotification(ScrollNotification notification) {
    ScrollMetrics metrics = notification.metrics;
    childKey.currentState.scrollHeightOld=metrics.pixels;
    if (metrics.pixels < 10) {
      if (isBouncingScrollPhysics) {
        isBouncingScrollPhysics = false;
        if(mounted){
          reload(() {});
        }
      }
    } else {
      if (!isBouncingScrollPhysics) {
        isBouncingScrollPhysics = true;
        if(mounted){
          reload(() {});
        }
      }
    }
    return false;
  }

  //分享的点击事件
  void _shareBtnClick() {
    openShareBottomSheet(
        context: context,
        map: liveModel.toJson(),
        chatTypeModel: ChatTypeModel.MESSAGE_TYPE_LIVE_COURSE,
    sharedType: 1);
  }




  ///预约流程
  ///

  Future<void> _bookLiveCourse(LiveVideoModel value, int index, bool isAddCalendar,{bool bindingTerminal=false}) async {
    int valuePlayType=value.playType;
    print(value.getGetPlayType());
    Map<String, dynamic> mapBook = await bookLiveCourse(
        courseId: value.id, startTime: value.startTime, isBook: valuePlayType == 2);
    if(mapBook!=null&&mapBook["code"]==200) {
      if (isAddCalendar) {
        onClickMakeAnAppointment(value, "", valuePlayType == 2);
      }
      if (mapBook["state"] != null&&mapBook["state"]&&bindingTerminal) {showAppDialog(context,
          title: "报名",
          info: "使用终端观看有机会加入直播小屏，获得教练实时指导，是否报名",
          cancel: AppDialogButton("仅上课", () {
            return true;
          }),
          confirm: AppDialogButton("我要报名", () {
            applyTerminalTrainingPr();
            return true;
          }));
      }
    }else if(mapBook!=null&&mapBook["code"]==321){
      ToastShow.show(msg: "预约失败:-时间不对", context: context);
    }else{
      getDataAction();
    }
    return;
  }

  //点击预约后-查询是否有创建提醒的空间id
  void onClickMakeAnAppointment(LiveVideoModel value, String alert, bool isBook) async {
    //todo android 添加日历提醒 测试没有问题-虽然没有全机型测试------ios还未测试
    await [Permission.calendar].request();
    DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();
    List<Calendar> _calendars;
    final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
    _calendars = calendarsResult?.data;
    if (_calendars == null || _calendars.length < 1) {
      var result = await _deviceCalendarPlugin.createCalendar("mirror", localAccountName: "mirror——1",);
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
        _deleteAlertEvents(_calendars[0].id,  value.startTime);
      }
    }
  }

  //删除已经预约的日历提醒
  void deleteAlertEvents(int courseId,String startTime) async {
    await [Permission.calendar].request();
    DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();
    List<Calendar> _calendars;
    final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
    _calendars = calendarsResult?.data;
    if (_calendars == null || _calendars.length < 1) {
      var result = await _deviceCalendarPlugin.createCalendar("mirror", localAccountName: "mirror——1",);
      if (result.isSuccess) {
        _deleteAlertEvents(result.data, startTime);
      }
    } else {
      _deleteAlertEvents(_calendars[0].id, startTime);
    }
  }

  //创建提醒
  void createEvent(String calendarId, DeviceCalendarPlugin _deviceCalendarPlugin,
      LiveVideoModel value, String alert) async {
    Event _event = new Event(calendarId);
    DateTime startTime = DateUtil.stringToDateTime(value.startTime);
    _event.start = startTime;
    var endTime = DateUtil.stringToDateTime(value.endTime);
    List<Reminder> _reminders = <Reminder>[];
    _reminders.add(new Reminder(minutes: howEarlyToRemind));
    _event.end = endTime;
    _event.title = value.title ?? "直播课程预约";
    _event.description = value.coursewareDto?.name;
    _event.reminders = _reminders;
    await _deviceCalendarPlugin.createOrUpdateEvent(_event);
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
          _calendars[0].id,
          RetrieveEventsParams(startDate: startDate, endDate: endDate));
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

  ///------------------------------底部按钮的所有点击事件  start --------------------------------------------------------

  //去登陆
  void _login() {
    ToastShow.show(msg: "请先登陆app!", context: context);
    // 去登录
    AppRouter.navigateToLoginPage(context);
  }


  //判断是预约还是取消预约
  void _judgeBookOrCancelBook({bool bindingTerminal, bool isVip}) {
    print("---------------------------");
    if (liveModel.playType == 2) {
      _bookLiveCourse(liveModel, 0, true,bindingTerminal: bindingTerminal);
    } else {
      showAppDialog(context,
          title: "取消预约",
          info: "确认取消预约吗？",
          cancel: AppDialogButton("取消", () {
            print("点了取消");
            return true;
          }),
          confirm: AppDialogButton("确定", () {
            print("点击了确定");
            _bookLiveCourse(liveModel, 0, true);
            return true;
          }));
    }
  }

  //回放和试听--看视频
  void _seeVideo() {
    if (liveModel.playType == 3) {
      ToastShow.show(msg: "回放", context: context);
    } else {
      ToastShow.show(msg: "试听", context: context);
    }
  }

  //使用终端进行训练
  void _useTerminal() {
    ToastShow.show(msg: "使用终端进行训练", context: context);
  }

  //登陆终端进行训练
  void _loginTerminal() {
    ToastShow.show(msg: "登陆终端进行训练", context: context);
  }

  //开通vip
  void _openVip() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return VipNotOpenPage(
        type: VipState.NOTOPEN,
      );
    }));
  }

  //报名终端
  void applyTerminalTrainingPr() async {
    applyTerminalTraining(courseId: liveModel.id, startTime: liveModel.startTime);
    ToastShow.show(msg: "已报名，若中选将收到系统消息", context: context);
  }



  ///这是关注的方法
  onClickAttention() {
    if(!(mounted&&isLoggedIn)){
      ToastShow.show(msg: "请先登陆app!", context: context);
      AppRouter.navigateToLoginPage(context);
      return;
    }
    if (!(liveModel.coachDto?.relation == 1 || liveModel.coachDto?.relation == 3)) {
      _getAttention(liveModel.coachDto?.uid);
    }
  }

  ///这是关注的方法
  _getAttention(int userId) async {
    int attntionResult = await ProfileAddFollow(userId);
    print('关注监听=========================================$attntionResult');
    if (attntionResult == 1 || attntionResult == 3) {
      liveModel.coachDto?.relation = 1;
      if(mounted){
        reload(() {});
      }
    }
  }

  ///点击了教练
  onClickCoach() {
    AppRouter.navigateToMineDetail(context, liveModel.coachDto?.uid);
  }
  ///点击了他人刚刚训练完成
  onClickOtherComplete() {
    // AppRouter.navigateToOtherCompleteCoursePage(context,liveModel.id);
  }

  //显示全部的动作
  onClickShowAllAction(){
    isShowAllItemAction=true;
    reload(() {});
  }

  //加载网络数据
  void getDataAction() async {
    String startTime="";
    if(liveModel!=null){
      startTime=liveModel.startTime;
    }
    recommendLoadingStatus=LoadingStatus.STATUS_COMPLETED;
    //加载数据
    Map<String, dynamic> model = await (isHaveStartTime?liveCourseDetail:getLatestLiveById)(courseId: liveCourseId, startTime: startTime);
    if (model == null) {
      loadingStatus = LoadingStatus.STATUS_IDEL;
      Future.delayed(Duration(seconds: 1), () {
        if(mounted){
          reload(() {});
        }
      });
    } else {
      liveModel = LiveVideoModel.fromJson(model);
      loadingStatus = LoadingStatus.STATUS_COMPLETED;
      if(mounted){
        reload(() {});
      }
    }
  }

}
