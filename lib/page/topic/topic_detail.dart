// import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'dart:async';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';

// hide NestedScrollView, NestedScrollViewState;
import 'package:flutter/material.dart';

// hide NestedScrollView, NestedScrollViewState;
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/api/topic/topic_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/page/profile/profile_detail_page.dart';
import 'package:mirror/page/topic/topic_list.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/string_util.dart';
import 'package:mirror/util/text_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/feed/feed_share_popups.dart';
import 'package:mirror/widget/primary_scrollcontainer.dart';
import 'package:mirror/widget/round_underline_tab_indicator.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class TopicDetail extends StatefulWidget {
  TopicDetail({Key key, this.isTopicList, this.model}) : super(key: key);
  bool isTopicList;
  TopicDtoModel model;

  @override
  TopicDetailState createState() => TopicDetailState();
}

class TopicDetailState extends State<TopicDetail> with SingleTickerProviderStateMixin {
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

  List<GlobalKey> scrollChildKeys;
  GlobalKey<PrimaryScrollContainerState> leftKey = GlobalKey();
  GlobalKey<PrimaryScrollContainerState> rightKey = GlobalKey();
  bool bigOrSmallScroll = false;
  StreamController<TopicUiChangeModel> appBarStreamController = StreamController<TopicUiChangeModel>();
  bool streamCanChange = false;
  TopicUiChangeModel topicUiChangeModel = TopicUiChangeModel();
  RefreshController _newsRefereshController = RefreshController();
  RefreshController _recommendRefereshController = RefreshController();
  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
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
            if (streamCanChange) {
              topicUiChangeModel.canOnclick = true;
              topicUiChangeModel.titleColor = AppColor.black;
              topicUiChangeModel.iconColor = AppColor.black;
              appBarStreamController.sink.add(topicUiChangeModel);
              streamCanChange = false;
            }
          } else if (!streamCanChange) {
            topicUiChangeModel.canOnclick = false;
            topicUiChangeModel.titleColor = AppColor.transparent;
            topicUiChangeModel.iconColor = AppColor.white;
            appBarStreamController.sink.add(topicUiChangeModel);
            streamCanChange = true;
          }
        }

      });
    super.initState();
  }

  // 请求关注话题
  requestFollowTopic() async {
    Map<String, dynamic> map = await followTopic(topicId: widget.model.id);
    if (map["state"] == true) {
      setState(() {
        widget.model.isFollow = 1;
      });
      if (widget.isTopicList) {
        context.read<ProfilePageNotifier>().removeListId(null);
      }
    } else {
      ToastShow.show(msg: "关注失败", context: context);
    }
  }

  // 请求取消关注话题
  requestCancelFollowTopic() async {
    Map<String, dynamic> map = await cancelFollowTopic(topicId: widget.model.id);
    if (map["state"] == true) {
      setState(() {
        widget.model.isFollow = 0;
      });
      if (widget.isTopicList) {
        context.read<ProfilePageNotifier>().removeListId(widget.model.id);
      }
    } else {
      ToastShow.show(msg: "取消关注失败", context: context);
    }
  }

  // 头部高度
  sliverAppBarHeight() {
    // UI图原始高度
    double height = 197.0 - ScreenUtil.instance.statusBarHeight;
    if (widget.model.description != null) {
      //加上文字高度
      height +=
          getTextSize(widget.model.description, AppStyle.textRegular14, 10, ScreenUtil.instance.width - 32).height;
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
        body: widget.model != null
            ? NestedScrollView(
                controller: _scrollController,
                headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                  return <Widget>[
                    StreamBuilder<TopicUiChangeModel>(
                        initialData: topicUiChangeModel,
                        stream: appBarStreamController.stream,
                        builder: (BuildContext stramContext, AsyncSnapshot<TopicUiChangeModel> snapshot) {
                          return SliverAppBar(
                            expandedHeight: sliverAppBarHeight(),
                            pinned: true,
                            title: Text(
                              "${widget.model.name}",
                              style:
                                  TextStyle(fontWeight: FontWeight.w500, fontSize: 18, color: snapshot.data.titleColor),
                            ),
                            leading: IconButton(
                              icon: Icon(
                                Icons.arrow_back_ios,
                                color: snapshot.data.iconColor,
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            actions: <Widget>[
                              snapshot.data.canOnclick
                                  ? Container(
                                      width: 60,
                                      padding: EdgeInsets.only(top: 14, bottom: 14),
                                      child: _followButton(),
                                    )
                                  : Container(),
                              IconButton(
                                icon: Icon(
                                  Icons.wysiwyg,
                                  color: snapshot.data.iconColor,
                                ),
                                onPressed: () {
                                  openShareBottomSheet(context: context, map: widget.model.toJson(), sharedType: 3);
                                },
                              )
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
                                      bottom: widget.model.description != null
                                          ? (getTextSize(widget.model.description, AppStyle.textRegular14, 10,
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
                                                    image: NetworkImage(widget.model.avatarUrl ??
                                                        "https://tva1.sinaimg.cn/large/006y8mN6gy1g7aa03bmfpj3069069mx8.jpg"),
                                                    fit: BoxFit.cover),
                                                color: AppColor.white)),
                                      )),
                                  // 话题内容
                                  Positioned(
                                      bottom: widget.model.description != null
                                          ? (getTextSize(widget.model.description, AppStyle.textRegular14, 10,
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
                                                  "#${widget.model.name}",
                                                  style: AppStyle.textMedium16,
                                                ),
                                                SizedBox(
                                                  height: 3,
                                                ),
                                                Text(
                                                  "${StringUtil.getNumber(widget.model.feedCount)}条动态",
                                                  style: AppStyle.textPrimary3Regular12,
                                                )
                                              ],
                                            ),
                                            // SizedBox(width: 12,),
                                            Spacer(),
                                            _followButton(),
                                            SizedBox(
                                              width: 16,
                                            )
                                          ],
                                        ),
                                      )),
                                  // 话题描述
                                  widget.model.description != null
                                      ? Positioned(
                                          bottom: 0,
                                          child: Container(
                                            width: ScreenUtil.instance.width,
                                            padding: EdgeInsets.only(left: 16, top: 12, right: 16, bottom: 12),
                                            child: Text(
                                              widget.model.description,
                                              style: AppStyle.textRegular14,
                                              maxLines: 10,
                                            ),
                                          ))
                                      : Container(),
                                ],
                              ),
                            ),
                          );
                        }),
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
                      TopicList(
                        topicId: widget.model.id,
                        type: 5,
                      ),
                    ),
                    // 推荐话题
                    // 最新话题
                    PrimaryScrollContainer(
                      scrollChildKeys[1],
                      TopicList(
                        topicId: widget.model.id,
                        type: 4,
                      ),
                    ),
                  ],
                ),
              )
            : Container());
  }

  Widget _followButton() {
    return GestureDetector(
        onTap: () {
          if (widget.model.isFollow == 0) {
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
            child: widget.model.isFollow == 0
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add,
                        size: 16,
                        color: AppColor.black,
                      ),
                      Text("关注", style: AppStyle.textMedium12)
                    ],
                  )
                : Center(
                    child: Text("已关注", style: AppStyle.textMedium12),
                  )));
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

class TopicDetailNotifier extends ChangeNotifier {
  Color titleColor = AppColor.transparent;
  Color iconColor = AppColor.bgWhite;
  bool scrollWatch = false;
  bool canOnclick = false;

  void ChangeColor(bool scrollBig) {
    if (scrollBig) {
      titleColor = AppColor.bgBlack;
      iconColor = AppColor.bgBlack;
      canOnclick = true;
      scrollWatch = true;
    } else {
      titleColor = AppColor.transparent;
      iconColor = AppColor.bgWhite;
      canOnclick = false;
      scrollWatch = false;
    }
    notifyListeners();
  }
}

class TopicUiChangeModel {
  Color titleColor = AppColor.bgBlack;
  Color iconColor = AppColor.bgBlack;
  bool canOnclick = true;
}
