import 'dart:async';
import 'dart:convert';
import 'package:mirror/api/training/live_api.dart';
import 'package:mirror/data/model/training/live_video_mode.dart';
import 'package:mirror/data/model/training/live_video_model.dart';
import 'package:mirror/data/model/training/training_schedule_model.dart';
import 'package:mirror/util/event_bus.dart';
import 'package:mirror/widget/input_formatter/release_feed_input_formatter.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mirror/api/machine_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/data/model/machine_model.dart';
import 'package:mirror/data/model/message/chat_type_model.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/comment_input_bottom_bar.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/icon.dart';
import 'package:provider/provider.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/consta'
    'nt/style.dart';
import 'package:mirror/data/notifier/machine_notifier.dart';
import 'package:mirror/page/training/video_course/video_course_play_page.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/date_util.dart';
import 'package:mirror/widget/seekbar.dart';
import 'package:mirror/widget/video_course_circle_progressbar.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

/// remote_controller_page
/// Created by yangjiayi on 2020/12/31.

//机器遥控器页

///courseId：课程id,直播课程id或者视频课程的id
///modeTye:类型,[liveVideoMode]
class RemoteControllerPage extends StatefulWidget {
  final int courseId;
  final String modeType;

  RemoteControllerPage({this.courseId, this.modeType = mode_null});

  @override
  _RemoteControllerState createState() => _RemoteControllerState(courseId, modeType);
}

class _RemoteControllerState extends State<RemoteControllerPage> {
  String _title = "终端遥控";

  int courseId;
  String modeType;

  _RemoteControllerState(this.courseId, this.modeType);

  int _totalDuration = 0;
  double _currentPosition = 0;
  int _currentPartIndex = 0;
  int _remainingPartTime = 0;
  double _partProgress = 0;
  Map<int, int> _indexMapWithoutRest = {};
  int _partAmountWithoutRest = 0;

  int _volume;
  int _luminance;

  int _status;

  List<VideoCoursePart> _partList = [];

  //是不是直播间的控制
  bool isLiveRoomController() => modeType == mode_live;

  //是不是视频课的控制
  bool isVideoRoomController() => modeType == mode_video;

  //是不是空的课程
  bool isNullCourse() => modeType == mode_null;


  StreamController<int> streamVideoCourseCircleProgressBar = StreamController<int>();

  Timer timer;

  @override
  void dispose() {
    super.dispose();
    if (isLiveRoomController()) {
      //退出聊天室
      Application.rongCloud.quitChatRoom(courseId.toString());
    }
    streamVideoCourseCircleProgressBar.close();
    _unRegisterEventBus();
    if(timer!=null){
      timer.cancel();
      timer=null;
    }
  }

  @override
  void initState() {
    super.initState();
    _partList.addAll(testPartList);
    _parsePartList();
    _updateInfoByPosition();
    _volume = context.read<MachineNotifier>().machine?.volume;
    _luminance = context.read<MachineNotifier>().machine?.luminance;
    _status = context.read<MachineNotifier>().machine?.status;

    if (isLiveRoomController()) {
      //加入聊天室
      Application.rongCloud.joinChatRoom(courseId.toString());
    }
    _getCourseInformation();
    _initEventBus();

    if(isLiveRoomController()){
      _timer();
    }
  }

  _parseModelToPartList(LiveVideoModel liveVideoModel) {
    _partList.clear();
    liveVideoModel.coursewareDto.componentDtos.forEach((component) {
      List<String> urlList = [];
      component.scriptToVideo?.forEach((element) {
        urlList.add(element.videoUrl);
      });
      VideoCoursePart part = VideoCoursePart();
      part.videoList = urlList;
      part.duration = (component.times / 1000).floor();
      part.name = component.name;
      part.type = component.type == 3 ? 1 : 0;
      _partList.add(part);
    });
  }

  _parsePartList() {
    _indexMapWithoutRest.clear();
    _partAmountWithoutRest = 0;
    _totalDuration = 0;
    for (int i = 0; i < _partList.length; i++) {
      //序号以除去休息的段落数量为基准计算 如果为是休息则序号不加 如果不是休息序号加1
      if (_partList[i].type == 1) {
        _indexMapWithoutRest[i] = _partAmountWithoutRest - 1;
      } else {
        _indexMapWithoutRest[i] = _partAmountWithoutRest;
        _partAmountWithoutRest++;
      }
      _totalDuration += _partList[i].duration;
    }
  }

