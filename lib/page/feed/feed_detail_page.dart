import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/constants.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/media_file_model.dart';
import 'package:mirror/data/model/profile/black_model.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/page/home/sub_page/share_page/share_page_sub_page/commentInputBox.dart';
import 'package:mirror/page/home/sub_page/share_page/share_page_sub_page/course_address_label.dart';
import 'package:mirror/page/home/sub_page/share_page/share_page_sub_page/getTripleArea.dart';
import 'package:mirror/page/home/sub_page/share_page/share_page_sub_page/head_view.dart';
import 'package:mirror/page/training/common/common_comment_page.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/string_util.dart';
import 'package:mirror/util/text_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/expandable_text.dart';
import 'package:mirror/widget/feed_video_player.dart';
import 'package:mirror/widget/slide_banner.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

// 动态详情页
class FeedDetailPage extends StatefulWidget {
  FeedDetailPage({Key key, this.model, this.type, this.index, this.comment, this.fatherModel});

  CommentDtoModel fatherModel;
  CommentDtoModel comment;
  HomeFeedModel model;
  int index;
  int type;

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
    feedModel = context.read<FeedMapNotifier>().feedMap[widget.model.id];
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
      } else if(model.inThisBlack == 1){
        isBlack = 2;
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    print("动态详情页build---------------------------------------------${feedModel}");
    return Scaffold(
        backgroundColor: AppColor.white,
        appBar: CustomAppBar(
          titleString: "动态详情页",
          leadingOnTap: () {
            Navigator.of(context).pop(true);
          },
        ),
        body: Stack(
          children: [
            Container(
              height: ScreenUtil.instance.height,
              child: SmartRefresher(
                  enablePullDown: false,
                  enablePullUp: true,
                  footer: footerWidget(),
                  controller: _refreshController,
                  onLoading: () {
                    childKey.currentState.onLoading();
                  },
                  child: CustomScrollView(physics: ClampingScrollPhysics(), controller: _controller, slivers: <Widget>[
                    SliverToBoxAdapter(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                        // 顶部间距
                        SizedBox(
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
                                index:widget.index,
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
                            margin: EdgeInsets.only(left: 16, right: 16),
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
                            margin: EdgeInsets.only(left: 16, right: 16, top: 12),
                            width: ScreenUtil.instance.width,
                            child: ExpandableText(
                              text: feedModel.content,
                              model: feedModel,
                              maxLines: 2,
                              style: TextStyle(fontSize: 14, color: AppColor.textPrimary1),
                            ),
                          ),
                        ),
                        context.watch<FeedMapNotifier>().feedMap[feedModel.id].totalCount != -1
                            ? Container(
                                // color: AppColor.mainRed,
                                margin: EdgeInsets.only(top: 18, left: 16),
                                alignment: Alignment(-1, 0),
                                child:
                                    // context.watch<FeedMapNotifier>().feedMap[feedModel.id].totalCount != -1
                                    //     ?
                                    // DynamicModelNotifier
                                    Selector<FeedMapNotifier, int>(builder: (context, totalCount, child) {
                                  return Text(
                                    "共${StringUtil.getNumber(totalCount)}条评论",
                                    style: AppStyle.textRegular16,
                                  );
                                }, selector: (context, notifier) {
                                  return notifier.feedMap[feedModel.id].totalCount;
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
                  ])),
            ),
            Positioned(
              bottom: 0,
              child: CommentInputBox(
                isUnderline: true,
                isFeedDetail: true,
                feedModel: context.watch<FeedMapNotifier>().feedMap[feedModel.id],
              ),
            )
          ],
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
    return FeedVideoPlayer(
      videos.last.url,
      sizeInfo,
      ScreenUtil.instance.width,
      isInListView: true,
    );
  }

  //底部或滑动
  Widget footerWidget() {
    return CustomFooter(
      builder: (BuildContext context, LoadStatus mode) {
        Widget body;
        if (mode == LoadStatus.idle) {
          body = Text("");
        } else if (mode == LoadStatus.loading) {
          body = Container(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(),
          );
        } else if (mode == LoadStatus.failed) {
          body = Text("");
        } else if (mode == LoadStatus.canLoading) {
          body = Text("");
        } else {
          body = Text("");
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
    List<String> tags = [];
    if (model.courseDto != null) {
      tags.add(model.courseDto.title);
    }
    if (model.address != null) {
      tags.add(model.address);
    }
    return Row(
      children: [for (String item in tags) CourseAddressLabel(item, tags)],
    );
  }
}
