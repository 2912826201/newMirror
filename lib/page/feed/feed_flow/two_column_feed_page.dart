import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/api/search/search_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/data_response_model.dart';
import 'package:mirror/data/model/feed/feed_flow_data_notifier.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/page/message/message_view/currency_msg.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/util/integer_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/icon.dart';
import 'package:mirror/widget/smart_refressher_head_footer.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import 'feed_flow_page.dart';

class TwoColumnFeedPage extends StatefulWidget {
  final int targetId;
  final String keyWord;
  final FocusNode focusNode;

  TwoColumnFeedPage({
    this.targetId,
    this.keyWord,
    this.focusNode,
  });

  @override
  _TwoColumnFeedPageState createState() => _TwoColumnFeedPageState();
}

class _TwoColumnFeedPageState extends State<TwoColumnFeedPage> {
// 加载中默认文字
  String loadText = "加载中...";

  // 加载状态
  LoadingStatus loadStatus = LoadingStatus.STATUS_LOADING;

  //上拉加载数据
  RefreshController _refreshController = RefreshController(initialRefresh: false);

  // scroll_to_index定位
  AutoScrollController controller;

  String pageName = "OtherCompleteCoursePage";

  @override
  void initState() {
    super.initState();
    context.read<FeedFlowDataNotifier>().clear();
    controller = AutoScrollController(
        viewportBoundaryGetter: () => Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: Axis.vertical);
    loadStatus = LoadingStatus.STATUS_LOADING;
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.keyWord != null
          ? null
          : CustomAppBar(
              titleString: "TA们刚刚完成训练",
            ),
      body: Container(
        color: AppColor.bgWhite,
        child: _buildSuggestions(),
      ),
    );
  }

  Widget _buildSuggestions() {
    if (context.watch<FeedFlowDataNotifier>().homeFeedModelList != null &&
        context.watch<FeedFlowDataNotifier>().homeFeedModelList.length > 0) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: getRefreshIndicator(),
      );
    } else {
      return getNoDateUi();
    }
  }

  Widget getNoDateUi() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 224,
            height: 224,
            color: AppColor.color246,
            margin: EdgeInsets.only(bottom: 16, top: 188),
          ),
          Text(
            "这里空空如也，去推荐看看吧",
            style: TextStyle(fontSize: 14, color: AppColor.textSecondary),
          ),
        ],
      ),
    );
  }

  //有数据的ui
  Widget getRefreshIndicator() {
    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      header: SmartRefresherHeadFooter.init().getHeader(),
      footer: SmartRefresherHeadFooter.init().getFooter(),
      controller: _refreshController,
      onLoading: _loadData,
      onRefresh: _onRefresh,
      child: listView(),
    );
  }

  //获取listview
  Widget listView() {
    return WaterfallFlow.builder(
      shrinkWrap: true,
      physics: BouncingScrollPhysics(),
      controller: controller,
      gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        // 上下间隔
        mainAxisSpacing: 4.0,
        // 左右间隔
        crossAxisSpacing: 8.0,
      ),
      itemBuilder: (context, index) {
        bool isHero = index == context.watch<FeedFlowDataNotifier>().pageSelectPosition &&
            pageName == context.watch<FeedFlowDataNotifier>().pageName;
        return autoScrollTag(context.watch<FeedFlowDataNotifier>().homeFeedModelList[index], index,
            context.watch<FeedFlowDataNotifier>().homeFeedModelList.length, isHero);
      },
      itemCount: context.watch<FeedFlowDataNotifier>().homeFeedModelList.length,
    );
    //   StaggeredGridView.countBuilder(
    //   shrinkWrap: true,
    //   physics: BouncingScrollPhysics(),
    //   itemCount: recommendTopicList.length,
    //   primary: false,
    //   crossAxisCount: 4,
    //   // 上下间隔
    //   mainAxisSpacing: 8.0,
    //   // 左右间隔
    //   crossAxisSpacing: 8.0,
    //   controller: _scrollController,
    //   itemBuilder: (context, index) {
    //     return GestureDetector(
    //       child: Hero(
    //         tag: "complex${recommendTopicList[index].id}",
    //         child:item(recommendTopicList[index],index,recommendTopicList.length),
    //       ),
    //       onTap: (){
    //         HomeFeedModel feedModel = recommendTopicList[index];
    //         List<HomeFeedModel> list = [];
    //         list.add(feedModel);
    //         context.read<FeedMapNotifier>().updateFeedMap(list);
    //         Navigator.push(
    //           context,
    //           new MaterialPageRoute(builder: (context) => FeedDetailPage(model: feedModel,type: 1,)),
    //         );
    //       },
    //     );
    //   },
    //   staggeredTileBuilder: (index) => StaggeredTile.fit(2),
    // );
  }

  Widget autoScrollTag(HomeFeedModel homeFeedModel, int index, int length, bool isHero) {
    return AutoScrollTag(
      key: ValueKey(index),
      controller: controller,
      index: index,
      child: GestureDetector(
        child: item(homeFeedModel, index, length, isHero),
        onTap: () => oneListViewListItemClick(index),
      ),
    );
  }

  Widget item(HomeFeedModel homeFeedModel, int index, int length, bool isHero) {
    return Container(
      color: Colors.transparent,
      child: Column(
        children: [
          Visibility(
            visible: index == 0 || index == 1,
            child: SizedBox(height: 16),
          ),
          ClipRRect(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(3), topRight: Radius.circular(3)),
            child: isHero
                ? Hero(
                    tag: "TwoColumnFeedPage${homeFeedModel.id}$index",
                    child: Container(
                      width: double.infinity,
                      child: getImage(homeFeedModel, index),
                    ),
                  )
                : Container(
                    width: double.infinity,
                    child: getImage(homeFeedModel, index),
                  ),
          ),
          Container(
            width: double.infinity,
            color: AppColor.white,
            padding: const EdgeInsets.only(left: 8, right: 8, top: 6),
            child: Text(
              homeFeedModel.content,
              style: TextStyle(fontSize: 13, color: AppColor.textPrimary1),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(3), bottomRight: Radius.circular(3)),
            child: getHorUserItem(homeFeedModel, index),
          ),
          Visibility(
            visible: index == length - 1 || index == length - 2,
            child: SizedBox(height: 16),
          ),
        ],
      ),
    );
  }

  //横向的用户资料
  Widget getHorUserItem(HomeFeedModel homeFeedModel, int index) {
    return Container(
      width: double.infinity,
      color: AppColor.white,
      padding: const EdgeInsets.only(left: 8, right: 8, top: 6, bottom: 8),
      child: Stack(
        children: [
          Row(
            children: [
              getUserImage(homeFeedModel.avatarUrl, 16, 16),
              SizedBox(width: 4),
              Expanded(
                child: SizedBox(
                  child: Text(
                    homeFeedModel.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              AppIcon.getAppIcon(homeFeedModel.isLaud == 1 ? AppIcon.like_red_12 : AppIcon.like_12, 12),
              SizedBox(width: 5),
              Text(
                IntegerUtil.formatIntegerEn(homeFeedModel.laudCount),
                style: TextStyle(color: AppColor.textSecondary, fontSize: 12),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: SizedBox(
                child: GestureDetector(
                  child: Container(
                    height: 20,
                    color: Colors.transparent,
                  ),
                  onTap: () {
                    print("点击了用户名字");
                  },
                ),
              )),
              GestureDetector(
                child: Container(
                  height: 20,
                  width: 50,
                  color: Colors.transparent,
                ),
                onTap: () {
                  print("点赞");
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  //获取图片
  Widget getImage(HomeFeedModel homeFeedModel, int index) {
    String url = "";
    int width = 1024;
    int height = 1024;
    bool isImageOrVideo = true;
    if (homeFeedModel.picUrls != null && homeFeedModel.picUrls.length > 0) {
      url = homeFeedModel.picUrls[0].url;
      width = homeFeedModel.picUrls[0].width;
      height = homeFeedModel.picUrls[0].height;
      isImageOrVideo = true;
    } else if (homeFeedModel.videos != null && homeFeedModel.videos.length > 0) {
      url = FileUtil.getVideoFirstPhoto(homeFeedModel.videos[0].url);
      width = homeFeedModel.videos[0].width;
      height = homeFeedModel.videos[0].height;
      isImageOrVideo = false;
    }

    return Container(
      width: double.infinity,
      child: Stack(
        children: [
          ClipRRect(
            //圆角图片
            borderRadius: BorderRadius.circular(2),
            child: CachedNetworkImage(
              height: setAspectRatio(height.toDouble(), width.toDouble(), index),
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => new Container(
                  child: new Center(
                child: new CircularProgressIndicator(),
              )),
              imageUrl: url,
              errorWidget: (context, url, error) => new Image.asset("images/test.png"),
            ),
          ),
          Positioned(
            child: Visibility(
              visible: !isImageOrVideo,
              child: Icon(
                Icons.play_circle_outline_outlined,
                size: 18,
                color: AppColor.white,
              ),
            ),
            right: 10,
            top: 8,
          ),
        ],
      ),
    );
  }

  void oneListViewListItemClick(int index) async {
    if (widget.focusNode != null) {
      widget.focusNode.unfocus();
    }
    context.read<FeedFlowDataNotifier>().pageSelectPosition = index;
    context.read<FeedFlowDataNotifier>().pageName = pageName;
    setState(() {});
    Future.delayed(Duration(milliseconds: 100), () {
      Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: Duration(milliseconds: 500),
            pageBuilder: (_, __, ___) => FeedFlowPage(
              pullFeedType: 7,
              pullFeedTargetId: widget.targetId,
              onCallback: resetHero,
            ), // <-- here is the magic
          ));
    });
  }

  void resetHero() async {
    if (mounted) {
      setState(() {});
      Future.delayed(Duration(milliseconds: 100), () async {
        print("回滚jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj---${context.read<FeedFlowDataNotifier>().pageSelectPosition}");
        await controller.scrollToIndex(context.read<FeedFlowDataNotifier>().pageSelectPosition,
            duration: Duration(milliseconds: 1), preferPosition: AutoScrollPosition.begin);
        setState(() {});
      });
    }
  }

  //刷新
  void _onRefresh() {
    context.read<FeedFlowDataNotifier>().clear();
    _loadData();
  }

  //加载数据
  void _loadData() async {
    int pageSize = context.read<FeedFlowDataNotifier>().pageSize;
    int lastTime = context.read<FeedFlowDataNotifier>().pageLastTime;

    if (pageSize > 0 && lastTime == null) {
      _refreshController.refreshCompleted();
      _refreshController.loadComplete();
      return;
    }
    DataResponseModel model = widget.keyWord == null
        ? await getPullList(type: 7, size: 20, targetId: widget.targetId, lastTime: lastTime)
        : await searchFeed(key: widget.keyWord, size: 20, lastTime: lastTime);
    if (model != null && model.list != null && model.list.length > 0) {
      model.list.forEach((v) {
        context.read<FeedFlowDataNotifier>().homeFeedModelList.add(HomeFeedModel.fromJson(v));
        context.read<FeedFlowDataNotifier>().homeFeedModelList.add(HomeFeedModel.fromJson(v));
        context.read<FeedFlowDataNotifier>().homeFeedModelList.add(HomeFeedModel.fromJson(v));
        context.read<FeedFlowDataNotifier>().homeFeedModelList.add(HomeFeedModel.fromJson(v));
        context.read<FeedFlowDataNotifier>().homeFeedModelList.add(HomeFeedModel.fromJson(v));
        context.read<FeedFlowDataNotifier>().homeFeedModelList.add(HomeFeedModel.fromJson(v));
        context.read<FeedFlowDataNotifier>().homeFeedModelList.add(HomeFeedModel.fromJson(v));
        context.read<FeedFlowDataNotifier>().homeFeedModelList.add(HomeFeedModel.fromJson(v));
        context.read<FeedFlowDataNotifier>().homeFeedModelList.add(HomeFeedModel.fromJson(v));
        context.read<FeedFlowDataNotifier>().homeFeedModelList.add(HomeFeedModel.fromJson(v));
        context.read<FeedFlowDataNotifier>().homeFeedModelList.add(HomeFeedModel.fromJson(v));
        context.read<FeedFlowDataNotifier>().homeFeedModelList.add(HomeFeedModel.fromJson(v));
        context.read<FeedFlowDataNotifier>().homeFeedModelList.add(HomeFeedModel.fromJson(v));
        context.read<FeedFlowDataNotifier>().homeFeedModelList.add(HomeFeedModel.fromJson(v));
        context.read<FeedFlowDataNotifier>().homeFeedModelList.add(HomeFeedModel.fromJson(v));
        context.read<FeedFlowDataNotifier>().homeFeedModelList.add(HomeFeedModel.fromJson(v));
        context.read<FeedFlowDataNotifier>().homeFeedModelList.add(HomeFeedModel.fromJson(v));
        context.read<FeedFlowDataNotifier>().homeFeedModelList.add(HomeFeedModel.fromJson(v));
        context.read<FeedFlowDataNotifier>().homeFeedModelList.add(HomeFeedModel.fromJson(v));
        context.read<FeedFlowDataNotifier>().homeFeedModelList.add(HomeFeedModel.fromJson(v));
        context.read<FeedFlowDataNotifier>().homeFeedModelList.add(HomeFeedModel.fromJson(v));
        context.read<FeedFlowDataNotifier>().homeFeedModelList.add(HomeFeedModel.fromJson(v));
        context.read<FeedFlowDataNotifier>().homeFeedModelList.add(HomeFeedModel.fromJson(v));
        context.read<FeedFlowDataNotifier>().homeFeedModelList.add(HomeFeedModel.fromJson(v));
        context.read<FeedFlowDataNotifier>().homeFeedModelList.add(HomeFeedModel.fromJson(v));
        context.read<FeedFlowDataNotifier>().homeFeedModelList.add(HomeFeedModel.fromJson(v));
        context.read<FeedFlowDataNotifier>().homeFeedModelList.add(HomeFeedModel.fromJson(v));
        context.read<FeedFlowDataNotifier>().homeFeedModelList.add(HomeFeedModel.fromJson(v));
        context.read<FeedFlowDataNotifier>().homeFeedModelList.add(HomeFeedModel.fromJson(v));
        context.read<FeedFlowDataNotifier>().homeFeedModelList.add(HomeFeedModel.fromJson(v));
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

  // 宽高比例高度
  double setAspectRatio(double height, double width, int index) {
    if (index == 0) {
      return (((ScreenUtil.instance.screenWidthDp - 32) / 2 - 4) / width) * height - 20;
    }
    return (((ScreenUtil.instance.screenWidthDp - 32) / 2 - 4) / width) * height;
  }

  //
  getInitialScrollOffset(int index) {
    double initialScrollOffset = 0.0;
    for (int i = 0; i < index; i++) {
      // HomeFeedModel homeFeedModel=context.read<FeedFlowDataNotifier>().homeFeedModelList[i];
      initialScrollOffset += 630.0;
      // initialScrollOffset+=48.0;
      // initialScrollOffset+=60.0;
    }
    return initialScrollOffset;
  }
}
