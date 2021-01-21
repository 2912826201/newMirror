import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/training/live_video_model.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/page/home/sub_page/share_page/dynamic_list.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:provider/provider.dart';

FocusNode commentFocus = FocusNode();

// 加载中的布局
class LoadingView extends StatelessWidget {
  String loadText;
  LoadingStatus loadStatus;

  LoadingView({this.loadText, this.loadStatus});

  Widget _pad(Widget widget, {l, t, r, b}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(l ??= 0.0, t ??= 0.0, r ??= 0.0, b ??= 0.0),
      child: widget,
    );
  }

  var loadingTs = TextStyle(color: AppColor.textHint, fontSize: 12);

  @override
  Widget build(BuildContext context) {
    var loadingText = _pad(
        Text(
          loadText,
          style: loadingTs,
        ),
        l: 20.0);
    var loadingIndicator = Visibility(
        visible: loadStatus == LoadingStatus.STATUS_LOADING ? true : false,
        child: SizedBox(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(AppColor.mainRed),
            // loading 大小
            strokeWidth: 2,
          ),
          width: 12.0,
          height: 12.0,
        ));
    return _pad(
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            loadingIndicator,
            loadingText,
          ],
        ),
        b: 20.0);
  }
}

// 推荐
class RecommendPage extends StatefulWidget {
  RecommendPage({Key key, this.pc}) : super(key: key);
  PanelController pc = new PanelController();

  RecommendPageState createState() => RecommendPageState();
}

class RecommendPageState extends State<RecommendPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; //必须重写
  // 数据源
  List<int> recommendIdList = [];
  List<HomeFeedModel> recommendModelList = [];
  List<LiveVideoModel> liveVideoModel = [];

  // 列表监听
  ScrollController _controller = new ScrollController();

  // 请求下一页
  int lastTime;

  // 加载中默认文字
  String loadText = "";

  // 加载状态
  LoadingStatus loadStatus = LoadingStatus.STATUS_IDEL;

  // 数据加载页数
  int dataPage = 1;
