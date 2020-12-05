import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/ball_pulse_footer.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/database/token_db_helper.dart';
import 'package:mirror/data/model/course_model.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/page/home/sub_page/recommend_page.dart';
import 'package:mirror/page/home/sub_page/share_page/dynamic_list.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:mirror/data/notifier/token_notifier.dart';
import 'package:provider/provider.dart';

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

class AttentionPageState extends State<AttentionPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; //必须重写

  var status = Status.notLoggedIn;

  // 加载中默认文字
  String loadText = "加载中...";

  // 加载状态
  LoadingStatus loadStatus = LoadingStatus.STATUS_IDEL;

  // 数据加载页数
  int dataPage = 1;

  // 数据源
  List<HomeFeedModel> attentionModel = [];

  // 请求下一页
  int lastTime;

  // 列表监听
  ScrollController _controller = new ScrollController();

  @override
  void initState() {
    bool isLoggedIn = context.read<TokenNotifier>().isLoggedIn;
    print("是否登录$isLoggedIn");
    if (!isLoggedIn) {
      status = Status.notLoggedIn;
    } else {
      getRecommendFeed();
    }
    _controller.addListener(() {
      if (_controller.position.pixels == _controller.position.maxScrollExtent) {
        dataPage += 1;
        getRecommendFeed();
      }
    });
    super.initState();
  }

  // // 推荐页model
// 推荐页model
  getRecommendFeed() async {
    if (loadStatus == LoadingStatus.STATUS_IDEL) {
      // 先设置状态，防止下拉就直接加载
      setState(() {
        loadStatus = LoadingStatus.STATUS_LOADING;
      });
    }
    Map<String, dynamic> model = await getPullList(type: 0, size: 20, lastTime: lastTime);
    setState(() {
      if (dataPage == 1) {
        if (model["list"] != null) {
          model["list"].forEach((v) {
            attentionModel.add(HomeFeedModel.fromJson(v));
          });
          attentionModel.insert(0, HomeFeedModel());
          status = Status.concern;
          print("数据长度${attentionModel.length}");
        } else {
          status = Status.noConcern;
        }
      } else if (dataPage > 1 && model["lastTime"] != null) {
        print("5data");
        if (model["list"] != null) {
          model["list"].forEach((v) {
            attentionModel.add(HomeFeedModel.fromJson(v));
          });
          print("数据长度${attentionModel.length}");
        }
        loadStatus = LoadingStatus.STATUS_IDEL;
        loadText = "加载中...";
      } else {
        // 加载完毕
        loadText = "加载完毕";
        loadStatus = LoadingStatus.STATUS_COMPLETED;
      }
    });
    lastTime = model["lastTime"];
  }

  Widget pageDisplay(
    double bottomPadding,
  ) {
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
            child: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification notification) {
            ScrollMetrics metrics = notification.metrics;
            // 注册通知回调
            if (notification is ScrollStartNotification) {
              // 滚动开始
              // print('滚动开始');
            } else if (notification is ScrollUpdateNotification) {
              // 滚动位置更新
              // print('滚动位置更新');
              // 当前位置
              // print("当前位置${metrics.pixels}");
            } else if (notification is ScrollEndNotification) {
              // 滚动结束
              // print('滚动结束');
            }
          },
          child: RefreshIndicator(
            onRefresh: () async {
              dataPage = 1;
              attentionModel.clear();
              loadStatus = LoadingStatus.STATUS_LOADING;
              loadText = "加载中...";
              Map<String, dynamic> model = await getPullList(type: 0, size: 20, lastTime: lastTime);
              setState(() {
                if (model["list"] != null) {
                  model["list"].forEach((v) {
                    attentionModel.add(HomeFeedModel.fromJson(v));
                  });
                  attentionModel.insert(0, HomeFeedModel());
                  print("数据长度${attentionModel.length}");
                }
              });
            },
            child: MediaQuery.removePadding(
              removeTop: true,
              context: context,
              child: ListView.builder(
                  itemCount: attentionModel.length,
                  controller: _controller,
                  itemBuilder: (context, index) {
                    if(index == attentionModel.length  && lastTime != null) {
                      return LoadingView(loadText: loadText,loadStatus:loadStatus ,);
                    } else {
                        return index == 0
                        ? Container(
                            height: 14,
                          )
                        : DynamicListLayout(
                            index: index,
                            pc: widget.pc,
                            isShowRecommendUser: true,
                            model:attentionModel[index] ,
                            // 可选参数 子Item的个数
                            key: GlobalObjectKey("attention$index"));}
                  }),
            )
            // child: SliverList(
            //
            //   delegate: SliverChildBuilderDelegate(
            //     (context, index) {
            //       return DynamicListLayout(
            //           index: index,
            //           pc: widget.pc,
            //           isShowRecommendUser: true,
            //           model: attentionModel[index],
            //           // 可选参数 子Item的个数
            //           key: GlobalObjectKey("attention$index"));
            //     },
            //     childCount: attentionModel.length,
            //   ),
            // ),
          ),


        ));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = ScreenUtil.instance.bottomBarHeight;
    return pageDisplay(bottomPadding);
  }
}
