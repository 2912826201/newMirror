import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/media_file_model.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/data/notifier/token_notifier.dart';
import 'package:mirror/page/feed/create_map_screen.dart';
import 'package:mirror/page/feed/feed_detail_page.dart';
import 'package:mirror/page/home/sub_page/share_page/share_page_sub_page/attention_user.dart';
import 'package:mirror/page/home/sub_page/share_page/share_page_sub_page/commentInputBox.dart';
import 'package:mirror/page/home/sub_page/share_page/share_page_sub_page/comment_layout.dart';
import 'package:mirror/page/home/sub_page/share_page/share_page_sub_page/course_address_label.dart';
import 'package:mirror/page/home/sub_page/share_page/share_page_sub_page/getTripleArea.dart';
import 'package:mirror/page/home/sub_page/share_page/share_page_sub_page/head_view.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/expandable_text.dart';
import 'package:mirror/widget/feed_video_player.dart';
import 'package:mirror/widget/slide_banner.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class DynamicListLayout extends StatelessWidget {
  DynamicListLayout(
      {Key key,
      this.index,
      this.isShowRecommendUser,
      this.model,
      this.pageName,
      this.deleteFeedChanged,
      this.isHero = false,
      this.removeFollowChanged,
      this.mineDetailId,
      this.topicId,
      this.isMySelf,
      this.isShowConcern = false})
      : super(key: key);
  final index;
  bool isShowRecommendUser;
  HomeFeedModel model;
  int mineDetailId;
  String pageName;

  // 话题详情页id
  int topicId;
  bool isHero;
  bool isMySelf;

  // 删除动态
  ValueChanged<int> deleteFeedChanged;

  // 取消关注
  ValueChanged<HomeFeedModel> removeFollowChanged;

  // 是否显示关注按钮
  bool isShowConcern;

  @override
  Widget build(BuildContext context) {
    // print('==============================动态itembuild');
    return Column(
      children: [
        // 头部头像时间
        HeadView(
            model: model,
            isShowConcern: isShowConcern,
            pageName: pageName,
            isMySelf: isMySelf,
            mineDetailId: mineDetailId != null ? mineDetailId : 0,
            deleteFeedChanged: (id) {
              deleteFeedChanged(id);
            },
            removeFollowChanged: (m) {
              removeFollowChanged(m);
            }),
        // 图片区域
        model.selectedMediaFiles != null && model.selectedMediaFiles.type == mediaTypeKeyImage
            ? SlideBanner(
                height: model.selectedMediaFiles.list.first.sizeInfo.height.toDouble(),
                model: model,
                index: index,
                pageName: pageName,
                isHero: isHero,
              )
            : model.picUrls.length > 0
                ? SlideBanner(
                    height: model.picUrls[0].height.toDouble(),
                    model: model,
                    index: index,
                    pageName: pageName,
                    isHero: isHero,
                  )
                : Container(),
        // 视频区域
        model.selectedMediaFiles != null && model.selectedMediaFiles.type == mediaTypeKeyVideo
            ? getVideo(selectedMediaFiles: model.selectedMediaFiles)
            : model.videos.isNotEmpty
                ? getVideo(videos: model.videos)
                : Container(),
        // 点赞，转发，评论三连区域 getTripleArea
        GetTripleArea(model: model, index: index),
        // 课程信息和地址
        Offstage(
          offstage: (model.address == null && model.courseDto == null),
          child: Container(
            margin: EdgeInsets.only(left: 16, right: 16),
            width: ScreenUtil.instance.width,
            child: getCourseInfo(model, context),
          ),
        ),

        // 文本文案
        Offstage(
          offstage: model.content.length == 0,
          child: Container(
            margin: EdgeInsets.only(left: 16, right: 16, top: 12),
            width: ScreenUtil.instance.screenWidthDp,
            child: ExpandableText(
              text: model.content,
              topicId: topicId,
              model: model,
              maxLines: 2,
              style: TextStyle(fontSize: 14, color: AppColor.textPrimary1),
            ),
          ),
        ),

        // 评论文本
        (context.watch<FeedMapNotifier>().feedMap != null &&
                context.watch<FeedMapNotifier>().feedMap[model.id] != null &&
                context.watch<FeedMapNotifier>().feedMap[model.id].comments != null &&
                context.watch<FeedMapNotifier>().feedMap[model.id].comments.length != 0)
            ? CommentLayout(model: model)
            : Container(),
        // 输入框
        CommentInputBox(feedModel: model),
        // 推荐用户
        getAttention(this.index, this.isShowRecommendUser),
        // 分割块
        Container(
          height: 18,
          color: AppColor.white,
        )
      ],
    );
  }

  // // 删除动态
  // deleteFeed() async {
  //   Map<String, dynamic> map = await deletefeed(id: model.id);
  //   if (map["state"]) {
  //     deleteFeedChanged(model.id);
  //   } else {
  //     print("删除失败");
  //   }
  // }
  //
  // // 关注or取消关注
  // removeFollow(int isFollow, int id, BuildContext context) async {
  //   print("isFollow:::::::::$isFollow");
  //   // 取消关注
  //   if (isFollow == 1) {
  //     int relation = await ProfileCancelFollow(id);
  //     if (relation == 0 || relation == 2) {
  //       // context.read<FeedMapNotifier>().setIsFollow(id, isFollow);
  //       removeFollowChanged(model);
  //       ToastShow.show(msg: "已取消关注", context: context);
  //     } else {
  //       ToastShow.show(msg: "取消关注失败", context: context);
  //     }
  //   }
  // }

