import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/topic/topic_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/data_response_model.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/page/home/sub_page/recommend_page.dart';
import 'package:mirror/page/profile/overscroll_behavior.dart';
import 'package:mirror/page/topic/topic_detail.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/string_util.dart';
import 'package:mirror/widget/Input_method_rules/pin_yin_text_edit_controller.dart';

class SearchTopic extends StatefulWidget {
  SearchTopic({Key key, this.keyWord, this.focusNode, this.textController}) : super(key: key);
  FocusNode focusNode;
  TextEditingController textController;
  String keyWord;

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
  ScrollController _scrollController = new ScrollController();

  // 是否存在下一页
  int hasNext;

// 加载中默认文字
  String loadText = "加载中...";

  // 加载状态
  LoadingStatus loadStatus = LoadingStatus.STATUS_IDEL;
  String lastString;

  @override
  void deactivate() {
    print("State 被暂时从视图树中移除时");
    super.deactivate();
  }

  @override
  void initState() {
    requestFeednIterface();
    // 上拉加载
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        requestFeednIterface();
      }
    });
    widget.textController.addListener(() {
      // 取消延时器
      if (timer != null) {
        timer.cancel();
      }
      // 延迟器:
      timer = Timer(Duration(milliseconds: 700), () {
        if (lastString != widget.keyWord) {
          if (topicList.isNotEmpty) {
            print("333333333333333333333");
            topicList.clear();
            lastScore = null;
            hasNext = null;
          }
          requestFeednIterface();
        }
      });
      lastString = widget.keyWord;
    });
    super.initState();
  }

  @override
  void dispose() {
    print("话题页销毁了页面");
    _scrollController.dispose();

    ///取消延时任务
    if (timer != null) {
      timer.cancel();
    }
    super.dispose();
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
      DataResponseModel model = await searchTopic(key: widget.keyWord, size: 20, lastScore: lastScore);
      lastScore = model.lastScore;
      hasNext = model.hasNext;
      if (model.list.isNotEmpty) {
        model.list.forEach((v) {
          topicList.add(TopicDtoModel.fromJson(v));
        });
        loadStatus = LoadingStatus.STATUS_IDEL;
        loadText = "加载中...";
      }
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

  @override
  Widget build(BuildContext context) {
    if (topicList.isNotEmpty) {
      return Container(
          child: ScrollConfiguration(
              behavior: OverScrollBehavior(),
              child: RefreshIndicator(
                  onRefresh: () async {
                    topicList.clear();
                    lastScore = null;
                    hasNext = null;
                    loadStatus = LoadingStatus.STATUS_LOADING;
                    loadText = "加载中...";
                    requestFeednIterface();
                  },
                  child: CustomScrollView(
                      controller: _scrollController,
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
                                itemCount: topicList.length + 1,
                                itemExtent: 56,
                                itemBuilder: (context, index) {
                                  // if (feedList.isNotEmpty) {
                                  if (index == topicList.length) {
                                    return LoadingView(
                                      loadText: loadText,
                                      loadStatus: loadStatus,
                                    );
                                  } else if (index == topicList.length + 1) {
                                    return Container();
                                  } else {
                                    return SearchTopiciItem(
                                      model: topicList[index],
                                    );
                                  }
                                  // }
                                },
                              )),
                        ))
                      ]))));
    } else {
      return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 224,
              height: 224,
              color: AppColor.color246,
              // margin: EdgeInsets.only(bottom: 16, top: 188),
            ),
            const Text(
              "你的放大镜陨落星辰了",
              style: TextStyle(fontSize: 14, color: AppColor.textSecondary),
            ),
            const Text("换一个试一试", style: TextStyle(color: AppColor.textSecondary, fontSize: 14)),
          ],
        ),
      );
    }
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
        AppRouter.navigateToTopicDetailPage(context, topicModel);
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
              style: AppStyle.textRegular16,
            ),
            const SizedBox(height: 2),
            Text(
              "${StringUtil.getNumber(model.feedCount)}篇动态",
              style: AppStyle.textHintRegular12,
            ),
            // SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}
