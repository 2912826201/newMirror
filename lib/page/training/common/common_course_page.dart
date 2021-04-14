//当没有加载完成或者没有加载成功时的title
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/training/live_video_model.dart';
import 'package:mirror/util/date_util.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/util/integer_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/icon.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

Widget getNoCompleteTitle(BuildContext context, String text) {
  return Container(
    height: CustomAppBar.appBarHeight,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          width: CustomAppBar.appBarHorizontalPadding,
        ),
        CustomAppBarIconButton(
          svgName: AppIcon.nav_return,
          iconColor: AppColor.black,
          onTap: () => Navigator.pop(context),
        ),
        Text(
          text,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: AppColor.textPrimary1,
          ),
        ),
        CustomAppBarIconButton(
          svgName: AppIcon.nav_share,
          iconColor: AppColor.black,
          onTap: () {
            ToastShow.show(msg: "当前数据没有加载完毕！", context: context);
          },
        ),
        SizedBox(
          width: CustomAppBar.appBarHorizontalPadding,
        ),
      ],
    ),
  );
}

//获取课程显示的图片
String getCourseShowImage(LiveVideoModel courseModel) {
  String imageUrl;
  if (courseModel.picUrl != null) {
    imageUrl = courseModel.picUrl;
  } else if (courseModel.coursewareDto?.picUrl != null) {
    imageUrl = courseModel.coursewareDto?.picUrl;
  } else if (courseModel.coursewareDto?.previewVideoUrl != null) {
    imageUrl = courseModel.coursewareDto?.previewVideoUrl;
  }
  return imageUrl;
}

//获取训练数据ui
Widget getTitleWidget(LiveVideoModel videoModel, BuildContext context, GlobalKey globalKey) {
  var widgetArray = <Widget>[];
  var titleArray = [
    ((videoModel.times ?? 0) ~/ 60000).toString(),
    IntegerUtil.formationCalorie(videoModel.calories, isHaveCompany: false),
    videoModel.levelDto?.ename
  ];
  var subTitleArray = ["分钟", "千卡", videoModel.levelDto?.name];
  var tagArray = ["时间", "消耗", "难度"];

  for (int i = 0; i < titleArray.length; i++) {
    widgetArray.add(Container(
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              verticalDirection: VerticalDirection.down,
              children: [
                Text(
                  titleArray[i] ?? "",
                  style: AppStyle.textPrimary2Medium23,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(
                  width: 2,
                ),
                Container(
                  child: Text(
                    subTitleArray[i] ?? "",
                    style: TextStyle(fontSize: 12, color: AppColor.textPrimary3),
                  ),
                  margin: const EdgeInsets.only(top: 4),
                )
              ],
            ),
          ),
          SizedBox(
            height: 6,
          ),
          Text(
            tagArray[i],
            style: TextStyle(fontSize: 12, color: AppColor.textHint),
          ),
        ],
      ),
      width: (MediaQuery.of(context).size.width - 1) / 3,
    ));
    if (i < titleArray.length - 1) {
      widgetArray.add(Container(
        width: 0.5,
        height: 18,
        color: AppColor.textHint,
      ));
    }
  }
  return SliverToBoxAdapter(
    child: Container(
      width: double.infinity,
      color: AppColor.white,
      key: globalKey,
      padding: const EdgeInsets.only(top: 14, bottom: 14),
      child: Row(
        children: widgetArray,
      ),
    ),
  );
}

