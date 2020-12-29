import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mirror/config/config.dart';
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
  double _progress;
  String _downloadedPath;
  Function(int, int) _progressListener;

  @override
  void initState() {
    super.initState();
    _progressListener = (received, total) {
      setState(() {
        _progress = received / total;
      });

      print("[${DateTime.now().millisecondsSinceEpoch}]received:$received; total:$total; progress:$_progress");
    };
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
                String fileName = _controller.text.split("/").last;
                Response response = await Dio().download(
                    _controller.text, AppConfig.getAppDownloadDir() + "/" + fileName,
                    onReceiveProgress: _progressListener);

                // final taskId = await FileUtil().download(_controller.text, true, true);
                print("response：$response");
              },
              child: Text("开始下载")),
          Text("progress:$_progress"),
          RaisedButton(
              onPressed: () async {
                _downloadedPath = await FileUtil().getDownloadedPath(_controller.text);
                setState(() {});
              },
              child: Text("查询该文件是否已下载")),
          Text(_downloadedPath == null ? "尚未下载" : "$_downloadedPath"),
          RaisedButton(
              onPressed: () async {
                for (String videoUrl in testVideoUrls) {
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
