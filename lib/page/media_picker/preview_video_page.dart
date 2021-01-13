import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/media_file_model.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/feed_video_player.dart';
import 'package:mirror/widget/image_cropper.dart';

/// preview_video_page
/// Created by yangjiayi on 2021/1/13.

class PreviewVideoPage extends StatefulWidget {
  const PreviewVideoPage({Key key, this.filePath, this.sizeInfo}) : super(key: key);

  final String filePath;
  final SizeInfo sizeInfo;

  @override
  _PreviewVideoState createState() => _PreviewVideoState();
}

class _PreviewVideoState extends State<PreviewVideoPage> {
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
                  // model.croppedImage = await _getImage();
                  model.type = mediaTypeKeyVideo;

                  SelectedMediaFiles files = SelectedMediaFiles();
                  files.type = mediaTypeKeyVideo;
                  files.list = [model];

                  Application.selectedMediaFiles = files;

                  Navigator.pop(context, true);
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
              child: FeedVideoPlayer(widget.filePath, widget.sizeInfo, _previewSize, isfile: true,),
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
