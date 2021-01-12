import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/constants.dart';
import 'package:mirror/data/model/media_file_model.dart';
import 'package:mirror/util/file_util.dart';
import 'package:video_player/video_player.dart';

/// feed_video_player
/// Created by yangjiayi on 2021/1/11.

class FeedVideoPlayer extends StatefulWidget {
  final String url;
  final SizeInfo sizeInfo;
  final double width;

  FeedVideoPlayer(this.url, this.sizeInfo, this.width, {Key key}) : super(key: key);

  @override
  _FeedVideoPlayerState createState() => _FeedVideoPlayerState();
}

class _FeedVideoPlayerState extends State<FeedVideoPlayer> {
  Size containerSize;
  Size videoSize;
  double offsetX;
  double offsetY;

  VideoPlayerController _controller;

  @override
  void initState() {
    _calculateSize();
    super.initState();
    _controller = VideoPlayerController.network(widget.url)
      ..initialize().then((_) {
        setState(() {
          _controller.play();
        });
      });
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
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
            child: CachedNetworkImage(
              imageUrl: FileUtil.getVideoFirstPhoto(widget.url),
              width: videoSize.width,
              height: videoSize.height,
            ),
          ),
          Positioned(
            left: offsetX,
            top: offsetY,
            child: _controller != null && _controller.value.initialized
                ? SizedBox(
                    width: videoSize.width,
                    height: videoSize.height,
                    child: VideoPlayer(_controller),
                  )
                : Container(),
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
