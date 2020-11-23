import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/course_model.dart';
import 'package:mirror/page/home/sub_page/recommend_page.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

enum Status {
  notLoggedIn, //未登录
  noConcern, //无关注
  concern // 关注
}

// 关注
class AttentionPage extends StatefulWidget {
  AttentionPage({Key key, this.coverUrls, this.pc}) : super(key: key);
  List<CourseModel> coverUrls = [];
  PanelController pc = new PanelController();

  AttentionPageState createState() => AttentionPageState();
}

class AttentionPageState extends State<AttentionPage> with AutomaticKeepAliveClientMixin{

  @override
  bool get wantKeepAlive => true; //必须重写

  var status = Status.notLoggedIn;

  @override
  void initState() {
    status = Status.concern;
    super.initState();
  }

  Widget pageDisplay(double bottomPadding) {
    switch (status) {
      case Status.notLoggedIn:
        return Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 224,
                height: 224,
                color: AppColor.color246,
                margin: EdgeInsets.only(bottom: 16, top: 150),
              ),
              Text(
                "登录账号后查看你关注的精彩内容",
                style: TextStyle(fontSize: 14, color: AppColor.textSecondary),
              ),
              Container(
                width: 293,
                height: 44,
                color: Colors.black,
                margin: EdgeInsets.only(top: 32),
                child: Center(
                  child: Text(
                    "Login",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              )
            ],
          ),
        );
        break;
      case Status.noConcern:
        return Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 224,
                height: 224,
                color: AppColor.color246,
                margin: EdgeInsets.only(bottom: 16, top: 188),
              ),
              Text(
                "这里空空如也，去推荐看看吧",
                style: TextStyle(fontSize: 14, color: AppColor.textSecondary),
              ),
            ],
          ),
        );
        break;
      case Status.concern:
        return Container(
            // margin: EdgeInsets.only(bottom:115),
            margin: EdgeInsets.only(bottom: 51 + bottomPadding),
            // color: Colors.orange,
            child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification notification) {
                  ScrollMetrics metrics = notification.metrics;
                  // 注册通知回调
                  if (notification is ScrollStartNotification) {
                    // 滚动开始
                    print('滚动开始');
                  } else if (notification is ScrollUpdateNotification) {
                    // 滚动位置更新
                    print('滚动位置更新');
                    // 当前位置
                    print("当前位置${metrics.pixels}");
                  } else if (notification is ScrollEndNotification) {
                    // 滚动结束
                    print('滚动结束');
                  }
                },
                child: MediaQuery.removePadding(
                  removeTop: true,
                  context: context,
                  child: ListView.builder(
                      itemCount: 19,
                      itemBuilder: (context, index) {
                        return index == 0 ? Container(height: 14,) : recommendListLayout(
                            index: index,
                            pc: widget.pc,
                            isShowRecommendUser: true,
                            // 可选参数 子Item的个数
                            key: GlobalObjectKey("attention$index"));
                      }),
                )));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    print("关注页");
    double screen_top = ScreenUtil.instance.statusBarHeight;
    final double bottomPadding = ScreenUtil.instance.bottomBarHeight;
    return pageDisplay(bottomPadding);
  }
}
