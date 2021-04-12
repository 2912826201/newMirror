import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/config/shared_preferences.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/data_response_model.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/data/model/feed/post_feed.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:mirror/page/home/sub_page/recommend_page.dart';
import 'package:mirror/page/home/sub_page/share_page/dynamic_list.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/data/notifier/token_notifier.dart';
import 'package:mirror/util/event_bus.dart';
import 'package:mirror/util/integer_util.dart';
import 'package:mirror/util/string_util.dart';
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
  bool isRequestInterface = false;

  // 声明定时器
  Timer timer;

  GlobalKey globalKey = GlobalKey();
  @override
  void initState() {
    print("初始化一下啊");
    isLoggedIn = context.read<TokenNotifier>().isLoggedIn;
    print("是否登录$isLoggedIn");
    if (!isLoggedIn) {
      status = Status.notLoggedIn;
    } else {
      getRecommendFeed();
      // new Future.delayed(Duration.zero, () {
      //   print("AttentionPage发布失败数据");
      //   // 取出发布动态数据
      //   PostFeedModel feedModel = PostFeedModel.fromJson(jsonDecode(AppPrefs.getPublishFeedLocalInsertData(
      //       "${Application.postFailurekey}_${context.read<ProfileNotifier>().profile.uid}")));
      //   if (feedModel != null) {
      //     feedModel.selectedMediaFiles.list.forEach((v) {
      //       v.file = File(v.filePath);
      //     });
      //     // 插入数据
      //     insertData(HomeFeedModel().conversionModel(feedModel, context, isRefresh: true));
      //   }
      // });
    }

    // 上拉加载
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<FeedMapNotifier>().setBuildCallBack(true);
      EventBus.getDefault()
          .registerSingleParameter(_feedUnreadCallBack, EVENTBUS_ATTENTION_Page, registerName: EVENTBUS__FEED_UNREAD);
    });
  }

  @override
  void deactivate() {
    // TODO: implement deactivate
    super.deactivate();
    print('============================关注页deactivate');
    context.read<FeedMapNotifier>().setBuildCallBack(false);
  }
  _feedUnreadCallBack(int unread) {
    _unReadFeedCount = unread;
  }
  // 请求关注接口
  getRecommendFeed() async {
    isRequestInterface = true;
    print("开始请求动态数据");
    if (dataPage > 1 && lastTime == null) {
      _refreshController.loadNoData();
      return;
    }
    DataResponseModel model = await getPullList(type: 0, size: 20, lastTime: lastTime);
    if (model != null) {
      print('---7666666666666666666666666666666666666model！=null');
      if (mounted) {
        setState(() {
          print("dataPage:  ￥￥$dataPage");
          if (dataPage == 1) {
            //fixme model.list为空 null 会报错
            if (model.list != null && model.list.isNotEmpty) {
              model.list.forEach((v) {
                attentionIdList.add(HomeFeedModel.fromJson(v).id);
                attentionModelList.add(HomeFeedModel.fromJson(v));
              });
              attentionIdList.insert(0, -1);
              status = Status.concern;
            }
            _refreshController.refreshCompleted();
          } else if (dataPage > 1 && lastTime != null) {
            if (model.list.isNotEmpty) {
              model.list.forEach((v) {
                attentionIdList.add(HomeFeedModel.fromJson(v).id);
                attentionModelList.add(HomeFeedModel.fromJson(v));
              });
              _refreshController.loadComplete();
            } else {
             _refreshController.loadNoData();
            }
          }
          // attentionModelList = StringUtil.getFeedItemHeight(14.0, attentionModelList, isShowRecommendUser: true);
        });
      }
      lastTime = model.lastTime;
      isRequestInterface = false;
    } else if (PostFeedModel.fromJson(jsonDecode(AppPrefs.getPublishFeedLocalInsertData(
            "${Application.postFailurekey}_${context.read<ProfileNotifier>().profile.uid}"))) ==
        null) {
      print('-""--7666666666666666666666666666666666666else if');
      status = Status.noConcern;
      _refreshController.loadNoData();
    } else {
      print('-""--7666666666666666666666666666666666666else else');
      _refreshController.loadNoData();
    }
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
    if (addFeedNum != 0 && _unReadFeedCount != 0) {
      ToastShow.show(
          msg: "更新了${_unReadFeedCount}条动态",
          context: context,
          gravity: Toast.CENTER);
      _unReadFeedCount = 0;
      EventBus.getDefault().post(msg: _unReadFeedCount ,registerName:EVENTBUS__FEED_UNREAD);
      // context.read<FeedMapNotifier>().setUnReadFeedCount(0);
      print('--------------------------------------------addFeedNum != 0');
    }
    // 更新全局监听
    context.read<FeedMapNotifier>().updateFeedMap(attentionModelList);
    print("本地存储的数据长度1:${context.read<FeedMapNotifier>().value.feedMap.length}");
  }

  // // 删除本地插入数据
  // deleteData() {
  //   attentionIdList.removeWhere((v) => v == Application.insertFeedId);
  //   attentionModelList.removeWhere((element) => element.id == Application.insertFeedId);
  //   if (attentionIdList.length == 1 && attentionIdList.first == -1) {
  //     loadStatus = LoadingStatus.STATUS_IDEL;
  //     loadText = "";
  //     attentionIdList.clear();
  //     attentionModelList.clear();
  //     status = Status.noConcern;
  //   }
  // }

  // 插入发布数据
  insertData(HomeFeedModel model) {
    if (attentionIdList.isEmpty) {
      attentionIdList.insert(0, -1);
    }
    attentionIdList.insert(1, model.id);
    attentionModelList.insert(0, model);
    print(attentionIdList.toString());
    // // 更新全局监听
    new Future.delayed(Duration.zero, () {
      context.read<FeedMapNotifier>().insertFeedMap(model);
    });
    setState(() {});
    status = Status.concern;
  }

  // 需求修改 不插入本地数据所以不需要替换了  接口请求返回替换数据
  // replaceData(HomeFeedModel model) {
  //   print("更新model");
  //   attentionIdList.removeWhere((element) => element == Application.insertFeedId);
  //   attentionModelList.removeWhere((element) => element.id == Application.insertFeedId);
  //   context.read<FeedMapNotifier>().deleteFeed(Application.insertFeedId);
  //   attentionIdList.insert(1, model.id);
  //   attentionModelList.insert(0, model);
  //   // // 更新全局监听
  //   context.read<FeedMapNotifier>().insertFeedMap(model);
  //   print(attentionIdList.toString());
  //   print("更新结束");
  // }

  // 回到顶部
  backToTheTop() {
    // 判定滑动控制器是否绑定
    if (_controller.hasClients) {
      _controller.animateTo(0, duration: Duration(milliseconds: 1), curve: Curves.easeInOut);
    }
  }

  // 返回关注视图
  backToView(int index, HomeFeedModel feedmodel) {
    print("疯狂build");
    if (index == 0) {
      return  Container(
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
        // key: GlobalObjectKey("attention$index"),
        deleteFeedChanged: (id) {
          setState(() {
            attentionIdList.remove(id);
            context.read<FeedMapNotifier>().deleteFeed(id);
            attentionModelList.removeWhere((v) => v.id == id);
            // 更新全局监听
            context.read<FeedMapNotifier>().updateFeedMap(attentionModelList);
            print(attentionIdList.toString());
            if (attentionIdList.length == 1 && attentionIdList.first == -1) {
              attentionIdList.clear();
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
          List<HomeFeedModel> feedList = [];
          feedMap.forEach((key, value) {
            if (value.pushId == pushId) {
              themList.add(key);
              feedList.add(value);
            }
          });
          if (arrayDate(attentionIdList, themList).length == 1) {
            dataPage = 1;
            attentionIdList.clear();
            attentionModelList.clear();
            lastTime = null;
            getRecommendFeed();
          } else {
            setState(() {
              attentionIdList = arrayDate(attentionIdList, themList);
              // 去重
              attentionModelList = StringUtil.followModelFilterDeta(attentionModelList, feedList);
              // 更新全局监听
              context.read<FeedMapNotifier>().updateFeedMap(attentionModelList);
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
                margin: const EdgeInsets.only(bottom: 16, top: 150),
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
        break;
      case Status.noConcern:
        return  Container(
          child:  Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
               Container(
                width: 224,
                height: 224,
                color: AppColor.color246,
                margin: const EdgeInsets.only(bottom: 16, top: 188),
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
        return  Container();
        break;
      case Status.concern:
        return backToView(index, feedModel);
    }
  }

  @override
  void dispose() {
    print("关注页面销毁了");
    _controller.dispose();
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
      isRequestInterface = false;
    }

    if (isLogged && attentionIdList.isEmpty && !isRequestInterface && status != Status.noConcern) {
      print("builder 调用接口");
      getRecommendFeed();
    }
    return Container(
      child: SmartRefresher(
          enablePullUp: true,
          enablePullDown: true,
          footer: SmartRefresherHeadFooter.init().getFooter(isShowNoMore: showNoMroe),
          header: SmartRefresherHeadFooter.init().getHeader(),
          controller: _refreshController,
          onLoading:(){
            setState(() {
              showNoMroe = IntegerUtil.showNoMore(globalKey);
            });
            dataPage += 1;
            getRecommendFeed();
          },
            onRefresh: (){
              dataPage = 1;
              attentionIdList.clear();
              attentionModelList.clear();
              lastTime = null;
              // 清空曝光过的listKey
              ExposureDetectorController.instance.signOutClearHistory();
              getRecommendFeed();
            },

          child: CustomScrollView(key: globalKey,controller: _controller, physics: AlwaysScrollableScrollPhysics(), slivers: [
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
              }, childCount: attentionIdList.length + 1),
            )
          ])),
    );
  }
}
