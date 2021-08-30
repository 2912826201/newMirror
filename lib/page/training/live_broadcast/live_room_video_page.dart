import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:fijkplayer/fijkplayer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/training/course_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/config/shared_preferences.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/page/search/sub_page/should_build.dart';
import 'package:mirror/util/event_bus.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/dialog.dart';

class LiveRoomVideoPage extends StatefulWidget {
  final int liveCourseId;
  final String coachId;

  const LiveRoomVideoPage({
    Key key,
    @required this.liveCourseId,
    @required this.coachId,
  }) : super(key: key);

  @override
  _LiveRoomVideoPageState createState() => _LiveRoomVideoPageState(liveCourseId, coachId);
}

class _LiveRoomVideoPageState extends XCState {
  _LiveRoomVideoPageState(this.liveCourseId, this.coachId);

  final int liveCourseId;
  final String coachId;

  String url = "rtmp://58.200.131.2:1935/livetv/cctv13";
  final FijkPlayer player = FijkPlayer();
  LoadingStatus loadingStatus = LoadingStatus.STATUS_LOADING;
  StreamSubscription<ConnectivityResult> connectivityListener;

  Timer _timerAsyncPreparing;
  Timer _timer;
  int _timerCount = 0;
  int asyncPreparingCount = 0;

  @override
  void initState() {
    super.initState();
    //加入聊天室
    Application.rongCloud.joinChatRoom(coachId);
    //判断是否被禁言
    AppPrefs.setLiveRoomMuteMessage(int.parse(coachId));
    // player.setDataSource(url, autoPlay: true);
    EventBus.getDefault().registerNoParameter(exit, EVENTBUS_LIVEROOM_TESTPAGE, registerName: EVENTBUS_LIVEROOM_EXIT);
    loadingStatus = LoadingStatus.STATUS_LOADING;
    getLiveVideoUrl();
    _initConnectivity();
    _initTimer();

    player.addListener(() {
      if (player.state == FijkState.error) {
        _clearTimeAsyncPreparing();
        if (null != player.value.exception.message && player.value.exception.message == "Operation not permitted") {
          if (_timerCount < 5) {
            print("直播异常");
            player.stop();
            _showAppDialog("直播未开播", "直播未开播，请稍后再来");
          } else {
            // ToastShow.show(msg: "直播中断了", context: context);
            print("直播中断了");
            _showAppDialog("直播结束", "直播结束，看看其他的直播吧");
          }
        } else {
          // ToastShow.show(msg: "直播异常", context: context);
          print("直播异常");
          _showAppDialog("直播未开播", "直播未开播，请稍后再来");
        }
      } else if (player.state == FijkState.asyncPreparing) {
        _initTimerAsyncPreparing();
      } else {
        _clearTimeAsyncPreparing();
      }
      print("走了监听:${player.value.exception.message},${player.value.exception.code},${player.state}");
    });
  }

  //退出界面
  void exit() {
    print("退出界面几次");
    Future.delayed(Duration(milliseconds: 100), () {
      EventBus.getDefault().unRegister(pageName: EVENTBUS_LIVEROOM_TESTPAGE, registerName: EVENTBUS_LIVEROOM_EXIT);
      //退出聊天室
      Application.rongCloud.quitChatRoom(coachId);
      // player.stop();
      player.release();
      connectivityListener.cancel();
      _clearTimeAsyncPreparing();
      _clearTimer();
      Navigator.of(context).pop();
    });
  }

