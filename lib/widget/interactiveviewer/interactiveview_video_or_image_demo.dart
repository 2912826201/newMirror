import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:video_player/video_player.dart';

class DemoSourceEntity {
  int heroId;
  String url;
  String previewUrl;
  String type;
  int height;
  int width;
  int duration;

  DemoSourceEntity(this.heroId, this.type, this.url, {this.previewUrl, this.width, this.height, this.duration});

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["heroId"] = heroId;
    map["url"] = url;
    map["previewUrl"] = previewUrl;
    map["type"] = type;
    return map;
  }

  @override
  String toString() {
    // TODO: implement toString
    return toJson().toString();
  }
}

class DemoImageItem extends StatefulWidget {
  final DemoSourceEntity source;

  DemoImageItem(this.source);

  @override
  _DemoImageItemState createState() => _DemoImageItemState();
}

class _DemoImageItemState extends State<DemoImageItem> {
  @override
  void initState() {
    super.initState();
    print('initState: ${widget.source.heroId}');
  }

  @override
  void dispose() {
    super.dispose();
    print('dispose: ${widget.source.heroId}');
  }

  @override
  Widget build(BuildContext context) {
    print("图片Item:${widget.source.url}");
    return Stack(
      children: <Widget>[
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
        ),
        Align(
          alignment: Alignment.center,
          child: Hero(
            tag: widget.source.heroId,
            child: CachedNetworkImage(
              placeholder: (context, url) {
                return Image.network(
                  FileUtil.getImageSlim(widget.source.url),
                  fit: BoxFit.cover,
                );
              },

              /// imageUrl的淡入动画的持续时间。
              fadeInDuration: Duration(milliseconds: 0),
              useOldImageOnUrlChange: true,
              fit: BoxFit.cover,
              imageUrl: widget.source.url != null ? widget.source.url : "",
              errorWidget: (context, url, error) => Container(
                color: AppColor.bgWhite,
              ),
            ),
            // child: CachedNetworkImage(
            //   imageUrl: widget.source.url,
            //   fit: BoxFit.contain,
            // ),
          ),
        ),
      ],
    );
  }
}

class DemoVideoItem extends StatefulWidget {
  final DemoSourceEntity source;
  final bool isFocus;

  DemoVideoItem(this.source, {this.isFocus});

  @override
  _DemoVideoItemState createState() => _DemoVideoItemState();
}

class _DemoVideoItemState extends State<DemoVideoItem> {
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
    print('initState: ${widget.source.heroId}');
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
    print('dispose: ${widget.source.heroId}');
    _controller.removeListener(listener);
    _controller?.pause();
    _controller?.dispose();
  }

  @override
  void didUpdateWidget(covariant DemoVideoItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isFocus && !widget.isFocus) {
      // pause
      _controller?.pause();
    }
  }

// 计算长宽比
  double setAspectRatio() {
    double videoWidth = ScreenUtil.instance.width;
    return (videoWidth / widget.source.width) * widget.source.height;
    if (widget.source.height > widget.source.width) {
      return (widget.source.height / widget.source.width);
    } else {
      return (widget.source.width / widget.source.height);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.initialized
        ? Stack(
            alignment: Alignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _controller.value.isPlaying ? _controller.pause() : _controller.play();
                  });
                },
                child: Hero(
                  tag: widget.source.heroId,
                  child: Container(
                    width: ScreenUtil.instance.width,
                    height: setAspectRatio(),
                    // child: AspectRatio(
                    //   aspectRatio: widget.source.height > widget.source.width ? _controller.value.aspectRatio : setAspectRatio(),
                    child: VideoPlayer(_controller),
                    // )
                  ),
                ),
              ),
              _controller.value.isPlaying == true
                  ? const SizedBox()
                  : const IgnorePointer(
                      ignoring: true,
                      child: Icon(
                        Icons.play_arrow,
                        size: 100,
                        color: Colors.white,
                      ),
                    ),
            ],
          )
        : Theme(
            data: ThemeData(cupertinoOverrideTheme: CupertinoThemeData(brightness: Brightness.dark)),
            child: CupertinoActivityIndicator(radius: 30));
  }
}
