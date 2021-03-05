import 'package:flutter/material.dart';
import 'package:mirror/api/message_api.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/profile/profile_model.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:mirror/data/notifier/release_progress_notifier.dart';
import 'package:mirror/data/notifier/token_notifier.dart';
import 'package:mirror/page/home/home_page.dart';
import 'package:mirror/page/if_page.dart';
import 'package:mirror/page/profile/profile_detail_page.dart';
import 'package:mirror/page/profile/profile_page.dart';
import 'package:mirror/page/message/message_page.dart';
import 'package:mirror/page/search/sub_page/should_build.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/screen_util.dart';
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
  List normalImgUrls = [
    "images/test/home-filling1.png",
    "images/test/work-filling.png",
    'images/test/comment-filling.png',
    'images/test/user-filling.png'
  ];
  List selectedImgUrls = [
    "images/test/home-filling.png",
    "images/test/work-filling1.png",
    "images/test/comment-filling1.png",
    "images/test/user-filling1.png",
  ];
  double _start = 0;

  @override
  void initState() {
    super.initState();
    currentIndex = 0;
    _start = (ScreenUtil.instance.width / 5) / 7;
  }

  @override
  void dispose() {
    // controller.dispose();
    super.dispose();
  }

  // @override
  // Widget build(BuildContext context) {
  //   print("MainPage_____________________________________________build");
  //   double itemWidth = MediaQuery.of(context).size.width / 5;
  //   // print("初始创建底部页");
  //   // print(ScreenUtil.instance.bottomBarHeight);
  //   return Scaffold(
  //     // 此属性是重新计算布局空间大小
  //     // 内部元素要监听键盘高度必需要设置为false,
  //     // resizeToAvoidBottomInset: true,
  //     bottomNavigationBar: BottomAppBar(
  //         child: Stack(
  //       children: <Widget>[
  //         AnimatedPositionedDirectional(
  //           top: 9,
  //           start: _start,
  //           width: itemWidth,
  //           height: 32,
  //           duration: Duration(milliseconds: 300),
  //           child: Container(
  //             decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: AppColor.black),
  //           ),
  //         ),
  //         Row(children: [
  //           Expanded(
  //             child: SizedBox(height: 51, width: itemWidth, child: tabbar(0, context,itemWidth)),
  //             flex: 1,
  //           ),
  //           Expanded(
  //             child: SizedBox(height: 51, width: itemWidth, child: tabbar(1, context,itemWidth)),
  //             flex: 1,
  //           ),
  //           Expanded(
  //             child: SizedBox(height: 51, width: itemWidth, child: tabbar(2, context,itemWidth)),
  //             flex: 1,
  //           ),
  //           Expanded(
  //             child: SizedBox(height: 51, width: itemWidth, child: tabbar(3, context,itemWidth)),
  //             flex: 1,
  //           )
  //         ])
  //       ],
  //     )),
  //     // SlidingUpPanel
  //     body:
  //     // pages[currentIndex]
  //     Stack(
  //       children: <Widget>[
  //         new Offstage(
  //           offstage: currentIndex != 0, //这里控制
  //           child: HomePage(),
  //         ),
  //         new Offstage(
  //           offstage: currentIndex != 1, //这里控制
  //           child: TrainingPage(),
  //         ),
  //         new Offstage(
  //           offstage: currentIndex != 2, //这里控制
  //           child: context.watch<TokenNotifier>().isLoggedIn ? MessagePage() : Container(),
  //         ),
  //         new Offstage(
  //           offstage: currentIndex != 3, //这里控制
  //           child: context.watch<TokenNotifier>().isLoggedIn ? ProfilePage() : Container(),
  //         ),
  //       ],
  //     ),
  //     // returnView(currentIndex),
  //   );
  // }
  _getFollowCount() async {
    ProfileModel attentionModel = await ProfileFollowCount();
    if (attentionModel != null) {
      print('  666666666666666666666666666666666666${attentionModel.toJson().toString()}');
      context
          .read<ProfilePageNotifier>()
          .changeAttentionModel(attentionModel, context.read<ProfileNotifier>().profile.uid);
    }
  }

  // 自定义BottomAppBar
  Widget tabbar(int index, BuildContext context, double itemWidth) {
    //设置默认未选中的状态
    TextStyle style = TextStyle(fontSize: 15, color: Colors.black);
    String imgUrl = normalImgUrls[index];
    if (currentIndex == index) {
      //选中的话
      style = TextStyle(fontSize: 15, color: Colors.white);
      imgUrl = selectedImgUrls[index];
    }
    //构造返回的Widget
    Widget item(BuildContext context) {
      return Container(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: EdgeInsets.only(top: 2, bottom: 2, left: 7.5, right: 7.5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(imgUrl, width: 28, height: 28),
                    Container(
                        margin: const EdgeInsets.only(left: 6),
                        child: Offstage(
                          offstage: currentIndex != index,
                          child: Text(
                            titles[index],
                            style: style,
                          ),
                        ))
                  ],
                ),
                // ),
              ),
              onTap: () {
                if ((index == 2 || index == 3) && !context.read<TokenNotifier>().isLoggedIn) {
                  AppRouter.navigateToLoginPage(context);
                } else {
                  context.read<SelectedbottomNavigationBarNotifier>().changeIndex(index);
                  if (currentIndex != index) {
                    reload(() {
                      currentIndex = index;
                      if (index == 0) {
                        _start = itemWidth / 7;
                      }
                      if (index == 1) {
                        _start = itemWidth + itemWidth * 0.4;
                      }
                      if (index == 2) {
                        //在切换到消息页时 请求未读互动通知数
                        getUnReads();
                        _start = 2 * itemWidth + itemWidth * 0.64;
                      }
                      if (index == 3) {
                        //切换到我的页时刷新关注数
                        _getFollowCount();
                        _start = 3 * itemWidth + itemWidth * 0.9;
                      }
                    });
                  }
                }
              },
            ),
          ],
        ),
      );
    }

    return item(context);
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
    return ChangeNotifierProvider(
      create: (_) => ReleaseProgressNotifier(plannedSpeed: 0.0),
      builder: (context, _) {
        return Scaffold(
          // 此属性是重新计算布局空间大小
          // 内部元素要监听键盘高度必需要设置为false,
          // resizeToAvoidBottomInset: true,
          bottomNavigationBar: BottomAppBar(
              child: Stack(
            children: <Widget>[
              AnimatedPositionedDirectional(
                top: 9,
                start: _start,
                width: itemWidth,
                height: 32,
                duration: Duration(milliseconds: 300),
                child: Container(
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: AppColor.black),
                ),
              ),
              Row(children: [
                Expanded(
                  child: SizedBox(height: 51, width: itemWidth, child: tabbar(0, context, itemWidth)),
                  flex: 1,
                ),
                Expanded(
                  child: SizedBox(height: 51, width: itemWidth, child: tabbar(1, context, itemWidth)),
                  flex: 1,
                ),
                Expanded(
                  child: SizedBox(height: 51, width: itemWidth, child: tabbar(2, context, itemWidth)),
                  flex: 1,
                ),
                Expanded(
                  child: SizedBox(height: 51, width: itemWidth, child: tabbar(3, context, itemWidth)),
                  flex: 1,
                )
              ])
            ],
          )),
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
      },
    );
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