  @override
  Widget shouldBuild(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Container(
        child: Stack(
          children: [
            judgeShowUi(),
            getOccludeUi(),
          ],
        ),
      ),
    );
  }

  Widget judgeShowUi() {
    if (loadingStatus == LoadingStatus.STATUS_LOADING) {
      return getLoading();
    } else if (loadingStatus == LoadingStatus.STATUS_IDEL) {
      return getErrorUi();
    } else {
      return getShowVideoUi();
    }
  }

  Widget getLoading() {
    return Container(
      color: AppColor.textPrimary1,
      alignment: Alignment.centerLeft,
      width: ScreenUtil.instance.width,
      height: ScreenUtil.instance.height,
      child: Center(
        child: Container(
          height: 24.0,
          width: 24.0,
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget getErrorUi() {
    return Container(
      color: AppColor.textPrimary1,
      alignment: Alignment.centerLeft,
      width: ScreenUtil.instance.width,
      height: ScreenUtil.instance.height,
      child: Center(
        child: Text("直播加载失败！！！", style: TextStyle(color: AppColor.white, fontSize: 18)),
      ),
    );
  }

  //展示直播的ui
  Widget getShowVideoUi() {
    return Container(
      color: AppColor.textPrimary1,
      alignment: Alignment.centerLeft,
      width: ScreenUtil.instance.width,
      height: MediaQuery.of(context).size.height,
      child: SingleChildScrollView(
          child: Column(
        children: [
          Container(
            width: ScreenUtil.instance.width,
            height: MediaQuery.of(context).size.height,
            child: FijkView(
              panelBuilder: fijkPanel2Builder(snapShot: true),
              player: player,
              color: AppColor.mainBlack,
              fit: FijkFit.cover,
              fsFit: FijkFit.cover,
            ),
          )
        ],
      )),
    );
  }

  //遮挡
  Widget getOccludeUi() {
    return Container(
      width: ScreenUtil.instance.width,
      height: ScreenUtil.instance.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            height: 64,
            width: ScreenUtil.instance.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColor.textPrimary1.withOpacity(0.35),
                  AppColor.textPrimary1.withOpacity(0.001),
                ],
              ),
            ),
          ),
          Container(
            height: 64,
            width: ScreenUtil.instance.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColor.textPrimary1.withOpacity(0.001),
                  AppColor.textPrimary1.withOpacity(0.35),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  //获取聊天室的直播地址
  void getLiveVideoUrl() async {
    Map<String, dynamic> map = await getPullStreamUrl(liveCourseId);
    if (map["code"] == 200) {
      if (map["data"] != null && map["data"]["url"] != null) {
        print("直播地址：${map["data"].toString()}");
        url = map["data"]["url"];
        print("直播地址url：$url");
        player.setDataSource(url, autoPlay: true);
        loadingStatus = LoadingStatus.STATUS_COMPLETED;
      } else {
        if(context!=null&&mounted) {
          ToastShow.show(msg: "暂无该场直播!", context: context);
        }
        loadingStatus = LoadingStatus.STATUS_IDEL;
      }
    } else {
      if(context!=null&&mounted) {
        ToastShow.show(msg: "直播地址获取失败!", context: context);
      }
      loadingStatus = LoadingStatus.STATUS_IDEL;
    }
    if (mounted) {
      reload(() {});
    }
  }

  //获取网络连接状态
  _initConnectivity() async {
    connectivityListener = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.mobile) {
        print("移动网");
        player.reset();
      } else if (result == ConnectivityResult.wifi) {
        player.reset();
        print("wifi");
      } else {
        player.stop();
        print("无网了");
        _showAppDialog("网络连接失败", "网络已断开，请检查网络设置。");
      }
    });
  }

  _clearTimeAsyncPreparing() {
    if (_timerAsyncPreparing != null) {
      _timerAsyncPreparing.cancel();
      _timerAsyncPreparing = null;
    }
  }

  _clearTimer() {
    if (_timer != null) {
      _timer.cancel();
      _timer = null;
    }
  }

  _initTimerAsyncPreparing() {
    if (_timerAsyncPreparing != null) {
      return;
    }
    _timerAsyncPreparing = Timer.periodic(Duration(seconds: 1), (timer) {
      if (player.state == FijkState.asyncPreparing) {
        asyncPreparingCount++;
        if (asyncPreparingCount > 10) {
          asyncPreparingCount = 0;
          _timerAsyncPreparing.cancel();
          _timerAsyncPreparing = null;
          player.stop();
          _showAppDialog("网络较弱", "网络较弱，请检查网络设置");
        }
      } else {
        asyncPreparingCount = 0;
        _timerAsyncPreparing.cancel();
        _timerAsyncPreparing = null;
      }
    });
  }

  _initTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _timerCount++;
      if (_timerCount >= 10) {
        _clearTimer();
      }
    });
  }

  _showAppDialog(String title, String subtitle) {
    if (context != null) {
      EventBus.getDefault().post(registerName: EVENTBUS_ON_CLICK_BODY);
      showAppDialog(context,
          title: title,
          info: subtitle,
          barrierDismissible: false,
          confirm: AppDialogButton("确定", () {
            print("点击了确定");
            return true;
          }));
    }
  }
}
