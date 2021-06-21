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
import 'package:qiniu_flutter_sdk/qiniu_flutter_sdk.dart';

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
    File file = File(file1.path);
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
    File file = File(file1.path);
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

  _onUploadNewNew() async {
    PickedFile file1 = await ImagePicker.platform.pickImage(source: ImageSource.gallery);
    File file = File(file1.path);
    if (file == null) {
      return;
    }

    Storage storage = Storage();
    PutController putController = PutController();
    // 添加整体进度监听
    putController.addProgressListener((double percent) {
      setState(() {
        _process = percent;
      });
      print('任务进度变化：已发送：$percent');
    });
    // 添加发送进度监听
    putController.addSendProgressListener((double percent) {
      print('已上传进度变化：已发送：$percent');
    });
    // 添加状态监听
    putController.addStatusListener((StorageStatus status) {
      print('状态变化: 当前任务状态：$status');
    });

    try {
      await storage.putFile(
        file,
        token,
        options: PutOptions(
          key: _key(file),
          controller: putController,
        ),
      );
    } catch (error) {
      if (error is StorageError) {
        switch (error.type) {
          case StorageErrorType.CONNECT_TIMEOUT:
            print('发生错误: 连接超时');
            break;
          case StorageErrorType.SEND_TIMEOUT:
            print('发生错误: 发送数据超时');
            break;
          case StorageErrorType.RECEIVE_TIMEOUT:
            print('发生错误: 响应数据超时');
            break;
          case StorageErrorType.RESPONSE:
            print('发生错误: ${error.message}');
            break;
          case StorageErrorType.CANCEL:
            print('发生错误: 请求取消');
            break;
          case StorageErrorType.UNKNOWN:
            print('发生错误: 未知错误');
            break;
          case StorageErrorType.NO_AVAILABLE_HOST:
            print('发生错误: 无可用 Host');
            break;
          case StorageErrorType.IN_PROGRESS:
            print('发生错误: 已在队列中');
            break;
        }
      } else {
        print('发生错误: ${error.toString()}');
      }
    }
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
            RaisedButton(
              child: Text('新新版上传'),
              onPressed: _onUploadNewNew,
            ),
          ],
        ),
      ),
    );
  }
}
