import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mirror/config/config.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/feed/post_feed.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/data/notifier/token_notifier.dart';
import 'package:mirror/data/notifier/user_interactive_notifier.dart';
import 'package:mirror/im/message_manager.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/badger_util.dart';
import 'package:mirror/util/event_bus.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/text_util.dart';
import 'package:mirror/widget/icon.dart';
import 'package:provider/provider.dart';

import 'count_badge.dart';

/// IFTabBar
/// Created by yangjiayi on 2021/3/20.

class IFTabBar extends StatefulWidget {
  //单击事件
  final Function(int) tabBarClickListener;

  //双击事件
  final ValueChanged<int> onDoubleTap;

  IFTabBar({this.tabBarClickListener, this.onDoubleTap});

  @override
  _IFTabBarState createState() => _IFTabBarState();
}

//文字样式
const tabBarTextStyle = TextStyle(color: AppColor.mainBlack, fontSize: 15, fontWeight: FontWeight.w500);

class _IFTabBarState extends State<IFTabBar> {
  List<Widget> normalIcons = [];
  List<Widget> selectedIcons = [];

  //当前index 初始值设为0
  int currentIndex = 0;

  ///已知固定常量
  //高度
  double tabBarHeight = 48;

  //图标尺寸
  double iconSize = 24;

  //选中后的按钮尺寸
  double selectedButtonHeight = 32;
  double selectedButtonWidth = 90;

  //边距
  double iconMargin = AppConfig.needShowTraining ? 32 : 50;
  double selectedButtonMargin = AppConfig.needShowTraining ? 16 : 18;

  //选中后按钮图标和字的间距
  double selectedButtonSpace = 8;

  ///可得到的常量
  //屏幕宽
  double screenWidth;

  //选中后按钮文字宽度（2个汉字）
  double selectedButtonTextWidth;

  //选中后按钮图标和文字距两边的边距
  double selectedButtonPadding;

  //图标和图标及图标和选中按钮间的两种间距
  double innerPaddingBig;
  double innerPaddingSmall;

  ///需要计算得出的变量
  //各图标在的位置左边距
  double leftMarginIcon1;
  double leftMarginIcon2;
  double leftMarginIcon3;
  double leftMarginIcon4;

  //各文字在的位置左边距
  double leftMarginText1;
  double leftMarginText2;
  double leftMarginText3;
  double leftMarginText4;

  //各图标在的位置左边距
  double onClickWidth1;
  double onClickWidth2;
  double onClickWidth3;
  double onClickWidth4;

  //选中的按钮在的位置左边距
  double leftMarginSelectedButton;

  //将4个tab选中情况的位置算出后直接放入4个list中方便使用，顺序为leftMarginIcon1到4然后是leftMarginSelectedButton
  List<double> leftMarginList1 = [];
  List<double> leftMarginList2 = [];
  List<double> leftMarginList3 = [];
  List<double> leftMarginList4 = [];

  List<double> onClickWidthList1 = [];
  List<double> onClickWidthList2 = [];
  List<double> onClickWidthList3 = [];
  List<double> onClickWidthList4 = [];
  double selectedButtonTextHeight = 0;
  StreamController<int> streamController = StreamController<int>();
  int firstTapTime;
  int beforTapTab;

