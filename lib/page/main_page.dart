import 'dart:core';
import 'package:flutter/material.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/api/message_api.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/config/config.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:mirror/data/notifier/user_interactive_notifier.dart';
import 'package:mirror/page/home/home_page.dart';
import 'package:mirror/page/profile/profile_page.dart';
import 'package:mirror/page/message/message_page.dart';
import 'package:mirror/page/search/sub_page/should_build.dart';
import 'package:mirror/util/event_bus.dart';
import 'package:mirror/widget/if_tab_bar.dart';
import 'package:provider/provider.dart';
import 'profile/profile_page.dart';
import 'training/training_page.dart';

class MainPage extends StatefulWidget {
  MainPageState createState() => MainPageState();
}

class MainPageState extends XCState {
  int currentIndex;
  final pageController = PageController();

  //关注未读数
  int _unReadFeedCount = 0;

  @override
  void initState() {
    super.initState();
    currentIndex = 0;
  }

  @override
  void dispose() {
    super.dispose();
  }


  List pages = [
    HomePage(key: homePageKey),
    TrainingPage(),
    MessagePage(),
    ProfilePage(),
  ];

  _getFollowCount() async {
    ProfileFollowCount().then((attentionModel) {
      if (mounted && attentionModel != null) {
        context
            .read<UserInteractiveNotifier>()
            .changeAttentionModel(attentionModel, context.read<ProfileNotifier>().profile.uid);
      }
    });
  }

  _getUnReadFeedCount() {
    getUnReadFeedCount().then((value) {
      if (mounted && value != null && value != context.read<FeedMapNotifier>().value.unReadFeedCount) {
        context.read<FeedMapNotifier>().setUnReadFeedCount(value);
      }
    });
  }
  _getUnReadFansCount() {
    fansUnread().then((value) {
      if (mounted && value != null && value != context.read<UserInteractiveNotifier>().value.fansUnreadCount) {
        context.read<UserInteractiveNotifier>().changeUnreadFansCount(value);
      }
    });
  }
  @override
  Widget shouldBuild(BuildContext context) {
    print("MainPage_____________________________________________build");
    return Scaffold(
        bottomNavigationBar: IFTabBar(
          tabBarClickListener: (index) {
            int nowIndex = index;
            if(!AppConfig.needShowTraining){
              if(index==2&&currentIndex<2){
                nowIndex = nowIndex-1;
              }
              if(index<2&&currentIndex==2){
                nowIndex = nowIndex+1;
              }
            }
            if (currentIndex == index) {
              print("范慧慧");
              return;
            }
            print("跳转111111");
            if (pageController.hasClients) {
              print("跳转222222");
              if (nowIndex - currentIndex == 1 || currentIndex - nowIndex == 1) {
                pageController.animateToPage(index,
                    duration: Duration(milliseconds: 250), curve: Cubic(1.0, 1.0, 1.0, 1.0));
              } else{
                pageController.jumpToPage(index);
              }
              currentIndex = index;
            }
            if (_unReadFeedCount == 0) {
              _getUnReadFeedCount();
            }
            if(Application.appContext.read<UserInteractiveNotifier>().value.fansUnreadCount==0){
              _getUnReadFansCount();
            }
            Future.delayed(Duration.zero, () {
              getUnReads();
            });
            switch (index) {
              case 0:
                break;
              case 1:
                EventBus.getDefault().post(registerName: TRAINING_PAGE_GET_DATA);
                break;
              case 2:
                break;
              case 3:
                _getFollowCount();
                break;
            }
          },
          onDoubleTap: (index) {
            print("双击index：：${index} currentIndex:::$currentIndex");
            if (homePageKey.currentState != null && currentIndex == 0) {
              homePageKey.currentState.subpageRefresh(isBottomNavigationBar: true);
            }
            if (index == 0 && currentIndex != 0) {
              if (pageController.hasClients) {
                print("跳转222222");
                if (index - currentIndex == 1 || currentIndex - index == 1) {
                  pageController.animateToPage(index,
                      duration: Duration(milliseconds: 250), curve: Cubic(1.0, 1.0, 1.0, 1.0));
                } else {
                  pageController.jumpToPage(index);
                }
                currentIndex = index;
                EventBus.getDefault().post(msg: index,registerName: MAIN_PAGE_JUMP_PAGE);
              }
              if (_unReadFeedCount == 0) {
                _getUnReadFeedCount();
              }
              Future.delayed(Duration.zero, () {
                getUnReads();
              });
            }
          },
        ),
        body: PageView.builder(
          itemBuilder: (BuildContext context,int index) {
            return pages[index];
          },
          itemCount: 4,
          controller: pageController,
          // itemBuilder: SliverChildBuilderDelegate((BuildContext context, int index) {
          //   return pages[index];
          // }, childCount: 4),
          // 提前预加载当前pageView的下一个视图
          allowImplicitScrolling: true,
          physics: NeverScrollableScrollPhysics(), // 禁止滑动
        ));
  }
}
