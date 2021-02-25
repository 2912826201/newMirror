import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mirror/api/machine_api.dart';
import 'package:mirror/data/model/machine_model.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:provider/provider.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/notifier/machine_notifier.dart';
import 'package:mirror/page/training/video_course/video_course_play_page.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/date_util.dart';
import 'package:mirror/widget/seekbar.dart';
import 'package:mirror/widget/video_course_circle_progressbar.dart';

/// remote_controller_page
/// Created by yangjiayi on 2020/12/31.

//机器遥控器页

class RemoteControllerPage extends StatefulWidget {
  @override
  _RemoteControllerState createState() => _RemoteControllerState();
}

class _RemoteControllerState extends State<RemoteControllerPage> {
  String _title = "终端遥控";

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

  @override
  void initState() {
    super.initState();
    _parsePartList();
    _updateInfoByPosition();
    _volume = context.read<MachineNotifier>().machine?.volume;
    _luminance = context.read<MachineNotifier>().machine?.luminance;
    _status = context.read<MachineNotifier>().machine?.status;
  }

  _parsePartList() {
    _indexMapWithoutRest.clear();
    _partAmountWithoutRest = 0;
    for (int i = 0; i < testPartList.length; i++) {
      //序号以除去休息的段落数量为基准计算 如果为是休息则序号不加 如果不是休息序号加1
      if (testPartList[i].type == 1) {
        _indexMapWithoutRest[i] = _partAmountWithoutRest - 1;
      } else {
        _indexMapWithoutRest[i] = _partAmountWithoutRest;
        _partAmountWithoutRest++;
      }
      _totalDuration += testPartList[i].duration;
    }
  }

  _updateInfoByPosition() {
    int time = _currentPosition.toInt();
    for (int i = 0; i < testPartList.length; i++) {
      _currentPartIndex = i;
      if (time <= testPartList[i].duration) {
        _remainingPartTime = testPartList[i].duration - time;
        _partProgress = time / testPartList[i].duration;
        return;
      } else {
        time -= testPartList[i].duration;
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
            CustomAppBarIconButton(
                icon: Icons.menu,
                iconColor: AppColor.black,
                isLeading: false,
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
    return Column(
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
    );
  }

  Widget _buildScreen() {
    // return _buildMachinePic();
    return _buildVideoCourse();
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 214.5,
          width: 214.5,
          child: Stack(
            children: [
              Center(
                child: VideoCourseCircleProgressBar(testPartList, _currentPartIndex, _partProgress),
              ),
              Center(
                  child: Text(
                DateUtil.formatMillisecondToMinuteAndSecond(_remainingPartTime * 1000),
                style: TextStyle(color: AppColor.textPrimary1, fontSize: 32, fontWeight: FontWeight.w500),
              )),
            ],
          ),
        ),
        Text(
          testPartList[_currentPartIndex].type == 1
              ? "休息"
              : "${testPartList[_currentPartIndex].name} ${_indexMapWithoutRest[_currentPartIndex] + 1}/$_partAmountWithoutRest",
          style: TextStyle(color: AppColor.textPrimary2, fontSize: 16),
        )
      ],
    );
  }

  Widget _buildPanel(MachineNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40.5, 16, 40.5, 0),
      child: Column(
        children: [
          SizedBox(
              height: 48,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                      alignment: Alignment.center,
                      height: 28,
                      width: 28,
                      child: Icon(
                        Icons.volume_up,
                        color: notifier.machine.status != 0 ? AppColor.textPrimary2 : AppColor.textHint,
                        size: 24,
                      )),
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
                  Container(
                      alignment: Alignment.center,
                      height: 28,
                      width: 28,
                      child: Icon(
                        Icons.wb_sunny,
                        color: notifier.machine.status != 0 ? AppColor.textPrimary2 : AppColor.textHint,
                        size: 24,
                      )),
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
                  Container(
                    alignment: Alignment.center,
                    height: 28,
                    width: 28,
                    child: Icon(
                      Icons.book,
                      color: AppColor.textPrimary2,
                      size: 24,
                    ),
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
                        Icon(
                          Icons.chevron_right,
                          color: AppColor.textHint,
                          size: 16,
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
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    print("上一段");
                  },
                  child: Container(
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.skip_previous,
                      color: AppColor.white,
                      size: 32,
                    ),
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    print("暂停");
                    _showPauseDialog();
                  },
                  child: Container(
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.pause,
                      color: AppColor.white,
                      size: 32,
                    ),
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    print("下一段");
                  },
                  child: Container(
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.skip_next,
                      color: AppColor.white,
                      size: 32,
                    ),
                  ),
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
              setState(() {
                _updateInfoByPosition();
              });
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
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            height: 74,
                            width: 74,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColor.textPrimary1,
                            ),
                            child: Icon(
                              Icons.stop,
                              size: 48,
                              color: AppColor.textHint,
                            ),
                          ),
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
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            height: 74,
                            width: 74,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColor.white,
                            ),
                            child: Icon(
                              Icons.play_arrow,
                              size: 48,
                              color: AppColor.textHint,
                            ),
                          ),
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
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(
                            Icons.close,
                            size: 18,
                          ),
                        ))
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
}
