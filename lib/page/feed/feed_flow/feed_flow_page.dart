import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/data_response_model.dart';
import 'package:mirror/data/model/feed/feed_flow_data_notifier.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/page/feed/feed_flow/feed_flow_item.dart';
import 'package:mirror/page/home/sub_page/share_page/dynamic_list.dart';
import 'package:mirror/page/search/sub_page/search_feed.dart';
import 'package:mirror/util/click_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/first_end_item_children_delegate.dart';
import 'package:mirror/widget/slide_banner.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class FeedFlowPage extends StatefulWidget {
  final Function onCallback;
  final int pullFeedType;
  final int pullFeedTargetId;
  final double initialScrollOffset;

  FeedFlowPage({this.onCallback, this.pullFeedType, this.pullFeedTargetId, this.initialScrollOffset=0.0});

  @override
  _FeedFlowPageState createState() => _FeedFlowPageState();
}

class _FeedFlowPageState extends State<FeedFlowPage> {
  int state = 0;

  // scroll_to_index定位
  AutoScrollController controller;

  //上拉加载数据
  RefreshController _refreshController = RefreshController(initialRefresh: false);

  int firstIndex = -1;
  int lastIndex = -1;


  // ScrollController scrollController;

  @override
  void initState() {
    super.initState();

    // scrollController=new ScrollController(initialScrollOffset: widget.initialScrollOffset);
    //
    // if (scrollController.hasClients) {
    //   print("`````````````````````````````````${scrollController.offset}");
    // }
    controller = AutoScrollController(
        initialScrollOffset: 0,
        viewportBoundaryGetter: () => Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: Axis.vertical);

    // scrollController.addListener(() {
    //   print("_scrollController:::::::::${scrollController.offset}");
    // });
  }

  @override
  Widget build(BuildContext context) {
    print("11111111111111111111111111111111111111111111");
    return WillPopScope(
        child: Scaffold(
          appBar: CustomAppBar(
            titleString: "动态流",
            leadingOnTap: requestPop,
          ),
          body: getBody(),
        ),
        onWillPop: _requestPop);
  }

  Widget getBody() {
    // state = 1;
    int position = context.watch<FeedFlowDataNotifier>().pageSelectPosition;
    if (state == 0) {
      Future.delayed(Duration(milliseconds: 200), () async {
        state = 1;
        controller.jumpTo(widget.initialScrollOffset);
        // await controller.scrollToIndex(position,
        //     duration: Duration(milliseconds: 1), preferPosition: AutoScrollPosition.begin);
        Future.delayed(Duration(milliseconds: 200), () async {
          state = 1;
          if (mounted) {
            setState(() {});
          }
        });
      });
    }
    return Container(
      child: Stack(
        children: [
          getSmartRefresher(),
          Visibility(
            visible: state == 0,
            child: getColumnData(),
          ),
        ],
      ),
    );
  }

