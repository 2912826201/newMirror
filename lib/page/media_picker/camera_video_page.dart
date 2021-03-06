import 'dart:async';
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/config/config.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/constants.dart';
import 'package:mirror/data/model/media_file_model.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/icon.dart';
import 'package:permission_handler/permission_handler.dart';

/// camera_video_page
/// Created by yangjiayi on 2021/1/13.

//相机录视频页
class CameraVideoPage extends StatefulWidget {
  CameraVideoPage({Key key, this.publishMode = 0, this.topicId}) : super(key: key);

  final int publishMode;
  final int topicId;

  @override
  CameraVideoState createState() => CameraVideoState();
}

class CameraVideoState extends State<CameraVideoPage> with WidgetsBindingObserver {
  //切换摄像头的时间间隔 1000ms
  final int _switchCameraInterval = 1000;
  int _latestSwitchCameraTime = 0;

  CameraController _controller;

  double _previewSize = 0;

  int _cameraIndex = 0;

  Size _cameraSize;

  String _filePath;

  bool _isRecording = false;
  int _milliDuration = 0;
  Timer _timer;

  @override
  void initState() {
    super.initState();
    // 获取屏幕宽以设置各布局大小
    _previewSize = ScreenUtil.instance.screenWidthDp;
    print("预览区域大小：$_previewSize");

    WidgetsBinding.instance.addObserver(this);

    print("Camera: ${Application.cameras}");
    if (Application.cameras.isNotEmpty) {
      onCameraSelected(Application.cameras[_cameraIndex]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        backgroundColor: AppColor.mainBlack,
        brightness: Brightness.dark,
        hasLeading: widget.publishMode == 2 ? false : true,
      ),
      body: (_controller == null || !_controller.value.isInitialized)
          ? Container(
              color: Colors.grey,
            )
          : Column(
              children: [
                Container(
                  color: AppColor.mainBlue,
                  width: _previewSize,
                  height: _previewSize,
                  child: Stack(
                    overflow: Overflow.clip,
                    children: [
                      Positioned(
                        top: _controller.value.aspectRatio <= 1
                            ? (_previewSize - _previewSize / _controller.value.aspectRatio) / 2
                            : 0,
                        left: _controller.value.aspectRatio <= 1
                            ? 0
                            : (_previewSize - _previewSize * _controller.value.aspectRatio) / 2,
                        child: Container(
                          height: _controller.value.aspectRatio <= 1
                              ? _previewSize / _controller.value.aspectRatio
                              : _previewSize,
                          width: _controller.value.aspectRatio <= 1
                              ? _previewSize
                              : _previewSize * _controller.value.aspectRatio,
                          child: CameraPreview(_controller),
                        ),
                      ),
                      Positioned(
                        right: 16,
                        bottom: 16,
                        child: AppIconButton(
                          isCircle: true,
                          bgColor: AppColor.imageBgGrey.withOpacity(0.65),
                          buttonHeight: 32,
                          buttonWidth: 32,
                          iconSize: 24,
                          svgName: AppIcon.camera_switch,
                          onTap: () {
                            int currentTime = DateTime.now().millisecondsSinceEpoch;
                            if (currentTime - _latestSwitchCameraTime < _switchCameraInterval) {
                              //避免切换摄像头过于频繁
                              return;
                            }
                            if (_controller.value.isTakingPicture || _controller.value.isRecordingVideo) {
                              //拍照或录像过程中不能切换
                              return;
                            }
                            //FIXME 模拟器会有切到后置摄像头后第一次点击无反应的问题 要持续关注
                            print("切换摄像头！");
                            _latestSwitchCameraTime = currentTime;
                            _cameraIndex = (_cameraIndex + 1) % Application.cameras.length;
                            onCameraSelected(Application.cameras[_cameraIndex]);
                          },
                        ),
                      ),
                      // 进度条
                      Positioned(
                        bottom: 0,
                        child: Container(
                          color: AppColor.white.withOpacity(0.45),
                          height: 3,
                          width: _previewSize,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        child: Container(
                          color: AppColor.mainRed,
                          height: 3,
                          width: _previewSize *
                              (_milliDuration > maxRecordVideoDuration * 1000
                                  ? maxRecordVideoDuration * 1000
                                  : _milliDuration) /
                              (maxRecordVideoDuration * 1000),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    color: AppColor.mainBlack,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _isRecording
                                ? Container(
                                    margin: const EdgeInsets.only(right: 3),
                                    height: 5,
                                    width: 5,
                                    decoration: BoxDecoration(shape: BoxShape.circle, color: AppColor.mainRed),
                                  )
                                : Container(),
                            Text(
                              "${DateFormat("mm:ss").format(DateTime.fromMillisecondsSinceEpoch(_milliDuration))}",
                              style: TextStyle(color: AppColor.white.withOpacity(0.85), fontSize: 10),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        GestureDetector(
                          onLongPressStart: (longPressStartDetails) async {
                            print("开始录制！");
                            await startRecordVideo();
                          },
                          onLongPressEnd: (longPressEndDetails) {
                            finishRecording();
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            width: 66,
                            height: 66,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColor.white, width: 4),
                            ),
                            child: Container(
                              width: 49,
                              height: 49,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _isRecording ? AppColor.white.withOpacity(0.24) : AppColor.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    print("Camera dispose");
    if (_timer != null && _timer.isActive) {
      _timer.cancel();
    }
    _controller?.dispose()?.then((value) {
      Application.isCameraInUse = false;
    });
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller.value.isInitialized) {
      return;
    }
    //在切到后台或返回前台
    if (state == AppLifecycleState.inactive) {
      _isRecording = false;
      _milliDuration = 0;
      if (_timer != null && _timer.isActive) {
        _timer.cancel();
      }
      print("Camera dispose");
      _controller?.dispose()?.then((value) {
        Application.isCameraInUse = false;
      });
    } else if (state == AppLifecycleState.resumed) {
      if (_controller != null) {
        onCameraSelected(_controller.description);
      }
    }
  }

  void onCameraSelected(CameraDescription description) async {
    // //TODO 需完善权限处理 根据权限结果处理页面
    // Map<Permission, PermissionStatus> permissionMap = await [Permission.camera, Permission.storage].request();
    // print(permissionMap);
    if (_controller != null) {
      print("Camera dispose");
      await _controller.dispose();
      Application.isCameraInUse = false;
    }
    _controller = CameraController(description, ResolutionPreset.high, enableAudio: true);

    // If the controller is updated then update the UI.
    _controller.addListener(() {
      print("controller.value : ${_controller.value}");
      if (mounted)
        setState(() {
          //如果镜头角度是转了90度 那么尺寸要宽高互换
          if (Application.cameras[_cameraIndex].sensorOrientation == 90 ||
              Application.cameras[_cameraIndex].sensorOrientation == 270) {
            _cameraSize = Size(_controller.value.previewSize.height, _controller.value.previewSize.width);
          } else {
            _cameraSize = _controller.value.previewSize;
          }
        });
      if (_controller.value.hasError) {
        print("Camera error ${_controller.value.errorDescription}");
      }
    });

    try {
      while (Application.isCameraInUse) {
        await Future.delayed(Duration(milliseconds: 100));
      }
      await _controller.initialize();
      Application.isCameraInUse = true;
    } on CameraException catch (e) {
      print(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  //TODO 需要注意iOS可能需要在开始录制前准备录制
  Future<void> startRecordVideo() async {
    if (!_controller.value.isInitialized) {
      //没有完成相机初始化
      print("Error: camera is not initialized.");
      return null;
    }
    if (_controller.value.isRecordingVideo) {
      //正在录制中
      return null;
    }
    _filePath = "${AppConfig.getAppVideoDir()}/${DateTime.now().millisecondsSinceEpoch.toString()}.mp4";
    try {
      await _controller.startVideoRecording(_filePath);
    } on CameraException catch (e) {
      print(e);
      return null;
    }

    //更新状态
    setState(() {
      //开始计时
      _isRecording = true;
      _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
        setState(() {
          _milliDuration = timer.tick * 100;
          if (_milliDuration >= maxRecordVideoDuration * 1000) {
            timer.cancel();
            //结束录制
            finishRecording();
          }
        });
      });
    });
  }

  Future<void> stopRecordVideo() async {
    if (!_controller.value.isRecordingVideo) {
      //没有在录制中
      return null;
    }
    try {
      await _controller.stopVideoRecording();
    } on CameraException catch (e) {
      print(e);
      return null;
    }
    //更新状态
    setState(() {
      //结束计时
      _isRecording = false;
      _timer.cancel();
    });
  }

  Future<void> finishRecording() async {
    print("结束录制！");
    await stopRecordVideo();
    //检查时长 满足条件则跳转预览页
    if (_milliDuration > minRecordVideoDuration * 1000) {
      //设置尺寸信息
      SizeInfo sizeInfo = SizeInfo();
      sizeInfo.width = _cameraSize.width.toInt();
      sizeInfo.height = _cameraSize.height.toInt();
      sizeInfo.duration = _milliDuration ~/ 1000;
      sizeInfo.videoCroppedRatio = 1.0;
      sizeInfo.createTime = File(_filePath).lastModifiedSync().millisecondsSinceEpoch;
      if (sizeInfo.width > sizeInfo.height) {
        sizeInfo.offsetRatioX = (sizeInfo.height - sizeInfo.width) / 2 / sizeInfo.width;
      } else if (sizeInfo.width < sizeInfo.height) {
        sizeInfo.offsetRatioY = (sizeInfo.width - sizeInfo.height) / 2 / sizeInfo.height;
      }
      AppRouter.navigateToPreviewVideoPage(
        context,
        _filePath,
        sizeInfo,
        (result) {
          if (result != null) {
            if (widget.publishMode == 1) {
              Navigator.pop(context, result);
              AppRouter.navigateToReleasePage(context, topicId: widget.topicId);
            } else if (widget.publishMode == 2) {
              AppRouter.navigateToReleasePage(context, topicId: widget.topicId);
              if (Application.ifPageController != null) {
                Application.ifPageController.index = Application.ifPageController.length - 1;
              }
              //FIXME 需要关了摄像头
            } else {
              Navigator.pop(context, result);
            }
          }
        },
      );
    } else {
      print("时长不够！");
    }
    _milliDuration = 0;
    _filePath = null;
  }
}
