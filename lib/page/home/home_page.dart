import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/page/home/sub_page/attention_page.dart';
import 'package:mirror/page/home/sub_page/recommend_page.dart';
import 'package:mirror/page/media_picker/media_picker_page.dart';
import 'package:mirror/page/search/search_page.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/round_underline_tab_indicator.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.controller}) : super(key: key);
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
    if (context.watch<FeedMapNotifier>().postFeedModel != null) {
      controller.index = 0;
    }
    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: CustomAppBar(
        leading: CustomAppBarIconButton(Icons.camera_alt_outlined, AppColor.black, true, () {
          print("${FluroRouter.appRouter.hashCode}");
          AppRouter.navigateToMediaPickerPage(context, 9, typeImageAndVideo, true, startPageGallery, false, (result) {},
              publishMode: 1);
        }),
        titleWidget: Container(
          width: 140,
          child: TabBar(
            controller: controller,
            tabs: [Text("关注"), Text("推荐")],
            labelStyle: TextStyle(fontSize: 18),
            labelColor: Colors.black,
            // indicatorPadding: EdgeInsets.symmetric(horizontal: 24),
            // unselectedLabelColor: Color.fromRGBO(153, 153, 153, 1),
            unselectedLabelStyle: TextStyle(fontSize: 16),
            indicator: RoundUnderlineTabIndicator(
              borderSide: BorderSide(
                width: 3,
                color: Color.fromRGBO(253, 137, 140, 1),
              ),
              insets: EdgeInsets.only(bottom: -6),
              wantWidth: 16,
            ),
          ),
        ),
        actions: [
          CustomAppBarIconButton(Icons.search, AppColor.black, false, () {
                print("${FluroRouter.appRouter.hashCode}");
            AppRouter.navigateSearchPage(context);
          }),
        ],
      ),
      body: TabBarView(
        controller: this.controller,
        children: [
          AttentionPage(
            postFeedModel: context.watch<FeedMapNotifier>().postFeedModel,
          ),
          RecommendPage()
          // RecommendPage()
        ],
      ),
    );
  }
}
