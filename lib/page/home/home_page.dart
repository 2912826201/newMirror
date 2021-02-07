import 'package:flutter/material.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/page/home/sub_page/attention_page.dart';
import 'package:mirror/page/home/sub_page/home_top_tab.dart';
import 'package:mirror/page/home/sub_page/recommend_page.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  HomePage({
    Key key,
    this.controller
  }) : super(key: key);
  TabController controller;

  HomePageState createState() => HomePageState(controller: controller);
}

class HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  HomePageState({TabController controller});

  // taBar和TabBarView必要的
  TabController controller;
  @override
  bool get wantKeepAlive => true; //必须重写

  @override
  initState() {
    super.initState();
    controller = TabController(length: 2, vsync: this, initialIndex: 1);
  }
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }



    @override
    Widget build(BuildContext context) {
      print("HomePage_____________________________________________build");
      // print("首页");
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
                        child: HomeTopTab(controller: controller,),
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
                            ),
                            RecommendPage(
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
