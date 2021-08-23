// import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/cupertino.dart' hide NestedScrollView, NestedScrollViewState;

// hide NestedScrollView, NestedScrollViewState;
import 'package:flutter/material.dart' hide TabBar, TabBarView, NestedScrollView, NestedScrollViewState;
import 'package:interactiveviewer_gallery/hero_dialog_route.dart';

// hide NestedScrollView, NestedScrollViewState;
import 'package:mirror/api/topic/topic_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/config/runtime_properties.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/message/chat_type_model.dart';
import 'package:mirror/data/notifier/token_notifier.dart';
import 'package:mirror/data/notifier/user_interactive_notifier.dart';
import 'package:mirror/page/media_picker/media_picker_page.dart';
import 'package:mirror/page/profile/profile_page.dart';
import 'package:mirror/page/topic/topic_list.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/colors_util.dart';
import 'package:mirror/util/event_bus.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/string_util.dart';
import 'package:mirror/util/text_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/customize_tab_bar/customiize_tab_bar_view.dart';
import 'package:mirror/widget/customize_tab_bar/customize_tab_bar.dart' as Custom;
import 'package:mirror/widget/feed/feed_share_popups.dart';
import 'package:mirror/widget/icon.dart';
import 'package:mirror/widget/interactiveviewer/interactiveview_video_or_image_demo.dart';
import 'package:mirror/widget/interactiveviewer/interactiveviewer_gallery.dart';
import 'package:mirror/widget/round_underline_tab_indicator.dart';
import 'package:provider/provider.dart';

class TopicDetail extends StatefulWidget {
  TopicDetail({Key key, this.isTopicList, this.topicId}) : super(key: key);
  bool isTopicList;
  int topicId;

  @override
  TopicDetailState createState() => TopicDetailState();
}

class TopicDetailState extends State<TopicDetail> with SingleTickerProviderStateMixin {
  // taBar和TabBarView必要的
  TabController _tabController;

  //   主控制器
  // ScrollController _scrollController = new ScrollController();

  // 图标颜色
  Color iconColor = AppColor.bgWhite;

  // 头部滑动距离
  double headSlideHeight;

  TopicDtoModel model;

  // tabBar渐隐渐显控制器
  StreamController<TopicUiChangeModel> appBarStreamController = StreamController<TopicUiChangeModel>();

  // 遮挡层显示控制器
  StreamController<bool> occlusionLayerStreamController = StreamController<bool>();
  bool streamCanChange = false;
  TopicUiChangeModel topicUiChangeModel = TopicUiChangeModel();
  List<String> backgroundImages = [
    "assets/png/pic_topic_banner_element_1.png",
    "assets/png/pic_topic_banner_element_2.png",
    "assets/png/pic_topic_banner_element_3.png",
    "assets/png/pic_topic_banner_element_4.png",
    "assets/png/pic_topic_banner_element_5.png",
    "assets/png/pic_topic_banner_element_6.png"
  ];
  List<TopicDtoModel> topicDtoModelList = [];
  bool isScrollCanChange = true;
  final GlobalKey<NestedScrollViewState> _key = GlobalKey<NestedScrollViewState>();
  StreamController<double> followStreamController;
  StreamController<double> notFollowStreamController;
  bool followOrNot = false;
  bool beforOnClickOver = true;

  @override
  void dispose() {
    _tabController.dispose();
    // _scrollController.dispose();

    super.dispose();
  }