@override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  void initState() {
    // 合并请求
    mergeRequest();
    // Future.wait([
    // // 请求推荐接口
    //  getHotList(size: 20),
    //   // 请求推荐教练
    //   recommendCoach(),
    // ]).then((results) {
    //   List<HomeFeedModel> modelList = results[0];
    //    if (modelList.isNotEmpty) {
    //      for (HomeFeedModel model in modelList) {
    //        recommendIdList.add(model.id);
    //      }
    //      recommendModelList.addAll(modelList);
    //    }
    //   // 更新全局监听
    //   context.read<FeedMapNotifier>().updateFeedMap(recommendModelList);
    //   courseList = results[1];
    //   setState(() {});
    // }).catchError((e) {
    //   print("报错了");
    //   print(e);
    // });
    _controller.addListener(() {
      if (_controller.position.pixels == _controller.position.maxScrollExtent) {
        dataPage += 1;
        getRecommendFeed();
      }
    });
    super.initState();
  }

  // 合并请求
  mergeRequest() {
    // 合并请求
    Future.wait([
      // 请求推荐接口
      getHotList(size: 20),
      // 请求推荐教练
      // recommendCoach(),
      newRecommendCoach(),
    ]).then((results) {
      if (results[0] != null) {
        List<HomeFeedModel> modelList = results[0];
        if (modelList.isNotEmpty) {
          for (HomeFeedModel model in modelList) {
            recommendIdList.add(model.id);
          }
          recommendModelList.addAll(modelList);
        }
        // 更新全局监听
        context.read<FeedMapNotifier>().updateFeedMap(recommendModelList);
      }
      if (results[1] != null) {
        liveVideoModel = results[1];
        print("推荐教练书剑返回");
        print(liveVideoModel.toString());
      }
      setState(() {});
    }).catchError((e) {
      print("报错了");
      print(e);
    });
  }

  // 推荐页model
  getRecommendFeed() async {
    if (loadStatus == LoadingStatus.STATUS_IDEL) {
      // 先设置状态，防止下拉就直接加载
      setState(() {
        loadStatus = LoadingStatus.STATUS_LOADING;
      });
    }
    // 请求推荐接口
    List<HomeFeedModel> modelList = await getHotList(size: 20);

    setState(() {
      if (dataPage == 1) {
        if (modelList.isNotEmpty) {
          for (HomeFeedModel model in modelList) {
            recommendIdList.add(model.id);
          }
          recommendModelList.addAll(modelList);
        }
      } else if (dataPage > 1) {
        if (modelList.isNotEmpty) {
          for (HomeFeedModel model in modelList) {
            recommendIdList.add(model.id);
          }
          recommendModelList.addAll(modelList);
        }
        loadStatus = LoadingStatus.STATUS_IDEL;
        loadText = "加载中...";
      } else {
        // 加载完毕
        loadText = "已加载全部动态";
        loadStatus = LoadingStatus.STATUS_COMPLETED;
      }
    });
    // 更新全局监听
    context.read<FeedMapNotifier>().updateFeedMap(recommendModelList);
  }

  @override
  Widget build(BuildContext context) {
    double screen_top = ScreenUtil.instance.statusBarHeight;
    final double bottomPadding = ScreenUtil.instance.bottomBarHeight;
    print("推荐页");
    return Stack(
      children: [
        Container(
            child: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification notification) {
            ScrollMetrics metrics = notification.metrics;
            // 注册通知回调
            if (notification is ScrollStartNotification) {
              // 滚动开始
              // print('滚动开始');
            } else if (notification is ScrollUpdateNotification) {
              // 滚动位置更新
              // print('滚动位置更新');
              // 当前位置
              // print("当前位置${metrics.pixels}");
            } else if (notification is ScrollEndNotification) {
              // 滚动结束
              // print('滚动结束');
            }
          },
          child: RefreshIndicator(
              onRefresh: () async {
                print("推荐ye下拉刷新");
                // dataPage = 1;
                if (recommendModelList.isNotEmpty) {
                  recommendIdList.clear();
                }
                if (liveVideoModel.isNotEmpty) {
                  liveVideoModel.clear();
                }
                loadStatus = LoadingStatus.STATUS_LOADING;
                loadText = "加载中...";
                mergeRequest();
                // List<HomeFeedModel> modelList = await getHotList(size: 20);
                // setState(() {
                //   try {
                //     if (modelList.isNotEmpty) {
                //       for (HomeFeedModel model in modelList) {
                //         recommendIdList.add(model.id);
                //       }
                //       recommendModelList.addAll(modelList);
                //     }
                //   } catch (e) {}
                // });
                // // 更新全局监听
                // context.read<FeedMapNotifier>().updateFeedMap(recommendModelList);
              },
              child: CustomScrollView(
                controller: _controller,
                // BouncingScrollPhysics
                physics:
                    // ClampingScrollPhysics(),
                    // FixedExtentScrollPhysics(),
                    AlwaysScrollableScrollPhysics(),
                // BouncingScrollPhysics(),
                slivers: [
                  // 因为SliverList并不支持设置滑动方向由CustomScrollView统一管理，所有这里使用自定义滚动
                  // CustomScrollView要求内部元素为Sliver组件， SliverToBoxAdapter可包裹普通的组件。
                  // 横向滑动区域
                  SliverToBoxAdapter(
                    child: liveVideoModel.isNotEmpty ? getCourse() : Container(),
                  ),
                  // 垂直列表
                  SliverList(
                    // controller: _controller,
                    delegate: SliverChildBuilderDelegate((content, index) {
                      // 获取动态id
                      int id;
                      // 获取动态id指定model
                      HomeFeedModel model;
                      if (index < recommendModelList.length) {
                        id = recommendIdList[index];
                        model = context.read<FeedMapNotifier>().feedMap[id];
                      }
                      // if (model != null) {
                      if (index == recommendIdList.length) {
                        return LoadingView(
                          loadText: loadText,
                          loadStatus: loadStatus,
                        );
                      } else {
                        return DynamicListLayout(
                            index: index,
                            model: model,
                            // 可选参数 子Item的个数
                            key: GlobalObjectKey("recommend$index"),
                            isShowRecommendUser: false);
                      }
                      // } else {
                      //   // 缺省图
                      //   return Container();
                      // }
                    }, childCount: recommendIdList.length + 1),
                  )
                ],
              )),
        )),
      ],
      // )
    );
  }

  // 课程横向布局
  getCourse() {
    return Container(
      margin: EdgeInsets.only(top: 24, bottom: 18),
      height: 93,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemCount: liveVideoModel.length,
        itemBuilder: (context, index) {
          return Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.only(
                      left: index > 0 ? 24 : 16, right: index == liveVideoModel.length - 1 ? 16 : 0, top: 0, bottom: 8.5),
                  height: 53,
                  width: 53,
                  decoration: BoxDecoration(
                    // color: Colors.redAccent,
                    image:
                        DecorationImage(image: NetworkImage(liveVideoModel[index].coachDto.avatarUri), fit: BoxFit.cover),
                    // image
                    borderRadius: BorderRadius.all(Radius.circular(26.5)),
                  ),
                ),
                Container(
                  width: 53,
                  margin: EdgeInsets.only(
                      left: index > 0 ? 24 : 16, right: index == liveVideoModel.length - 1 ? 16 : 0, top: 0, bottom: 8.5),
                  child: Center(
                    child: Text(
                      liveVideoModel[index].coachDto.nickName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
