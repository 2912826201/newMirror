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
import 'package:mirror/page/topic/topic_detail.dart';
import 'package:mirror/util/screen_util.dart';

class SearchTopic extends StatefulWidget {
  SearchTopic({Key key, this.keyWord, this.focusNode,this.textController}) : super(key: key);
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

  // 数据加载页数
  int dataPage = 1;

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
        dataPage += 1;
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
            dataPage = 1;
          }
          requestFeednIterface();
        }
        lastString = widget.keyWord;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    print("销毁了页面");

    ///取消延时任务
    timer.cancel();
    super.dispose();
  }

  // 请求动态接口
  requestFeednIterface() async {
    if (loadStatus == LoadingStatus.STATUS_IDEL) {
      // 先设置状态，防止下拉就直接加载
      setState(() {
        loadStatus = LoadingStatus.STATUS_LOADING;
      });
    }
    if (dataPage > 1 && lastScore == null) {
      loadText = "已加载全部动态";
      print("返回不请求数据");
      return;
    }
    DataResponseModel model = await searchTopic(key: widget.keyWord, size: 20, lastScore: lastScore);

    setState(() {
      print("dataPage:  ￥￥$dataPage");
      if (dataPage == 1) {
        if (model.list.isNotEmpty) {
          print(model.list.length);
          model.list.forEach((v) {
            topicList.add(TopicDtoModel.fromJson(v));
          });
          if (model.hasNext == 0) {
            loadText = "";
            loadStatus = LoadingStatus.STATUS_COMPLETED;
          }
        }
      } else if (dataPage > 1 && lastScore != null) {
        if (model.list.isNotEmpty) {
          model.list.forEach((v) {
            topicList.add(TopicDtoModel.fromJson(v));
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
    lastScore = model.lastScore;
  }

  @override
  Widget build(BuildContext context) {

    if (topicList.isNotEmpty) {
      return Container(
          child: RefreshIndicator(
              onRefresh: () async {
                topicList.clear();
                lastScore = null;
                dataPage = 1;
                loadStatus = LoadingStatus.STATUS_LOADING;
                loadText = "加载中...";
                requestFeednIterface();
              },
              child:
                  CustomScrollView(controller: _scrollController, physics: AlwaysScrollableScrollPhysics(), slivers: [
                SliverToBoxAdapter(
                    child: Container(
                  margin: EdgeInsets.only(left: 16, right: 16),
                  child: MediaQuery.removePadding(
                      removeTop: true,
                      context: context,
                      child: ListView.builder(
                        shrinkWrap: true,
                        primary: false,
                        itemCount: topicList.length + 1,
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
              ])));
    } else {
      return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 224,
              height: 224,
              color: AppColor.color246,
              margin: EdgeInsets.only(bottom: 16, top: 188),
            ),
            Text(
              "这里空空如也，去推荐看看吧",
              style: TextStyle(fontSize: 14, color: AppColor.textSecondary),
            ),
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
    return  GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          new MaterialPageRoute(builder: (context) => TopicDetail(topicId: model.id,)),
        );
      },
      child: Container(
        color: AppColor.mainRed,
        width: ScreenUtil.instance.width,
        margin: EdgeInsets.only(left: 16, right: 16),
        padding: EdgeInsets.only(top: 6,bottom: 6),
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
            SizedBox(height: 2),
            Text(
              "${model.feedCount}篇动态",
              style: AppStyle.textHintRegular12,
            ),
            // SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}
