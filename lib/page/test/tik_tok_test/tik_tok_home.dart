import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/page/message/message_page.dart';
import 'package:mirror/page/profile/profile_page.dart';
import 'package:mirror/page/test/tik_tok_test/camera_page.dart';
import 'package:mirror/page/test/tik_tok_test/custom_scroll_physices.dart';
import 'package:mirror/page/test/tik_tok_test/tik_tok_scaffold_controller.dart';
import 'package:mirror/page/test/tik_tok_test/tiktok_header.dart';
import 'package:mirror/page/test/tik_tok_test/tiktok_tabBar.dart';
import 'package:mirror/page/training/training_page.dart';

class TiktokHome extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<TiktokHome> with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  TikTokPageTag tabBarType = TikTokPageTag.home;

  TikTokScaffoldController tkController = TikTokScaffoldController();

  // taBar和TabBarView必要的
  TabController controller;
  // 是否禁用滑动
  bool isDisableSlide = false;
  @override
  void initState() {
    // TODO: implement initState
    controller = TabController(length: 2, vsync: this, initialIndex: 1);
  }
  @override
  Widget build(BuildContext context) {
    Widget currentPage;
    switch (tabBarType) {
      case TikTokPageTag.home:
        break;
      case TikTokPageTag.follow:
        currentPage =  TrainingPage();
        break;
      case TikTokPageTag.msg:
        currentPage =   MessagePage();
        break;
      case TikTokPageTag.me:
        currentPage = ProfilePage();
        break;
    }
    double a = MediaQuery.of(context).size.aspectRatio;
    bool hasBottomPadding = a < 0.55;

    bool hasBackground = hasBottomPadding;
    hasBackground = tabBarType != TikTokPageTag.home;
    if (hasBottomPadding) {
      hasBackground = true;
    }
    Widget tikTokTabBar = TikTokTabBar(
      hasBackground: hasBackground,
      current: tabBarType,
      onTabSwitch: (type) async {
        setState(() {
          tabBarType = type;
        });
      },
    );
    var cameraPage = CameraPage(
      onPop: tkController.animateToMiddle,
    );
    var header = tabBarType == TikTokPageTag.home
        ? TikTokHeader(
      controller: controller,
      onSearch: () {
        tkController.animateToLeft();
      },

    )
        : Container();
    return TikTokScaffold(
      controller: tkController,
      hasBottomPadding: hasBackground,
      tabBar: tikTokTabBar,
      header: header,
      leftPage: cameraPage,
      enableGesture: tabBarType == TikTokPageTag.home,
      cameraPageSlideCallBack: () {
        setState(() {
          isDisableSlide = false;
        });
      },
        middleSlideCallBack: () {
          setState(() {
            isDisableSlide = false;
          });
        },
      page:  Stack(
        children: [
          TabBarView(
            controller: controller,
            physics: isDisableSlide ? NeverScrollableScrollPhysics() : CustomScrollPhysics(overCallBack: (offset) {
              print('位移=' + offset.toString());
              if (controller.index == 0) {
                if (offset > 0.1) {
                  print(controller.index);
                  setState(() {
                    isDisableSlide = true;
                  });
                }
              }
            }),
            children: [
              Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                color: Colors.redAccent,
              ),
              Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                color: Colors.amber,
              )
              // RecommendPage()
            ],
          ),
          Opacity(
            opacity: 1,
            child: currentPage ?? Container(),
          ),
        ],
      )
    );
  }
}
