import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/training/course_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/training/course_model.dart';
import 'package:mirror/data/model/training/training_complete_result_model.dart';
import 'package:mirror/data/notifier/user_interactive_notifier.dart';
import 'package:mirror/page/profile/profile_detail_page.dart';
import 'package:mirror/page/training/video_course/video_course_result_share_dialog.dart';
import 'package:mirror/util/event_bus.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/util/integer_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/custom_button.dart';
import 'package:mirror/widget/icon.dart';
import 'package:mirror/widget/no_blue_effect_behavior.dart';
import 'package:provider/provider.dart';

/// video_course_result_page
/// Created by yangjiayi on 2021/1/14.

class VideoCourseResultPage extends StatefulWidget {
  final TrainingCompleteResultModel result;
  final CourseModel course;

  VideoCourseResultPage(this.result, this.course, {Key key}) : super(key: key);

  @override
  _VideoCourseResultState createState() => _VideoCourseResultState();
}

class _VideoCourseResultState extends State<VideoCourseResultPage> {
  TrainingCompleteResultModel result;
  CourseModel course;
  int _feedbackIndex = -1;
  bool _isFeedbacking = false;

  @override
  void dispose() {
    super.dispose();
    EventBus.init().unRegister(pageName: VIDEO_COURSE_RESULT_PAGE, registerName: VIDEO_COURSE_RESULT);
  }

  @override
  void initState() {
    result = widget.result;
    course = widget.course;
    super.initState();
    //在进入本页面前已通过课程id获取课程详情 所以不在这个页面获取了 避免出现加载延迟的情况
    EventBus.init().registerSingleParameter(setData, VIDEO_COURSE_RESULT_PAGE, registerName: VIDEO_COURSE_RESULT);
  }

