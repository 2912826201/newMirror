//  动态子元素课程信息和地址标签
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/data/model/feed/feed_tag_model.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/text_util.dart';
import 'package:mirror/widget/icon.dart';

//FIXME 目前只支持tags最多2个标签 需要做优化兼容
class CourseAddressLabel extends StatelessWidget {
  final int index;
  final List<FeedTagModel> tags;

  CourseAddressLabel(this.index, this.tags);

  // 最外层圆角背景的宽度
  double getBgWidth() {
    // 获取屏幕宽度
    double screenWidth = ScreenUtil.instance.screenWidthDp;
    // 课程边框最大宽度
    double maxWidth = (screenWidth - 32 - 12) * 0.75; //减去两遍间距 32，再减去和地址的间距12.按照需求最大占剩下的4分之3，地址最大占4分之一
    // 文本最大宽度
    double textMaxWidth = maxWidth - 16 - 16 - 3; // 文本最大宽度要减去两边间距16，图片 16，文本和图片间距3.
    // 获取文本宽度
    double textWidth = getTextSize(tags[index].text, TextStyle(fontSize: 12), 1).width;
    // 获取背景边框宽度
    double BgWidth = textWidth + 16 + 16 + 3;
    // 为课程时
    if (index == 0) {
      // 文字宽度超长
      if (textWidth >= textMaxWidth) {
        return maxWidth;
      } else {
        return BgWidth;
      }
    } else {
      // 地址位置
      if (getTextSize(tags[0].text, TextStyle(fontSize: 12), 1).width >= textMaxWidth) {
        return (screenWidth - 32 - 12) * 0.25;
      } else {
        if (getTextSize(tags[0].text, TextStyle(fontSize: 12), 1).width + textWidth >
            (screenWidth - 32 - 12 - 32 - 3 - 32 - 3)) {
          return (screenWidth - 32 - 12) - getTextSize(tags[0].text, TextStyle(fontSize: 12), 1).width - 35;
        } else {
          return BgWidth;
        }
      }
    }
  }

  // 内层文本的宽度
  double getTextWidth() {
    // print("内层最大文本宽度${getBgWidth() - 16 - 16 - 3}");
    return getBgWidth() - 16 - 16 - 3;
  }

  // 截取文本添加...
  // 虽然有属性可设置，但是有个问题是汉字和数字，或者汉字和英文混排时，flutter 设置属性超出显示...数字和英文会自动换行。
  String interceptText(String textStr) {
    // 获取文本宽度
    double textWidth = getTextSize(tags[index].text, TextStyle(fontSize: 12), 1, getTextWidth()).width;
    if (textWidth > getTextWidth()) {
      String frontText = textStr.substring(0, getTextWidth() ~/ 13);
      if (interceptNum(frontText) > 0) {
        return textStr.substring(
                0, (getTextWidth() ~/ 12 + (interceptNum(frontText) ~/ (Platform.isIOS ? 2.1 : 1.5)))) +
            "...";
      }
      ;
      return frontText + "...";
    }
    return textStr;
  }

  // 判断截取了几个数字加小写英文
  int interceptNum(String str) {
    RegExp regExpStr = new RegExp(r"^[a-z0-9_]+$");
    var noChinesecharacter = 0;
    for (var i = 0; i < str.length; i++) {
      if (regExpStr.hasMatch(str[i])) {
        noChinesecharacter += 1;
      }
    }
    // print("存在$noChinesecharacter个非汉字");
    return noChinesecharacter;
  }

  @override
  Widget build(BuildContext context) {
    // coverUrls.indexOf(i)
    return Container(
      margin: EdgeInsets.only(left: index != 0 ? 12 : 0),
      padding: EdgeInsets.only(top: 3.5, bottom: 3.5),
      width: getBgWidth(),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        color: Color.fromRGBO(242, 242, 242, 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(left: 8),
            child: tags[index].type == feed_tag_type_location
                ? AppIcon.getAppIcon(AppIcon.tag_location, 16)
                : tags[index].type == feed_tag_type_course
                    ? AppIcon.getAppIcon(AppIcon.tag_course, 16)
                    : Container(
                        width: 16,
                      ),
          ),
          Container(
            width: getTextWidth(),
            child: Text(
              interceptText(tags[index].text),
              style: TextStyle(fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            margin: EdgeInsets.only(left: 3),
          ),
        ],
        // )
      ),
    );
  }
}
