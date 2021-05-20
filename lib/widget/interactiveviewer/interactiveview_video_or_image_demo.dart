import 'dart:async';

import 'package:better_player/better_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/util/date_util.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/icon.dart';
import 'package:mirror/widget/seekbar.dart';
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

  // 计算长宽比
  double setAspectRatio() {
    double videoWidth = ScreenUtil.instance.width;
    print(videoWidth);
    print(widget.source.width);
    print(ScreenUtil.instance.height);
    print(widget.source.height);
    print((videoWidth / widget.source.width) * widget.source.height);
    return (videoWidth / widget.source.width) * widget.source.height;
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
    await _controller.initialize().then((value) {
      _controller.play();
      setState(() {});
    });
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
  }

  @override
  Widget build(BuildContext context) {
    return
        // _controller.value.initialized
        //   ?
        Stack(
      alignment: Alignment.center,
      children: [
        Hero(
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
      ],
    );
    // : CachedNetworkImage(
    //     imageUrl: FileUtil.getVideoFirstPhoto(widget.source.url),
    //     width: ScreenUtil.instance.width,
    //     height: setAspectRatio(),
    //     placeholder: (context, url) {
    //       return Container(
    //         color: AppColor.bgWhite,
    //       );
    //     },
    //     errorWidget: (context, url, error) => Container(
    //       color: AppColor.bgWhite,
    //     ),
    //   );
    // : Theme(
    //     data: ThemeData(cupertinoOverrideTheme: CupertinoThemeData(brightness: Brightness.dark)),
    //     child: CupertinoActivityIndicator(radius: 30));
  }
}

class DemoVideoItem2 extends StatefulWidget {
  final DemoSourceEntity source;
  final bool isFocus;

  DemoVideoItem2(this.source, {this.isFocus});

  @override
  _DemoVideoItem2State createState() => _DemoVideoItem2State();
}

class _DemoVideoItem2State extends State<DemoVideoItem2> {
  BetterPlayerController controller;
  BetterPlayerDataSource dataSource;
  BetterPlayerConfiguration configuration;
  Function(BetterPlayerEvent) eventListener;
  bool isShowController = false;
  bool isPlaying = true;

  // _DemoVideoItem2State() {
  //
  // }

  @override
  void initState() {
    super.initState();
    print('initState: ${widget.source.heroId}');
    init();
  }

  init() async {
    dataSource = BetterPlayerDataSource.network(widget.source.url);
    eventListener = (BetterPlayerEvent event) {
      if (!mounted) {
        return;
      }

      if (betterPlayerEventListener != null) {
        betterPlayerEventListener(event);
      }
      // event.parameters.forEach((key, value) {
      //   print("value:$key,$value,${value is Duration}");
      // });

      // print("BetterPlayerEvent:${event.parameters.toString()}");

      switch (event.betterPlayerEventType) {
        case BetterPlayerEventType.initialized:
          setState(() {});
          break;
        default:
          break;
      }
    };
    configuration = BetterPlayerConfiguration(
        // 如果不加上这个比例，在播放本地视频时宽高比不正确
        aspectRatio: ScreenUtil.instance.width / setAspectRatio(),
        autoPlay: true,
        eventListener: eventListener,
        looping: true,
        //定义按下播放器时播放器是否以全屏启动
        fullScreenByDefault: false,
        placeholder: CachedNetworkImage(
          imageUrl: FileUtil.getVideoFirstPhoto(widget.source.url),
          width: ScreenUtil.instance.width,
          height: setAspectRatio(),
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
          // enableSkips:false,
          // enableMute:false,
          // enableFullscreen:false,
          // controlBarColor:AppColor.transparent,
        ));
    controller = BetterPlayerController(configuration, betterPlayerDataSource: dataSource);
  }

