import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:video_player/video_player.dart';

class InteractiveVideoItem extends StatefulWidget {
  final VideosModel source;
  final bool isFocus;

  InteractiveVideoItem(this.source, {this.isFocus});

  @override
  _InteractiveVideoItemState createState() => _InteractiveVideoItemState();
}

class _InteractiveVideoItemState extends State<InteractiveVideoItem> {
  VideoPlayerController _controller;
  VoidCallback listener;
  String localFileName;

  _DemoVideoItemState() {
    listener = () {
      if (!mounted) {
        return;
      }
      setState(() {});
    };
  }

  @override
  void initState() {
    super.initState();
    print('initState: ${widget.source.url}');
    init();
  }

  init() async {
    _controller = VideoPlayerController.network(widget.source.url);
    // loop play
    _controller.setLooping(true);
    await _controller.initialize();
    setState(() {});
    _controller.addListener(listener);
  }

  @override
  void dispose() {
    super.dispose();
    print('dispose: ${widget.source.url}');
    _controller.removeListener(listener);
    _controller?.pause();
    _controller?.dispose();
  }

  @override
  void didUpdateWidget(covariant InteractiveVideoItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isFocus && !widget.isFocus) {
      // pause
      _controller?.pause();
    }
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? Stack(
      alignment: Alignment.center,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _controller.value.isPlaying
                  ? _controller.pause()
                  : _controller.play();
            });
          },
          child: Hero(
            tag: widget.source.url,
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            ),
          ),
        ),
        _controller.value.isPlaying == true
            ? const SizedBox()
            : IgnorePointer(
          ignoring: true,
          child: const Icon(
            Icons.play_arrow,
            size: 100,
            color: Colors.white,
          ),
        ),
      ],
    )
        :
    // Container();
    Theme(
        data: ThemeData(
            cupertinoOverrideTheme:
            CupertinoThemeData(brightness: Brightness.dark)),
        child: CupertinoActivityIndicator(radius: 30));
  }
}