//获取教练的名字
Widget getCoachItem(LiveVideoModel videoModel, BuildContext context, Function onClickAttention, Function onClickCoach,
    GlobalKey globalKey) {
  return SliverToBoxAdapter(
    child: GestureDetector(
      onTap: onClickCoach,
      child: Container(
        key: globalKey,
        padding: const EdgeInsets.only(left: 16),
        margin: const EdgeInsets.only(bottom: 12),
        color: Colors.white,
        width: double.infinity,
        height: 48.0,
        child: Row(
          children: [
            Container(
              height: 32,
              width: 32,
              decoration: BoxDecoration(
                color: Colors.white,
                // border: Border.all(width: 0.0, color: Colors.black),
                borderRadius: BorderRadius.circular(30),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.network(
                  videoModel.coachDto?.avatarUri ?? "",
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(
              width: 12,
            ),
            Container(
              child: Text(
                // ignore: null_aware_before_operator
                videoModel.coachDto?.nickName ?? "",
                style: AppStyle.textPrimary2Medium14,
              ),
            ),
            Expanded(child: SizedBox()),
            GestureDetector(
              onTap: onClickAttention,
              child: Container(
                color: Colors.transparent,
                height: 48.0,
                padding: EdgeInsets.only(right: 16),
                child: UnconstrainedBox(
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(100)),
                    child: Material(
                        borderRadius: BorderRadius.all(Radius.circular(100)),
                        color: videoModel.coachDto?.relation == 1 || videoModel.coachDto?.relation == 3
                            ? AppColor.white
                            : AppColor.black,
                        child: InkWell(
                          splashColor: AppColor.textHint,
                          onTap: onClickAttention,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(100)),
                              border: Border.all(
                                  width: videoModel.coachDto?.relation == 1 || videoModel.coachDto?.relation == 3
                                      ? 1
                                      : 0.0,
                                  color: AppColor.textHint),
                            ),
                            padding: const EdgeInsets.only(left: 16, right: 16, top: 5, bottom: 5),
                            child: Text(
                              videoModel.coachDto?.relation == 1 || videoModel.coachDto?.relation == 3 ? "已关注" : "关注",
                              style: TextStyle(
                                  color: videoModel.coachDto?.relation == 1 || videoModel.coachDto?.relation == 3
                                      ? AppColor.textHint
                                      : AppColor.white,
                                  fontSize: 11),
                            ),
                          ),
                        )),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

//获取横线
Widget getLineView() {
  return SliverToBoxAdapter(
    child: Container(
      width: double.infinity,
      height: 12,
      color: AppColor.bgWhite.withOpacity(0.65),
    ),
  );
}

//训练器材界面
Widget getTrainingEquipmentUi(
    LiveVideoModel videoModel, BuildContext context, TextStyle titleTextStyle, GlobalKey globalKey) {
  var widgetList = <Widget>[];
  widgetList.add(Container(
    padding: const EdgeInsets.only(left: 16),
    child: Text(
      "训练器材",
      style: titleTextStyle,
    ),
  ));

  widgetList.add(Expanded(child: SizedBox()));

  if (videoModel.equipmentDtos == null || videoModel.equipmentDtos.length < 1) {
    widgetList.add(Container(
      padding: const EdgeInsets.only(right: 32),
      child: Text(
        "无",
        style: TextStyle(fontSize: 14, color: AppColor.textSecondary),
      ),
    ));
  } else {
    List<String> terminalPicUrlList = getTerminalPicUrlList(videoModel.equipmentDtos);
    for (int i = 0; i < terminalPicUrlList.length; i++) {
      widgetList.add(Container(
        color: AppColor.color707070.withOpacity(0.05),
        margin: const EdgeInsets.all(8),
        child: Image.network(
          terminalPicUrlList[i] ?? "",
          width: 24,
          height: 24,
          fit: BoxFit.cover,
        ),
      ));
    }
  }

  return SliverToBoxAdapter(
    child: Container(
        key: globalKey,
        width: MediaQuery.of(context).size.width,
        margin: const EdgeInsets.only(top: 12),
        child: Column(
          children: [
            Container(
              height: 48,
              padding: const EdgeInsets.only(right: 4),
              child: Row(
                children: widgetList,
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 1,
              margin: const EdgeInsets.only(left: 16, right: 16),
              color: AppColor.bgWhite,
            ),
          ],
        )),
  );
}

List<String> getTerminalPicUrlList(List<EquipmentDtos> equipmentDtos) {
  List<String> stringArray = <String>[];
  for (int i = 0; i < equipmentDtos.length; i++) {
    if (!stringArray.contains(equipmentDtos[i].terminalPicUrl)) {
      stringArray.add(equipmentDtos[i].terminalPicUrl);
    }
  }
  return stringArray;
}

//获取动作的ui
Widget getActionUiVideo(LiveVideoModel videoModel, BuildContext context, TextStyle titleTextStyle) {
  // ignore: null_aware_before_operator
  if (videoModel.coursewareDto?.actionMapList == null || videoModel.coursewareDto?.actionMapList?.length < 1) {
    return SliverToBoxAdapter();
  }
  var widgetArray = <Widget>[];
  widgetArray.add(Container(
    padding: const EdgeInsets.only(left: 16, top: 24, bottom: 11.5),
    width: double.infinity,
    child: Text(
      "动作${videoModel.coursewareDto?.actionMapList?.length}个",
      style: titleTextStyle,
    ),
  ));

  widgetArray.add(Container(
    width: double.infinity,
    height: 1,
    margin: const EdgeInsets.only(left: 16, right: 16),
    color: AppColor.bgWhite,
  ));

  widgetArray.add(
    Container(
      width: double.infinity,
      height: 66,
      margin: const EdgeInsets.only(top: 18, bottom: 18),
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: videoModel.coursewareDto?.actionMapList?.length,
          itemBuilder: (context, index) {
            String timeString = "";
            int longTime = 0;
            try {
              longTime = videoModel.coursewareDto?.actionMapList[index]["endTime"] -
                  videoModel.coursewareDto?.actionMapList[index]["startTime"];
            } catch (e) {
              longTime = 0;
            }
            if (longTime > 0) {
              timeString = DateUtil.formatSecondToStringNumNoShowMinute(longTime ~/ 1000) + "'${((longTime % 1000) ~/ 10)}'";
            }
            return Container(
              width: 136,
              height: 66,
              padding: const EdgeInsets.all(12),
              margin: index == 0
                  ? const EdgeInsets.only(left: 15.5, right: 4)
                  // ignore: null_aware_before_operator
                  : (index ==
                          // ignore: null_aware_before_operator
                          videoModel.coursewareDto?.actionMapList?.length - 1
                      ? const EdgeInsets.only(left: 4, right: 15.5)
                      : const EdgeInsets.only(left: 4, right: 4)),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: AppColor.bgWhite,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    width: double.infinity,
                    child: Text(
                      videoModel.coursewareDto?.actionMapList[index]["name"] ?? "",
                      style: TextStyle(fontSize: 14, color: AppColor.textPrimary2),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                      width: double.infinity,
                      child: Text(
                        timeString,
                        style: TextStyle(fontSize: 12, color: AppColor.textSecondary),
                      )),
                ],
              ),
            );
          }),
    ),
  );

  return SliverToBoxAdapter(
    child: Container(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: widgetArray,
      ),
    ),
  );
}

//获取动作的ui
Widget getActionUiLive(
    LiveVideoModel liveModel, BuildContext context, GlobalKey globalKey, bool isShowAllItem, Function onClick) {
  if (liveModel == null ||
      liveModel.coursewareDto == null ||
      liveModel.coursewareDto.actionMapList == null ||
      liveModel.coursewareDto.actionMapList.length < 1) {
    return SliverToBoxAdapter();
  }

  var widgetArray = <Widget>[];
  widgetArray.add(Container(
    padding: const EdgeInsets.only(left: 16, top: 24, bottom: 11.5),
    width: double.infinity,
    child: Text(
      "动作${liveModel.coursewareDto?.actionMapList?.length}个",
      style: AppStyle.textMedium18,
    ),
  ));

  int length = 0;
  if (isShowAllItem || liveModel.coursewareDto.actionMapList.length < 5) {
    length = liveModel.coursewareDto.actionMapList.length;
  } else {
    length = 5;
  }

  for (int i = 0; i < length; i++) {
    widgetArray.add(Container(
      width: double.infinity,
      height: 0.5,
      margin: const EdgeInsets.only(left: 16, right: 16),
      color: AppColor.bgWhite,
    ));

    String timeString = "";
    int longTime = 0;
    try {
      longTime =
          liveModel.coursewareDto?.actionMapList[i]["endTime"] - liveModel.coursewareDto?.actionMapList[i]["startTime"];
    } catch (e) {
      longTime = 0;
    }
    if (longTime > 0) {
      timeString = DateUtil.formatSecondToStringNumNoShowMinute(longTime ~/ 1000) + "'${((longTime % 1000) ~/ 10)}'";
    }

    widgetArray.add(
      Container(
        width: double.infinity,
        margin: const EdgeInsets.only(left: 16, right: 16),
        padding: const EdgeInsets.only(top: 13.5, bottom: 13),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              liveModel.coursewareDto?.actionMapList[i]["name"] ?? "未知动作",
              style: AppStyle.textPrimary2Regular16,
            ),
            Text(
              timeString,
              style: AppStyle.textSecondaryRegular14,
            ),
          ],
        ),
      ),
    );
  }

  if (length < liveModel.coursewareDto.actionMapList.length) {
    widgetArray.add(Container(
      width: double.infinity,
      height: 0.5,
      margin: const EdgeInsets.only(left: 16, right: 16),
      color: AppColor.bgWhite,
    ));
    widgetArray.add(GestureDetector(
      child: Container(
        padding: const EdgeInsets.only(left: 16, top: 24, bottom: 11.5),
        width: double.infinity,
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.keyboard_arrow_down, size: 16, color: AppColor.black),
            SizedBox(width: 6),
            Text(
              "查看全部${liveModel.coursewareDto.actionMapList.length}个动作",
              style: TextStyle(fontSize: 14, color: AppColor.textPrimary2),
            )
          ],
        ),
      ),
      onTap: onClick,
    ));
  }

  return SliverToBoxAdapter(
    child: Container(
      width: double.infinity,
      key: globalKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: widgetArray,
      ),
    ),
  );
}

