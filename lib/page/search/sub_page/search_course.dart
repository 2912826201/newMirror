import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/api.dart';
import 'package:mirror/api/search/search_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/data_response_model.dart';
import 'package:mirror/data/model/training/course_model.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/page/home/sub_page/recommend_page.dart';
import 'package:mirror/page/training/video_course/video_course_list_page.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/date_util.dart';
import 'package:mirror/widget/overscroll_behavior.dart';

class SearchCourse extends StatefulWidget {
  SearchCourse({Key key, this.keyWord, this.textController, this.focusNode,this.controller}) : super(key: key);
  FocusNode focusNode;
  TextEditingController textController;
  TabController controller;
  String keyWord;

  @override
  SearchCourseState createState() => SearchCourseState();
}

class SearchCourseState extends State<SearchCourse> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // 声明定时器
  Timer timer;
  List<CourseModel> liveVideoList = [];

  // 滑动控制器
  ScrollController _scrollController = new ScrollController();

  // 请求下一页
  int lastTime;

  // 是否有下一页
  int hasNext;

  // 加载中默认文字
  String loadText = "加载中...";

  // 加载状态
  LoadingStatus loadStatus = LoadingStatus.STATUS_IDEL;
  String lastString;

// Token can be shared with different requests.
  CancelToken token = CancelToken();

  @override
  void initState() {
    requestSearchCourse(refreshOrLoading: true);
    // 上拉加载
    _scrollController.addListener(() {
      if (widget.focusNode.hasFocus) {
        print('-------------------focusNode---focusNode----focusNode--focusNode');
        widget.focusNode.unfocus();
      }
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        requestSearchCourse(refreshOrLoading: false);
      }
    });
    widget.textController.addListener(() {
      // if(widget.controller.index == 1) {
        // 取消延时器
        if (timer != null) {
          timer.cancel();
        }
        // 延迟器:
        timer = Timer(Duration(milliseconds: 700), () {
          if (lastString != widget.keyWord) {
            if (liveVideoList.isNotEmpty) {
              lastTime = null;
              hasNext = null;
            }
            requestSearchCourse(refreshOrLoading: true);
          }
        });
        lastString = widget.keyWord;
      // }
    });
    super.initState();
  }

  @override
  void dispose() {
    print("课程页销毁了页面");
    _scrollController.dispose();
    // 取消网络请求
    cancelRequests(token: token);

    ///取消延时任务
    if (timer != null) {
      timer.cancel();
    }
    super.dispose();
  }

  // 请求搜索课程接口
  requestSearchCourse({bool refreshOrLoading}) async {
    if (hasNext != 0) {
      if (loadStatus == LoadingStatus.STATUS_IDEL) {
        // 先设置状态，防止下拉就直接加载
        setState(() {
          loadStatus = LoadingStatus.STATUS_LOADING;
        });
      }
      DataResponseModel model = await searchCourse(key: widget.keyWord, size: 20, lastTime: lastTime, token: token);
      if (refreshOrLoading) {
        liveVideoList.clear();
      }
      if (model != null) {
        lastTime = model.lastTime;
        hasNext = model.hasNext;
        if (model.list.length != 0) {
          model.list.forEach((v) {
            liveVideoList.add(CourseModel.fromJson(v));
          });
          loadStatus = LoadingStatus.STATUS_IDEL;
          loadText = "加载中...";
        }
      }
    }
    if (hasNext == 0) {
      loadText = "已加载全部课程";
      loadStatus = LoadingStatus.STATUS_COMPLETED;
      print("返回不请求数据");
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (liveVideoList.isNotEmpty) {
      return Container(
          child: ScrollConfiguration(
              behavior: OverScrollBehavior(),
              child: RefreshIndicator(
                  onRefresh: () async {
                    lastTime = null;
                    hasNext = null;
                    loadStatus = LoadingStatus.STATUS_LOADING;
                    loadText = "加载中...";
                    requestSearchCourse(refreshOrLoading: true);
                  },
                  child: CustomScrollView(
                      controller: _scrollController,
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                                itemCount: liveVideoList.length + 1,
                                itemBuilder: (context, index) {
                                  // if (feedList.isNotEmpty) {
                                  if (index == liveVideoList.length) {
                                    return LoadingView(
                                      loadText: loadText,
                                      loadStatus: loadStatus,
                                    );
                                  } else if (index == liveVideoList.length + 1) {
                                    return Container();
                                  } else {
                                    return SearchCourseItem(
                                      videoModel: liveVideoList[index],
                                      index: index,
                                      count: liveVideoList.length,
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
              decoration: BoxDecoration(
                image: DecorationImage(image: AssetImage("assets/png/default_no_data.png"), fit: BoxFit.cover),
              ),
              margin: const EdgeInsets.only(bottom: 16),
            ),
            const Text(
              "你的放大镜陨落星辰了",
              style: TextStyle(fontSize: 14, color: AppColor.textWhite60),
            ),
            const Text("换一个试一试", style: TextStyle(color: AppColor.textWhite60, fontSize: 14)),
          ],
        ),
      );
    }
  }
}

class SearchCourseItem extends StatefulWidget {
  SearchCourseItem({Key key, this.index, this.count, this.videoModel}) : super(key: key);
  CourseModel videoModel;
  int index;
  int count;

  @override
  SearchCourseItemState createState() => SearchCourseItemState();
}

class SearchCourseItemState extends State<SearchCourseItem> {
  EdgeInsetsGeometry firstMargin = const EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 6);
  EdgeInsetsGeometry commonMargin = const EdgeInsets.only(left: 16, right: 16, top: 6, bottom: 6);
  EdgeInsetsGeometry endMargin = const EdgeInsets.only(left: 16, right: 16, top: 6, bottom: 16);

  //hero动画的标签
  var heroTagArray = <String>[];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        color: AppColor.transparent,
        width: MediaQuery.of(context).size.width,
        margin: widget.index == widget.count - 1 ? endMargin : (widget.index == 0 ? firstMargin : commonMargin),
        child: Row(
          children: [
            buildVideoCourseItemLeftImageUi(widget.videoModel, getHeroTag(widget.videoModel, widget.index)),
            buildVideoCourseItemRightDataUi(widget.videoModel, 90, false),
          ],
        ),
      ),
      onTap: () {
        //点击事件
        print("====heroTagArray[index]:${heroTagArray[widget.index]}");
        AppRouter.navigateToVideoDetail(context, widget.videoModel.id,
            heroTag: heroTagArray[widget.index], videoModel: widget.videoModel);
      },
    );
  }

  //给hero的tag设置唯一的值
  Object getHeroTag(CourseModel videoModel, index) {
    if (heroTagArray != null && heroTagArray.length > index) {
      return heroTagArray[index];
    } else {
      String string = "heroTag_video_${DateUtil.getNowDateMs()}_${Random().nextInt(100000)}_${videoModel.id}_$index";
      heroTagArray.add(string);
      return string;
    }
  }
}
