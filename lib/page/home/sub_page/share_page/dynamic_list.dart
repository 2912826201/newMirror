import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/feed/feed_tag_model.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/media_file_model.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/page/home/sub_page/share_page/share_page_sub_page/attention_user.dart';
import 'package:mirror/page/home/sub_page/share_page/share_page_sub_page/commentInputBox.dart';
import 'package:mirror/page/home/sub_page/share_page/share_page_sub_page/comment_layout.dart';
import 'package:mirror/page/home/sub_page/share_page/share_page_sub_page/course_address_label.dart';
import 'package:mirror/page/home/sub_page/share_page/share_page_sub_page/getTripleArea.dart';
import 'package:mirror/page/home/sub_page/share_page/share_page_sub_page/head_view.dart';
import 'package:mirror/page/home/sub_page/share_page/share_page_sub_page/better_video_player.dart';
import 'package:mirror/page/test/viewer_video_test.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/date_util.dart';
import 'package:mirror/util/event_bus.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/expandable_text.dart';
import 'package:mirror/widget/feed_video_player.dart';
import 'package:mirror/widget/slide_banner.dart';
import 'package:mirror/widget/video_exposure/video_exposure.dart';
import 'package:provider/provider.dart';

class DynamicListLayout extends StatefulWidget {
  DynamicListLayout({
    Key key,
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
    this.isShowConcern = false,
  }) : super(key: key);
  final int index;
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
  DynamicListLayoutState createState() => DynamicListLayoutState();
}

class DynamicListLayoutState extends State<DynamicListLayout> {
  // @override
  // bool get wantKeepAlive => true; //必须重写   这么添加时保留轮播图滑动的图片
  @override
  void dispose() {
    // TODO: implement dispose
    print(
        "小红花&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('==============================动态itembuild');
    return widget.model != null
        ? Column(
            children: [
              // 头部头像时间
              HeadView(
                  model: widget.model,
                  isShowConcern: widget.isShowConcern,
                  pageName: widget.pageName,
                  mineDetailId: widget.mineDetailId != null ? widget.mineDetailId : 0,
                  deleteFeedChanged: (id) {
                    widget.deleteFeedChanged(id);
                  },
                  removeFollowChanged: (m) {
                    widget.removeFollowChanged(m);
                  }),
              // 图片区域
              widget.model.picUrls.length > 0
                  ? SlideBanner(
                      height: widget.model.picUrls[0].height.toDouble(),
                      model: widget.model,
                      index: widget.index,
                      pageName: widget.pageName,
                      isHero: widget.isHero,
                    )
                  : Container(),
              // 视频区域
              widget.model.videos.isNotEmpty ? getVideo(feedModel: widget.model, index: widget.index) : Container(),
              // 点赞，转发，评论三连区域 getTripleArea
              GetTripleArea(model: widget.model, index: widget.index),
              // 课程信息和地址
              Offstage(
                offstage: (widget.model.address == null && widget.model.courseDto == null),
                child: Container(
                  color: AppColor.white,
                  margin: const EdgeInsets.only(left: 16, right: 16),
                  width: ScreenUtil.instance.width,
                  child: getCourseInfo(widget.model, context),
                ),
              ),

              // 文本文案
              Offstage(
                offstage: widget.model.content.length == 0,
                child: Container(
                  margin: const EdgeInsets.only(left: 16, right: 16, top: 12),
                  width: ScreenUtil.instance.screenWidthDp,
                  color: AppColor.white,
                  child: ExpandableText(
                    text: widget.model.content,
                    topicId: widget.topicId,
                    model: widget.model,
                    maxLines: 2,
                    style: const TextStyle(fontSize: 14, color: AppColor.textPrimary1),
                  ),
                ),
              ),

              // 评论文本
              (context.watch<FeedMapNotifier>().value.feedMap != null &&
                      context.watch<FeedMapNotifier>().value.feedMap[widget.model.id] != null &&
                      context.watch<FeedMapNotifier>().value.feedMap[widget.model.id].comments != null &&
                      context.watch<FeedMapNotifier>().value.feedMap[widget.model.id].comments.length != 0)
                  ? CommentLayout(model: widget.model)
                  : Container(),
              // 输入框
              CommentInputBox(feedModel: widget.model),
              // Note 推荐用户 暂时屏蔽
              // getAttention(widget.index, widget.isShowRecommendUser),
              // 分割块
              Container(
                height: 18,
                color: AppColor.white,
              )
            ],
          )
        : Container();
  }

// 视频
  Widget getVideo({HomeFeedModel feedModel, int index}) {
    List<VideosModel> videos = feedModel.videos;
    SizeInfo sizeInfo = SizeInfo();
    if (videos != null) {
      sizeInfo.width = videos.first.width;
      sizeInfo.height = videos.first.height;
      sizeInfo.duration = videos.first.duration;
      sizeInfo.offsetRatioX = videos.first.offsetRatioX ?? 0.0;
      sizeInfo.offsetRatioY = videos.first.offsetRatioY ?? 0.0;
      sizeInfo.videoCroppedRatio = videos.first.videoCroppedRatio;

      return betterVideoPlayer(
        feedModel: feedModel,
        sizeInfo: sizeInfo,
        durationString: DateUtil.formatSecondToStringNumShowMinute(videos.first.duration),
      );
      // VideoWidget(feedModel:feedModel,sizeInfo: sizeInfo,play:videoIsPlay,durationString:  DateUtil.formatSecondToStringNumShowMinute(videos.first.duration),);
      return widget.isHero
          ? Hero(
              tag: widget.pageName + "${widget.model.id}${widget.index}",
              child: FeedVideoPlayer(
                videos.first.url,
                sizeInfo,
                ScreenUtil.instance.width,
                model: feedModel,
                durationString: DateUtil.formatSecondToStringNumShowMinute(videos.first.duration),
                isInListView: true,
                index: widget.index,
              ),
            )
          : FeedVideoPlayer(
              videos.first.url,
              sizeInfo,
              ScreenUtil.instance.width,
              model: feedModel,
              durationString: DateUtil.formatSecondToStringNumShowMinute(videos.first.duration),
              isInListView: true,
              index: widget.index,
            );
    }
  }

  // 课程信息和地址
  Widget getCourseInfo(HomeFeedModel model, BuildContext context) {
    List<FeedTagModel> tags = [];
    // 课程不为空转换model
    if (model.courseDto != null) {
      FeedTagModel tag = FeedTagModel();
      tag.type = feed_tag_type_course;
      tag.text = model.courseDto.title;
      tag.courseId = model.courseDto.id;
      tags.add(tag);
    }
    // 地址不为空转换model
    if (model.address != null) {
      FeedTagModel tag = FeedTagModel();
      tag.type = feed_tag_type_location;
      tag.text = model.address;
      tag.longitude = model.longitude;
      tag.latitude = model.latitude;
      tags.add(tag);
    }
    return Row(
      children: [
        for (int i = 0; i < tags.length; i++)
          GestureDetector(
            onTap: () {
              FeedTagModel tag = tags[i];
              switch (tag.type) {
                case feed_tag_type_course:
                  AppRouter.navigateToVideoDetail(context, tag.courseId);
                  break;
                case feed_tag_type_location:
                  AppRouter.navigateCreateMapScreenPage(
                    context,
                    tag.longitude,
                    tag.latitude,
                    tag.text,
                  );
                  break;
                default:
                  break;
              }
            },
            child: CourseAddressLabel(i, tags),
          )
      ],
    );
  }

  // 关注页的推荐用户
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

class VideoIsPlay {
  bool isPlay;
  int id;

  VideoIsPlay({this.isPlay = false, this.id});
}
