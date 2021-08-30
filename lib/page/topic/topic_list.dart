import 'package:dio/dio.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:keframe/frame_separate_widget.dart';
import 'package:keframe/size_cache_widget.dart';
import 'package:mirror/api/api.dart';

import 'package:mirror/api/topic/topic_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/data_response_model.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/page/home/sub_page/share_page/dynamic_list.dart';
import 'package:mirror/page/topic/topic_detail.dart';
import 'package:mirror/util/event_bus.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/overscroll_behavior.dart';
import 'package:mirror/widget/size_transition_view.dart';
import 'package:mirror/widget/sliding_element_exposure/exposure_detector.dart';
import 'package:mirror/widget/smart_refressher_head_footer.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';


class TopicList extends StatefulWidget {
  TopicList({Key key, this.topicId, this.type, this.tabKey}) : super(key: key);

  int type;

  // 话题ID
  int topicId;
  final Key tabKey;

  @override
  TopicListState createState() => TopicListState();
}

class TopicListState extends State<TopicList> with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true; //必须重写

  // 推荐数据是否存在下一页
  int recommendHasNext;

  // 推荐话题ListModel
  List<HomeFeedModel> recommendTopicList = [];
  RefreshController refreshController = RefreshController(initialRefresh: true);

  // 是否显示缺省图
  bool isShowDefaultMap;

  // Token can be shared with different requests.
  CancelToken token = CancelToken();
  Map<int, AnimationController> animationMap = {};

  // final GlobalKey<SliverAnimatedListState> _listKey = GlobalKey<SliverAnimatedListState>();

  // 双击刷新
  onDoubleTap(TopicDoubleTapTabbar topicDoubleTapTabbar) {
    // bool isrefresh = false;
    // if (topicDoubleTapTabbar.topicId == widget.topicId) {
    //   if (topicDoubleTapTabbar.tabControllerIndex == 0 && widget.type == 5) {
    //     isrefresh = true;
    //   } else if (topicDoubleTapTabbar.tabControllerIndex == 1 && widget.type == 4) {
    //     isrefresh = true;
    //   }
    //   if (isrefresh) {
    //     refreshController.requestRefresh(duration: Duration(milliseconds: 250));
    //   }
    // _key.currentState.currentInnerPosition.animateTo(0.0, duration: Duration(milliseconds: 250), curve: Curves.linear);
    // widget.
    // refreshController.
    // }
    // print("执行几次");
    // topicDoubleTapTabbar.innerController.animateTo(0.0, duration: Duration(milliseconds: 250), curve: Curves.linear);
    // topicDoubleTapTabbar.outerController.animateTo(0.0, duration: Duration(milliseconds: 250), curve: Curves.linear);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    // 取消网络请求
    cancelRequests(token: token);
    EventBus.getDefault()
        .unRegister(registerName: EVENTBUS_TOPICDETAIL_DELETE_FEED, pageName: EVENTBUS__TOPICDATAIL_PAGE);
    EventBus.getDefault().unRegister(
        registerName: EVENTBUS_TOPICDETAIL_DOUBLE_TAP_TABBAR + "${widget.topicId}",
        pageName: EVENTBUS__TOPICDATAIL_PAGE);
    super.dispose();
  }

  // 请求推荐话题动态接口
  requestRecommendTopic({bool refreshOrLoading}) async {
    if (recommendHasNext != 0) {
      DataResponseModel model =
          await pullTopicList(type: widget.type, size: 20, targetId: widget.topicId, token: token);
      if (refreshOrLoading) {
        recommendTopicList.clear();
        animationMap.clear();
      }
      if (model != null) {
        recommendHasNext = model.hasNext;
        if (model.list.isNotEmpty) {
          model.list.forEach((v) {
            recommendTopicList.add(HomeFeedModel.fromJson(v));
            animationMap[HomeFeedModel.fromJson(v).id] =
                AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
          });
        }
        if (refreshOrLoading) {
          refreshController.refreshCompleted();
        } else {
          refreshController.loadComplete();
        }
        //筛选首页关注页话题动态
        List<HomeFeedModel> homeFollowModel = [];
        context.read<FeedMapNotifier>().value.feedMap.forEach((key, value) {
          if (value.recommendSourceDto != null) {
            homeFollowModel.add(value);
          }
        });
        homeFollowModel.forEach((element) {
          recommendTopicList.forEach((v) {
            if (element.id == v.id) {
              v.recommendSourceDto = element.recommendSourceDto;
            }
          });
        });
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
    if (recommendTopicList.length > 0) {
      isShowDefaultMap = true;
    } else {
      isShowDefaultMap = false;
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // requestRecommendTopic(refreshOrLoading:true);
    EventBus.getDefault().registerSingleParameter(_deleteFeedCallBack, EVENTBUS__TOPICDATAIL_PAGE,
        registerName: EVENTBUS_TOPICDETAIL_DELETE_FEED);
    EventBus.getDefault().registerSingleParameter(onDoubleTap, EVENTBUS__TOPICDATAIL_PAGE,
        registerName: EVENTBUS_TOPICDETAIL_DOUBLE_TAP_TABBAR + "${widget.topicId}");
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    // Future.delayed(Duration(milliseconds: 250), () {
    //   requestRecommendTopic(refreshOrLoading: true);
    // });
    // });
  }

  _deleteFeedCallBack(int id) {
    if (animationMap.containsKey(id)) {
      animationMap[id].forward().then((value) {
        recommendTopicList.removeWhere((v) => v.id == id);
        if (mounted) {
          setState(() {
            animationMap.removeWhere((key, value) => key == id);
          });
        }
        if (context.read<FeedMapNotifier>().value.feedMap.containsKey(id)) {
          context.read<FeedMapNotifier>().deleteFeed(id);
        }
        if (recommendTopicList.length == 0) {
          requestRecommendTopic(refreshOrLoading: true);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // return
    final child = Container(
        // color: AppColor.white,
        child: MediaQuery.removePadding(
            removeTop: true,
            context: context,
            child: ScrollConfiguration(
                behavior: OverScrollBehavior(),
                child: SizeCacheWidget(
                    // 粗略估计一屏上列表项的最大数量如3个，将 SizeCacheWidget 的 estimateCount 设置为 3*2。快速滚动场景构建响应更快，并且内存更稳定
                    estimateCount: 6,
                    child: SmartRefresher(
                      enablePullDown: true,
                      enablePullUp: true,
                      footer: SmartRefresherHeadFooter.init().getFooter(),
                      header: SmartRefresherHeadFooter.init().getHeader(),
                      controller: refreshController,
                      onRefresh: () {
                        recommendHasNext = null;
                        refreshController.loadComplete();
                        requestRecommendTopic(refreshOrLoading: true);
                      },
                      onLoading: () {
                        requestRecommendTopic(refreshOrLoading: false);
                      },
                      child: isShowDefaultMap == null
                          ? Container()
                          : isShowDefaultMap
                              ? CustomScrollView(
                                  slivers: [
                                    SliverList(
                                        delegate: SliverChildBuilderDelegate((content, index) {
                                      HomeFeedModel feedModel = recommendTopicList[index];
                                      return FrameSeparateWidget(
                                          index: index,
                                          placeHolder: Container(
                                            height: 512,
                                            width: ScreenUtil.instance.width,
                                          ),
                                          child: SizeTransitionView(
                                              id: feedModel.id,
                                              animationMap: animationMap,
                                              child: ExposureDetector(
                                                key: Key('topic_list_${widget.type}_${feedModel.id}'),
                                                child: DynamicListLayout(
                                                  index: recommendTopicList.indexOf(feedModel),
                                                  pageName: DynamicPageType.topicRecommend,
                                                  isShowRecommendUser: false,
                                                  isShowConcern: false,
                                                  model: feedModel,
                                                  topicId: widget.topicId,
                                                  // 可选参数 子Item的个数
                                                  key: GlobalObjectKey(
                                                      "topicRecommend${recommendTopicList.indexOf(feedModel)}"),
                                                ),
                                                onExposure: (visibilityInfo) {
                                                  // 如果没有显示
                                                  if (context
                                                      .read<FeedMapNotifier>()
                                                      .value
                                                      .feedMap[feedModel.id]
                                                      .isShowInputBox) {
                                                    context.read<FeedMapNotifier>().showInputBox(feedModel.id);
                                                    print(
                                                        '第${recommendTopicList.indexOf(feedModel)} 块曝光,展示比例为${visibilityInfo.visibleFraction}');
                                                  }
                                                },
                                              )));
                                    }, childCount: recommendTopicList.length)),
                                    // SliverAnimatedList(
                                    // key: _listKey,
                                    // itemBuilder: (BuildContext context, int index, Animation<double> animation) {
                                    //   HomeFeedModel model = recommendTopicList[index];
                                    //   return _buildItem(model, animation);
                                    // },
                                    // initialItemCount: recommendTopicList.length)
                                  ],
                                )
                              // CustomScrollView(
                              //     slivers: [
                              //       SliverFillRemaining(
                              //         // child: Container(
                              //         //     margin: EdgeInsets.only(left: 16, right: 16),
                              //             child: WaterfallFlow.builder(
                              //               physics: NeverScrollableScrollPhysics(),
                              //               gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                              //                 crossAxisCount: 2,
                              //                 // 上下间隔
                              //                 mainAxisSpacing: 4.0,
                              //                 //   // 左右间隔
                              //                 crossAxisSpacing: 8.0,
                              //               ),
                              //               itemBuilder: (context, index) {
                              //                 // 获取动态id
                              //                 int id;
                              //                 // 获取动态id指定model
                              //                 HomeFeedModel model;
                              //                 if (index < recommendTopicList.length) {
                              //                   id = recommendTopicList[index].id;
                              //                   model = context.read<FeedMapNotifier>().value.feedMap[id];
                              //                 }
                              //                 return SearchFeeditem(
                              //                   model: model,
                              //                   list: recommendTopicList,
                              //                   index: index,
                              //                   pageName: "topicRecommend",
                              //                 );
                              //               },
                              //               itemCount: recommendTopicList.length,
                              //             )),
                              //       // )
                              //     ],
                              //   )
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
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                              image: AssetImage("assets/png/default_no_data.png"), fit: BoxFit.cover),
                                        ),
                                        margin: const EdgeInsets.only(bottom: 16),
                                      ),
                                      const Text(
                                        "这里空空如也，去推荐看看吧",
                                        style: AppStyle.text1Regular14,
                                      ),
                                    ],
                                  ),
                                ),
                    )))));
    return NestedScrollViewInnerScrollPositionKeyWidget(widget.tabKey, child);
  }
}
