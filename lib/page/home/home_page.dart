import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/course_model.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/page/home/sub_page/attention_page.dart';
import 'package:mirror/page/home/sub_page/home_top_tab.dart';
import 'package:mirror/page/home/sub_page/recommend_page.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class HomePage extends StatefulWidget {
  HomePage({
    Key key,
    this.pc,
  }) : super(key: key);
  PanelController pc = new PanelController();

  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
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
    // 请求接口
    // getAttentionFeed();
    super.initState();
    controller = TabController(length: 2, vsync: this, initialIndex: 1);
    for (var i in coverUrls) {
      CourseModel a = new CourseModel(i, coverUrls.indexOf(i));
      courses.add(a);
    }
  }
  // 关注页model
 getAttentionFeed() async {
   Map<String, dynamic> a = await getPullList(type: 0, size: 20);

   print("关注页数据$a");
 }

  @override
  Widget build(BuildContext context) {
    print("首页");
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
                  child: TabBarView(
                    controller: this.controller,
                    // physics: new NeverScrollableScrollPhysics(),// 禁止滑动

                    children: [
                      // CustomScrollComState(urls: courses,),
                      AttentionPage(
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
    // return
  }
}
