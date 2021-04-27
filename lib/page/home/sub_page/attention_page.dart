import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/data_response_model.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/page/home/sub_page/share_page/dynamic_list.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/data/notifier/token_notifier.dart';
import 'package:mirror/util/event_bus.dart';
import 'package:mirror/util/integer_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/sliding_element_exposure/exposure_detector.dart';
import 'package:mirror/widget/sliding_element_exposure/exposure_detector_controller.dart';
import 'package:mirror/widget/smart_refressher_head_footer.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
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
  AttentionPage({Key key}) : super(key: key);

  AttentionPageState createState() => AttentionPageState();
}

GlobalKey<AttentionPageState> attentionKey = GlobalKey();

class AttentionPageState extends State<AttentionPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; //必须重写

  var status = Status.loggedIn;

  //关注未读数
  int _unReadFeedCount = 0;

  // 加载中默认文字
  String loadText = "";

  // 加载状态
  LoadingStatus loadStatus = LoadingStatus.STATUS_IDEL;

  // 数据加载页数
  int dataPage = 1;

  // 数据源
  List<int> attentionIdList = [];
  List<HomeFeedModel> attentionModelList = [];
  RefreshController _refreshController = RefreshController();

  // 请求下一页
  int lastTime;

  // 列表监听
  ScrollController _controller = new ScrollController();

  // 是否登录
  bool isLoggedIn = false;

  bool showNoMroe = true;

  // 是否请求接口
  bool isRequestInterfaceEnd = false;

  // 声明定时器
  Timer timer;

  GlobalKey globalKey = GlobalKey();

  @override
  void dispose() {
    print("关注页面销毁了");
    _controller.dispose();
    // EventBus.getDefault().unRegister(registerName: AGAIN_LOGIN_REPLACE_LAYOUT, pageName: EVENTBUS_ATTENTION_PAGE);
    // EventBus.getDefault().unRegister(registerName: EVENTBUS__FEED_UNREAD, pageName: EVENTBUS_ATTENTION_PAGE);
    super.dispose();
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
  void deactivate() {
    // TODO: implement deactivate
    super.deactivate();
    print('============================关注页deactivate');
    context.read<FeedMapNotifier>().setBuildCallBack(false);
  }

  @override
  void initState() {
    print("初始化一下啊");
    isLoggedIn = context.read<TokenNotifier>().isLoggedIn;
    print("是否登录$isLoggedIn");
    if (!isLoggedIn) {
      status = Status.notLoggedIn;
    } else {
      getRecommendFeed(refreshOrLoading: true);
    }
    // 上拉加载
    super.initState();
    // 重新登录替换关注页布局
    EventBus.getDefault().registerNoParameter(_againLoginReplaceLayout, EVENTBUS_ATTENTION_PAGE,
        registerName: AGAIN_LOGIN_REPLACE_LAYOUT);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<FeedMapNotifier>().setBuildCallBack(true);
      // 动态未读数
      /* EventBus.getDefault()
          .registerSingleParameter(_feedUnreadCallBack, EVENTBUS_ATTENTION_PAGE, registerName: EVENTBUS__FEED_UNREAD);*/
    });
  }

  // 重新登录替换布局
  _againLoginReplaceLayout() {
    // 调用关注接口提换
    getRecommendFeed(refreshOrLoading: true);
  }
  // 双击刷新
  onDoubleTap() {
    _refreshController.requestRefresh(duration: Duration(milliseconds: 250));
  }

  //
  // 请求关注接口
  getRecommendFeed({bool refreshOrLoading}) async {
    print("开始请求动态数据");
    if (dataPage > 1 && lastTime == null) {
      _refreshController.loadNoData();
      return;
    }
    DataResponseModel model = await getPullList(type: 0, size: 20, lastTime: lastTime);
    if (refreshOrLoading) {
      attentionIdList.clear();
      attentionModelList.clear();
    }
    print('---7666666666666666666666666666666666666model！=null');
    if (mounted) {
      setState(() {
        print("dataPage:  ￥￥$dataPage");
        if (dataPage == 1) {
          if (model != null) {
            print("第一页");
            if (model.list != null && model.list.isNotEmpty) {
              model.list.forEach((v) {
                attentionIdList.add(HomeFeedModel.fromJson(v).id);
                attentionModelList.add(HomeFeedModel.fromJson(v));
              });
              status = Status.concern;
            } else {
              // 这是为了加载无动态缺省布局
              attentionIdList.insert(0, -1);
              status = Status.noConcern;
            }
            lastTime = model.lastTime;
          } else {
            attentionIdList.insert(0, -1);
            status = Status.noConcern;
          }
          _refreshController.refreshCompleted();
        } else if (dataPage > 1 && lastTime != null) {
          if (model != null) {
            print("第二页");
            if (model.list.isNotEmpty) {
              model.list.forEach((v) {
                attentionIdList.add(HomeFeedModel.fromJson(v).id);
                attentionModelList.add(HomeFeedModel.fromJson(v));
              });
              _refreshController.loadComplete();
            } else {
              _refreshController.loadNoData();
            }
            lastTime = model.lastTime;
          } else {
            _refreshController.loadNoData();
          }
        }
      });
    }
    isRequestInterfaceEnd = true;
    // 更新动态数量
    int addFeedNum = 0;
    attentionModelList.forEach((element) {
      var obj = element.id;
      var isExist = false;
      context.read<FeedMapNotifier>().value.feedMap.forEach((key, value) {
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
    if (addFeedNum != 0 && context.read<FeedMapNotifier>().value.unReadFeedCount != 0) {
      ToastShow.show(
          msg: "更新了${context.read<FeedMapNotifier>().value.unReadFeedCount}条动态",
          context: context,
          gravity: Toast.CENTER);
      /* _unReadFeedCount = 0;*/
      /*EventBus.getDefault().post(msg: _unReadFeedCount, registerName: EVENTBUS__FEED_UNREAD);*/
      context.read<FeedMapNotifier>().setUnReadFeedCount(0);
      print('--------------------------------------------addFeedNum != 0');
    }
    // 更新全局监听
    if (attentionModelList.length > 0) {
      context.read<FeedMapNotifier>().updateFeedMap(attentionModelList);
      print("本地存储的数据长度1:${context.read<FeedMapNotifier>().value.feedMap.length}");
    }
  }

  // 插入发布数据
  insertData(HomeFeedModel model) {
    print("插入数据了");
    // 清除无动态缺省图的id
    attentionIdList.removeWhere((v) => v == -1);
    attentionIdList.insert(0, model.id);
    attentionModelList.insert(0, model);
    print(attentionIdList.toString());
    // // 更新全局监听
    // new Future.delayed(Duration.zero, () {
    context.read<FeedMapNotifier>().insertFeedMap(model);
    // });
    setState(() {});
    status = Status.concern;
  }

  // 回到顶部
  backToTheTop() {
    // 判定滑动控制器是否绑定
    if (_controller.hasClients) {
      _controller.animateTo(0, duration: Duration(milliseconds: 1), curve: Curves.easeInOut);
    }
  }

  /**比较两数组 取出不同的，
   * array1 数组一
   * array2 数组二
   * **/
  List<int> arrayDate(List<int> array1, List<int> array2) {
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
    // print("result${result.toString()}");
    return result;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    print("AttentionPage_______build");
    print("当前时间${DateTime.now().millisecondsSinceEpoch.toString()}");
    var isLogged = context.watch<TokenNotifier>().isLoggedIn;
    print(isLogged);
    if (!isLogged) {
      status = Status.notLoggedIn;
      this.dataPage = 1;
      this.attentionIdList.clear();
      this.attentionModelList.clear();
      this.lastTime = null;
    }

    // 未登录状态不需要刷新
    if (status == Status.notLoggedIn) {
      return Container(
        height: ScreenUtil.instance.height -
            48 -
            44 -
            ScreenUtil.instance.bottomBarHeight -
            ScreenUtil.instance.statusBarHeight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 224,
              height: 224,
              decoration: BoxDecoration(
                image: DecorationImage(image: AssetImage("assets/png/default_no_data.png"), fit: BoxFit.cover),
              ),
              margin: const EdgeInsets.only(bottom: 16),
            ),
            const Text(
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
                margin: const EdgeInsets.only(top: 32),
                child: const Center(
                  child: const Text(
                    "登录",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            )
          ],
        ),
      );
    }
    return Container(
      child: SmartRefresher(
          enablePullUp: status == Status.concern ? true : false,
          enablePullDown: true,
          footer: SmartRefresherHeadFooter.init().getFooter(isShowNoMore: showNoMroe),
          header: SmartRefresherHeadFooter.init().getHeader(),
          controller: _refreshController,
          onLoading: () {
            setState(() {
              showNoMroe = IntegerUtil.showNoMore(globalKey);
            });
            dataPage += 1;
            getRecommendFeed(refreshOrLoading: false);
          },
          onRefresh: () {
            dataPage = 1;
            _refreshController.loadComplete();
            lastTime = null;
            // 清空曝光过的listKey
            ExposureDetectorController.instance.signOutClearHistory();
            getRecommendFeed(refreshOrLoading: true);
          },
          child: CustomScrollView(
              key: globalKey,
              controller: _controller,
              physics: Platform.isIOS ? BouncingScrollPhysics() : AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverList(
                  // controller: _controller,
                  delegate: SliverChildBuilderDelegate((content, index) {
                    if (status == Status.noConcern) {
                      return pageDisplay(0, HomeFeedModel());
                    }
                    // 获取动态id
                    int id;
                    // 获取动态id指定model
                    HomeFeedModel feedModel;
                    if (index < attentionIdList.length) {
                      id = attentionIdList[index];
                      feedModel = context.read<FeedMapNotifier>().value.feedMap[id];
                    }
                    print("attentionIdList数据源长度：：：：${attentionIdList.length}");
                    return ExposureDetector(
                      key: Key('attention_page_$id'),
                      child: pageDisplay(index, feedModel),
                      onExposure: (visibilityInfo) {
                        // 如果没有显示
                        if (attentionIdList[index] != -1 &&
                            context.read<FeedMapNotifier>().value.feedMap[attentionIdList[index]].isShowInputBox) {
                          context.read<FeedMapNotifier>().showInputBox(attentionIdList[index]);
                          print('第$index 块曝光,展示比例为${visibilityInfo.visibleFraction}');
                        }
                      },
                    );
                  }, childCount: attentionIdList.length),
                )
              ])),
    );
  }

  // 缺省图关注视图切换
  Widget pageDisplay(int index, HomeFeedModel feedModel) {
    print("status:::$status");
    switch (status) {
      case Status.noConcern:
        return Container(
          height: ScreenUtil.instance.height -
              48 -
              44 -
              ScreenUtil.instance.bottomBarHeight -
              ScreenUtil.instance.statusBarHeight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 224,
                height: 224,
                decoration: BoxDecoration(
                  image: DecorationImage(image: AssetImage("assets/png/default_no_data.png"), fit: BoxFit.cover),
                ),
                margin: const EdgeInsets.only(bottom: 16),
              ),
              const Text(
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
        return backToView(index, feedModel);
    }
  }

  // 返回关注视图
  Widget backToView(int index, HomeFeedModel feedmodel) {
    print("疯狂build");
    return DynamicListLayout(
      index: index,
      isShowRecommendUser: true,
      model: feedmodel,
      isShowConcern: false,
      pageName: "attentionPage",
      // 可选参数 子Item的个数
      // key: GlobalObjectKey("attention$index"),
      deleteFeedChanged: (id) {
        setState(() {
          attentionIdList.remove(id);
          context.read<FeedMapNotifier>().deleteFeed(id);
          attentionModelList.removeWhere((v) => v.id == id);
          // 更新全局监听
          context.read<FeedMapNotifier>().updateFeedMap(attentionModelList);
          print(attentionIdList.toString());
          if (attentionIdList.length == 0) {
            print("进入了00000");
            // 这是为了加载无动态缺省布局
            attentionIdList.insert(0, -1);
            attentionModelList.clear();
            status = Status.noConcern;
          }
        });
      },
      removeFollowChanged: (model) {
        int pushId = model.pushId;
        Map<int, HomeFeedModel> feedMap = context.read<FeedMapNotifier>().value.feedMap;

        ///临时的空数组
        List<int> themList = [];

        print("themList:::${themList.toString()}");
        print("attentionIdList:::${attentionIdList.toString()}");
        if (arrayDate(attentionIdList, themList).length == 0) {
          print("进入了11111");
          dataPage = 1;
          // attentionIdList.clear();
          attentionModelList.clear();
          lastTime = null;
          getRecommendFeed();
        } else {
          print("进入了222222");
          setState(() {
            attentionIdList = arrayDate(attentionIdList, themList);
            // 更新全局监听
            context.read<FeedMapNotifier>().updateFeedMap(attentionModelList);
          });
        }
      },
    );
  }
}