  @override
  void dispose() {
    super.dispose();
  }

// 计算长宽比
  double setAspectRatio() {
    double videoWidth = ScreenUtil.instance.width;
    return (videoWidth / widget.source.width) * widget.source.height;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Hero(
            tag: widget.source.heroId,
            child: Container(
              width: ScreenUtil.instance.width,
              height: setAspectRatio(),
              child: controller.isVideoInitialized()
                  ? BetterPlayer(
                      controller: controller,
                    )
                  : CachedNetworkImage(
                      imageUrl: FileUtil.getVideoFirstPhoto(widget.source.url),
                      width: ScreenUtil.instance.width,
                      height: setAspectRatio(),
                      placeholder: (context, url) {
                        return Container(
                          color: AppColor.bgWhite,
                        );
                      },
                      errorWidget: (context, url, error) => Container(
                        color: AppColor.bgWhite,
                      ),
                    ),
              // )
            ),
          ),
          getOccludeUi(),
          Container(
            width: ScreenUtil.instance.width,
            height: ScreenUtil.instance.height,
            child: controller.isVideoInitialized()
                ? VideoControl(
                    setVideoPlayProgress,
                    onDragCompletedListener,
                    setPlayOrPause,
                    isShowController,
                    setShowController,
                  )
                : Container(),
          ),
          Positioned(
            left: 0,
            top: ScreenUtil.instance.statusBarHeight - 6,
            child: Visibility(
              visible: isShowController,
              child: AppIconButton(
                iconSize: 24,
                svgName: AppIcon.close_24,
                buttonHeight: 40,
                buttonWidth: 40,
                iconColor: AppColor.white,
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
        ],
      ),
      // body: GestureDetector(
      //   onTap: (){
      //     isShowController=!isShowController;
      //     showControllerCount=0;
      //     setState(() {
      //
      //     });
      //   },
      //   child: ,
      // ),
    );
  }

  setShowController(bool isShowController) {
    this.isShowController = isShowController;
    setState(() {});
  }

  Function(BetterPlayerEvent event) betterPlayerEventListener;

  setVideoPlayProgress(Function(BetterPlayerEvent event) function) {
    betterPlayerEventListener = function;
  }

  onDragCompletedListener(Duration moment) {
    controller.seekTo(moment);
  }

  setPlayOrPause(bool isPlaying) {
    this.isPlaying = isPlaying;
    if (isPlaying) {
      controller.play();
    } else {
      controller.pause();
    }
  }

