import 'dart:async';
import 'dart:convert';
import 'package:mirror/api/training/course_api.dart';
import 'package:mirror/data/model/training/course_mode.dart';
import 'package:mirror/data/model/training/course_model.dart';
import 'package:mirror/data/model/training/training_schedule_model.dart';
import 'package:mirror/page/training/machine/remote_controller_progress_bar.dart';
import 'package:mirror/util/event_bus.dart';
import 'package:mirror/util/toast_util.dart';
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
import 'package:mirror/widget/seekbar.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

/// remote_controller_page
/// Created by yangjiayi on 2020/12/31.

//机器遥控器页

///courseId：课程id,直播课程id或者视频课程的id
///liveRoomId：直播间id
///modeType:类型,[CourseMode]
class RemoteControllerPage extends StatefulWidget {
  final int courseId;
  final int liveRoomId;
  final String modeType;

  RemoteControllerPage({this.courseId, this.liveRoomId, this.modeType = mode_null});

  @override
  _RemoteControllerState createState() => _RemoteControllerState(courseId, modeType);
}

class _RemoteControllerState extends State<RemoteControllerPage> {
  String _title = "终端遥控";

  int liveRoomId;

  int courseId;
  String modeType;

  _RemoteControllerState(this.courseId, this.modeType);

  int _totalDuration = 0;
  double _currentPosition = 0;

  //最大值不变
  bool _currentPositionNoConstant = false;
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

  GlobalKey<RemoteControllerProgressBarState> progressBarChildKey = GlobalKey();

  Timer timer;

  MachineModel machineModel;

  CourseModel liveVideoModel;

  bool _showDialog=false;
  BuildContext contextDialog;

