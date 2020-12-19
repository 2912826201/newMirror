import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/data/model/course_model.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/media_file_model.dart';
import 'package:mirror/data/model/post_feed/post_feed.dart';
import 'package:mirror/data/model/upload/upload_result_model.dart';
import 'package:mirror/page/home/sub_page/attention_page.dart';
import 'package:mirror/page/home/sub_page/home_top_tab.dart';
import 'package:mirror/page/home/sub_page/recommend_page.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class HomePage extends StatefulWidget {
  HomePage({
    Key key,
    this.pc,
    this.controller
  }) : super(key: key);
  PanelController pc = new PanelController();
  TabController controller;

  HomePageState createState() => HomePageState(controller: controller);
}

class HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  HomePageState({TabController controller});

  // taBar和TabBarView必要的
  TabController controller;
  @override
  bool get wantKeepAlive => true; //必须重写
  // 测试图片
  var coverUrls = [
    "https://img9.doubanio.com\/view\/photo\/s_ratio_poster\/public\/p2623955494.webp",
    "https://img9.doubanio.com\/view\/photo\/s_ratio_poster\/public\/p2615992304.webp",
    "https://img3.doubanio.com\/view\/photo\/s_ratio_poster\/public\/p2615642201.webp",
    "https://img2.doubanio.com\/view\/photo\/s_ratio_poster\/public\/p2599858573.webp",
    "https://img1.doubanio.com\/view\/photo\/s_ratio_poster\/public\/p2620104689.webp",
    "https://img3.doubanio.com\/view\/photo\/s_ratio_poster\/public\/p2620161520.webp",
    "https://img3.doubanio.com\/view\/photo\/s_ratio_poster\/public\/p2621884130.webp",
    "https://img9.doubanio.com\/view\/photo\/s_ratio_poster\/public\/p2622904695.webp",
    "https://img2.doubanio.com\/view\/photo\/s_ratio_poster\/public\/p2621751023.webp"
  ];
  List<CourseModel> courses = [];

  @override
  initState() {
    super.initState();
    controller = TabController(length: 2, vsync: this, initialIndex: 1);
    for (var i in coverUrls) {
      CourseModel a = new CourseModel(i, coverUrls.indexOf(i));
      courses.add(a);
    }
  }




    @override
    Widget build(BuildContext context) {
      print("首页");
      if(context.watch<FeedMapNotifier>().postFeedModel != null) {
        controller.index = 0;
      }
      // pulishFeed();
      return Container(
        child: Stack(
          children: [
            Container(
              // 设置背景色
              decoration: BoxDecoration(color: Colors.white),
              // 层叠布局
              child: Stack(
                // 子布局定位
                children: [
                  Positioned(
                      top: ScreenUtil.instance.statusBarHeight,
                      height: 44,
                      width: ScreenUtil.instance.screenWidthDp,
                      child: Container(
                        child: HomeTopTab(controller: controller),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(bottom: BorderSide(width: 0.5, color: Color(0xffe5e5e5))),
                        ),
                      )),
                  Container(
                    margin: EdgeInsets.only(top: 44 + ScreenUtil.instance.statusBarHeight),
                    // child: Column(
                    //   children: [
                         // createdPostPromptView(),
                    child:TabBarView(
                          controller: this.controller,
                          children: [
                              AttentionPage(
                                postFeedModel: context.watch<FeedMapNotifier>().postFeedModel,
                              coverUrls: courses,
                              pc: widget.pc,
                            ),
                            RecommendPage(
                              coverUrls: courses,
                              pc: widget.pc,
                            )
                            // RecommendPage()
                          ],
                        ),
                  )
                ],
              ),
            ),
          ],
        ),
      );
      // return
    }
  }
