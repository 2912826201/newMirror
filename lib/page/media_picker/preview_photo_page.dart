import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:mirror/config/runtime_properties.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/constants.dart';
import 'package:mirror/data/model/media_file_model.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/custom_button.dart';
import 'package:mirror/widget/icon.dart';
import 'package:mirror/widget/image_cropper/image_cropper.dart';

/// preview_photo_page
/// Created by yangjiayi on 2020/12/4.

class PreviewPhotoPage extends StatefulWidget {
  const PreviewPhotoPage({Key key, this.filePath, this.fixedWidth, this.fixedHeight}) : super(key: key);

  final String filePath;
  final int fixedWidth;
  final int fixedHeight;

  @override
  _PreviewPhotoState createState() => _PreviewPhotoState();
}

class _PreviewPhotoState extends State<PreviewPhotoPage> {
  var _cropperController = CropperController();
  File _file;

  double _previewSize = 0;

  @override
  void initState() {
    super.initState();
    // 获取屏幕宽以设置各布局大小
    _previewSize = ScreenUtil.instance.screenWidthDp;
    print("预览区域大小：$_previewSize");
    _file = File(widget.filePath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(
          backgroundColor: AppColor.black,
          brightness: Brightness.dark,
          leading: CustomAppBarIconButton(
            svgName: AppIcon.nav_close,
            iconColor: AppColor.white,
            onTap: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            Container(
              padding: const EdgeInsets.only(right: CustomAppBar.appBarIconPadding - CustomAppBar.appBarHorizontalPadding),
              child: CustomYellowButton(
                "继续",
                CustomYellowButton.buttonStateNormal,
                () async {
                  MediaFileModel model = MediaFileModel();
                  model.croppedImage = await _getImage();
                  model.type = mediaTypeKeyImage;

                  model.sizeInfo.width = widget.fixedWidth == null ? cropImageSize.toInt() : widget.fixedWidth;
                  model.sizeInfo.height = widget.fixedHeight == null ? cropImageSize.toInt() : widget.fixedHeight;
                  model.sizeInfo.createTime = DateTime.now().millisecondsSinceEpoch;

                  SelectedMediaFiles files = SelectedMediaFiles();
                  files.type = mediaTypeKeyImage;
                  files.list = [model];

                  RuntimeProperties.selectedMediaFiles = files;

                  Navigator.pop(context, true);
                },
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Container(
              color: AppColor.mainBlue,
              width: _previewSize,
              height: _previewSize,
              child: CropperImage(
                //需要处理成不能操作
                FileImage(_file),
                round: 0,
                maskPadding: 0,
                outWidth: widget.fixedWidth == null ? cropImageSize : widget.fixedWidth.toDouble(),
                outHeight: widget.fixedHeight == null ? cropImageSize : widget.fixedHeight.toDouble(),
                controller: _cropperController,
                backBoxColor0: AppColor.transparent,
                backBoxColor1: AppColor.transparent,
              ),
            ),
            Expanded(
                child: Container(
              alignment: Alignment.center,
              color: AppColor.black,
            ))
          ],
        ));
  }

  Future<ui.Image> _getImage() async {
    print("开始获取" + DateTime.now().millisecondsSinceEpoch.toString());

    ui.Image image = await _cropperController.outImage();

    print("2已获取到ui.Image" + DateTime.now().millisecondsSinceEpoch.toString());
    print(image);
    // ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    // print("已获取到ByteData" + DateTime.now().millisecondsSinceEpoch.toString());
    // Uint8List picBytes = byteData.buffer.asUint8List();
    // print("已获取到Uint8List" + DateTime.now().millisecondsSinceEpoch.toString());
    return image;
  }
}
