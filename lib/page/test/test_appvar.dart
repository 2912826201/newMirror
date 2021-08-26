import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/string_util.dart';
import 'package:mirror/util/text_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/icon.dart';

class StickyDemo extends StatefulWidget {
  TopicDtoModel model;

  StickyDemo({this.model});

  @override
  _StickyDemoState createState() => _StickyDemoState();
}

class _StickyDemoState extends State<StickyDemo> with SingleTickerProviderStateMixin {
  TabController tabController;

// 头部滑动距离
  double headSlideHeight;

  @override
  void initState() {
    super.initState();
    this.tabController = TabController(length: 2, vsync: this);
  }

  // 头部高度
  sliverAppBarHeight() {
    // UI图原始高度
    double height = 197
        // 197.0 - ScreenUtil.instance.statusBarHeight
        ;
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

  Widget _followButton() {
    return GestureDetector(
        onTap: () {
          if (widget.model.isFollow == 0) {
            // requestFollowTopic();
          } else {
            // requestCancelFollowTopic();
          }
        },
        child: Container(
            height: 28,
            width: 72,
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(15)),
                border: Border.all(width: 1, color: AppColor.black)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(4.0),
        child: AppBar(),
        // titleSpacing: 0,
        // title: Text(
        //   "#${widget.model.name}",
        //   style: TextStyle(
        //     fontWeight: FontWeight.w500,
        //     fontSize: 18,
        //   ),
        // ),
        // leading: CustomAppBarIconButton(
        //   svgName: AppIcon.nav_return,
        //   onTap: () {
        //     Navigator.pop(context);
        //   },
        // ),
        // actions: <Widget>[
        //   Container(
        //     width: 60,
        //     padding: EdgeInsets.only(top: 14, bottom: 14),
        //     margin: EdgeInsets.only(right: 8),
        //     child: _followButton(),
        //   ),
        //   CustomAppBarIconButton(svgName: AppIcon.nav_share, onTap: () {}),
        //   SizedBox(
        //     width: 8,
        //   )
        // ],
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Container(
              width: ScreenUtil.instance.width,
              height: sliverAppBarHeight(),
              child: Stack(
                children: [
                  // 背景颜色
                  Container(
                    height: 128,
                    width: ScreenUtil.instance.width,
                    decoration: BoxDecoration(
                      // color: Colors.redAccent,
                      image: DecorationImage(image: NetworkImage(widget.model.avatarUrl.coverUrl), fit: BoxFit.cover),
                    ),
                    child: Container(
                      color: AppColor.mainBlack.withOpacity(0.7),
                    ),
                  ),
                  Positioned(
                      top: ScreenUtil.instance.statusBarHeight,
                      child: Container(
                        width: ScreenUtil.instance.width,
                        height: 44,
                        // color: AppColor.mainRed,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 16,
                            ),
                            CustomAppBarIconButton(
                              svgName: AppIcon.nav_return,
                              iconColor: AppColor.white,
                              onTap: () {
                                Navigator.pop(context);
                              },
                            ),
                            SizedBox(
                              width: 12,
                            ),
                            Text(
                              "#${widget.model.name}",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 18,
                              ),
                            ),
                            Spacer(),
                            Container(
                              width: 60,
                              margin: EdgeInsets.only(right: 16),
                              child: _followButton(),
                            ),
                            CustomAppBarIconButton(svgName: AppIcon.nav_share, iconColor: AppColor.white, onTap: () {}),
                            SizedBox(
                              width: 16,
                            )
                          ],
                        ),
                      )),
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
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: StickyTabBarDelegate(
              child: TabBar(
                labelColor: Colors.black,
                controller: this.tabController,
                tabs: <Widget>[
                  Tab(text: 'Home'),
                  Tab(text: 'Profile'),
                ],
              ),
            ),
          ),
          SliverFillRemaining(
            child: TabBarView(
              controller: this.tabController,
              children: <Widget>[
                ListView.builder(
                  itemBuilder: (context, index) {
                    return Container(
                      height: 85,
                      alignment: Alignment.center,
                      color: Colors.primaries[index % Colors.primaries.length],
                      child: Text(
                        '$index',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    );
                  },
                  itemCount: 25,
                ),
                ListView.builder(
                  itemBuilder: (context, index) {
                    return Container(
                      height: 85,
                      alignment: Alignment.center,
                      color: Colors.primaries[index % Colors.primaries.length],
                      child: Text(
                        '$index',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    );
                  },
                  itemCount: 25,
                ),
                // ListView.
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar child;

  StickyTabBarDelegate({@required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return this.child;
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
