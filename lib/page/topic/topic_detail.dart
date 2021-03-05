// import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/cupertino.dart';

// hide NestedScrollView, NestedScrollViewState;
import 'package:flutter/material.dart';

// hide NestedScrollView, NestedScrollViewState;
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/api/topic/topic_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/data_response_model.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/data/model/profile/topic_list_model.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/page/profile/profile_detail_page.dart';
import 'package:mirror/page/topic/topic_newest.dart';
import 'package:mirror/page/topic/topic_recommend.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/string_util.dart';
import 'package:mirror/util/text_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/primary_scrollcontainer.dart';
import 'package:mirror/widget/round_underline_tab_indicator.dart';
import 'package:provider/provider.dart';

class TopicDetail extends StatefulWidget {
  TopicDetail({Key key, this.topicId,this.isTopicList}) : super(key: key);
  int topicId;
  bool isTopicList;
  @override
  TopicDetailState createState() => TopicDetailState();
}

class TopicDetailState extends State<TopicDetail> with SingleTickerProviderStateMixin {
  TopicDtoModel model;

  // taBar和TabBarView必要的
  TabController _tabController;

  //   主控制器
  ScrollController _scrollController = new ScrollController();

  // 透明度
  int _titleAlpha = 0; //范围 0-255
  // 文字颜色
  Color titleColor = AppColor.transparent;

  // 图标颜色
  Color iconColor = AppColor.bgWhite;

  // 头部滑动距离
  double headSlideHeight;

  // 推荐加载中默认文字
  String recommendLoadText = "";

  // 推荐加载状态
  LoadingStatus recommendLoadStatus = LoadingStatus.STATUS_IDEL;

  // 推荐数据是否存在下一页
  int recommendHasNext;

  // 推荐话题ListModel
  List<HomeFeedModel> recommendTopicList = [];

  // 最新加载中默认文字
  String newestLoadText = "";

  // 最新加载状态
  LoadingStatus newestLoadStatus = LoadingStatus.STATUS_IDEL;

  // 最新数据是否存在下一页
  int newestHasNext;

  // 最新话题ListModel
  List<HomeFeedModel> newestTopicList = [];

  // 最新话题动态请求下一页
  int newestLastTime;

  // GlobalKey<NestedScrollViewState> _key = GlobalKey<NestedScrollViewState>();

  List<GlobalKey> scrollChildKeys;
  GlobalKey<PrimaryScrollContainerState> leftKey = GlobalKey();
  GlobalKey<PrimaryScrollContainerState> rightKey = GlobalKey();
  bool bigOrSmallScroll = false;
  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    requestTopicDetail();
    requestRecommendTopic();
    requestNewestTopic();

