import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/api/training/course_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/training/course_model.dart';
import 'package:mirror/data/model/training/training_complete_result_model.dart';
import 'package:mirror/util/integer_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/icon.dart';
import 'package:mirror/widget/no_blue_effect_behavior.dart';

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
  int _feedbackIndex = -1;
  bool _isFeedbacking = false;

  @override
  void initState() {
    super.initState();
    //在进入本页面前已通过课程id获取课程详情 所以不在这个页面获取了 避免出现加载延迟的情况
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        backgroundColor: AppColor.bgBlack,
        brightness: Brightness.dark,
        leading: CustomAppBarIconButton(
            svgName: AppIcon.nav_close,
            iconColor: AppColor.white,
            onTap: () {
              Navigator.pop(context);
            }),
        titleWidget: Text(
          "训练结束",
          style: TextStyle(color: AppColor.white, fontSize: 16),
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
              print("炫耀！");
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
                  style: TextStyle(color: AppColor.white, fontSize: 16),
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
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
                gradient: LinearGradient(
              colors: [AppColor.textPrimary1, AppColor.textPrimary2],
              stops: [0, 1],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            )),
            child: Text(
              "恭喜你，${Application.profile.nickName}\n第${widget.result.no}次完成\n${widget.course.title}",
              style: TextStyle(color: AppColor.white, fontSize: 18, fontWeight: FontWeight.w500),
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
                        widget.result.synthesisRank > 25 ? widget.result.synthesisRank / 100 : 0.25,
                        widget.result.completionDegree > 25 ? widget.result.completionDegree / 100 : 0.25,
                        widget.result.lowerRank > 25 ? widget.result.lowerRank / 100 : 0.25,
                        widget.result.upperRank > 25 ? widget.result.upperRank / 100 : 0.25,
                        widget.result.coreRank > 25 ? widget.result.coreRank / 100 : 0.25
                      ],
                    ),
                  )),
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
                                children: [
                                  Text(
                                    "${widget.result.synthesisScore}",
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
                                children: [
                                  Text(
                                    "${IntegerUtil.formationCalorie(widget.result.calorie, isHaveCompany: false)}",
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
                                children: [
                                  Text(
                                    "${widget.result.mseconds ~/ 60000}",
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
            ClipOval(
              child: CachedNetworkImage(
                height: 32,
                width: 32,
                imageUrl: widget.course.coachDto.avatarUri,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppColor.bgWhite,
                ),
              ),
            ),
            SizedBox(
              width: 12,
            ),
            Text(
              widget.course.coachDto.nickName,
              style: TextStyle(color: AppColor.textPrimary2, fontSize: 14, fontWeight: FontWeight.w500),
            ),
            SizedBox(
              width: 4,
            ),
            Icon(
              Icons.check_circle,
              color: AppColor.textPrimary2,
              size: 16,
            ),
            Spacer(),
            InkWell(
                onTap: () {
                  if (widget.course.coachDto.relation == 0 || widget.course.coachDto.relation == 2) {
                    ProfileAddFollow(widget.course.coachId).then((relation) {
                      if (relation != null) {
                        setState(() {
                          widget.course.coachDto.relation = relation;
                        });
                      }
                    });
                  }
                },
                child: Container(
                  width: 56,
                  height: 24,
                  alignment: Alignment.centerRight,
                  decoration: BoxDecoration(
                    color: widget.course.coachDto.relation == 0 || widget.course.coachDto.relation == 2
                        ? AppColor.textPrimary1
                        : AppColor.transparent,
                    borderRadius: BorderRadius.all(Radius.circular(14)),
                    border: Border.all(
                        width:
                            widget.course.coachDto.relation == 0 || widget.course.coachDto.relation == 2 ? 0.5 : 0.0),
                  ),
                  child: Center(
                    child: Text(
                        widget.course.coachDto.relation == 0 || widget.course.coachDto.relation == 2 ? "关注" : "已关注",
                        style: widget.course.coachDto.relation == 0 || widget.course.coachDto.relation == 2
                            ? AppStyle.whiteRegular12
                            : AppStyle.textSecondaryRegular12),
                  ),
                ))
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
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () async {
                      if (!_isFeedbacking && _feedbackIndex < 0) {
                        _isFeedbacking = true;
                        bool feedbackResult = await videoCourseCommitFeeling(widget.result.id, 0);
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
                        Container(
                          color: _feedbackIndex == 0 ? AppColor.mainRed : AppColor.mainBlue,
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
                        bool feedbackResult = await videoCourseCommitFeeling(widget.result.id, 1);
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
                        Container(
                          color: _feedbackIndex == 1 ? AppColor.mainRed : AppColor.mainBlue,
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
                        bool feedbackResult = await videoCourseCommitFeeling(widget.result.id, 2);
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
                        Container(
                          color: _feedbackIndex == 2 ? AppColor.mainRed : AppColor.mainBlue,
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
          ],
        ),
      ),
    );
  }
}

class PentagonChart extends StatelessWidget {
  final double width;
  final List<double> rateList;

  const PentagonChart({Key key, @required this.width, @required this.rateList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double containerWidth = width * 2;
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
        Positioned(
          top: 32,
          left: containerWidth / 2,
          child: CustomPaint(
            painter: _PentagonChartPainter(pointList, rateList),
          ),
        ),
        Positioned(
          child: SizedBox(
            width: containerWidth,
            child: Text(
              "综合",
              textAlign: TextAlign.center,
              style: AppStyle.textPrimary3Regular14,
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
                  style: AppStyle.textPrimary3Regular14,
                ),
                SizedBox(
                  width: width + 12 * 2,
                ),
                Text(
                  "完成度",
                  style: AppStyle.textPrimary3Regular14,
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
                  style: AppStyle.textPrimary3Regular14,
                ),
                SizedBox(
                  width: a,
                ),
                Text(
                  "下肢",
                  style: AppStyle.textPrimary3Regular14,
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