// 视频
  Widget getVideo({List<VideosModel> videos, SelectedMediaFiles selectedMediaFiles}) {
    SizeInfo sizeInfo = SizeInfo();
    if (videos != null) {
      sizeInfo.width = videos.first.width;
      sizeInfo.height = videos.first.height;
      sizeInfo.duration = videos.first.duration;
      sizeInfo.offsetRatioX = videos.first.offsetRatioX ?? 0.0;
      sizeInfo.offsetRatioY = videos.first.offsetRatioY ?? 0.0;
      sizeInfo.videoCroppedRatio = videos.first.videoCroppedRatio;
      return FeedVideoPlayer(
        videos.first.url,
        sizeInfo,
        ScreenUtil.instance.width,
        isInListView: true,
      );
    }
    if (selectedMediaFiles != null) {
      print(selectedMediaFiles.list.first.toString());
      print( selectedMediaFiles.list.first.file.path,);
      sizeInfo.width = selectedMediaFiles.list.first.sizeInfo.width;
      sizeInfo.height = selectedMediaFiles.list.first.sizeInfo.height;
      sizeInfo.duration = selectedMediaFiles.list.first.sizeInfo.duration;
      sizeInfo.offsetRatioX = selectedMediaFiles.list.first.sizeInfo.offsetRatioX ?? 0.0;
      sizeInfo.offsetRatioY = selectedMediaFiles.list.first.sizeInfo.offsetRatioY ?? 0.0;
      sizeInfo.videoCroppedRatio = selectedMediaFiles.list.first.sizeInfo.videoCroppedRatio;
      return FeedVideoPlayer(
        selectedMediaFiles.list.first.file.path,
        sizeInfo,
        ScreenUtil.instance.width,
        isInListView: true,
        isFile: true,
      );
    }
  }

  // 课程信息和地址
  Widget getCourseInfo(HomeFeedModel model, BuildContext context) {
    List<String> tags = [];
    double longitude;
    double latitude;
    bool isAddress = false;
    bool isCourse = false;
    if (model.courseDto != null) {
      tags.add(model.courseDto.title);
      isCourse = true;
    }
    if (model.address != null) {
      tags.add(model.address);
      longitude = model.longitude;
      latitude = model.latitude;
      isAddress = true;
    }
    return Row(
      children: [
        for (String item in tags)
          GestureDetector(
            onTap: () {
              if (tags.length > 1) {
                if (tags.indexOf(item) == 0) {
                  AppRouter.navigateToVideoDetail(context, model.courseDto.id);
                } else {
                  AppRouter.navigateCreateMapScreenPage(
                    context,
                    longitude,
                    latitude,
                    model.address,
                  );
                }
              } else {
                if (isAddress) {
                  AppRouter.navigateCreateMapScreenPage(
                    context,
                    longitude,
                    latitude,
                    model.address,
                  );
                }
                if (isCourse) {
                  AppRouter.navigateToVideoDetail(context, model.courseDto.id);
                }
              }
            },
            child: CourseAddressLabel(item, tags),
          )
      ],
    );
  }

  // 列表3的推荐书籍
  Widget getAttention(var index, bool isShowRecommendUser) {
    if (index == 2 && isShowRecommendUser) {
      return AttentionUser();
    }
    return Container(
      width: 0,
      height: 0,
    );
  }
}