  _updateInfoByPosition() {
    double time = _currentPosition;
    for (int i = 0; i < _partList.length; i++) {
      _currentPartIndex = i;
      if (time <= _partList[i].duration) {
        _remainingPartTime = _partList[i].duration - time.toInt();
        _partProgress = time / _partList[i].duration;
        return;
      } else {
        time -= _partList[i].duration;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        appBar: CustomAppBar(
          titleString: _title,
          actions: [
            Visibility(
              visible: isLiveRoomController(),
              child: CustomAppBarIconButton(
                  svgName: AppIcon.nav_danmaku,
                  iconColor: AppColor.black,
                  onTap: () {
                    openInputBottomSheet(
                      buildContext: this.context,
                      voidCallback: _postMessage,
                      isShowAt: false,
                      isShowPostBtn: false,
                    );
                  }),
            ),
            CustomAppBarIconButton(
                svgName: AppIcon.nav_settings,
                iconColor: AppColor.black,
                onTap: () {
                  AppRouter.navigateToMachineSetting(context);
                }),
          ],
        ),
        body: Consumer<MachineNotifier>(
          builder: (context, notifier, child) {
            if (notifier.machine == null) {
              //因为在build过程中所以要delay
              Future.delayed(Duration.zero, () {
                Navigator.pop(context);
              });
              return Container();
            } else {
              //从已连接变为未连接时要弹窗
              if (notifier.machine.status == 0 && _status == 1) {
                Future.delayed(Duration.zero, () {
                  _showDisconnectPopup();
                });
              }
              _status = notifier.machine.status;
              return _buildBody(notifier);
            }
          },
        ),
      ),
    );
  }