  @override
  void initState() {
    followStreamController = StreamController.broadcast();
    notFollowStreamController = StreamController.broadcast();

    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // 请求话题详情页数据
      requestTopicInfo();
      PrimaryScrollController.of(context).addListener(() {
        print("点击状态栏还会有回调吗？");
        if (PrimaryScrollController.of(context).hasClients) {
          if (PrimaryScrollController.of(context).offset >= headSlideHeight) {
            topicUiChangeModel.opacity = 1;
            topicUiChangeModel.canOnclick = true;
            appBarStreamController.sink.add(topicUiChangeModel);
          } else if (headSlideHeight - PrimaryScrollController.of(context).offset > 1) {
            if (PrimaryScrollController.of(context).offset < headSlideHeight) {
              double offset = PrimaryScrollController.of(context).offset / headSlideHeight;
              topicUiChangeModel.opacity = offset;
            } else {
              topicUiChangeModel.opacity = 0.0;
            }
            topicUiChangeModel.canOnclick = false;
            appBarStreamController.sink.add(topicUiChangeModel);
          }
          // print("_key.currentState.currentInnerPosition.viewportDimension:::${_key.currentState.currentInnerPosition.viewportDimension}");
          // print("_key.currentState.currentInnerPosition.pixels:::${_key.currentState.currentInnerPosition.pixels}");
          // print("_key.currentState.currentInnerPosition.extentBefore:::${_key.currentState.currentInnerPosition.extentBefore}");
          // print("_key.currentState.currentInnerPosition.extentAfter:::${_key.currentState.currentInnerPosition.extentAfter}");
          // print("_key.currentState.currentInnerPosition.extentInside:::${_key.currentState.currentInnerPosition.extentInside}");
          print("PrimaryScrollController.of(context).offset :::${PrimaryScrollController.of(context).offset}");
          // if(PrimaryScrollController.of(context).offset == 0.0) {
          //   // _key.currentState.currentInnerPosition.animateTo(0.0, duration: Duration(milliseconds: 250), curve: Curves.linear);
          //   // _key.currentState.innerController.animateTo(0.0, duration: Duration(milliseconds: 250), curve: Curves.linear);
          //   TopicDoubleTapTabbar topicDoubleTapTabbar = TopicDoubleTapTabbar();
          //   topicDoubleTapTabbar.topicId = model.id;
          //   topicDoubleTapTabbar.tabControllerIndex = _tabController.index;
          //   topicDoubleTapTabbar.innerController = _key.currentState.innerController;
          //   topicDoubleTapTabbar.outerController = _key.currentState.outerController;
          //   // _key.currentState.widget.physics = NeverScrollableScrollPhysics();
          //   // EventBus.getDefault()
          //   //     .post(msg: topicDoubleTapTabbar, registerName: EVENTBUS_TOPICDETAIL_DOUBLE_TAP_TABBAR + "${model.id}");
          // }
        }
      });
    });
    // _scrollController
    //   ..addListener(() {
    //     // print('--------$headSlideHeight-------------${_scrollController.offset}');
    //     if (_scrollController.hasClients) {
    //       if (_scrollController.offset >= headSlideHeight) {
    //         topicUiChangeModel.opacity = 1;
    //         topicUiChangeModel.canOnclick = true;
    //         appBarStreamController.sink.add(topicUiChangeModel);
    //       } else if (headSlideHeight - _scrollController.offset > 1) {
    //         if (_scrollController.offset < headSlideHeight) {
    //           double offset = _scrollController.offset / headSlideHeight;
    //           topicUiChangeModel.opacity = offset;
    //         } else {
    //           topicUiChangeModel.opacity = 0.0;
    //         }
    //         topicUiChangeModel.canOnclick = false;
    //         appBarStreamController.sink.add(topicUiChangeModel);
    //       }
    //     }
    //   });
    super.initState();
  }

  // 请求话题详情页信息
  requestTopicInfo() async {
    model = await getTopicInfo(topicId: widget.topicId);
    if (model != null) {
      if (model.isFollow == 1) followOrNot = true;
    }
    print('------requestTopicInfo-------requestTopicInfo------------${model.toString()}');
    topicDtoModelList.add(model);
    setState(() {});
  }

  // 请求关注话题
  requestFollowTopic() async {
    Map<String, dynamic> map = await followTopic(topicId: model.id);
    if (map != null && map["state"] == true && mounted) {
      setState(() {
        model.isFollow = 1;
      });
      notFollowStreamController.sink.add(0);
      followOrNot = true;
      if (widget.isTopicList) {
        context.read<UserInteractiveNotifier>().removeListId(model.id, isAdd: false);
      }
    } else {
      ToastShow.show(msg: "关注失败", context: context);
    }
  }

  // 请求取消关注话题
  requestCancelFollowTopic() async {
    Map<String, dynamic> map = await cancelFollowTopic(topicId: model.id);
    if (map != null && map["state"] == true && mounted) {
      setState(() {
        model.isFollow = 0;
      });
      followStreamController.sink.add(0);
      followOrNot = false;
      if (widget.isTopicList) {
        context.read<UserInteractiveNotifier>().removeListId(model.id);
      }
    } else {
      ToastShow.show(msg: "取消关注失败", context: context);
    }
  }

  // 头部高度
  sliverAppBarHeight() {
    double height = 109.0 + ScreenUtil.instance.statusBarHeight + CustomAppBar.appBarHeight;
    if (model.description != null) {
      //加上文字高度
      height += getTextSize(model.description, AppStyle.textRegular14, 10, ScreenUtil.instance.width - 32).height;
      // 文字上下方间距
      height += 25;
    }
    headSlideHeight = height - ScreenUtil.instance.statusBarHeight - CustomAppBar.appBarHeight;
    return height;
  }

  // 获取背景颜色
  Color getBackgroundColor() {
    Color color;
    // if (model.backgroundColorId != null && Application.topicBackgroundConfig.isNotEmpty) {
    //   Application.topicBackgroundConfig.forEach((element) {
    //     if (model.backgroundColorId == element.id) {
    //       color = ColorsUtil.hexToColor("#${element.backgroundColor}");
    //       return;
    //     }
    //   });
    // } else {
      color = AppColor.mainBlack;
    // }
    return color;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColor.mainBlack,
        resizeToAvoidBottomInset: false,
        body: model != null
            ? Stack(
                children: [
                  NestedScrollView(
                      key: _key,
                      controller: PrimaryScrollController.of(context),
                      headerSliverBuilder: (BuildContext c, bool f) {
                        return <Widget>[
                          SliverToBoxAdapter(
                              child: Container(
                            height: sliverAppBarHeight(),
                            width: ScreenUtil.instance.width,
                            child: Stack(
                              children: [
                                // 背景颜色
                                Application.slideTopicBezierCurve
                                    ? ClipPath(
                                        //路径裁切组件
                                        clipper: BottomClipper(), //路径
                                        child: Container(
                                          height: 114 + ScreenUtil.instance.statusBarHeight,
                                          width: ScreenUtil.instance.width,
                                          color: getBackgroundColor(),
                                          child: Image.asset(
                                            backgroundImages[model.patternId],
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      )
                                    : Container(
                                        height: 84 + ScreenUtil.instance.statusBarHeight,
                                        width: ScreenUtil.instance.width,
                                        color: getBackgroundColor(),
                                        child: Image.asset(
                                          backgroundImages[model.patternId],
                                          fit: BoxFit.cover,
                                        ),
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
                                    child: Hero(
                                        tag: model.id.toString(),
                                        child: GestureDetector(
                                            onTap: () {
                                              Navigator.of(context).push(
                                                HeroDialogRoute<void>(builder: (BuildContext context) {
                                                  return InteractiveviewerGallery(
                                                      sources: topicDtoModelList,
                                                      initIndex: 0,
                                                      itemBuilder: itemBuilder);
                                                }),
                                              );
                                            },
                                            child: Container(
                                              width: 69,
                                              height: 69,
                                              padding: const EdgeInsets.all(2),
                                              decoration: const BoxDecoration(
                                                  // 圆角
                                                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                                  color: AppColor.white
                                              ),
                                              child: Container(
                                                  decoration: BoxDecoration(
                                                      // 圆角
                                                      borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                                                      color: AppColor.white
                                                  ),
                                                  clipBehavior: Clip.antiAlias,
                                                  child: model.avatarUrl != null ?
                                                  CachedNetworkImage(
                                                    // 指定缓存宽高
                                                    memCacheWidth: 150,
                                                    memCacheHeight: 150,
                                                    imageUrl:
                                                        model.avatarUrl != null && model.avatarUrl.coverUrl != null
                                                            ? FileUtil.getSmallImage(model.avatarUrl.coverUrl)
                                                            : "",
                                                    fit: BoxFit.cover,
                                                    placeholder: (context, url) => Container(
                                                      color: AppColor.bgWhite,
                                                    ),
                                                    errorWidget: (context, url, e) {
                                                      return Container(
                                                        color: AppColor.bgWhite,
                                                      );
                                                    },
                                                  ) : Image.asset(
                                                    "assets/png/topic_cover.png",
                                                  ),),
                                            )))),
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
                                                  "#${model.name}",
                                                  style: AppStyle.whiteMedium16,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 3,
                                              ),
                                              Text(
                                                "${StringUtil.getNumber(model.feedCount)}条动态",
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
                                model.description != null
                                    ? Positioned(
                                        bottom: 0,
                                        child: Container(
                                          width: ScreenUtil.instance.width,
                                          padding: const EdgeInsets.only(left: 16, top: 12, right: 16, bottom: 12),
                                          child: Application.slideAnimatedTextTypewriter
                                              ? DefaultTextStyle(
                                                  textAlign: TextAlign.start,
                                                  maxLines: 10,
                                                  style: AppStyle.textRegular14,
                                                  child: AnimatedTextKit(
                                                    animatedTexts: [
                                                      TyperAnimatedText(
                                                        model.description,
                                                        speed: Duration(milliseconds: 20),
                                                      ),
                                                    ],
                                                    totalRepeatCount: 1,
                                                  ),
                                                )
                                              : Text(
                                                  model.description,
                                                  style: AppStyle.textRegular14,
                                                  maxLines: 10,
                                                ),
                                        ))
                                    : Container(),
                              ],
                            ),
                          )),
                        ];
                      },
                      // tabBar 悬停位置
                      pinnedHeaderSliverHeightBuilder: () {
                        return ScreenUtil.instance.statusBarHeight + CustomAppBar.appBarHeight;
                      },
                      innerScrollPositionKeyBuilder: () {
                        String index = 'Tab${model.id}';

                        index += _tabController.index.toString();

                        return Key(index);
                      },
                      body: model.dataState==2?Column(children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(
                              left: ScreenUtil.instance.width * 0.32, right: ScreenUtil.instance.width * 0.32),
                          // color: AppColor.white,
                          child: Custom.TabBar(
                            //
                            // labelColor: Colors.black,
                            controller: _tabController,
                            // labelStyle: const TextStyle(fontSize: 16),
                            // unselectedLabelColor: AppColor.textHint,

                            indicatorSize: Custom.TabBarIndicatorSize.label,
                            labelStyle: const TextStyle(
                              fontSize: 16,
                            ),
                            labelColor: AppColor.bgWhite,
                            unselectedLabelColor: AppColor.textHint,
                            unselectedLabelStyle: const TextStyle(fontSize: 16),
                            onDoubleTap: (index) {
                              if (_tabController.index == index) {
                                // print(_key.currentState.innerController);
                                if (PrimaryScrollController.of(context).offset != 0 &&
                                    PrimaryScrollController.of(context).offset > (headSlideHeight - 0.5)) {
                                  occlusionLayerStreamController.sink.add(true);
                                  // 回到顶部
                                  subpageRefresh();
                                };
                              } else {
                                _tabController.animateTo(index);
                              }
                            },
                            indicator: const RoundUnderlineTabIndicator(
                              borderSide: BorderSide(
                                width: 2,
                                color: AppColor.bgWhite,
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
                        Expanded(
                            child: TabBarView(
                          controller: _tabController,
                          physics: ClampingScrollPhysics(),
                          children: <Widget>[
                            // 推荐话题
                            TopicList(
                              topicId: model.id,
                              type: 5,
                              tabKey: Key('Tab${model.id}0'),
                            ),
                            // 最新话题
                            TopicList(
                              topicId: model.id,
                              type: 4,
                              tabKey: Key('Tab${model.id}1'),
                            ),
                          ],
                        ))
                      ]):Container(
                          padding: EdgeInsets.only(top: 12),
                          color: AppColor.mainBlack,
                          child: Column(
                            children: [
                              Center(
                                child: Container(
                                  width: 224,
                                  height: 224,
                                  child: Image.asset(DefaultImage.error),
                                ),
                              ),
                              SizedBox(
                                height: 16,
                              ),
                              Center(
                                child: Text(
                                  "该账号封禁中·",
                                  style: AppStyle.whiteRegular14,
                                ),
                              )
                            ],
                          ))),
                  Positioned(top: 0, child: appBar()),
                  model.dataState==2
                      ?Positioned(
                    bottom: ScreenUtil.instance.bottomBarHeight + 28,
                    left: (ScreenUtil.instance.width - 127) / 2,
                    right: (ScreenUtil.instance.width - 127) / 2,
                    child: _gotoRelease(),
                  ):Container(),
                  Positioned(
                      top: 0,
                      child: StreamBuilder<bool>(
                          initialData: false,
                          stream: occlusionLayerStreamController.stream,
                          builder: (BuildContext stramContext, AsyncSnapshot<bool> snapshot) {
                            return snapshot.data
                                ? Container(
                                    color: AppColor.transparent,
                                    width: ScreenUtil.instance.width,
                                    height: ScreenUtil.instance.height,
                                  )
                                : Container();
                          }))
                ],
              )
            : Container(
                width: ScreenUtil.instance.width,
                height: ScreenUtil.instance.height,
                child: Column(
                  children: [
                    Container(
                      width: ScreenUtil.instance.width,
                      height: ScreenUtil.instance.statusBarHeight + CustomAppBar.appBarHeight,
                      // color: AppColor.bgBlack,
                      alignment: Alignment(-1, 1),
                      child: CustomAppBarIconButton(
                        svgName: AppIcon.nav_return,
                        iconColor: AppColor.bgBlack,
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    Expanded(
                        child: Center(
                      child: CupertinoActivityIndicator(),
                    ))
                  ],
                ),
              ));
  }

  // 子页面下拉刷新
  subpageRefresh() {
    _key.currentState.currentInnerPosition
        .animateTo(0.0, duration: Duration(milliseconds: 250), curve: Curves.linear)
        .then((value) => occlusionLayerStreamController.sink.add(false));
  }

  // 大图预览内部的Item
  Widget itemBuilder(BuildContext context, int index, bool isFocus, Function(Function(bool isFocus), int) setFocus) {
    TopicDtoModel topicDtoModel = topicDtoModelList[index];

    DemoSourceEntity sourceEntity = DemoSourceEntity(
      topicDtoModel.id.toString(),
      " image",
      topicDtoModel.avatarUrl?.coverUrl ,
      isTopicNoCover:  topicDtoModel.avatarUrl == null
    );
    print("____sourceEntity:${sourceEntity.toString()}");
    return DemoImageItem(sourceEntity, isFocus, index, setFocus);
  }

  Widget appBar() {
    return StreamBuilder<TopicUiChangeModel>(
        initialData: topicUiChangeModel,
        stream: appBarStreamController.stream,
        builder: (BuildContext stramContext, AsyncSnapshot<TopicUiChangeModel> snapshot) {
          return Container(
            color: AppColor.mainBlack.withOpacity(snapshot.data.opacity),
            height: CustomAppBar.appBarHeight + ScreenUtil.instance.statusBarHeight,
            width: ScreenUtil.instance.width,
            padding: EdgeInsets.only(top: ScreenUtil.instance.statusBarHeight),
            child: Center(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CustomAppBarIconButton(
                    svgName: AppIcon.nav_return,
                    iconColor:
                    // snapshot.data.opacity != 0.0
                    //     ? AppColor.bgWhite.withOpacity(snapshot.data.opacity)
                    //     :
                    AppColor.white,
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  SizedBox(
                    width: 12,
                  ),
                  Text(
                    "#${model.name}",
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                        color: AppColor.bgWhite.withOpacity(snapshot.data.opacity)),
                  ),
                  Spacer(),
                  snapshot.data.canOnclick
                      ? Container(
                          width: 60,
                          margin: EdgeInsets.only(right: 8),
                          child: _followButton(),
                        )
                      : Container(),
                  CustomAppBarIconButton(
                    svgName: AppIcon.nav_share,
                    iconColor:
                    // snapshot.data.opacity != 0.0
                    //     ? AppColor.bgWhite.withOpacity(snapshot.data.opacity)
                    //     :
                    AppColor.white,
                    onTap: () {
                      openShareBottomSheet(
                          context: context,
                          map: model.toJson(),
                          sharedType: 3,
                          chatTypeModel: ChatTypeModel.NULL_COMMENT);
                    },
                  ),
                  SizedBox(
                    width: 8,
                  )
                ],
              ),
            ),
          );
        });
  }

  Widget _gotoRelease() {
    return InkWell(
      onTap: () {
        if (!context.read<TokenNotifier>().isLoggedIn) {
          AppRouter.navigateToLoginPage(context);
          return;
        }
        RuntimeProperties.topicMap[model.id] = model;
        AppRouter.navigateToMediaPickerPage(context, 9, typeImageAndVideo, true, startPageGallery, false, (result) {},
            publishMode: 1, topicId: model.id);
      },
      child: Container(
        width: 127,
        height: 43,
        decoration: const BoxDecoration(
          color: AppColor.textPrimary2,
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
                child: AppIcon.getAppIcon(
                  AppIcon.camera_27,
                  27,
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
          if (!context.read<TokenNotifier>().isLoggedIn) {
            AppRouter.navigateToLoginPage(context);
            return;
          }
          if (!beforOnClickOver) {
            return;
          }
          beforOnClickOver = false;
          if (model.isFollow == 0) {
            if(model.dataState!=2){
              ToastShow.show(msg: "该账号已封禁", context: context);
              return;}
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
                color: AppColor.mainYellow
                // border: Border.all(width: 1, color: AppColor.bgBlack)
            ),
            child: Stack(
              children: [
                StreamBuilder<double>(
                    initialData: followOrNot ? 0 : 1,
                    stream: notFollowStreamController.stream,
                    builder: (BuildContext stramContext, AsyncSnapshot<double> snapshot) {
                      return AnimatedOpacity(
                        opacity: snapshot.data,
                        duration: Duration(milliseconds: 400),
                        child: Center(
                            child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add, size: 16, color: AppColor.black),
                            Text("关注",
                                style:
                                    TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColor.textPrimary1))
                          ],
                        )),
                        onEnd: () {
                          if (model.isFollow == 1) {
                            followStreamController.sink.add(1);
                          } else {
                            beforOnClickOver = true;
                          }
                        },
                      );
                    }),
                StreamBuilder<double>(
                    initialData: !followOrNot ? 0 : 1,
                    stream: followStreamController.stream,
                    builder: (BuildContext stramContext, AsyncSnapshot<double> snapshot) {
                      return AnimatedOpacity(
                        opacity: snapshot.data,
                        duration: Duration(milliseconds: 400),
                        child: Center(
                          child: Text("已关注",
                              style:
                                  TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColor.textPrimary1)),
                        ),
                        onEnd: () {
                          if (model.isFollow == 0) {
                            notFollowStreamController.sink.add(1);
                          } else {
                            beforOnClickOver = true;
                          }
                        },
                      );
                    })
              ],
            ) /* model.isFollow == 0
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, size: 16, color: AppColor.black),
                      Text("关注",
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColor.textPrimary1))
                    ],
                  )
                : Center(
                    child: Text("已关注",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColor.textPrimary1)),
                  )*/
            ));
  }
}

