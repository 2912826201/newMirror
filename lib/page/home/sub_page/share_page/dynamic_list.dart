import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/config/config.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/feed/feed_tag_model.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/media_file_model.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/page/home/sub_page/share_page/share_page_sub_page/attention_user.dart';
import 'package:mirror/page/home/sub_page/share_page/share_page_sub_page/better_video_player.dart';
import 'package:mirror/page/home/sub_page/share_page/share_page_sub_page/commentInputBox.dart';
import 'package:mirror/page/home/sub_page/share_page/share_page_sub_page/comment_layout.dart';
import 'package:mirror/page/home/sub_page/share_page/share_page_sub_page/course_address_label.dart';
import 'package:mirror/page/home/sub_page/share_page/share_page_sub_page/getTripleArea.dart';
import 'package:mirror/page/home/sub_page/share_page/share_page_sub_page/head_view.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/date_util.dart';
import 'package:mirror/util/event_bus.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/expandable_text.dart';
import 'package:mirror/widget/feed_video_player.dart';
import 'package:mirror/widget/slide_banner.dart';
import 'package:provider/provider.dart';

class DynamicPageType {
  static String attentionPage = "attentionPage";
  static String recommendPage = "recommendPage";
  static String profileDetailsPage = "profileDetailsPage";
  static String topicRecommend = "topicRecommend";
  static String searchComplex = "searchComplex";
  static String searchFeed = "searchFeed";
}

class DynamicListLayout extends StatefulWidget {
  DynamicListLayout({
    Key key,
    this.index,
    this.isShowRecommendUser,
    this.model,
    this.pageName,
    this.deleteFeedChanged,
    this.isHero = false,
    // this.removeFollowChanged,
    this.mineDetailId,
    this.topicId,
    this.isMySelf,
    this.isShowConcern = false,
    this.itemHeightKey,
  }) : super(key: key);
  final int index;
  bool isShowRecommendUser;
  HomeFeedModel model;
  int mineDetailId;
  String pageName;
  GlobalKey itemHeightKey;

  // ???????????????id
  int topicId;
  bool isHero;
  bool isMySelf;

  // ????????????
  ValueChanged<int> deleteFeedChanged;

  // ????????????
  // ValueChanged<HomeFeedModel> removeFollowChanged;

  // ????????????????????????
  bool isShowConcern;

  @override
  DynamicListLayoutState createState() => DynamicListLayoutState();
}

class DynamicListLayoutState extends State<DynamicListLayout> {
  // @override
  // bool get wantKeepAlive => true; //????????????   ?????????????????????????????????????????????

  bool isScroll = false;

  @override
  void dispose() {
    // TODO: implement dispose
    print(
        "?????????&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&");
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  setScroll(bool isScroll) {
    this.isScroll = isScroll;
  }

  // ?????????
  double setAspectRatio(double height) {
    if (height == 0) {
      return ScreenUtil.instance.width;
    } else {
      return (ScreenUtil.instance.width / widget.model.picUrls[0].width.toDouble()) * height;
    }
  }

  @override
  Widget build(BuildContext context) {
    print('==============================??????itembuild');
    return widget.model != null
        ? Column(
            key: widget.itemHeightKey,
            children: [
              // ??????????????????
              HeadView(
                model: widget.model,
                isShowConcern: widget.isShowConcern,
                pageName: widget.pageName,
                mineDetailId: widget.mineDetailId != null ? widget.mineDetailId : 0,
                deleteFeedChanged: (id) {
                  if (widget.topicId != null) {
                    // ???????????????????????????
                    EventBus.init().post(msg: widget.model.id, registerName: EVENTBUS_TOPICDETAIL_DELETE_FEED);
                  }
                  widget.deleteFeedChanged(id);
                },
                // removeFollowChanged: (m) {
                //   if(widget.pageName == DynamicPageType.attentionPage)widget.removeFollowChanged(m);
                // }
              ),
              // ????????????
              widget.model.picUrls.length > 0
                  ? SlideBanner(
                      height: widget.model.picUrls[0].height.toDouble(),
                      model: widget.model,
                      index: widget.index,
                      pageName: widget.pageName,
                      isHero: widget.isHero,
                    )
                  : Container(),
              // ????????????
              widget.model.videos.isNotEmpty ? getVideo(feedModel: widget.model, index: widget.index) : Container(),
              // ???????????????????????????????????? getTripleArea
              GetTripleArea(model: widget.model, index: widget.index),
              // ?????????????????????
              Offstage(
                offstage: (widget.model.address == null &&
                    // widget.model.courseDto == null
                    widget.model.simpleActivityDto == null),
                child: Container(
                  // color: AppColor.white,
                  margin: const EdgeInsets.only(left: 16, right: 16),
                  width: ScreenUtil.instance.width,
                  child: getCourseInfo(widget.model, context),
                ),
              ),

              // ????????????
              Offstage(
                offstage: widget.model.content == null || widget.model.content.length == 0,
                child: Container(
                  margin: const EdgeInsets.only(left: 16, right: 16, top: 12),
                  width: ScreenUtil.instance.screenWidthDp,
                  // color: AppColor.white,
                  child: ExpandableText(
                    text: widget.model.content,
                    topicId: widget.topicId,
                    model: widget.model,
                    maxLines: 2,
                    style: AppStyle.whiteRegular14,
                  ),
                ),
              ),

              // ????????????
              (context.watch<FeedMapNotifier>().value.feedMap != null &&
                      context.watch<FeedMapNotifier>().value.feedMap[widget.model.id] != null &&
                      context.watch<FeedMapNotifier>().value.feedMap[widget.model.id].comments != null &&
                      context.watch<FeedMapNotifier>().value.feedMap[widget.model.id].comments.length != 0)
                  ? CommentLayout(model: widget.model)
                  : Container(),
              // ?????????
              CommentInputBox(feedModel: widget.model),
              // Note ???????????? ????????????
              AppConfig.needShowTraining ? getAttention(widget.index, widget.isShowRecommendUser) : Container(),
              // ?????????
              Container(
                height: 18,
                // color: AppColor.white,
              )
            ],
          )
        : Container();
  }

// ??????
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

  // ?????????????????????
  Widget getCourseInfo(HomeFeedModel model, BuildContext context) {
    List<FeedTagModel> tags = [];
    // // ?????????????????????model
    if (model.courseDto != null) {
      FeedTagModel tag = FeedTagModel();
      tag.type = feed_tag_type_course;
      tag.text = model.courseDto.title;
      tag.courseId = model.courseDto.id;
      tags.add(tag);
    }
    // ?????????????????????model
    if (model.simpleActivityDto != null) {
      FeedTagModel tag = FeedTagModel();
      tag.type = feed_tag_type_activity;
      tag.text = model.simpleActivityDto.title;
      tag.activityId = model.simpleActivityDto.id;
      tags.add(tag);
    }
    // ?????????????????????model
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
                case feed_tag_type_activity:
                  AppRouter.navigateActivityDetailPage(context, tag.activityId);
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

  // ????????????????????????
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
