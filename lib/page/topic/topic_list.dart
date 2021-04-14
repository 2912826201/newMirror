// import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound_lite/flutter_sound.dart';

// import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/api/topic/topic_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/data_response_model.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/page/home/sub_page/recommend_page.dart';
import 'package:mirror/page/home/sub_page/share_page/dynamic_list.dart';
import 'package:mirror/page/search/sub_page/search_feed.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/overscroll_behavior.dart';
import 'package:mirror/widget/sliding_element_exposure/exposure_detector.dart';
import 'package:mirror/widget/smart_refressher_head_footer.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

class TopicList extends StatefulWidget {
  TopicList({this.topicId, this.type});

  int type;

  // 话题ID
  int topicId;

  @override
  TopicListState createState() => TopicListState();
}

class TopicListState extends State<TopicList> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; //必须重写

  // 推荐数据是否存在下一页
  int recommendHasNext;

  // 推荐话题ListModel
  List<HomeFeedModel> recommendTopicList = [];
  RefreshController refreshController = RefreshController();

  // 请求推荐话题动态接口
  requestRecommendTopic({bool refreshOrLoading}) async {
    if (recommendHasNext != 0) {
      DataResponseModel model = await pullTopicList(type: widget.type, size: 20, targetId: widget.topicId);
      if (model != null) {
        recommendHasNext = model.hasNext;
        if (model.list.isNotEmpty) {
          model.list.forEach((v) {
            recommendTopicList.add(HomeFeedModel.fromJson(v));
          });
        }
        if (refreshOrLoading) {
          refreshController.refreshCompleted();
        } else {
          refreshController.loadComplete();
        }
        context.read<FeedMapNotifier>().updateFeedMap(recommendTopicList);
      } else {
        if (refreshOrLoading) {
          refreshController.refreshFailed();
        } else {
          refreshController.loadFailed();
        }
      }
    }
    if (recommendHasNext == 0) {
      if (refreshOrLoading) {
        refreshController.refreshCompleted();
        refreshController.loadComplete();
      } else {
        refreshController.loadNoData();
      }
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Future.delayed(Duration(milliseconds: 250), () {
        requestRecommendTopic(refreshOrLoading: true);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return recommendTopicList.isNotEmpty
        ? Container(
            color: AppColor.white,
            child: MediaQuery.removePadding(
                removeTop: true,
                context: context,
                child: ScrollConfiguration(
                    behavior: OverScrollBehavior(),
                    child: SmartRefresher(
                      enablePullDown: true,
                      enablePullUp: true,
                      footer: SmartRefresherHeadFooter.init().getFooter(),
                      header: SmartRefresherHeadFooter.init().getHeader(),
                      controller: refreshController,
                      onRefresh: () {
                        recommendTopicList.clear();
                        recommendHasNext = null;
                        requestRecommendTopic(refreshOrLoading: true);
                      },
                      onLoading: () {
                        requestRecommendTopic(refreshOrLoading: false);
                      },
                      child: ListView.builder(
                          itemCount: recommendTopicList.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return ExposureDetector(
                              key: Key('topic_list_${widget.type}_${recommendTopicList[index].id}'),
                              child: DynamicListLayout(
                                index: index,
                                topicId: widget.topicId,
                                pageName: "topicRecommend",
                                isShowRecommendUser: false,
                                isShowConcern: false,
                                model: recommendTopicList[index],
                                // 可选参数 子Item的个数
                                key: GlobalObjectKey("attention$index"),
                              ),
                              onExposure: (visibilityInfo) {
                                // 如果没有显示
                                if (context
                                    .read<FeedMapNotifier>()
                                    .value
                                    .feedMap[recommendTopicList[index].id]
                                    .isShowInputBox) {
                                  context.read<FeedMapNotifier>().showInputBox(recommendTopicList[index].id);
                                }
                                print('第$index 块曝光,展示比例为${visibilityInfo.visibleFraction}');
                              },
                            );
                          }),
                    )))
            // margin: EdgeInsets.only(left: 16, right: 16),
            // child: WaterfallFlow.builder(
            //   gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
            //     crossAxisCount: 2,
            //     // 上下间隔
            //     mainAxisSpacing: 4.0,
            //     //   // 左右间隔
            //     crossAxisSpacing: 8.0,
            //   ),
            //   itemBuilder: (context, index) {
            //     // 获取动态id
            //     int id;
            //     // 获取动态id指定model
            //     HomeFeedModel model;
            //     if (index < widget.topicList.length) {
            //       id = widget.topicList[index].id;
            //       model = context.read<FeedMapNotifier>().feedMap[id];
            //     }
            //     // if (feedList.isNotEmpty) {
            //     if (index == widget.topicList.length) {
            //       return LoadingView(
            //         loadText: widget.loadText,
            //         loadStatus: widget.loadStatus,
            //       );
            //     } else if (index == widget.topicList.length + 1) {
            //       return Container();
            //     } else {
            //       return SearchFeeditem(
            //         model: model,
            //         list: widget.topicList,
            //         index: index,
            //         pageName: "topicRecommend",
            //       );
            //     }
            //   },
            //   itemCount: widget.topicList.length + 1,
            // )
            )
        : Container(
            width: double.infinity,
            height: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 224,
                  height: 224,
                  color: AppColor.color246,
                  margin: const EdgeInsets.only(bottom: 16),
                ),
                const Text(
                  "这里空空如也，去推荐看看吧",
                  style: TextStyle(fontSize: 14, color: AppColor.textSecondary),
                ),
              ],
            ),
          );
  }
}
