import 'dart:async';

import 'package:better_player/better_player.dart' hide BetterPlayer;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/api.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/config/shared_preferences.dart';
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
import 'package:mirror/util/date_util.dart';
import 'package:mirror/util/event_bus.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/better_player_list_video/better_player.dart';
import 'package:mirror/widget/icon.dart';
import 'package:mirror/widget/video_exposure/video_exposure.dart';
import 'package:provider/provider.dart';
import '../dynamic_list.dart';

class betterVideoPlayer extends StatefulWidget {
  HomeFeedModel feedModel;
  final SizeInfo sizeInfo;
  final String durationString;

  betterVideoPlayer({Key key, this.sizeInfo, this.feedModel, this.durationString}) : super(key: key);

  @override
  _betterVideoPlayerState createState() => _betterVideoPlayerState();
}

class _betterVideoPlayerState extends State<betterVideoPlayer> {
  Size containerSize;
  Size videoSize;
  double offsetX;
  double offsetY;

  // 控件显示
  double initHeight = 40.0;

  // 是否可点赞
  bool isSetUpLuad = true;

  // 开启关闭音量的监听
  StreamController<bool> streamController;
  StreamController<double> streamHeight;
  BetterPlayerController controller;
  BetterPlayerDataSource dataSource;
  BetterPlayerConfiguration configuration;
  Function(BetterPlayerEvent) eventListener;
  int firstTapTimep;

  @override
  void initState() {
    super.initState();
    streamController = StreamController.broadcast();
    streamHeight = StreamController.broadcast();
    _calculateSize();
    EventBus.getDefault().registerSingleParameter(_deletedVideooController, EVENTBUS_VIDEO_VIEW,
        registerName: EVENTBUS_VIDEO_DELETE_FEED);
    EventBus.getDefault().registerSingleParameter(_deletedFeedVideoPlay, EVENTBUS_VIDEO_VIEW,
        registerName: EVENTBUS_DELETE_FEED_VIDEO_PLAY);
  }

  _deletedVideooController(int id) {
    if (widget.feedModel.id == id) {
      deletedControllerContrastValue();
    }
  }

  _deletedFeedVideoPlay(int id) {
    if (mounted) {
      print("重新开始加子");
      controller.play();
    }
  }

  init() async {
    dataSource = BetterPlayerDataSource.network(widget.feedModel.videos.first.url);
    // if (mounted) {
    //   setState(() {});
    // }
    print("初始化");
    eventListener = (BetterPlayerEvent event) {
      switch (event.betterPlayerEventType) {
        case BetterPlayerEventType.initialized:
          if (AppPrefs.getVideoSoundSwitch()) {
            controller?.setVolume(1.0);
          } else {
            controller?.setVolume(0);
          }
          break;
        default:
          // ToastShow.show(msg: "初始化失败", context: context);
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
            fit: BoxFit.cover,
            placeholder: (context, url) {
              return Container(
                color: AppColor.imageBgGrey,
              );
            },
            errorWidget: (context, url, error) {
              print("offsetY：#$offsetY");
              return Container(
                color: AppColor.imageBgGrey,
                padding: EdgeInsets.only(top: (containerSize.height - ScreenUtil.instance.width * 0.53) / 2.0),
                child: getImageAsset("assets/png/image_error.png"),
              );
            }),
        controlsConfiguration: BetterPlayerControlsConfiguration(
          showControls: false,
        ));

    controller = BetterPlayerController(configuration, betterPlayerDataSource: dataSource);
    if (AppPrefs.getVideoSoundSwitch()) {
      controller?.setVolume(1.0);
    } else {
      controller?.setVolume(0);
    }
    Application.feedVideoControllerList.add(controller.hashCode);
    Application.feedVideoControllerLists.add(controller);
    Application.feedVideoTimeList.add(DateUtil.getGenerateFormatDate(widget.feedModel.createTime, false));
    if (mounted) {
      setState(() {});
    }
    new Future.delayed(Duration(seconds: 3), () {
      if (mounted) {
        streamHeight.sink.add(0.0);
        firstTapTimep = null;
      }
    });
  }

  Widget getImageAsset(String assetPath) {
    //print("assetPath:${assetPath}");
    return UnconstrainedBox(
      alignment: Alignment.topCenter,
      child: Image.asset(
        assetPath ?? "",
        width: ScreenUtil.instance.width * 0.53,
        height: ScreenUtil.instance.width * 0.53,
        fit: BoxFit.cover,
      ),
    );
  }

  @override
  void dispose() {
    print("视频页销毁————————————————————————————————————————————————");
    controller?.pause();
    deletedControllerContrastValue();
    // controller?.removeEventsListener(eventListener);
    streamController.close();
    streamHeight.close();
    super.dispose();
  }

