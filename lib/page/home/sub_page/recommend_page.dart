import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/data_response_model.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/training/live_video_model.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/data/notifier/token_notifier.dart';
import 'package:mirror/page/home/sub_page/share_page/dynamic_list.dart';
import 'package:mirror/page/profile/profile_detail_page.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/string_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

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

  // 是否存在下一页
  int hasNext;

  // 加载中默认文字
  String loadText = "";
  bool isLogin = true;

  // 加载状态
  LoadingStatus loadStatus = LoadingStatus.STATUS_IDEL;

  // 初始化的第一个item上的间距
  double initHeight = 0.0;

  // 声明定时器
  Timer timer;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // 合并请求
    mergeRequest();
    isLogin = context.read<TokenNotifier>().isLoggedIn;
    _controller.addListener(() {
      if (_controller.position.pixels == _controller.position.maxScrollExtent) {
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
      newRecommendCoach(),
    ]).then((results) {
      if (mounted) {
        if (recommendModelList.isNotEmpty) {
          recommendIdList.clear();
          recommendModelList.clear();
        }
        if (liveVideoModel.isNotEmpty) {
          liveVideoModel.clear();
        }
        setState(() {
          if (results[1] != null) {
            // initHeight += 93;
            liveVideoModel = results[1];
            print("推荐教练书剑返回");
            print(liveVideoModel.toString());
          }
          if (results[0] != null) {
            DataResponseModel dataModel = results[0];
            if (dataModel.list.isNotEmpty) {
              dataModel.list.forEach((v) {
                context.read<ProfilePageNotifier>().profileUiChangeModel.remove(HomeFeedModel.fromJson(v).pushId);
                recommendIdList.add(HomeFeedModel.fromJson(v).id);
                recommendModelList.add(HomeFeedModel.fromJson(v));
              });
            }
            hasNext = dataModel.hasNext;
            if (hasNext == 0) {
              print('================================hashnext');
              loadStatus = LoadingStatus.STATUS_COMPLETED;
              loadText = "";
            }
            recommendModelList = StringUtil.getFeedItemHeight(initHeight, recommendModelList);
          }
        });
        // 更新全局监听
        context.read<FeedMapNotifier>().updateFeedMap(recommendModelList);
      }
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
    DataResponseModel dataModel = DataResponseModel();
    // List<HomeFeedModel> modelList = [];
    if (hasNext != 0) {
      // 请求推荐接口
      dataModel = await getHotList(size: 20);
      if (dataModel == null) {
        loadText = "";
        loadStatus = LoadingStatus.STATUS_COMPLETED;
      }
      hasNext = dataModel.hasNext;
      if (dataModel.list.isNotEmpty) {
        dataModel.list.forEach((v) {
          recommendIdList.add(HomeFeedModel.fromJson(v).id);
          // modelList.add(HomeFeedModel.fromJson(v));
          recommendModelList.add(HomeFeedModel.fromJson(v));
        });
      }
      // if (modelList.isNotEmpty) {
      //   for (HomeFeedModel model in modelList) {
      //     recommendIdList.add(model.id);
      //   }
      //   recommendModelList.addAll(modelList);
      // }
      loadStatus = LoadingStatus.STATUS_IDEL;
      loadText = "加载中...";
    }
    if (hasNext == 0) {
      loadText = "已加载全部动态";
      loadStatus = LoadingStatus.STATUS_COMPLETED;
    }
    if (mounted) {
      setState(() {});
    }
    recommendModelList = StringUtil.getFeedItemHeight(initHeight, recommendModelList);
    // 更新全局监听
    context.read<FeedMapNotifier>().updateFeedMap(recommendModelList);
  }

  @override
  Widget build(BuildContext context) {
    print("推荐页");
    return Consumer<TokenNotifier>(
      builder: (context, notifier, child) {
        if (notifier.isLoggedIn && !isLogin) {
          Future.delayed(Duration.zero, () {
            recommendIdList.clear();
            recommendModelList.clear();
            getRecommendFeed();
          });
          isLogin = notifier.isLoggedIn;
        }
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
                  // 纵向滚动
                  if (metrics.axis == Axis.vertical) {
                    if (timer != null) {
                      timer.cancel();
                    }
                  }
                  // 当前位置
                  // print("当前位置${metrics.pixels}");
                } else if (notification is ScrollEndNotification) {
                  // 纵向滚动
                  if (metrics.axis == Axis.vertical) {
                    timer = Timer(Duration(milliseconds: 3000), () {
                      print("定时3秒到了");
                      for (int i = 0; i < recommendModelList.length; i++) {
                        HomeFeedModel value = recommendModelList[i];
                        // 屏幕可滑动区域
                        double slidingArea = ScreenUtil.instance.height -
                            ScreenUtil.instance.statusBarHeight -
                            ScreenUtil.instance.bottomBarHeight -
                            44 -
                            51;
                        // 屏幕的一半偏移值
                        double screenOffser = metrics.pixels + (slidingArea / 2);
                        if (screenOffser >= value.headOffset && screenOffser < value.bottomOffset) {
                          print("进了");
                          context.read<FeedMapNotifier>().showInputBox(value.id);
                        }
                      }
                    });
                  }
                  // 滚动结束
                  // print('滚动结束');
                }
              },
              child: RefreshIndicator(
                  onRefresh: () async {
                    print("推荐ye下拉刷新");
                    // dataPage = 1;
                    loadStatus = LoadingStatus.STATUS_LOADING;
                    loadText = "加载中...";
                    hasNext = null;
                    mergeRequest();
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
                      recommendIdList.isNotEmpty
                          ? SliverList(
                              // controller: _controller,
                              delegate: SliverChildBuilderDelegate((content, index) {
                                // 获取动态id
                                int id;
                                // 获取动态id指定model
                                HomeFeedModel model;
                                if (index < recommendIdList.length) {
                                  id = recommendIdList[index];
                                  model = context.read<FeedMapNotifier>().feedMap[id];
                                }
                                if (index == recommendIdList.length) {
                                  return LoadingView(
                                    loadText: loadText,
                                    loadStatus: loadStatus,
                                  );
                                } else {
                                  return DynamicListLayout(
                                      index: index,
                                      model: model,
                                      pageName: "recommendPage",
                                      isShowConcern: true,
                                      // 可选参数 子Item的个数
                                      key: GlobalObjectKey("recommend$index"),
                                      isShowRecommendUser: false);
                                }
                              }, childCount: recommendIdList.length + 1),
                            )
                          : SliverToBoxAdapter(
                              child: Container(
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
                                    "这里空空如也，去关注看看吧",
                                    style: TextStyle(fontSize: 14, color: AppColor.textSecondary),
                                  ),
                                ],
                              ),
                            )),
                    ],
                  )),
            )),
          ],
          // )
        );
      },
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
          return GestureDetector(
            onTap: () {
              if (context.read<TokenNotifier>().isLoggedIn) {
                if (liveVideoModel[index].coachDto.isLiving == 0) {
                  AppRouter.navigateToMineDetail(context, liveVideoModel[index].coachDto.uid);
                } else {
                  ToastShow.show(msg: "直播页", context: context, gravity: Toast.CENTER);
                }
              } else {
                AppRouter.navigateToLoginPage(context);
              }
            },
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.only(
                        left: index > 0 ? 24 : 16,
                        right: index == liveVideoModel.length - 1 ? 16 : 0,
                        top: 0,
                        bottom: 8.5),
                    height: 53,
                    width: 53,
                    decoration: BoxDecoration(
                      // color: Colors.redAccent,
                      image: DecorationImage(
                          image: NetworkImage(liveVideoModel[index].coachDto.avatarUri), fit: BoxFit.cover),
                      // image
                      borderRadius: BorderRadius.all(Radius.circular(26.5)),
                    ),
                  ),
                  Container(
                    width: 53,
                    margin: EdgeInsets.only(
                        left: index > 0 ? 24 : 16,
                        right: index == liveVideoModel.length - 1 ? 16 : 0,
                        top: 0,
                        bottom: 8.5),
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
            ),
          );
        },
      ),
    );
  }
}
