import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// import 'package:keframe/frame_separate_widget.dart';
// import 'package:keframe/size_cache_widget.dart';
import 'package:mirror/api/api.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/api/search/search_api.dart';
import 'package:mirror/api/topic/topic_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/config/config.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/data_response_model.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/training/course_model.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/data/model/profile/searchuser_model.dart';
import 'package:mirror/data/model/user_model.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/page/home/sub_page/recommend_page.dart';
import 'package:mirror/page/home/sub_page/share_page/dynamic_list.dart';
import 'package:mirror/page/search/sub_page/search_course.dart';
import 'package:mirror/page/search/sub_page/search_user.dart';
import 'package:mirror/util/event_bus.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/icon.dart';
import 'package:mirror/widget/overscroll_behavior.dart';
import 'package:mirror/widget/size_transition_view.dart';
import 'package:mirror/widget/sliding_element_exposure/exposure_detector.dart';
import 'package:mirror/widget/smart_refressher_head_footer.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'search_topic.dart';

class SearchComplex extends StatefulWidget {
  SearchComplex({Key key, this.keyWord, this.focusNode, this.textController, this.controller}) : super(key: key);
  final String keyWord;
  final FocusNode focusNode;
  final TabController controller;
  final TextEditingController textController;

  SearchComplexState createState() => SearchComplexState();
}

