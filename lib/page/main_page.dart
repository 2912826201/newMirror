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
  bool isInit = false;
  List titles = ["首页", "训练", "消息", "我的"];
  List<Widget> normalIcons = [];
  List<Widget> selectedIcons = [];
  double _start = 0;

  @override
  void initState() {
    super.initState();
    currentIndex = 0;
    _start = (ScreenUtil.instance.width / 5) / 7;
    EventBus.getDefault().registerNoParameter(_postFeedCallBack, EVENTBUS_MAIN_PAGE, registerName: EVENTBUS_POSTFEED_CALLBACK);
  }

  void _postFeedCallBack() {
    print('--------------广播监听回调');
    reload(() {
      _start = (ScreenUtil.instance.width / 5) / 7;
      currentIndex = 0;
    });
  }

  @override
  void dispose() {
    // controller.dispose();
    super.dispose();
    /* EventBus.getDefault().unRegister(registerName:EVENTBUS_POSTFEED_CALLBACK,pageName:EVENTBUS_MAIN_PAGE);*/
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
    double itemWidth = MediaQuery.of(context).size.width / 5;
    // print("初始创建底部页");
    // print(ScreenUtil.instance.bottomBarHeight);
    // return ChangeNotifierProvider(
    //     create: (_) => ReleaseProgressNotifier(plannedSpeed: 0.0),
    // builder: (context, _) {
    // return ChangeNotifierProvider(
    //   create: (_) => ReleaseProgressNotifier(plannedSpeed: 0.0),
    //   builder: (context, _) {
    return Scaffold(
      // 此属性是重新计算布局空间大小
      // 内部元素要监听键盘高度必需要设置为false,
      // resizeToAvoidBottomInset: true,
      bottomNavigationBar: IFTabBar(
        tabBarClickListener: (index) {
          if (currentIndex == index) {
            return;
          }
          print('------------------------点击回调$index');
          reload(() {
            currentIndex = index;
          });
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
      // SlidingUpPanel
      body:
          // pages[currentIndex]
          Stack(
        children: <Widget>[
          new Offstage(
            offstage: currentIndex != 0, //这里控制
            child: HomePage(),
          ),
          new Offstage(
            offstage: currentIndex != 1, //这里控制
            child: TrainingPage(),
          ),
          new Offstage(
            offstage: currentIndex != 2, //这里控制
            child: context.watch<TokenNotifier>().isLoggedIn ? MessagePage() : Container(),
          ),
          new Offstage(
            offstage: currentIndex != 3, //这里控制
            child: context.watch<TokenNotifier>().isLoggedIn ? ProfilePage() : Container(),
          ),
        ],
      ),
      // returnView(currentIndex),
    );
    //   },
    // );
  }
}

// 底部bottomNavigationBar item点击监听。
class SelectedbottomNavigationBarNotifier extends ChangeNotifier {
  SelectedbottomNavigationBarNotifier(this.selectedIndex);

  int selectedIndex;

  changeIndex(int index) {
    print("changeIndex $index");
    this.selectedIndex = index;
    //控制panel的控制器对象
    notifyListeners();
  }
}
