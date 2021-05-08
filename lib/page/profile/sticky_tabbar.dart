

import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide TabBar;
import 'package:mirror/constant/color.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/customize_tab_bar/customize_tab_bar.dart';
///这个是个人主页实现吸顶TabBar的类
class StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar child;
  double width;
  StickyTabBarDelegate({@required this.child,this.width});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColor.white,
      padding: EdgeInsets.only(left: width/4,right: width/4),
      child: this.child,
      );
  }

  @override
  double get maxExtent =>this.child.preferredSize.height;

  @override
  double get minExtent =>this.child.preferredSize.height;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }

}
class fillingContainerDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  double height;
  Color color;
  fillingContainerDelegate({@required this.child,this.height,this.color});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent =>height;

  @override
  double get minExtent =>height;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }

}



