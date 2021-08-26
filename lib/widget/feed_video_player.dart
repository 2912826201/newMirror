import 'dart:async';
import 'dart:io';

import 'package:better_player/better_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
import 'package:mirror/util/file_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:provider/provider.dart';


import 'better_player_list_video/better_player_list_video_player_dont_keep_state.dart';
import 'icon.dart';

/// feed_video_player
/// Created by yangjiayi on 2021/1/11.

class FeedVideoPlayer extends StatefulWidget {
  final String url;
  final SizeInfo sizeInfo;
  final double width;
  final bool isInListView;
  final bool isFile;
  final String thumbPath;
  final String durationString;
  final HomeFeedModel model;
  final int index;

  FeedVideoPlayer(this.url, this.sizeInfo, this.width,
      {Key key,
      this.isInListView = false,
      this.isFile = false,
      this.thumbPath,
      this.durationString,
      this.model,
      this.index,
      })
      : super(key: key);

  @override
  _FeedVideoPlayerState createState() => _FeedVideoPlayerState();
}

class _FeedVideoPlayerState extends State<FeedVideoPlayer> {
  Size containerSize;
  Size videoSize;
  double offsetX;
  double offsetY;

  bool isMute = false;

  // 控件显示
  double initHeight = 0;
  BetterPlayerListVideoPlayerController listController;
  BetterPlayerController controller;
  BetterPlayerDataSource dataSource;
  BetterPlayerConfiguration configuration;
  Function(BetterPlayerEvent) eventListener;

  // Function(double visibilityFraction) playerVisibilityChangedBehavior;

  // 开启关闭音量的监听
  StreamController<bool> streamController = StreamController<bool>();
  StreamController<double> streamHeight = StreamController<double>();
  // 是否可点赞
  bool isSetUpLuad = true;
  @override
  void initState() {
    print("初始化更好的播放器");
    _calculateSize();
    super.initState();
    init();
  }




  init(){

    if (widget.isFile) {
      dataSource = BetterPlayerDataSource.file(widget.url);
    } else {
      dataSource = BetterPlayerDataSource.network(widget.url);
      if (mounted) {
        setState(() {});
      }
    }

    eventListener = (BetterPlayerEvent event) {
      // print("event: ${event.betterPlayerEventType}, params: ${event.parameters}");

      switch (event.betterPlayerEventType) {
        case BetterPlayerEventType.initialized:
          listController?.setVolume(0);
          controller?.setVolume(0);
          break;
        default:
          break;
      }
    };

    // playerVisibilityChangedBehavior = (double visibility) {
    //   print("打印可见度 $visibility");
    // };
    configuration = BetterPlayerConfiguration(
      // 如果不加上这个比例，在播放本地视频时宽高比不正确
        aspectRatio: videoSize.width / videoSize.height,
        eventListener: eventListener,
        autoPlay: !widget.isInListView,
        looping: true,
        //定义按下播放器时播放器是否以全屏启动
        fullScreenByDefault: false,
        placeholder: widget.isFile
            ? widget.thumbPath == null
            ? Container()
            : Image.file(
          File(widget.thumbPath),
          width: videoSize.width,
          height: videoSize.height,
        )
            : CachedNetworkImage(
          imageUrl: FileUtil.getVideoFirstPhoto(widget.url),
                width: videoSize.width,
                useOldImageOnUrlChange: true,
                height: videoSize.height,
                placeholder: (context, url) {
                  return Container(
                    color: AppColor.textWhite60,
                  );
                },
                errorWidget: (context, url, error) => Container(
                  color: AppColor.textWhite60,
                ),
              ),
        controlsConfiguration: BetterPlayerControlsConfiguration(
          showControls: false,
          // // 取消全屏按钮
          // enableFullscreen: false,
          //
          // ///用于启用/禁用静音的标志
          // enableMute: false,
          //
          // ///用于启用/禁用进度文本的标记
          // enableProgressText: false,
          //
          // ///用于启用/禁用进度条的标志
          // enableProgressBar: false,
          //
          // ///标记用于启用/禁用进度栏拖动
          // enableProgressBarDrag: false,
          //
          // ///标记用于启用/禁用播放暂停
          // enablePlayPause: false,
          //
          // ///标记用于启用前进和后退
          // enableSkips: false,
          //
          // ///标记，用于显示init上的控件
          // showControlsOnInitialize: false,
          // // tab背景颜色
          // controlBarColor: AppColor.transparent,
          // /*
          // 要禁用更多按钮就需要把更多内的功能全部取消掉
          //  */
          // // 标记，用于显示/隐藏溢出菜单，其中包含播放，字幕，质量选项。
          // enableOverflowMenu: false,
          //
          // ///用于显示/隐藏播放速度的标志
          // enablePlaybackSpeed: false,
          //
          // ///用于显示/隐藏字幕的标志
          // enableSubtitles: false,
          //
          // ///标记用于显示/
          // enableQualities: false,
          //
          // ///用于显示/隐藏画中画模式的标志
          // enablePip: false,
          //
          // ///用于启用/禁用重试功能的标志
          // enableRetry: false,
          //
          // ///用于显示/隐藏音轨的标志
          // enableAudioTracks: false
        ));

    if (widget.isInListView) {
      // listController = BetterPlayerListVideoPlayerController();
    } else {
      controller = BetterPlayerController(configuration, betterPlayerDataSource: dataSource);
    }
  }


