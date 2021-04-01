import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:interactiveviewer_gallery/hero_dialog_route.dart';
import 'package:interactiveviewer_gallery/interactiveviewer_gallery.dart';
import 'package:mirror/api/api.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/constants.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/feed/feed_tag_model.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/media_file_model.dart';
import 'package:mirror/data/model/profile/black_model.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/page/home/sub_page/share_page/share_page_sub_page/commentInputBox.dart';
import 'package:mirror/page/home/sub_page/share_page/share_page_sub_page/course_address_label.dart';
import 'package:mirror/page/home/sub_page/share_page/share_page_sub_page/getTripleArea.dart';
import 'package:mirror/page/home/sub_page/share_page/share_page_sub_page/head_view.dart';
import 'package:mirror/page/profile/overscroll_behavior.dart';
import 'package:mirror/page/training/common/common_comment_page.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/string_util.dart';
import 'package:mirror/util/text_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/expandable_text.dart';
import 'package:mirror/widget/feed_video_player.dart';
import 'package:mirror/widget/interactiveviewer/interactive_video_item.dart';
import 'package:mirror/widget/interactiveviewer/interactiveview_video_or_image_demo.dart';
import 'package:mirror/widget/slide_banner.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

// 动态详情页
class FeedDetailPage extends StatefulWidget {
  FeedDetailPage(
      {Key key, this.model, this.type, this.index, this.comment, this.fatherModel, this.errorCode, this.isInterative});

  CommentDtoModel fatherModel;
  CommentDtoModel comment;
  HomeFeedModel model;
  int index;
  int type;
  int errorCode;
  bool isInterative;

  @override
  FeedDetailPageState createState() => FeedDetailPageState();
}

class FeedDetailPageState extends State<FeedDetailPage> {
  HomeFeedModel feedModel;

  //上拉加载数据
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  GlobalKey<CommonCommentPageState> childKey = GlobalKey();
  GlobalKey _key = GlobalKey();

