import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/media_file_model.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/image_cropper.dart';

/// preview_photo_page
/// Created by yangjiayi on 2020/12/4.

class PreviewPhotoPage extends StatefulWidget {
  const PreviewPhotoPage({Key key, this.filePath}) : super(key: key);

  final filePath;

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
        appBar: AppBar(
          backgroundColor: AppColor.bgBlack,
          title: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Spacer(),
              GestureDetector(
                onTap: () async {
                  MediaFileModel model = MediaFileModel();
                  model.croppedImage = await _getImage();

                  SelectedMediaFiles files = SelectedMediaFiles();
                  files.type = mediaTypeKeyImage;
                  files.list = [model];
                  Navigator.pop(context, files);
                },
                child: Container(
                  alignment: Alignment.center,
                  height: 28,
                  width: 60,
                  decoration: BoxDecoration(color: AppColor.mainRed, borderRadius: BorderRadius.circular(14)),
                  child: Text("下一步", style: TextStyle(color: AppColor.white, fontSize: 14)),
                ),
              )
            ],
          ),
        ),
        body: Column(
          children: [
            Container(
              color: AppColor.mainBlue,
              width: _previewSize,
              height: _previewSize,
              child: CropperImage(//需要处理成不能操作
                FileImage(_file),
                round: 0,
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