  //遮挡
  Widget getOccludeUi() {
    return Container(
      width: ScreenUtil.instance.width,
      height: ScreenUtil.instance.height,
      color: AppColor.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            height: 64,
            width: ScreenUtil.instance.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColor.textPrimary1.withOpacity(0.35),
                  AppColor.textPrimary1.withOpacity(0.001),
                ],
              ),
            ),
          ),
          Container(
            height: 64,
            width: ScreenUtil.instance.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColor.textPrimary1.withOpacity(0.001),
                  AppColor.textPrimary1.withOpacity(0.35),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class VideoControl extends StatefulWidget {
  final Function(Function(BetterPlayerEvent event)) setVideoPlayProgress;
  final Function onDragCompletedListener;
  final Function setPlayOrPause;
  final Function setShowController;
  final bool isShowController;

  VideoControl(
    this.setVideoPlayProgress,
    this.onDragCompletedListener,
    this.setPlayOrPause,
    this.isShowController,
    this.setShowController,
  );

  @override
  _VideoControlState createState() => _VideoControlState(isShowController);
}

class _VideoControlState extends State<VideoControl> {
  double maxValue = 100;
  double value = 0;
  String progressString = "00:00";
  String durationString = "00:00";
  bool isDragging = false;
  bool isPlaying = true;
  bool isShowController = false;

  _VideoControlState(this.isShowController);

  @override
  void initState() {
    super.initState();
    widget.setVideoPlayProgress(setVideoPlayProgress);
    iniTimeShowController();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ScreenUtil.instance.width,
      height: ScreenUtil.instance.height,
      child: Column(
        children: [
          Expanded(
            child: SizedBox(
              child: GestureDetector(
                onTap: () {
                  if (isPlaying) {
                    isShowController = !isShowController;
                    widget.setShowController(isShowController);
                    setState(() {});
                  }
                },
                child: Container(
                  color: AppColor.transparent,
                  child: Center(
                    child: Visibility(
                      visible: !isPlaying,
                      child: AppIconButton(
                        iconSize: 48,
                        svgName: AppIcon.play_circle_48,
                        buttonHeight: 60,
                        buttonWidth: 60,
                        onTap: () {
                          isPlaying = !isPlaying;
                          try {
                            setState(() {});
                            if (widget.setPlayOrPause != null) {
                              widget.setPlayOrPause(isPlaying);
                            }
                          } catch (e) {
                            isPlaying = !isPlaying;
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Visibility(
              visible: isShowController,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  children: [
                    SizedBox(width: 12),
                    AppIconButton(
                      iconSize: 28,
                      svgName: isPlaying ? AppIcon.pause_28 : AppIcon.play_28,
                      buttonHeight: 30,
                      buttonWidth: 30,
                      iconColor: AppColor.white,
                      onTap: () {
                        isPlaying = !isPlaying;
                        try {
                          setState(() {});
                          if (widget.setPlayOrPause != null) {
                            widget.setPlayOrPause(isPlaying);
                          }
                        } catch (e) {
                          isPlaying = !isPlaying;
                        }
                      },
                    ),
                    SizedBox(width: 14),
                    Text(progressString, style: TextStyle(fontSize: 12, color: AppColor.white)),
                    SizedBox(width: 8),
                    Expanded(
                      child: AppSeekBar(
                        100,
                        0,
                        value,
                        false,
                        _onDragging,
                        _onDragCompleted,
                        activeDisabledTrackBarColor: AppColor.white.withOpacity(0.5),
                        inactiveDisabledTrackBarColor: AppColor.white,
                        inactiveTrackBarColor:AppColor.white.withOpacity(0.5),
                        activeTrackBarColor:AppColor.white,
                        handler1Color: AppColor.white,
                        handler2Color: AppColor.white,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(durationString, style: TextStyle(fontSize: 12, color: AppColor.white)),
                    SizedBox(width: 16),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  setVideoPlayProgress(BetterPlayerEvent event) {
    if (isDragging) {
      return;
    }
    if (event == null || event.parameters == null) {
      return;
    }
    double progress;
    double maxValue;
    event.parameters.forEach((key, value) {
      switch (key) {
        case "progress":
          progress = (value as Duration).inSeconds.toDouble()+1;
          break;
        case "duration":
          maxValue = (value as Duration).inSeconds.toDouble();
          break;
      }
    });

    setProgress(progress, maxValue);
  }

  setProgress(double progress, double maxValue) {
    if (progress == null || maxValue == null) {
      return;
    }
    this.progressString = DateUtil.formatSecondToStringNumShowMinute1(progress.toInt());
    this.durationString = DateUtil.formatSecondToStringNumShowMinute1(maxValue.toInt());
    value = progress / maxValue * 100;
    this.maxValue = maxValue;
    try {
      if (mounted) {
        setState(() {});
      }
    } catch (e) {}
  }

  _onDragging(int handlerIndex, dynamic lowerValue, dynamic upperValue) {
    isDragging = true;
    print("_onDragging:$handlerIndex,$lowerValue,$upperValue");
    setProgress(lowerValue / 100 * this.maxValue, this.maxValue);
  }

  _onDragCompleted(int handlerIndex, dynamic lowerValue, dynamic upperValue) {
    print("_onDragCompleted:$handlerIndex,$lowerValue,$upperValue");
    double progress = lowerValue / 100 * this.maxValue;
    setProgress(progress, this.maxValue);
    if (widget.onDragCompletedListener != null) {
      Duration moment = Duration(seconds: progress.toInt());
      widget.onDragCompletedListener(moment);
    }
    isDragging = false;
  }

  Timer _time;
  int showControllerCount = 0;

  iniTimeShowController() {
    _time = Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (isShowController) {
        if(isDragging){
          showControllerCount = 0;
        }else {
          if (isPlaying) {
            showControllerCount++;
            if (showControllerCount > 50) {
              if (isShowController) {
                isShowController = false;
                if (mounted) {
                  try {
                    setState(() {});

                    widget.setShowController(isShowController);
                  } catch (e) {}
                } else {
                  if (_time != null) {
                    _time.cancel();
                    _time = null;
                  }
                }
              }
            }
          } else {
            showControllerCount = 0;
          }
        }
      } else {
        if (!isPlaying) {
          isShowController = true;
          if (mounted) {
            try {
              setState(() {});

              widget.setShowController(isShowController);
            } catch (e) {}
          } else {
            if (_time != null) {
              _time.cancel();
              _time = null;
            }
          }
        }
        showControllerCount = 0;
      }
    });
  }
}
