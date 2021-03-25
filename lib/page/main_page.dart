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

  @override
  void initState() {
    super.initState();
    currentIndex = 0;
  }

  @override
  void dispose() {
    super.dispose();
  }

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
      if (value != null) {
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
              return;
            }
            pageController.jumpToPage(index);
            currentIndex = index;
            if (context.read<FeedMapNotifier>().value.unReadFeedCount == 0) {
              _getUnReadFeedCount();
            }
            switch (index) {
              case 0:
                break;
              case 1:
                break;
              case 2:
                getUnReads();
                break;
              case 3:
                _getFollowCount();
                break;
            }
          },
        ),
        body: PageView(
          controller: pageController,
          children: [
            HomePage(),
            TrainingPage(),
            MessagePage(),
            ProfilePage(),
          ],
          physics: NeverScrollableScrollPhysics(), // 禁止滑动
        ));
  }
}
