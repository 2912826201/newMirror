import 'dart:async';
import 'dart:io';

import 'package:app_settings/app_settings.dart';
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

/// camera_record_page
/// Created by yangjiayi on 2021/3/17.

//相机拍照录视频二合一页
class CameraRecordPage extends StatefulWidget {
  CameraRecordPage({Key key, this.publishMode = 0, this.fixedWidth, this.fixedHeight, this.topicId, this.startMode = 0})
      : super(key: key);

  final int publishMode;
  final int fixedWidth;
  final int fixedHeight;
  final int topicId;

  final int startMode; //0-拍照 1-录视频

  _CameraRecordState _state;

  @override
  _CameraRecordState createState() {
    _state = _CameraRecordState();
    return _state;
  }

  bool switchMode(int mode) {
    return _state._switchMode(mode);
  }
}

class _CameraRecordState extends State<CameraRecordPage> with WidgetsBindingObserver {
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

  int _currentMode; //0-拍照 1-录视频

  bool _permissionCameraGranted;
  bool _permissionMicrophoneGranted;

  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _currentMode = widget.startMode;
    // 获取屏幕宽以设置各布局大小
    _previewSize = ScreenUtil.instance.screenWidthDp;
    print("预览区域大小：$_previewSize");

    WidgetsBinding.instance.addObserver(this);

