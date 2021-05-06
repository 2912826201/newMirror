import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
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

  RemoteControllerProgressBar(Key key, this.partList, this.currentPartIndex, this.partProgress, this.remainingPartTime,
      this.indexMapWithoutRest, this.partAmountWithoutRest, this.isLiveRoomController)
      : super(key: key);

  @override
  RemoteControllerProgressBarState createState() => RemoteControllerProgressBarState(partList, currentPartIndex,
      partProgress, remainingPartTime, indexMapWithoutRest, partAmountWithoutRest, isLiveRoomController);
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

  RemoteControllerProgressBarState(this.partList, this.currentPartIndex, this.partProgress, this.remainingPartTime,
      this.indexMapWithoutRest, this.partAmountWithoutRest, this.isLiveRoomController);

  void setStateData(List<VideoCoursePart> partList, int currentPartIndex, double partProgress, int remainingPartTime,
      Map<int, int> indexMapWithoutRest, int partAmountWithoutRest, bool isLiveRoomController, double currentPosition) {
    this.partList = partList;
    this.currentPartIndex = currentPartIndex;
    this.partProgress = partProgress;
    this.remainingPartTime = remainingPartTime;
    this.indexMapWithoutRest = indexMapWithoutRest;
    this.partAmountWithoutRest = partAmountWithoutRest;
    this.isLiveRoomController = isLiveRoomController;
    this.currentPosition = currentPosition;
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
                  DateUtil.formatMillisecondToMinuteAndSecond(remainingPartTime * 1000),
                  style: TextStyle(
                    color: AppColor.textPrimary1,
                    fontSize: 32,
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
        )
      ],
    );
  }
}
