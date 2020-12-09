import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/course_model.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/page/home/sub_page/share_page/dynamic_list.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:provider/provider.dart';
FocusNode commentFocus = FocusNode();
enum LoadingStatus {
  //正在加载中
  STATUS_LOADING,
  //数据加载完成
  STATUS_COMPLETED,
  //空闲状态
  STATUS_IDEL,
}
// 加载中的布局
class LoadingView extends StatelessWidget {
  String loadText;
  LoadingStatus loadStatus;
  LoadingView({this.loadText,this.loadStatus});
  Widget _pad(Widget widget, {l,t,r,b}) {
    return Padding(padding: EdgeInsets.fromLTRB(l ??= 0.0, t ??= 0.0, r ??= 0.0, b ??= 0.0),child: widget,);
  }
  var loadingTs =TextStyle(color: AppColor.textHint,fontSize: 12);

  @override
  Widget build(BuildContext context) {
    var loadingText = _pad(
        Text(
          loadText,
          style: loadingTs,
        ),
        l: 20.0);
    var loadingIndicator = Visibility(
        visible: loadStatus == LoadingStatus.STATUS_LOADING ? true : false,
        child: SizedBox(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(AppColor.mainRed),
            // loading 大小
            strokeWidth:2,
          ),
          width: 12.0,
          height: 12.0,
        ));
    return _pad(
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            loadingIndicator,
            loadingText,
          ],
        ),
        b: 20.0);
  }
}

// 推荐
class RecommendPage extends StatefulWidget {
  RecommendPage({Key key, this.coverUrls, this.pc}) : super(key: key);
  PanelController pc = new PanelController();
  List<CourseModel> coverUrls = [];

  RecommendPageState createState() => RecommendPageState();
}

class RecommendPageState extends State<RecommendPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; //必须重写
  // 数据源
  List<HomeFeedModel> recommendModel = [];
  // 列表监听
  ScrollController _controller = new ScrollController();
  // 请求下一页
  int lastTime;
  // 加载中默认文字
  String loadText ="加载中...";
  // 加载状态
  LoadingStatus loadStatus = LoadingStatus.STATUS_IDEL;
  // 数据加载页数
  int dataPage =  1;
  @override
  void initState() {
    getRecommendFeed();
    _controller.addListener(() {
      if (_controller.position.pixels == _controller.position.maxScrollExtent) {
        dataPage +=1;
        getRecommendFeed();
      }
    });
    super.initState();
  }

  // 推荐页model
  getRecommendFeed() async {
    if (loadStatus == LoadingStatus.STATUS_IDEL) {
      // 先设置状态，防止下拉就直接加载
      setState(() {
        loadStatus = LoadingStatus.STATUS_LOADING;
      });
    }
    Map<String, dynamic> model = await getPullList(type: 1, size: 20, lastTime: lastTime);
    setState(() {
      if (dataPage == 1) {
        if (model["list"] != null) {
          model["list"].forEach((v) {
            recommendModel.add(HomeFeedModel.fromJson(v));
          });
        }
      } else if (dataPage > 1) {
        if (model["list"] != null) {
          model["list"].forEach((v) {
            recommendModel.add(HomeFeedModel.fromJson(v));
          });
        }
        loadStatus = LoadingStatus.STATUS_IDEL;
        loadText = "加载中...";
      }  else {
        // 加载完毕
        loadText = "已加载全部动态";
        loadStatus = LoadingStatus.STATUS_COMPLETED;
      }
    });
    lastTime = model["lastTime"];
  }

  @override
  Widget build(BuildContext context) {
    double screen_top = ScreenUtil.instance.statusBarHeight;
    final double bottomPadding = ScreenUtil.instance.bottomBarHeight;
    print("推荐页");
    return Stack(
      children: [
        Container(
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
                    recommendModel.clear();
                    loadStatus = LoadingStatus.STATUS_LOADING;
                    loadText = "加载中...";
                    Map<String, dynamic> model = await getPullList(type: 1, size: 20, lastTime: lastTime);
                    setState(() {
                      if (model["list"] != null) {
                        model["list"].forEach((v) {
                          recommendModel.add(HomeFeedModel.fromJson(v));
                        });
                      }
                    });
                  },
                  child: CustomScrollView(
                    controller: _controller,
                    // BouncingScrollPhysics
                   physics:
                   // ClampingScrollPhysics(),
                   AlwaysScrollableScrollPhysics() ,
                   // BouncingScrollPhysics(),
                    slivers: [
                      // 因为SliverList并不支持设置滑动方向由CustomScrollView统一管理，所有这里使用自定义滚动
                      // CustomScrollView要求内部元素为Sliver组件， SliverToBoxAdapter可包裹普通的组件。
                      // 横向滑动区域
                      SliverToBoxAdapter(
                        child: getCourse(),
                      ),
                      // 垂直列表
                      SliverList(
                        // controller: _controller,
                        delegate: SliverChildBuilderDelegate((content, index) {
                          // print("listSdadada");
                          // print(index);
                          // print(recommendModel.length);
                          if(index == recommendModel.length -1) {
                            return LoadingView(loadText: loadText,loadStatus:loadStatus ,);
                          } else {
                          return DynamicListLayout(
                              index: index,
                              pc: widget.pc,
                              model: recommendModel[index],
                              // 可选参数 子Item的个数
                              key: GlobalObjectKey("recommend$index"),
                              isShowRecommendUser: false);}
                        }, childCount: recommendModel.length),
                      )
                    ],
                  )
                ),

            )),
      ],
      // )
    );
  }

  // 课程横向布局
  getCourse() {
    return Container(
      margin: EdgeInsets.only(top: 24, bottom: 18),
      height: 93,
      child: ListView(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        children: widget.coverUrls.map((e) {
          var index = e.index;
          return Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.only(
                      left: index > 0 ? 24 : 16,
                      right: index == widget.coverUrls.length - 1 ? 16 : 0,
                      top: 0,
                      bottom: 8.5),
                  height: 53,
                  width: 53,
                  decoration: BoxDecoration(
                    // color: Colors.redAccent,
                    image: DecorationImage(image: NetworkImage(e.avatar), fit: BoxFit.cover),
                    // image
                    borderRadius: BorderRadius.all(Radius.circular(26.5)),
                  ),
                ),
                Container(
                  width: 53,
                  margin: EdgeInsets.only(
                      left: index > 0 ? 24 : 16,
                      right: index == widget.coverUrls.length - 1 ? 16 : 0,
                      top: 0,
                      bottom: 8.5),
                  child: Center(
                    child: Text(
                      "小课${index}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