  // 移除控制器标识
  deletedControllerContrastValue() {
    Application.feedVideoControllerList.removeWhere((v) => v == controller.hashCode);
    Application.feedVideoControllerLists.removeWhere((v) => v == controller);
    Application.feedVideoTimeList
        .removeWhere((element) => element == DateUtil.getGenerateFormatDate(widget.feedModel.createTime, false));
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
        key: Key("${widget.feedModel.createTime}_key"),
        onVisibilityChanged: (info) async {
          print("visibilityInfo:::::::::::${info.visibleFraction}");
          if (info.visibleFraction >= 0.5) {
            if (controller == null) {
              await init();
            }
            if (controller != null && !Application.feedVideoControllerList.contains(controller.hashCode)) {
              Application.feedVideoControllerList.add(controller.hashCode);
              Application.feedVideoControllerLists.add(controller);
              Application.feedVideoTimeList.add(DateUtil.getGenerateFormatDate(widget.feedModel.createTime, false));
            }
            if (Application.feedVideoControllerList.first == controller.hashCode) {
              controller.play();
              print("视频时长：：：${widget.durationString}");
              print("查看时间更直观：：：：${DateUtil.getGenerateFormatDate(widget.feedModel.createTime, false)}");
            }
            Application.feedVideoControllerList.forEach((element) {
              print(element);
            });
            print('当前控制器：：：${controller.hashCode}');
            // if (!controller.isPlaying()) {

            // }
          } else if (info.visibleFraction < 0.5 && info.visibleFraction >= 0.0) {
            deletedControllerContrastValue();
            print("!!!!!!!!!!!!!!!!!!!!!!!");
            Application.feedVideoControllerList.forEach((element) {
              print(element);
            });
            if (Application.feedVideoControllerLists.length == 1) {
              Application.feedVideoControllerLists.first.play();
            }
            print('当前控制器：：：${controller.hashCode}');
            if (controller != null && controller.isPlaying()) {
              controller.pause();
            }
          }
          print("控制器长度：：：：${Application.feedVideoControllerList.length}");
          Application.feedVideoTimeList.forEach((element) {
            print("控制器存在的动态时间：：：：$element");
          });
        },
        child: controller == null
            ? Container(
                height: containerSize.height,
                width: containerSize.width,
                child: Stack(children: [
                  Positioned(
                    left: offsetX,
                    top: offsetY,
                    child: CachedNetworkImage(
                      imageUrl: FileUtil.getVideoFirstPhoto(widget.feedModel.videos.first.url),
                      width: videoSize.width,
                      height: videoSize.height,
                      fit: BoxFit.cover,
                      placeholder: (context, url) {
                        return Container(
                          color: AppColor.imageBgGrey,
                        );
                      },
                      errorWidget: (context, url, error) => Container(
                        color: AppColor.imageBgGrey,
                      ),
                    ),
                  ),
                  Positioned(
                      bottom: 0,
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
                        padding: const EdgeInsets.only(left: 2, right: 16),
                        alignment: Alignment(1, 0),
                        child: Text(
                          widget.durationString ?? "00 : 00",
                          style: const TextStyle(fontSize: 11, color: AppColor.white),
                        ),
                      ))
                ]))
            : Container(
                height: containerSize.height,
                width: containerSize.width,
                child: Stack(
                  children: [
                    Positioned(
                      left: offsetX,
                      top: offsetY,
                      child: GestureDetector(
                          onTap: () {
                            if (firstTapTimep == null) {
                              firstTapTimep = DateTime.now().millisecondsSinceEpoch;
                              streamHeight.sink.add(40.0);
                              // 延迟器:
                              new Future.delayed(Duration(seconds: 3), () {
                                streamHeight.sink.add(0.0);
                                firstTapTimep = null;
                              });
                            }
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
                          )),
                    ),
                    // controller.isVideoInitialized() ?
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
                                    padding: const EdgeInsets.only(left: 2, right: 16),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        StreamBuilder<bool>(
                                            initialData: controller.videoPlayerController.value.volume > 0,
                                            stream: streamController.stream,
                                            builder: (BuildContext stramContext, AsyncSnapshot<bool> snapshot) {
                                              return GestureDetector(
                                                behavior: HitTestBehavior.opaque,
                                                onTap: () {
                                                  if (controller.videoPlayerController.value.volume > 0) {
                                                    AppPrefs.setVideoSoundSwitch(false);
                                                    controller.setVolume(0.0);
                                                  } else {
                                                    AppPrefs.setVideoSoundSwitch(true);
                                                    controller.setVolume(1.0);
                                                  }
                                                  streamController.sink
                                                      .add(controller.videoPlayerController.value.volume > 0);
                                                },
                                                child: AppIcon.getAppIcon(
                                                  snapshot.data == false ? AppIcon.volume_off_16 : AppIcon.volume_on_16,
                                                  16,
                                                  color: AppColor.white,
                                                  containerHeight: 44,
                                                  containerWidth: 44,
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
                    // : Container()
                  ],
                ),
              ));
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
