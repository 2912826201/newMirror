import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:mirror/page/training/video_course/video_course_play_page.dart';
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
  String _downloadedPath;

  @override
  void initState() {
    super.initState();
    IsolateNameServer.registerPortWithName(_port.sendPort, downloadPortName);
    _port.listen((dynamic data) {
      _id = data[0];
      _status = data[1];
      _progress = data[2];
      print("[${DateTime.now().millisecondsSinceEpoch}]id:$_id; status:$_status; progress:$_progress");
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
                _downloadedPath = await FileUtil().getDownloadedPath(_controller.text);
                setState(() {});
              },
              child: Text("查询该文件是否已下载")),
          Text(_downloadedPath == null ? "尚未下载" : "$_downloadedPath"),
          RaisedButton(
              onPressed: () async {
                for(String videoUrl in testVideoUrls){
                  final taskId = await FileUtil().download(videoUrl, true, true);
                  print("task的id是：$taskId");
                }
              },
              child: Text("下载视频课测试页视频")),
          RaisedButton(
              onPressed: () {
                testVideoUrls.forEach((element) {
                  FileUtil().removeDownloadTask(element);
                });
              },
              child: Text("删除视频课测试页视频")),
        ],
      ),
    );
  }
}
