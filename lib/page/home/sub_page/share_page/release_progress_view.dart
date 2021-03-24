import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/feed/post_feed.dart';
import 'package:mirror/data/model/media_file_model.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/icon.dart';
import 'package:provider/provider.dart';

class ReleaseProgressView extends StatefulWidget {
  ReleaseProgressView({Key key, this.postprogressModel, this.deleteReleaseFeedChanged, this.resendFeedChanged})
      : super(key: key);

  @override
  ReleaseProgressViewState createState() => ReleaseProgressViewState();

  // 删除本地插入的动态

  VoidCallback deleteReleaseFeedChanged;

  // 重新发布动态
  VoidCallback resendFeedChanged;

  //  发布动态model
  PostprogressModel postprogressModel;
}

class ReleaseProgressViewState extends State<ReleaseProgressView> {
  bool show = true;
  File imageFile;
  String type;

  @override
  Widget build(BuildContext context) {
    return widget.postprogressModel != null && widget.postprogressModel.showPulishView == true
        ? AnimatedOpacity(
            opacity: widget.postprogressModel != null && widget.postprogressModel.postFeedModel != null ? 1 : 0,
            duration: Duration(milliseconds: 1500),
            curve: Curves.ease,
            child: _publishView(),
            onEnd: () {
              widget.postprogressModel.showPulishView = false;
            },
          )
        : Container();
  }

  _publishView() {
    print('-----------------------￥￥￥￥发布视图');
    if (widget.postprogressModel != null &&
        widget.postprogressModel.postFeedModel != null &&
        widget.postprogressModel.postFeedModel.selectedMediaFiles != null) {
      type = widget.postprogressModel.postFeedModel.selectedMediaFiles.type;
      if (type == mediaTypeKeyVideo) {
        imageFile = File(widget.postprogressModel.postFeedModel.selectedMediaFiles.list.first.thumbPath);
      } else if (widget.postprogressModel.postFeedModel.selectedMediaFiles.list.first.file != null) {
        imageFile = widget.postprogressModel.postFeedModel.selectedMediaFiles.list.first.file;
      }
    }
    return Container(
      height: 60,
      width: ScreenUtil.instance.screenWidthDp,
      color: AppColor.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
              child: Container(
                  margin: EdgeInsets.only(left: 16, right: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        margin: EdgeInsets.only(right: 6),
                        child: Stack(
                          alignment: const FractionalOffset(0.5, 0.5),
                          children: [
                            imageFile != null ? Image.file(imageFile) : Container(),
                            type != null
                                ? type ==
                                        // context.watch<ReleaseProgressNotifier>().postFeedModel.selectedMediaFiles.type ==
                                        mediaTypeKeyVideo
                                    ? Container(
                                        width: 13,
                                        height: 13,
                                        color: AppColor.mainRed,
                                      )
                                    : Container()
                                : Container()
                          ],
                        ),
                      ),
                      publishTextStatus(widget.postprogressModel.plannedSpeed),
                      Spacer(),
                      Offstage(
                          offstage: widget.postprogressModel.plannedSpeed != -1,
                          child: Container(
                            child: Row(
                              children: [
                                AppIconButton(
                                  iconSize: 18,
                                  svgName: AppIcon.trash_bucket,
                                  buttonHeight: 30,
                                  buttonWidth: 30,
                                  onTap: widget.resendFeedChanged,
                                ),
                                AppIconButton(
                                  iconSize: 18,
                                  svgName: AppIcon.trash_bucket,
                                  buttonHeight: 30,
                                  buttonWidth: 30,
                                  onTap: widget.deleteReleaseFeedChanged,
                                ),
                              ],
                            ),
                          ))
                    ],
                  ))),
          LinearProgressIndicator(
            value: widget.postprogressModel.plannedSpeed != -1 ? widget.postprogressModel.plannedSpeed : 1,
            valueColor: new AlwaysStoppedAnimation<Color>(
                widget.postprogressModel.plannedSpeed != -1 ? AppColor.mainRed : Colors.amberAccent),
            backgroundColor: AppColor.white,
          ),
        ],
      ),
    );
  }

  // 发布动态进度条视图
  publishTextStatus(double plannedSpeed) {
    print("空值的来历￥￥$plannedSpeed");
    if (plannedSpeed >= 0 && plannedSpeed < 1) {
      return Text(
        "正在发布",
        style: AppStyle.textSecondaryRegular14,
      );
    } else if (plannedSpeed == 1) {
      return Text(
        "完成",
        style: AppStyle.textSecondaryRegular14,
      );
    } else if (plannedSpeed == -1) {
      return Container(
        // height: 36,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "发布失败",
              style: AppStyle.textMedium14,
            ),
            Text(
              "我们会在网络信号改善时重试",
              style: AppStyle.textSecondaryRegular11,
            )
          ],
        ),
      );
    }
  }
}
