import 'dart:async';

import 'package:fijkplayer/fijkplayer.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/util/screen_util.dart';

/// video_course_play_page2
/// Created by yangjiayi on 2020/12/15.

class VideoCoursePlayPage2 extends StatefulWidget {
  @override
  _VideoCoursePlayState2 createState() => _VideoCoursePlayState2();
}

class _VideoCoursePlayState2 extends State<VideoCoursePlayPage2> {
  final List<String> urls = [
    "http://devmedia.aimymusic.com/0313a2d9f77857d073102320b1a4893c.mp4",
    "http://devmedia.aimymusic.com/25e85ec9a9399023629d3fc15bcb8877.mp4",
    "http://devmedia.aimymusic.com/01e889ed5d0314abba48382d669b739b",
    "http://devmedia.aimymusic.com/alita/51be47a088ff3858c29653fd16536a37.mp4"
  ];

  final FijkPlayer player = FijkPlayer();

  int _currentPlayingIndex = -1;

  double _progress = 0.0;
  int _duration = 0;
  StreamSubscription _currentPosSubs;
  int _currentPos;

  @override
  void initState() {
    super.initState();
    _currentPos = player.currentPos.inMilliseconds;
    _currentPosSubs = player.onCurrentPosUpdate.listen((v) {
      setState(() {
        _currentPos = v.inMilliseconds;
        if (_duration == 0) {
          _progress = 0;
        } else {
          _progress = _currentPos / _duration;
        }
        print("duration: $_duration, currentPos: $_currentPos, progress: $_progress");
      });
    });
    player.addListener(_playerListener);
    _playNext();
  }

  @override
  void dispose() {
    super.dispose();
    player.removeListener(_playerListener);
    player.release();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FijkView(
            player: player,
            color: AppColor.bgBlack,
            fit: FijkFit.cover,
            fsFit: FijkFit.cover,
          ),
          //拦截一下播放器的默认手势操作
          GestureDetector(
            onTap: () {},
            child: Container(
              color: AppColor.transparent,
            ),
          ),
          Positioned(
              right: 16,
              top: 8 + ScreenUtil.instance.statusBarHeight,
              child: RaisedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("X"),
              )),
          Positioned(
            left: 16,
            top: 8 + ScreenUtil.instance.statusBarHeight,
            child: Text(
              "$_currentPlayingIndex",
              style: TextStyle(color: AppColor.white, backgroundColor: AppColor.bgBlack),
            ),
          ),
          Positioned(
            bottom: 8,
            child: Container(
              height: 10,
                width: ScreenUtil.instance.screenWidthDp,
                child: LinearProgressIndicator(
              value: _progress,
            )),
          )
        ],
      ),
    );
  }

  _playerListener() {
    FijkValue value = player.value;

    print("player value: $value");

    if (value.prepared) {
      _duration = value.duration.inMilliseconds;
      print("width: ${value.size.width}, height: ${value.size.height}");
    }

    switch (value.state) {
      case FijkState.completed:
        if (_currentPlayingIndex < urls.length - 1) {
          _playNext();
        }
        break;
      default:
        break;
    }
  }

  _playNext() async {
    setState(() {
      _currentPlayingIndex++;
    });
    await player.reset();
    await player.setDataSource(urls[_currentPlayingIndex], autoPlay: true);
  }
}
