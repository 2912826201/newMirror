import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/data/model/media_file_model.dart';
import 'package:mirror/data/model/upload/upload_result_model.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/util/screen_util.dart';

import 'media_picker/media_picker_page.dart';

/// media_test_page
/// Created by yangjiayi on 2020/11/21.

class MediaTestPage extends StatefulWidget {
  @override
  _MediaTestState createState() => _MediaTestState();
}

class _MediaTestState extends State<MediaTestPage> {
  double _process = 0.0;
  double _screenWidth;
  String type;
  List<MediaFileModel> list = [];

  @override
  Widget build(BuildContext context) {
    _screenWidth = ScreenUtil.instance.screenWidthDp;
    return Scaffold(
      appBar: AppBar(
        title: Text("视频图片测试页"),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image(
                image: AssetImage("images/test.png"),
                color: Colors.redAccent,
                colorBlendMode: BlendMode.darken,
                width: 100.0,
                height: 100.0,
              ),
              Image(
                image: NetworkImage("http://i2.hdslb.com/bfs/face/c2d82a7e6512a85657e997dc8f84ab538e87a8cc.jpg"),
                width: 100.0,
                height: 100.0,
              ),
            ],
          ),
          RaisedButton(
            onPressed: () {
              AppRouter.navigateToMediaPickerPage(context, 9, typeImageAndVideo, false, startPageGallery, false, false,
                  (result) async {
                SelectedMediaFiles files = Application.selectedMediaFiles;
                if (true != result || files == null) {
                  print("没有选择媒体文件");
                  return;
                }
                Application.selectedMediaFiles = null;
                print(files.type + ":" + files.list.toString());
                type = files.type;
                list = files.list;
                for (MediaFileModel model in list) {
                  if (model.croppedImage != null) {
                    print("开始获取ByteData" + DateTime.now().millisecondsSinceEpoch.toString());
                    ByteData byteData = await model.croppedImage.toByteData(format: ui.ImageByteFormat.png);
                    print("已获取到ByteData" + DateTime.now().millisecondsSinceEpoch.toString());
                    Uint8List picBytes = byteData.buffer.asUint8List();
                    print("已获取到Uint8List" + DateTime.now().millisecondsSinceEpoch.toString());
                    model.croppedImageData = picBytes;
                  }
                }
                setState(() {});
              });
            },
            child: Text("图片视频（不裁）"),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RaisedButton(
                onPressed: () {
                  AppRouter.navigateToMediaPickerPage(
                      context, 9, typeImageAndVideo, true, startPageGallery, false, false, (result) async {
                    SelectedMediaFiles files = Application.selectedMediaFiles;
                    if (true != result || files == null) {
                      print("没有选择媒体文件");
                      return;
                    }
                    Application.selectedMediaFiles = null;
                    print(files.type + ":" + files.list.toString());
                    type = files.type;
                    list = files.list;
                    for (MediaFileModel model in list) {
                      if (model.croppedImage != null) {
                        print("开始获取ByteData" + DateTime.now().millisecondsSinceEpoch.toString());
                        ByteData byteData = await model.croppedImage.toByteData(format: ui.ImageByteFormat.png);
                        print("已获取到ByteData" + DateTime.now().millisecondsSinceEpoch.toString());
                        Uint8List picBytes = byteData.buffer.asUint8List();
                        print("已获取到Uint8List" + DateTime.now().millisecondsSinceEpoch.toString());
                        model.croppedImageData = picBytes;
                      }
                    }
                    setState(() {});
                  });
                },
                child: Text("图片视频（裁剪）0"),
              ),
              RaisedButton(
                onPressed: () {
                  AppRouter.navigateToMediaPickerPage(context, 9, typeImageAndVideo, true, startPagePhoto, false, false,
                      (result) async {
                    SelectedMediaFiles files = Application.selectedMediaFiles;
                    if (true != result || files == null) {
                      print("没有选择媒体文件");
                      return;
                    }
                    Application.selectedMediaFiles = null;
                    print(files.type + ":" + files.list.toString());
                    type = files.type;
                    list = files.list;
                    for (MediaFileModel model in list) {
                      if (model.croppedImage != null) {
                        print("开始获取ByteData" + DateTime.now().millisecondsSinceEpoch.toString());
                        ByteData byteData = await model.croppedImage.toByteData(format: ui.ImageByteFormat.png);
                        print("已获取到ByteData" + DateTime.now().millisecondsSinceEpoch.toString());
                        Uint8List picBytes = byteData.buffer.asUint8List();
                        print("已获取到Uint8List" + DateTime.now().millisecondsSinceEpoch.toString());
                        model.croppedImageData = picBytes;
                      }
                    }
                    setState(() {});
                  });
                },
                child: Text("图片视频（裁剪）1"),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RaisedButton(
                onPressed: () {
                  AppRouter.navigateToMediaPickerPage(
                      context, 9, typeImageAndVideo, true, startPageGallery, false, true, (result) {});
                },
                child: Text("裁剪后去发布0"),
              ),
              RaisedButton(
                onPressed: () {
                  AppRouter.navigateToMediaPickerPage(
                      context, 9, typeImageAndVideo, true, startPagePhoto, false, true, (result) {});
                },
                child: Text("裁剪后去发布1"),
              ),
            ],
          ),
          LinearProgressIndicator(
            value: _process,
          ),
          RaisedButton(child: Text("上传"), onPressed: list.length > 0 ? _onUpload : null),
          Expanded(
              child: GridView.builder(
                  itemCount: list.length, gridDelegate: _galleryGridDelegate(), itemBuilder: _buildGridItem)),
        ],
      ),
    );
  }

  _onUpload() async {
    List<File> fileList = [];
    UploadResults results;
    if (type == mediaTypeKeyImage) {
      String timeStr = DateTime.now().millisecondsSinceEpoch.toString();
      int i = 0;
      list.forEach((element) async {
        if (element.croppedImageData == null) {
          fileList.add(element.file);
        } else {
          i++;
          File imageFile = await FileUtil().writeImageDataToFile(element.croppedImageData, timeStr + i.toString());
          fileList.add(imageFile);
        }
      });
      results = await FileUtil().uploadPics(fileList, (path, percent, index) {
        setState(() {
          _process = percent;
        });
        print("$index," + path + ":$percent");
      });
    } else if (type == mediaTypeKeyVideo) {
      list.forEach((element) {
        fileList.add(element.file);
      });
      results = await FileUtil().uploadMedias(fileList, (path, percent, index) {
        setState(() {
          _process = percent;
        });
        print("$index," + path + ":$percent");
      });
    }
    print(results.isSuccess);
    for (int i = 0; i < results.resultMap.length; i++) {
      UploadResultModel model = results.resultMap.values.elementAt(i);
      print("第${i + 1}个上传文件");
      print(model.isSuccess);
      print(model.error);
      print(model.filePath);
      print(model.url);
    }
  }

  Widget _buildGridItem(BuildContext context, int index) {
    MediaFileModel model = list[index];
    return Builder(builder: (context) {
      return type == mediaTypeKeyVideo
          ? Image.memory(
              model.thumb,
              fit: BoxFit.cover,
            )
          : model.croppedImageData == null
              ? Image.file(
                  model.file,
                  fit: BoxFit.cover,
                )
              : Image.memory(
                  model.croppedImageData,
                  fit: BoxFit.cover,
                );
    });
  }
}

SliverGridDelegateWithFixedCrossAxisCount _galleryGridDelegate() {
  return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3, childAspectRatio: 1, mainAxisSpacing: 0, crossAxisSpacing: 0);
}
