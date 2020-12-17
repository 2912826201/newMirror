import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:photo_manager/photo_manager.dart';

/// media_file_model
/// Created by yangjiayi on 2020/11/21.

const mediaTypeKeyImage = "image";
const mediaTypeKeyVideo = "video";
//选的图片视频等信息 根据开发进度不断完善
class MediaFileModel {
  File file;
  Image croppedImage;
  Uint8List thumb;
  Uint8List croppedImageData;

  SizeInfo sizeInfo = SizeInfo();
}

class SelectedMediaFiles {
  String type;
  List<MediaFileModel> list;
}

class SizeInfo {
  int height = 0;
  int width = 0;
  double offsetRatioX = 0.0;
  double offsetRatioY = 0.0;
  int duration = 0; //时长，只有音视频有用，图片此值为0，单位秒
}