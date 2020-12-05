import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
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

  double _previewSize = 0;

  @override
  void initState() {
    super.initState();
    // 获取屏幕宽以设置各布局大小
    _previewSize = ScreenUtil.instance.screenWidthDp;
    print("预览区域大小：$_previewSize");
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
                onTap: () {},
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
                FileImage(File(widget.filePath)),
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
}
