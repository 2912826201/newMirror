import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/api/search/search_api.dart';
import 'package:mirror/api/topic/topic_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/data_response_model.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/training/live_video_model.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/data/model/profile/searchuser_model.dart';
import 'package:mirror/data/model/user_model.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/page/home/sub_page/recommend_page.dart';
import 'package:mirror/page/home/sub_page/share_page/dynamic_list.dart';
import 'package:mirror/page/search/sub_page/search_course.dart';
import 'package:mirror/page/search/sub_page/search_feed.dart';
import 'package:mirror/page/search/sub_page/search_user.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/string_util.dart';
import 'package:mirror/widget/Input_method_rules/pin_yin_text_edit_controller.dart';
import 'package:mirror/widget/icon.dart';
import 'package:mirror/widget/overscroll_behavior.dart';
import 'package:mirror/widget/sliding_element_exposure/exposure_detector.dart';
import 'package:provider/provider.dart';
import 'package:waterfall_flow/waterfall_flow.dart';
import 'search_topic.dart';

class SearchComplex extends StatefulWidget {
  SearchComplex({Key key, this.keyWord, this.focusNode, this.textController, this.controller}) : super(key: key);
  String keyWord;
  FocusNode focusNode;
  TabController controller;
  TextEditingController textController;

  SearchComplexState createState() => SearchComplexState();
}

class SearchComplexState extends State<SearchComplex> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; //必须重写
  // 相关动态data
  List<HomeFeedModel> feedList = [];

  // 相关话题data
  List<TopicDtoModel> topicList = [];

  // 相关用户data
  List<UserModel> userList = [];

  // 相关课程data
  List<LiveVideoModel> liveVideoList = [];

  // 声明定时器
  Timer timer;
  String lastString;

  // 滑动控制器
  ScrollController _scrollController = new ScrollController();