class TopicUiChangeModel {
  double opacity = 0;
  bool canOnclick = false;
}

class TopicDoubleTapTabbar {
  int tabControllerIndex;
  int topicId;

  // 内部控制器
  ScrollController innerController;

// 外部部控制器
  ScrollController outerController;
}

class BottomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    // path.lineTo(0, 0); //第1个点
    // path.lineTo(0, size.height - 50.0); //第2个点
    // var firstControlPoint = Offset(size.width / 2, size.height);
    // var firstEdnPoint = Offset(size.width, size.height - 50.0);
    // path.quadraticBezierTo(
    //     firstControlPoint.dx,
    //     firstControlPoint.dy,
    //     firstEdnPoint.dx,
    //     firstEdnPoint.dy
    // );
    // path.lineTo(size.width, size.height - 50.0); //第3个点
    // path.lineTo(size.width, 0); //第4个点
    //波浪曲线路径
    path.lineTo(0, 0); //第1个点
    path.lineTo(0, size.height - 40.0); //第2个点
    var firstControlPoint = Offset(size.width / 4, size.height); //第一段曲线控制点
    var firstEndPoint = Offset(size.width / 2.25, size.height - 30); //第一段曲线结束点
    path.quadraticBezierTo(
        //形成曲线
        firstControlPoint.dx,
        firstControlPoint.dy,
        firstEndPoint.dx,
        firstEndPoint.dy);

    var secondControlPoint = Offset(size.width / 4 * 3, size.height - 90); //第二段曲线控制点
    var secondEndPoint = Offset(size.width, size.height - 40); //第二段曲线结束点
    path.quadraticBezierTo(
        //形成曲线
        secondControlPoint.dx,
        secondControlPoint.dy,
        secondEndPoint.dx,
        secondEndPoint.dy);

    path.lineTo(size.width, size.height - 40);
    path.lineTo(size.width, 0);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
