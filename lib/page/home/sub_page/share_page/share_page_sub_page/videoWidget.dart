import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/constants.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/media_file_model.dart';
import 'package:mirror/util/event_bus.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/icon.dart';
import 'package:video_player/video_player.dart';

import '../dynamic_list.dart';

class VideoWidget extends StatefulWidget {
  HomeFeedModel feedModel;
  VideoIsPlay play;
  final SizeInfo sizeInfo;
  final bool isFile;
  final String thumbPath;
  final String durationString;

  VideoWidget(
      {Key key, @required this.play, this.sizeInfo, this.feedModel, this.durationString, this.thumbPath, this.isFile})
      : super(key: key);

  @override
  _VideoWidgetState createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
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
    print(videoIsPlay.id);
    print(widget.feedModel.id);
    widget.play = videoIsPlay;
    if (videoIsPlay.id == widget.feedModel.id) {
      if (widget.feedModel.videos.first.controller != null) {
        if (videoIsPlay.isPlay) {
          if (widget.feedModel.videos.first.controller.value.isPlaying) {
            return;
          }

          widget.feedModel.videos.first.controller.play();
          streamController.sink.add(widget.feedModel.videos.first.controller.value.volume > 0);
          widget.feedModel.videos.first.controller.setLooping(true);
        } else {
          if (!widget.feedModel.videos.first.controller.value.isPlaying) {
            return;
          }
          widget.feedModel.videos.first.controller.pause();
        }
      } else {
        print("初始化了啊啊啊啊");
        init();
      }
    }
  }

  init() async {
    widget.feedModel.videos.first.controller = VideoPlayerController.network(widget.feedModel.videos.first.url);
    widget.feedModel.videos.first.controller.setVolume(0);
    await widget.feedModel.videos.first.controller.initialize().then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void didUpdateWidget(VideoWidget oldWidget) {
    print("此回调什么时候又");
    if (oldWidget.play != widget.play) {
      if (widget.play.isPlay) {
        widget.feedModel.videos.first.controller.play();
        streamController.sink.add(widget.feedModel.videos.first.controller.value.volume > 0);
        widget.feedModel.videos.first.controller.setLooping(true);
      } else {
        widget.feedModel.videos.first.controller.pause();
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    print("视频页销毁————————————————————————————————————————————————");
    widget.feedModel.videos.first.controller?.pause();
    widget.feedModel.videos.first.controller.dispose();
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
              child: SizedBox(
                width: videoSize.width,
                height: videoSize.height,
                child: widget.feedModel.videos.first.controller.value.initialized
                    ? VideoPlayer(widget.feedModel.videos.first.controller)
                    : CachedNetworkImage(
                        imageUrl: widget.feedModel.videos.first.coverUrl,
                        fit: BoxFit.fitWidth,
                        placeholder: (context, url) => Container(
                          color: AppColor.bgWhite,
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppColor.bgWhite,
                        ),
                      ),
                // Center(
                //         child: CupertinoActivityIndicator(radius: 30),
                //       ),
              ),
            ),
          ),
          widget.feedModel.videos.first.controller.value.initialized
              ? Positioned(
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
                                      initialData: widget.feedModel.videos.first.controller.value.volume > 0,
                                      stream: streamController.stream,
                                      builder: (BuildContext stramContext, AsyncSnapshot<bool> snapshot) {
                                        return GestureDetector(
                                          onTap: () {
                                            if (widget.feedModel.videos.first.controller.value.volume > 0) {
                                              widget.feedModel.videos.first.controller.setVolume(0.0);
                                            } else {
                                              widget.feedModel.videos.first.controller.setVolume(1.0);
                                            }
                                            streamController.sink
                                                .add(widget.feedModel.videos.first.controller.value.volume > 0);
                                          },
                                          child: AppIcon.getAppIcon(
                                            snapshot.data == false ? AppIcon.volume_off_16 : AppIcon.volume_on_16,
                                            16,
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
              : Container()
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