  @override
  void dispose() {
    super.dispose();
    // EventBus.getDefault().unRegister(pageName:EVENTBUS_MAIN_PAGE, registerName: EVENTBUS_POST_PORGRESS_VIEW);
    // EventBus.getDefault().unRegister(pageName:EVENTBUS_IF_TAB_BAR, registerName: EVENTBUS_IF_TAB_BAR_UNREAD);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      EventBus.getDefault()
          .registerSingleParameter(_postFeedCallBack, EVENTBUS_MAIN_PAGE, registerName: EVENTBUS_POST_PORGRESS_VIEW);
      EventBus.getDefault()
          .registerNoParameter(_resetUnreadMessage, EVENTBUS_IF_TAB_BAR, registerName: EVENTBUS_IF_TAB_BAR_UNREAD);
      EventBus.getDefault().registerSingleParameter(_jumpPage, EVENTBUS_MAIN_PAGE, registerName: MAIN_PAGE_JUMP_PAGE);
    });
    normalIcons.add(AppIcon.getAppIcon(AppIcon.if_home, 24, color: AppColor.white));
    normalIcons.add(AppIcon.getAppIcon(AppIcon.if_training, 24, color: AppColor.white));
    normalIcons.add(AppIcon.getAppIcon(AppIcon.if_message, 24, color: AppColor.white));
    normalIcons.add(AppIcon.getAppIcon(AppIcon.if_profile, 24, color: AppColor.white));

    selectedIcons.add(AppIcon.getAppIcon(AppIcon.if_home, 24, color: AppColor.mainBlack));
    selectedIcons.add(AppIcon.getAppIcon(AppIcon.if_training, 24, color: AppColor.mainBlack));
    selectedIcons.add(AppIcon.getAppIcon(AppIcon.if_message, 24, color: AppColor.mainBlack));
    selectedIcons.add(AppIcon.getAppIcon(AppIcon.if_profile, 24, color: AppColor.mainBlack));
    screenWidth = ScreenUtil.instance.screenWidthDp;
    Size textSize = calculateTextWidth("首页", tabBarTextStyle, screenWidth, 1).size;
    selectedButtonTextWidth = textSize.width;
    selectedButtonTextHeight = textSize.height;
    //已选中按钮中 图标和文字距离左右的边距
    selectedButtonPadding = (selectedButtonWidth - iconSize - selectedButtonSpace - selectedButtonTextWidth) / 2;
    //图标和图标的间距比较大
    innerPaddingBig = (screenWidth - iconSize * 3 - selectedButtonWidth - iconMargin - selectedButtonMargin) / 3;
    //选中框不在左右两边时，图标和选中框的间距比较小
    innerPaddingSmall = (screenWidth - iconSize * 3 - selectedButtonWidth - iconMargin * 2 - innerPaddingBig) / 2;

    //第一个按钮选中时的数值
    calculateLeftMargin(0);
    leftMarginList1.add(leftMarginIcon1);
    leftMarginList1.add(leftMarginIcon2);
    leftMarginList1.add(leftMarginIcon3);
    leftMarginList1.add(leftMarginIcon4);
    leftMarginList1.add(leftMarginSelectedButton);
    leftMarginText1 = leftMarginSelectedButton + selectedButtonPadding + iconSize + selectedButtonSpace;
    calculateOnClickWidth(0);
    onClickWidthList1.add(onClickWidth1);
    onClickWidthList1.add(onClickWidth2);
    onClickWidthList1.add(onClickWidth3);
    onClickWidthList1.add(onClickWidth4);
    //第二个按钮选中时的数值
    calculateLeftMargin(1);
    leftMarginList2.add(leftMarginIcon1);
    leftMarginList2.add(leftMarginIcon2);
    leftMarginList2.add(leftMarginIcon3);
    leftMarginList2.add(leftMarginIcon4);
    leftMarginList2.add(leftMarginSelectedButton);
    leftMarginText2 = leftMarginSelectedButton + selectedButtonPadding + iconSize + selectedButtonSpace;
    calculateOnClickWidth(1);
    onClickWidthList2.add(onClickWidth1);
    onClickWidthList2.add(onClickWidth2);
    onClickWidthList2.add(onClickWidth3);
    onClickWidthList2.add(onClickWidth4);
    //第三个按钮选中时的数值
    calculateLeftMargin(2);
    leftMarginList3.add(leftMarginIcon1);
    leftMarginList3.add(leftMarginIcon2);
    leftMarginList3.add(leftMarginIcon3);
    leftMarginList3.add(leftMarginIcon4);
    leftMarginList3.add(leftMarginSelectedButton);
    leftMarginText3 = leftMarginSelectedButton + selectedButtonPadding + iconSize + selectedButtonSpace;
    calculateOnClickWidth(2);
    onClickWidthList3.add(onClickWidth1);
    onClickWidthList3.add(onClickWidth2);
    onClickWidthList3.add(onClickWidth3);
    onClickWidthList3.add(onClickWidth4);
    //第四个按钮选中时的数值
    calculateLeftMargin(3);
    leftMarginList4.add(leftMarginIcon1);
    leftMarginList4.add(leftMarginIcon2);
    leftMarginList4.add(leftMarginIcon3);
    leftMarginList4.add(leftMarginIcon4);
    leftMarginList4.add(leftMarginSelectedButton);
    leftMarginText4 = leftMarginSelectedButton + selectedButtonPadding + iconSize + selectedButtonSpace;
    calculateOnClickWidth(3);
    onClickWidthList4.add(onClickWidth1);
    onClickWidthList4.add(onClickWidth2);
    onClickWidthList4.add(onClickWidth3);
    onClickWidthList4.add(onClickWidth4);
  }

  _postFeedCallBack(PostprogressModel postprogress) {
    widget.tabBarClickListener(0);
    print("几次");
    streamController.sink.add(0);
  }

  // // app界面id
  // class PageType {
  // static const int AttentionPage = 1;//关注页
  // static const int RecommendPage = 2;//推荐页
  // static const int TrainingPage= 3;//训练页
  // static const int MessagePage = 4;//消息页
  // static const int ProfilePage = 5;//我的页面
  // }

  _jumpPage(int pageIndex) {
    int pagePosition = -1;
    switch (pageIndex) {
      case 1: //关注页
      case 2: //推荐页
        pagePosition = 0;
        break;
      case 3: //训练页
        pagePosition = 1;
        break;
      case 4: //消息页
        pagePosition = 2;
        break;
      case 5: //我的页面
        pagePosition = 3;
        break;
      default:
        pagePosition = -1;
        break;
    }
    if (pagePosition >= 0) {
      if (widget.tabBarClickListener != null) {
        widget.tabBarClickListener(pagePosition);
      }
      if (streamController != null) {
        currentIndex = pagePosition;
        streamController.sink.add(pagePosition);
      }
    }
  }

  _resetUnreadMessage() {
    Future.delayed(Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          BadgerUtil.init().setBadgeCount();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    //用各get方法来获取当前index时的位置
    return StreamBuilder<int>(
        initialData: currentIndex,
        stream: streamController.stream,
        builder: (BuildContext stramContext, AsyncSnapshot<int> snapshot) {
          return
              // BottomAppBar(
              // child:
              Container(
            color: AppColor.mainBlack,
            height: tabBarHeight,
            width: screenWidth,
            child: Stack(
              children: [
                Center(
                  child: _animatedContainer(snapshot),
                ),
                Center(
                  child: _iconRow(snapshot),
                ),
                Center(
                  child: IgnorePointer(child: _textRow(snapshot)),
                ),
                _onClickRow(snapshot)
              ],
            ),
            // ),
          );
        });
  }

  _onClickListener(int index) {
    if ((index == 2 || index == 3) && !context.read<TokenNotifier>().isLoggedIn) {
      AppRouter.navigateToLoginPage(context);
      return;
    }
    print('------------------------点击');
    streamController.sink.add(index);
    widget.tabBarClickListener(index);
    currentIndex = index;
    setState(() {});
  }

  Widget _onClickRow(AsyncSnapshot<int> snapshot) {
    if (snapshot.data != 0) {
      beforTapTab = snapshot.data;
      firstTapTime = null;
    }
    return Container(
      width: screenWidth,
      height: tabBarHeight,
      child: Row(
        children: [
          InkWell(
            highlightColor: AppColor.transparent,
            radius: 0,
            onTap: () {
              if (beforTapTab != 0) {
                firstTapTime = null;
                beforTapTab = 0;
                _onClickListener(0);
                return;
              }
              if (firstTapTime == null) {
                firstTapTime = DateTime.now().millisecondsSinceEpoch;
              } else {
                if (DateTime.now().millisecondsSinceEpoch - firstTapTime <= 250) {
                  if (widget.onDoubleTap != null) {
                    widget.onDoubleTap(0);
                  }
                  firstTapTime = null;
                  return;
                } else {
                  firstTapTime = DateTime.now().millisecondsSinceEpoch;
                }
              }
              _onClickListener(0);
            },
            child: Container(
              width: getItemClickWidth(snapshot.data)[0],
              height: tabBarHeight,
            ),
          ),
          AppConfig.needShowTraining
              ? InkWell(
                  highlightColor: AppColor.transparent,
                  radius: 0,
                  onTap: () {
                    _onClickListener(1);
                  },
                  child: Container(
                    width: getItemClickWidth(snapshot.data)[1],
                    height: tabBarHeight,
                  ),
                )
              : Container(),
          InkWell(
            highlightColor: AppColor.transparent,
            radius: 0,
            onTap: () {
              _onClickListener(2);
            },
            child: Container(
              width: getItemClickWidth(snapshot.data)[2],
              height: tabBarHeight,
            ),
          ),
          InkWell(
              highlightColor: AppColor.transparent,
              radius: 0,
              onTap: () {
                _onClickListener(3);
              },
              child: Container(
                width: getItemClickWidth(snapshot.data)[3],
                height: tabBarHeight,
              )),
        ],
      ),
    );
  }

  Widget _animatedContainer(AsyncSnapshot<int> snapshot) {
    return Container(
      height: tabBarHeight,
      width: screenWidth,
      padding: EdgeInsets.only(top: (tabBarHeight - selectedButtonHeight) / 2),
      child: Stack(
        children: [
          AnimatedContainer(
            curve: const Cubic(0.1, 0.2, 0.2, 1.0),
            margin: EdgeInsets.only(left: getLeftMarginSelectedButton(snapshot.data)),
            duration: const Duration(milliseconds: 250),
            child: Container(
              height: 32,
              width: 90,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: AppColor.white),
            ),
          )
        ],
      ),
    );
  }

  Widget _iconRow(AsyncSnapshot<int> snapshot) {
    print('-------------------_iconRow');
    return Container(
      height: tabBarHeight,
      width: screenWidth,
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: EdgeInsets.only(left: getLeftMarginIcon1(snapshot.data)),
            child: Container(
              height: tabBarHeight,
              width: 80,
              alignment: Alignment.centerLeft,
              child: Container(
                width: 24,
                height: 24,
                child: Stack(
                  children: [
                    snapshot.data == 0 ? selectedIcons[0] : normalIcons[0],
                    Consumer<FeedMapNotifier>(builder: (context, notifier, child) {
                      return Positioned(
                          top: 0,
                          right: 0,
                          child: notifier.value.unReadFeedCount != 0
                              ? ClipOval(
                                  child: Container(
                                    height: 8,
                                    width: 8,
                                    color: AppColor.mainRed,
                                  ),
                                )
                              : Container());
                    })
                  ],
                ),
              ),
            ),
          ),
          AppConfig.needShowTraining
              ? AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: EdgeInsets.only(left: getLeftMarginIcon2(snapshot.data)),
                  child: Container(
                    height: tabBarHeight,
                    width: 80,
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 24,
                      height: 24,
                      child: snapshot.data == 1 ? selectedIcons[1] : normalIcons[1],
                    ),
                  ),
                )
              : Container(),
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: EdgeInsets.only(left: getLeftMarginIcon3(snapshot.data)),
            child: Container(
              height: tabBarHeight,
              width: 80,
              child: Stack(
                children: [
                  Positioned(
                    child: Container(
                      width: 24,
                      height: 24,
                      child: snapshot.data == 2 ? selectedIcons[2] : normalIcons[2],
                    ),
                    left: 0,
                    top: (tabBarHeight - 24) / 2,
                  ),
                  Visibility(
                    visible: currentIndex == 2
                        ? false
                        : MessageManager.unreadNoticeNumber + MessageManager.unreadMessageNumber < 1
                            ? false
                            : true,
                    child: Positioned(
                      child: CountBadge(MessageManager.unreadNoticeNumber + MessageManager.unreadMessageNumber, false),
                      left: 12,
                      top: (tabBarHeight - 24) / 2 - 7,
                    ),
                  )
                ],
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: EdgeInsets.only(left: getLeftMarginIcon4(snapshot.data)),
            child: Container(
              height: tabBarHeight,
              width: 80,
              alignment: Alignment.centerLeft,
              child: Container(
                  width: 24,
                  height: 24,
                  child: Stack(
                    children: [
                      snapshot.data == 3 ? selectedIcons[3] : normalIcons[3],
                      Consumer<UserInteractiveNotifier>(builder: (context, notifier, child) {
                        return Positioned(
                            top: 0,
                            right: 4,
                            child: notifier.value.fansUnreadCount > 0
                                ? ClipOval(
                                    child: Container(
                                      height: 8,
                                      width: 8,
                                      color: AppColor.mainRed,
                                    ),
                                  )
                                : Container());
                      })
                    ],
                  )),
            ),
          ),
        ],
      ),
    );
  }

  Widget _textRow(AsyncSnapshot<int> snapshot) {
    print('------------------------------textRow');
    return Container(
      height: selectedButtonTextHeight,
      width: screenWidth,
      child: Stack(
        children: [
          AnimatedOpacity(
            opacity: snapshot.data == 0 ? 1 : 0,
            duration: const Duration(milliseconds: 150),
            child: Container(
              margin: EdgeInsets.only(left: leftMarginText1),
              child: const Text(
                "首页",
                style: tabBarTextStyle,
              ),
            ),
          ),
          AppConfig.needShowTraining
              ? AnimatedOpacity(
                  opacity: snapshot.data == 1 ? 1 : 0,
                  duration: const Duration(milliseconds: 150),
                  child: Container(
                    margin: EdgeInsets.only(left: leftMarginText2),
                    child: const Text("训练", style: tabBarTextStyle),
                  ),
                )
              : Container(),
          AnimatedOpacity(
            opacity: snapshot.data == 2 ? 1 : 0,
            duration: const Duration(milliseconds: 150),
            child: Container(
              margin: EdgeInsets.only(left: leftMarginText3),
              child: const Text("消息", style: tabBarTextStyle),
            ),
          ),
          AnimatedOpacity(
            opacity: snapshot.data == 3 ? 1 : 0,
            duration: const Duration(milliseconds: 150),
            child: Container(
              margin: EdgeInsets.only(left: leftMarginText4),
              child: const Text("我的", style: tabBarTextStyle),
            ),
          ),
        ],
      ),
    );
  }

  getLeftMarginIcon1(int index) {
    switch (index) {
      case 0: //首页
        return leftMarginList1[0];
      case 1: //训练
        return leftMarginList2[0];
      case 2: //消息
        return leftMarginList3[0];
      case 3: //我的
        return leftMarginList4[0];
    }
  }

  getLeftMarginIcon2(int index) {
    switch (index) {
      case 0: //首页
        return leftMarginList1[1];
      case 1: //训练
        return leftMarginList2[1];
      case 2: //消息
        return leftMarginList3[1];
      case 3: //我的
        return leftMarginList4[1];
    }
  }

  getLeftMarginIcon3(int index) {
    switch (index) {
      case 0: //首页
        return leftMarginList1[2];
      case 1: //训练
        return leftMarginList2[2];
      case 2: //消息
        return leftMarginList3[2];
      case 3: //我的
        return leftMarginList4[2];
    }
  }

  getLeftMarginIcon4(int index) {
    switch (index) {
      case 0: //首页
        return leftMarginList1[3];
      case 1: //训练
        return leftMarginList2[3];
      case 2: //消息
        return leftMarginList3[3];
      case 3: //我的
        return leftMarginList4[3];
    }
  }

  getLeftMarginSelectedButton(int index) {
    switch (index) {
      case 0: //首页
        return leftMarginList1[4];
      case 1: //训练
        return leftMarginList2[4];
      case 2: //消息
        return leftMarginList3[4];
      case 3: //我的
        return leftMarginList4[4];
    }
  }

  List<double> getItemClickWidth(int index) {
    switch (index) {
      case 0:
        return onClickWidthList1;
      case 1:
        return onClickWidthList2;
      case 2:
        return onClickWidthList3;
      case 3:
        return onClickWidthList4;
    }
  }

  //计算图标及选中按钮距离左边的边距
  calculateLeftMargin(int index) {
    //根据所选按钮的index计算各位置
    //是否有训练按钮是两套方案 无法通过数据微调套用公式 所以完全分开写
    if (AppConfig.needShowTraining) {
      switch (index) {
        case 0: //首页
          leftMarginSelectedButton = selectedButtonMargin;
          leftMarginIcon1 = leftMarginSelectedButton + selectedButtonPadding;
          leftMarginIcon2 = leftMarginSelectedButton + selectedButtonWidth + innerPaddingBig;
          leftMarginIcon3 = leftMarginIcon2 + iconSize + innerPaddingBig;
          leftMarginIcon4 = leftMarginIcon3 + iconSize + innerPaddingBig;
          break;
        case 1: //训练
          leftMarginIcon1 = iconMargin;
          leftMarginSelectedButton = leftMarginIcon1 + iconSize + innerPaddingSmall;
          leftMarginIcon2 = leftMarginSelectedButton + selectedButtonPadding;
          leftMarginIcon3 = leftMarginSelectedButton + selectedButtonWidth + innerPaddingSmall;
          leftMarginIcon4 = leftMarginIcon3 + iconSize + innerPaddingBig;
          break;
        case 2: //消息
          leftMarginIcon1 = iconMargin;
          leftMarginIcon2 = leftMarginIcon1 + iconSize + innerPaddingBig;
          leftMarginSelectedButton = leftMarginIcon2 + iconSize + innerPaddingSmall;
          leftMarginIcon3 = leftMarginSelectedButton + selectedButtonPadding;
          leftMarginIcon4 = leftMarginSelectedButton + selectedButtonWidth + innerPaddingSmall;
          break;
        case 3: //我的
          leftMarginIcon1 = iconMargin;
          leftMarginIcon2 = leftMarginIcon1 + iconSize + innerPaddingBig;
          leftMarginIcon3 = leftMarginIcon2 + iconSize + innerPaddingBig;
          leftMarginSelectedButton = leftMarginIcon3 + iconSize + innerPaddingBig;
          leftMarginIcon4 = leftMarginSelectedButton + selectedButtonPadding;
          break;
      }
    } else {
      //训练按钮的数据写成和首页一样
      switch (index) {
        case 0: //首页
          leftMarginSelectedButton = selectedButtonMargin;
          leftMarginIcon1 = leftMarginSelectedButton + selectedButtonPadding;
          leftMarginIcon2 = leftMarginIcon1;
          leftMarginIcon3 = (ScreenUtil.instance.screenWidthDp - iconSize) / 2;
          leftMarginIcon4 = ScreenUtil.instance.screenWidthDp - iconMargin - iconSize;
          break;
        case 1: //训练 没有训练按钮所以不做重新计算
          break;
        case 2: //消息
          leftMarginIcon1 = iconMargin;
          leftMarginIcon2 = leftMarginIcon1;
          leftMarginSelectedButton = (ScreenUtil.instance.screenWidthDp - selectedButtonWidth) / 2;
          leftMarginIcon3 = leftMarginSelectedButton + selectedButtonPadding;
          leftMarginIcon4 = ScreenUtil.instance.screenWidthDp - iconMargin - iconSize;
          break;
        case 3: //我的
          leftMarginIcon1 = iconMargin;
          leftMarginIcon2 = leftMarginIcon1;
          leftMarginIcon3 = (ScreenUtil.instance.screenWidthDp - iconSize) / 2;
          leftMarginSelectedButton = ScreenUtil.instance.screenWidthDp - selectedButtonMargin - selectedButtonWidth;
          leftMarginIcon4 = leftMarginSelectedButton + selectedButtonPadding;
          break;
      }
    }
  }

  //计算响应点击事件的宽度
  calculateOnClickWidth(int index) {
    //是否有训练按钮是两套方案 无法通过数据微调套用公式 所以完全分开写
    if (AppConfig.needShowTraining) {
      switch (index) {
        case 0: //首页
          onClickWidth1 = selectedButtonWidth + selectedButtonMargin;
          onClickWidth2 = innerPaddingBig + iconSize + (innerPaddingBig / 2);
          onClickWidth3 = innerPaddingBig + iconSize;
          onClickWidth4 = (innerPaddingBig / 2) + iconSize + iconMargin;
          break;
        case 1: //训练
          onClickWidth1 = iconMargin + iconSize + innerPaddingSmall;
          onClickWidth2 = selectedButtonWidth;
          onClickWidth3 = innerPaddingSmall + iconSize + (innerPaddingBig / 2);
          onClickWidth4 = (innerPaddingBig / 2) + iconSize + iconMargin;
          break;
        case 2: //消息
          onClickWidth1 = iconMargin + iconSize + (innerPaddingBig / 2);
          onClickWidth2 = innerPaddingSmall + iconSize + (innerPaddingBig / 2);
          onClickWidth3 = selectedButtonWidth;
          onClickWidth4 = innerPaddingSmall + iconSize + iconMargin;
          break;
        case 3: //我的
          onClickWidth1 = iconMargin + iconSize + (innerPaddingBig / 2);
          onClickWidth2 = innerPaddingBig + iconSize;
          onClickWidth3 = iconSize + (innerPaddingBig / 2) + innerPaddingBig;
          onClickWidth4 = selectedButtonWidth + selectedButtonMargin;
          break;
      }
    } else {
      //全都是屏幕宽的1/3
      onClickWidth1 = ScreenUtil.instance.screenWidthDp / 3;
      onClickWidth2 = onClickWidth1;
      onClickWidth3 = onClickWidth1;
      onClickWidth4 = onClickWidth1;
    }
  }
}