  // 列表监听
  ScrollController _controller = new ScrollController();
  int totalCount = 0;
  double itemHeight = 0;
  int isBlack = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    print("进入详情页");
    if (widget.errorCode == CODE_SUCCESS) {
      feedModel = context.read<FeedMapNotifier>().value.feedMap[widget.model.id];
      _checkBlackStatus();
      itemHeight += ScreenUtil.instance.statusBarHeight + kToolbarHeight + 76 + 48 + 18 + 16;
      if (feedModel.picUrls.isNotEmpty) {
        itemHeight += setAspectRatio(feedModel.picUrls.first.height.toDouble());
      }
      if (feedModel.videos.isNotEmpty) {
        itemHeight += _calculateHeight();
      }
      if (feedModel.content != null) {
        itemHeight +=
            getTextSize(feedModel.content, TextStyle(fontSize: 14), 2, ScreenUtil.instance.width - 32).height + 12;
      }
      if (feedModel.address == null || feedModel.courseDto == null) {
        itemHeight += 23;
      }
    }
  }

  double setAspectRatio(double height) {
    if (height == 0) {
      return ScreenUtil.instance.width;
    } else {
      return (ScreenUtil.instance.width / feedModel.picUrls[0].width) * height;
    }
  }

  ///请求黑名单关系
  _checkBlackStatus() async {
    BlackModel model = await ProfileCheckBlack(feedModel.pushId);
    if (model != null) {
      print('inThisBlack===================${model.inThisBlack}');
      print('inYouBlack===================${model.inYouBlack}');
      if (model.inYouBlack == 1) {
        isBlack = 1;
      } else if (model.inThisBlack == 1) {
        isBlack = 2;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColor.white,
        appBar: CustomAppBar(
          titleString: "动态详情页",
          leadingOnTap: () {
            Navigator.of(context).pop(true);
          },
        ),
        body: widget.errorCode != CODE_NO_DATA
            ? Stack(
                children: [
                  Container(
                      height: ScreenUtil.instance.height,
                      child: ScrollConfiguration(
                          behavior: OverScrollBehavior(),
                          child: SmartRefresher(
                              enablePullDown: false,
                              enablePullUp: true,
                              footer: footerWidget(),
                              controller: _refreshController,
                              onLoading: () {
                                childKey.currentState.onLoading();
                              },
                              child: CustomScrollView(
                                  physics: ClampingScrollPhysics(),
                                  controller: _controller,
                                  slivers: <Widget>[
                                    SliverToBoxAdapter(
                                      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                                        // 顶部间距
                                        const SizedBox(
                                          height: 14,
                                        ),
                                        // 头部布局
                                        HeadView(
                                            isBlack: isBlack,
                                            isShowConcern: true,
                                            model: feedModel,
                                            deleteFeedChanged: (id) {
                                              // deleteFeedChanged(id);
                                            },
                                            removeFollowChanged: (m) {
                                              // removeFollowChanged(m);
                                            }),
                                        // 图片区域
                                        feedModel.picUrls.isNotEmpty
                                            ? SlideBanner(
                                                height: feedModel?.picUrls[0]?.height?.toDouble(),
                                                model: feedModel,
                                                index: widget.index,
                                                pageName: "FeedDetailPage",
                                                isDynamicDetails: true,
                                              )
                                            : Container(),
                                        // 视频区域
                                        feedModel.videos.isNotEmpty ? getVideo(feedModel?.videos) : Container(),
                                        // 点赞，转发，评论三连区域 getTripleArea
                                        GetTripleArea(
                                          offsetKey: _key,
                                          model: feedModel,
                                          // back: () {
                                          //   context.read<FeedMapNotifier>().commensAssignment(feedModel.id, commentModel, totalCount);
                                          // },
                                        ),
                                        // 课程信息和地址
                                        Offstage(
                                          offstage: (feedModel.address == null && feedModel.courseDto == null),
                                          child: Container(
                                            margin: const EdgeInsets.only(left: 16, right: 16),
                                            // color: Colors.orange,
                                            width: ScreenUtil.instance.width,
                                            child: getCourseInfo(feedModel),
                                          ),
                                        ),
                                        // // 文本文案
                                        Offstage(
                                          offstage: feedModel.content.length == 0,
                                          child: Container(
                                            // color: Colors.cyan,
                                            margin: const EdgeInsets.only(left: 16, right: 16, top: 12),
                                            width: ScreenUtil.instance.width,
                                            child: ExpandableText(
                                              text: feedModel.content,
                                              model: feedModel,
                                              maxLines: 2,
                                              style: const TextStyle(fontSize: 14, color: AppColor.textPrimary1),
                                            ),
                                          ),
                                        ),
                                        context.watch<FeedMapNotifier>().value.feedMap[feedModel.id].totalCount != -1
                                            ? Container(
                                                // color: AppColor.mainRed,
                                                margin: const EdgeInsets.only(top: 18, left: 16),
                                                alignment: const Alignment(-1, 0),
                                                child:
                                                    // context.watch<FeedMapNotifier>().feedMap[feedModel.id].totalCount != -1
                                                    //     ?
                                                    // DynamicModelNotifier
                                                    Selector<FeedMapNotifier, int>(
                                                        builder: (context, totalCount, child) {
                                                  return Text(
                                                    "共${StringUtil.getNumber(totalCount)}条评论",
                                                    style: AppStyle.textRegular16,
                                                  );
                                                }, selector: (context, notifier) {
                                                  return notifier.value.feedMap[feedModel.id].totalCount;
                                                }))
                                            : Container(),
                                      ]),
                                    ),
                                    _getCourseCommentUi(),
                                    SliverToBoxAdapter(
                                      child: SizedBox(
                                        height: ScreenUtil.instance.bottomBarHeight,
                                      ),
                                    ),
                                  ])))),
                  Positioned(
                    bottom: 0,
                    child: CommentInputBox(
                      isUnderline: true,
                      isFeedDetail: true,
                      feedModel: context.watch<FeedMapNotifier>().value.feedMap[feedModel.id],
                    ),
                  )
                ],
              )
            : Container(
                width: ScreenUtil.instance.screenWidthDp,
                height: ScreenUtil.instance.height,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Spacer(),
                    Container(
                      height: ScreenUtil.instance.screenWidthDp * 0.59,
                      width: ScreenUtil.instance.screenWidthDp * 0.59,
                      color: AppColor.bgWhite,
                    ),
                    const Text(
                      "该动态已失效",
                      style: AppStyle.textHintRegular16,
                    ),
                    const Spacer()
                  ],
                ),
              ));
  }

  Widget _getCourseCommentUi() {
    /* Future.delayed(Duration(milliseconds: 100),()async{
      print("开始滚动------------------------------------------------------------------------");
      if(widget.comment.type==2) {
        childKey.currentState.startAnimationScroll(widget.comment.targetId);
      }else{
        childKey.currentState.startAnimationScroll(widget.comment.id);
      }
    });*/
    return SliverToBoxAdapter(
      child: CommonCommentPage(
        key: childKey,
        scrollController: _controller,
        refreshController: _refreshController,
        targetId: feedModel.id,
        pushId: feedModel.pushId,
        targetType: 0,
        isInteractiveIn: widget.isInterative,
        pageCommentSize: 20,
        pageSubCommentSize: 3,
        externalScrollHeight: itemHeight.toInt(),
        commentDtoModel: widget.comment,
        fatherComment: widget.fatherModel,
      ),
    );
  }

  _calculateHeight() {
    double containerWidth = ScreenUtil.instance.width;
    double containerHeight;
    double videoRatio = feedModel.videos.first.width / feedModel.videos.first.height;
    double containerRatio;

    //如果有裁剪的比例 则直接用该比例
    if (feedModel.videos.first.videoCroppedRatio != null) {
      containerRatio = feedModel.videos.first.videoCroppedRatio;
    } else {
      if (videoRatio < minMediaRatio) {
        containerRatio = minMediaRatio;
      } else if (videoRatio > maxMediaRatio) {
        containerRatio = maxMediaRatio;
      } else {
        containerRatio = videoRatio;
      }
    }
    containerHeight = containerWidth / containerRatio;
    return containerHeight;
  }

