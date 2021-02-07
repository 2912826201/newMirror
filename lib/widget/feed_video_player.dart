import 'package:better_player/better_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
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

  FeedVideoPlayer(this.url, this.sizeInfo, this.width, {Key key, this.isInListView = false, this.isFile = false})
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

  @override
  void initState() {
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
    configuration = BetterPlayerConfiguration(
        // 如果不加上这个比例，在播放本地视频时宽高比不正确
        aspectRatio: videoSize.width / videoSize.height,
        eventListener: eventListener,
        autoPlay: !widget.isInListView,
        looping: true,
        fullScreenByDefault: false,
        placeholder: CachedNetworkImage(
          imageUrl: FileUtil.getVideoFirstPhoto(widget.url),
          width: videoSize.width,
          height: videoSize.height,
        ),
        controlsConfiguration: BetterPlayerControlsConfiguration(showControls: false));

    if (widget.isInListView) {
      listController = BetterPlayerListVideoPlayerController();
    } else {
      controller = BetterPlayerController(configuration, betterPlayerDataSource: dataSource);
    }
  }

  @override
  void dispose() {
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