  Widget _buildBody(MachineNotifier notifier) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            height: 260,
            child: _buildScreen(),
          ),
          Container(
            height: 12,
            color: AppColor.bgWhite,
          ),
          _buildPanel(notifier),
        ],
      ),
    );
  }

  Widget _buildScreen() {
    if (isNullCourse()) {
      return _buildMachinePic();
    } else {
      return _buildVideoCourse();
    }
  }

  Widget _buildMachinePic() {
    return Center(
      child: Container(
        height: 210,
        width: 114.5,
        color: AppColor.mainBlue,
      ),
    );
  }

  Widget _buildVideoCourse() {
    return StreamBuilder(
      stream: streamVideoCourseCircleProgressBar.stream,
      builder: (context, snapshot) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 214.5,
              width: 214.5,
              child: Stack(
                children: [
                  Center(
                    child: VideoCourseCircleProgressBar(_partList, _currentPartIndex, _partProgress),
                  ),
                  Center(
                    child: Text(
                      DateUtil.formatMillisecondToMinuteAndSecond(_remainingPartTime * 1000),
                      style: TextStyle(
                        color: AppColor.textPrimary1,
                        fontSize: 32,
                        fontWeight: FontWeight.w500,
                        fontFamily: "BebasNeue",
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              _partList[_currentPartIndex].type == 1
                  ? "休息"
                  : "${_partList[_currentPartIndex].name} ${_indexMapWithoutRest[_currentPartIndex] + 1}/$_partAmountWithoutRest",
              style: TextStyle(color: AppColor.textPrimary2, fontSize: 16),
            )
          ],
        );
      },
    );
  }

  Widget _buildPanel(MachineNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 16, 40, 0),
      child: Column(
        children: [
          SizedBox(
              height: 48,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AppIcon.getAppIcon(
                    AppIcon.volume,
                    28,
                    color: notifier.machine.status != 0 ? AppColor.textPrimary2 : AppColor.textHint,
                  ),
                  Expanded(
                      child: Container(
                    //slider会将handler的大小算在组件宽度 所以间距要减去handler的宽度的一半 才是进度条本体的间距
                    padding: const EdgeInsets.only(left: 6, right: 6),
                    child: AppSeekBar(100, 0, _volume.toDouble(), notifier.machine.status == 0,
                        (handlerIndex, lowerValue, upperValue) {
                      setState(() {
                        _volume = lowerValue.toInt();
                      });
                    }, (handlerIndex, lowerValue, upperValue) {
                      //调接口保存值
                      print("调接口保存音量：$lowerValue");
                      setMachineVolume(notifier.machine.machineId, lowerValue.toInt()).then((value) {
                        if (value) {
                          notifier.setMachine(notifier.machine..volume = lowerValue.toInt());
                        }
                      });
                    }),
                  )),
                  SizedBox(
                    width: 42,
                    child: Text(
                      "$_volume%",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 14,
                          color: notifier.machine.status != 0 ? AppColor.textPrimary2 : AppColor.textHint,
                          fontWeight: FontWeight.w500),
                    ),
                  )
                ],
              )),
          SizedBox(
            height: 12,
          ),
          SizedBox(
              height: 48,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AppIcon.getAppIcon(
                    AppIcon.luminance,
                    28,
                    color: notifier.machine.status != 0 ? AppColor.textPrimary2 : AppColor.textHint,
                  ),
                  Expanded(
                      child: Container(
                    //slider会将handler的大小算在组件宽度 所以间距要减去handler的宽度的一半 才是进度条本体的间距
                    padding: const EdgeInsets.only(left: 6, right: 6),
                    child: AppSeekBar(100, 0, _luminance.toDouble(), notifier.machine.status == 0,
                        (handlerIndex, lowerValue, upperValue) {
                      setState(() {
                        _luminance = lowerValue.toInt();
                      });
                    }, (handlerIndex, lowerValue, upperValue) {
                      //调接口保存值
                      print("调接口保存亮度：$lowerValue");
                      setMachineLuminance(notifier.machine.machineId, lowerValue.toInt()).then((value) {
                        if (value) {
                          notifier.setMachine(notifier.machine..luminance = lowerValue.toInt());
                        }
                      });
                    }),
                  )),
                  SizedBox(
                    width: 42,
                    child: Text(
                      "$_luminance%",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 14,
                          color: notifier.machine.status != 0 ? AppColor.textPrimary2 : AppColor.textHint,
                          fontWeight: FontWeight.w500),
                    ),
                  )
                ],
              )),
          SizedBox(
            height: 12,
          ),
          SizedBox(
              height: 48,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  notifier.machine.status == 0
                      ? AppIcon.getAppIcon(
                          AppIcon.machine_disconnected_28,
                          28,
                          color: AppColor.textPrimary2,
                        )
                      : AppIcon.getAppIcon(
                          AppIcon.machine_connected_28,
                          28,
                          color: AppColor.textPrimary2,
                        ),
                  SizedBox(
                    width: 12,
                  ),
                  Text(
                    "${notifier.machine.name}连接状态",
                    style: AppStyle.textRegular15,
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: () {
                      // 需求修改 无论是否状态为已连接 都可以进入机器信息页
                      // if (notifier.machine.status != 0) {
                      AppRouter.navigateToMachineConnectionInfo(context);
                      // }
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          notifier.machine.status != 0 ? "已连接" : "未连接",
                          style: TextStyle(fontSize: 14, color: AppColor.textPrimary2),
                        ),
                        Container(
                          alignment: Alignment.center,
                          height: 12,
                          width: 12,
                          child: Container(
                            height: 4,
                            width: 4,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: notifier.machine.status != 0 ? AppColor.lightGreen : AppColor.mainRed,
                            ),
                          ),
                        ),
                        AppIcon.getAppIcon(
                          AppIcon.arrow_right_16,
                          16,
                          color: AppColor.textHint,
                        ),
                      ],
                    ),
                  )
                ],
              )),
          SizedBox(
            height: 46,
          ),
          Container(
            alignment: Alignment.center,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(3)),
              color: notifier.machine.status != 0 ? AppColor.textPrimary2 : AppColor.textHint,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                AppIconButton(
                  iconSize: 28,
                  svgName: AppIcon.skip_previous_28,
                  onTap: () {
                    print("上一段");
                    if (!isNullCourse()) {
                      remoteControlPrevious(notifier.machine.machineId, courseId);
                    }
                  },
                  buttonHeight: 44,
                  buttonWidth: (ScreenUtil.instance.screenWidthDp - 40 * 2) / 3,
                ),
                AppIconButton(
                  iconSize: 28,
                  svgName: AppIcon.pause_28,
                  onTap: () async {
                    print("暂停");
                    if (!isNullCourse()) {
                      bool result = await remoteControlPause(notifier.machine.machineId, courseId);
                      if (result != null && result) {
                        _showPauseDialog();
                      }
                    }
                  },
                  buttonHeight: 44,
                  buttonWidth: (ScreenUtil.instance.screenWidthDp - 40 * 2) / 3,
                ),
                AppIconButton(
                  iconSize: 28,
                  svgName: AppIcon.skip_next_28,
                  onTap: () {
                    print("下一段");
                    if (!isNullCourse()) {
                      remoteControlNext(notifier.machine.machineId, courseId);
                    }
                  },
                  buttonHeight: 44,
                  buttonWidth: (ScreenUtil.instance.screenWidthDp - 40 * 2) / 3,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 16,
          ),
          Slider(
            max: _totalDuration.toDouble(),
            min: 0,
            value: _currentPosition,
            onChanged: (position) {
              _currentPosition = position;
              _updateInfoByPosition();
              streamVideoCourseCircleProgressBar.sink.add(0);
            },
          ),
          FlatButton(
            onPressed: () {
              MachineModel machine = context.read<MachineNotifier>().machine;
              machine.status = (machine.status + 1) % 2;
              context.read<MachineNotifier>().setMachine(machine);
            },
            child: Text("连接/中断"),
          ),
        ],
      ),
    );
  }

  _showPauseDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Dialog(
            backgroundColor: AppColor.transparent,
            elevation: 0,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () async {
                        if (isLiveRoomController()) {
                          await finishLiveCourse(context.read<MachineNotifier>().machine.machineId, courseId);
                        } else if (isVideoRoomController()) {
                          await finishVideoCourse(context.read<MachineNotifier>().machine.machineId, courseId);
                        }
                        Navigator.pop(context);
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          AppIcon.getAppIcon(AppIcon.remocon_stop_74, 74),
                          SizedBox(
                            height: 16,
                          ),
                          Text(
                            "退出训练",
                            style: TextStyle(color: AppColor.white, fontSize: 14),
                          )
                        ],
                      )),
                  SizedBox(
                    width: 53,
                  ),
                  GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () async {
                        await remoteControlResume(context.read<MachineNotifier>().machine.machineId, courseId);
                        Navigator.pop(context);
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          AppIcon.getAppIcon(AppIcon.remocon_play_74, 74),
                          SizedBox(
                            height: 16,
                          ),
                          Text(
                            "继续训练",
                            style: TextStyle(color: AppColor.white, fontSize: 14),
                          )
                        ],
                      )),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  //发送弹幕
  _postMessage(String content, List<Rule> rules) {
    if (!isLiveRoomController()) {
      return;
    }
    print("发送弹幕：$content");
    if (null == content || content.length < 1 && courseId != null) {
      return;
    }
    _sendChatRoomMsg(content);
  }

  //发送直播聊天信息
  _sendChatRoomMsg(text) async {
    TextMessage msg = TextMessage();
    UserInfo userInfo = UserInfo();
    userInfo.userId = Application.profile.uid.toString();
    userInfo.name = Application.profile.nickName;
    userInfo.portraitUri = Application.profile.avatarUri;
    msg.sendUserInfo = userInfo;
    Map<String, dynamic> textMap = Map();
    textMap["fromUserId"] = msg.sendUserInfo.userId.toString();
    textMap["toUserId"] = courseId;
    textMap["subObjectName"] = ChatTypeModel.MESSAGE_TYPE_USER_BARRAGE;
    textMap["name"] = ChatTypeModel.MESSAGE_TYPE_USER_BARRAGE_NAME;
    textMap["data"] = text;
    msg.content = jsonEncode(textMap);
    await Application.rongCloud.sendChatRoomMessage(courseId.toString(), msg);
  }

  _showDisconnectPopup() {
    showModalBottomSheet(
      context: context,
      elevation: 0,
      backgroundColor: AppColor.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
            color: AppColor.white,
          ),
          height: 389 + ScreenUtil.instance.bottomBarHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 10,
              ),
              Container(
                height: 44,
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        "连接中断",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppColor.black),
                      ),
                    ),
                    Positioned(
                      right: 16,
                      top: 0,
                      child: AppIconButton(
                        svgName: AppIcon.nav_close,
                        iconSize: 18,
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 24,
              ),
              Text(
                "检测到当前终端连接中断，请尝试以下办法：",
                style: AppStyle.textRegular15,
              ),
              SizedBox(
                height: 12,
              ),
              Text(
                "·检测终端是否成功启动",
                style: TextStyle(fontSize: 15, color: AppColor.textPrimary3),
              ),
              Text(
                "·检测终端网络连接状态",
                style: TextStyle(fontSize: 15, color: AppColor.textPrimary3),
              ),
              SizedBox(
                height: 18,
              ),
              Container(
                color: AppColor.mainBlue,
                height: 160,
                width: 160,
              )
            ],
          ),
        );
      },
    );
  }

  _getCourseInformation() async {
    if (isNullCourse()) {
      return;
    }
    LiveVideoModel liveVideoModel = await getLiveVideoModel(courseId: courseId, type: modeType);
    if (liveVideoModel == null) {
      courseId = null;
      modeType = mode_null;
    } else {
      _parseModelToPartList(liveVideoModel);
      _parsePartList();
      _updateInfoByPosition();
    }
    if (mounted) {
      setState(() {});
    }
  }



  _initEventBus(){
    EventBus.getDefault().registerNoParameter(_endOfTraining,
        EVENTBUS_REMOTE_CONTROLLER_PAGE, registerName: END_OF_TRAINING);

    EventBus.getDefault().registerSingleParameter(_startTraining,
        EVENTBUS_REMOTE_CONTROLLER_PAGE, registerName: START_TRAINING);

    EventBus.getDefault().registerSingleParameter(_scheduleTraining,
        EVENTBUS_REMOTE_CONTROLLER_PAGE, registerName: SCHEDULE_TRAINING_VIDEO);
  }

  _unRegisterEventBus(){
    EventBus.getDefault().unRegister(pageName: EVENTBUS_REMOTE_CONTROLLER_PAGE, registerName: END_OF_TRAINING);
    EventBus.getDefault().unRegister(pageName: EVENTBUS_REMOTE_CONTROLLER_PAGE, registerName: START_TRAINING);
    EventBus.getDefault().unRegister(pageName: EVENTBUS_REMOTE_CONTROLLER_PAGE, registerName: SCHEDULE_TRAINING_VIDEO);
  }



  //机器退出训练
  _endOfTraining() {
    courseId = null;
    modeType = mode_null;
    if (mounted) {
      setState(() {});
    }
  }

  //机器进入训练
  _startTraining(List list) {
    if (!(list[0] == courseId && list[1] == modeType)) {
      courseId = list[0];
      modeType = list[1];
      if (mounted) {
        setState(() {});
      }
    }
  }

  //机器训练视频课程的训练进度
  _scheduleTraining(TrainingScheduleModel model) {
    _currentPosition=0;
    for(int i=0;i<model.index;i++){
      _currentPosition+=_partList[i].duration;
    }
    int time = model.progressBar~/1000;
    _currentPosition+=time;
    _currentPartIndex=model.index;
    _remainingPartTime = _partList[_currentPartIndex].duration - time;
    _partProgress = time / _partList[_currentPartIndex].duration;
    if(mounted){
      streamVideoCourseCircleProgressBar.sink.add(0);
      // _timeSchedule();
    }
  }

  //直播计时
  _timer(){
    timer=Timer.periodic(Duration(milliseconds: 100), (timer) {
      _currentPosition +=0.1;
      if(_currentPartIndex>_partList[_partList.length-1].duration&&_currentPartIndex==_partList.length-1){
        this.timer.cancel();
        this.timer=null;
      }else {
        _updateInfoByPosition();
        if (mounted) {
          streamVideoCourseCircleProgressBar.sink.add(0);
        }
      }
    });
  }
}
