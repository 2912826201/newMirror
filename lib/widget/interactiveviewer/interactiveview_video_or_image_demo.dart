import 'dart:async';
import 'dart:io';

import 'package:better_player/better_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/util/date_util.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/string_util.dart';
import 'package:mirror/widget/icon.dart';
import 'package:mirror/widget/seekbar.dart';
import 'package:video_player/video_player.dart';


class DemoSourceEntity {
  String heroId;
  String url;
  String previewUrl;
  String type;
  double height;
  double width;
  int duration;
  String imageFilePath;
  String videoImageFilePath;
  String videoFilePath;
  bool isTemporary;

  DemoSourceEntity(this.heroId, this.type, this.url,
      {this.previewUrl,
        this.width,
        this.height,
        this.duration,
        this.isTemporary=false,
      });

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
  final bool isFocus;
  final int index;
  final Function(Function(bool isFocus),int) setFocus;

  DemoImageItem(this.source,this.isFocus,this.index,this.setFocus);

  @override
  _DemoImageItemState createState() => _DemoImageItemState(isFocus);
}

class _DemoImageItemState extends State<DemoImageItem> {
  bool isFocus=false;


  _DemoImageItemState(this.isFocus);

  setFocus(bool isFocus){
    this.isFocus=isFocus;
    if(mounted) {
      setState(() {

      });
    }
  }


