import 'dart:math';

import 'package:intl/intl.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/util/integer_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/icon.dart';
import 'package:mirror/widget/live_label_widget.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/training/live_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/training/live_video_model.dart';
import 'package:mirror/data/notifier/machine_notifier.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/date_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/no_blue_effect_behavior.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'video_course/video_course_list_page.dart';

class TrainingPage extends StatefulWidget {
  @override
  _TrainingState createState() => _TrainingState();
}

class _TrainingState extends State<TrainingPage> with AutomaticKeepAliveClientMixin {
  double _screenWidth = 0.0;

  List<LiveVideoModel> _liveList = [];
  List<LiveVideoModel> _videoCourseList = [];

  bool _isVideoCourseRequesting = false;
  int _isVideoCourseLastTime;
  bool _videoCourseHasNext;

  //TODO 临时变量 之后要像机器信息一样全局维护
  bool _isPlayingCourse = false;

  RefreshController _refreshController = RefreshController();

  //hero动画的标签
  List<String> heroTagArray = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _screenWidth = ScreenUtil.instance.screenWidthDp;
    super.initState();
    _requestCourse();

    getLatestLive().then((result) {
      if (result != null) {
        _liveList.addAll(result);
      }
      if (mounted) {
        setState(() {});
      }
    }).catchError((error) {});
  }

  _requestCourse() {
    if (_isVideoCourseRequesting) {
      return;
    }
    if (_videoCourseHasNext != null && !_videoCourseHasNext) {
      // 不是第一次取数据 且没有下一页时直接返回
      return;
    }
    _isVideoCourseRequesting = true;
    getTerminalLearnedCourse(10, lastTime: _isVideoCourseLastTime).then((result) {
      _isVideoCourseRequesting = false;
      if (result != null) {
        _videoCourseHasNext = result.hasNext == 1;
        _isVideoCourseLastTime = result.lastTime;
        _videoCourseList.addAll(result.list);
      }
      if (mounted) {
        _refreshController.loadComplete();
        setState(() {});
      }
    }).catchError((error) {
      _isVideoCourseRequesting = false;
      if (mounted) {
        _refreshController.loadComplete();
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print("TrainingPage_____________________________________________build");
    super.build(context);
    return Scaffold(
      appBar: CustomAppBar(
        hasLeading: false,
        titleString: "训练",
      ),
      backgroundColor: AppColor.white,
      body: Stack(
        children: [
          ScrollConfiguration(
            behavior: NoBlueEffectBehavior(),
            child: SmartRefresher(
              enablePullDown: false,
              // enablePullUp: _videoCourseHasNext,
              enablePullUp: true,
              controller: _refreshController,
              footer: CustomFooter(
                height: 40,
                builder: (BuildContext context, LoadStatus mode) {
                  Widget body;
                  if (mode == LoadStatus.loading) {
                    body = Container();
                  } else if (mode == LoadStatus.noMore) {
                    body = Container();
                  } else if (mode == LoadStatus.failed) {
                    body = Container();
                  } else {
                    body = Container();
                  }
                  return Container(
                    child: Center(
                      child: body,
                    ),
                  );
                },
              ),
              onLoading: _requestCourse,
              child: ListView.builder(
                physics: BouncingScrollPhysics(),
                //有个头部 尾部用SmartRefresher的上拉加载footer代替
                itemCount: _videoCourseList.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _buildTopView(context.watch<MachineNotifier>());
                    // } else if (index == _videoCourseList.length + 1) {
                    //   return Container(
                    //     height: 40,
                    //   );
                  } else {
                    return _buildCourseItem(index - 1);
                  }
                },
              ),
            ),
          ),
          _isPlayingCourse
              ? Positioned(
                  left: 0,
                  bottom: 0,
                  child: _buildInfoBar(),
                )
              : Container(),
        ],
      ),
    );
  }

  //我的课程列表上方的所有部分
  Widget _buildTopView(MachineNotifier notifier) {
    return Column(
      children: [
        _buildBanner(),
        notifier.machine == null ? _buildConnection() : _buildEquipment(notifier),
        _buildLive(),
        _buildCourseTitle(),
        _buildPlaceHolder()
      ],
    );
  }

  Widget _buildBanner() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Container(
        height: _screenWidth * 140 / 375,
        color: AppColor.bgBlack,
        child: Center(
          child: RaisedButton(
            onPressed: () {
              AppRouter.navigateToTestPage(context);
            },
            child: Text("去测试页"),
          ),
        ),
      ),
    );
  }

  Widget _buildConnection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 4),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: Text(
                "连接设备",
                style: AppStyle.textMedium16,
              ))
            ],
          ),
          GestureDetector(
              onTap: () {
                if (Application.token.anonymous == 0) {
                  AppRouter.navigateToScanCodePage(context);
                } else {
                  AppRouter.navigateToLoginPage(context);
                }
              },
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                height: 36,
                decoration: BoxDecoration(
                    border: Border.all(
                  color: AppColor.textPrimary1,
                  width: 1,
                )),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AppIcon.getAppIcon(AppIcon.machine_connection, 16),
                    SizedBox(
                      width: 4,
                    ),
                    Text(
                      "连接设备",
                      style: AppStyle.textRegular14,
                    )
                  ],
                ),
              ))
        ],
      ),
    );
  }

  Widget _buildEquipment(MachineNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 4),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: Text(
                "设备",
                style: AppStyle.textMedium16,
              ))
            ],
          ),
          //TODO 暂时先做个样式 实际可能有多个设备
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              AppRouter.navigateToMachineRemoteController(context);
            },
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              height: 64,
              child: Row(
                children: [
                  Container(
                    color: AppColor.mainBlue,
                    width: 100,
                    height: 64,
                  ),
                  SizedBox(
                    width: 12,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "${notifier.machine.name}",
                            style: AppStyle.textMedium15,
                          ),
                          SizedBox(
                            width: 4.5,
                          ),
                          notifier.machine.status == 0
                              ? AppIcon.getAppIcon(
                                  AppIcon.machine_disconnected_18,
                                  18,
                                  color: AppColor.textPrimary2,
                                )
                              : AppIcon.getAppIcon(
                                  AppIcon.machine_connected_18,
                                  18,
                                  color: AppColor.textPrimary2,
                                ),
                          SizedBox(
                            width: 2.5,
                          ),
                          Container(
                            alignment: Alignment.center,
                            height: 12,
                            width: 12,
                            child: Container(
                              height: 4,
                              width: 4,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: notifier.machine.status == 0 ? AppColor.mainRed : AppColor.lightGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "点击可操控终端设备",
                              style: AppStyle.textSecondaryRegular12,
                            )),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLive() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 4),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                  child: Text(
                "近期直播",
                style: AppStyle.textMedium16,
              )),
              GestureDetector(
                onTap: () {
                  AppRouter.navigateToLiveBroadcast(context);
                },
                child: Row(
                  children: [
                    Text(
                      "全部",
                      style: AppStyle.textPrimary3Regular14,
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    AppIcon.getAppIcon(
                      AppIcon.arrow_right_16,
                      16,
                      color: AppColor.textPrimary3,
                    ),
                  ],
                ),
              )
            ],
          ),
          _liveList.length > 0
              ? GestureDetector(
                  onTap: () {
                    AppRouter.navigateToLiveDetail(context, _liveList.first.id, liveModel: _liveList.first);
                  },
                  child: Container(
                      margin: const EdgeInsets.only(top: 12),
                      height: _screenWidth * 151 / 343,
                      child: Stack(
                        children: [
                          CachedNetworkImage(
                            imageUrl: _liveList.first.picUrl,
                            width: _screenWidth,
                            height: _screenWidth * 151 / 343,
                            fit: BoxFit.cover,
                          ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    LiveLabelWidget(isWhiteBorder: false),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    Text(
                                      "${_parseLiveTime(_liveList.first.startTime)} - ${_parseLiveTime(_liveList.first.endTime)}",
                                      style:
                                          TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColor.white),
                                    )
                                  ],
                                ),
                                Spacer(),
                                Text(
                                  "${_liveList.first.coursewareDto.name}",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: AppColor.white),
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "${_liveList.first.coursewareDto.targetDto.name}·${IntegerUtil.formationCalorie(_liveList.first.coursewareDto.calories, isHaveCompany: false)}Kcal",
                                      style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w400,
                                          color: AppColor.white.withOpacity(0.85)),
                                    ),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    Text(
                                      "${_liveList.first.coachDto.nickName}",
                                      style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w400,
                                          color: AppColor.white.withOpacity(0.85)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                        ],
                      )),
                )
              : Container(),
        ],
      ),
    );
  }

  Widget _buildCourseTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
              child: Text(
            "我的课程",
            style: AppStyle.textMedium16,
          )),
          GestureDetector(
            onTap: () {
              AppRouter.navigateToVideoCourseList(context);
            },
            child: Row(
              children: [
                Text(
                  "添加课程",
                  style: AppStyle.textPrimary3Regular14,
                ),
                SizedBox(
                  width: 4,
                ),
                AppIcon.getAppIcon(
                  AppIcon.add_circle_white,
                  16,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPlaceHolder() {
    if (_videoCourseList.length > 0) {
      return Container();
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 16,
          ),
          Image.asset(
            "assets/png/default_no_data.png",
            height: 224,
            width: 224,
            fit: BoxFit.cover,
          ),
          SizedBox(
            height: 16,
          ),
          Text(
            "还没有课程，去添加课程吧",
            style: AppStyle.textSecondaryRegular14,
          ),
          SizedBox(
            height: 16,
          ),
        ],
      );
    }
  }

  Widget _buildCourseItem(int index) {
    LiveVideoModel videoModel = _videoCourseList[index];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: ScreenUtil.instance.screenWidthDp,
          child: Row(
            children: [
              buildVideoCourseItemLeftImageUi(videoModel, getHeroTag(videoModel, index)),
              buildVideoCourseItemRightDataUi(videoModel, 90, true),
            ],
          ),
        ),
        onTap: () {
          //点击事件
          print("====heroTagArray[index]:${heroTagArray[index]}");
          AppRouter.navigateToVideoDetail(context, videoModel.id, heroTag: heroTagArray[index], videoModel: videoModel);
        },
      ),
    );
  }

  //给hero的tag设置唯一的值
  Object getHeroTag(LiveVideoModel videoModel, index) {
    if (heroTagArray != null && heroTagArray.length > index) {
      return heroTagArray[index];
    } else {
      String string = "heroTag_video_${DateUtil.getNowDateMs()}_${Random().nextInt(100000)}_${videoModel.id}_$index";
      heroTagArray.add(string);
      return string;
    }
  }

  Widget _buildInfoBar() {
    return GestureDetector(
      onTap: () {
        print("进入遥控页");
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        height: 40,
        width: ScreenUtil.instance.screenWidthDp - 32,
        color: AppColor.textPrimary1,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                print("关闭信息条");
              },
              child: Container(
                alignment: Alignment.center,
                height: 36,
                width: 36,
                child: Icon(
                  Icons.highlight_off,
                  color: AppColor.white,
                  size: 16,
                ),
              ),
            ),
            Expanded(
                child: Text(
              "继续播放：普拉提产后恢复系列高速燃脂普拉提产后恢复系列高速燃脂",
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(color: AppColor.white, fontSize: 14),
            )),
            SizedBox(
              width: 12,
            ),
          ],
        ),
      ),
    );
  }
}

String _parseLiveTime(String liveTime) {
  DateTime time = DateTime.tryParse(liveTime);
  String timeStr;
  if (time == null) {
    timeStr = liveTime;
  } else {
    if (DateUtil.isToday(time)) {
      timeStr = DateUtil.formatTimeString(time);
    } else if (DateUtil.isToYear(time)) {
      timeStr = DateFormat('MM-dd HH:mm').format(time);
    } else {
      timeStr = DateUtil.formatDateTimeString(time);
    }
  }
  return timeStr;
}