  Widget getColumnData() {
    var widgetArray = <Widget>[];
    int pageSelectPosition = context.watch<FeedFlowDataNotifier>().pageSelectPosition;
    int modelLength = context.watch<FeedFlowDataNotifier>().homeFeedModelList.length;
    if(modelLength>5){
      modelLength=5;
    }
    return Container(
      color: AppColor.white,
      child: ListView.builder(
        // controller: scrollController,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          if (index == 0) {
            return DynamicListLayout(
              index: pageSelectPosition,
              pageName: "TwoColumnFeedPage",
              isShowRecommendUser: false,
              isHero: true,
              model: context.watch<FeedFlowDataNotifier>().homeFeedModelList[pageSelectPosition],
              // 可选参数 子Item的个数
              key: GlobalObjectKey("attention$pageSelectPosition"),
            );
          } else {
            return DynamicListLayout(
              index: index,
              pageName: "TwoColumnFeedPage",
              isShowRecommendUser: false,
              model: context.watch<FeedFlowDataNotifier>().homeFeedModelList[index],
              // 可选参数 子Item的个数
              key: GlobalObjectKey("attention$index"),
            );
          }
        },
        itemCount: modelLength,
      ),
    );
  }

  Widget getSmartRefresher() {
    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      footer: footerWidget(),
      header: WaterDropHeader(
        complete: Text("刷新完成"),
        failed: Text(" "),
      ),
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      controller: _refreshController,
      child: getListViewData(),
    );
  }

  Widget getListViewData() {
    return ListView.custom(
      controller: controller,
      itemExtent: 630,
      childrenDelegate: FirstEndItemChildrenDelegate(
        (BuildContext context, int index) {
          bool isHero = index == context.watch<FeedFlowDataNotifier>().pageSelectPosition && state != 0;

          return autoScrollTag(index, context.watch<FeedFlowDataNotifier>().homeFeedModelList[index], isHero);
        },
        firstEndCallback: firstEndCallbackListView,
        childCount: context.watch<FeedFlowDataNotifier>().homeFeedModelList.length,
      ),
      dragStartBehavior: DragStartBehavior.down,
    );
  }

  Color getColor(int index) {
    if (index % 5 == 1) {
      return Colors.red;
    } else if (index % 5 == 2) {
      return Colors.lightGreen;
    } else if (index % 5 == 3) {
      return Colors.amberAccent;
    } else if (index % 5 == 4) {
      return Colors.tealAccent;
    } else {
      return Colors.deepPurpleAccent;
    }
  }

  Widget autoScrollTag(int index, HomeFeedModel homeFeedModel, bool isHero) {
    return AutoScrollTag(
      key: ValueKey(index),
      controller: controller,
      index: index,
      child: DynamicListLayout(
        index: index,
        pageName: "TwoColumnFeedPage",
        isShowRecommendUser: true,
        isHero: isHero,
        model: homeFeedModel,
        // 可选参数 子Item的个数
        key: GlobalObjectKey("attention$index"),
      ),
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

  void firstEndCallbackListView(int firstIndex, int lastIndex) {
    this.firstIndex = firstIndex;
    this.lastIndex = lastIndex;
    print("firstIndex:$firstIndex, lastIndex:$lastIndex");
  }

  void _onRefresh() async {
    context.read<FeedFlowDataNotifier>().clear();
    _onLoading();
  }

  void _onLoading() async {
    int pageSize = context.read<FeedFlowDataNotifier>().pageSize;
    int lastTime = context.read<FeedFlowDataNotifier>().pageLastTime;

    if (pageSize > 0 && lastTime == null) {
      _refreshController.refreshCompleted();
      _refreshController.loadComplete();
      return;
    }
    DataResponseModel model =
        await getPullList(type: widget.pullFeedType, size: 20, targetId: widget.pullFeedTargetId, lastTime: lastTime);
    if (model != null && model.list != null && model.list.length > 0) {
      model.list.forEach((v) {
        context.read<FeedFlowDataNotifier>().homeFeedModelList.add(HomeFeedModel.fromJson(v));
      });
      context.read<FeedFlowDataNotifier>().pageLastTime = model.lastTime;
      context.read<FeedFlowDataNotifier>().pageSize = pageSize + 1;
    }
    _refreshController.refreshCompleted();
    _refreshController.loadComplete();
    if (mounted) {
      setState(() {});
    }
  }

  void requestPop() async {
    if (await _requestPop()) {
      Future.delayed(Duration.zero, () {
        Navigator.of(context).pop();
      });
    }
  }

  // 监听返回
  Future<bool> _requestPop() {
    print("_requestPop");
    if (ClickUtil.isFastClick(time: 600)) {
      return new Future.value(false);
    }

    int firstIndex = this.firstIndex;
    if (this.lastIndex - this.firstIndex > 1) {
      firstIndex++;
    }else if(this.lastIndex==context.read<FeedFlowDataNotifier>().homeFeedModelList.length-1){
      firstIndex++;
    }
    print("11111111--$firstIndex");
    if (context.read<FeedFlowDataNotifier>().pageSelectPosition != firstIndex) {
      context.read<FeedFlowDataNotifier>().pageSelectPosition = firstIndex;
      print("11111111--$context.read<FeedFlowDataNotifier>().pageSelectPosition");
      if (widget.onCallback != null) {
        print("11111111--onCallback");
        widget.onCallback();
      }
      if(mounted) {
        setState(() {});
      }
      Future.delayed(Duration(milliseconds: 300), () {
        Navigator.of(context).pop();
      });
      return new Future.value(false);
    }
    print("222222222222222222");
    return new Future.value(true);
  }
}
