import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/search/search_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/data_response_model.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/page/home/sub_page/share_page/dynamic_list.dart';
import 'package:mirror/util/string_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:provider/provider.dart';

class FeedFlow extends StatefulWidget {
  FeedFlow(
      {Key key, this.feedList, this.pageName, this.feedLastTime, this.searchKeyWords, this.feedHasNext, this.feedIndex,this.listHeight})
      : super(key: key);

  @override
  FeedFlowState createState() => FeedFlowState();

  // 搜索动态出入列表
  List<HomeFeedModel> feedList;

  // hero动画key,页面名加动态id加索引值
  String pageName;

// 搜索动态关键词
  String searchKeyWords;

// 动态lastTime
  int feedLastTime;

  // 是否存在下一页
  int feedHasNext;

  //  列表的索引值
  int feedIndex;

  // 列表的高度
  double listHeight;
}

class FeedFlowState extends State<FeedFlow> {
  RefreshController _refreshController = RefreshController(); // 刷新控件控制器
  // 列表滑动到指定item控制器
  AutoScrollController controller;

  @override
  void initState() {
    controller = AutoScrollController(
        viewportBoundaryGetter: () => Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: Axis.vertical);
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //   if (widget.feedIndex != null) {
    //     controller.scrollToIndex(widget.feedIndex , preferPosition: AutoScrollPosition.begin);
    //   }
    // });

    super.initState();
  }

  // 请求动态接口
  requestFeednIterface() async {
    if (widget.feedHasNext != 0) {
      DataResponseModel model = await searchFeed(key: widget.searchKeyWords, size: 20, lastTime: widget.feedLastTime);
      widget.feedLastTime = model.lastTime;
      widget.feedHasNext = model.hasNext;
      if (model.list.isNotEmpty) {
        model.list.forEach((v) {
          widget.feedList.add(HomeFeedModel.fromJson(v));
        });
        _refreshController.loadComplete();
      }
      List<HomeFeedModel> feedList = [];
      context.read<FeedMapNotifier>().value.feedMap.forEach((key, value) {
        feedList.add(value);
      });
      // 更新全局内没有的数据
      context.read<FeedMapNotifier>().updateFeedMap( StringUtil.followModelFilterDeta(widget.feedList,feedList));
    }
    if (widget.feedHasNext == 0) {
      // 加载完毕
      _refreshController.loadNoData();
    }
    if (mounted) {
      setState(() {});
    }
  }

  // 下拉刷新
  _onRefresh() async {
    widget.feedHasNext = null;
    widget.feedLastTime = null;
    widget.feedList.clear();
    DataResponseModel model = await searchFeed(key: widget.searchKeyWords, size: 20, lastTime: widget.feedLastTime);
    widget.feedLastTime = model.lastTime;
    widget.feedHasNext = model.hasNext;
    if (model.list.isNotEmpty) {
      model.list.forEach((v) {
        widget.feedList.add(HomeFeedModel.fromJson(v));
      });
      _refreshController.refreshCompleted();
    }
    if (widget.feedHasNext == 0) {
      // 加载完毕
      _refreshController.resetNoData();
    }
    List<HomeFeedModel> feedList = [];
    context.read<FeedMapNotifier>().value.feedMap.forEach((key, value) {
      feedList.add(value);
    });
    // 更新全局内没有的数据
    context.read<FeedMapNotifier>().updateFeedMap( StringUtil.followModelFilterDeta(widget.feedList,feedList));

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: CustomAppBar(
          titleString: "动态流",
        ),
        body: Container(
            color: AppColor.white,
            child: SmartRefresher(
                enablePullUp: true,
                enablePullDown: true,
                footer: CustomFooter(
                  builder: (BuildContext context, LoadStatus mode) {
                    Widget body;
                    if (mode == LoadStatus.loading) {
                      body = Text("正在加载");
                    } else if (mode == LoadStatus.idle) {
                      body = Text("上拉加载更多");
                    } else if (mode == LoadStatus.failed) {
                      body = Text("加载失败,请重试");
                    } else {
                      body = Text("没有更多了");
                    }
                    return Container(
                      child: Center(
                        child: body,
                      ),
                    );
                  },
                ),
                header: WaterDropHeader(
                  complete: Text("刷新完成"),
                  failed: Text(" "),
                ),
                controller: _refreshController,
                onLoading: requestFeednIterface,
                onRefresh: _onRefresh,
                child: ListView.builder(
                    controller: controller,
                    itemCount: widget.feedList.length,
                    itemBuilder: (context, index) {
                      return AutoScrollTag(
                          key: ValueKey(index),
                          controller: controller,
                          index: index,
                          child: DynamicListLayout(
                            index: index,
                            pageName: widget.pageName,
                            isShowConcern:false,
                            isShowRecommendUser: false,
                            model: widget.feedList[index],
                            // 可选参数 子Item的个数
                            key: GlobalObjectKey("attention$index"),
                          ));
                    })
                // child: CustomScrollView(physics: AlwaysScrollableScrollPhysics(), slivers: [
                //   SliverList(
                //     delegate: SliverChildBuilderDelegate((content, index) {
                //       return DynamicListLayout(
                //         index: index,
                //         pageName: widget.pageName,
                //         isShowRecommendUser: false,
                //         model: widget.feedList[index],
                //         // 可选参数 子Item的个数
                //         key: GlobalObjectKey("attention$index"),
                //         // deleteFeedChanged: (id) {
                //         //   setState(() {
                //         //     attentionIdList.remove(id);
                //         //     context.read<FeedMapNotifier>().deleteFeed(id);
                //         //   });
                //         // },
                //         // removeFollowChanged: (model) {
                //         //   int pushId = model.pushId;
                //         //   Map<int, HomeFeedModel> feedMap = context.read<FeedMapNotifier>().feedMap;
                //         //
                //         //   ///临时的空数组
                //         //   List<int> themList = [];
                //         //   feedMap.forEach((key, value) {
                //         //     if (value.pushId == pushId) {
                //         //       themList.add(key);
                //         //     }
                //         //   });
                //         //   setState(() {
                //         //     attentionIdList = arrayDate(attentionIdList, themList);
                //         //     loadStatus = LoadingStatus.STATUS_IDEL;
                //         //     loadText = "";
                //         //   });
                //         // },
                //       );
                //     }, childCount: widget.feedList.length),
                //   )
                // ])
                )));
  }
}
