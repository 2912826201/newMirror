import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
  TopicRecommend({Key key,this.topicId}) : super(key: key);
  int topicId;
  @override
  TopicRecommendState createState() => TopicRecommendState();

}
class TopicRecommendState extends State<TopicRecommend> {
  // 加载中默认文字
  String loadText = "";

  // 加载状态
  LoadingStatus loadStatus = LoadingStatus.STATUS_IDEL;

  // 数据加载页数
  int dataPage = 1;
  // 话题ListModel
  List<HomeFeedModel>  topicList = [];
  @override
  void initState() {
    // TODO: implement initState
    requestRecommendTopic();
    super.initState();
  }
  // 请求动态详情接口      model = await getPullList
  requestRecommendTopic() async {
    if (loadStatus == LoadingStatus.STATUS_IDEL) {
      // 先设置状态，防止下拉就直接加载
      setState(() {
        loadStatus = LoadingStatus.STATUS_LOADING;
      });
    }
    DataResponseModel model = await getPullList(type: 5, size: 20,targetId:widget.topicId );
    setState(() {
      if (dataPage == 1) {
        if (model.list.isNotEmpty) {
          model.list.forEach((v) {
            topicList.add(HomeFeedModel.fromJson(v));
          });
          if (model.hasNext == 0) {
            loadText = "";
            loadStatus = LoadingStatus.STATUS_IDEL;
          }

        }
      } else if (dataPage > 1 ) {
        if (model.list.isNotEmpty) {
          model.list.forEach((v) {
            topicList.add(HomeFeedModel.fromJson(v));
          });
          loadStatus = LoadingStatus.STATUS_IDEL;
          loadText = "加载中...";
        } else {
          // 加载完毕
          loadText = "已加载全部话题动态";
          loadStatus = LoadingStatus.STATUS_COMPLETED;
        }
      }
    });
    context.read<FeedMapNotifier>().updateFeedMap(topicList);
  }

  //
  @override
  Widget build(BuildContext context) {
    if (topicList.isNotEmpty) {
      return Container(
          child: RefreshIndicator(
              onRefresh: () async {
                topicList.clear();
                dataPage = 1;
                loadStatus = LoadingStatus.STATUS_LOADING;
                loadText = "加载中...";
                requestRecommendTopic();
              },
              // child:
              //     CustomScrollView(controller: _scrollController, physics: AlwaysScrollableScrollPhysics(), slivers: [
              //   SliverToBoxAdapter(
              child: Container(
                margin: EdgeInsets.only(left: 16, right: 16),
                child: StaggeredGridView.countBuilder(
                  physics:NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: topicList.length + 1,
                  primary: false,
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
                    if (index < topicList.length) {
                      id = topicList[index].id;
                      model = context
                          .read<FeedMapNotifier>()
                          .feedMap[id];
                    }
                    // if (feedList.isNotEmpty) {
                    if (index == topicList.length) {
                      return LoadingView(
                        loadText: loadText,
                        loadStatus: loadStatus,
                      );
                    } else if (index == topicList.length + 1) {
                      return Container();
                    } else {
                      return SearchFeeditem(
                        model: model,
                        list: topicList,
                        index: index,
                        isComplex: false,
                      );
                    }
                    // }
                  },
                  staggeredTileBuilder: (index) => StaggeredTile.fit(2),
                ),
              ))
        //     ])
        // )
      );
    } else {
      return Container(
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

}