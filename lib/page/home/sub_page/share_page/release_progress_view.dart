import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/media_file_model.dart';
import 'package:mirror/data/notifier/release_progress_notifier.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:provider/provider.dart';

class ReleaseProgressView extends StatefulWidget {
  @override
  ReleaseProgressViewState createState() => ReleaseProgressViewState();

}

class ReleaseProgressViewState extends State<ReleaseProgressView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: ScreenUtil.instance.screenWidthDp,
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
                      context.watch<ReleaseProgressNotifier>().postFeedModel.selectedMediaFiles != null
                          ? Container(
                        width: 36,
                        height: 36,
                        margin: EdgeInsets.only(right: 6),
                        child: Stack(
                          alignment: const FractionalOffset(0.5, 0.5),
                          children: [
                            context.watch<ReleaseProgressNotifier>().postFeedModel.selectedMediaFiles.type ==
                                mediaTypeKeyVideo
                                ? Image.memory(
                              context
                                  .watch<ReleaseProgressNotifier>()
                                  .postFeedModel
                                  .selectedMediaFiles
                                  .list
                                  .first
                                  .thumb,
                              fit: BoxFit.cover,
                            )
                                : context
                                .watch<ReleaseProgressNotifier>()
                                .postFeedModel
                                .selectedMediaFiles
                                .list
                                .first
                                .croppedImageData !=
                                null
                                ? Image.memory(
                              context
                                  .watch<ReleaseProgressNotifier>()
                                  .postFeedModel
                                  .selectedMediaFiles
                                  .list
                                  .first
                                  .croppedImageData,
                              fit: BoxFit.cover,
                            )
                                : context
                                .watch<ReleaseProgressNotifier>()
                                .postFeedModel
                                .selectedMediaFiles
                                .list
                                .first
                                .file !=
                                null
                                ? Image.file(
                              context
                                  .watch<ReleaseProgressNotifier>()
                                  .postFeedModel
                                  .selectedMediaFiles
                                  .list
                                  .first
                                  .file,
                              fit: BoxFit.cover,
                            )
                                : Container(),
                            context.watch<ReleaseProgressNotifier>().postFeedModel.selectedMediaFiles.type ==
                                mediaTypeKeyVideo
                                ? Container(
                              width: 13,
                              height: 13,
                              color: AppColor.mainRed,
                            )
                                : Container()
                          ],
                        ),
                      )
                          : Container(),
                      publishTextStatus(context.watch<ReleaseProgressNotifier>().plannedSpeed),
                      Spacer(),
                      Offstage(
                          offstage: context.watch<ReleaseProgressNotifier>().plannedSpeed != -1,
                          child: Container(
                            width: 48,
                            child: Row(
                              children: [
                                Container(
                                  width: 18,
                                  height: 18,
                                  color: Colors.lime,
                                ),
                                Spacer(),
                                Container(
                                  width: 18,
                                  height: 18,
                                  color: Colors.lime,
                                ),
                              ],
                            ),
                          ))
                    ],
                  ))),
          LinearProgressIndicator(
            value: context.watch<ReleaseProgressNotifier>().plannedSpeed != -1
                ? context.watch<ReleaseProgressNotifier>().plannedSpeed
                : 1,
            valueColor: new AlwaysStoppedAnimation<Color>(
                context.watch<ReleaseProgressNotifier>().plannedSpeed != -1 ? AppColor.mainRed : Colors.amberAccent),
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
        height: 36,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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