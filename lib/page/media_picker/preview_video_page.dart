import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mirror/config/runtime_properties.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/media_file_model.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/custom_button.dart';
import 'package:mirror/widget/dialog.dart';
import 'package:mirror/widget/feed_video_player.dart';
import 'package:mirror/widget/icon.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

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
    // genThumbnail(ThumbnailRequest(video: widget.filePath, quality: 100)).then((result){
    //   print("width: ${result.width}, height: ${result.height}");
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(
          backgroundColor: AppColor.mainBlack,
          brightness: Brightness.dark,
          leading: CustomAppBarIconButton(
            svgName: AppIcon.nav_close,
            iconColor: AppColor.white,
            onTap: () {
              showAppDialog(context,
                  title: "放弃视频?",
                  info: "如果现在关闭相机,你的视频将被删除",
                  barrierDismissible:false,
                  cancel: AppDialogButton("放弃", () {
                    print("点了放弃");
                    Navigator.pop(context);
                    return true;
                  }),
                  confirm: AppDialogButton("保留", () {
                    print("点击了保留");
                    return true;
                  }));
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
                  model.type = mediaTypeKeyVideo;
                  model.file = _file;
                  model.sizeInfo = widget.sizeInfo;
                  model.thumb = await VideoThumbnail.thumbnailData(
                      video: widget.filePath, imageFormat: ImageFormat.JPEG, quality: 100);

                  SelectedMediaFiles files = SelectedMediaFiles();
                  files.type = mediaTypeKeyVideo;
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
              child: FeedVideoPlayer(
                widget.filePath,
                widget.sizeInfo,
                _previewSize,
                isFile: true,
              ),
            ),
            Expanded(
                child: Container(
              alignment: Alignment.center,
              color: AppColor.mainBlack,
            ))
          ],
        ));
  }
}

class ThumbnailRequest {
  final String video;
  final int maxHeight;
  final int maxWidth;
  final int timeMs;
  final int quality;

  const ThumbnailRequest({this.video, this.maxHeight, this.maxWidth, this.timeMs, this.quality});
}

class ThumbnailResult {
  final Image image;
  final int dataSize;
  final int height;
  final int width;

  const ThumbnailResult({this.image, this.dataSize, this.height, this.width});
}

Future<ThumbnailResult> genThumbnail(ThumbnailRequest r) async {
  final Completer<ThumbnailResult> completer = Completer();
  Uint8List bytes = await VideoThumbnail.thumbnailData(
      video: r.video,
      imageFormat: ImageFormat.JPEG,
      maxHeight: r.maxHeight,
      maxWidth: r.maxWidth,
      timeMs: r.timeMs,
      quality: r.quality);

  int _imageDataSize = bytes.length;
  print("image size: $_imageDataSize");

  final _image = Image.memory(bytes);
  _image.image.resolve(ImageConfiguration()).addListener(ImageStreamListener((ImageInfo info, bool _) {
    completer.complete(ThumbnailResult(
      image: _image,
      dataSize: _imageDataSize,
      height: info.image.height,
      width: info.image.width,
    ));
  }));
  return completer.future;
}
