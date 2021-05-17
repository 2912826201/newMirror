import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/data_response_model.dart';
import 'package:mirror/data/model/feed/feed_flow_data_notifier.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/page/home/sub_page/share_page/dynamic_list.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/first_end_item_children_delegate.dart';
import 'package:mirror/widget/pull_to_refresh/pull_to_refresh.dart';
import 'package:mirror/widget/smart_refressher_head_footer.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class FeedFlowPage extends StatefulWidget {
  final Function onCallback;
  final int pullFeedType;
  final int pullFeedTargetId;
  final double initScrollHeight;
  final String pageName;

  FeedFlowPage({this.pageName, this.onCallback, this.pullFeedType, this.pullFeedTargetId, this.initScrollHeight = 0.0});

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

  @override
  void initState() {
    super.initState();

    print("widget.initScrollHeight:${widget.initScrollHeight}");

    controller = AutoScrollController(
        initialScrollOffset: widget.initScrollHeight,
        viewportBoundaryGetter: () => Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: Axis.vertical);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleString: "TA们刚刚完成训练",
        leadingOnTap: requestPop,
      ),
      body: getBody(),
    );
  }

  Widget getBody() {
    return Container(
      color: AppColor.white,
      child: getSmartRefresher(),
    );
  }

  Widget getSmartRefresher() {
    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      footer: footerWidget(),
      header: SmartRefresherHeadFooter.init().getHeader(),
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      controller: _refreshController,
      child: getListViewData(),
    );
  }

  Widget getListViewData() {
    return ListView.custom(
      controller: controller,
      physics: BouncingScrollPhysics(),
      childrenDelegate: FirstEndItemChildrenDelegate(
        (BuildContext context, int index) {
          if (index >= context.watch<FeedFlowDataNotifier>().homeFeedModelList.length+1) {
            return Container();
          }
          if (index == context.watch<FeedFlowDataNotifier>().homeFeedModelList.length) {
            return Container(
              color: Colors.transparent,
              height: 20,
            );
          }
          bool isHero = index == context.watch<FeedFlowDataNotifier>().pageSelectPosition;

          return autoScrollTag(index, context.watch<FeedFlowDataNotifier>().homeFeedModelList[index], isHero);
        },
        firstEndCallback: firstEndCallbackListView,
        childCount: context.watch<FeedFlowDataNotifier>().homeFeedModelList.length + 1,
      ),
      dragStartBehavior: DragStartBehavior.down,
    );
  }

  Widget autoScrollTag(int index, HomeFeedModel homeFeedModel, bool isHero) {
    return AutoScrollTag(
      key: ValueKey(index),
      controller: controller,
      index: index,
      child: Container(
        color: AppColor.white,
        child: DynamicListLayout(
          index: index,
          pageName: widget.pageName,
          isShowRecommendUser: false,
          isHero: isHero,
          model: homeFeedModel,
          // 可选参数 子Item的个数
          key: GlobalObjectKey("attention$index"),
        ),
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
    _onLoading(isRefresh: true);
  }

  void _onLoading({bool isRefresh = false}) async {
    int pageSize = context.read<FeedFlowDataNotifier>().pageSize;
    int lastTime = context.read<FeedFlowDataNotifier>().pageLastTime;

    if (isRefresh) {
      pageSize = 0;
      lastTime = null;
    }

    if (pageSize > 0 && lastTime == null) {
      _refreshController.refreshCompleted();
      _refreshController.loadComplete();
      return;
    }
    DataResponseModel model =
        await getPullList(type: widget.pullFeedType, size: 20, targetId: widget.pullFeedTargetId, lastTime: lastTime);
    if(context==null||!mounted){
      return;
    }
    if (isRefresh) {
      context.read<FeedFlowDataNotifier>().clear();
    }
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
    return new Future.value(true);
    // print("_requestPop");
    // if (ClickUtil.isFastClick(time: 600)) {
    //   return new Future.value(false);
    // }
    //
    // int firstIndex = this.firstIndex;
    // if (this.lastIndex - this.firstIndex > 1) {
    //   firstIndex++;
    // }else if(this.lastIndex==context.read<FeedFlowDataNotifier>().homeFeedModelList.length-1){
    //   firstIndex++;
    // }
    // print("11111111--$firstIndex");
    // if (context.read<FeedFlowDataNotifier>().pageSelectPosition != firstIndex) {
    //   context.read<FeedFlowDataNotifier>().pageSelectPosition = firstIndex;
    //   print("11111111--$context.read<FeedFlowDataNotifier>().pageSelectPosition");
    //   if (widget.onCallback != null) {
    //     print("11111111--onCallback");
    //     widget.onCallback();
    //   }
    //   if(mounted) {
    //     setState(() {});
    //   }
    //   Future.delayed(Duration(milliseconds: 300), () {
    //     Navigator.of(context).pop();
    //   });
    //   return new Future.value(false);
    // }
    // print("222222222222222222");
    // return new Future.value(true);
  }
}
