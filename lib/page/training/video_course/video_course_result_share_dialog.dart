import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/config/runtime_properties.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/media_file_model.dart';
import 'package:mirror/data/model/training/course_model.dart';
import 'package:mirror/data/model/training/training_complete_result_model.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/util/integer_util.dart';
import 'package:mirror/widget/icon.dart';

import 'video_course_result_page.dart';

/// video_course_result_share_page
/// Created by yangjiayi on 2021/5/7.


class VideoCourseResultShareDialog extends Dialog {
  final TrainingCompleteResultModel result;
  final CourseModel course;

  VideoCourseResultShareDialog(this.result, this.course, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: _VideoCourseResultSharePage(result, course),
      ),
    );
  }
}

class _VideoCourseResultSharePage extends StatefulWidget {
  final TrainingCompleteResultModel result;
  final CourseModel course;

  _VideoCourseResultSharePage(this.result, this.course, {Key key}) : super(key: key);

  @override
  _VideoCourseResultShareState createState() => _VideoCourseResultShareState();
}

class _VideoCourseResultShareState extends State<_VideoCourseResultSharePage> {
  var _cropperKey = GlobalKey<_VideoCourseResultShareState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _checkMounted();
    });
  }

  _checkMounted() {
    if (mounted) {
      Future.delayed(Duration(seconds: 1), () {
        _generateImageAndPublish();
      });
    } else {
      Future.delayed(Duration(seconds: 1), () {
        _checkMounted();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 574,
      width: 375,
      child: RepaintBoundary(
        key: _cropperKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 494,
              width: 375,
              child: Stack(
                children: [
                  Image.asset(
                    "assets/png/video_course_result_share_bg.png",
                    height: 494,
                    width: 375,
                    fit: BoxFit.cover,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 44,
                      ),
                      _buildUserInfo(),
                      SizedBox(
                        height: 20,
                      ),
                      _buildText(),
                      _buildChart(),
                      _buildScoreInfo(),
                      SizedBox(
                        height: 33.5,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              height: 80,
              width: 375,
              alignment: Alignment.center,
              color: AppColor.white,
              child: Image.asset(
                "assets/png/video_course_result_share_logo.png",
                height: 24,
                width: 134,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Padding(
      padding: const EdgeInsets.only(left: 36, right: 36),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                //??????????????????????????????????????????
                border: Border.all(width: 1.5, color: AppColor.white)),
            child: ClipOval(
              child: CachedNetworkImage(
                height: 40,
                width: 40,
                imageUrl: FileUtil.getSmallImage(Application.profile.avatarUri),
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppColor.bgWhite,
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppColor.bgWhite,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 8,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Application.profile.nickName,
                  softWrap: false,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppStyle.text1Regular15,
                ),
                SizedBox(
                  height: 3,
                ),
                Text(
                  "?????????iFitness??????????????????????????????~",
                  softWrap: false,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppStyle.text2Regular12,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    return Expanded(
      child: Container(
        width: 375,
        alignment: Alignment.center,
        child: PentagonChart(
          width: 102.0,
          rateList: [
            //???????????? ?????????25???
            widget.result.synthesisRank > 25 ? widget.result.synthesisRank / 100 : 0.25,
            widget.result.completionDegree > 25 ? widget.result.completionDegree / 100 : 0.25,
            widget.result.lowerRank > 25 ? widget.result.lowerRank / 100 : 0.25,
            widget.result.upperRank > 25 ? widget.result.upperRank / 100 : 0.25,
            widget.result.coreRank > 25 ? widget.result.coreRank / 100 : 0.25
          ],
          fontColor: AppColor.white.withOpacity(0.65),
          fontSize: 13.5,
        ),
      ),
    );
  }

  Widget _buildText() {
    return Container(
      height: 70,
      padding: const EdgeInsets.only(left: 36, right: 36),
      child: Text(
        "???${widget.result.no}?????????\n${widget.course.title}",
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: AppStyle.whiteMedium16,
      ),
    );
  }

  Widget _buildScoreInfo() {
    return Container(
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
                      "${widget.result.synthesisScore}",
                      style: AppStyle.whiteRegular23,
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
                      "??????????????????",
                      style: AppStyle.whiteRegular12,
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
                      "${IntegerUtil.formationCalorie(widget.result.calorie, isHaveCompany: false)}",
                      style: AppStyle.whiteRegular23,
                    ),
                    SizedBox(
                      width: 2,
                    ),
                    Text(
                      "??????",
                      style: AppStyle.whiteRegular12,
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
                      "??????????????????",
                      style: AppStyle.whiteRegular12,
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
                      "${widget.result.mseconds ~/ 60000}",
                      style: AppStyle.whiteRegular23,
                    ),
                    SizedBox(
                      width: 2,
                    ),
                    Text(
                      "??????",
                      style: AppStyle.whiteRegular12,
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
                      "????????????",
                      style: AppStyle.whiteRegular12,
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _generateImageAndPublish() async {
    RenderRepaintBoundary boundary = _cropperKey.currentContext.findRenderObject();
    double dpr = ui.window.devicePixelRatio; // ??????????????????????????????
    ui.Image image = await boundary.toImage(pixelRatio: dpr);
    print("????????????ByteData" + DateTime.now().millisecondsSinceEpoch.toString());
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    print("????????????ByteData" + DateTime.now().millisecondsSinceEpoch.toString());
    Uint8List picBytes = byteData.buffer.asUint8List();
    print("????????????Uint8List" + DateTime.now().millisecondsSinceEpoch.toString());
    SelectedMediaFiles selectedMediaFiles = SelectedMediaFiles();
    selectedMediaFiles.type = mediaTypeKeyImage;
    MediaFileModel mediaFileModel = MediaFileModel();
    mediaFileModel.type = mediaTypeKeyImage;
    mediaFileModel.croppedImageData = picBytes;
    mediaFileModel.sizeInfo.width = image.width;
    mediaFileModel.sizeInfo.height = image.height;
    selectedMediaFiles.list = [mediaFileModel];
    RuntimeProperties.selectedMediaFiles = selectedMediaFiles;
    Navigator.pop(context);
    AppRouter.navigateToReleasePage(context, videoCourseId: widget.course.id);
  }
}
