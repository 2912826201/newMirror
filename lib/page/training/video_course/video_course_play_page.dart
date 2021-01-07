import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/util/date_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/dialog.dart';
import 'package:mirror/widget/volume_popup.dart';
import 'package:video_player/video_player.dart';

/// video_course_play_page
/// Created by yangjiayi on 2020/12/15.

final List<String> testVideoUrls = [
  "http://media.aimymusic.com/0145ebc4f595f4cb9c4e014db8196c6d.mp4",
  "http://media.aimymusic.com/0ed8e0430848f70646b09592ab86dc18.mp4",
  "http://media.aimymusic.com/100f9b2588e9f1b1311aea8c50222d6a.mp4",
  "http://media.aimymusic.com/029c7bd8c8a94659aff5fda7d798d50f.mp4",
];

//测试用数据结构
class Part {
  List<String> videoList;
  int duration;
  String name;
  int type; //0-课程 1-休息

  Part(this.videoList, this.duration, this.name, this.type);
}

final List<Part> partList = [
  Part([
    // "videos/1.mp4",
    // "videos/2.mp4",
    testVideoUrls[0],
    testVideoUrls[1],
  ], 50, "第一段多视频结束不休息", 0),
  Part([
    // "videos/3.mp4",
    testVideoUrls[2],
  ], 55, "第二段单视频结束有休息", 0),
  Part([], 30, "休息", 1),
  Part([
    // "videos/4.mp4",
    testVideoUrls[3],
  ], 182, "第三段单视频结束后完成", 0),
];

//单位毫秒
int _buttonTapInterval = 500;
int _timerInterval = 100;

class VideoCoursePlayPage extends StatefulWidget {
  VideoCoursePlayPage(this.videoPathMap, {Key key}) : super(key: key);

  //视频播放地址对应本地文件地址的map
  final Map<String, String> videoPathMap;

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

  Map<int, int> _indexMapWithoutRest = {};
  int _partAmountWithoutRest = 0;

  VideoPlayerController _controller;

  int _currentPartIndex = -1;
  int _currentVideoIndex = -1;

  double _progress = 0.0;
  int _videoDuration = 0;
  int _currentVideoPos = 0;

  //记录当前part中已播完的视频的总长度 单位毫秒
  int _partCompletedDuration = 0;

  bool _isResting = false;
  bool _isPlaying = false;

  int _buttonTapTime = 0;

  VoidCallback _playerListener;

  //计时器 每秒更新一些数据 并实现休息阶段的倒计时
  Timer _timer;

  //每秒更新 所以单位是秒
  int _totalTrainingTime = 0;

  //时间戳单位毫秒
  int _restStartTimeStamp = 0;
  double _restProgress = 0.0;