//其他人完成的训练ui
Widget getOtherUsersUi(List<HomeFeedModel> recommendTopicList, BuildContext context, TextStyle titleTextStyle,
    Function(int onClickPosition) onClick, GlobalKey globalKey, String pageName) {
  if (recommendTopicList != null && recommendTopicList.length > 0) {
    var imageArray = <Widget>[];
    for (int i = 0; i < recommendTopicList.length; i++) {
      String url = "";
      if (recommendTopicList[i].picUrls != null && recommendTopicList[i].picUrls.length > 0) {
        url = recommendTopicList[i].picUrls[0].url;
      } else if (recommendTopicList[i].videos != null && recommendTopicList[i].videos.length > 0) {
        url = FileUtil.getVideoFirstPhoto(recommendTopicList[i].videos[0].url);
      }
      imageArray.add(
        Hero(
          tag: "$pageName${recommendTopicList[i].id}$i",
          child: GestureDetector(
            child: Container(
              color: AppColor.transparent,
              margin: const EdgeInsets.only(right: 8),
              child: Image.network(
                url,
                fit: BoxFit.cover,
              ),
              width: (MediaQuery.of(context).size.width - 16 * 3) / 3,
              height: (MediaQuery.of(context).size.width - 16 * 3) / 3,
            ),
            onTap: () => onClick(i),
          ),
        ),
      );
    }

    return SliverToBoxAdapter(
      child: Container(
        key: globalKey,
        color: AppColor.transparent,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 12,
              color: AppColor.bgWhite.withOpacity(0.65),
            ),
            GestureDetector(
              child: Container(
                color: Colors.transparent,
                padding: const EdgeInsets.only(top: 23, bottom: 11),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(left: 16),
                      child: Text(
                        "TA们刚刚完成训练",
                        style: titleTextStyle,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(right: 16),
                      child: AppIcon.getAppIcon(AppIcon.arrow_right_16, 16, color: AppColor.textHint),
                    ),
                  ],
                ),
              ),
              onTap: () => onClick(-1),
            ),
            Container(
              width: double.infinity,
              height: 1,
              margin: const EdgeInsets.only(left: 16, right: 16),
              color: AppColor.bgWhite,
            ),
            SizedBox(
              height: 12,
            ),
            Container(
              padding: const EdgeInsets.only(left: 16, right: 8),
              child: Row(
                children: imageArray,
              ),
            ),
            SizedBox(
              height: 16,
            ),
          ],
        ),
      ),
    );
  } else {
    return SliverToBoxAdapter(
      child: Container(key: globalKey),
    );
  }
}