    scrollChildKeys = [leftKey, rightKey];
    _tabController.addListener(() {
      for (int i = 0; i < scrollChildKeys.length; i++) {
        GlobalKey<PrimaryScrollContainerState> key = scrollChildKeys[i];
        if (key.currentState != null) {
          key.currentState.onPageChange(_tabController.index == i); //控制是否当前显示
        }
      }
    });
    _scrollController
      ..addListener(() {
        print("足控");
        print("_scrollController:::::::::${_scrollController.offset}");
        if (_scrollController.hasClients) {
            if (_scrollController.offset >= headSlideHeight - 3) {
              print("进了");
              if(!context.read<TopicDetailNotifier>().scrollWatch){
                context.read<TopicDetailNotifier>().ChangeColor(true);
              }
            } else if(context.read<TopicDetailNotifier>().scrollWatch){
              context.read<TopicDetailNotifier>().ChangeColor(false);
            }
        }
        if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
          if (_tabController.index == 0) {
            requestRecommendTopic();
          } else if (_tabController.index == 1) {
            requestNewestTopic();
          }
          print("lalalalalalalalalalalalal");
        }
      });
    super.initState();
  }

  // 请求动态详情接口
  requestTopicDetail() async {
    model = await getTopicInfo(topicId: widget.topicId);
    if (mounted) {
      setState(() {});
    }
  }

  // 请求推荐话题动态接口
  requestRecommendTopic() async {
    if (recommendHasNext != 0) {
      if (recommendLoadStatus == LoadingStatus.STATUS_IDEL) {
        // 先设置状态，防止下拉就直接加载
        setState(() {
          recommendLoadStatus = LoadingStatus.STATUS_LOADING;
        });
      }
      DataResponseModel model = await getPullList(type: 5, size: 20, targetId: widget.topicId);
      recommendHasNext = model.hasNext;
      if (model.list.isNotEmpty) {
        model.list.forEach((v) {
          recommendTopicList.add(HomeFeedModel.fromJson(v));
        });
        recommendLoadStatus = LoadingStatus.STATUS_IDEL;
        recommendLoadText = "加载中...";
      }
      context.read<FeedMapNotifier>().updateFeedMap(recommendTopicList);
    }
    if (recommendHasNext == 0) {
      // 加载完毕
      recommendLoadText = "已加载全部话题动态";
      recommendLoadStatus = LoadingStatus.STATUS_COMPLETED;
    }
    if (mounted) {
      setState(() {});
    }
  }

  // 请求最新话题动态
  requestNewestTopic() async {
    if (newestHasNext != 0) {
      if (newestLoadStatus == LoadingStatus.STATUS_IDEL) {
        // 先设置状态，防止下拉就直接加载
        setState(() {
          newestLoadStatus = LoadingStatus.STATUS_LOADING;
        });
      }
      DataResponseModel model =
          await getPullList(type: 4, size: 20, targetId: widget.topicId, lastTime: newestLastTime);
      newestLastTime = model.lastTime;
      newestHasNext = model.hasNext;
      if (model.list.isNotEmpty) {
        model.list.forEach((v) {
          newestTopicList.add(HomeFeedModel.fromJson(v));
        });
        newestLoadStatus = LoadingStatus.STATUS_IDEL;
        newestLoadText = "加载中...";
      }
      context.read<FeedMapNotifier>().updateFeedMap(newestTopicList);
    }
    if (newestHasNext == 0) {
      // 加载完毕
      newestLoadText = "已加载全部话题动态";
      newestLoadStatus = LoadingStatus.STATUS_COMPLETED;
    }
    if (mounted) {
      setState(() {});
    }
  }

  // 请求关注话题
  requestFollowTopic() async {
    Map<String, dynamic> map = await followTopic(topicId: widget.topicId);
    if (map["state"] == true) {
      setState(() {
        model.isFollow = 1;
      });
      if(widget.isTopicList){
        context.read<ProfilePageNotifier>().removeListId(null);
      }
    } else {
      ToastShow.show(msg: "关注失败", context: context);
    }
  }

  // 请求取消关注话题
  requestCancelFollowTopic() async {
    Map<String, dynamic> map = await cancelFollowTopic(topicId: widget.topicId);
    if (map["state"] == true) {
      setState(() {
        model.isFollow = 0;
      });
      if(widget.isTopicList){
        context.read<ProfilePageNotifier>().removeListId(widget.topicId);
      }
    } else {
      ToastShow.show(msg: "取消关注失败", context: context);
    }
  }

  // 头部高度
  sliverAppBarHeight() {
    // UI图原始高度
    double height = 197.0 - ScreenUtil.instance.statusBarHeight;
    if (model.description != null) {
      //加上文字高度
      height += getTextSize(model.description, AppStyle.textRegular14, 10, ScreenUtil.instance.width - 32).height;
      // 文字上下方间距
      height += 25;
    }
    headSlideHeight = height - kToolbarHeight;
    print("headSlideHeight$headSlideHeight");
    return height;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: model != null
            ? NestedScrollView(
                controller: _scrollController,
                headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                  return <Widget>[
                    SliverAppBar(
                      expandedHeight: sliverAppBarHeight(),
                      pinned: true,
                      title: Text(model.name, style: TextStyle(color: context.watch<TopicDetailNotifier>().titleColor)),
                      leading: new IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color: context.watch<TopicDetailNotifier>().iconColor,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      actions: <Widget>[
                        new IconButton(
                          icon: Icon(
                            Icons.wysiwyg,
                            color: context.watch<TopicDetailNotifier>().iconColor,
                          ),
                          onPressed: () {
                            print("更多");
                          },
                        ),
                      ],
                      backgroundColor: AppColor.white,
                      flexibleSpace: FlexibleSpaceBar(
                        background: Stack(
                          children: [
                            // 背景颜色
                            Container(
                              height: 128,
                              width: ScreenUtil.instance.width,
                              color: AppColor.bgBlack,
                            ),
                            // 头像
                            Positioned(
                                left: 14,
                                bottom: model.description != null
                                    ? (getTextSize(model.description, AppStyle.textRegular14, 10,
                                                ScreenUtil.instance.width - 32)
                                            .height +
                                        25 +
                                        13)
                                    : 13,
                                child: Container(
                                  width: 71,
                                  height: 71,
                                  padding: EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                      // 圆角
                                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                      color: AppColor.white),
                                  child: Container(
                                      decoration: BoxDecoration(
                                          // 圆角
                                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                          image: DecorationImage(
                                              image: NetworkImage(model.avatarUrl ??
                                                  "https://tva1.sinaimg.cn/large/006y8mN6gy1g7aa03bmfpj3069069mx8.jpg"),
                                              fit: BoxFit.cover),
                                          color: AppColor.white)),
                                )),
                            // 话题内容
                            Positioned(
                                bottom: model.description != null
                                    ? (getTextSize(model.description, AppStyle.textRegular14, 10,
                                                ScreenUtil.instance.width - 32)
                                            .height +
                                        25)
                                    : 0,
                                child: Container(
                                  height: 69,
                                  width: ScreenUtil.instance.width - 96,
                                  margin: EdgeInsets.only(left: 96),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "#${model.name}",
                                            style: AppStyle.textMedium16,
                                          ),
                                          SizedBox(
                                            height: 3,
                                          ),
                                          Text(
                                            "${StringUtil.getNumber(model.feedCount)}条动态",
                                            style: AppStyle.textPrimary3Regular12,
                                          )
                                        ],
                                      ),
                                      // SizedBox(width: 12,),
                                      Spacer(),
                                      GestureDetector(
                                          onTap: () {
                                            if (model.isFollow == 0) {
                                              requestFollowTopic();
                                            } else {
                                              requestCancelFollowTopic();
                                            }
                                          },
                                          child: Container(
                                              height: 28,
                                              width: 72,
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.all(Radius.circular(15)),
                                                  border: Border.all(width: 1, color: AppColor.black)),
                                              child: model.isFollow == 0
                                                  ? Row(
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Icon(
                                                          Icons.add,
                                                          size: 16,
                                                        ),
                                                        Text("关注", style: AppStyle.textMedium12)
                                                      ],
                                                    )
                                                  : Center(
                                                      child: Text("已关注", style: AppStyle.textMedium12),
                                                    ))),
                                      SizedBox(
                                        width: 16,
                                      )
                                    ],
                                  ),
                                )),
                            // 话题描述
                            model.description != null
                                ? Positioned(
                                    bottom: 0,
                                    child: Container(
                                      width: ScreenUtil.instance.width,
                                      padding: EdgeInsets.only(left: 16, top: 12, right: 16, bottom: 12),
                                      child: Text(
                                        model.description,
                                        style: AppStyle.textRegular14,
                                        maxLines: 10,
                                      ),
                                    ))
                                : Container(),
                          ],
                        ),
                      ),
                    ),
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: TopicDetailTabBarDelegate(
                        child: TabBar(
                          labelColor: Colors.black,
                          controller: _tabController,
                          labelStyle: TextStyle(fontSize: 16),
                          unselectedLabelColor: AppColor.textHint,
                          indicator: RoundUnderlineTabIndicator(
                            borderSide: BorderSide(
                              width: 2,
                              color: AppColor.bgBlack,
                            ),
                            insets: EdgeInsets.only(bottom: 0),
                            wantWidth: 20,
                          ),
                          tabs: <Widget>[
                            Tab(text: '推荐'),
                            Tab(text: '最新'),
                          ],
                        ),
                      ),
                    ),
                  ];
                },
                body: TabBarView(
                  controller: _tabController,
                  children: <Widget>[
                    PrimaryScrollContainer(
                      scrollChildKeys[0],
                      TopicRecommend(
                        topicList: recommendTopicList,
                        topicId: widget.topicId,
                        loadStatus: recommendLoadStatus,
                        loadText: recommendLoadText,
                        refreshCallBack: (bool) {
                          print("回调");
                          setState(() {
                            recommendLoadText = "";
                            recommendTopicList.clear();
                            recommendHasNext = null;
                            recommendLoadStatus = LoadingStatus.STATUS_IDEL;
                            requestRecommendTopic();
                          });
                        },
                      ),
                    ),
                    // 推荐话题

                    // 最新话题
                    PrimaryScrollContainer(
                        scrollChildKeys[1],
                        TopicNewest(
                          topicList: newestTopicList,
                          loadStatus: newestLoadStatus,
                          topicId: widget.topicId,
                          loadText: newestLoadText,
                          refreshCallBack: (bool) {
                            setState(() {
                              newestLoadText = "";
                              newestTopicList.clear();
                              newestHasNext = null;
                              newestLastTime = null;
                              newestLoadStatus = LoadingStatus.STATUS_IDEL;
                              requestNewestTopic();
                            });
                          },
                        )),
                  ],
                ),
              )
            : Container());
  }
}

class TopicDetailTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar child;

  TopicDetailTabBarDelegate({@required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      padding: EdgeInsets.only(left: ScreenUtil.instance.width * 0.32, right: ScreenUtil.instance.width * 0.32),
      color: AppColor.white,
      child: this.child,
    );
  }

  @override
  double get maxExtent => this.child.preferredSize.height;

  @override
  double get minExtent => this.child.preferredSize.height;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}


class TopicDetailNotifier extends ChangeNotifier{
  Color titleColor=AppColor.transparent;
  Color iconColor = AppColor.bgWhite;
  bool scrollWatch = false;


  void ChangeColor(bool scrollBig){
    if(scrollBig){
      titleColor = AppColor.bgBlack;
      iconColor = AppColor.bgBlack;
      scrollWatch = true;
    }else{
      titleColor=AppColor.transparent;
      iconColor = AppColor.bgWhite;
      scrollWatch = false;
    }
    notifyListeners();
  }
}