// 加载中默认文字
  String loadText = "加载中...";

  // 加载状态
  LoadingStatus loadStatus = LoadingStatus.STATUS_IDEL;

  // 是否存在下一页
  int hasNext;

  // 下一页
  int lastTime;

  @override
  void dispose() {
    _scrollController.dispose();
    if (timer != null) {
      timer.cancel();
    }
    super.dispose();
  }

  @override
  void initState() {
    // 合并请求
    mergeRequest();
    widget.textController.addListener(() {
      // 取消延时
      if (timer != null) {
        timer.cancel();
      }
      // 延迟器:
      timer = Timer(Duration(milliseconds: 700), () {
        if (lastString != widget.keyWord) {
          liveVideoList.clear();
          userList.clear();
          topicList.clear();
          feedList.clear();
          mergeRequest();
        }
      });
      lastString = widget.keyWord;
    });
    // 上拉加载
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        requestFeednIterface();
      }
    });
    super.initState();
  }

  // 合并请求
  mergeRequest() async {
    var result = await Future.wait([
      // 请求相关用户
      ProfileSearchUser(widget.keyWord, 3),
      // 请求相关话题
      searchTopic(key: widget.keyWord, size: 3),
      // 请求相关动态
      searchFeed(key: widget.keyWord, size: 20),
      // 请求相关课程
      searchCourse(key: widget.keyWord, size: 2),
    ]);
    SearchUserModel userModel;
    userModel = result[0];
    DataResponseModel topicModel = result[1];
    DataResponseModel feedModel = result[2];
    DataResponseModel courseModel = result[3];
    if (courseModel != null && courseModel.list.length != 0) {
      courseModel.list.forEach((v) {
        if (v != null) {
          liveVideoList.add(LiveVideoModel.fromJson(v));
        }
      });
    }

    if (userModel != null && userModel.list.length != 0) {
      userModel.list.forEach((element) {
        print('model================ ${element.relation}');
      });
      userList.addAll(userModel.list);
    }
    if (topicModel != null && topicModel.list.length != 0) {
      topicModel.list.forEach((v) {
        topicList.add(TopicDtoModel.fromJson(v));
      });
    }
    if (feedModel != null && feedModel.list.length != 0) {
      feedModel.list.forEach((v) {
        feedList.add(HomeFeedModel.fromJson(v));
        lastTime = feedModel.lastTime;
        hasNext = feedModel.hasNext;
        if (hasNext == 0) {
          // 加载完毕
          loadText = "已加载全部动态";
          loadStatus = LoadingStatus.STATUS_COMPLETED;
        }
      });
      // 更新全局监听

      context.read<FeedMapNotifier>().updateFeedMap(feedList);
    }
    if (mounted) {
      setState(() {});
    }
  }

  // 请求动态接口
  requestFeednIterface() async {
    if (hasNext != 0) {
      if (loadStatus == LoadingStatus.STATUS_IDEL) {
        // 先设置状态，防止下拉就直接加载
        setState(() {
          loadStatus = LoadingStatus.STATUS_LOADING;
        });
      }
      DataResponseModel model = await searchFeed(key: widget.keyWord, size: 20, lastTime: lastTime);
      hasNext = model.hasNext;
      lastTime = model.lastTime;
      if (hasNext != 0) {
        if (model.list.isNotEmpty) {
          model.list.forEach((v) {
            feedList.add(HomeFeedModel.fromJson(v));
          });
          loadStatus = LoadingStatus.STATUS_IDEL;
          loadText = "加载中...";
        }
        // 更新全局监听
        List<HomeFeedModel> feeds = [];
        context.read<FeedMapNotifier>().value.feedMap.forEach((key, value) {
          feeds.add(value);
        });
        // 只同步没有的数据
        context.read<FeedMapNotifier>().updateFeedMap(StringUtil.followModelFilterDeta(feedList, feeds));
      }
      if (hasNext == 0) {
        // 加载完毕
        loadText = "已加载全部动态";
        loadStatus = LoadingStatus.STATUS_COMPLETED;
      }
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return liveVideoList.length == 0 && userList.length == 0 && topicList.length == 0 && feedList.length == 0
        ? Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 224,
                  height: 224,
                  color: AppColor.bgWhite,
                  // margin: EdgeInsets.only(bottom: 16, top: 188),
                ),
                const Text(
                  "你的放大镜陨落星辰了",
                  style: TextStyle(fontSize: 14, color: AppColor.textSecondary),
                ),
                const Text("换一个试一试", style: TextStyle(color: AppColor.textSecondary, fontSize: 14)),
              ],
            ),
          )
        : Container(
            child: ScrollConfiguration(
                behavior: OverScrollBehavior(),
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    SliverToBoxAdapter(
                        child: Offstage(
                      offstage: liveVideoList.length == 0,
                      child: ItemTitle("相关课程", 12, 1, widget.controller),
                    )),
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
                            offstage: userList.length == 0, child: ItemTitle("相关用户", 16, 4, widget.controller))),
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
                            offstage: topicList.length == 0, child: ItemTitle("相关话题", 16, 2, widget.controller))),
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
                            offstage: feedList.length == 0, child: ItemTitle("相关动态", 16, 3, widget.controller))),
                    SliverToBoxAdapter(
                        child: Offstage(
                            offstage: feedList.length == 0,
                            child: Container(
                                // margin: EdgeInsets.only(left: 16, right: 16),
                                child: MediaQuery.removePadding(
                                    removeTop: true,
                                    context: context,
                                    // 瀑布流
                                    // child: WaterfallFlow.builder(
                                    //   primary: false,
                                    //   shrinkWrap: true,
                                    //   gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                                    //     crossAxisCount: 2,
                                    //     // 上下间隔
                                    //     mainAxisSpacing: 4.0,
                                    //     //   // 左右间隔
                                    //     crossAxisSpacing: 8.0,
                                    //   ),
                                    //   itemBuilder: (context, index) {
                                    //     if (index == feedList.length) {
                                    //       return LoadingView(
                                    //         loadText: loadText,
                                    //         loadStatus: loadStatus,
                                    //       );
                                    //     } else if (index == feedList.length + 1) {
                                    //       return Container();
                                    //     } else {
                                    //       return SearchFeeditem(
                                    //         model: feedList[index],
                                    //         list: feedList,
                                    //         index: index,
                                    //         pageName: "searchComplex",
                                    //       );
                                    //     }
                                    //   },
                                    //   itemCount: feedList.length + 1,
                                    // )
                                    child: ListView.builder(
                                        primary: false,
                                        shrinkWrap: true,
                                        itemCount: feedList.length + 1,
                                        itemBuilder: (context, index) {
                                          // HomeFeedModel model;
                                          // int id = model = context.read<FeedMapNotifier>().value.feedMap[id];
                                          if (index == feedList.length) {
                                            return LoadingView(
                                              loadText: loadText,
                                              loadStatus: loadStatus,
                                            );
                                          } else if (index == feedList.length + 1) {
                                            return Container();
                                          } else {
                                            return ExposureDetector(
                                              key: Key('search_complex_${feedList[index].id}'),
                                              child: DynamicListLayout(
                                                index: index,
                                                pageName: "searchComplex",
                                                isShowRecommendUser: false,
                                                isShowConcern: false,
                                                model: feedList[index],
                                                // 可选参数 子Item的个数
                                                key: GlobalObjectKey("attention$index"),
                                              ),
                                              onExposure: (visibilityInfo) {
                                                // 如果没有显示
                                                if (context
                                                    .read<FeedMapNotifier>()
                                                    .value
                                                    .feedMap[feedList[index].id]
                                                    .isShowInputBox) {
                                                  context.read<FeedMapNotifier>().showInputBox(feedList[index].id);
                                                }
                                                print('第$index 块曝光,展示比例为${visibilityInfo.visibleFraction}');
                                              },
                                            );
                                          }
                                        })
                                    // child: StaggeredGridView.countBuilder(
                                    //   shrinkWrap: true,
                                    //   itemCount: feedList.length + 1,
                                    //   primary: false,
                                    //   crossAxisCount: 4,
                                    //   // 上下间隔
                                    //   mainAxisSpacing: 4.0,
                                    //   // 左右间隔
                                    //   crossAxisSpacing: 8.0,
                                    //   itemBuilder: (context, index) {
                                    //     if (index == feedList.length) {
                                    //       return LoadingView(
                                    //         loadText: loadText,
                                    //         loadStatus: loadStatus,
                                    //       );
                                    //     } else if (index == feedList.length + 1) {
                                    //       return Container();
                                    //     } else {
                                    //       return SearchFeeditem(
                                    //         model: feedList[index],
                                    //         list: feedList,
                                    //         index: index,
                                    //         focusNode: widget.focusNode,
                                    //         pageName: "searchComplex",
                                    //       );
                                    //     }
                                    //   },
                                    //   staggeredTileBuilder: (index) => StaggeredTile.fit(2),
                                    // )
                                    )))),
                  ],
                )),
          );
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
