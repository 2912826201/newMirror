import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/constants.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/data_response_model.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/data/model/media_file_model.dart';
import 'package:mirror/data/model/feed/post_feed.dart';
import 'package:mirror/data/model/upload/upload_result_model.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/page/home/sub_page/recommend_page.dart';
import 'package:mirror/page/home/sub_page/share_page/dynamic_list.dart';
import 'package:mirror/page/profile/profile_detail_page.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/data/notifier/token_notifier.dart';
import 'package:mirror/util/string_util.dart';
import 'package:mirror/util/text_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/first_end_item_children_delegate.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

enum Status {
  notLoggedIn, //未登录
  loggedIn, // 登录
  noConcern, //无关注
  concern // 关注
}

enum PostStatus {
  publishing, //正在发布
  complete, // 发布完成
  fail, //发布失败
}

// 关注
class AttentionPage extends StatefulWidget {
  AttentionPage({Key key, this.postFeedModel}) : super(key: key);

  // 发布动态需要的数据
  PostFeedModel postFeedModel;

  AttentionPageState createState() => AttentionPageState();
}

GlobalKey<AttentionPageState> attentionKey = GlobalKey();

class AttentionPageState extends State<AttentionPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; //必须重写

  var status = Status.loggedIn;

  // 加载中默认文字
  String loadText = "";

  // 加载状态
  LoadingStatus loadStatus = LoadingStatus.STATUS_IDEL;

  // 数据加载页数
  int dataPage = 1;

  // 数据源
  List<int> attentionIdList = [];
  List<HomeFeedModel> attentionModelList = [];

  // 请求下一页
  int lastTime;

  // 列表监听
  ScrollController _controller = new ScrollController();

  // 是否登录
  bool isLoggedIn = false;

  // 是否请求接口
  bool isRequestInterface = false;

  // 声明定时器
  Timer timer;
  @override
  void initState() {
    print("初始化一下啊");
    isLoggedIn = context.read<TokenNotifier>().isLoggedIn;
    print("是否登录$isLoggedIn");
    if (!isLoggedIn) {
      status = Status.notLoggedIn;
    } else {
      getRecommendFeed();
    }

    // 上拉加载
    _controller.addListener(() {
      if (_controller.position.pixels == _controller.position.maxScrollExtent) {
        dataPage += 1;
        getRecommendFeed();
      }
    });
    super.initState();
  }



  // 请求关注接口
  getRecommendFeed() async {
    isRequestInterface = true;
    if (loadStatus == LoadingStatus.STATUS_IDEL) {
      // 先设置状态，防止下拉就直接加载
      setState(() {
        loadStatus = LoadingStatus.STATUS_LOADING;
      });
    }
    print("postFeedModel%%%%%%%$widget.postFeedModel");
    print("开始请求动态数据");
    if (dataPage > 1 && lastTime == null) {
      setState(() {
        loadText = "已加载全部动态";
        loadStatus = LoadingStatus.STATUS_COMPLETED;
        print("返回不请求数据");
      });
      return;
    }
    DataResponseModel model = await getPullList(type: 0, size: 20, lastTime: lastTime);
    if (mounted) {
      setState(() {
        print("dataPage:  ￥￥$dataPage");
        if (dataPage == 1) {
          //fixme model.list为空 null 会报错
          if (model.list != null && model.list.isNotEmpty) {
            model.list.forEach((v) {
              context.read<ProfilePageNotifier>().profileUiChangeModel.remove(HomeFeedModel.fromJson(v).pushId);
              attentionIdList.add(HomeFeedModel.fromJson(v).id);
              attentionModelList.add(HomeFeedModel.fromJson(v));
            });
            if (model.hasNext == 0) {
              loadText = "";
              loadStatus = LoadingStatus.STATUS_IDEL;
            }
            attentionIdList.insert(0, -1);
            status = Status.concern;
          } else {
            status = Status.noConcern;
          }
        } else if (dataPage > 1 && lastTime != null) {
          if (model.list.isNotEmpty) {
            model.list.forEach((v) {
              attentionIdList.add(HomeFeedModel.fromJson(v).id);
              attentionModelList.add(HomeFeedModel.fromJson(v));
            });
            loadStatus = LoadingStatus.STATUS_IDEL;
            loadText = "加载中...";
          } else {
            // 加载完毕
            loadText = "已加载全部动态";
            loadStatus = LoadingStatus.STATUS_COMPLETED;
          }
        }
        attentionModelList =  StringUtil.getFeedItemHeight(14.0, attentionModelList);
        // getFeedItemHeight(attentionModelList);
      });

    }
    lastTime = model.lastTime;
    isRequestInterface = false;
    // 更新动态数量
    int addFeedNum = 0;
    attentionModelList.forEach((element) {
      var obj = element.id;
      var isExist = false;
      context.read<FeedMapNotifier>().feedMap.forEach((key, value) {
        var aj = value.id;
        if (obj == aj) {
          isExist = true;
          return;
        }
      });
      if (!isExist) {
        addFeedNum++;
      }
    });
    if (addFeedNum != 0) {
      ToastShow.show(msg: "更新了$addFeedNum条动态", context: context, gravity: Toast.CENTER);
    }
    // 更新全局监听
    context.read<FeedMapNotifier>().updateFeedMap(attentionModelList);
    print("本地存储的数据长度1:${context.read<FeedMapNotifier>().feedMap.length}");
  }

  // 插入数据
  insertData(int id) {
    attentionIdList.insert(1, id);
  }

  // 回到顶部
  backToTheTop() {
    // 判定滑动控制器是否绑定
    if (_controller.hasClients) {
      _controller.jumpTo(0);
    }
  }

  // 返回关注视图
  backToView(int index, HomeFeedModel feedmodel) {
    if (index == 0) {
      return Container(
        height: 14,
      );
    } else {
      return DynamicListLayout(
        index: index,
        isShowRecommendUser: true,
        model: feedmodel,
        isShowConcern: false,
        pageName: "attentionPage",
        // 可选参数 子Item的个数
        key: GlobalObjectKey("attention$index"),
        deleteFeedChanged: (id) {
          setState(() {
            attentionIdList.remove(id);
            context.read<FeedMapNotifier>().deleteFeed(id);
            print(attentionIdList.toString());
            if (attentionIdList.length == 1 && attentionIdList.first == -1) {
              loadStatus = LoadingStatus.STATUS_IDEL;
              loadText = "";
              status = Status.noConcern;
            }
          });
        },
        removeFollowChanged: (model) {
          int pushId = model.pushId;
          Map<int, HomeFeedModel> feedMap = context.read<FeedMapNotifier>().feedMap;

          ///临时的空数组
          List<int> themList = [];
          feedMap.forEach((key, value) {
            if (value.pushId == pushId) {
              themList.add(key);
            }
          });
          print('arrayDate(attentionIdList,themList).length   ==== ${arrayDate(attentionIdList, themList).length}');
          if (arrayDate(attentionIdList, themList).length == 1) {
            print(
                '=============================空 themList.length${themList.length} attentionIdList.length${attentionIdList.length}');
            dataPage = 1;
            attentionIdList.clear();
            attentionModelList.clear();
            loadStatus = LoadingStatus.STATUS_IDEL;
            lastTime = null;
            loadText = "";
            getRecommendFeed();
          } else {
            print('=============================有');
            print(
                '=============================有 themList.length${themList.length} attentionIdList.length${attentionIdList.length}');
            setState(() {
              attentionIdList = arrayDate(attentionIdList, themList);
              loadStatus = LoadingStatus.STATUS_IDEL;
              loadText = "";
            });
          }
        },
      );
    }
  }

  /**比较两数组 取出不同的，
   * array1 数组一
   * array2 数组二
   * **/
  List<int> arrayDate(List<int> array1, List<int> array2) {
    var arr1 = array1;
    var arr2 = array2;
    List<int> result = [];
    for (var i = 0; i < array1.length; i++) {
      var obj = array1[i];
      var isExist = false;
      for (var j = 0; j < array2.length; j++) {
        var aj = array2[j];
        if (obj == aj) {
          isExist = true;
          continue;
        }
      }
      if (!isExist) {
        result.add(obj);
      }
    }
    print("result${result.toString()}");
    return result;
  }


  // 缺省图未登录关注视图切换
  Widget pageDisplay(int index, HomeFeedModel feedModel) {
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
              GestureDetector(
                onTap: () async {
                  AppRouter.navigateToLoginPage(context);
                },
                child: Container(
                  width: 293,
                  height: 44,
                  color: Colors.black,
                  margin: EdgeInsets.only(top: 32),
                  child: Center(
                    child: Text(
                      "登录",
                      style: TextStyle(color: Colors.white),
                    ),
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
      case Status.loggedIn:
        return Container();
        break;
      case Status.concern:
        if (index == attentionIdList.length) {
          return LoadingView(
            loadText: loadText,
            loadStatus: loadStatus,
          );
        } else {
          return backToView(index, feedModel);
        }
    }
  }

  @override
  void dispose() {
    print("关注页面销毁了");
    _controller.dispose();
    super.dispose();
  }

  @override
  void deactivate() {
    print("deactivate：：：：：：关注页");
    super.deactivate();
  }

  @override
  void didChangeDependencies() {
    print("didChangeDependencies：：：：：：关注页");
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant AttentionPage oldWidget) {
    print("didUpdateWidget：：：：：：关注页");
    // context.read<FeedMapNotifier>().clearBuildCount();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    print("关注页");
    print("当前时间${DateTime.now().millisecondsSinceEpoch.toString()}");
    var isLogged = context.watch<TokenNotifier>().isLoggedIn;
    print(isLogged);
    if (!isLogged) {
      status = Status.notLoggedIn;
      this.dataPage = 1;
      this.attentionIdList.clear();
      this.attentionModelList.clear();
      this.lastTime = null;
      loadStatus = LoadingStatus.STATUS_LOADING;
      isRequestInterface = false;
    }

    if (isLogged && attentionIdList.isEmpty && !isRequestInterface && status != Status.noConcern) {
      getRecommendFeed();
    }
    return Container(
        child: NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        ScrollMetrics metrics = notification.metrics;
        // 注册通知回调
        if (notification is ScrollStartNotification) {
          // 滚动开始
          print('滚动开始');
        } else if (notification is ScrollUpdateNotification) {
          // 滚动位置更新
          if(timer != null) {
            timer.cancel();
          }
          print('滚动位置更新');
          // 当前位置
          print("当前位置${metrics.pixels}");
        } else if (notification is ScrollEndNotification) {
          print("本地存储的数据长度2:${context.read<FeedMapNotifier>().feedMap.length}");
          // 延迟器:
          timer = Timer(Duration(milliseconds: 3000), () {
            print("定时1秒到了");
            for(int i = 0 ; i < attentionModelList.length; i++) {
              HomeFeedModel value = attentionModelList[i];
              if(metrics.pixels >= value.headOffset && metrics.pixels < value.bottomOffset ) {
                print("进了");
                context.read<FeedMapNotifier>().showInputBox(value.id);
              }
            }
          });
          // 滚动结束
          print('滚动结束');
        }
      },
      child: RefreshIndicator(
          onRefresh: () async {
            dataPage = 1;
            attentionIdList.clear();
            attentionModelList.clear();
            loadStatus = LoadingStatus.STATUS_IDEL;
            lastTime = null;
            loadText = "";
            getRecommendFeed();
          },
          child: CustomScrollView(controller: _controller, physics: AlwaysScrollableScrollPhysics(), slivers: [
            SliverList(
              // controller: _controller,
              delegate: SliverChildBuilderDelegate((content, index) {
                if (status == Status.noConcern || status == Status.notLoggedIn || status == Status.noConcern) {
                  return pageDisplay(0, HomeFeedModel());
                }
                // 获取动态id
                int id;
                // 获取动态id指定model
                HomeFeedModel feedModel;
                if (index < attentionIdList.length) {
                  id = attentionIdList[index];
                  feedModel = context.read<FeedMapNotifier>().feedMap[id];
                }
                return pageDisplay(index, feedModel);
              }, childCount: attentionIdList.length + 1),
            )
            // )
          ])),
    ));
  }
}
