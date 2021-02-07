import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/media_file_model.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/custom_button.dart';
import 'package:mirror/widget/image_cropper.dart';

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
  var _cropperKey = GlobalKey<_PreviewPhotoState>();
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
          backgroundColor: AppColor.bgBlack,
          brightness: Brightness.dark,
          actions: [
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.only(right: CustomAppBar.appBarIconPadding),
              child: CustomRedButton(
                "下一步",
                CustomRedButton.buttonStateNormal,
                () async {
                  MediaFileModel model = MediaFileModel();
                  model.croppedImage = await _getImage();
                  model.type = mediaTypeKeyImage;

                  model.sizeInfo.width = widget.fixedWidth == null ? baseOutSize.toInt() : widget.fixedWidth;
                  model.sizeInfo.height = widget.fixedHeight == null ? baseOutSize.toInt() : widget.fixedHeight;
                  model.sizeInfo.createTime = DateTime.now().millisecondsSinceEpoch;

                  SelectedMediaFiles files = SelectedMediaFiles();
                  files.type = mediaTypeKeyImage;
                  files.list = [model];

                  Application.selectedMediaFiles = files;

                  Navigator.pop(context, true);
                },
                isDarkBackground: true,
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
                outWidth: widget.fixedWidth == null ? baseOutSize : widget.fixedWidth.toDouble(),
                outHeight: widget.fixedHeight == null ? baseOutSize : widget.fixedHeight.toDouble(),
                key: _cropperKey,
              ),
            ),
            Expanded(
                child: Container(
              alignment: Alignment.center,
              color: AppColor.bgBlack,
            ))
          ],
        ));
  }

  Future<ui.Image> _getImage() async {
    print("开始获取" + DateTime.now().millisecondsSinceEpoch.toString());

    ui.Image image = await (_cropperKey.currentContext as CropperImageElement).outImage();

    print("已获取到ui.Image" + DateTime.now().millisecondsSinceEpoch.toString());
    print(image);
    // ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    // print("已获取到ByteData" + DateTime.now().millisecondsSinceEpoch.toString());
    // Uint8List picBytes = byteData.buffer.asUint8List();
    // print("已获取到Uint8List" + DateTime.now().millisecondsSinceEpoch.toString());
    return image;
  }
}
