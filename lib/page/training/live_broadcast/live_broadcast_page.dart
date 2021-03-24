
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/page/search/sub_page/should_build.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/no_blue_effect_behavior.dart';

import 'live_broadcast_item_page.dart';
import 'live_broadcast_title_page.dart';
import 'live_room_video_page.dart';
import 'live_room_video_operation_page.dart';

/// 直播日程页--框架页
class LiveBroadcastPage extends StatefulWidget {

  @override
  createState() => new LiveBroadcastPageState();
}

class LiveBroadcastPageState extends XCState {
  //设置只能加载多少个日期
  var getDateNumber = 7;

  //所有加载数据的日期
  var stringDateList = <DateTime>[];

  //滑动的控制器
  PageController _pageController = PageController();
  void Function(int) pageCall;

  //title设置回来的回调  当body页面变化时，会调用参数中的函数，将结果传递到title界面
  void _pageChangedCall(void Function(int) call) {
    this.pageCall = call;
  }

  //标题被点击时回调  滚动body页面
  void _titleItemClickCall(int pos) {
    _pageController.animateToPage(pos,
        duration: Duration(milliseconds: 250), curve: Curves.easeInOut);
  }

  void _pageChange(int pos) {
    if (pageCall != null) {
      pageCall(pos);
    }
  }

  @override
  Widget shouldBuild(BuildContext context) {
    getTopCalendarDate();

    return Scaffold(
      appBar: CustomAppBar(
        hasDivider:false,
        titleString: "直播课",
      ),
      body: _buildSuggestions(),
    );
  }

  Widget _buildSuggestions() {
    return Container(
      color: AppColor.white,
      child: Column(
        children: [
          SizedBox(height: 10,),
          Container(
            width: double.infinity,
            child: LiveBroadcastTitlePage(
              stringDateList,
              setCall: _pageChangedCall,
              itemClick: _titleItemClickCall,
            ),
          ),
          SizedBox(height: 10,),
          Expanded(
              child: SizedBox(
                child: BodyPage(
                  dates: stringDateList,
                  controller: _pageController,
                  pageChangeCall: _pageChange,
                ),
              )
          )
        ],
      ),
    );
  }


  //设置头部日期数据
  void getTopCalendarDate() {
    var now = new DateTime.now();
    stringDateList.clear();
    for (int i = 0; i < getDateNumber; i++) {
      var fiftyDaysFromNow = now.add(new Duration(days: i));
      stringDateList.add(fiftyDaysFromNow);
    }
  }

}


// ignore: must_be_immutable
class BodyPage extends StatelessWidget {
  final List<DateTime> dates;
  final PageController controller;
  void Function(int) pageChangeCall;

  BodyPage({this.dates, this.controller, this.pageChangeCall});

  var pageViewItemList = <Widget>[];

  Widget _buildItemPage(int pos) {
    return pageViewItemList[pos];
  }

  @override
  Widget build(BuildContext context) {
    _getPageViewItemList();
    return ScrollConfiguration(
      behavior: NoBlueEffectBehavior(),
      child: PageView.builder(
          controller: controller,
          itemCount: dates.length,
          onPageChanged: pageChangeCall,
          itemBuilder: (context, pos) {
            return _buildItemPage(pos);
          }),
    );
  }

  //获取viewPager的item
  void _getPageViewItemList() {
    if (pageViewItemList.length < 1) {
      for (var value in dates) {
        pageViewItemList.add(LiveBroadcastItemPage(dataDate: value,));
      }
    }
  }
}
