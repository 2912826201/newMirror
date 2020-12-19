import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:video_player/video_player.dart';

/// video_course_play_page2
/// Created by yangjiayi on 2020/12/15.

class VideoCoursePlayPage2 extends StatefulWidget {
  @override
  _VideoCoursePlayState2 createState() => _VideoCoursePlayState2();
}

class _VideoCoursePlayState2 extends State<VideoCoursePlayPage2> {
  final List<String> urls = [
    "http://devmedia.aimymusic.com/alita/51be47a088ff3858c29653fd16536a37.mp4",
    "http://devmedia.aimymusic.com/0313a2d9f77857d073102320b1a4893c.mp4",
    "http://devmedia.aimymusic.com/25e85ec9a9399023629d3fc15bcb8877.mp4",
    "http://devmedia.aimymusic.com/01e889ed5d0314abba48382d669b739b",
  ];

  VideoPlayerController _controller;

  int _currentPlayingIndex = -1;

  double _progress = 0.0;
  int _duration = 0;
  int _currentPos;

  bool _isPlaying = false;

  VoidCallback _playerListener;


  _VideoCoursePlayState2(){
    _playerListener = () {
      if (!mounted) {
        return;
      }

      VideoPlayerValue value = _controller.value;

      print("controller value: $value");

      setState(() {
        _duration = value.duration.inMilliseconds;
        _currentPos = value.position.inMilliseconds;
        if (_duration == 0) {
          _progress = 0;
        } else {
          _progress = _currentPos / _duration;
        }
      });
      //当播放完成时开始播下一个视频
      if (value.isPlaying == false && _isPlaying == true && _currentPos >= _duration) {
        _playNext();
      }
      _isPlaying = value.isPlaying;
    };
  }

  @override
  void initState() {
    super.initState();
    _playNext();
  }

  @override
  dispose() async {
    super.dispose();
    _controller.removeListener(_playerListener);
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            alignment: Alignment.center,
            color: AppColor.bgBlack,
            child: _controller != null && _controller.value.initialized
                ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  )
                : Container(),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _controller.value.isPlaying ? _controller.pause() : _controller.play();
              });
            },
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

  _playNext() {
    if (_currentPlayingIndex >= urls.length - 1) {
      //已经最后一条
      return;
    }

    _currentPlayingIndex++;

    _controller?.removeListener(_playerListener);
    //这里需要dispose掉之前的_controller不然会有初始化过的_controller没被释放导致再进入播放页播放器初始化失败
    //但如果直接dispose页面会闪过一瞬界面报错状态
    _controller?.pause();
    var oldController = _controller;

    _controller = VideoPlayerController.network(urls[_currentPlayingIndex])
      ..initialize().then((_) {
        setState(() {
          _controller.addListener(_playerListener);
          _controller.play();
        });
        oldController?.dispose();
      });
  }
}
