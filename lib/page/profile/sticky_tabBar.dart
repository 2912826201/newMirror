

import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
///这个是个人主页实现吸顶TabBar的类
class StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar child;
  double width;

  StickyTabBarDelegate({@required this.child,this.width});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColor.white,
      padding: EdgeInsets.only(left: width*0.25,right: width*0.25),
      child: this.child,);
  }

  @override
  double get maxExtent => this.child.preferredSize.height;

  @override
  double get minExtent => this.child.preferredSize.height;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }

}