  @override
  void initState() {
    super.initState();
    widget.setFocus(setFocus,widget.index);
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
            tag: isFocus?widget.source.heroId:"",
            child: getImageUi(),
            // child: CachedNetworkImage(
            //   imageUrl: widget.source.url,
            //   fit: BoxFit.contain,
            // ),
          ),
        ),
      ],
    );
  }

  //获取图片的展示
  Widget getImageUi() {

    if(widget.source.imageFilePath!=null&&widget.source.imageFilePath.length>0){
      File imageFile = File(widget.source.imageFilePath);
      if (imageFile.existsSync()) {
        return getImageFile(imageFile);
      }
    }

    if(widget.source.url==null){
      return getErrorWidgetImage();
    }
    String imagePath=FileUtil.getImageSlim(widget.source.url);
    // String imagePath=widget.source.url;
    if(FileUtil.isHaveChatImageFile(imagePath)){
      print("有:$imagePath");
      File imageFile = File(FileUtil.getChatImagePath(imagePath));
      return getImageFile(imageFile);
    }else{
      print("没有:$imagePath");
      return getCachedNetworkImage(imagePath);
    }
  }

  Widget getImageFile(File file) {
    return Image.file(
      file,
      fit: BoxFit.cover,
    );
  }

  Widget getCachedNetworkImage(String imageUrl) {
    return CachedNetworkImage(
      imageUrl: imageUrl ?? "",
      fit: BoxFit.cover,
      fadeInDuration: Duration(milliseconds: 0),
      placeholder: (context, url) => getPlaceholderImage(),
      errorWidget: (context, url, error) => getErrorWidgetImage(),
    );
  }

  Widget getPlaceholderImage(){
    String imageSlimPath=FileUtil.getImageSlim(widget.source.url);
    if(FileUtil.isHaveChatImageFile(imageSlimPath)){
      File imageFile = File(FileUtil.getChatImagePath(imageSlimPath));
      return getImageFile(imageFile);
    }else{
      return getErrorWidgetImage();
    }
  }

  Widget getErrorWidgetImage() {
    return Container(
      color: AppColor.black,
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
  final int index;
  final Function(Function(bool isFocus),int) setFocus;
  DemoVideoItem2(this.source,this.isFocus,this.index,this.setFocus);

  @override
  _DemoVideoItem2State createState() => _DemoVideoItem2State(isFocus);
}

class _DemoVideoItem2State extends State<DemoVideoItem2> {
  BetterPlayerController controller;
  BetterPlayerDataSource dataSource;
  BetterPlayerConfiguration configuration;
  Function(BetterPlayerEvent) eventListener;
  bool isShowController = false;
  bool isPlaying = true;
  bool isFocus = true;
  String sourceUrl;


  _DemoVideoItem2State(this.isFocus);


  setFocus(bool isFocus){
    print("123546213");
    this.isFocus=isFocus;
    if(isFocus){
      if(controller!=null) {
        if (controller.isVideoInitialized()) {
          controller.play();
          resetControllerListener();
        }
      }else{
        init();
      }
    }else{
      if(controller!=null) {
        if (controller.isVideoInitialized()) {
          controller.pause();
          controller.dispose();
          controller = null;
          resetControllerListener();
          if(mounted){
            setState(() {});
          }
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getSourceUrl();
    print('initStatevideo: ${sourceUrl}');
    widget.setFocus(setFocus,widget.index);
    if(isFocus) {
      init();
    }
  }

  @override
  void dispose() {
    super.dispose();
    try{
      if(controller!=null) {
        controller.dispose();
        controller = null;
      }
    }catch (e){

    }
  }

  init() async {
    print("widget.source.url:$sourceUrl");
    dataSource = BetterPlayerDataSource.network(sourceUrl);
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
          print("初始化完成");
          setState(() {
            if(isFocus){
              controller.play();
            }
          });
          break;
        default:
          break;
      }
    };
    configuration = BetterPlayerConfiguration(
        // 如果不加上这个比例，在播放本地视频时宽高比不正确
        aspectRatio: ScreenUtil.instance.width / setAspectRatio(),
        autoPlay: false,
        eventListener: eventListener,
        looping: true,
        //定义按下播放器时播放器是否以全屏启动
        fullScreenByDefault: false,
        placeholder: getPlaceholder(),
        controlsConfiguration: BetterPlayerControlsConfiguration(
          showControls: false,
          // enableSkips:false,
          // enableMute:false,
          // enableFullscreen:false,
          // controlBarColor:AppColor.transparent,
        ));
    controller = BetterPlayerController(configuration, betterPlayerDataSource: dataSource);
  }


// 计算长宽比
  double setAspectRatio() {
    if(widget.source.width==null||widget.source.width<1){
      return ScreenUtil.instance.height;
    }
    if(widget.source.height==null||widget.source.height<1){
      return ScreenUtil.instance.height;
    }
    double videoWidth = ScreenUtil.instance.width;
    return (videoWidth / widget.source.width) * widget.source.height;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppColor.black,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: ScreenUtil.instance.width,
              height: ScreenUtil.instance.height,
              color: AppColor.black,
            ),
            Hero(
              tag: isFocus ? widget.source.heroId : "",
              child: Container(
                width: ScreenUtil.instance.width,
                height: setAspectRatio(),
                child: controller != null && controller.isVideoInitialized()
                    ? BetterPlayer(
                        controller: controller,
                      )
                    : getPlaceholder(),
                // )
              ),
            ),
            getOccludeUi(),
            Container(
              width: ScreenUtil.instance.width,
              height: ScreenUtil.instance.height,
              child: controller != null && controller.isVideoInitialized()
                  ? VideoControl(
                      setVideoPlayProgress,
                      onDragCompletedListener,
                      setPlayOrPause,
                      isShowController,
                      setShowController,
                      controller,
                      resetController,
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

  Function() resetControllerListener;

  resetController(Function() function){
    resetControllerListener=function;
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

  Widget getPlaceholder(){
    if(StringUtil.isURL(widget.source.url)){
      print("getPlaceholder:${FileUtil.getVideoFirstPhoto(sourceUrl)}");
      return CachedNetworkImage(
          imageUrl: FileUtil.getVideoFirstPhoto(sourceUrl),
          width: ScreenUtil.instance.width,
          height: setAspectRatio(),
          fadeInDuration: Duration.zero,
          placeholder: (context, url) {
            return Container(
              color: AppColor.black,
            );
          },
          errorWidget: (context, url, error) {
            return Container(
              width: ScreenUtil.instance.width,
              height: ScreenUtil.instance.height,
              color: AppColor.color343434,
              alignment: Alignment.center,
              child: getImageAsset("assets/png/image_error.png"),
            );
          }
      );
    }else if(widget.source.videoImageFilePath!=null){
      print("getPlaceholder:${widget.source.videoImageFilePath}");
      File videoImageFile = File(widget.source.videoImageFilePath);
      if (videoImageFile.existsSync()) {
        return Image.file(
          videoImageFile,
          fit: BoxFit.cover,
        );
      } else {
        return Container(color: AppColor.black);
      }
    } else {
      print("getPlaceholder:null}");
      return Container(color: AppColor.black);
    }
  }

  Widget getImageAsset(String assetPath) {
    //print("assetPath:${assetPath}");
    return UnconstrainedBox(
      child: Image.asset(
        assetPath ?? "",
        width: ScreenUtil.instance.width * 0.426,
        height: ScreenUtil.instance.width * 0.426,
        fit: BoxFit.cover,
      ),
    );
  }

  void getSourceUrl() {
    if (StringUtil.isURL(widget.source.url)) {
      sourceUrl = widget.source.url;
    } else if (widget.source.videoFilePath != null) {
      File videoFile = File(widget.source.videoFilePath);
      if (videoFile.existsSync()) {
        sourceUrl = widget.source.videoFilePath;
      } else {
        sourceUrl = "";
      }
    } else {
      sourceUrl = "";
    }
  }
}

class VideoControl extends StatefulWidget {
  final Function(Function(BetterPlayerEvent event)) setVideoPlayProgress;
  final Function(Function()) resetController;
  final Function onDragCompletedListener;
  final Function setPlayOrPause;
  final Function setShowController;
  final bool isShowController;
  final BetterPlayerController controller;

  VideoControl(
    this.setVideoPlayProgress,
    this.onDragCompletedListener,
    this.setPlayOrPause,
    this.isShowController,
    this.setShowController,
    this.controller,
    this.resetController,
  );

  @override
  _VideoControlState createState() => _VideoControlState(isShowController,controller.isPlaying());
}

class _VideoControlState extends State<VideoControl> {
  double maxValue = 100;
  double value = 0;
  String progressString = "00:00";
  String durationString = "00:00";
  bool isDragging = false;
  bool isPlaying = false;
  bool isShowController = false;

  _VideoControlState(this.isShowController,this.isPlaying);

  @override
  void initState() {
    super.initState();
    widget.setVideoPlayProgress(setVideoPlayProgress);
    widget.resetController(resetControllerListener);
    iniTimeShowController();
  }


  resetControllerListener(){
    if(widget.controller!=null) {
      this.isPlaying = widget.controller.isPlaying();
    }else{
      this.isPlaying=false;
    }
    if(mounted){
      setState(() {

      });
    }
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
                        pngName: "assets/png/play_circle_48.png",
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
          Container(
            height: ScreenUtil.instance.bottomBarHeight,
            width: ScreenUtil.instance.width,
            color: AppColor.transparent,
          ),
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
    bool isNullValue=false;
    event.parameters.forEach((key, value) {
      if(value==null){
        isNullValue=true;
        return;
      }
      switch (key) {
        case "progress":
          progress = (value as Duration).inSeconds.toDouble()+1;
          break;
        case "duration":
          maxValue = (value as Duration).inSeconds.toDouble();
          break;
      }
    });

    if(isNullValue){
      return;
    }
    setProgress(progress, maxValue);
  }

  setProgress(double progress, double maxValue) {
    if (progress == null || maxValue == null) {
      return;
    }
    this.progressString = DateUtil.formatSecondToStringNumShowMinute1(progress.toInt());
    this.durationString = DateUtil.formatSecondToStringNumShowMinute1(maxValue.toInt());
    value = progress / maxValue * 100;
    if (value >= 100) value = 100;
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