  setData(List list) {
    result = list[0];
    course = list[1];
    _feedbackIndex = -1;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        backgroundColor: AppColor.mainBlack,
        brightness: Brightness.dark,
        leading: CustomAppBarIconButton(
            svgName: AppIcon.nav_close,
            iconColor: AppColor.white,
            onTap: () {
              Navigator.pop(context);
            }),
        titleWidget: Text(
          "训练结束",
          style: AppStyle.whiteRegular16,
        ),
      ),
      body: Column(children: [
        Expanded(
          child: ScrollConfiguration(
            behavior: NoBlueEffectBehavior(),
            child: SingleChildScrollView(
              physics: ClampingScrollPhysics(),
              child: Column(
                children: [
                  _buildFirstPart(),
                  _buildSecondPart(),
                  _buildThirdPart(),
                  Container(
                    height: 42.5,
                    color: AppColor.bgWhite,
                  )
                ],
              ),
            ),
          ),
        ),
        Container(
          height: 48 + ScreenUtil.instance.bottomBarHeight,
          color: AppColor.textPrimary1,
          padding: EdgeInsets.only(bottom: ScreenUtil.instance.bottomBarHeight),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (context) {
                    return WillPopScope(
                      onWillPop: () async => true, //用来屏蔽安卓返回键关弹窗
                      child: VideoCourseResultShareDialog(result, course),
                    );
                  });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AppIcon.getAppIcon(
                  AppIcon.camera_24,
                  24,
                  color: AppColor.white,
                ),
                SizedBox(
                  width: 6,
                ),
                Text(
                  "炫耀一下吧",
                  style: AppStyle.whiteRegular16,
                )
              ],
            ),
          ),
        )
      ]),
    );
  }

  Widget _buildFirstPart() {
    return Container(
      color: AppColor.bgWhite,
      height: 503,
      child: Stack(
        children: [
          Container(
            height: 193,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColor.textPrimary1, AppColor.textPrimary2],
                stops: [0, 1],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Image.asset(
              "assets/png/video_course_result_bg.png",
              width: ScreenUtil.instance.screenWidthDp,
              height: 193,
              fit: BoxFit.cover,
            ),
          ),
          Container(
            height: 193,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            alignment: Alignment.centerLeft,
            child: Text(
              "恭喜你，${Application.profile.nickName}\n第${result.no}次完成\n${course.title}",
              style: AppStyle.whiteMedium18,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 16,
            width: ScreenUtil.instance.screenWidthDp - 32,
            child: Container(
              height: 350,
              decoration: BoxDecoration(color: AppColor.white, borderRadius: BorderRadius.all(Radius.circular(10))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      child: PentagonChart(
                        width: 144.0,
                        rateList: [
                          //修正分数 至少有25分
                          result.synthesisRank > 25 ? result.synthesisRank / 100 : 0.25,
                          result.completionDegree > 25 ? result.completionDegree / 100 : 0.25,
                          result.lowerRank > 25 ? result.lowerRank / 100 : 0.25,
                          result.upperRank > 25 ? result.upperRank / 100 : 0.25,
                          result.coreRank > 25 ? result.coreRank / 100 : 0.25
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: 78,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.ideographic,
                                children: [
                                  Text(
                                    "${result.synthesisScore}",
                                    style: TextStyle(color: AppColor.textPrimary2, fontSize: 23),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 6,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  AppIcon.getAppIcon(AppIcon.score_16, 16),
                                  SizedBox(
                                    width: 2,
                                  ),
                                  Text(
                                    "动作匹配得分",
                                    style: TextStyle(color: AppColor.textHint, fontSize: 12),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.ideographic,
                                children: [
                                  Text(
                                    "${IntegerUtil.formationCalorie(result.calorie, isHaveCompany: false)}",
                                    style: TextStyle(color: AppColor.textPrimary2, fontSize: 23),
                                  ),
                                  SizedBox(
                                    width: 2,
                                  ),
                                  Text(
                                    "千卡",
                                    style: TextStyle(color: AppColor.textPrimary3, fontSize: 12),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 6,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  AppIcon.getAppIcon(AppIcon.calorie_16, 16),
                                  SizedBox(
                                    width: 2,
                                  ),
                                  Text(
                                    "累计消耗热量",
                                    style: TextStyle(color: AppColor.textHint, fontSize: 12),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.ideographic,
                                children: [
                                  Text(
                                    "${result.mseconds ~/ 60000}",
                                    style: TextStyle(color: AppColor.textPrimary2, fontSize: 23),
                                  ),
                                  SizedBox(
                                    width: 2,
                                  ),
                                  Text(
                                    "分钟",
                                    style: TextStyle(color: AppColor.textPrimary3, fontSize: 12),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 6,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  AppIcon.getAppIcon(AppIcon.time_16, 16),
                                  SizedBox(
                                    width: 2,
                                  ),
                                  Text(
                                    "训练时长",
                                    style: TextStyle(color: AppColor.textHint, fontSize: 12),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecondPart() {
    return Container(
      color: AppColor.bgWhite,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Container(
        height: 64,
        decoration: BoxDecoration(color: AppColor.white, borderRadius: BorderRadius.all(Radius.circular(10))),
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: onClickCoach,
              child: ClipOval(
                child: CachedNetworkImage(
                  height: 32,
                  width: 32,
                  imageUrl: FileUtil.getSmallImage(course.coachDto.avatarUri),
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppColor.bgWhite,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 12,
            ),
            Text(
              course.coachDto.nickName,
              style: TextStyle(color: AppColor.textPrimary2, fontSize: 14, fontWeight: FontWeight.w500),
            ),
            SizedBox(
              width: 4,
            ),
            AppIcon.getAppIcon(AppIcon.identity_coach_16, 16),
            Spacer(),
            FollowButton(
              id: course.coachDto.uid,
              relation: course.coachDto.relation,
              buttonType: FollowButtonType.COACH,
              resetDataListener: () {},
              onClickAttention: (int relation) {
                course.coachDto.relation = relation;
              },
            ),

            // InkWell(
            //     onTap: () {
            //       if (course.coachDto.relation == 0 || course.coachDto.relation == 2) {
            //         ProfileAddFollow(course.coachId).then((relation) {
            //           if (relation != null) {
            //             setState(() {
            //               course.coachDto.relation = relation;
            //             });
            //           }
            //         });
            //       }
            //     },
            //     child: Container(
            //       width: 56,
            //       height: 24,
            //       alignment: Alignment.centerRight,
            //       decoration: BoxDecoration(
            //         color: course.coachDto.relation == 0 || course.coachDto.relation == 2
            //             ? AppColor.textPrimary1
            //             : AppColor.transparent,
            //         borderRadius: BorderRadius.all(Radius.circular(14)),
            //         border: Border.all(
            //             width:
            //                 course.coachDto.relation == 0 || course.coachDto.relation == 2 ? 0.5 : 0.0),
            //       ),
            //       child: Center(
            //         child: Text(
            //             course.coachDto.relation == 0 || course.coachDto.relation == 2 ? "关注" : "已关注",
            //             style: course.coachDto.relation == 0 || course.coachDto.relation == 2
            //                 ? AppStyle.whiteRegular12
            //                 : AppStyle.textSecondaryRegular12),
            //       ),
            //     ))
          ],
        ),
      ),
    );
  }

  Widget _buildThirdPart() {
    return Container(
      color: AppColor.bgWhite,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Container(
        height: 140,
        decoration: BoxDecoration(color: AppColor.white, borderRadius: BorderRadius.all(Radius.circular(10))),
        child: Column(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              height: 48,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Text(
                "本次训练感受",
                style: AppStyle.textMedium14,
              ),
            ),
            SizedBox(
              height: 6,
            ),
            _feedbackIndex < 0
                ? Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () async {
                            if (!_isFeedbacking && _feedbackIndex < 0) {
                              _isFeedbacking = true;
                              bool feedbackResult = await videoCourseCommitFeeling(result.id, 0);
                              _isFeedbacking = false;
                              if (feedbackResult) {
                                setState(() {
                                  _feedbackIndex = 0;
                                });
                              }
                            }
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(
                                "assets/png/video_course_result_easy.png",
                                fit: BoxFit.cover,
                                height: 45,
                                width: 45,
                              ),
                              SizedBox(
                                height: 6,
                              ),
                              Text("太简单了", style: TextStyle(color: AppColor.textSecondary, fontSize: 13))
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () async {
                            if (!_isFeedbacking && _feedbackIndex < 0) {
                              _isFeedbacking = true;
                              bool feedbackResult = await videoCourseCommitFeeling(result.id, 1);
                              _isFeedbacking = false;
                              if (feedbackResult) {
                                setState(() {
                                  _feedbackIndex = 1;
                                });
                              }
                            }
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(
                                "assets/png/video_course_result_good.png",
                                fit: BoxFit.cover,
                                height: 45,
                                width: 45,
                              ),
                              SizedBox(
                                height: 6,
                              ),
                              Text("很棒", style: TextStyle(color: AppColor.textSecondary, fontSize: 13))
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () async {
                            if (!_isFeedbacking && _feedbackIndex < 0) {
                              _isFeedbacking = true;
                              bool feedbackResult = await videoCourseCommitFeeling(result.id, 2);
                              _isFeedbacking = false;
                              if (feedbackResult) {
                                setState(() {
                                  _feedbackIndex = 2;
                                });
                              }
                            }
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(
                                "assets/png/video_course_result_hard.png",
                                fit: BoxFit.cover,
                                height: 45,
                                width: 45,
                              ),
                              SizedBox(
                                height: 6,
                              ),
                              Text("太难了", style: TextStyle(color: AppColor.textSecondary, fontSize: 13))
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : Container(
                    height: 52,
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                    margin: const EdgeInsets.only(left: 16, right: 16),
                    decoration: BoxDecoration(
                      color: AppColor.bgWhite,
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          height: 20,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _feedbackIndex == 0
                                ? "太厉害了，下次尝试更高难度的训练吧！"
                                : _feedbackIndex == 1
                                ? "真棒，继续加油吧~"
                                : _feedbackIndex == 2
                                ? "别着急，下次尝试简单点的课程吧~"
                                : "",
                            style: TextStyle(
                              color: AppColor.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Image.asset(
                          "assets/png/video_course_result_fighting.png",
                          fit: BoxFit.cover,
                          height: 14,
                          width: 14,
                        ),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  ///点击了教练
  onClickCoach() async {
    if (await isOffline()) {
      ToastShow.show(msg: "请检查网络!", context: context);
      return;
    }
    jumpToUserProfilePage(context, course.coachDto.uid,
        avatarUrl: course.coachDto?.avatarUri, userName: course.coachDto?.nickName, callback: (dynamic r) {
      if (mounted && context != null) {
        bool result = context.read<UserInteractiveNotifier>().value.profileUiChangeModel[course.coachDto.uid].isFollow;
        print("result:$result");
        if (null != result && result is bool) {
          course.coachDto.relation = result ? 0 : 1;
          if (mounted) {
            setState(() {});
          }
        }
      }
    });
  }

  Future<bool> isOffline() async {
    ConnectivityResult connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      return false;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return false;
    } else {
      return true;
    }
  }
}

class PentagonChart extends StatelessWidget {
  //五边形的宽度
  final double width;

  //五个评分 0-1
  final List<double> rateList;

  //字的颜色
  final Color fontColor;

  //字的大小
  final double fontSize;

  PentagonChart(
      {Key key,
      @required this.width,
      @required this.rateList,
      this.fontColor = AppColor.textPrimary3,
      this.fontSize = 14.0})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 整个视图为五边形宽的2.25倍(当字号和宽度不匹配时可能会导致视图宽度不够)
    double containerWidth = width * 2.25;
    // 每条边的边长
    double a = width / 2 / cos(pi / 5);
    print("a:$a");
    Offset p1 = Offset(0.0, 0.0);
    print("p1:$p1");
    Offset p2 = Offset(width / 2, tan(pi / 5) * width / 2);
    print("p2:$p2");
    Offset p3 = Offset(a / 2, tan(pi / 5) * width / 2 + (width - a) / 2 / tan(pi / 10));
    print("p3:$p3");
    Offset p4 = Offset(-a / 2, tan(pi / 5) * width / 2 + (width - a) / 2 / tan(pi / 10));
    print("p4:$p4");
    Offset p5 = Offset(-width / 2, tan(pi / 5) * width / 2);
    print("p5:$p5");
    Offset c = Offset(0.0, a / 2 / cos(pi * 3 / 10));
    print("c:$c");
    List<Offset> pointList = [c, p1, p2, p3, p4, p5];
    double containerHeight = p3.dy + 20 * 2 + 12 * 2;
    return Container(
      height: containerHeight,
      width: containerWidth,
      child: Stack(children: [
        //五边形
        Positioned(
          top: 32,
          left: containerWidth / 2,
          child: CustomPaint(
            painter: _PentagonChartPainter(pointList, rateList),
          ),
        ),
        //五个文字
        Positioned(
          child: SizedBox(
            width: containerWidth,
            child: Text(
              "综合",
              textAlign: TextAlign.center,
              style: TextStyle(color: fontColor, fontSize: fontSize),
            ),
          ),
        ),
        Positioned(
          top: p2.dy + 10 + 12,
          child: Container(
            width: containerWidth,
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  //为了确保布局对称 加了个全角空格
                  "　核心",
                  style: TextStyle(color: fontColor, fontSize: fontSize),
                ),
                SizedBox(
                  width: width + 12 * 2,
                ),
                Text(
                  "完成度",
                  style: TextStyle(color: fontColor, fontSize: fontSize),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          child: Container(
            width: containerWidth,
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "上肢",
                  style: TextStyle(color: fontColor, fontSize: fontSize),
                ),
                SizedBox(
                  width: a,
                ),
                Text(
                  "下肢",
                  style: TextStyle(color: fontColor, fontSize: fontSize),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}

class _PentagonChartPainter extends CustomPainter {
  final List<Offset> pointList;
  final List<double> rateList;

  _PentagonChartPainter(this.pointList, this.rateList);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = AppColor.textHint.withOpacity(0.16)
      ..style = PaintingStyle.fill;

    Path path1 = Path();
    path1.moveTo(pointList[1].dx, pointList[1].dy);
    path1.lineTo(pointList[2].dx, pointList[2].dy);
    path1.lineTo(pointList[3].dx, pointList[3].dy);
    path1.lineTo(pointList[4].dx, pointList[4].dy);
    path1.lineTo(pointList[5].dx, pointList[5].dy);
    Path path2 = Path();
    path2.moveTo((pointList[1].dx - pointList[0].dx) * 3 / 4 + pointList[0].dx,
        (pointList[1].dy - pointList[0].dy) * 3 / 4 + pointList[0].dy);
    path2.lineTo((pointList[2].dx - pointList[0].dx) * 3 / 4 + pointList[0].dx,
        (pointList[2].dy - pointList[0].dy) * 3 / 4 + pointList[0].dy);
    path2.lineTo((pointList[3].dx - pointList[0].dx) * 3 / 4 + pointList[0].dx,
        (pointList[3].dy - pointList[0].dy) * 3 / 4 + pointList[0].dy);
    path2.lineTo((pointList[4].dx - pointList[0].dx) * 3 / 4 + pointList[0].dx,
        (pointList[4].dy - pointList[0].dy) * 3 / 4 + pointList[0].dy);
    path2.lineTo((pointList[5].dx - pointList[0].dx) * 3 / 4 + pointList[0].dx,
        (pointList[5].dy - pointList[0].dy) * 3 / 4 + pointList[0].dy);

    Path path3 = Path();
    path3.moveTo((pointList[1].dx - pointList[0].dx) * 2 / 4 + pointList[0].dx,
        (pointList[1].dy - pointList[0].dy) * 2 / 4 + pointList[0].dy);
    path3.lineTo((pointList[2].dx - pointList[0].dx) * 2 / 4 + pointList[0].dx,
        (pointList[2].dy - pointList[0].dy) * 2 / 4 + pointList[0].dy);
    path3.lineTo((pointList[3].dx - pointList[0].dx) * 2 / 4 + pointList[0].dx,
        (pointList[3].dy - pointList[0].dy) * 2 / 4 + pointList[0].dy);
    path3.lineTo((pointList[4].dx - pointList[0].dx) * 2 / 4 + pointList[0].dx,
        (pointList[4].dy - pointList[0].dy) * 2 / 4 + pointList[0].dy);
    path3.lineTo((pointList[5].dx - pointList[0].dx) * 2 / 4 + pointList[0].dx,
        (pointList[5].dy - pointList[0].dy) * 2 / 4 + pointList[0].dy);

    Path path4 = Path();
    path4.moveTo((pointList[1].dx - pointList[0].dx) * 1 / 4 + pointList[0].dx,
        (pointList[1].dy - pointList[0].dy) * 1 / 4 + pointList[0].dy);
    path4.lineTo((pointList[2].dx - pointList[0].dx) * 1 / 4 + pointList[0].dx,
        (pointList[2].dy - pointList[0].dy) * 1 / 4 + pointList[0].dy);
    path4.lineTo((pointList[3].dx - pointList[0].dx) * 1 / 4 + pointList[0].dx,
        (pointList[3].dy - pointList[0].dy) * 1 / 4 + pointList[0].dy);
    path4.lineTo((pointList[4].dx - pointList[0].dx) * 1 / 4 + pointList[0].dx,
        (pointList[4].dy - pointList[0].dy) * 1 / 4 + pointList[0].dy);
    path4.lineTo((pointList[5].dx - pointList[0].dx) * 1 / 4 + pointList[0].dx,
        (pointList[5].dy - pointList[0].dy) * 1 / 4 + pointList[0].dy);

    canvas.drawPath(path1, paint);
    canvas.drawPath(path2, paint);
    canvas.drawPath(path3, paint);
    canvas.drawPath(path4, paint);

    paint.color = AppColor.textHint.withOpacity(0.06);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1;

    canvas.drawLine(pointList[1], pointList[0], paint);
    canvas.drawLine(pointList[2], pointList[0], paint);
    canvas.drawLine(pointList[3], pointList[0], paint);
    canvas.drawLine(pointList[4], pointList[0], paint);
    canvas.drawLine(pointList[5], pointList[0], paint);

    paint.color = AppColor.mainRed.withOpacity(0.24);
    paint.style = PaintingStyle.fill;

    Path path5 = Path();
    path5.moveTo((pointList[1].dx - pointList[0].dx) * rateList[0] + pointList[0].dx,
        (pointList[1].dy - pointList[0].dy) * rateList[0] + pointList[0].dy);
    path5.lineTo((pointList[2].dx - pointList[0].dx) * rateList[1] + pointList[0].dx,
        (pointList[2].dy - pointList[0].dy) * rateList[1] + pointList[0].dy);
    path5.lineTo((pointList[3].dx - pointList[0].dx) * rateList[2] + pointList[0].dx,
        (pointList[3].dy - pointList[0].dy) * rateList[2] + pointList[0].dy);
    path5.lineTo((pointList[4].dx - pointList[0].dx) * rateList[3] + pointList[0].dx,
        (pointList[4].dy - pointList[0].dy) * rateList[3] + pointList[0].dy);
    path5.lineTo((pointList[5].dx - pointList[0].dx) * rateList[4] + pointList[0].dx,
        (pointList[5].dy - pointList[0].dy) * rateList[4] + pointList[0].dy);
    path5.lineTo((pointList[1].dx - pointList[0].dx) * rateList[0] + pointList[0].dx,
        (pointList[1].dy - pointList[0].dy) * rateList[0] + pointList[0].dy);

    canvas.drawPath(path5, paint);

    paint.color = AppColor.mainRed;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1;

    canvas.drawPath(path5, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
