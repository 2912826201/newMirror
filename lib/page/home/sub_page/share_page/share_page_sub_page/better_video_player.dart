import 'dart:async';

import 'package:better_player/better_player.dart' hide BetterPlayer;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/api.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/constants.dart';
import 'package:mirror/data/model/base_response_model.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/media_file_model.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:mirror/data/notifier/token_notifier.dart';
import 'package:mirror/data/notifier/user_interactive_notifier.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/event_bus.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/better_player_list_video/batter_player.dart';
import 'package:mirror/widget/icon.dart';
import 'package:mirror/widget/video_exposure/video_exposure.dart';
import 'package:toast/toast.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
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

  // 播放器控制器
  VideoPlayerController controller;

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
      if (controller != null) {
        if (videoIsPlay.isPlay) {
          if (controller.value.isPlaying) {
            return;
          }
          controller.play();
          streamController.sink.add(controller.value.volume > 0);
          controller.setLooping(true);
        } else {
          if (!controller.value.isPlaying) {
            return;
          }
          controller.pause();
        }
      } else {
        print("初始化了啊啊啊啊");
        init();
      }
    }
  }

  init() async {
    controller = VideoPlayerController.network(widget.feedModel.videos.first.url);
    controller.setVolume(0);
    await controller.initialize().then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void didUpdateWidget(VideoWidget oldWidget) {
    print("此回调什么时候又");
    if (oldWidget.play.id != widget.play.id) {
      if (widget.play.isPlay) {
        controller.play();
        streamController.sink.add(controller.value.volume > 0);
        controller.setLooping(true);
      } else {
        controller.pause();
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    print("视频页销毁————————————————————————————————————————————————");
    controller?.pause();
    controller?.dispose();
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
                child: controller.value.initialized
                    ? VideoPlayer(controller)
                    : CachedNetworkImage(
                        imageUrl: widget.feedModel.videos.first.coverUrl,
                        fit: BoxFit.cover,
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
          controller.value.initialized
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
                                      initialData: controller.value.volume > 0,
                                      stream: streamController.stream,
                                      builder: (BuildContext stramContext, AsyncSnapshot<bool> snapshot) {
                                        return GestureDetector(
                                          onTap: () {
                                            if (controller.value.volume > 0) {
                                              controller.setVolume(0.0);
                                            } else {
                                              controller.setVolume(1.0);
                                            }
                                            streamController.sink.add(controller.value.volume > 0);
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

class betterVideoPlayer extends StatefulWidget {
  HomeFeedModel feedModel;
  final SizeInfo sizeInfo;
  final String durationString;

  betterVideoPlayer({Key key, this.sizeInfo, this.feedModel, this.durationString})
      : super(key: key);

  @override
  _betterVideoPlayerState createState() => _betterVideoPlayerState();
}

class _betterVideoPlayerState extends State<betterVideoPlayer> {
  Size containerSize;
  Size videoSize;
  double offsetX;
  double offsetY;

  // 控件显示
  double initHeight = 0;

// 是否可点赞
  bool isSetUpLuad = true;

  // 开启关闭音量的监听
  StreamController<bool> streamController = StreamController<bool>();
  StreamController<double> streamHeight = StreamController<double>();
  BetterPlayerController controller;
  BetterPlayerDataSource dataSource;
  BetterPlayerConfiguration configuration;
  Function(BetterPlayerEvent) eventListener;

  @override
  void initState() {
    super.initState();
    _calculateSize();

    init();
  }

  init() async {
    dataSource = BetterPlayerDataSource.network(widget.feedModel.videos.first.url);
    if (mounted) {
      setState(() {});
    }

    eventListener = (BetterPlayerEvent event) {
      switch (event.betterPlayerEventType) {
        case BetterPlayerEventType.initialized:
          controller?.setVolume(0);
          break;
        default:
          break;
      }
    };
    configuration = BetterPlayerConfiguration(
        // 如果不加上这个比例，在播放本地视频时宽高比不正确
        aspectRatio: videoSize.width / videoSize.height,
        autoPlay: false,
        eventListener: eventListener,
        looping: true,
        //定义按下播放器时播放器是否以全屏启动
        fullScreenByDefault: false,
        placeholder: CachedNetworkImage(
          imageUrl: FileUtil.getVideoFirstPhoto(widget.feedModel.videos.first.url),
          width: videoSize.width,
          height: videoSize.height,
          placeholder: (context, url) {
            return Container(
              color: AppColor.bgWhite,
            );
          },
          errorWidget: (context, url, error) => Container(
            color: AppColor.bgWhite,
          ),
        ),
        controlsConfiguration: BetterPlayerControlsConfiguration(
          showControls: false,
        ));
    controller = BetterPlayerController(configuration, betterPlayerDataSource: dataSource);
  }

  @override
  void dispose() {
    print("视频页销毁————————————————————————————————————————————————");
    controller?.pause();
    controller?.removeEventsListener(eventListener);
    streamController.close();
    streamHeight.close();
    super.dispose();
  }

  // 点赞
  setUpLuad() async {
    bool isLoggedIn = context.read<TokenNotifier>().isLoggedIn;
    if (isLoggedIn) {
      if (isSetUpLuad) {
        isSetUpLuad = false;
        BaseResponseModel model = await laud(id: widget.feedModel.id, laud: widget.feedModel.isLaud == 0 ? 1 : 0);
        print('===================================model.code==${model.code}');
        // 点赞/取消赞成功
        if (model.code == CODE_BLACKED) {
          ToastShow.show(msg: "你已被对方加入黑名单，成为好友才能互动哦~", context: context, gravity: Toast.CENTER);
        } else {
          context.read<FeedMapNotifier>().setLaud(
              context.read<FeedMapNotifier>().value.feedMap[widget.feedModel.id].isLaud == 0 ? 1 : 0,
              context.read<ProfileNotifier>().profile.avatarUri,
              widget.feedModel.id);
          context.read<UserInteractiveNotifier>().laudedChange(
              widget.feedModel.pushId, context.read<FeedMapNotifier>().value.feedMap[widget.feedModel.id].isLaud);
        }
        isSetUpLuad = true;
      }
    } else {
      // 去登录
      AppRouter.navigateToLoginPage(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return VideoExposure(
      key: Key('video_${widget.feedModel.id}'),
      child: Container(
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
                // 双击
                onDoubleTap: () {
                  // 获取是否点赞
                  int isLaud = context.read<FeedMapNotifier>().value.feedMap[widget.feedModel.id].isLaud;
                  print("isLaud:::$isLaud");
                  if (isLaud != 1) {
                    setUpLuad();
                  }
                },
                child: SizedBox(
                  width: videoSize.width,
                  height: videoSize.height,
                  child: BetterPlayer(
                    controller: controller,
                  ),
                ),
              ),
            ),
            controller.isVideoInitialized()
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
                                        initialData: controller.videoPlayerController.value.volume > 0,
                                        stream: streamController.stream,
                                        builder: (BuildContext stramContext, AsyncSnapshot<bool> snapshot) {
                                          return GestureDetector(
                                            onTap: () {
                                              if (controller.videoPlayerController.value.volume > 0) {
                                                controller.setVolume(0.0);
                                              } else {
                                                controller.setVolume(1.0);
                                              }
                                              streamController.sink
                                                  .add(controller.videoPlayerController.value.volume > 0);
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
      ),
      onExposure: (visibilityInfo) {
        if (visibilityInfo.visibleFraction == 1.0) {
          if (!controller.isPlaying()) {
            controller.play();
          }
        } else if (visibilityInfo.visibleFraction < 1.0 && visibilityInfo.visibleFraction >= 0.0) {
          if (controller.isPlaying()) {
            controller.pause();
          }
        }
      },
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
