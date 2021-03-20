import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/text_util.dart';

/// IFTabBar
/// Created by yangjiayi on 2021/3/20.

class IFTabBar extends StatefulWidget {
  @override
  _IFTabBarState createState() => _IFTabBarState();
}

class _IFTabBarState extends State<IFTabBar> {
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
  double iconMargin = 32;
  double selectedButtonMargin = 16;

  //选中后按钮图标和字的间距
  double selectedButtonSpace = 8;

  //选中后按钮文字样式
  TextStyle selectedButtonTextStyle = const TextStyle(color: AppColor.white, fontSize: 15);

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

  //选中的按钮在的位置左边距
  double leftMarginSelectedButton;

  //将4个tab选中情况的位置算出后直接放入4个list中方便使用，顺序为leftMarginIcon1到4然后是leftMarginSelectedButton
  List<double> leftMarginList1 = [];
  List<double> leftMarginList2 = [];
  List<double> leftMarginList3 = [];
  List<double> leftMarginList4 = [];

  @override
  void initState() {
    super.initState();
    screenWidth = ScreenUtil.instance.screenWidthDp;
    selectedButtonTextWidth = calculateTextWidth("首页", selectedButtonTextStyle, screenWidth, 1).size.width;
    selectedButtonPadding = (selectedButtonWidth - iconSize - selectedButtonSpace - selectedButtonTextWidth) / 2;
    innerPaddingBig = (screenWidth - iconSize * 3 - selectedButtonWidth - iconMargin - selectedButtonMargin) / 3;
    innerPaddingSmall = (screenWidth - iconSize * 3 - selectedButtonWidth - iconMargin * 2 - innerPaddingBig) / 2;

    calculateLeftMargin(0);
    leftMarginList1.add(leftMarginIcon1);
    leftMarginList1.add(leftMarginIcon2);
    leftMarginList1.add(leftMarginIcon3);
    leftMarginList1.add(leftMarginIcon4);
    leftMarginList1.add(leftMarginSelectedButton);
    leftMarginText1 = leftMarginSelectedButton + selectedButtonPadding + iconSize + selectedButtonSpace;
    calculateLeftMargin(1);
    leftMarginList2.add(leftMarginIcon1);
    leftMarginList2.add(leftMarginIcon2);
    leftMarginList2.add(leftMarginIcon3);
    leftMarginList2.add(leftMarginIcon4);
    leftMarginList2.add(leftMarginSelectedButton);
    leftMarginText2 = leftMarginSelectedButton + selectedButtonPadding + iconSize + selectedButtonSpace;
    calculateLeftMargin(2);
    leftMarginList3.add(leftMarginIcon1);
    leftMarginList3.add(leftMarginIcon2);
    leftMarginList3.add(leftMarginIcon3);
    leftMarginList3.add(leftMarginIcon4);
    leftMarginList3.add(leftMarginSelectedButton);
    leftMarginText3 = leftMarginSelectedButton + selectedButtonPadding + iconSize + selectedButtonSpace;
    calculateLeftMargin(3);
    leftMarginList4.add(leftMarginIcon1);
    leftMarginList4.add(leftMarginIcon2);
    leftMarginList4.add(leftMarginIcon3);
    leftMarginList4.add(leftMarginIcon4);
    leftMarginList4.add(leftMarginSelectedButton);
    leftMarginText4 = leftMarginSelectedButton + selectedButtonPadding + iconSize + selectedButtonSpace;
  }

  @override
  Widget build(BuildContext context) {
    //用各get方法来获取当前index时的位置
    return Container();
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

  calculateLeftMargin(int index) {
    //根据所选按钮的index计算各位置
    switch (index) {
      case 0: //首页
        leftMarginIcon1 = iconMargin;
        leftMarginIcon2 = leftMarginIcon1 + iconSize + innerPaddingBig;
        leftMarginIcon3 = leftMarginIcon2 + iconSize + innerPaddingBig;
        leftMarginSelectedButton = leftMarginIcon3 + iconSize + innerPaddingBig;
        leftMarginIcon4 = leftMarginSelectedButton + selectedButtonPadding;
        break;
      case 1: //训练
        leftMarginIcon1 = iconMargin;
        leftMarginIcon2 = leftMarginIcon1 + iconSize + innerPaddingBig;
        leftMarginSelectedButton = leftMarginIcon2 + iconSize + innerPaddingSmall;
        leftMarginIcon3 = leftMarginSelectedButton + selectedButtonPadding;
        leftMarginIcon4 = leftMarginSelectedButton + selectedButtonWidth + innerPaddingSmall;
        break;
      case 2: //消息
        leftMarginIcon1 = iconMargin;
        leftMarginSelectedButton = leftMarginIcon1 + iconSize + innerPaddingSmall;
        leftMarginIcon2 = leftMarginSelectedButton + selectedButtonPadding;
        leftMarginIcon3 = leftMarginSelectedButton + selectedButtonWidth + innerPaddingSmall;
        leftMarginIcon4 = leftMarginIcon3 + iconSize + innerPaddingBig;
        break;
      case 3: //我的
        leftMarginSelectedButton = selectedButtonMargin;
        leftMarginIcon1 = leftMarginSelectedButton + selectedButtonPadding;
        leftMarginIcon2 = leftMarginSelectedButton + selectedButtonWidth + innerPaddingBig;
        leftMarginIcon3 = leftMarginIcon2 + iconSize + innerPaddingBig;
        leftMarginIcon4 = leftMarginIcon3 + iconSize + innerPaddingBig;
        break;
    }
  }
}
