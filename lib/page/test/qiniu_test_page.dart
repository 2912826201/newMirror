/// qiniu_test_page
/// Created by yangjiayi on 2020/11/13.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mirror/api/qiniu_api.dart';
import 'package:mirror/data/model/upload/qiniu_token_model.dart';
import 'package:mirror/data/model/upload/upload_result_model.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:sy_flutter_qiniu_storage/sy_flutter_qiniu_storage.dart';

class QiniuTest extends StatefulWidget {
  @override
  _QiniuTestState createState() => new _QiniuTestState();
}

class _QiniuTestState extends State<QiniuTest> {
  double _process = 0.0;
  String token = "";
  String domain = "";

  @override
  void initState() {
    super.initState();
  }

  _getToken() async {
    QiniuTokenModel tokenModel = await requestQiniuToken(2);
    token = tokenModel.upToken;
    domain = tokenModel.domain;
  }

  _onUpload() async {
    PickedFile file1 = await ImagePicker.platform.pickImage(source: ImageSource.gallery);
    File file=File(file1.path);
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

  _onUploadNew() async {
    PickedFile file1 = await ImagePicker.platform.pickImage(source: ImageSource.gallery);
    File file=File(file1.path);
    if (file == null) {
      return;
    }
    List<File> list = [];
    list.add(file);

    UploadResults results = await FileUtil().uploadPics(list, (percent) {
      setState(() {
        _process = percent;
      });
      print("总进度:$percent");
    });
    print(results.isSuccess);
    print(results.resultMap);
  }

  String _key(File file) {
    return "ifapp/" + DateTime.now().millisecondsSinceEpoch.toString() + '.' + file.path.split('.').last;
  }

  //取消上传
  _onCancel() {
    SyFlutterQiniuStorage.cancelUpload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleString: '七牛云存储SDK demo',
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
              child: Text('获取token'),
              onPressed: _getToken,
            ),
            RaisedButton(
              child: Text('上传'),
              onPressed: _onUpload,
            ),
            RaisedButton(
              child: Text('取消上传'),
              onPressed: _onCancel,
            ),
            RaisedButton(
              child: Text('新版上传'),
              onPressed: _onUploadNew,
            ),
          ],
        ),
      ),
    );
  }
}
