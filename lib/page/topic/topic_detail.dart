// import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';

// hide NestedScrollView, NestedScrollViewState;
import 'package:flutter/material.dart';

// hide NestedScrollView, NestedScrollViewState;
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/api/topic/topic_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/message/chat_type_model.dart';
import 'package:mirror/data/notifier/user_interactive_notifier.dart';
import 'package:mirror/page/media_picker/media_picker_page.dart';
import 'package:mirror/page/profile/profile_detail_page.dart';
import 'package:mirror/page/topic/topic_list.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/colors_util.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/string_util.dart';
import 'package:mirror/util/text_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/feed/feed_share_popups.dart';
import 'package:mirror/widget/feed/release_feed_input_formatter.dart';
import 'package:mirror/widget/icon.dart';
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
  List<String> backgroundImages = [
    "assets/png/pic_topic_banner_element_1.png",
    "assets/png/pic_topic_banner_element_2.png",
    "assets/png/pic_topic_banner_element_3.png",
    "assets/png/pic_topic_banner_element_4.png",
    "assets/png/pic_topic_banner_element_5.png",
    "assets/png/pic_topic_banner_element_6.png"];

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
        // print("足控");
        // print("_scrollController:::::::::${_scrollController.offset}");
        if (_scrollController.hasClients) {
          if (_scrollController.offset >= headSlideHeight - 3) {
            // print("进了");
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
        context.read<UserInteractiveNotifier>().removeListId(null);
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
        context.read<UserInteractiveNotifier>().removeListId(widget.model.id);
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

  // 获取背景颜色
  Color getBackgroundColor() {
    Color color;
    if (widget.model.backgroundColorId != null && Application.topicBackgroundConfig.isNotEmpty) {
      Application.topicBackgroundConfig.forEach((element) {
        if (widget.model.backgroundColorId == element.id) {
          color = ColorsUtil.hexToColor("#${element.backgroundColor}");
          return ;
        }
      });
    } else {
      color = AppColor.bgBlack;
    }
    return color;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          children: [
            widget.model != null
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
                          titleSpacing: 0,
                          title: Text(
                            "#${widget.model.name}",
                            style:
                            TextStyle(fontWeight: FontWeight.w500, fontSize: 18, color: snapshot.data.titleColor),
                          ),
                          leading: CustomAppBarIconButton(
                            svgName: AppIcon.nav_return,
                            iconColor: snapshot.data.iconColor,
                            onTap: () {
                              Navigator.pop(context);
                            },
                          ),
                          actions: <Widget>[
                            snapshot.data.canOnclick
                                ? Container(
                              width: 60,
                              padding: EdgeInsets.only(top: 14, bottom: 14),
                              margin: EdgeInsets.only(right: 8),
                              child: _followButton(),
                            )
                                : Container(),
                            CustomAppBarIconButton(
                              svgName: AppIcon.nav_share,
                              iconColor: snapshot.data.iconColor,
                              onTap: () {
                                openShareBottomSheet(
                                    context: context,
                                    map: widget.model.toJson(),
                                    sharedType: 3,
                                    chatTypeModel: ChatTypeModel.NULL_COMMENT);
                              },
                            ),
                            SizedBox(
                              width: 8,
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
                                    color: getBackgroundColor(),
                                    child: Image.asset(backgroundImages[widget.model.patternId],fit: BoxFit.cover,),
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
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(
                                        // 圆角
                                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                          color: AppColor.white),
                                      child: Container(
                                          decoration: BoxDecoration(
                                            // 圆角
                                              borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                                              // image: DecorationImage(
                                              //     image: NetworkImage(widget.model.avatarUrl + "?imageslim"  ??
                                              //         "https://tva1.sinaimg.cn/large/006y8mN6gy1g7aa03bmfpj3069069mx8.jpg"+"?imageslim" ),
                                              //     fit: BoxFit.cover),
                                              color: AppColor.white),
                                          clipBehavior: Clip.antiAlias,
                                          child: CachedNetworkImage(
                                            // 调整磁盘缓存中图像大小
                                            maxHeightDiskCache: 150,
                                            maxWidthDiskCache: 150,
                                            imageUrl: widget.model.avatarUrl != null ? FileUtil.getSmallImage(
                                                widget.model.avatarUrl) : "",
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                Container(
                                                  color: AppColor.bgWhite,
                                                ),
                                            errorWidget: (context, url, e) {
                                              return Container(
                                                color: AppColor.bgWhite,
                                              );
                                            },
                                          )
                                      ),
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
                                      margin: const EdgeInsets.only(left: 96),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: ScreenUtil.instance.width * (168 / ScreenUtil.instance.width),
                                                child: Text(
                                                  "#${widget.model.name}",
                                                  style: AppStyle.textMedium16,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 3,
                                              ),
                                              Text(
                                                "${StringUtil.getNumber(widget.model.feedCount)}条动态",
                                                style: AppStyle.textPrimary3Regular12,
                                              )
                                            ],
                                          ),
                                          // SizedBox(width: 12,),
                                          const Spacer(),
                                          _followButton(),
                                          const SizedBox(
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
                                      padding: const EdgeInsets.only(left: 16, top: 12, right: 16, bottom: 12),
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
                        labelStyle: const TextStyle(fontSize: 16),
                        unselectedLabelColor: AppColor.textHint,
                        indicator: const RoundUnderlineTabIndicator(
                          borderSide: BorderSide(
                            width: 2,
                            color: AppColor.bgBlack,
                          ),
                          insets: EdgeInsets.only(bottom: 0),
                          wantWidth: 20,
                        ),
                        tabs: <Widget>[
                          const Tab(text: '推荐'),
                          const Tab(text: '最新'),
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
                : Container(),
            Positioned(
              bottom: ScreenUtil.instance.bottomBarHeight + 28,
              left: (ScreenUtil.instance.width - 127) / 2,
              right: (ScreenUtil.instance.width - 127) / 2,
              child: _gotoRelease(),
            )
          ],
        ));
  }

  Widget _gotoRelease() {
    return InkWell(
      onTap: () {
        Application.topicMap[widget.model.id] = widget.model;
        AppRouter.navigateToMediaPickerPage(
            context,
            9,
            typeImageAndVideo,
            true,
            startPageGallery,
            false, (result) {},
            publishMode: 1,
            topicId: widget.model.id);
      },
      child: Container(
        width: 127,
        height: 43,
        decoration: const BoxDecoration(
          color: AppColor.bgBlack,
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
        padding: const EdgeInsets.only(left: 12, right: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 27,
              width: 27,
              decoration: const BoxDecoration(
                color: AppColor.white,
                borderRadius: BorderRadius.all(Radius.circular(24)),
              ),
              child: Center(
                child: Icon(
                  Icons.camera_alt,
                  color: AppColor.black,
                ),
              ),
            ),
            const Spacer(),
            const Text(
              "立即参与",
              style: AppStyle.whiteRegular16,
            )
          ],
        ),
      ),
    );
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
                borderRadius: const BorderRadius.all(Radius.circular(15)),
                border: Border.all(width: 1, color: AppColor.bgBlack)),
            child: widget.model.isFollow == 0
                ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.add,
                  size: 16,
                  color: AppColor.black,
                ),
                const Text("关注", style: AppStyle.textMedium12)
              ],
            )
                : Center(
              child: const Text("已关注", style: AppStyle.textMedium12),
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

class TopicUiChangeModel {
  Color titleColor = AppColor.transparent;
  Color iconColor = AppColor.white;
  bool canOnclick = false;
}
