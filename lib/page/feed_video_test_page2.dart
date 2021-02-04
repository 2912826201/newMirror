import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/media_file_model.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/feed_video_player.dart';

/// feed_video_test_page2
/// Created by yangjiayi on 2021/1/12.

class FeedVideoTestPage2 extends StatefulWidget {
  @override
  _FeedVideoTestPage2State createState() => _FeedVideoTestPage2State();
}

class _FeedVideoTestPage2State extends State<FeedVideoTestPage2> {
  List<SizeInfo> sizeInfoList = [];
  String url = "http://media.aimymusic.com/07b0ced3d07e1aef0a8b6ce0102a74bf.mp4";

  @override
  void initState() {
    sizeInfoList.add(SizeInfo()
      ..width = 1280
      ..height = 720
      ..videoCroppedRatio = 1.0
      ..offsetRatioX = -0.21875);
    sizeInfoList.add(SizeInfo()
      ..width = 1280
      ..height = 720
      ..videoCroppedRatio = 16 / 9);
    sizeInfoList.add(SizeInfo()
      ..width = 1280
      ..height = 720
      ..videoCroppedRatio = 0.8
      ..offsetRatioX = -22 / 80);
    sizeInfoList.add(SizeInfo()
      ..width = 1280
      ..height = 720
      ..videoCroppedRatio = 1.9
      ..offsetRatioY = -11 / 320);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: ListView.builder(itemCount: 100, itemBuilder: _buildItem),
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    double width = ScreenUtil.instance.screenWidthDp;
    double height = width / 4;
    return Column(
      children: [
        FeedVideoPlayer(url, sizeInfoList[index % sizeInfoList.length], width, isInListView: true,),
        Container(
          width: width,
          height: height,
          color: AppColor.mainBlue,
        )
      ],
    );
  }
}
