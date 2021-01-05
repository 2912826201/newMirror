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
import 'package:mirror/data/model/profile/searchuser_model.dart';
import 'package:mirror/data/model/user_model.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/page/search/sub_page/search_feed.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:provider/provider.dart';
import 'search_topic.dart';

class SearchComplex extends StatefulWidget {
  SearchComplex({Key key, this.keyWord, this.focusNode, this.textController,this.controller}) : super(key: key);
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
      searchFeed(key: widget.keyWord, size: 4),
      // 请求相关课程
      // searchCourse(key: widget.keyWord, size: 2),
    ]).then((results) {
      print("历史记录（（（（（（（）））））");
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

  @override
  Widget build(BuildContext context) {
    return Container(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
              child: Offstage(
            offstage: courseList.length == 0,
            child: ItemTitle("相关课程", 12,1,widget.controller),
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
          SliverToBoxAdapter(child: Offstage(offstage: userList.length == 0, child: ItemTitle("相关用户", 16,4,widget.controller))),
          SliverList(
              delegate: SliverChildBuilderDelegate((content, index) {
            return Offstage(
                offstage: userList.length == 0,
                child: Container(
                  height: 48,
                  width: ScreenUtil.instance.width - 32,
                  margin: EdgeInsets.only(left: 16, right: 16),
                  color: Colors.primaries[index % Colors.primaries.length],
                  child: Text(
                    '$index',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ));
          }, childCount: userList.length)),
          SliverToBoxAdapter(child: Offstage(offstage: topicList.length == 0, child: ItemTitle("相关话题", 16,2,widget.controller))),
          SliverList(
              delegate: SliverChildBuilderDelegate((content, index) {
            return Offstage(
                offstage: topicList.length == 0,
                child: SearchTopiciItem(
                  model: topicList[index],
                ));
          }, childCount: topicList.length)),
          SliverToBoxAdapter(child: Offstage(offstage: feedList.length == 0, child: ItemTitle("相关动态", 16,3,widget.controller))),
          SliverToBoxAdapter(
              child: Offstage(
                  offstage: feedList.length == 0,
                  child: Container(
                      margin: EdgeInsets.only(left: 16, right: 16),
                      child: StaggeredGridView.countBuilder(
                        shrinkWrap: true,
                        itemCount: feedList.length,
                        primary: false,
                        crossAxisCount: 4,
                        // 上下间隔
                        mainAxisSpacing: 4.0,
                        // 左右间隔
                        crossAxisSpacing: 8.0,
                        itemBuilder: (context, index) {
                          // if (feedList.isNotEmpty) {
                          return SearchFeeditem(
                            model: feedList[index],
                            index: index,
                            focusNode: widget.focusNode,
                              isComplex:true
                          );
                        },
                        staggeredTileBuilder: (index) => StaggeredTile.fit(2),
                      )))),
        ],
      ),
    );
  }
}
class ItemTitle extends StatefulWidget {
  ItemTitle(this.title, this.top,this.initialIndex,this.controller);
  int initialIndex;
  String title;
  double top;
  TabController controller;
  @override
  ItemTitleState createState() => ItemTitleState();

}
class ItemTitleState extends State<ItemTitle> with SingleTickerProviderStateMixin{


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