//课程评论的头部
Widget getCourseTopText(TextStyle titleTextStyle) {
  return Container(
    padding: const EdgeInsets.only(left: 16, top: 10, bottom: 10),
    width: double.infinity,
    child: Text(
      "课程评论",
      style: titleTextStyle,
    ),
  );
}

//课程评论的头部数据
Widget getCourseTopNumber(bool isHotOrTime, int courseCommentCount, Function onHotClickBtn, Function onTimeClickBtn) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.only(left: 16.5, right: 16, top: 8),
    child: Row(
      children: [
        Text(
          "$courseCommentCount评论",
          style: TextStyle(fontSize: 16, color: AppColor.textPrimary1),
        ),
        Expanded(child: SizedBox()),
        InkWell(
          child: Text(
            "按热度",
            style: isHotOrTime ? AppStyle.textMedium14 : AppStyle.textSecondaryRegular14,
          ),
          splashColor: AppColor.textHint1,
          onTap: onHotClickBtn,
        ),
        SizedBox(
          width: 7,
        ),
        Container(
          width: 0.5,
          height: 15.5,
          color: AppColor.textHint1,
        ),
        SizedBox(
          width: 7,
        ),
        InkWell(
          child: Text(
            "按时间",
            style: !isHotOrTime ? AppStyle.textMedium14 : AppStyle.textSecondaryRegular14,
          ),
          splashColor: AppColor.textHint1,
          onTap: onTimeClickBtn,
        ),
      ],
    ),
  );
}

