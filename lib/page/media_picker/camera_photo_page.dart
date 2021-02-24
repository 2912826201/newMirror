import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/config/config.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:permission_handler/permission_handler.dart';

/// camera_photo_page
/// Created by yangjiayi on 2020/12/1.

//相机拍照页
class CameraPhotoPage extends StatefulWidget {
  CameraPhotoPage({Key key, this.publishMode = 0, this.fixedWidth, this.fixedHeight}) : super(key: key);

  final int publishMode;
  final int fixedWidth;
  final int fixedHeight;

  @override
  CameraPhotoState createState() => CameraPhotoState();
}

class CameraPhotoState extends State<CameraPhotoPage> with WidgetsBindingObserver {
  //切换摄像头的时间间隔 1000ms
  final int _switchCameraInterval = 1000;
  int _latestSwitchCameraTime = 0;

  CameraController _controller;

  double _previewSize = 0;

  int _cameraIndex = 0;

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
        backgroundColor: AppColor.black,
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
                            )),
                        Positioned(
                            right: 16,
                            bottom: 16,
                            child: GestureDetector(
                              onTap: () {
                                int currentTime = DateTime.now().millisecondsSinceEpoch;
                                if (currentTime - _latestSwitchCameraTime < _switchCameraInterval) {
                                  //避免切换摄像头过于频繁
                                  return;
                                }
                                _latestSwitchCameraTime = currentTime;
                                //FIXME 模拟器会有切到后置摄像头后第一次点击无反应的问题 要持续关注
                                print("切换摄像头！");
                                _cameraIndex = (_cameraIndex + 1) % Application.cameras.length;
                                onCameraSelected(Application.cameras[_cameraIndex]);
                              },
                              child: Icon(
                                Icons.camera,
                                size: 32,
                                color: Colors.white,
                              ),
                            )),
                      ],
                    )),
                Expanded(
                    child: Container(
                  alignment: Alignment.center,
                  color: AppColor.bgBlack,
                  child: GestureDetector(
                    onTap: () async {
                      print("拍照！");
                      String filePath = await takePhoto();
                      print("保存照片：$filePath");
                      if (filePath != null) {
                        AppRouter.navigateToPreviewPhotoPage(context, filePath, (result) {
                          if (result != null) {
                            if (widget.publishMode == 1) {
                              Navigator.pop(context, result);
                              AppRouter.navigateToReleasePage(context);
                            } else if (widget.publishMode == 2) {
                              AppRouter.navigateToReleasePage(context);
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
                  ),
                ))
              ],
            ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    print("Camera dispose");
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
    _controller = CameraController(description, ResolutionPreset.high, enableAudio: false);

    // If the controller is updated then update the UI.
    _controller.addListener(() {
      print("controller.value : ${_controller.value}");
      if (mounted) setState(() {});
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
}
