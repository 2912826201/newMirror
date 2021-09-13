import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/api.dart';
import 'package:mirror/api/topic/topic_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/config/config.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/data_response_model.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/string_util.dart';
import 'package:mirror/widget/overscroll_behavior.dart';
import 'package:mirror/widget/smart_refressher_head_footer.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class SearchTopic extends StatefulWidget {
  SearchTopic({Key key, this.keyWord, this.focusNode, this.textController, this.controller}) : super(key: key);
  final FocusNode focusNode;
  final TextEditingController textController;
  final TabController controller;
  final String keyWord;

  @override
  SearchTopicState createState() => SearchTopicState();
}

class SearchTopicState extends State<SearchTopic> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; //必须重写
  double lastScore;

  // 声明定时器
  Timer timer;
  List<TopicDtoModel> topicList = [];

  // 滑动控制器
  // ScrollController _scrollController = new ScrollController();

  // 是否存在下一页
  int hasNext;

  // 是否显示缺省图
  bool isShowDefaultMap;
  RefreshController _refreshController = RefreshController();
  String lastString;

// Token can be shared with different requests.
  CancelToken token = CancelToken();

  @override
  void deactivate() {
    print("State 被暂时从视图树中移除时");
    super.deactivate();
  }

  @override
  void initState() {
    requestFeedInterface(refreshOrLoading: true);
    int controllerIndex = 1;
    if (AppConfig.needShowTraining) {
      controllerIndex = 2;
    }
    print("widget.tabBarIndexList:::${Application.tabBarIndexList}");
    widget.controller.addListener(() {
      print("widget.tabBarIndexList话题:::${Application.tabBarIndexList}");
      // 切换tab监听在当前tarBarView下
      if (widget.controller.index == controllerIndex) {
        print(Application.tabBarIndexList.contains(controllerIndex));
        // 初始化过的文本变化
        if (Application.tabBarIndexList.contains(controllerIndex)) {
          print("lastString::::$lastString");
          print("widget.keyWord::::${widget.keyWord}");
          if (lastString != widget.keyWord) {
            if (topicList.isNotEmpty) {
              lastScore = null;
              hasNext = null;
            }
            requestFeedInterface(refreshOrLoading: true);
          }
        } else {
          Application.tabBarIndexList.add(controllerIndex);
        }
      }
    });
    widget.textController.addListener(() {
      // 输入文本时的监听要在当前tab下
      if (widget.controller.index == controllerIndex) {
        // 取消延时器
        if (timer != null) {
          timer.cancel();
        }
        // 延迟器:
        timer = Timer(Duration(milliseconds: 500), () {
          if (lastString != widget.keyWord) {
            lastScore = null;
            hasNext = null;
            requestFeedInterface(refreshOrLoading: true);
          }
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    print("话题页销毁了页面");
    // _scrollController.dispose();
    // 取消网络请求
    cancelRequests(token: token);

    ///取消延时任务
    if (timer != null) {
      timer.cancel();
    }
    super.dispose();
  }

  // 请求动态接口
  requestFeedInterface({bool refreshOrLoading}) async {
    if (hasNext != 0) {
      DataResponseModel model = await searchTopic(key: widget.keyWord, size: 20, lastScore: lastScore, token: token);
      if (refreshOrLoading) {
        topicList.clear();
      }
      if (model != null) {
        lastScore = model.lastScore;
        hasNext = model.hasNext;
        if (model.list.isNotEmpty) {
          // for (int i = 0; i < 5; i++) {
          model.list.forEach((v) {
            topicList.add(TopicDtoModel.fromJson(v));
          });
          // }
        }
        if (refreshOrLoading) {
          _refreshController.refreshCompleted();
        } else {
          _refreshController.loadComplete();
        }
      } else {
        if (refreshOrLoading) {
          _refreshController.refreshFailed();
        } else {
          _refreshController.loadFailed();
        }
      }
    }
    if (refreshOrLoading) {
      lastString = widget.keyWord;
    }
    if (hasNext == 0) {
      if (refreshOrLoading) {
        _refreshController.refreshCompleted();
        _refreshController.loadComplete();
      } else {
        _refreshController.loadComplete();
      }
    }
    if (topicList.length > 0) {
      isShowDefaultMap = false;
    } else {
      isShowDefaultMap = true;
    }
    print("topicList的长度：：：：${topicList.length}");
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return isShowDefaultMap == null
        ? Container()
        : !isShowDefaultMap
            ? Container(
                child: ScrollConfiguration(
                    behavior: OverScrollBehavior(),
                    child: SmartRefresher(
                        enablePullDown: true,
                        enablePullUp: true,
                        footer: SmartRefresherHeadFooter.init().getFooter(),
                        header: SmartRefresherHeadFooter.init().getHeader(),
                        controller: _refreshController,
                        onRefresh: () {
                          lastScore = null;
                          hasNext = null;
                          _refreshController.loadComplete();
                          requestFeedInterface(refreshOrLoading: true);
                        },
                        onLoading: () {
                          requestFeedInterface(refreshOrLoading: false);
                        },
                        child: CustomScrollView(
                            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                            // controller: _scrollController,
                            physics: AlwaysScrollableScrollPhysics(),
                            slivers: [
                              SliverToBoxAdapter(
                                  child: Container(
                                margin: const EdgeInsets.only(left: 16, right: 16),
                                child: MediaQuery.removePadding(
                                    removeTop: true,
                                    context: context,
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      primary: false,
                                      itemCount: topicList.length,
                                      itemBuilder: (context, index) {
                                        return SearchTopiciItem(
                                          model: topicList[index],
                                        );
                                        // }
                                      },
                                    )),
                              ))
                            ]))))
            : Container(
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
                      style: AppStyle.text1Regular14,
                    ),
                    const Text("换一个试一试", style: AppStyle.text1Regular14),
                  ],
                ),
              );
  }
}

class SearchTopiciItem extends StatelessWidget {
  SearchTopiciItem({this.model});

  TopicDtoModel model;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        FocusScope.of(context).requestFocus(FocusNode());
        TopicDtoModel topicModel = await getTopicInfo(topicId: model.id);
        AppRouter.navigateToTopicDetailPage(context, model.id);
      },
      child: Container(
        width: ScreenUtil.instance.width,
        margin: const EdgeInsets.only(left: 16, right: 16),
        padding: const EdgeInsets.only(top: 6, bottom: 6),
        // height: 54,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SizedBox(height: 6),
            Text(
              "#${model.name}",
              style: AppStyle.whiteRegular16,
            ),
            const SizedBox(height: 2),
            Text(
              "${StringUtil.getNumber(model.feedCount)}篇动态",
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColor.textWhite60),
            ),
            // SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}