    _checkPermission();
  }

  _checkPermission() async {
    bool isCameraGranted;
    bool isMicrophoneGranted;

    isCameraGranted = (await Permission.camera.status)?.isGranted;
    isMicrophoneGranted = (await Permission.microphone.status)?.isGranted;

    if (isCameraGranted == null) {
      isCameraGranted = false;
    }
    if (isMicrophoneGranted == null) {
      isMicrophoneGranted = false;
    }

    //和相册页不一样 哪怕权限一样但摄像头状态可能不一样 所以直接根据权限执行后续操作 不做同权限直接跳过的操作逻辑
    _permissionCameraGranted = isCameraGranted;
    _permissionMicrophoneGranted = isMicrophoneGranted;
    if (checkFullPermissions()) {
      //有全部权限 开启摄像头
      print("Camera: ${Application.cameras}");
      if (Application.cameras.isNotEmpty) {
        onCameraSelected(Application.cameras[_cameraIndex]);
      }
    } else {
      //无全部权限 刷新界面
      if (mounted) {
        setState(() {});
      }
    }
  }

  bool checkFullPermissions() {
    if (_currentMode == 0) {
      return _permissionCameraGranted != null && _permissionCameraGranted;
    } else {
      return (_permissionCameraGranted != null && _permissionCameraGranted) &&
          (_permissionMicrophoneGranted != null && _permissionMicrophoneGranted);
    }
  }

  @override
  Widget build(BuildContext context) {
    return checkFullPermissions()
        ? Scaffold(
            appBar: CustomAppBar(
              backgroundColor: AppColor.black,
              brightness: Brightness.dark,
              hasLeading: widget.publishMode == 2 ? false : true,
              leading: CustomAppBarIconButton(
                svgName: AppIcon.nav_close,
                iconColor: AppColor.white,
                onTap: () {
                  Navigator.pop(context);
                },
              ),
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
                                )),
                            Positioned(
                              right: 16,
                              bottom: 16,
                              child: AppIconButton(
                                isCircle: true,
                                bgColor: AppColor.textPrimary2.withOpacity(0.65),
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
                            _currentMode == 1
                                ? Positioned(
                                    bottom: 0,
                                    child: Container(
                                      color: AppColor.white.withOpacity(0.45),
                                      height: 3,
                                      width: _previewSize,
                                    ),
                                  )
                                : Container(),
                            _currentMode == 1
                                ? Positioned(
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
                                  )
                                : Container(),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(
                          alignment: Alignment.center,
                          color: AppColor.black,
                          child: _currentMode == 0
                              ? GestureDetector(
                                  onTap: () async {
                                    print("拍照！");
                                    String filePath = await takePhoto();
                                    print("保存照片：$filePath");
                                    if (filePath != null) {
                                      AppRouter.navigateToPreviewPhotoPage(context, filePath, (result) {
                                        if (result != null) {
                                          if (widget.publishMode == 1) {
                                            Navigator.pop(context, result);
                                            AppRouter.navigateToReleasePage(context, topicId: widget.topicId);
                                          } else if (widget.publishMode == 2) {
                                            AppRouter.navigateToReleasePage(context, topicId: widget.topicId);
                                            if (Application.ifPageController != null) {
                                              Application.ifPageController.index =
                                                  Application.ifPageController.length - 1;
                                            }
                                            //FIXME 需要关了摄像头
                                          } else {
                                            Navigator.pop(context, result);
                                          }
                                        }
                                      }, fixedWidth: widget.fixedWidth, fixedHeight: widget.fixedHeight);
                                    }
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
                                        color: AppColor.white,
                                      ),
                                    ),
                                  ),
                                )
                              : Column(
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
                                                decoration:
                                                    BoxDecoration(shape: BoxShape.circle, color: AppColor.mainRed),
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
                                    SizedBox(
                                      height: 12,
                                    ),
                                    // 占个高度保证按钮居中
                                    Text(
                                      " ",
                                      style: TextStyle(color: AppColor.white.withOpacity(0.85), fontSize: 10),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
          )
        : Scaffold(
            // 无权限时的布局
            backgroundColor: AppColor.bgBlack,
            appBar: CustomAppBar(
              backgroundColor: AppColor.black,
              brightness: Brightness.dark,
              hasLeading: widget.publishMode == 2 ? false : true,
              leading: CustomAppBarIconButton(
                svgName: AppIcon.nav_close,
                iconColor: AppColor.white,
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ),
            body: Container(
              width: ScreenUtil.instance.screenWidthDp,
              child: _permissionCameraGranted == null || (_currentMode == 1 && _permissionMicrophoneGranted == null)
                  ? Container()
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "打开权限才可以拍摄",
                          style: TextStyle(color: AppColor.white.withOpacity(0.85), fontSize: 18),
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        GestureDetector(
                          onTap: () async {
                            //和相册页不一样的是 相册页在进入前会请求一次权限 所以一定会有结果 而相机和麦克风可能从未请求过权限
                            if (!_permissionCameraGranted) {
                              PermissionStatus status = await Permission.camera.status;

                              if (status.isGranted) {
                                _permissionCameraGranted = true;
                                if (checkFullPermissions()) {
                                  print("Camera: ${Application.cameras}");
                                  if (Application.cameras.isNotEmpty) {
                                    onCameraSelected(Application.cameras[_cameraIndex]);
                                  }
                                }
                              } else if (status.isPermanentlyDenied) {
                                //安卓的禁止且之后不提示
                                AppSettings.openAppSettings();
                              } else {
                                //安卓或者从未请求过权限则重新请求 iOS跳设置页
                                if (Application.platform == 0 || status.isUndetermined) {
                                  status = await Permission.camera.request();
                                  if (status.isGranted) {
                                    _permissionCameraGranted = true;
                                    if (checkFullPermissions()) {
                                      print("Camera: ${Application.cameras}");
                                      if (Application.cameras.isNotEmpty) {
                                        onCameraSelected(Application.cameras[_cameraIndex]);
                                      }
                                    }
                                  }
                                } else {
                                  AppSettings.openAppSettings();
                                }
                              }
                            }
                          },
                          child: Text(
                            _permissionCameraGranted ? "相机访问权限已启用" : "启用相机访问权限",
                            style: TextStyle(
                                color: _permissionCameraGranted
                                    ? AppColor.white.withOpacity(0.35)
                                    : AppColor.mainRed.withOpacity(0.85),
                                fontSize: 14),
                          ),
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        _currentMode == 0
                            ? Container()
                            : GestureDetector(
                                onTap: () async {
                                  if (!_permissionMicrophoneGranted) {
                                    //和相册页不一样的是 相册页在进入前会请求一次权限 所以一定会有结果 而相机和麦克风可能从未请求过权限
                                    PermissionStatus status = await Permission.microphone.status;

                                    if (status.isGranted) {
                                      _permissionMicrophoneGranted = true;
                                      if (checkFullPermissions()) {
                                        print("Camera: ${Application.cameras}");
                                        if (Application.cameras.isNotEmpty) {
                                          onCameraSelected(Application.cameras[_cameraIndex]);
                                        }
                                      }
                                    } else if (status.isPermanentlyDenied) {
                                      //安卓的禁止且之后不提示
                                      AppSettings.openAppSettings();
                                    } else {
                                      //安卓或者从未请求过权限则重新请求 iOS跳设置页
                                      if (Application.platform == 0 || status.isUndetermined) {
                                        status = await Permission.microphone.request();
                                        if (status.isGranted) {
                                          _permissionMicrophoneGranted = true;
                                          if (checkFullPermissions()) {
                                            print("Camera: ${Application.cameras}");
                                            if (Application.cameras.isNotEmpty) {
                                              onCameraSelected(Application.cameras[_cameraIndex]);
                                            }
                                          }
                                        }
                                      } else {
                                        AppSettings.openAppSettings();
                                      }
                                    }
                                  }
                                },
                                child: Text(
                                  _permissionMicrophoneGranted ? "麦克风访问权限已启用" : "启用麦克风访问权限",
                                  style: TextStyle(
                                      color: _permissionMicrophoneGranted
                                          ? AppColor.white.withOpacity(0.35)
                                          : AppColor.mainRed.withOpacity(0.85),
                                      fontSize: 14),
                                ),
                              ),
                      ],
                    ),
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
    // 返回前台 检查权限
    // 只有paused才是真的离开了页面 会在弹窗弹出时进入inactived

    //在切到后台或返回前台
    if (state == AppLifecycleState.paused) {
      // 切到后台 如果摄像头已初始化则释放重置各属性
      _isPaused = true;
      if (_controller == null || !_controller.value.isInitialized) {
        return;
      }
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
      if (_isPaused) {
        _isPaused = false;
        _checkPermission();
      }
    }
  }

  // 安卓上即使不录视频 enableAudio设为true初始化CameraController就会请求录音权限（iOS仅在录视频时请求录音权限）
  // 所以不能统一进行初始化 要区分场景和条件 在所有权限都已授权时再将enableAudio设为true避免模式切换时重新初始化摄像头
  // 比较麻烦的是给了摄像头权限但没给录音权限时，拍照页可以运行，录像页不可以，当录像页给了权限后需要刷新页面重新初始化
  void onCameraSelected(CameraDescription description) async {
    // //TODO 需完善权限处理 根据权限结果处理页面
    // Map<Permission, PermissionStatus> permissionMap = await [Permission.camera, Permission.storage].request();
    // print(permissionMap);
    if (_controller != null) {
      print("Camera dispose");
      await _controller.dispose();
      Application.isCameraInUse = false;
    }

    //当模式为拍照但没有给到录音权限时 要初始化为不开声音的模式
    if (_currentMode == 0 && (_permissionMicrophoneGranted == null || _permissionMicrophoneGranted == false)) {
      _controller = CameraController(description, ResolutionPreset.high, enableAudio: false);
    } else {
      _controller = CameraController(description, ResolutionPreset.high, enableAudio: true);
    }

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

  Future<String> takePhoto() async {
    if (!_controller.value.isInitialized) {
      //没有完成相机初始化
      print("Error: camera is not initialized.");
      return null;
    }
    if (_controller.value.isTakingPicture) {
      //正在拍照中
      return null;
    }
    final String filePath = "${AppConfig.getAppPicDir()}/${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";
    try {
      await _controller.takePicture(filePath);
    } on CameraException catch (e) {
      print(e);
      return null;
    }
    return filePath;
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

  bool _switchMode(int mode) {
    if (_isRecording) {
      return false;
    }
    if (mode == _currentMode) {
      return true;
    } else {
      if (mounted) {
        setState(() {
          _currentMode = mode;
        });
        //当切到拍照页 权限都满足 但摄像头未初始化 则初始化摄像头
        if (_currentMode == 0 && checkFullPermissions() && (_controller == null || !_controller.value.isInitialized)) {
          print("Camera: ${Application.cameras}");
          if (Application.cameras.isNotEmpty) {
            onCameraSelected(Application.cameras[_cameraIndex]);
          }
        }
      }
      return true;
    }
  }
}