class SearchComplexState extends State<SearchComplex> with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true; //必须重写
  // 相关动态data
  List<HomeFeedModel> feedList = [];

  // 相关话题data
  List<TopicDtoModel> topicList = [];

  // 相关用户data
  List<UserModel> userList = [];

  // 相关课程data
  List<CourseModel> liveVideoList = [];

  // 声明定时器
  Timer timer;
  String lastString;

  // 滑动控制器
  // ScrollController _scrollController = new ScrollController();

  // 是否存在下一页
  int hasNext;

  // 下一页
  int lastTime;

  // 是否显示缺省图
  bool isShowDefaultMap;

  // Token can be shared with different requests.
  CancelToken token = CancelToken();
  Map<int, AnimationController> animationMap = {};
  RefreshController _refreshController = RefreshController();

  @override
  void dispose() {
    // _scrollController.dispose();
    // 取消网络请求
    cancelRequests(token: token);
    if (timer != null) {
      timer.cancel();
    }
    super.dispose();
  }

  @override
  void initState() {
    // 合并请求
    mergeRequest();
    EventBus.getDefault().registerSingleParameter(_deleteFeedCallBack, EVENTBUS_SEARCH_FEED_PAGE,
        registerName: EVENTBUS_SEARCH_DELETED_FEED);
    Application.tabBarIndexList.add(0);
    widget.controller.addListener(() {
      print("widget.tabBarIndexList动态:::${Application.tabBarIndexList}");
      // 切换tab监听在当前tarBarView下
      if (widget.controller.index == 0) {
        print(Application.tabBarIndexList.contains(0));
        // 初始化过的文本变化
        if (Application.tabBarIndexList.contains(0)) {
          if (lastString != widget.keyWord) {
            lastTime = null;
            hasNext = null;
            mergeRequest();
          }
        }
      }
    });
    widget.textController.addListener(() {
      if (widget.controller.index == 0) {
        // 取消延时
        if (timer != null) {
          timer.cancel();
        }
        // 延迟器:
        timer = Timer(Duration(milliseconds: 500), () {
          if (lastString != widget.keyWord) {
            mergeRequest();
          }
        });
      }
    });
    // 上拉加载
    // _scrollController.addListener(() {
    //   if (widget.focusNode.hasFocus) {
    //     print('-------------------focusNode---focusNode----focusNode--focusNode');
    //     FocusScope.of(context).requestFocus(FocusNode());
    //   }
    //   if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
    //     requestFeednIterface();
    //   }
    // });
    super.initState();
  }

  // 合并请求
  mergeRequest() async {
    List<Future> requestList = [];
    // 请求相关用户
    requestList.add(
      ProfileSearchUser(widget.keyWord, 3, token: token),
    );
    // 请求相关话题
    requestList.add(
      searchTopic(key: widget.keyWord, size: 3, token: token),
    );
    // 请求相关动态
    requestList.add(
      searchFeed(key: widget.keyWord, size: 20, token: token),
    );
    // 请求相关课程
    if (AppConfig.needShowTraining)
      requestList.add(
        searchCourse(key: widget.keyWord, size: 2, token: token),
      );
    var result = await Future.wait(requestList);
    liveVideoList.clear();
    userList.clear();
    topicList.clear();
    feedList.clear();
    animationMap.clear();
    SearchUserModel userModel;
    userModel = result[0];
    DataResponseModel topicModel = result[1];
    DataResponseModel feedModel = result[2];
    DataResponseModel courseModel;
    if (AppConfig.needShowTraining) {
      courseModel = result[3];
    }
    if (AppConfig.needShowTraining && courseModel != null && courseModel.list.length != 0) {
      courseModel.list.forEach((v) {
        if (v != null) {
          liveVideoList.add(CourseModel.fromJson(v));
        }
      });
    } else {
      // 接口失败
      liveVideoList.clear();
    }

    if (userModel != null && userModel.list.length != 0) {
      userModel.list.forEach((element) {
        print('model================ ${element.relation}');
      });
      userList.addAll(userModel.list);
    } else {
      userList.clear();
    }
    if (topicModel != null && topicModel.list.length != 0) {
      topicModel.list.forEach((v) {
        topicList.add(TopicDtoModel.fromJson(v));
      });
    } else {
      topicList.clear();
    }
    if (feedModel != null && feedModel.list.length != 0 && mounted) {
      lastTime = feedModel.lastTime;
      hasNext = feedModel.hasNext;
      feedModel.list.forEach((v) {
        feedList.add(HomeFeedModel.fromJson(v));
        animationMap[HomeFeedModel.fromJson(v).id] =
            AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
      });
      if (hasNext == 0) {
        print("-------------------_______________________________");
        // 加载完毕
        _refreshController.loadComplete();
      }

      // 更新全局监听
      if (mounted) {
        //筛选首页关注页话题动态
        List<HomeFeedModel> homeFollowModel = [];
        context.read<FeedMapNotifier>().value.feedMap.forEach((key, value) {
          if (value.recommendSourceDto != null) {
            homeFollowModel.add(value);
          }
        });
        homeFollowModel.forEach((element) {
          feedList.forEach((v) {
            if (element.id == v.id) {
              v.recommendSourceDto = element.recommendSourceDto;
            }
          });
        });
        context.read<FeedMapNotifier>().updateFeedMap(feedList);
      }
    } else {
      _refreshController.loadComplete();
      feedList.clear();
      animationMap.clear();
    }
    lastString = widget.keyWord;
    if (liveVideoList.length == 0 && userList.length == 0 && topicList.length == 0 && feedList.length == 0) {
      isShowDefaultMap = true;
    } else {
      isShowDefaultMap = false;
    }
    if (mounted) {
      print("111111111111111111");
      setState(() {});
    }
  }

  // 请求动态接口
  requestFeednIterface() async {
    if (hasNext != 0) {
      DataResponseModel model = await searchFeed(key: widget.keyWord, size: 20, lastTime: lastTime, token: token);
      if (model != null) {
        hasNext = model.hasNext;
        lastTime = model.lastTime;
        if (hasNext != 0 && mounted) {
          if (model.list.isNotEmpty) {
            model.list.forEach((v) {
              feedList.add(HomeFeedModel.fromJson(v));
              animationMap[HomeFeedModel.fromJson(v).id] =
                  AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
            });
            _refreshController.loadComplete();
            print("-------------------_______________________________");
          }
          //筛选首页关注页话题动态
          List<HomeFeedModel> homeFollowModel = [];
          context.read<FeedMapNotifier>().value.feedMap.forEach((key, value) {
            if (value.recommendSourceDto != null) {
              homeFollowModel.add(value);
            }
          });
          homeFollowModel.forEach((element) {
            feedList.forEach((v) {
              if (element.id == v.id) {
                v.recommendSourceDto = element.recommendSourceDto;
              }
            });
          });
          // 同步数据
          context.read<FeedMapNotifier>().updateFeedMap(feedList);
        }
        if (hasNext == 0) {
          _refreshController.loadComplete();
          print("-------------------_______________________________");
        }
      } else {
        _refreshController.loadComplete();
      }
      if (mounted) {
        setState(() {});
      }
    } else {
      _refreshController.loadComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return isShowDefaultMap == null
        ? Container()
        : isShowDefaultMap
            ? Container(
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
                      "你的放大镜陨落星辰了",
                      style: TextStyle(fontSize: 14, color: AppColor.textSecondary),
                    ),
                    const Text("换一个试一试", style: TextStyle(color: AppColor.textSecondary, fontSize: 14)),
                  ],
                ),
              )
            : ScrollConfiguration(
                behavior: OverScrollBehavior(),
                // child: SizeCacheWidget(
                //     // 粗略估计一屏上列表项的最大数量如3个，将 SizeCacheWidget 的 estimateCount 设置为 3*2。快速滚动场景构建响应更快，并且内存更稳定
                //     estimateCount: 6,
                child: SmartRefresher(
                    enablePullUp: true,
                    enablePullDown: false,
                    footer: SmartRefresherHeadFooter.init().getFooter(),
                    controller: _refreshController,
                    onLoading: () {
                      if (widget.focusNode.hasFocus) {
                        print('-------------------focusNode---focusNode----focusNode--focusNode');
                        FocusScope.of(context).requestFocus(FocusNode());
                      }
                      print('-------------------focusNode---focusNode----focusNode--focusNode');
                      requestFeednIterface();
                    },
                    child: CustomScrollView(
                      controller: PrimaryScrollController.of(context),
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                      slivers: [
                        if (AppConfig.needShowTraining)
                          SliverToBoxAdapter(
                              child: Offstage(
                            offstage: liveVideoList.length == 0,
                            child: ItemTitle("相关课程", 12, 1, widget.controller),
                          )),
                        if (AppConfig.needShowTraining)
                          SliverList(
                            delegate: SliverChildBuilderDelegate((content, index) {
                              return Offstage(
                                  offstage: liveVideoList.length == 0,
                                  child: SearchCourseItem(
                                    videoModel: liveVideoList[index],
                                    index: index,
                                    count: liveVideoList.length,
                                  ));
                            }, childCount: liveVideoList.length),
                          ),
                        SliverToBoxAdapter(
                            child: Offstage(
                                offstage: userList.length == 0,
                                child: ItemTitle("相关用户", 16, AppConfig.needShowTraining ? 4 : 3, widget.controller))),
                        SliverList(
                            delegate: SliverChildBuilderDelegate((content, index) {
                          return Offstage(
                              offstage: userList.length == 0,
                              child: Container(
                                  width: ScreenUtil.instance.width,
                                  margin: const EdgeInsets.only(left: 16, right: 16),
                                  child: SearchUserItem(
                                    model: userList[index],
                                    width: ScreenUtil.instance.width,
                                    type: 1,
                                  )));
                        }, childCount: userList.length)),
                        SliverToBoxAdapter(
                            child: Offstage(
                                offstage: topicList.length == 0,
                                child: ItemTitle("相关话题", 16, AppConfig.needShowTraining ? 2 : 1, widget.controller))),
                        SliverList(
                            delegate: SliverChildBuilderDelegate((content, index) {
                          return Offstage(
                              offstage: topicList.length == 0,
                              child: SearchTopiciItem(
                                model: topicList[index],
                              ));
                        }, childCount: topicList.length)),
                        SliverToBoxAdapter(
                            child: Offstage(
                                offstage: feedList.length == 0,
                                child: ItemTitle("相关动态", 16, AppConfig.needShowTraining ? 3 : 2, widget.controller))),
                        // SliverToBoxAdapter(
                        //     child: Offstage(
                        //         offstage: feedList.length == 0,
                        //         child: Container(
                        //             // margin: EdgeInsets.only(left: 16, right: 16),
                        //             child: MediaQuery.removePadding(
                        //                 removeTop: true,
                        //                 context: context,
                        //                 // 瀑布流
                        //                 // child: WaterfallFlow.builder(
                        //                 //   primary: false,
                        //                 //   shrinkWrap: true,
                        //                 //   gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                        //                 //     crossAxisCount: 2,
                        //                 //     // 上下间隔
                        //                 //     mainAxisSpacing: 4.0,
                        //                 //     //   // 左右间隔
                        //                 //     crossAxisSpacing: 8.0,
                        //                 //   ),
                        //                 //   itemBuilder: (context, index) {
                        //                 //     if (index == feedList.length) {
                        //                 //       return LoadingView(
                        //                 //         loadText: loadText,
                        //                 //         loadStatus: loadStatus,
                        //                 //       );
                        //                 //     } else if (index == feedList.length + 1) {
                        //                 //       return Container();
                        //                 //     } else {
                        //                 //       return SearchFeeditem(
                        //                 //         model: feedList[index],
                        //                 //         list: feedList,
                        //                 //         index: index,
                        //                 //         pageName: "searchComplex",
                        //                 //       );
                        //                 //     }
                        //                 //   },
                        //                 //   itemCount: feedList.length + 1,
                        //                 // )
                        //                 child: ListView.builder(
                        //                     primary: false,
                        //                     shrinkWrap: true,
                        //                     itemCount: feedList.length,
                        //                     itemBuilder: (context, index) {
                        //                       // HomeFeedModel model;
                        //                       // int id = model = context.read<FeedMapNotifier>().value.feedMap[id];
                        //                         return ExposureDetector(
                        //                           key: Key('search_complex_${feedList[index].id}'),
                        //                           child: DynamicListLayout(
                        //                             index: index,
                        //                             pageName: "searchComplex",
                        //                             isShowRecommendUser: false,
                        //                             isShowConcern: false,
                        //                             model: feedList[index],
                        //                             // 可选参数 子Item的个数
                        //                             key: GlobalObjectKey("attention$index"),
                        //                           ),
                        //                           onExposure: (visibilityInfo) {
                        //                             // 如果没有显示
                        //                             if (context
                        //                                 .read<FeedMapNotifier>()
                        //                                 .value
                        //                                 .feedMap[feedList[index].id]
                        //                                 .isShowInputBox) {
                        //                               context.read<FeedMapNotifier>().showInputBox(feedList[index].id);
                        //                             }
                        //                             print('第$index 块曝光,展示比例为${visibilityInfo.visibleFraction}');
                        //                           },
                        //                         );
                        //                     })
                        //                 // child: StaggeredGridView.countBuilder(
                        //                 //   shrinkWrap: true,
                        //                 //   itemCount: feedList.length + 1,
                        //                 //   primary: false,
                        //                 //   crossAxisCount: 4,
                        //                 //   // 上下间隔
                        //                 //   mainAxisSpacing: 4.0,
                        //                 //   // 左右间隔
                        //                 //   crossAxisSpacing: 8.0,
                        //                 //   itemBuilder: (context, index) {
                        //                 //     if (index == feedList.length) {
                        //                 //       return LoadingView(
                        //                 //         loadText: loadText,
                        //                 //         loadStatus: loadStatus,
                        //                 //       );
                        //                 //     } else if (index == feedList.length + 1) {
                        //                 //       return Container();
                        //                 //     } else {
                        //                 //       return SearchFeeditem(
                        //                 //         model: feedList[index],
                        //                 //         list: feedList,
                        //                 //         index: index,
                        //                 //         focusNode: widget.focusNode,
                        //                 //         pageName: "searchComplex",
                        //                 //       );
                        //                 //     }
                        //                 //   },
                        //                 //   staggeredTileBuilder: (index) => StaggeredTile.fit(2),
                        //                 // )
                        //                 )))),
                        // feedList.length > 0
                        // SliverList(
                        //   delegate: SliverChildBuilderDelegate((content, index) {
                        //     return ExposureDetector(
                        //       key: Key('search_complex_${feedList[index].id}'),
                        //       child: DynamicListLayout(
                        //         index: index,
                        //         pageName: "searchComplex",
                        //         isShowRecommendUser: false,
                        //         isShowConcern: false,
                        //         model: feedList[index],
                        //         // 可选参数 子Item的个数
                        //         key: GlobalObjectKey("attention$index"),
                        //       ),
                        //       onExposure: (visibilityInfo) {
                        //         // 如果没有显示
                        //         if (context.read<FeedMapNotifier>().value.feedMap[feedList[index].id].isShowInputBox) {
                        //           context.read<FeedMapNotifier>().showInputBox(feedList[index].id);
                        //         }
                        //         print('第$index 块曝光,展示比例为${visibilityInfo.visibleFraction}');
                        //       },
                        //     );
                        //   }, childCount: feedList.length),
                        // ),
                        SliverList(
                            delegate: SliverChildBuilderDelegate((content, index) {
                          return Offstage(
                              offstage: feedList.length == 0,
                              child:
                                  // FrameSeparateWidget(
                                  //     index: index,
                                  //     placeHolder: Container(
                                  //       height: 512,
                                  //       width: ScreenUtil.instance.width,
                                  //     ),
                                  //     child:
                                  _buildItem(index)
                              // )
                              );
                        }, childCount: feedList.length))
                      ],
                    )
                    // )
                    ),
              );
  }

  _deleteFeedCallBack(int id) {
    print("searchComplex删除动态");
    if (animationMap.containsKey(id)) {
      animationMap[id].forward().then((value) {
        feedList.removeWhere((v) => v.id == id);
        if (mounted) {
          setState(() {
            animationMap.removeWhere((key, value) => key == id);
          });
        }
        if (context.read<FeedMapNotifier>().value.feedMap.containsKey(id)) {
          context.read<FeedMapNotifier>().deleteFeed(id);
        }
        if (liveVideoList.length == 0 && userList.length == 0 && topicList.length == 0 && feedList.length == 0) {
          mergeRequest();
        }
      });
    }
  }

  _buildItem(int index) {
    return SizeTransitionView(
        id: feedList[index].id,
        animationMap: animationMap,
        child: ExposureDetector(
          key: Key('search_complex_${feedList[index].id}'),
          child: DynamicListLayout(
            index: index,
            pageName: "searchComplex",
            isShowRecommendUser: false,
            isShowConcern: false,
            model: feedList[index],
            // 可选参数 子Item的个数
            key: GlobalObjectKey("searchComplex$index"),
          ),
          onExposure: (visibilityInfo) {
            // 如果没有显示
            if (context.read<FeedMapNotifier>().value.feedMap[feedList[index].id].isShowInputBox) {
              context.read<FeedMapNotifier>().showInputBox(feedList[index].id);
              print('第$index 块曝光,展示比例为${visibilityInfo.visibleFraction}');
            }
          },
        ));
  }
}

class ItemTitle extends StatefulWidget {
  ItemTitle(this.title, this.top, this.initialIndex, this.controller);

  int initialIndex;
  String title;
  double top;
  TabController controller;

  @override
  ItemTitleState createState() => ItemTitleState();
}

class ItemTitleState extends State<ItemTitle> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: ScreenUtil.instance.screenWidthDp,
      margin: EdgeInsets.only(left: 16, right: 16, top: widget.top),
      height: 48,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            widget.title,
            style: AppStyle.textMedium15,
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              print("跳转");
              widget.controller.index = widget.initialIndex;
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text("更多", style: AppStyle.textSecondaryRegular13),
                const SizedBox(width: 6),
                AppIcon.getAppIcon(AppIcon.arrow_right_16, 16, color: AppColor.textPrimary3),
              ],
            ),
          )
        ],
      ),
    );
  }
}