  @override
  void dispose() {
    super.dispose();
    if (isLiveRoomController() && liveRoomId != null) {
      //退出聊天室
      Application.rongCloud.quitChatRoom(liveRoomId.toString());
    }
    _unRegisterEventBus();
    if (timer != null) {
      timer.cancel();
      timer = null;
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

    _getCourseInformation();
    _initEventBus();
  }

  _parseModelToPartList(CourseModel liveVideoModel) {
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
      } else if (i < _partList.length - 1) {
        time -= _partList[i].duration;
      } else {
        _partProgress = _partList[i].duration.toDouble();
      }
    }
    if (isLiveRoomController()) {
      _remainingPartTime = _currentPosition.toInt();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: _annotatedRegionUi(),
        onWillPop: _requestPop);
  }


  // 监听返回
  Future<bool> _requestPop() async {
    // print("isNullCourse:${isNullCourse()}");
    // print("machineModel:${machineModel!=null}");
    // print("machineModel:${machineModel?.machineId!=null}");
    if (!isNullCourse()) {
      if (machineModel != null) {
        if (machineModel.machineId != null) {
          bool result = await remoteControlPause(machineModel.machineId, courseId);
          if (result != null && result) {
            _showPauseDialog();
            return new Future.value(false);
          }
        }
      }
    }
    return new Future.value(true);
  }

  _leadingOnTap()async{
    if(await _requestPop()){
      Navigator.of(context).pop();
    }
  }

  Widget _annotatedRegionUi(){
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        appBar: CustomAppBar(
          titleString: _title,
          leadingOnTap:_leadingOnTap,
          actions: [
            Visibility(
              visible: isLiveRoomController() && liveRoomId != null,
              child: CustomAppBarIconButton(
                  svgName: AppIcon.nav_danmaku,
                  iconColor: AppColor.white,
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
                iconColor: AppColor.white,
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
          //上方图片及状态视图显示部分
          Container(
            height: 260,
            child: _buildScreen(),
          ),
          Container(
            height: 12,
            color: AppColor.bgWhite,
          ),
          //下方操作面板部分
          _buildPanel(notifier),
        ],
      ),
    );
  }

  Widget _buildScreen() {
    return Stack(
      children: [
        Visibility(visible: isNullCourse(), child: _buildMachinePic()),
        Visibility(visible: !isNullCourse(), child: _buildVideoCourse()),
      ],
    );
  }

  Widget _buildMachinePic() {
    return Center(
      child: Container(
        // color: AppColor.mainBlue,
        child: Image.asset("assets/png/terminal_png.png"),
      ),
    );
  }

  Widget _buildVideoCourse() {
    return RemoteControllerProgressBar(
      progressBarChildKey,
      _partList,
      _currentPartIndex,
      _partProgress,
      _remainingPartTime,
      _indexMapWithoutRest,
      _partAmountWithoutRest,
      isLiveRoomController(),
      liveVideoModel,
      machineModel == null ? 0 : machineModel.startCourse,
    );
    //
    // if(isLiveRoomController()){
    //   _remainingPartTime=_currentPosition.toInt();
    // }
    // // print("_remainingPartTime:${_remainingPartTime}");
    // return Column(
    //   crossAxisAlignment: CrossAxisAlignment.center,
    //   children: [
    //     SizedBox(
    //       height: 214.5,
    //       width: 214.5,
    //       child: Stack(
    //         children: [
    //           Center(
    //             child: VideoCourseCircleProgressBar(_partList, _currentPartIndex, _partProgress),
    //           ),
    //           Center(
    //             child: Text(
    //               DateUtil.formatMillisecondToMinuteAndSecond(_remainingPartTime * 1000),
    //               style: TextStyle(
    //                 color: AppColor.textPrimary1,
    //                 fontSize: 32,
    //                 fontWeight: FontWeight.w500,
    //                 fontFamily: "BebasNeue",
    //               ),
    //             ),
    //           ),
    //         ],
    //       ),
    //     ),
    //     Text(
    //       _partList[_currentPartIndex].type == 1
    //           ? "休息"
    //           : "${_partList[_currentPartIndex].name} ${_indexMapWithoutRest[_currentPartIndex] + 1}/$_partAmountWithoutRest",
    //       style: TextStyle(color: AppColor.textPrimary2, fontSize: 16),
    //     )
    //   ],
    // );
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
            ),
          ),
          SizedBox(
            height: 46,
          ),
          Container(
            alignment: Alignment.center,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(3)),
              color: !isNullCourse() ? AppColor.textPrimary2 : AppColor.textHint,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                AppIconButton(
                  iconSize: 28,
                  iconColor: isLiveRoomController() ? AppColor.white.withOpacity(0.36) : AppColor.white,
                  svgName: AppIcon.skip_previous_28,
                  onTap: () {
                    if (isVideoRoomController()) {
                      print("上一段");
                      remoteControlPrevious(notifier.machine.machineId, courseId);
                    }
                  },
                  buttonHeight: 44,
                  buttonWidth: (ScreenUtil.instance.screenWidthDp - 40 * 2) / 3,
                ),
                AppIconButton(
                  iconSize: 28,
                  iconColor: AppColor.white,
                  svgName: AppIcon.pause_28,
                  onTap: () async {
                    if (!isNullCourse()) {
                      print("暂停");
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
                  iconColor: isLiveRoomController() ? AppColor.white.withOpacity(0.36) : AppColor.white,
                  onTap: () {
                    if (isVideoRoomController()) {
                      print("下一段");
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
          // Slider(
          //   max: _totalDuration.toDouble(),
          //   min: 0,
          //   value: min(_currentPosition, _totalDuration.toDouble()),
          //   onChanged: (position) {
          //     _currentPosition = position;
          //     _updateInfoByPosition();
          //     _setProgressBarChildKeyData();
          //   },
          // ),
          // FlatButton(
          //   onPressed: () {
          //     MachineModel machine = context.read<MachineNotifier>().machine;
          //     machine.status = (machine.status + 1) % 2;
          //     context.read<MachineNotifier>().setMachine(machine);
          //   },
          //   child: Text("连接/中断"),
          // ),
        ],
      ),
    );
  }

  _showPauseDialog() {
    if(_showDialog){
      return;
    }
    _showDialog=true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        contextDialog=context;
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
                        _showDialog=false;
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
                      _showDialog=false;
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
                    ),
                  ),
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
    if (null == content || content.length < 1) {
      ToastShow.show(msg: "发送内容为空", context: context);
      return;
    }
    if (liveRoomId == null) {
      ToastShow.show(msg: "进入直播间错误", context: context);
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
    textMap["toUserId"] = liveRoomId;
    textMap["subObjectName"] = ChatTypeModel.MESSAGE_TYPE_USER_BARRAGE;
    textMap["name"] = ChatTypeModel.MESSAGE_TYPE_USER_BARRAGE_NAME;
    textMap["data"] = text;
    msg.content = jsonEncode(textMap);
    await Application.rongCloud.sendChatRoomMessage(liveRoomId.toString(), msg);
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
                        iconColor: AppColor.white,
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

  int getMachineStatusInfoCount = 0;

  _getCourseInformation() async {
    if (isNullCourse()) {
      return;
    }
    getMachineStatusInfoCount = 0;
    liveVideoModel = await getCourseModel(courseId: courseId, type: modeType);
    if (liveVideoModel == null) {
      courseId = null;
      modeType = mode_null;
    } else {
      if (isLiveRoomController() && liveRoomId != null) {
        //退出聊天室
        Application.rongCloud.quitChatRoom(liveRoomId.toString());
      }
      liveRoomId = liveVideoModel.coachDto.uid;
      Future.delayed(Duration(milliseconds: 100), () {
        if (isLiveRoomController() && liveRoomId != null) {
          //加入聊天室
          Application.rongCloud.joinChatRoom(liveRoomId.toString());
        }
      });
      _parseModelToPartList(liveVideoModel);
      _parsePartList();
      if (!isNullCourse()) {
        print("机器状态：${machineModel == null}");
        while (!(machineModel != null && machineModel.isConnect == 1 && machineModel.inGame == 1)) {
          getMachineStatusInfoCount++;
          Duration duration;
          if (getMachineStatusInfoCount == 1) {
            duration = Duration.zero;
          } else {
            duration = Duration(seconds: 1);
          }
          await Future.delayed(duration, () async {
            List<MachineModel> machineList = await getMachineStatusInfo();
            if (machineList != null && machineList.isNotEmpty) {
              machineModel = machineList.first;
              if (machineModel != null && machineModel.isConnect == 1 && machineModel.inGame == 1) {
                if (machineModel.timestamp == null) {
                  machineModel.timestamp = new DateTime.now().millisecondsSinceEpoch;
                }
                if (machineModel.startCourse == null) {
                  _currentPosition = 0;
                  // machineModel.startCourse=DateUtil.stringToDateTime(liveVideoModel.startTime).millisecondsSinceEpoch;
                } else {
                  if (machineModel.timestamp < machineModel.startCourse) {
                    _currentPosition = 0;
                  } else {
                    _currentPosition = (machineModel.timestamp - machineModel.startCourse) / 1000;
                  }
                }
              }
            }
          });
          if (getMachineStatusInfoCount > 6) {
            break;
          }
        }
      }
      _updateInfoByPosition();
    }
    if (isLiveRoomController()) {
      if (timer != null) {
        timer.cancel();
        this.timer = null;
      }
      _timer();
    }
    if (mounted) {
      setState(() {});
    }
  }

  _initEventBus() {
    EventBus.init().registerNoParameter(_endOfTraining, EVENTBUS_REMOTE_CONTROLLER_PAGE, registerName: END_OF_TRAINING);

    EventBus.init()
        .registerSingleParameter(_startTraining, EVENTBUS_REMOTE_CONTROLLER_PAGE, registerName: START_TRAINING);

    EventBus.init()
        .registerSingleParameter(_startLiveCourse, EVENTBUS_REMOTE_CONTROLLER_PAGE, registerName: START_LIVE_COURSE);

    EventBus.init().registerSingleParameter(_scheduleTraining, EVENTBUS_REMOTE_CONTROLLER_PAGE,
        registerName: SCHEDULE_TRAINING_VIDEO);
  }

  _unRegisterEventBus() {
    EventBus.init().unRegister(pageName: EVENTBUS_REMOTE_CONTROLLER_PAGE, registerName: END_OF_TRAINING);
    EventBus.init().unRegister(pageName: EVENTBUS_REMOTE_CONTROLLER_PAGE, registerName: START_TRAINING);
    EventBus.init().unRegister(pageName: EVENTBUS_REMOTE_CONTROLLER_PAGE, registerName: SCHEDULE_TRAINING_VIDEO);
  }

  //机器退出训练
  _endOfTraining() {
    courseId = null;
    modeType = mode_null;
    if (timer != null) {
      timer.cancel();
      this.timer = null;
    }
    if (mounted) {
      setState(() {});
    }
  }

  //机器进入训练
  _startTraining(List list) {
    if (!(list[0] == courseId && list[1] == modeType)) {
      courseId = list[0];
      modeType = list[1];
      _currentPosition = 0;
      _getCourseInformation();
    }
  }

  //机器开始直播课件
  _startLiveCourse(List list) {
    if (isLiveRoomController() && list[0] == 4) {
      if (liveRoomId != null && liveRoomId == list[1]) {
        if (machineModel != null) {
          machineModel.startCourse = list[2];
        } else {
          machineModel = MachineModel();
          machineModel.startCourse = list[2];
        }
      }
    }
  }

  int timeSchedule = 0;

  // _scheduleTraining(TrainingScheduleModel model) {
  //   if(model.courseId!=courseId||!isVideoRoomController()){
  //     courseId=model.courseId;
  //     modeType=mode_video;
  //     _currentPosition=0;
  //     _getCourseInformation();
  //     return;
  //   }
  //   _currentPosition=0;
  //   for(int i=0;i<model.index;i++){
  //     _currentPosition+=_partList[i].duration;
  //   }
  //   double time = model.progressBar/1000;
  //   _currentPosition+=time;
  //   _currentPartIndex=model.index;
  //   _remainingPartTime = _partList[_currentPartIndex].duration - time.toInt();
  //   _partProgress = time / _partList[_currentPartIndex].duration;
  //
  //
  //   print("model:${model.index},${model.progressBar},$_currentPosition,$_remainingPartTime,$_partProgress,${model.timestamp-timeSchedule}");
  //   timeSchedule=model.timestamp;
  //   if(mounted){
  //     streamVideoCourseCircleProgressBar.sink.add(0);
  //     // _timeSchedule();
  //   }
  // }

  // 机器训练视频课程的训练进度
  _scheduleTraining(TrainingScheduleModel model) {
    if (model.courseId != courseId || !isVideoRoomController()) {
      courseId = model.courseId;
      modeType = mode_video;
      _currentPosition = 0;
      _getCourseInformation();
      return;
    }
    double currentPosition = 0;
    for (int i = 0; i < model.index; i++) {
      currentPosition += _partList[i].duration;
    }
    currentPosition += model.progressBar / 1000;

    print(
        "model:${model.index},${model.progressBar},$_currentPosition,$_remainingPartTime,$_partProgress,${model.timestamp - timeSchedule},$_currentPartIndex");
    _currentPositionNoConstant = false;
    if(model.pause==0){
      _currentPositionNoConstant=true;
      _showPauseDialog();
    }else {
      if(_showDialog&&contextDialog!=null){
        print("...");
        _showDialog=false;
        try{
          Navigator.pop(contextDialog);
        }catch (e){}
      }
      if (model.index == _currentPartIndex) {
        if (_currentPosition <= currentPosition) {
          print("_currentPositionNoConstant小于:_currentPosition$_currentPosition,$currentPosition");
          _currentPosition = currentPosition;
        } else if (_currentPosition - currentPosition >= 4) {
          print("_currentPositionNoConstant大于4秒:_currentPosition$_currentPosition,$currentPosition");
          _currentPosition = currentPosition;
        } else if (_currentPosition - currentPosition >= 2) {
          print("_currentPositionNoConstant大于2秒:_currentPosition$_currentPosition,$currentPosition");
          _currentPositionNoConstant = true;
        } else {
          print("_currentPositionNoConstant小于2秒:_currentPosition$_currentPosition,$currentPosition");
        }
      } else {
        print("_currentPositionNoConstant：index不同:_currentPosition$_currentPosition,$currentPosition");
        _currentPosition = currentPosition;
      }
    }

    if (isVideoRoomController()) {
      if (timer == null) {
        _timer();
      }
    }
  }

  //直播计时
  _timer() {
    timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (!_currentPositionNoConstant) {
        _updateInfoByPosition();
        if (mounted) {
          _setProgressBarChildKeyData();
        }
        if (_currentPosition == 0 && isLiveRoomController()) {
          if (machineModel != null &&
              machineModel.startCourse != null &&
              DateTime.now().millisecondsSinceEpoch >= machineModel.startCourse) {
            _currentPosition += 0.1;
          }
        } else {
          _currentPosition += 0.1;
        }
      }
    });
  }

  _setProgressBarChildKeyData() {
    if (!mounted ||
        progressBarChildKey == null ||
        progressBarChildKey.currentState == null ||
        progressBarChildKey.currentState.setStateData == null) {
      return;
    }
    progressBarChildKey.currentState.setStateData(
      _partList,
      _currentPartIndex,
      _partProgress,
      _remainingPartTime,
      _indexMapWithoutRest,
      _partAmountWithoutRest,
      isLiveRoomController(),
      _currentPosition,
      liveVideoModel,
      machineModel == null ? 0 : machineModel.startCourse,
    );
  }
}
