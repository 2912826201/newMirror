import 'package:dio/dio.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/api.dart';

import 'package:mirror/api/topic/topic_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/data_response_model.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/page/home/sub_page/share_page/dynamic_list.dart';
import 'package:mirror/page/search/sub_page/search_feed.dart';
import 'package:mirror/util/event_bus.dart';
import 'package:mirror/widget/overscroll_behavior.dart';
import 'package:mirror/widget/sliding_element_exposure/exposure_detector.dart';
import 'package:mirror/widget/smart_refressher_head_footer.dart';
import 'package:provider/provider.dart';
import 'package:mirror/widget/pull_to_refresh/pull_to_refresh.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

class TopicList extends StatefulWidget {
  TopicList({this.topicId, this.type, this.tabKey});

  int type;

  // 话题ID
  int topicId;
  final Key tabKey;

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
  RefreshController refreshController = RefreshController(initialRefresh: true);

  // 是否显示缺省图
  bool isShowDefaultMap;

  // Token can be shared with different requests.
  CancelToken token = CancelToken();
  final GlobalKey<SliverAnimatedListState> _listKey = GlobalKey<SliverAnimatedListState>();

  @override
  void dispose() {
    // TODO: implement dispose
    // 取消网络请求
    cancelRequests(token: token);
    EventBus.getDefault()
        .unRegister(registerName: EVENTBUS_TOPICDETAIL_DELETE_FEED, pageName: EVENTBUS__TOPICDATAIL_PAGE);
    super.dispose();
  }

  // 请求推荐话题动态接口
  requestRecommendTopic({bool refreshOrLoading}) async {
    if (recommendHasNext != 0) {
      DataResponseModel model =
          await pullTopicList(type: widget.type, size: 20, targetId: widget.topicId, token: token);
      if (refreshOrLoading) {
        recommendTopicList.clear();
      }
      if (model != null) {
        recommendHasNext = model.hasNext;
        if (model.list.isNotEmpty) {
          model.list.forEach((v) {
            recommendTopicList.add(HomeFeedModel.fromJson(v));
            if (!refreshOrLoading) {
              _listKey.currentState.insertItem(1);
            }
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
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    // Future.delayed(Duration(milliseconds: 250), () {
    //   requestRecommendTopic(refreshOrLoading: true);
    // });
    // });
  }

  _deleteFeedCallBack(int id) {
    // 动画删除item
    setState(() {
      int _index;
      recommendTopicList.forEach((element) {
        if (element.id == id) {
          _index = recommendTopicList.indexOf(element);
        }
      });
      if (_index != null) {
        _listKey.currentState.removeItem(_index, (context, animation) => _buildItem(_index, animation));
        recommendTopicList.removeWhere((v) => v.id == id);
        context.read<FeedMapNotifier>().deleteFeed(id);
      }
      // // 更新全局监听
      // context.read<FeedMapNotifier>().updateFeedMap(recommendTopicList);
    });
  }

  _buildItem(int index, Animation animation) {
    return SizeTransition(
        sizeFactor: animation,
        child: ExposureDetector(
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
            if (context.read<FeedMapNotifier>().value.feedMap[recommendTopicList[index].id].isShowInputBox) {
              context.read<FeedMapNotifier>().showInputBox(recommendTopicList[index].id);
            }
            print('第$index 块曝光,展示比例为${visibilityInfo.visibleFraction}');
          },
        ));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // return
    final child = Container(
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
                                SliverAnimatedList(
                                    key: _listKey,
                                    itemBuilder: (BuildContext context, int index, Animation<double> animation) {
                                      return _buildItem(index, animation);
                                    },
                                    initialItemCount: recommendTopicList.length)
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
                                    style: TextStyle(fontSize: 14, color: AppColor.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                ))));
    return NestedScrollViewInnerScrollPositionKeyWidget(widget.tabKey, child);
  }
}
