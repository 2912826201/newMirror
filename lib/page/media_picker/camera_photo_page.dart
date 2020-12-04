import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:permission_handler/permission_handler.dart';

/// camera_photo_page
/// Created by yangjiayi on 2020/12/1.

//相机拍照页
class CameraPhotoPage extends StatefulWidget {
  @override
  CameraPhotoState createState() => CameraPhotoState();
}

class CameraPhotoState extends State<CameraPhotoPage> with WidgetsBindingObserver {
  CameraController _controller;

  double _previewSize = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    print("Camera: ${Application.cameras}");
    if (Application.cameras.isNotEmpty) {
      onCameraSelected(Application.cameras[0]);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 获取屏幕宽以设置各布局大小
    _previewSize = ScreenUtil.instance.screenWidthDp;
    print("预览区域大小：$_previewSize");
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.bgBlack,
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
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: CameraPreview(_controller),
                  ),
                ),
                Expanded(
                    child: Container(
                  alignment: Alignment.center,
                  color: AppColor.bgBlack,
                  child: Container(
                    width: 64,
                    height: 64,
                    color: AppColor.white,
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
    _controller?.dispose();
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
      _controller?.dispose();
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
    }
    _controller = CameraController(description, ResolutionPreset.medium);

    // If the controller is updated then update the UI.
    _controller.addListener(() {
      if (mounted) setState(() {});
      if (_controller.value.hasError) {
        print("Camera error ${_controller.value.errorDescription}");
      }
    });

    try {
      await _controller.initialize();
    } on CameraException catch (e) {
      print(e);
    }

    if (mounted) {
      setState(() {});
    }
  }
}
