import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/topic/topic_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/profile/topic_list_model.dart';
import 'package:mirror/page/topic/topic_newest.dart';
import 'package:mirror/page/topic/topic_recommend.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/string_util.dart';
import 'package:mirror/util/text_util.dart';
import 'package:mirror/widget/round_underline_tab_indicator.dart';

class TopicDetail extends StatefulWidget {
  TopicDetail({Key key, this.topicId}) : super(key: key);
  int topicId;

  @override
  TopicDetailState createState() => TopicDetailState();
}

class TopicDetailState extends State<TopicDetail> with SingleTickerProviderStateMixin {
  TopicDtoModel model;

  // taBar和TabBarView必要的
  TabController _tabController;

  //   列表监听
  ScrollController _scrollController = new ScrollController();

  // 透明度
  int _titleAlpha = 0; //范围 0-255
  // 文字颜色
  Color titleColor = AppColor.transparent;

  // 图标颜色
  Color iconColor = AppColor.bgWhite;

  // 头部滑动距离
  double headSlideHeight;

  // tarHeight
  double tarHeight = 54;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    requestTopicDetail();
    _scrollController
      ..addListener(() {
        print("headSlideHeight$headSlideHeight");
        print(_scrollController.offset);
        setState(() {
          if (_scrollController.offset >= headSlideHeight) {
            print("进了");
            // _titleAlpha = 255;
            titleColor = AppColor.bgBlack;
            iconColor = AppColor.bgBlack;
          } else {
            titleColor = AppColor.transparent;
            iconColor = AppColor.bgWhite;
          }
          // } else if (_scrollController.offset <= 0) {
          //   _titleAlpha = 0;
          //
          //   AppColor.bgBlack;
          //
          // } else {
          //   titleColor = Color.fromRGBO(0xFF, 0xFF, 0xFF, 1.0);
          //   // _titleAlpha = _scrollController.offset * 255 ~/ headSlideHeight;
          // }
        });
      });
    super.initState();
  }

  // 请求动态详情接口
  requestTopicDetail() async {
    model = await getTopicInfo(topicId: widget.topicId);
    setState(() {});
  }

  // 头部高度
  sliverAppBarHeight() {
    // UI图原始高度
    double height = 197.0 - ScreenUtil.instance.statusBarHeight;
    if (model.description != null) {
      //加上文字高度
      height += getTextSize(model.description, AppStyle.textRegular14, 0).height;
      // 文字上下方间距
      height += 25;
    }
    headSlideHeight = height - tarHeight;
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
                    pinned: true,
                    expandedHeight: sliverAppBarHeight(),
                    title: Text(model.name, style: TextStyle(color: titleColor)),
                    leading: new IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: iconColor,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    // GestureDetector(
                    //     onTap: () {
                    //       Navigator.of(context).pop(true);
                    //     },
                    //     child: Container(
                    //       margin: EdgeInsets.only(left: 16),
                    //       child: Image.asset(
                    //         "images/resource/2.0x/return2x.png",
                    //       ),
                    //     )),
                    // leadingWidth: 44.0,
                    // elevation: 0.5,
                    actions: <Widget>[
                      new IconButton(
                        icon: Icon(
                          Icons.wysiwyg,
                          color: iconColor,
                        ),
                        onPressed: () {
                          print("更多");
                        },
                      ),
                    ],
                    backgroundColor: AppColor.white,
                    flexibleSpace: FlexibleSpaceBar(
                      // title: Text(model.name, style: AppStyle.textMedium16),
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
                                  ? (getTextSize(model.description, AppStyle.textRegular14, 0).height + 25 + 13)
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
                                  ? (getTextSize(model.description, AppStyle.textRegular14, 0).height + 25)
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
                                    Container(
                                        height: 28,
                                        width: 72,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(Radius.circular(15)),
                                            border: Border.all(width: 0.5, color: AppColor.black)),

                                        ///判断是我的页面还是别人的页面
                                        child: Center(
                                          child: Text("关注", style: AppStyle.textRegular12),
                                        )),
                                    SizedBox(
                                      width: 16,
                                    )
                                  ],
                                ),
                              )),
                          // 话题描述
                          model.description != null ? Positioned(
                            bottom: 0,
                              child: Container(
                                width: ScreenUtil.instance.width,
                                padding: EdgeInsets.only(left: 16,top: 12,right: 16,bottom: 12),
                                child: Text(
                                  model.description,style: AppStyle.textRegular14,
                                ),
                              )
                          ) : Container(),
                        ],
                      ),
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: TopicTabBarDelegate(
                      child: TabBar(
                        labelColor: Colors.black,
                        controller: this._tabController,
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
                controller: this._tabController,
                children: <Widget>[
                  // 推荐话题
                  TopicRecommend(topicId: model.id,),
                  // 最新话题
                  TopicNewest(
                  ),
                ],
              ),
              // SliverFixedExtentList(
              //     itemExtent: 80.0,
              //     delegate: SliverChildBuilderDelegate(
              //       (BuildContext context, int index) {
              //         return Card(
              //           child: Container(
              //             alignment: Alignment.center,
              //             color: Colors.primaries[(index % 18)],
              //             child: Text(''),
              //           ),
              //         );
              //       },
              //     ),
              //   ),
              // ],
            )
          : Container(),
    );
  }
}

class TopicTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar child;

  TopicTabBarDelegate({@required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      padding: EdgeInsets.only(left: 129, right: 129),
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
