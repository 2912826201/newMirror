import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
import 'package:mirror/data/model/profile/searchuser_model.dart';
import 'package:mirror/data/model/user_model.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
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
  bool get wantKeepAlive => true; //????????????
  // ????????????data
  List<HomeFeedModel> feedList = [];

  // ????????????data
  List<TopicDtoModel> topicList = [];

  // ????????????data
  List<UserModel> userList = [];

  // ????????????data
  List<CourseModel> liveVideoList = [];

  // ???????????????
  Timer timer;
  String lastString;

  // ???????????????
  // ScrollController _scrollController = new ScrollController();

  // ?????????????????????
  int hasNext;

  // ?????????
  int lastTime;

  // ?????????????????????
  bool isShowDefaultMap;

  // Token can be shared with different requests.
  CancelToken token = CancelToken();
  Map<int, AnimationController> animationMap = {};
  RefreshController _refreshController = RefreshController();

  @override
  void dispose() {
    // _scrollController.dispose();
    // ??????????????????
    cancelRequests(token: token);
    if (timer != null) {
      timer.cancel();
    }
    super.dispose();
  }

  @override
  void initState() {
    // ????????????
    mergeRequest();
    EventBus.init().registerSingleParameter(_deleteFeedCallBack, EVENTBUS_SEARCH_FEED_PAGE,
        registerName: EVENTBUS_SEARCH_DELETED_FEED);
    Application.tabBarIndexList.add(0);
    widget.controller.addListener(() {
      print("widget.tabBarIndexList??????:::${Application.tabBarIndexList}");
      // ??????tab???????????????tarBarView???
      if (widget.controller.index == 0) {
        print(Application.tabBarIndexList.contains(0));
        // ???????????????????????????
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
        // ????????????
        if (timer != null) {
          timer.cancel();
        }
        // ?????????:
        timer = Timer(Duration(milliseconds: 500), () {
          if (lastString != widget.keyWord) {
            mergeRequest();
          }
        });
      }
    });
    // ????????????
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

  // ????????????
  mergeRequest() async {
    List<Future> requestList = [];
    // ??????????????????
    requestList.add(
      ProfileSearchUser(widget.keyWord, 3, token: token),
    );
    // ??????????????????
    requestList.add(
      searchTopic(key: widget.keyWord, size: 3, token: token),
    );
    // ??????????????????
    requestList.add(
      searchFeed(key: widget.keyWord, size: 20, token: token),
    );
    // ??????????????????
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
      // ????????????
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
        // ????????????
        _refreshController.loadComplete();
      }

      // ??????????????????
      if (mounted) {
        //?????????????????????????????????
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

  // ??????????????????
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
          //?????????????????????????????????
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
          // ????????????
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
                      "??????????????????????????????",
                      style: AppStyle.text1Regular14,
                    ),
                    const Text("??????????????????", style: AppStyle.text1Regular14),
                  ],
                ),
              )
            : ScrollConfiguration(
                behavior: OverScrollBehavior(),
                // child: SizeCacheWidget(
                //     // ????????????????????????????????????????????????3????????? SizeCacheWidget ??? estimateCount ????????? 3*2???????????????????????????????????????????????????????????????
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
                            child: ItemTitle("????????????", 12, 1, widget.controller),
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
                                child: ItemTitle("????????????", 16, AppConfig.needShowTraining ? 4 : 3, widget.controller))),
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
                                child: ItemTitle("????????????", 16, AppConfig.needShowTraining ? 2 : 1, widget.controller))),
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
                                child: ItemTitle("????????????", 16, AppConfig.needShowTraining ? 3 : 2, widget.controller))),
                        // SliverToBoxAdapter(
                        //     child: Offstage(
                        //         offstage: feedList.length == 0,
                        //         child: Container(
                        //             // margin: EdgeInsets.only(left: 16, right: 16),
                        //             child: MediaQuery.removePadding(
                        //                 removeTop: true,
                        //                 context: context,
                        //                 // ?????????
                        //                 // child: WaterfallFlow.builder(
                        //                 //   primary: false,
                        //                 //   shrinkWrap: true,
                        //                 //   gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                        //                 //     crossAxisCount: 2,
                        //                 //     // ????????????
                        //                 //     mainAxisSpacing: 4.0,
                        //                 //     //   // ????????????
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
                        //                             // ???????????? ???Item?????????
                        //                             key: GlobalObjectKey("attention$index"),
                        //                           ),
                        //                           onExposure: (visibilityInfo) {
                        //                             // ??????????????????
                        //                             if (context
                        //                                 .read<FeedMapNotifier>()
                        //                                 .value
                        //                                 .feedMap[feedList[index].id]
                        //                                 .isShowInputBox) {
                        //                               context.read<FeedMapNotifier>().showInputBox(feedList[index].id);
                        //                             }
                        //                             print('???$index ?????????,???????????????${visibilityInfo.visibleFraction}');
                        //                           },
                        //                         );
                        //                     })
                        //                 // child: StaggeredGridView.countBuilder(
                        //                 //   shrinkWrap: true,
                        //                 //   itemCount: feedList.length + 1,
                        //                 //   primary: false,
                        //                 //   crossAxisCount: 4,
                        //                 //   // ????????????
                        //                 //   mainAxisSpacing: 4.0,
                        //                 //   // ????????????
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
                        //         // ???????????? ???Item?????????
                        //         key: GlobalObjectKey("attention$index"),
                        //       ),
                        //       onExposure: (visibilityInfo) {
                        //         // ??????????????????
                        //         if (context.read<FeedMapNotifier>().value.feedMap[feedList[index].id].isShowInputBox) {
                        //           context.read<FeedMapNotifier>().showInputBox(feedList[index].id);
                        //         }
                        //         print('???$index ?????????,???????????????${visibilityInfo.visibleFraction}');
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
    print("searchComplex????????????");
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
            pageName: DynamicPageType.searchComplex,
            isShowRecommendUser: false,
            isShowConcern: false,
            model: feedList[index],
            // ???????????? ???Item?????????
            key: GlobalObjectKey("searchComplex$index"),
          ),
          onExposure: (visibilityInfo) {
            // ??????????????????
            if (context.read<FeedMapNotifier>().value.feedMap[feedList[index].id].isShowInputBox) {
              context.read<FeedMapNotifier>().showInputBox(feedList[index].id);
              print('???$index ?????????,???????????????${visibilityInfo.visibleFraction}');
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
            style: AppStyle.whiteMedium15,
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              print("??????");
              widget.controller.index = widget.initialIndex;
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text("??????",
                    style:  const TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: AppColor.textWhite60)),
                const SizedBox(width: 6),
                AppIcon.getAppIcon(AppIcon.arrow_right_16, 16, color: AppColor.textWhite60),
              ],
            ),
          )
        ],
      ),
    );
  }
}