  @override
  void deactivate() {
    // TODO: implement deactivate
    super.deactivate();
    print("销毁更好的播放器页面了");
    controller?.removeEventsListener(eventListener);
  }

  @override
  void dispose() {
    streamController.close();
    streamHeight.close();
    super.dispose();
  }

// 点赞
  setUpLuad() async {
    bool isLoggedIn = context.read<TokenNotifier>().isLoggedIn;
    if (isLoggedIn) {
      if(isSetUpLuad) {
        isSetUpLuad = false;
        BaseResponseModel model = await laud(id: widget.model.id, laud: widget.model.isLaud == 0 ? 1 : 0);
        print('===================================model.code==${model.code}');
        // 点赞/取消赞成功
        if (model.code == CODE_BLACKED) {
          ToastShow.show(msg: "你已被对方加入黑名单，成为好友才能互动哦~", context: context, gravity: Toast.CENTER);
        } else {
          context.read<FeedMapNotifier>().setLaud(
              context
                  .read<FeedMapNotifier>()
                  .value
                  .feedMap[widget.model.id].isLaud == 0 ? 1 : 0,
              context
                  .read<ProfileNotifier>()
                  .profile
                  .avatarUri,
              widget.model.id);
          context
              .read<UserInteractiveNotifier>()
              .laudedChange(widget.model.pushId, context
              .read<FeedMapNotifier>()
              .value
              .feedMap[widget.model.id].isLaud);
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
    return Container(
      height:
          // videoSize.height,
          containerSize.height,
      width:
          // videoSize.width ,
          containerSize.width,
      child: Stack(
        // overflow: Overflow.visible ,
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
                  int isLaud = context.read<FeedMapNotifier>().value.feedMap[widget.model.id].isLaud;
                  print("isLaud:::$isLaud");
                  if (isLaud != 1) {
                    setUpLuad();
                  }
                },
                child: SizedBox(
                  width: videoSize.width,
                  // videoSize.width,
                  height: videoSize.height,
                  // videoSize.height,
                  child: widget.isInListView
                      ?
                  BetterPlayerListVideoPlayerDontKeep(
                          dataSource,
                          // betterPlayerListVideoPlayerController: listController,
                          configuration: configuration,
                          playFraction:
                              0.95 * containerSize.width * containerSize.height / (videoSize.width * videoSize.height),
                          index: widget.index,
                          modelId: widget.model.id,
                        )
                      : BetterPlayer(
                          controller: controller,
                        ),
                ),
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
                          padding: const EdgeInsets.only(left: 4, right: 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              StreamBuilder<bool>(
                                  initialData: isMute,
                                  stream: streamController.stream,
                                  builder: (BuildContext stramContext, AsyncSnapshot<bool> snapshot) {
                                    return GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () {
                                          isMute = !isMute;
                                          streamController.sink.add(isMute);
                                          if (isMute == false) {
                                            listController.setVolume(0.0);
                                          } else {
                                            listController.setVolume(1.0);
                                          }
                                        },
                                        child: Container(
                                          height: 40,
                                          width: 40,
                                          child: Center(
                                              child: AppIconButton(
                                            svgName:
                                                snapshot.data == false ? AppIcon.volume_off_16 : AppIcon.volume_on_16,
                                            iconSize: 16,
                                          )),
                                        ));
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
    double containerWidth = widget.width;
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
