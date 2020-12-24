import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:video_player/video_player.dart';

/// video_course_play_page
/// Created by yangjiayi on 2020/12/15.

//测试用数据结构
class Part {
  List<String> videoList;
  int duration;
  String name;
  int type; //0-课程 1-休息

  Part(this.videoList, this.duration, this.name, this.type);
}

class VideoCoursePlayPage extends StatefulWidget {
  @override
  _VideoCoursePlayState createState() => _VideoCoursePlayState();
}

class _VideoCoursePlayState extends State<VideoCoursePlayPage> {
  // final List<String> urls = [
  //   "http://devmedia.aimymusic.com/alita/51be47a088ff3858c29653fd16536a37.mp4",
  //   "http://devmedia.aimymusic.com/0313a2d9f77857d073102320b1a4893c.mp4",
  //   "http://devmedia.aimymusic.com/25e85ec9a9399023629d3fc15bcb8877.mp4",
  //   "http://devmedia.aimymusic.com/01e889ed5d0314abba48382d669b739b",
  // ];

  final List<String> assets = [
    "videos/1.mp4",
    "videos/2.mp4",
    "videos/3.mp4",
    "videos/4.mp4",
  ];

  final List<Part> partList = [
    Part([
      "videos/1.mp4",
      "videos/2.mp4",
    ], 50, "第一段多视频结束不休息", 0),
    Part([
      "videos/3.mp4",
    ], 55, "第二段单视频结束有休息", 0),
    Part([], 30, "休息", 1),
    Part(["videos/4.mp4"], 182, "第三段单视频结束后完成", 0),
  ];

  VideoPlayerController _controller;

  int _currentPlayingIndex = -1;

  double _progress = 0.0;
  int _videoDuration = 0;
  int _currentVideoPos;

  bool _isPlaying = false;

  VoidCallback _playerListener;

  _VideoCoursePlayState() {
    _playerListener = () {
      if (!mounted) {
        return;
      }

      VideoPlayerValue value = _controller.value;

      print("controller value: $value");

      setState(() {
        _videoDuration = value.duration.inMilliseconds;
        _currentVideoPos = value.position.inMilliseconds;
        if (_videoDuration == 0) {
          _progress = 0;
        } else {
          _progress = _currentVideoPos / _videoDuration;
        }
      });
      //当播放完成时开始播下一个视频
      if (value.isPlaying == false && _isPlaying == true && _currentVideoPos >= _videoDuration) {
        _playNextVideo();
      }
      _isPlaying = value.isPlaying;
    };
  }

  @override
  void initState() {
    super.initState();
    _playNextVideo();
  }

  @override
  dispose() async {
    super.dispose();
    _controller.removeListener(_playerListener);
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 44,
            color: AppColor.bgBlack,
          ),
          Expanded(
            child: Stack(
              children: [
                Container(
                  color: AppColor.bgBlack,
                ),
                Container(
                  height: ScreenUtil.instance.height * 0.75,
                  alignment: Alignment.center,
                  child: _controller != null && _controller.value.initialized
                      ? AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: VideoPlayer(_controller),
                        )
                      : Container(),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _controller.value.isPlaying ? _controller.pause() : _controller.play();
                    });
                  },
                  child: Container(
                    color: AppColor.transparent,
                  ),
                ),
                Positioned(
                    bottom: 24,
                    child: Container(
                      width: ScreenUtil.instance.screenWidthDp,
                      // height: 64,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                      child: Container(
                        child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("这是时长",
                                  style: TextStyle(
                                      color: AppColor.white.withOpacity(0.85),
                                      fontSize: 28,
                                      fontWeight: FontWeight.w500)),
                              SizedBox(height: 7.5),
                              Row(
                                children: [
                                  Text("这是课程内容",
                                      softWrap: false,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(color: AppColor.white.withOpacity(0.85), fontSize: 16)),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Text("进度", style: TextStyle(color: AppColor.white.withOpacity(0.85), fontSize: 16)),
                                  SizedBox(
                                    width: 8,
                                  ),
                                ],
                              )
                            ],
                          ),
                          Spacer(),
                          Container(
                            height: 48,
                            width: 48,
                            color: AppColor.white.withOpacity(0.06),
                          )
                        ]),
                      ),
                    )),
                Positioned(
                    right: 16,
                    top: 80,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        alignment: Alignment.center,
                        height: 32,
                        width: 32,
                        decoration: BoxDecoration(color: AppColor.white.withOpacity(0.06), shape: BoxShape.circle),
                        child: Icon(
                          Icons.clear,
                          color: AppColor.white,
                          size: 16,
                        ),
                      ),
                    )),
                Positioned(
                    right: 16,
                    top: 128,
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        alignment: Alignment.center,
                        height: 32,
                        width: 32,
                        decoration: BoxDecoration(color: AppColor.white.withOpacity(0.06), shape: BoxShape.circle),
                        child: Icon(
                          Icons.settings,
                          color: AppColor.white,
                          size: 16,
                        ),
                      ),
                    )),
                Positioned(
                  left: 16,
                  top: 26,
                  child: Text(
                    "$_currentPlayingIndex",
                    style: TextStyle(color: AppColor.white, backgroundColor: AppColor.mainRed),
                  ),
                ),
                Positioned(
                  top: 8,
                  child: Container(
                      height: 10,
                      width: ScreenUtil.instance.screenWidthDp,
                      child: LinearProgressIndicator(
                        value: _progress,
                      )),
                )
              ],
            ),
          ),
          Container(
            height: 60,
            color: AppColor.bgBlack,
            child: Stack(
              children: [
                Container(
                  height: 60,
                  color: AppColor.white.withOpacity(0.06),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  _playNextVideo() {
    // if (_currentPlayingIndex >= urls.length - 1) {
    //   //已经最后一条
    //   return;
    // }

    if (_currentPlayingIndex >= assets.length - 1) {
      //已经最后一条
      return;
    }

    _currentPlayingIndex++;

    _controller?.removeListener(_playerListener);
    //这里需要dispose掉之前的_controller不然会有初始化过的_controller没被释放导致再进入播放页播放器初始化失败
    //但如果直接dispose页面会闪过一瞬界面报错状态
    _controller?.pause();
    var oldController = _controller;

    // _controller = VideoPlayerController.network(urls[_currentPlayingIndex])
    //   ..initialize().then((_) {
    //     setState(() {
    //       _controller.addListener(_playerListener);
    //       _controller.play();
    //     });
    //     oldController?.dispose();
    //   });
    _controller = VideoPlayerController.asset(assets[_currentPlayingIndex])
      ..initialize().then((_) {
        setState(() {
          _controller.addListener(_playerListener);
          _controller.play();
        });
        oldController?.dispose();
      });
  }
}
