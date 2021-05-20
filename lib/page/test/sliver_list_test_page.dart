import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as W;
import 'package:flutter/rendering.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/feed/feed_share_popups.dart';
import 'package:mirror/widget/icon.dart';
import 'package:mirror/widget/round_underline_tab_indicator.dart';

import 'animated_list_demo.dart';

class SliverListDemoPage extends StatefulWidget {
  @override
  _SliverListDemoPageState createState() => _SliverListDemoPageState();
}

class _SliverListDemoPageState extends State<SliverListDemoPage> with SingleTickerProviderStateMixin {
  int listCount = 30;

// taBar和TabBarView必要的
  TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    super.initState();
  }

  // a() {
  //   NestedScrollView(
  //     controller: _scrollController,
  //     headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
  //       return <Widget>[
  //         StreamBuilder<TopicUiChangeModel>(
  //             initialData: topicUiChangeModel,
  //             stream: appBarStreamController.stream,
  //             builder: (BuildContext stramContext, AsyncSnapshot<TopicUiChangeModel> snapshot) {
  //               return SliverAppBar(
  //                 expandedHeight: sliverAppBarHeight(),
  //                 pinned: true,
  //                 titleSpacing: 0,
  //                 title: Text(
  //                   "#${widget.model.name}",
  //                   style:
  //                   TextStyle(fontWeight: FontWeight.w500, fontSize: 18, color: snapshot.data.titleColor),
  //                 ),
  //                 leading: CustomAppBarIconButton(
  //                   svgName: AppIcon.nav_return,
  //                   iconColor: snapshot.data.iconColor,
  //                   onTap: () {
  //                     Navigator.pop(context);
  //                   },
  //                 ),
  //                 actions: <Widget>[
  //                   snapshot.data.canOnclick
  //                       ? Container(
  //                     width: 60,
  //                     padding: EdgeInsets.only(top: 14, bottom: 14),
  //                     margin: EdgeInsets.only(right: 8),
  //                     child: _followButton(),
  //                   )
  //                       : Container(),
  //                   CustomAppBarIconButton(
  //                     svgName: AppIcon.nav_share,
  //                     iconColor: snapshot.data.iconColor,
  //                     onTap: () {
  //                       openShareBottomSheet(
  //                           context: context,
  //                           map: widget.model.toJson(),
  //                           sharedType: 3,
  //                           chatTypeModel: ChatTypeModel.NULL_COMMENT);
  //                     },
  //                   ),
  //                   SizedBox(
  //                     width: 8,
  //                   )
  //                 ],
  //                 backgroundColor: AppColor.white,
  //                 flexibleSpace: FlexibleSpaceBar(
  //                   background: Stack(
  //                     children: [
  //                       // 背景颜色
  //                       Container(
  //                         height: 128,
  //                         width: ScreenUtil.instance.width,
  //                         color: AppColor.bgBlack,
  //                       ),
  //                       // 头像
  //                       Positioned(
  //                           left: 14,
  //                           bottom: widget.model.description != null
  //                               ? (getTextSize(widget.model.description, AppStyle.textRegular14, 10,
  //                               ScreenUtil.instance.width - 32)
  //                               .height +
  //                               25 +
  //                               13)
  //                               : 13,
  //                           child: Container(
  //                             width: 71,
  //                             height: 71,
  //                             padding: const EdgeInsets.all(2),
  //                             decoration: const BoxDecoration(
  //                               // 圆角
  //                                 borderRadius: BorderRadius.all(Radius.circular(10.0)),
  //                                 color: AppColor.white),
  //                             child: Container(
  //                                 decoration: BoxDecoration(
  //                                   // 圆角
  //                                     borderRadius: const BorderRadius.all(Radius.circular(10.0)),
  //                                     // image: DecorationImage(
  //                                     //     image: NetworkImage(widget.model.avatarUrl + "?imageslim"  ??
  //                                     //         "https://tva1.sinaimg.cn/large/006y8mN6gy1g7aa03bmfpj3069069mx8.jpg"+"?imageslim" ),
  //                                     //     fit: BoxFit.cover),
  //                                     color: AppColor.white),
  //                                 clipBehavior: Clip.antiAlias,
  //                                 child: CachedNetworkImage(
  //                                   // 调整磁盘缓存中图像大小
  //                                   maxHeightDiskCache: 150,
  //                                   maxWidthDiskCache: 150,
  //                                   imageUrl: widget.model.avatarUrl != null ? FileUtil.getSmallImage(
  //                                       widget.model.avatarUrl) : "",
  //                                   fit: BoxFit.cover,
  //                                   placeholder: (context, url) =>
  //                                       Container(
  //                                         color: AppColor.bgWhite,
  //                                       ),
  //                                   errorWidget: (context, url, e) {
  //                                     return Container(
  //                                       color: AppColor.bgWhite,
  //                                     );
  //                                   },
  //                                 )
  //                             ),
  //                           )),
  //                       // 话题内容
  //                       Positioned(
  //                           bottom: widget.model.description != null
  //                               ? (getTextSize(widget.model.description, AppStyle.textRegular14, 10,
  //                               ScreenUtil.instance.width - 32)
  //                               .height +
  //                               25)
  //                               : 0,
  //                           child: Container(
  //                             height: 69,
  //                             width: ScreenUtil.instance.width - 96,
  //                             margin: const EdgeInsets.only(left: 96),
  //                             child: Row(
  //                               crossAxisAlignment: CrossAxisAlignment.center,
  //                               children: [
  //                                 Column(
  //                                   mainAxisAlignment: MainAxisAlignment.center,
  //                                   crossAxisAlignment: CrossAxisAlignment.start,
  //                                   children: [
  //                                     Container(
  //                                       width: ScreenUtil.instance.width * (168 / ScreenUtil.instance.width),
  //                                       child: Text(
  //                                         "#${widget.model.name}",
  //                                         style: AppStyle.textMedium16,
  //                                       ),
  //                                     ),
  //                                     const SizedBox(
  //                                       height: 3,
  //                                     ),
  //                                     Text(
  //                                       "${StringUtil.getNumber(widget.model.feedCount)}条动态",
  //                                       style: AppStyle.textPrimary3Regular12,
  //                                     )
  //                                   ],
  //                                 ),
  //                                 // SizedBox(width: 12,),
  //                                 const Spacer(),
  //                                 _followButton(),
  //                                 const SizedBox(
  //                                   width: 16,
  //                                 )
  //                               ],
  //                             ),
  //                           )),
  //                       // 话题描述
  //                       widget.model.description != null
  //                           ? Positioned(
  //                           bottom: 0,
  //                           child: Container(
  //                             width: ScreenUtil.instance.width,
  //                             padding: const EdgeInsets.only(left: 16, top: 12, right: 16, bottom: 12),
  //                             child: Text(
  //                               widget.model.description,
  //                               style: AppStyle.textRegular14,
  //                               maxLines: 10,
  //                             ),
  //                           ))
  //                           : Container(),
  //                     ],
  //                   ),
  //                 ),
  //               );
  //             }),
  //         SliverPersistentHeader(
  //           pinned: true,
  //           delegate: TopicDetailTabBarDelegate(
  //             child: TabBar(
  //               labelColor: Colors.black,
  //               controller: _tabController,
  //               labelStyle: const TextStyle(fontSize: 16),
  //               unselectedLabelColor: AppColor.textHint,
  //               indicator: const RoundUnderlineTabIndicator(
  //                 borderSide: BorderSide(
  //                   width: 2,
  //                   color: AppColor.bgBlack,
  //                 ),
  //                 insets: EdgeInsets.only(bottom: 0),
  //                 wantWidth: 20,
  //               ),
  //               tabs: <Widget>[
  //                 const Tab(text: '推荐'),
  //                 const Tab(text: '最新'),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ];
  //     },
  //     body: TabBarView(
  //       controller: _tabController,
  //       children: <Widget>[
  //         PrimaryScrollContainer(
  //           scrollChildKeys[0],
  //           TopicList(
  //             topicId: widget.model.id,
  //             type: 5,
  //           ),
  //         ),
  //         // 推荐话题
  //         // 最新话题
  //         PrimaryScrollContainer(
  //           scrollChildKeys[1],
  //           TopicList(
  //             topicId: widget.model.id,
  //             type: 4,
  //           ),
  //         ),
  //       ],
  //     ),
  //   )
  // }
  // 头部高度
  sliverAppBarHeight() {
    // UI图原始高度
    double height = 153.0 + ScreenUtil.instance.statusBarHeight;
    return height;
  }

  List<Widget> _sliverBuilder(BuildContext context, bool innerBoxIsScrolled) {
    return <Widget>[
      // SliverPersistentHeader(
      //   pinned: true,
      //   delegate: GSYSliverHeaderDelegate(
      //     maxHeight: 48,
      //     minHeight: 48,
      //     vSync: this,
      //     snapConfig: FloatingHeaderSnapConfiguration(
      //       curve: Curves.bounceInOut,
      //       duration: const Duration(milliseconds: 10),
      //     ),
      //     child: new Container(
      //       color: Colors.redAccent,
      //     ),
      //   ),
      // ),
      ///头部信息
      SliverPersistentHeader(
        delegate: GSYSliverHeaderDelegate(
          maxHeight: 180,
          minHeight: 180,
          vSync: this,
          snapConfig: FloatingHeaderSnapConfiguration(
            curve: Curves.bounceInOut,
            duration: const Duration(milliseconds: 10),
          ),
          child: new Container(
            color: Colors.cyan,
          ),
        ),
      ),
      // SliverAppBar(
      //   expandedHeight: sliverAppBarHeight(),
      //   pinned: true,
      //   titleSpacing: 0,
      //   title: Text(
      //     "#${"widget.model.name"}",
      //     style:
      //     TextStyle(fontWeight: FontWeight.w500, fontSize: 18,),
      //   ),
      //   leading: CustomAppBarIconButton(
      //     svgName: AppIcon.nav_return,
      //     onTap: () {
      //       Navigator.pop(context);
      //     },
      //   ),
      //   actions: <Widget>[
      //     CustomAppBarIconButton(
      //       svgName: AppIcon.nav_share,
      //       onTap: () {
      //       },
      //     ),
      //     SizedBox(
      //       width: 8,
      //     )
      //   ],
      //   backgroundColor: AppColor.white,
      //   flexibleSpace: FlexibleSpaceBar(
      //     background: Stack(
      //       children: [
      //         // 背景颜色
      //         Container(
      //           height: 128,
      //           width: ScreenUtil.instance.width,
      //           color: AppColor.bgBlack,
      //         ),
      //         // 头像
      //         Positioned(
      //             left: 14,
      //             bottom: 13,
      //             child: Container(
      //               width: 71,
      //               height: 71,
      //               padding: const EdgeInsets.all(2),
      //               decoration: const BoxDecoration(
      //                 // 圆角
      //                   borderRadius: BorderRadius.all(Radius.circular(10.0)),
      //                   color: AppColor.white),
      //               child: Container(
      //                   decoration: BoxDecoration(
      //                     // 圆角
      //                       borderRadius: const BorderRadius.all(Radius.circular(10.0)),
      //                       // image: DecorationImage(
      //                       //     image: NetworkImage(widget.model.avatarUrl + "?imageslim"  ??
      //                       //         "https://tva1.sinaimg.cn/large/006y8mN6gy1g7aa03bmfpj3069069mx8.jpg"+"?imageslim" ),
      //                       //     fit: BoxFit.cover),
      //                       color: AppColor.white),
      //                   clipBehavior: Clip.antiAlias,
      //                   child: CachedNetworkImage(
      //                     // 调整磁盘缓存中图像大小
      //                     maxHeightDiskCache: 150,
      //                     maxWidthDiskCache: 150,
      //                     imageUrl:"https://tva1.sinaimg.cn/large/006y8mN6gy1g7aa03bmfpj3069069mx8.jpg",
      //                     fit: BoxFit.cover,
      //                     placeholder: (context, url) =>
      //                         Container(
      //                           color: AppColor.bgWhite,
      //                         ),
      //                     errorWidget: (context, url, e) {
      //                       return Container(
      //                         color: AppColor.bgWhite,
      //                       );
      //                     },
      //                   )
      //               ),
      //             )),
      //         // 话题内容
      //         Positioned(
      //             bottom: 0,
      //             child: Container(
      //               height: 69,
      //               width: ScreenUtil.instance.width - 96,
      //               margin: const EdgeInsets.only(left: 96),
      //               child: Row(
      //                 crossAxisAlignment: CrossAxisAlignment.center,
      //                 children: [
      //                   Column(
      //                     mainAxisAlignment: MainAxisAlignment.center,
      //                     crossAxisAlignment: CrossAxisAlignment.start,
      //                     children: [
      //                       Container(
      //                         width: ScreenUtil.instance.width * (168 / ScreenUtil.instance.width),
      //                         child: Text(
      //                           "#哈哈哈哈哈",
      //                           style: AppStyle.textMedium16,
      //                         ),
      //                       ),
      //                       const SizedBox(
      //                         height: 3,
      //                       ),
      //                       Text(
      //                         "4条动态",
      //                         style: AppStyle.textPrimary3Regular12,
      //                       )
      //                     ],
      //                   ),
      //                   // SizedBox(width: 12,),
      //                   const Spacer(),
      //                   // _followButton(),
      //                   const SizedBox(
      //                     width: 16,
      //                   )
      //                 ],
      //               ),
      //             )),
      //       ],
      //     ),
      //   ),
      // ),
      SliverOverlapAbsorber(
        handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        sliver: SliverPersistentHeader(
          pinned: true,
          /// SliverPersistentHeaderDelegate 的实现
          delegate: GSYSliverHeaderDelegate(
              maxHeight: 60,
              minHeight: 60,
              changeSize: true,
              vSync: this,
              snapConfig: FloatingHeaderSnapConfiguration(
                curve: Curves.bounceInOut,
                duration: const Duration(milliseconds: 10),
              ),
              builder: (BuildContext context, double shrinkOffset, bool overlapsContent) {
                return Container(
                  color: AppColor.bgWhite,
                  child:  TabBar(
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
                );

                //   SizedBox.expand(
                //   child: Padding(
                //     padding: EdgeInsets.only(
                //         bottom: 10, left: lr, right: lr, top: lr),
                //     child: new Row(
                //       mainAxisSize: MainAxisSize.max,
                //       children: <Widget>[
                //         new Expanded(
                //           child: new Container(
                //             alignment: Alignment.center,
                //             color: Colors.orangeAccent,
                //             child: new TextButton(
                //               onPressed: () {
                //                 setState(() {
                //                   listCount = 30;
                //                 });
                //               },
                //               child: new Text("按键1"),
                //             ),
                //           ),
                //         ),
                //         new Expanded(
                //           child: new Container(
                //             alignment: Alignment.center,
                //             color: Colors.orangeAccent,
                //             child: new TextButton(
                //               onPressed: () {
                //                 setState(() {
                //                   listCount = 4;
                //                 });
                //               },
                //               child: new Text("按键2"),
                //             ),
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // );
              }),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bgWhite,
      body: new Container(
        child: NestedScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          headerSliverBuilder: _sliverBuilder,
          body: CustomScrollView(
            slivers: [
              W.Builder(
                builder: (context) {
                  return SliverOverlapInjector(handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context));
                },
              ),
              SliverFillRemaining(
                child: TabBarView(
                  controller: _tabController,
                  children: <Widget>[
                    AnimatedListDemo(),
                    // 推荐话题
                    Container(
                      height: double.infinity,
                      padding: EdgeInsets.only(left: 10),
                      alignment: Alignment.centerLeft,
                      color: AppColor.mainBlue,
                    ),
                  ],
                ),
              ),
              // SliverList(
              //   delegate: SliverChildBuilderDelegate(
              //     (context, index) {
              //       return Card(
              //         child: new Container(
              //           height: 60,
              //           padding: EdgeInsets.only(left: 10),
              //           alignment: Alignment.centerLeft,
              //           child: new Text("Item $index"),
              //         ),
              //       );
              //     },
              //     childCount: 100,
              //   ),
              // )
            ],
          ),
        ),
      ),
    );
  }
}

///动态头部处理
class GSYSliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  GSYSliverHeaderDelegate(
      {@required this.minHeight,
      @required this.maxHeight,
      @required this.snapConfig,
      @required this.vSync,
      this.child,
      this.builder,
      this.changeSize = false});

  final double minHeight;
  final double maxHeight;
  final Widget child;
  final Builder builder;
  final bool changeSize;
  final TickerProvider vSync;
  final FloatingHeaderSnapConfiguration snapConfig;
  AnimationController animationController;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => math.max(maxHeight, minHeight);

  @override
  TickerProvider get vsync => vSync;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    if (builder != null) {
      return builder(context, shrinkOffset, overlapsContent);
    }
    return child;
  }

  @override
  bool shouldRebuild(GSYSliverHeaderDelegate oldDelegate) {
    return true;
  }

  @override
  FloatingHeaderSnapConfiguration get snapConfiguration => snapConfig;
}

typedef Widget Builder(BuildContext context, double shrinkOffset, bool overlapsContent);
