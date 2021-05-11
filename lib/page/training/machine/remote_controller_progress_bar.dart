import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/training/course_model.dart';
import 'package:mirror/page/training/video_course/video_course_play_page.dart';
import 'package:mirror/util/date_util.dart';
import 'package:mirror/widget/video_course_circle_progressbar.dart';

class RemoteControllerProgressBar extends StatefulWidget {
  final List<VideoCoursePart> partList;
  final int currentPartIndex;
  final double partProgress;
  final int remainingPartTime;
  final Map<int, int> indexMapWithoutRest;
  final int partAmountWithoutRest;
  final bool isLiveRoomController;
  final CourseModel liveVideoModel;
  final int startCourse;

  RemoteControllerProgressBar(
      Key key,
      this.partList,
      this.currentPartIndex,
      this.partProgress,
      this.remainingPartTime,
      this.indexMapWithoutRest,
      this.partAmountWithoutRest,
      this.isLiveRoomController,
      this.liveVideoModel,
      this.startCourse)
      : super(key: key);

  @override
  RemoteControllerProgressBarState createState() => RemoteControllerProgressBarState(
      partList,
      currentPartIndex,
      partProgress,
      remainingPartTime,
      indexMapWithoutRest,
      partAmountWithoutRest,
      isLiveRoomController,
      liveVideoModel,
      startCourse);
}

class RemoteControllerProgressBarState extends State<RemoteControllerProgressBar> {
  List<VideoCoursePart> partList;
  int currentPartIndex;
  double partProgress;
  int remainingPartTime;
  Map<int, int> indexMapWithoutRest;
  int partAmountWithoutRest;
  bool isLiveRoomController;
  double currentPosition;
  CourseModel liveVideoModel;
  int startCourse;

  RemoteControllerProgressBarState(
      this.partList,
      this.currentPartIndex,
      this.partProgress,
      this.remainingPartTime,
      this.indexMapWithoutRest,
      this.partAmountWithoutRest,
      this.isLiveRoomController,
      this.liveVideoModel,
      this.startCourse);

  void setStateData(
      List<VideoCoursePart> partList,
      int currentPartIndex,
      double partProgress,
      int remainingPartTime,
      Map<int, int> indexMapWithoutRest,
      int partAmountWithoutRest,
      bool isLiveRoomController,
      double currentPosition,
      CourseModel liveVideoModel,
      int startCourse) {
    this.partList = partList;
    this.currentPartIndex = currentPartIndex;
    this.partProgress = partProgress;
    this.remainingPartTime = remainingPartTime;
    this.indexMapWithoutRest = indexMapWithoutRest;
    this.partAmountWithoutRest = partAmountWithoutRest;
    this.isLiveRoomController = isLiveRoomController;
    this.currentPosition = currentPosition;
    this.liveVideoModel = liveVideoModel;
    this.startCourse = startCourse;
    try {
      if (mounted) {
        setState(() {});
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    if (isLiveRoomController && currentPosition != null) {
      remainingPartTime = currentPosition.toInt();
    }
    String remainingPartString = DateUtil.formatMillisecondToMinuteAndSecond(remainingPartTime * 1000);
    if (isLiveRoomController && remainingPartTime == 0 && startCourse == null && liveVideoModel != null) {
      if (DateTime.now().millisecondsSinceEpoch <
          DateUtil.stringToDateTime(liveVideoModel.startTime).millisecondsSinceEpoch) {
        int subValue = DateUtil.stringToDateTime(liveVideoModel.startTime).millisecondsSinceEpoch -
            DateTime.now().millisecondsSinceEpoch;
        remainingPartString = DateUtil.formatSecondToStringNumShowMinute1((subValue+500) ~/ 1000);
      } else {
        remainingPartString = "即将开始";
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 214.5,
          width: 214.5,
          child: Stack(
            children: [
              Center(
                child: VideoCourseCircleProgressBar(partList, currentPartIndex, partProgress),
              ),
              Center(
                child: Text(
                  remainingPartString,
                  style: TextStyle(
                    color: AppColor.textPrimary1,
                    fontSize: remainingPartString.contains("即将开始") ? 16 : 32,
                    fontWeight: FontWeight.w500,
                    fontFamily: "BebasNeue",
                  ),
                ),
              ),
            ],
          ),
        ),
        Text(
          partList[currentPartIndex].type == 1
              ? "休息"
              : "${partList[currentPartIndex].name} ${indexMapWithoutRest[currentPartIndex] + 1}/$partAmountWithoutRest",
          style: TextStyle(color: AppColor.textPrimary2, fontSize: 16),
          softWrap: false,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        )
      ],
    );
  }
}