  _VideoCoursePlayState() {
    _playerListener = () {
      if (!mounted) {
        return;
      }

      VideoPlayerValue value = _controller.value;

      print("【${DateTime.now().millisecondsSinceEpoch}】controller value: $value");

      //这个智障回调可能会同时回调多次一样的值 如果都setState则浪费资源降低性能
      //目前只用到了时长 播放进度位置 和播放状态3个值，如果这三个值并没有变化 则不做操作
      if (_videoDuration == value.duration.inMilliseconds &&
          _currentVideoPos == value.position.inMilliseconds &&
          _isPlaying == value.isPlaying) {
        return;
      }

      setState(() {
        _videoDuration = value.duration.inMilliseconds;
        _currentVideoPos = value.position.inMilliseconds;
        if (_videoDuration == 0) {
          _progress = 0;
        } else {
          _progress = (_currentVideoPos + _partCompletedDuration) / (partList[_currentPartIndex].duration * 1000);
          if (_progress > 1) {
            _progress = 1;
          }
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
    if (_timer == null) {
      _timer = Timer.periodic(Duration(milliseconds: _timerInterval), _updateInfoByTimer);
    }
    //TODO 是否需要校验一下数据 比如视频文件map
    _playNextPart();
  }

  @override
  dispose() async {
    super.dispose();
    _timer?.cancel();
    _controller?.removeListener(_playerListener);
    _controller?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _onBackButtonClicked();
        return false;
      },
      child: Scaffold(
        body: Stack(children: [
          Column(
            children: [
              Container(
                height: ScreenUtil.instance.statusBarHeight,
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.only(left: 16),
                          height: 27,
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            DateUtil.formatMillisecondToMinuteAndSecond(_totalTrainingTime),
                            style: TextStyle(
                                color: AppColor.white.withOpacity(0.85), fontWeight: FontWeight.w500, fontSize: 18),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                          height: 21,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "训练时长",
                                style: TextStyle(
                                  color: AppColor.white.withOpacity(0.35),
                                  fontSize: 10,
                                ),
                              ),
                              Spacer(),
                              Icon(
                                Icons.play_circle_outline,
                                color: AppColor.white.withOpacity(0.35),
                                size: 12,
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Text(
                                "1234人已学习",
                                style: TextStyle(
                                  color: AppColor.white.withOpacity(0.35),
                                  fontSize: 10,
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                    Positioned(bottom: 24, child: _buildInfoView()),
                    Positioned(
                        right: 16,
                        top: 80,
                        child: GestureDetector(
                          onTap: () {
                            _onBackButtonClicked();
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
                        top: 128,
                        child: GestureDetector(
                          onTap: () {
                            showVolumePopup(context);
                          },
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
                  ],
                ),
              ),
              Container(
                height: 60 + ScreenUtil.instance.bottomBarHeight,
                color: AppColor.black,
                child: Container(
                  padding: EdgeInsets.only(bottom: ScreenUtil.instance.bottomBarHeight),
                  width: ScreenUtil.instance.screenWidthDp,
                  height: 60 + ScreenUtil.instance.bottomBarHeight,
                  color: AppColor.white.withOpacity(0.12),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                    GestureDetector(
                      onTap: () {
                        int currentTime = DateTime.now().millisecondsSinceEpoch;
                        if (currentTime - _buttonTapTime < _buttonTapInterval) {
                          return;
                        } else {
                          _buttonTapTime = currentTime;
                          _returnToPreviousPart(_currentPartIndex);
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
                    GestureDetector(
                      onTap: () {
                        int currentTime = DateTime.now().millisecondsSinceEpoch;
                        if (currentTime - _buttonTapTime < _buttonTapInterval) {
                          return;
                        } else {
                          _buttonTapTime = currentTime;
                          _skipToNextPart(_currentPartIndex);
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
                ),
              )
            ],
          ),
          _buildRestView()
        ]),
      ),
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
                Center(
                  child: SizedBox(
                      //TODO 描边会出框 减掉进度条粗细的一半试试
                      height: 46.5,
                      width: 46.5,
                      child: CircularProgressIndicator(
                        value: _progress,
                        strokeWidth: 3,
                        backgroundColor: AppColor.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColor.white.withOpacity(0.24)),
                      )),
                ),
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
                    _formatTime((partList[_currentPartIndex].duration * (1 - _restProgress)).round()),
                    style:
                        TextStyle(color: AppColor.white.withOpacity(0.85), fontSize: 60, fontWeight: FontWeight.w500),
                  ),
                ),
                SizedBox(
                    height: 154,
                    width: 154,
                    child: CircularProgressIndicator(
                      value: _restProgress,
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

  //点击返回键或者关闭按钮
  _onBackButtonClicked() {
    showAppDialog(context,
        info: "确认退出当前试听课程吗？",
        topImageUrl: "",
        cancel: AppDialogButton("仍要退出", () {
          Navigator.pop(context);
          return true;
        }),
        confirm: AppDialogButton("继续训练", () {
          return true;
        }));
  }

  //播放下一段落
  _playNextPart() {
    if (_currentPartIndex >= partList.length - 1) {
      //TODO 已经最后一段落 处理结束的操作
      Navigator.pop(context);
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
      _currentVideoIndex = -1;
      _playNextVideo();
    } else if (part.type == 1) {
      //需要开始休息
      setState(() {
        _isResting = true;
        _restStartTimeStamp = DateTime.now().millisecondsSinceEpoch;
      });
    } else {
      //类型出错
      return;
    }
  }

  //播放下一个视频
  _playNextVideo() {
    if (_currentVideoIndex >= partList[_currentPartIndex].videoList.length - 1) {
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

    _controller =
        VideoPlayerController.file(File(widget.videoPathMap[partList[_currentPartIndex].videoList[_currentVideoIndex]]))
          ..initialize().then((_) {
            setState(() {
              _controller.addListener(_playerListener);
              _controller.play();
            });
            oldController?.dispose();
          });
  }

  _updateInfoByTimer(Timer timer) {
    if (_isResting) {
      //休息时
      if (_restProgress == 1) {
        //如果进度已经是满了 播放下一段落
        _playNextPart();
        return;
      }
      int restTime = DateTime.now().millisecondsSinceEpoch - _restStartTimeStamp;
      setState(() {
        _restProgress = restTime / (partList[_currentPartIndex].duration * 1000);

        if (_restProgress >= 1) {
          _restProgress = 1;
          //这里不直接播放下一段的目的是让进度满的状态展示停留一下
        }
      });
    } else if (_isPlaying) {
      //训练且在播放时 每次增加timer间隔
      setState(() {
        _totalTrainingTime += _timerInterval;
      });
    }
  }

  _returnToPreviousPart(int basePartIndex) {
    if (basePartIndex == 0) {
      //已经是第一段落 不做操作
      return;
    }
    Part previousPart = partList[basePartIndex - 1];
    if (previousPart.type == 0) {
      //如果基准段落的上一段落是训练 则将基准段落的值-2赋值给当前段落索引 跳到基准段落的下一段落
      _currentPartIndex = basePartIndex - 2;
      _playNextPart();
    } else if (previousPart.type == 1) {
      //如果基准段落的上一段落是休息 则需要递归到上上个段落
      _returnToPreviousPart(basePartIndex - 1);
    } else {
      //类型出错
      return;
    }
  }

  _skipToNextPart(int basePartIndex) {
    if (basePartIndex >= partList.length - 1) {
      //已经是最后一段落 直接结束
      return;
    }
    Part nextPart = partList[basePartIndex + 1];
    if (nextPart.type == 0) {
      //如果基准段落的下一段落是训练 则将基准段落的值赋值给当前段落索引 跳到基准段落的下一段落
      _currentPartIndex = basePartIndex;
      _playNextPart();
    } else if (nextPart.type == 1) {
      //如果基准段落的下一段落是休息 则需要递归到下下个段落
      _skipToNextPart(basePartIndex + 1);
    } else {
      //类型出错
      return;
    }
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
