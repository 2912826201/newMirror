/// qiniu_test_page
/// Created by yangjiayi on 2020/11/13.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sy_flutter_qiniu_storage/sy_flutter_qiniu_storage.dart';

class QiniuTest extends StatefulWidget {
  @override
  _QiniuTestState createState() => new _QiniuTestState();
}

class _QiniuTestState extends State<QiniuTest> {
  double _process = 0.0;

  @override
  void initState() {
    super.initState();
  }

  _onUpload() async {
    String token =
        "YwcBjjrz_J9x5nPioouc4S7H-eb_JLxUpKV4gF4-:-698sxUdUFVkFGXHV5o3Sp8hBZc=:eyJmaWxlLXR5cGUiOjAsImZzaXplLWxpbWl0IjoyMDk3MTUyMDAsInNjb3BlIjoiYWlteW11c2ljLWRldnBpYyIsInJldHVybkJvZHkiOiJ7XCJrZXlcIjpcIiQoa2V5KVwiLFwiaGFzaFwiOlwiJChldGFnKVwiLFwiYnVja2V0XCI6XCIkKGJ1Y2tldClcIixcImZzaXplXCI6JChmc2l6ZSl9IiwiZGVhZGxpbmUiOjE2MDUyNzMyNTR9";
    String domain = "http://devpic.aimymusic.com";
    File file = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (file == null) {
      return;
    }
    final syStorage = new SyFlutterQiniuStorage();
    //监听上传进度
    syStorage.onChanged().listen((dynamic percent) {
      double p = percent;
      setState(() {
        _process = p;
      });
      print(percent);
    });

    //上传文件
    var result = await syStorage.upload(file.path, token, _key(file));
    print(result);
  }

  String _key(File file) {
    return DateTime.now().millisecondsSinceEpoch.toString() + '.' + file.path.split('.').last;
  }

  //取消上传
  _onCancel() {
    SyFlutterQiniuStorage.cancelUpload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: const Text('七牛云存储SDK demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            LinearProgressIndicator(
              value: _process,
            ),
            RaisedButton(
              child: Text('上传'),
              onPressed: _onUpload,
            ),
            RaisedButton(
              child: Text('取消上传'),
              onPressed: _onCancel,
            ),
          ],
        ),
      ),
    );
  }
}
