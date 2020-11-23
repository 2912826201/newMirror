import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:photo_manager/photo_manager.dart';

/// media_file_model
/// Created by yangjiayi on 2020/11/21.

const mediaTypeKeyImage = "image";
const mediaTypeKeyVideo = "video";
//TODO 选的图片视频等信息 根据开发进度不断完善
class MediaFileModel {
  File file;
  Image croppedImage;
  Uint8List thumb;
  Uint8List croppedImageData;
}

class SelectedMediaFiles {
  String type;
  List<MediaFileModel> list;
}