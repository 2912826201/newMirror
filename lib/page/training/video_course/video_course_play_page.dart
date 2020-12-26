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

int _buttonTapInterval = 500;

class VideoCoursePlayPage extends StatefulWidget {
  @override
  _VideoCoursePlayState createState() => _VideoCoursePlayState();
}

//FIXME 要处理退到后台时和返回前台时的逻辑
class _VideoCoursePlayState extends State<VideoCoursePlayPage> {
  // final List<String> urls = [
  //   "http://devmedia.aimymusic.com/alita/51be47a088ff3858c29653fd16536a37.mp4",
  //   "http://devmedia.aimymusic.com/0313a2d9f77857d073102320b1a4893c.mp4",
  //   "http://devmedia.aimymusic.com/25e85ec9a9399023629d3fc15bcb8877.mp4",
  //   "http://devmedia.aimymusic.com/01e889ed5d0314abba48382d669b739b",
  // ];

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

  //视频播放地址 应该是下载后的文件地址
  List<String> videoList = [];
  Map<int, int> _indexMapWithoutRest = {};
  int _partAmountWithoutRest = 0;

  VideoPlayerController _controller;

  int _currentPartIndex = -1;
  int _currentVideoIndex = -1;

  double _progress = 0.0;
  int _videoDuration = 0;
  int _currentVideoPos = 0;

  //记录当前part中已播完的视频的总长度
  int _partCompletedDuration = 0;

  bool _isResting = false;
  bool _isPlaying = false;

