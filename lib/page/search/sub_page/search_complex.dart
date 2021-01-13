import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/api/search/search_api.dart';
import 'package:mirror/api/topic/topic_api.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/data_response_model.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/data/model/profile/searchuser_model.dart';
import 'package:mirror/data/model/user_model.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/page/home/sub_page/recommend_page.dart';
import 'package:mirror/page/search/sub_page/search_feed.dart';
import 'package:mirror/page/search/sub_page/search_user.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:provider/provider.dart';
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
  List<CourseDtoModel> courseList = [];

  // 声明定时器
  Timer timer;
  String lastString;

  // 滑动控制器
  ScrollController _scrollController = new ScrollController();

  // 数据加载页数
  int dataPage = 1;

// 加载中默认文字
  String loadText = "加载中...";

  // 加载状态
  LoadingStatus loadStatus = LoadingStatus.STATUS_IDEL;
  int lastTime;

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
          courseList.clear();
          userList.clear();
          topicList.clear();
          feedList.clear();
          mergeRequest();
        }
        lastString = widget.keyWord;
      });
    });
    // 上拉加载
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        dataPage += 1;
        requestFeednIterface();
      }
    });
    super.initState();
  }

  // 合并请求
  mergeRequest() async {
    Future.wait([
      // 请求相关用户
      ProfileSearchUser(widget.keyWord, 3),
      // 请求相关话题
      searchTopic(key: widget.keyWord, size: 3),
      // 请求相关动态
      searchFeed(key: widget.keyWord, size: 20),
      // 请求相关课程
      // searchCourse(key: widget.keyWord, size: 2),
    ]).then((results) {
      SearchUserModel userModel;
      userModel = results[0];
      DataResponseModel topicModel = results[1];
      DataResponseModel feedModel = results[2];
      // DataResponseModel courseModel = results[3];
      // if (courseModel != null && courseModel.list != null) {
      //   courseModel.list.forEach((v) {
      //     courseList.add(CourseDtoModel.fromJson(v));
      //   });
      // }
      if (userModel != null && userModel.list.isNotEmpty) {
        userList = userModel.list;
      }
      if (topicModel != null && topicModel.list.isNotEmpty) {
        topicModel.list.forEach((v) {
          topicList.add(TopicDtoModel.fromJson(v));
        });
      }
      if (feedModel != null && feedModel.list.isNotEmpty) {
        feedModel.list.forEach((v) {
          feedList.add(HomeFeedModel.fromJson(v));
          lastTime = feedModel.lastTime;
        });
      }
      // 更新全局监听
      context.read<FeedMapNotifier>().updateFeedMap(feedList);
      setState(() {});
    }).catchError((e) {
      print("报错了");
      print(e);
    });
  }

  // 请求动态接口
  requestFeednIterface() async {
    if (loadStatus == LoadingStatus.STATUS_IDEL) {
      // 先设置状态，防止下拉就直接加载
      setState(() {
        loadStatus = LoadingStatus.STATUS_LOADING;
      });
    }
    if (dataPage > 1 && lastTime == null) {
      loadText = "已加载全部动态";
      print("返回不请求数据");
      return;
    }
    DataResponseModel model = await searchFeed(key: widget.keyWord, size: 20, lastTime: lastTime);

    setState(() {
      print("dataPage:  ￥￥$dataPage");
      if (dataPage == 1) {
        if (model.list.isNotEmpty) {
          print(model.list.length);
          model.list.forEach((v) {
            feedList.add(HomeFeedModel.fromJson(v));
          });
        }
      } else if (dataPage > 1 && lastTime != null) {
        if (model.list.isNotEmpty) {
          model.list.forEach((v) {
            feedList.add(HomeFeedModel.fromJson(v));
          });
          loadStatus = LoadingStatus.STATUS_IDEL;
          loadText = "加载中...";
        } else {
          // 加载完毕
          loadText = "已加载全部动态";
          loadStatus = LoadingStatus.STATUS_COMPLETED;
        }
      }
    });
    lastTime = model.lastTime;
    // 更新全局监听
    context.read<FeedMapNotifier>().updateFeedMap(feedList);
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      child: CustomScrollView(
        controller:_scrollController ,
        slivers: [
          SliverToBoxAdapter(
              child: Offstage(
            offstage: courseList.length == 0,
            child: ItemTitle("相关课程", 12, 1, widget.controller),
          )),
          SliverList(
            delegate: SliverChildBuilderDelegate((content, index) {
              return Offstage(
                  offstage: courseList.length == 0,
                  child: Container(
                    height: 90,
                    width: ScreenUtil.instance.width - 32,
                    margin: EdgeInsets.only(left: 16, right: 16),
                    color: Colors.primaries[index % Colors.primaries.length],
                    child: Text(
                      '$index',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ));
            }, childCount: courseList.length),
          ),
          SliverToBoxAdapter(
              child: Offstage(offstage: userList.length == 0, child: ItemTitle("相关用户", 16, 4, widget.controller))),
          SliverList(
              delegate: SliverChildBuilderDelegate((content, index) {
            return Offstage(
                offstage: userList.length == 0,
                child: Container(
                    width: ScreenUtil.instance.width,
                    margin: EdgeInsets.only(left: 16, right: 16),
                    child: SearchUserItem(
                      model: userList[index],
                      width: ScreenUtil.instance.width,
                    )));
          }, childCount: userList.length)),
          SliverToBoxAdapter(
              child: Offstage(offstage: topicList.length == 0, child: ItemTitle("相关话题", 16, 2, widget.controller))),
          SliverList(
              delegate: SliverChildBuilderDelegate((content, index) {
            return Offstage(
                offstage: topicList.length == 0,
                child: SearchTopiciItem(
                  model: topicList[index],
                ));
          }, childCount: topicList.length)),
          SliverToBoxAdapter(
              child: Offstage(offstage: feedList.length == 0, child: ItemTitle("相关动态", 16, 3, widget.controller))),
          SliverToBoxAdapter(
              child: Offstage(
                  offstage: feedList.length == 0,
                  child: Container(
                      margin: EdgeInsets.only(left: 16, right: 16),
                      child: StaggeredGridView.countBuilder(
                        shrinkWrap: true,
                        itemCount: feedList.length + 1,
                        primary: false,
                        crossAxisCount: 4,
                        // 上下间隔
                        mainAxisSpacing: 4.0,
                        // 左右间隔
                        crossAxisSpacing: 8.0,
                        itemBuilder: (context, index) {
                          if (index == feedList.length) {
                            return LoadingView(
                              loadText: loadText,
                              loadStatus: loadStatus,
                            );
                          } else if (index == feedList.length + 1) {
                            return Container();
                          } else {
                            return SearchFeeditem(
                              model: feedList[index],
                              list: feedList,
                              index: index,
                              focusNode: widget.focusNode,
                              isComplex: true,
                            );
                          }
                        },
                        staggeredTileBuilder: (index) => StaggeredTile.fit(2),
                      )))),
        ],
      ),
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
          Spacer(),
          GestureDetector(
            onTap: () {
              print("跳转");
              widget.controller.index = widget.initialIndex;
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("更多", style: AppStyle.textSecondaryRegular13),
                SizedBox(width: 6),
                Image.asset(
                  "images/resource/2.0x/delete_icon_black@2x.png",
                  width: 16,
                  height: 16,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