// 视频
  Widget getVideo(List<VideosModel> videos) {
    SizeInfo sizeInfo = SizeInfo();
    sizeInfo.width = videos.first.width;
    sizeInfo.height = videos.first.height;
    sizeInfo.duration = videos.first.duration;
    sizeInfo.offsetRatioX = videos.first.offsetRatioX ?? 0.0;
    sizeInfo.offsetRatioY = videos.first.offsetRatioY ?? 0.0;
    sizeInfo.videoCroppedRatio = videos.first.videoCroppedRatio;
    return Hero(
      tag: videos.first.url,
      child: GestureDetector(
        onTap: () {
          // Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context){
          //   return InteractiveviewDemoPage();
          // }));
          Navigator.of(context).push(
            HeroDialogRoute<void>(
              builder: (BuildContext context) => InteractiveviewerGallery<VideosModel>(
                sources: videos,
                initIndex: 0,
                itemBuilder: itemBuilder,
              ),
            ),
          );
        },
        child: FeedVideoPlayer(
          videos.last.url,
          sizeInfo,
          ScreenUtil.instance.width,
          isInListView: true,
        ),
      ),
    );
  }

  Widget itemBuilder(
    BuildContext context,
    int index,
    bool isFocus,
  ) {
    VideosModel videosModel = feedModel.videos[index];
    return InteractiveVideoItem(
      videosModel,
      isFocus: isFocus,
    );
  }

  //底部或滑动
  Widget footerWidget() {
    return CustomFooter(
      builder: (BuildContext context, LoadStatus mode) {
        Widget body;
        if (mode == LoadStatus.idle) {
          body = const Text("");
        } else if (mode == LoadStatus.loading) {
          body = Container(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(),
          );
        } else if (mode == LoadStatus.failed) {
          body = const Text("");
        } else if (mode == LoadStatus.canLoading) {
          body = const Text("");
        } else {
          body = const Text("");
        }
        return Container(
          height: 55.0,
          child: Center(child: body),
        );
      },
    );
  }

  // 课程信息和地址
  Widget getCourseInfo(HomeFeedModel model) {
    List<FeedTagModel> tags = [];
    if (model.courseDto != null) {
      FeedTagModel tag = FeedTagModel();
      tag.type = feed_tag_type_course;
      tag.text = model.courseDto.title;
      tag.courseId = model.courseDto.id;
      tags.add(tag);
    }
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
}
