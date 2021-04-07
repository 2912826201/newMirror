import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/constants.dart';
import 'package:mirror/data/model/media_file_model.dart';
import 'package:mirror/util/event_bus.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:video_player/video_player.dart';

import '../dynamic_list.dart';

class VideoWidget extends StatefulWidget {
  final String url;
  final int id;
  final bool play;
  final SizeInfo sizeInfo;
  final bool isFile;
  final String thumbPath;
  final String durationString;

  const VideoWidget(
      {Key key,
      @required this.url,
      @required this.play,
      this.sizeInfo,
      this.id,
      this.durationString,
      this.thumbPath,
      this.isFile})
      : super(key: key);

  @override
  _VideoWidgetState createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  VideoPlayerController _controller;
  Size containerSize;
  Size videoSize;
  double offsetX;
  double offsetY;

  // 控件显示
  double initHeight = 0;

  // 开启关闭音量的监听
  StreamController<bool> streamController = StreamController<bool>();
  StreamController<double> streamHeight = StreamController<double>();

  @override
  void initState() {
    super.initState();
    _calculateSize();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      EventBus.getDefault().registerSingleParameter(_videoPlayOrpause, EVENTBUS_VIDEOWIGET_PAGE,
          registerName: EVENTBUS__VIDEO_PLAYORPAUSE);
    });
    init();
  }

  _videoPlayOrpause(VideoIsPlay videoIsPlay) {
    print("视频产生变化：：：${videoIsPlay.isPlay}");
    print("视频路径：：${widget.url}");
    print(_controller.dataSource);
    if (videoIsPlay.isPlay && videoIsPlay.id == widget.id) {
      _controller.play();
      streamController.sink.add(_controller.value.volume > 0);
      _controller.setLooping(true);
    } else {
      _controller.pause();
    }
    if (mounted) {
      setState(() {});
    }
  }

  init() async {
    _controller = VideoPlayerController.network(widget.url);
    _controller.setVolume(0);
    await _controller.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  // @override
  // void didUpdateWidget(VideoWidget oldWidget) {
  //   if (oldWidget.play != widget.play) {
  //     if (widget.play) {
  //       _controller.play();
  //       streamController.sink.add(_controller.value.volume > 0);
  //       _controller.setLooping(true);
  //     } else {
  //       _controller.pause();
  //     }
  //   }
  //   super.didUpdateWidget(oldWidget);
  // }

  @override
  void dispose() {
    print("视频页销毁————————————————————————————————————————————————");
    // _controller?.pause();
    // _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: containerSize.height,
      width: containerSize.width,
      child: Stack(
        children: [
          Positioned(
              left: offsetX,
              top: offsetY,
              child: GestureDetector(
                onTap: () {
                  streamHeight.sink.add(40.0);
                  // 延迟器:
                  new Future.delayed(Duration(seconds: 3), () {
                    streamHeight.sink.add(0.0);
                  });
                },
                child: _controller.value.initialized
                    ? SizedBox(width: videoSize.width, height: videoSize.height, child: VideoPlayer(_controller))
                    : Theme(
                        data: ThemeData(cupertinoOverrideTheme: CupertinoThemeData(brightness: Brightness.dark)),
                        child: CupertinoActivityIndicator(radius: 30)),
              )),
          Positioned(
              bottom: 0,
              child: StreamBuilder<double>(
                  initialData: initHeight,
                  stream: streamHeight.stream,
                  builder: (BuildContext stramContext, AsyncSnapshot<double> snapshot) {
                    return AnimatedContainer(
                        height: snapshot.data,
                        width: ScreenUtil.instance.width,
                        duration: Duration(milliseconds: 100),
                        child: Container(
                          decoration: BoxDecoration(
                            // 渐变色
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomLeft,
                              colors: [
                                AppColor.transparent,
                                AppColor.black.withOpacity(0.5),
                              ],
                            ),
                          ),
                          width: ScreenUtil.instance.width,
                          height: 40,
                          padding: const EdgeInsets.only(left: 16, right: 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              StreamBuilder<bool>(
                                  initialData: _controller.value.volume > 0,
                                  stream: streamController.stream,
                                  builder: (BuildContext stramContext, AsyncSnapshot<bool> snapshot) {
                                    return GestureDetector(
                                      onTap: () {
                                        if (_controller.value.volume > 0) {
                                          _controller.setVolume(0.0);
                                        } else {
                                          _controller.setVolume(1.0);
                                        }
                                        streamController.sink.add(_controller.value.volume > 0);
                                      },
                                      child: Icon(
                                        snapshot.data == false ? Icons.volume_mute : Icons.volume_up,
                                        size: 16,
                                        color: AppColor.white,
                                      ),
                                    );
                                  }),
                              Spacer(),
                              Text(
                                widget.durationString ?? "00 : 00",
                                style: const TextStyle(fontSize: 11, color: AppColor.white),
                              ),
                            ],
                          ),
                        ));
                  }))
        ],
      ),
    );
  }

  _calculateSize() {
    double containerWidth = ScreenUtil.instance.width;
    double containerHeight;
    double videoWidth;
    double videoHeight;

    double videoRatio = widget.sizeInfo.width / widget.sizeInfo.height;
    double containerRatio;

    //如果有裁剪的比例 则直接用该比例
    if (widget.sizeInfo.videoCroppedRatio != null) {
      containerRatio = widget.sizeInfo.videoCroppedRatio;
    } else {
      if (videoRatio < minMediaRatio) {
        containerRatio = minMediaRatio;
      } else if (videoRatio > maxMediaRatio) {
        containerRatio = maxMediaRatio;
      } else {
        containerRatio = videoRatio;
      }
    }

    containerHeight = containerWidth / containerRatio;
    if (videoRatio < containerRatio) {
      videoWidth = containerWidth;
      videoHeight = videoWidth / videoRatio;
    } else if (videoRatio > containerRatio) {
      videoHeight = containerHeight;
      videoWidth = videoHeight * videoRatio;
    } else {
      videoWidth = containerWidth;
      videoHeight = containerHeight;
    }

    offsetX = videoWidth * widget.sizeInfo.offsetRatioX;
    offsetY = videoHeight * widget.sizeInfo.offsetRatioY;

    containerSize = Size(containerWidth, containerHeight);
    videoSize = Size(videoWidth, videoHeight);
  }
}
