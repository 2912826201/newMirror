import 'package:flutter/material.dart';
import 'package:mirror/data/model/media_file_model.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/feed_video_player.dart';

/// feed_video_test_page
/// Created by yangjiayi on 2021/1/11.

class FeedVideoTestPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SizeInfo sizeInfo = SizeInfo();
    sizeInfo.width = 1280;
    sizeInfo.height = 720;
    sizeInfo.videoCroppedRatio = 1.0;
    sizeInfo.offsetRatioX = -0.21875;
    return Scaffold(
      appBar: CustomAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FeedVideoPlayer("http://media.aimymusic.com/023a5bbc5718283b68fc71b4a8dece4b.mp4", sizeInfo,
              ScreenUtil.instance.screenWidthDp * 2 / 3),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FeedVideoPlayer("http://media.aimymusic.com/023a5bbc5718283b68fc71b4a8dece4b.mp4", sizeInfo,
                  ScreenUtil.instance.screenWidthDp * 1 / 3),
              FeedVideoPlayer("http://media.aimymusic.com/023a5bbc5718283b68fc71b4a8dece4b.mp4", sizeInfo,
                  ScreenUtil.instance.screenWidthDp * 1 / 3),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FeedVideoPlayer("http://media.aimymusic.com/023a5bbc5718283b68fc71b4a8dece4b.mp4", sizeInfo,
                  ScreenUtil.instance.screenWidthDp * 2 / 9),
              FeedVideoPlayer("http://media.aimymusic.com/023a5bbc5718283b68fc71b4a8dece4b.mp4", sizeInfo,
                  ScreenUtil.instance.screenWidthDp * 2 / 9),
              FeedVideoPlayer("http://media.aimymusic.com/023a5bbc5718283b68fc71b4a8dece4b.mp4", sizeInfo,
                  ScreenUtil.instance.screenWidthDp * 2 / 9),
            ],
          ),
        ],
      ),
    );
  }
}
