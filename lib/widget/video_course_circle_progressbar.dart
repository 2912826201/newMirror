import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'dart:math';

import 'package:mirror/page/training/video_course/video_course_play_page.dart';

/// video_course_circle_progressbar
/// Created by yangjiayi on 2021/1/5.

double _radianBetweenPart = pi * 5 / 180; //每段间隔的角度 5°

//尺寸颜色暂时写死
class VideoCourseCircleProgressBar extends StatelessWidget {
  VideoCourseCircleProgressBar(this.partList, this.partIndex, this.partProgress, {Key key}) : super(key: key);

  final List<Part> partList;
  final int partIndex;
  final double partProgress;

  @override
  Widget build(BuildContext context) {
    List<_RadianPart> list = _convertPartList();
    return CustomPaint(
      child: Center(
        child: Container(
          height: 125,
          width: 125,
          decoration: BoxDecoration(
              color: AppColor.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(offset: Offset(0, 3), blurRadius: 12, color: AppColor.textHint)]),
        ),
      ),
      painter: _VideoCourseCircleProgressPainter(list),
    );
  }

  List<_RadianPart> _convertPartList() {
    List<_RadianPart> list = [];
    if (partList == null || partIndex < 0 || partIndex >= partList.length) {
      return list;
    } else {
      int notRestDuration = 0;
      int notRestCount = 0;
      //先计算非休息总时长和段数 再根据index遍历进行状态
      for (int i = 0; i < partList.length; i++) {
        if (partList[i].type != 1) {
          notRestDuration += partList[i].duration;
          notRestCount++;
        }
        _RadianPart radianPart = _RadianPart(partList[i]);
        if (i < partIndex) {
          radianPart.progress = 1;
        } else if (i == partIndex) {
          radianPart.progress = partProgress;
        } else {
          radianPart.progress = 0;
        }
        list.add(radianPart);
      }
      //根据时长计算角度
      double lastRadian = -pi / 2;
      for (int i = 0; i < list.length; i++) {
        double totalRadian = pi * 2 - _radianBetweenPart * notRestCount;
        if (list[i].type == 1) {
          list[i].startRadian = lastRadian;
          list[i].sweepRadian = 0;
        } else {
          list[i].startRadian = lastRadian;
          list[i].sweepRadian = totalRadian * list[i].duration / notRestDuration;
          lastRadian += (list[i].sweepRadian + _radianBetweenPart);
        }
      }
      return list;
    }
  }
}

class _RadianPart extends Part {
  _RadianPart(Part part) : super(part.videoList, part.duration, part.name, part.type);

  double startRadian;
  double sweepRadian;
  double progress; //进行中的进度 已完成为1 未开始为0
}

class _VideoCourseCircleProgressPainter extends CustomPainter {
  _VideoCourseCircleProgressPainter(this.list);

  List<_RadianPart> list;

  final Paint bgPaint = _BgPaint();
  final Paint progressPaint = _ProgressPaint();
  final double radius = 77;

  @override
  void paint(Canvas canvas, Size size) {
    Rect rect = Rect.fromCircle(center: Offset(size.width / 2, size.height / 2), radius: radius);

    list.forEach((element) {
      if (element.type == 1) {
        //只画非休息段落
        return;
      }

      if (element.progress == 0) {
        canvas.drawArc(rect, element.startRadian, element.sweepRadian, false, bgPaint);
      } else if (element.progress == 1) {
        canvas.drawArc(rect, element.startRadian, element.sweepRadian, false, progressPaint);
      } else {
        canvas.drawArc(rect, element.startRadian, element.sweepRadian, false, bgPaint);
        canvas.drawArc(rect, element.startRadian, element.sweepRadian * element.progress, false, progressPaint);
      }
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class _BgPaint extends Paint {
  _BgPaint() {
    color = AppColor.textHint;
    style = PaintingStyle.stroke;
    strokeCap = StrokeCap.round;
    strokeWidth = 3;
  }
}

class _ProgressPaint extends Paint {
  _ProgressPaint() {
    color = AppColor.textPrimary1;
    style = PaintingStyle.stroke;
    strokeCap = StrokeCap.round;
    strokeWidth = 3;
  }
}
