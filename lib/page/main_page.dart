import 'dart:core';
import 'package:flutter/material.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/api/message_api.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/data/model/machine_model.dart';
import 'package:mirror/data/model/training/live_video_mode.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:mirror/data/notifier/user_interactive_notifier.dart';
import 'package:mirror/page/home/home_page.dart';
import 'package:mirror/page/profile/profile_page.dart';
import 'package:mirror/page/message/message_page.dart';
import 'package:mirror/page/search/sub_page/should_build.dart';
import 'package:mirror/route/router.dart';
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
    EventBus.getDefault().registerSingleParameter(_getMachineStatusInfo,
        EVENTBUS_MAIN_PAGE,registerName: GET_MACHINE_STATUS_INFO);
  }

  @override
  void dispose() {
    super.dispose();
  }

  _feedUnreadCallBack(int unread) {
    _unReadFeedCount = unread;
  }

  List pages = [
    HomePage(key: homePageKey),
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
            Future.delayed(Duration.zero,(){
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
            if (homePageKey.currentState != null && index == 0) {
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

  _getMachineStatusInfo(MachineModel model){
    print("MachineModel:${model.toJson().toString()}");
    if(model!=null&&model.isConnect==1&&model.inGame==1){
      if(model.type==0){
        if(!AppRouter.isHaveMachineRemoteControllerPage()){
          List list = [];
          String modeType = mode_live;
          list.add(model.courseId);
          list.add(modeType);
          EventBus.getDefault().post(msg: list, registerName: START_TRAINING);
        }
      }
    }
  }
}