//课程评论输入框
Widget getCourseTopEdit(Function editClick) {
  return Center(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          margin: EdgeInsets.only(left: 16),
          width: 28,
          height: 28,
          child: getUserImage(Application.profile.avatarUri, 28, 28),
        ),
        GestureDetector(
          child: Container(
            width: ScreenUtil.instance.screenWidthDp - 32 - 40,
            height: 28,
            margin: EdgeInsets.only(left: 12),
            padding: EdgeInsets.only(left: 16),
            alignment: Alignment(-1, 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(14)),
              color: AppColor.bgWhite.withOpacity(0.65),
            ),
            child: Text("说点什么吧", style: TextStyle(fontSize: 14, color: AppColor.textHint)),
          ),
          onTap: editClick,
        ),
      ],
    ),
  );
}

//评论没有数据
Widget getCommentNoData() {
  return Container(
    child: Column(
      children: [
        Image.asset(
          "assets/png/default_no_data.png",
          fit: BoxFit.cover,
          width: 224,
          height: 224,
        ),
        SizedBox(
          height: 16,
        ),
        Text(
          "偷偷逆袭中，还没有人来冒泡呢",
          style: TextStyle(fontSize: 14, color: AppColor.textSecondary),
        )
      ],
    ),
  );
}

//获取有几个子评论
String getSubCommentComplete(CommentDtoModel value, bool isFold) {
  if (value == null) {
    return "";
  }

  int valueReplyLength = 0;
  if (value.replys == null || value.replys.length < 1) {
    valueReplyLength = 0;
  } else {
    valueReplyLength = value.replys.length;
  }

  // print("valueReplyLength$valueReplyLength${value.replyCount}${value.pullNumber}");

  var subCommentCompleteTitle = valueReplyLength < value.replyCount + value.pullNumber ? "查看" : (isFold ? "查看" : "隐藏");

  if (subCommentCompleteTitle == "隐藏") {
    return "隐藏回复";
  } else {
    if (isFold) {
      if (valueReplyLength > 0) {
        return "$subCommentCompleteTitle$valueReplyLength条回复";
      } else {
        return "$subCommentCompleteTitle${value.replyCount + value.pullNumber}条回复";
      }
    } else {
      if (valueReplyLength >= value.replyCount + value.pullNumber) {
        return "隐藏回复";
      } else {
        return "$subCommentCompleteTitle${value.replyCount - (valueReplyLength - value.pullNumber)}条回复";
      }
    }
  }
}

//获取用户的头像
Widget getUserImage(String imageUrl, double height, double width) {
  if (imageUrl == null || imageUrl == "") {
    imageUrl = "http://pic.netbian.com/uploads/allimg/201220/220540-16084731404798.jpg";
  }
  return ClipRRect(
    borderRadius: BorderRadius.circular(height / 2),
    child: CachedNetworkImage(
      height: height,
      width: width,
      imageUrl: imageUrl == null ? "" : imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: AppColor.bgWhite,
      ),
      errorWidget: (context, url, error) => Container(
        color: AppColor.bgWhite,
      ),
    ),
  );
}
