import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// video_test_page
/// Created by yangjiayi on 2020/12/15.

class VideoTestPage extends StatefulWidget {
  @override
  VideoTestState createState() => VideoTestState();
}


class VideoTestState extends State<VideoTestPage> {
  VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(
        'http://devmedia.aimymusic.com/01e889ed5d0314abba48382d669b739b')
      ..initialize().then((_) {
        _controller.addListener(_playerListener);
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: _controller.value.initialized
              ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          )
              : Container(),
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: "唯一标识video",
          onPressed: () {
            setState(() {
              _controller.value.isPlaying
                  ? _controller.pause()
                  : _controller.play();
            });
          },
          child: Icon(
            _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
          ),
        ),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_playerListener);
    _controller.dispose();
    super.dispose();
  }

  _playerListener() {
    print(_controller.value);
  }
}