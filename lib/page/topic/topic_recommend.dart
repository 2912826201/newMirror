import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound_lite/flutter_sound.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/data_response_model.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/page/home/sub_page/recommend_page.dart';
import 'package:mirror/page/search/sub_page/search_feed.dart';
import 'package:provider/provider.dart';

class TopicRecommend extends StatefulWidget {
  TopicRecommend({this.loadText, this.loadStatus, this.tabKey, this.topicList, this.refreshCallBack});

  final ValueChanged<bool> refreshCallBack;
  Key tabKey;

  // 话题ListModel
  List<HomeFeedModel> topicList;

  // 加载中默认文字
  String loadText = "";

  // 加载状态
  LoadingStatus loadStatus = LoadingStatus.STATUS_IDEL;

  @override
  TopicRecommendState createState() => TopicRecommendState();
}
class TopicRecommendState extends State<TopicRecommend> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; //必须重写
  @override
  Widget build(BuildContext context) {
    Container child = Container(
        child: RefreshIndicator(
            onRefresh: () async {
              widget.refreshCallBack(true);
            },
            child: Container(
                margin: EdgeInsets.only(left: 16, right: 16),
                child: StaggeredGridView.countBuilder(
                  itemCount: widget.topicList.length + 1,
                  crossAxisCount: 4,
                  // 上下间隔
                  mainAxisSpacing: 4.0,
                  // 左右间隔
                  crossAxisSpacing: 8.0,
                  itemBuilder: (context, index) {
                    // 获取动态id
                    int id;
                    // 获取动态id指定model
                    HomeFeedModel model;
                    if (index < widget.topicList.length) {
                      id = widget.topicList[index].id;
                      model = context.read<FeedMapNotifier>().feedMap[id];
                    }
                    // if (feedList.isNotEmpty) {
                    if (index == widget.topicList.length) {
                      return LoadingView(
                        loadText: widget.loadText,
                        loadStatus: widget.loadStatus,
                      );
                    } else if (index == widget.topicList.length + 1) {
                      return Container();
                    } else {
                      return SearchFeeditem(
                        model: model,
                        list: widget.topicList,
                        index: index,
                        isComplex: false,
                      );
                    }
                  },
                  staggeredTileBuilder: (index) => StaggeredTile.fit(2),
                ))));
    return widget.topicList.isNotEmpty
        ? NestedScrollViewInnerScrollPositionKeyWidget(widget.tabKey, child)
        : Container(
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

}