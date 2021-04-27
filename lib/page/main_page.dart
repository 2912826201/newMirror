import 'dart:async';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/api/message_api.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:mirror/data/notifier/token_notifier.dart';
import 'package:mirror/data/notifier/user_interactive_notifier.dart';
import 'package:mirror/page/home/home_page.dart';
import 'package:mirror/page/profile/profile_page.dart';
import 'package:mirror/page/message/message_page.dart';
import 'package:mirror/page/search/sub_page/should_build.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/click_util.dart';
import 'package:mirror/util/event_bus.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/icon.dart';
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

  _feedUnreadCallBack(int unread) {
    _unReadFeedCount = unread;
  }

  List pages = [
    HomePage(key:homePageKey),
    TrainingPage(),
    MessagePage(),
    ProfilePage(),
  ];

  _getFollowCount() async {
    ProfileFollowCount().then((attentionModel) {
      if (attentionModel != null) {
        context
            .read<UserInteractiveNotifier>()
            .changeAttentionModel(attentionModel, context.read<ProfileNotifier>().profile.uid);
      }
    });
  }

  _getUnReadFeedCount() {
    getUnReadFeedCount().then((value) {
      if (value != null && value != context.read<FeedMapNotifier>().value.unReadFeedCount) {
        context.read<FeedMapNotifier>().setUnReadFeedCount(value);
      }
    });
  }

  @override
  Widget shouldBuild(BuildContext context) {
    print("MainPage_____________________________________________build");
    return Scaffold(
        bottomNavigationBar: IFTabBar(
          tabBarClickListener: (index) {
            if (currentIndex == index) {
              print("范慧慧");
              return;
            }
            print("跳转111111");
            if (pageController.hasClients) {
              print("跳转222222");
              pageController.jumpToPage(index);
              currentIndex = index;
            }
            if (_unReadFeedCount == 0) {
              _getUnReadFeedCount();
            }
            getUnReads();
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
            if(homePageKey.currentState != null) {
              homePageKey.currentState.subpageRefresh();
            }
          },
        ),
        body: PageView.custom(
          controller: pageController,
          childrenDelegate: SliverChildBuilderDelegate((BuildContext context, int index) {
            return pages[index];
          }, childCount: 4),
            // 提前预加载当前pageView的下一个视图
          allowImplicitScrolling: true,
          physics: NeverScrollableScrollPhysics(), // 禁止滑动
        ));
  }
}