  int _buttonTapTime = 0;

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
          _progress = (_currentVideoPos + _partCompletedDuration) / (partList[_currentPartIndex].duration * 1000);
        }
        //当播放完成时开始播下一个视频
        if (value.isPlaying == false && _isPlaying == true && _currentVideoPos >= _videoDuration) {
          //将已完成时长加上该视频时长
          _partCompletedDuration += _videoDuration;
          _playNextVideo();
        }
        _isPlaying = value.isPlaying;
      });
    };
  }

  @override
  void initState() {
    super.initState();
    _parsePartList();
    _playNextPart();
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
      body: Stack(children: [
        Column(
          children: [
            Container(
              height: 92,
              color: AppColor.black,
            ),
            Expanded(
              child: Stack(
                children: [
                  Container(
                    color: AppColor.black,
                  ),
                  Container(
                    height: ScreenUtil.instance.screenWidthDp / 0.75,
                    alignment: Alignment.center,
                    child: _controller != null && _controller.value.initialized
                        ? AspectRatio(
                            aspectRatio: _controller.value.aspectRatio,
                            child: VideoPlayer(_controller),
                          )
                        : Container(),
                  ),
                  Positioned(bottom: 24, child: _buildInfoView()),
                  Positioned(
                      right: 16,
                      top: 32,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          height: 32,
                          width: 32,
                          decoration: BoxDecoration(color: AppColor.white.withOpacity(0.12), shape: BoxShape.circle),
                          child: Icon(
                            Icons.clear,
                            color: AppColor.white,
                            size: 16,
                          ),
                        ),
                      )),
                  Positioned(
                      right: 16,
                      top: 80,
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          alignment: Alignment.center,
                          height: 32,
                          width: 32,
                          decoration: BoxDecoration(color: AppColor.white.withOpacity(0.12), shape: BoxShape.circle),
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
                      "$_currentVideoIndex",
                      style: TextStyle(color: AppColor.white, backgroundColor: AppColor.mainRed),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 60,
              color: AppColor.black,
              child: Stack(
                children: [
                  Container(
                    width: ScreenUtil.instance.screenWidthDp,
                    height: 60,
                    color: AppColor.white.withOpacity(0.12),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      GestureDetector(
                        onTap: () {
                          int currentTime = DateTime.now().millisecondsSinceEpoch;
                          if (currentTime - _buttonTapTime < _buttonTapInterval) {
                            return;
                          } else {
                            _buttonTapTime = currentTime;
                          }
                        },
                        child: Container(
                          alignment: Alignment.center,
                          height: 60,
                          width: 60,
                          child: Icon(
                            Icons.skip_previous,
                            color: AppColor.white,
                            size: 24,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 65,
                      ),
                      GestureDetector(
                        onTap: () {
                          int currentTime = DateTime.now().millisecondsSinceEpoch;
                          if (currentTime - _buttonTapTime < _buttonTapInterval) {
                            return;
                          } else {
                            _buttonTapTime = currentTime;
                          }
                        },
                        child: Container(
                          alignment: Alignment.center,
                          height: 60,
                          width: 60,
                          child: Icon(
                            Icons.skip_next,
                            color: AppColor.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ]),
                  )
                ],
              ),
            )
          ],
        ),
        _buildRestView()
      ]),
    );
  }

  Widget _buildInfoView() {
    return Container(
      width: ScreenUtil.instance.screenWidthDp,
      // height: 64,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Container(
        child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_formatTime(partList[_currentPartIndex] == null ? 0 : partList[_currentPartIndex].duration),
                  style: TextStyle(color: AppColor.white.withOpacity(0.85), fontSize: 28, fontWeight: FontWeight.w500)),
              SizedBox(height: 7.5),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(partList[_currentPartIndex] == null ? "" : partList[_currentPartIndex].name,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: AppColor.white.withOpacity(0.85), fontSize: 16)),
                  SizedBox(
                    width: 8,
                  ),
                  Text("${_indexMapWithoutRest[_currentPartIndex] + 1}/$_partAmountWithoutRest",
                      style: TextStyle(color: AppColor.white.withOpacity(0.85), fontSize: 16)),
                  SizedBox(
                    width: 8,
                  ),
                ],
              )
            ],
          ),
          Spacer(),
          GestureDetector(
            onTap: () {
              int currentTime = DateTime.now().millisecondsSinceEpoch;
              if (currentTime - _buttonTapTime < _buttonTapInterval) {
                return;
              } else {
                _buttonTapTime = currentTime;
                setState(() {
                  _controller.value.isPlaying ? _controller.pause() : _controller.play();
                });
              }
            },
            child: Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColor.white.withOpacity(0.12),
              ),
              child: Stack(children: [
                SizedBox(
                    height: 48,
                    width: 48,
                    child: CircularProgressIndicator(
                      value: _progress > 1 ? 1 : _progress,
                      strokeWidth: 3,
                      backgroundColor: AppColor.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColor.white.withOpacity(0.24)),
                    )),
                Center(
                  child: _isPlaying
                      ? Icon(
                          Icons.pause,
                          color: AppColor.white,
                          size: 24,
                        )
                      : Icon(
                          Icons.play_arrow,
                          color: AppColor.white,
                          size: 24,
                        ),
                )
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  // 休息
  Widget _buildRestView() {
    if (_isResting) {
      return Container(
        alignment: Alignment.center,
        color: AppColor.textPrimary1.withOpacity(0.56),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 154,
              width: 154,
              child: Stack(children: [
                Center(
                  child: Text(
                    "29\"",
                    style:
                        TextStyle(color: AppColor.white.withOpacity(0.85), fontSize: 60, fontWeight: FontWeight.w500),
                  ),
                ),
                SizedBox(
                    height: 154,
                    width: 154,
                    child: CircularProgressIndicator(
                      value: 0.5,
                      strokeWidth: 6,
                      backgroundColor: AppColor.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColor.white),
                    ))
              ]),
            ),
            SizedBox(
              height: 24,
            ),
            GestureDetector(
              onTap: () {
                int currentTime = DateTime.now().millisecondsSinceEpoch;
                if (currentTime - _buttonTapTime < _buttonTapInterval) {
                  return;
                } else {
                  _buttonTapTime = currentTime;
                  _playNextPart();
                }
              },
              child: Container(
                alignment: Alignment.center,
                height: 32,
                width: 92,
                decoration: BoxDecoration(
                    border: Border.all(color: AppColor.white.withOpacity(0.85), width: 1, style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(16)),
                child: Text(
                  "跳过休息",
                  style: TextStyle(
                    color: AppColor.white,
                    fontSize: 14,
                  ),
                ),
              ),
            )
          ],
        ),
      );
    } else {
      return Container();
    }
  }

  //播放下一段落
  _playNextPart() {
    if (_currentPartIndex >= partList.length - 1) {
      //TODO 已经最后一段落 处理结束的操作
      return;
    }

    _currentPartIndex++;

    Part part = partList[_currentPartIndex];
    if (part.type == 0) {
      //需要去播放
      setState(() {
        _isResting = false;
        _partCompletedDuration = 0;
      });
      videoList = _parseVideoList(part.videoList);
      _currentVideoIndex = -1;
      _playNextVideo();
    } else if (part.type == 1) {
      //需要开始休息
      setState(() {
        _isResting = true;
      });
    } else {
      //类型出错
      return;
    }
  }

  //播放下一个视频
  _playNextVideo() {
    if (_currentVideoIndex >= videoList.length - 1) {
      //已经最后一条 需要去播下一段落了
      _playNextPart();
      return;
    }

    _currentVideoIndex++;

    _controller?.removeListener(_playerListener);
    //这里需要dispose掉之前的_controller不然会有初始化过的_controller没被释放导致再进入播放页播放器初始化失败
    //但如果直接dispose页面会闪过一瞬界面报错状态
    _controller?.pause();
    var oldController = _controller;

    _controller = VideoPlayerController.asset(videoList[_currentVideoIndex])
      ..initialize().then((_) {
        setState(() {
          _controller.addListener(_playerListener);
          _controller.play();
        });
        oldController?.dispose();
      });
  }

  _parsePartList() {
    _indexMapWithoutRest.clear();
    _partAmountWithoutRest = 0;
    for (int i = 0; i < partList.length; i++) {
      //序号以除去休息的段落数量为基准计算 如果为是休息则序号不加 如果不是休息序号加1
      if (partList[i].type == 1) {
        _indexMapWithoutRest[i] = _partAmountWithoutRest - 1;
      } else {
        _indexMapWithoutRest[i] = _partAmountWithoutRest;
        _partAmountWithoutRest++;
      }
    }
  }

  List<String> _parseVideoList(List<String> list) {
    //FIXME 这里要调用下载服务来获取已经下好的地址
    return list;
  }

  String _formatTime(int duration) {
    int hour = (duration / 3600).floor();
    int minuteAmount = duration % 3600;
    int minute = (minuteAmount / 60).floor();
    int second = minuteAmount % 60;
    String hourStr;
    String minuteStr;
    String secondStr;
    if (hour > 0) {
      hourStr = "$hour:";
    } else {
      hourStr = "";
    }
    if (minute > 0) {
      minuteStr = "$minute\'";
    } else if (hourStr != "") {
      minuteStr = "0\'";
    } else {
      minuteStr = "";
    }
    secondStr = "$second\"";
    return hourStr + minuteStr + secondStr;
  }
}
