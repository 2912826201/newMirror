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

class FeedFlowPage2 extends StatefulWidget {
  final Function onCallback;
  final int pullFeedType;
  final int pullFeedTargetId;
  final double initialScrollOffset;

  FeedFlowPage2({this.onCallback, this.pullFeedType, this.pullFeedTargetId, this.initialScrollOffset=0.0});

  @override
  _FeedFlowPage2State createState() => _FeedFlowPage2State();
}

class _FeedFlowPage2State extends State<FeedFlowPage2> {
  int state = 0;

  // scroll_to_index定位
  AutoScrollController controller;

  //上拉加载数据
  RefreshController _refreshController = RefreshController(initialRefresh: false);

  int firstIndex = -1;
  int lastIndex = -1;


  int showFirstItemPosition;
  int showEndItemPosition;
  int showItemCount=6;

  // ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    showFirstItemPosition=context.read<FeedFlowDataNotifier>().pageSelectPosition;
    if(showFirstItemPosition+5>=context.read<FeedFlowDataNotifier>().homeFeedModelList.length-1){
      showItemCount=context.read<FeedFlowDataNotifier>().homeFeedModelList.length-showFirstItemPosition;
      showEndItemPosition=context.read<FeedFlowDataNotifier>().homeFeedModelList.length;
    }else{
      showItemCount=5;
      showEndItemPosition=showItemCount+showFirstItemPosition;
    }

    // scrollController=new ScrollController(initialScrollOffset: widget.initialScrollOffset);
    //
    // if (scrollController.hasClients) {
    //   print("`````````````````````````````````${scrollController.offset}");
    // }
    controller = AutoScrollController(
        initialScrollOffset: widget.initialScrollOffset,
        viewportBoundaryGetter: () => Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: Axis.vertical);

    controller.addListener(() {
      print("_scrollController:::::::::${controller.offset}");
      if(controller.offset<controller.position.minScrollExtent){

        if(showFirstItemPosition-2<=0){
          showFirstItemPosition=0;
        }else{
          showFirstItemPosition-=2;
        }
        showItemCount=showEndItemPosition-showFirstItemPosition;

        print("showItemCount:$showItemCount,showEndItemPosition:$showEndItemPosition,showFirstItemPosition:$showFirstItemPosition");

        setState(() {

        });
      }else if(controller.offset>controller.position.maxScrollExtent){

        if(showEndItemPosition>=context.read<FeedFlowDataNotifier>().homeFeedModelList.length){
          return;
        }
        if(showEndItemPosition+2>=context.read<FeedFlowDataNotifier>().homeFeedModelList.length){
          showEndItemPosition=context.read<FeedFlowDataNotifier>().homeFeedModelList.length;
        }else{
          showEndItemPosition+=2;
        }
        showItemCount=showFirstItemPosition+showEndItemPosition;

        print("showItemCount:$showItemCount,showEndItemPosition:$showEndItemPosition,showFirstItemPosition:$showFirstItemPosition");

        setState(() {

        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
    return Container(
      child: getSmartRefresher(),
    );
  }


  Widget getSmartRefresher() {
    return SmartRefresher(
      enablePullDown: false,
      enablePullUp: false,
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
      physics: BouncingScrollPhysics(),
      controller: controller,
      childrenDelegate: FirstEndItemChildrenDelegate(
        (BuildContext context, int position) {
          int index=showFirstItemPosition+position;
          bool isHero = index == context.watch<FeedFlowDataNotifier>().pageSelectPosition;
          return autoScrollTag(index, context.watch<FeedFlowDataNotifier>().homeFeedModelList[index], isHero);
        },
        firstEndCallback: firstEndCallbackListView,
        childCount: showItemCount,
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
    // context.read<FeedFlowDataNotifier>().clear();
    // _onLoading();
    print("下拉刷新：_onRefresh-showFirstItemPosition：$showFirstItemPosition, showItemCount:$showItemCount");
    print("下拉刷新：itemcount:${context.read<FeedFlowDataNotifier>().homeFeedModelList.length}");
    _refreshController.refreshCompleted();
    _refreshController.loadComplete();
  }

  void _onLoading() async {

    print("上拉加载：_onLoading-showFirstItemPosition：$showFirstItemPosition, showItemCount:$showItemCount");
    print("上拉加载：itemcount:${context.read<FeedFlowDataNotifier>().homeFeedModelList.length}");
    _refreshController.refreshCompleted();
    _refreshController.loadComplete();
    //
    // int pageSize = context.read<FeedFlowDataNotifier>().pageSize;
    // int lastTime = context.read<FeedFlowDataNotifier>().pageLastTime;
    //
    // if (pageSize > 0 && lastTime == null) {
    //   _refreshController.refreshCompleted();
    //   _refreshController.loadComplete();
    //   return;
    // }
    // DataResponseModel model =
    //     await getPullList(type: widget.pullFeedType, size: 20, targetId: widget.pullFeedTargetId, lastTime: lastTime);
    // if (model != null && model.list != null && model.list.length > 0) {
    //   model.list.forEach((v) {
    //     context.read<FeedFlowDataNotifier>().homeFeedModelList.add(HomeFeedModel.fromJson(v));
    //   });
    //   context.read<FeedFlowDataNotifier>().pageLastTime = model.lastTime;
    //   context.read<FeedFlowDataNotifier>().pageSize = pageSize + 1;
    // }
    // _refreshController.refreshCompleted();
    // _refreshController.loadComplete();
    // if (mounted) {
    //   setState(() {});
    // }
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
