
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/data/model/live_model.dart';
import 'package:mirror/widget/no_blue_effect_behavior.dart';

import 'live_broadcast_item_page.dart';
import 'live_broadcast_title_page.dart';

/// 直播日程页
class LiveBroadcastPage extends StatefulWidget {
  //todo 先这样实现---以后再改为路由
  static LiveModel liveModel;

  @override
  createState() => new LiveBroadcastPageState();
}

class LiveBroadcastPageState extends State<LiveBroadcastPage> {
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
        duration: Duration(milliseconds: 200), curve: Curves.easeInOut);
  }

  void _pageChange(int pos) {
    if (pageCall != null) {
      pageCall(pos);
    }
  }

  @override
  Widget build(BuildContext context) {
    getTopCalendarDate();

    return Scaffold(
      appBar: null,
      body: _buildSuggestions(),
    );
  }

  Widget _buildSuggestions() {
    return Column(
      children: [
        SizedBox(height: 40,),
        _getTitleBar(),
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
    );
  }

  //头部bar
  Widget _getTitleBar() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 30,
      child: Stack(
        children: [
          Positioned(
            child: GestureDetector(
              child: Container(
                height: 30,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_back_ios_rounded,
                      size: 22,
                      color: Colors.black,
                    )
                  ],
                ),
              ),
              onTap: () {
                Navigator.of(context).pop("1");
              },
            ),
            left: 16,
          ),
          Container(
              width: double.infinity,
              child: Container(
                height: 30,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "直播课",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              )),
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


class BodyPage extends StatelessWidget {

  List<DateTime> dates;
  PageController controller;
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
