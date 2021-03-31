import 'dart:io';

import 'package:better_player/better_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/constants.dart';
import 'package:mirror/data/model/media_file_model.dart';
import 'package:mirror/util/file_util.dart';

/// feed_video_player
/// Created by yangjiayi on 2021/1/11.

class FeedVideoPlayer extends StatefulWidget {
  final String url;
  final SizeInfo sizeInfo;
  final double width;
  final bool isInListView;
  final bool isFile;
  final String thumbPath;

  FeedVideoPlayer(this.url, this.sizeInfo, this.width,
      {Key key, this.isInListView = false, this.isFile = false, this.thumbPath})
      : super(key: key);

  @override
  _FeedVideoPlayerState createState() => _FeedVideoPlayerState();
}

class _FeedVideoPlayerState extends State<FeedVideoPlayer> {
  Size containerSize;
  Size videoSize;
  double offsetX;
  double offsetY;

  BetterPlayerListVideoPlayerController listController;
  BetterPlayerController controller;
  BetterPlayerDataSource dataSource;
  BetterPlayerConfiguration configuration;
  Function(BetterPlayerEvent) eventListener;
  Function(double visibilityFraction) playerVisibilityChangedBehavior;

  @override
  void initState() {
    print("初始化更好的播放器");
    _calculateSize();

    super.initState();

    if (widget.isFile) {
      dataSource = BetterPlayerDataSource.file(widget.url);
    } else {
      dataSource = BetterPlayerDataSource.network(widget.url);
    }

    eventListener = (BetterPlayerEvent event) {
      print("event: ${event.betterPlayerEventType}, params: ${event.parameters}");
      switch (event.betterPlayerEventType) {
        case BetterPlayerEventType.initialized:
          listController?.setVolume(0);
          controller?.setVolume(0);
          break;
        default:
          break;
      }
    };

    playerVisibilityChangedBehavior = (double visibility) {
      print("打印可见度 $visibility");
    };
    configuration = BetterPlayerConfiguration(
        // 如果不加上这个比例，在播放本地视频时宽高比不正确
        aspectRatio: videoSize.width / videoSize.height,
        eventListener: eventListener,
        playerVisibilityChangedBehavior: playerVisibilityChangedBehavior,
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
                height: videoSize.height,
              ),
        controlsConfiguration: BetterPlayerControlsConfiguration(
            // 取消全屏按钮
            enableFullscreen: false,
            // tab背景颜色
            controlBarColor:AppColor.transparent,
            /*
            要禁用更多按钮就需要把更多内的功能全部取消掉
             */
            // 标记，用于显示/隐藏溢出菜单，其中包含播放，字幕，质量选项。
            enableOverflowMenu: false,
            ///用于显示/隐藏播放速度的标志
            enablePlaybackSpeed: false,
            ///用于显示/隐藏字幕的标志
            enableSubtitles: false,
            ///标记用于显示/
            enableQualities: false,
            ///用于显示/隐藏画中画模式的标志
            enablePip: false,
            ///用于启用/禁用重试功能的标志
            enableRetry: false,
            ///用于显示/隐藏音轨的标志
            enableAudioTracks: false));

    if (widget.isInListView) {
      listController = BetterPlayerListVideoPlayerController();
    } else {
      controller = BetterPlayerController(configuration, betterPlayerDataSource: dataSource);
    }
  }

  @override
  void dispose() {
    print("销毁更好的播放器页面了");
    super.dispose();
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
        children: [
          Positioned(
            left: offsetX,
            top: offsetY,
            child: SizedBox(
              width: videoSize.width,
              height: videoSize.height,
              child: widget.isInListView
                  ? BetterPlayerListVideoPlayer(
                      dataSource,
                      betterPlayerListVideoPlayerController: listController,
                      configuration: configuration,
                      playFraction:
                          0.95 * containerSize.width * containerSize.height / (videoSize.width * videoSize.height),
                    )
                  : BetterPlayer(
                      controller: controller,
                    ),
            ),
          ),
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
