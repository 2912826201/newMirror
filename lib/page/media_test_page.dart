import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:mirror/data/model/media_file_model.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/screen_util.dart';

import 'media_picker/media_picker_page.dart';

/// media_test_page
/// Created by yangjiayi on 2020/11/21.

class MediaTestPage extends StatefulWidget {
  @override
  MediaTestState createState() => MediaTestState();
}

class MediaTestState extends State<MediaTestPage> {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RaisedButton(
                onPressed: () {
                  AppRouter.navigateToMediaPickerPage(context, 9, typeImageAndVideo, false, (result) async {
                    SelectedMediaFiles files = result as SelectedMediaFiles;
                    print(files.type + ":" + files.list.toString());
                    type = files.type;
                    list = files.list;
                    for (MediaFileModel model in list) {
                      if (model.croppedImage != null) {
                        print("${model.file.path}开始获取ByteData" + DateTime.now().millisecondsSinceEpoch.toString());
                        ByteData byteData = await model.croppedImage.toByteData(format: ui.ImageByteFormat.png);
                        print("${model.file.path}已获取到ByteData" + DateTime.now().millisecondsSinceEpoch.toString());
                        Uint8List picBytes = byteData.buffer.asUint8List();
                        print("${model.file.path}已获取到Uint8List" + DateTime.now().millisecondsSinceEpoch.toString());
                        model.croppedImageData = picBytes;
                      }
                    }
                    setState(() {});
                  });
                },
                child: Text("图片视频（不裁剪）"),
              ),
              RaisedButton(
                onPressed: () {
                  AppRouter.navigateToMediaPickerPage(context, 9, typeImageAndVideo, true, (result) async {
                    SelectedMediaFiles files = result as SelectedMediaFiles;
                    print(files.type + ":" + files.list.toString());
                    type = files.type;
                    list = files.list;
                    for (MediaFileModel model in list) {
                      if (model.croppedImage != null) {
                        print("${model.file.path}开始获取ByteData" + DateTime.now().millisecondsSinceEpoch.toString());
                        ByteData byteData = await model.croppedImage.toByteData(format: ui.ImageByteFormat.png);
                        print("${model.file.path}已获取到ByteData" + DateTime.now().millisecondsSinceEpoch.toString());
                        Uint8List picBytes = byteData.buffer.asUint8List();
                        print("${model.file.path}已获取到Uint8List" + DateTime.now().millisecondsSinceEpoch.toString());
                        model.croppedImageData = picBytes;
                      }
                    }
                    setState(() {});
                  });
                },
                child: Text("图片视频（裁剪）"),
              ),
            ],
          ),
          Expanded(
              child: GridView.builder(
                  itemCount: list.length, gridDelegate: _galleryGridDelegate(), itemBuilder: _buildGridItem)),
        ],
      ),
    );
  }

  Widget _buildGridItem(BuildContext context, int index) {
    MediaFileModel model = list[index];
    return Builder(builder: (context) {
      return model.croppedImageData == null
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
