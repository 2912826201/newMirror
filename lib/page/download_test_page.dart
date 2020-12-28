import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:mirror/config/config.dart';
import 'package:mirror/util/file_util.dart';

/// download_test_page
/// Created by yangjiayi on 2020/12/28.

class DownloadTestPage extends StatefulWidget {
  @override
  _DownloadTestState createState() => _DownloadTestState();
}

class _DownloadTestState extends State<DownloadTestPage> {
  TextEditingController _controller = TextEditingController();
  ReceivePort _port = ReceivePort();
  String _id;
  DownloadTaskStatus _status;
  int _progress;
  bool _isDownloaded = false;

  @override
  void initState() {
    super.initState();
    IsolateNameServer.registerPortWithName(_port.sendPort, downloadPortName);
    _port.listen((dynamic data) {
      _id = data[0];
      _status = data[1];
      _progress = data[2];
      print("id:$_id; status:$_status; progress:$_progress");
      setState(() {});
    });

    FlutterDownloader.registerCallback(FileUtil.downloadCallback);
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping(downloadPortName);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Text("输入文件地址"),
          TextField(
            controller: _controller,
          ),
          RaisedButton(
              onPressed: () async {
                final taskId = await FileUtil().download(_controller.text, true, true);
                print("task的id是：$taskId");
              },
              child: Text("开始下载")),
          Text("id:$_id; status:$_status; progress:$_progress"),
          RaisedButton(
              onPressed: () async {
                _isDownloaded = await FileUtil().checkIsDownloaded(_controller.text);
                setState(() {});
              },
              child: Text("查询该文件是否已下载")),
          Text(_isDownloaded ? "是" : "否"),
        ],
      ),
    );
  }
}
