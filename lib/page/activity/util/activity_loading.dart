import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/activity/activity_model.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/text_util.dart';
import 'package:shimmer/shimmer.dart';

class ActivityLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      child: ListView.builder(
        itemBuilder: (context, index) => Card(
          clipBehavior: Clip.hardEdge,
          color: AppColor.layoutBgGrey,
          margin: EdgeInsets.only(left: 16, right: 16, top: index == 0 ? 18 : 12),
          child: Container(
            margin: EdgeInsets.only(top: 12, bottom: 12),
            height: 140,
            width: ScreenUtil.instance.width,
          ),
        ),
        itemCount: 20,
      ),
      baseColor: AppColor.layoutBgGrey.withOpacity(0.5),
      highlightColor: AppColor.layoutBgGrey.withOpacity(0.1),
      // enabled: _enabled,
    );
  }
}

// 截取文本
interceptText(ActivityModel activityModel) {
  activityModel.activityTitle1 = null;
  activityModel.activityTitle = null;
  if (activityModel.status == 0 || activityModel.status == 1) {
    activityModel.tagWidth = 56.0;
  } else if (activityModel.status == 3) {
    activityModel.tagWidth = 62.0;
  } else if (activityModel.status == 2) {
    activityModel.tagWidth = 59.0;
  }
  // 剩余宽度
  double remainingWidth = ScreenUtil.instance.width * 0.49 - activityModel.tagWidth;
  // 文本总宽度
  double totalTextWidth = 0.0;
  activityModel.title.runes.forEach((element) {
    // 文本宽度
    double textWidth;
    textWidth = getTextSize(String.fromCharCode(element), AppStyle.whiteMedium17, 1).width;
    totalTextWidth += textWidth;
    if (totalTextWidth > remainingWidth) {
      if (activityModel.activityTitle1 == null) {
        activityModel.activityTitle1 = '\u200B';
      }
      activityModel.activityTitle1 += String.fromCharCode(element);
    } else {
      if (activityModel.activityTitle == null) {
        activityModel.activityTitle = '\u200B';
      }
      activityModel.activityTitle += String.fromCharCode(element);
    }
  });
}