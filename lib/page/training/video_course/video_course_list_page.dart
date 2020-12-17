import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/live_broadcast/live_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/live_model.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/data/model/video_tag_madel.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/date_util.dart';
import 'package:mirror/util/toast_util.dart';

/// 视频课程列表-筛选页
class VideoCourseListPage extends StatefulWidget {
  static LiveModel videoModel;

  @override
  createState() => new VideoCourseListPageState();
}

class VideoCourseListPageState extends State<VideoCourseListPage> {
  //选择的所有标签
  List<VideoSubTagModel> _titleItemList = <VideoSubTagModel>[];
  String _titleItemString = "课程筛选";
  String _targetTitleItemString = "目标";
  String _partTitleItemString = "部位";
  String _levelTitleItemString = "难度";

  //当前显示的直播课程的list
  var videoModelArray = <LiveModel>[];

  //头部标签
  VideoTagModel videoTagModel;

  //状态
  LoadingStatus loadingStatus;

  //hero动画的标签
  var heroTagArray = <String>[];

  //滚动的监听事件
  ScrollController scrollController = new ScrollController();

  //头部 每一个筛选item的高度
  double topTitleItemHeight = 40.0;

  //返回顶部bar的透明度
  double topItemOpacity = 0.0;

  //返回顶部bar每次都使用的高度
  double topItemHeight = 0.0;

  //返回顶部bar的高度 给topItemHeight 设置高度的值
  double topItemHeight1 = 50.0;

  //当滑动到什么距离需要显示返回顶部的bar
  double showBackTopBoxHeight = 0.0;

  //是否还有下一页的数据
  bool isHaveNextPageData = true;

  //是否在加载下一页的数据中
  bool isLoadAddNextPageData = false;

  //每一页获取的数量
  int pageSize = 5;

  //一些通用的属性
  var marginCommonly = const EdgeInsets.only(left: 3, right: 3);
  var topTitleItem =
      const EdgeInsets.only(left: 10, right: 10, top: 2, bottom: 2);
  var topTitleItemSelect = BoxDecoration(
    borderRadius: BorderRadius.circular(50),
    color: Colors.cyanAccent,
  );
  var topTitleItemNoSelect = BoxDecoration(
    borderRadius: BorderRadius.circular(50),
    color: AppColor.textHint,
  );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    videoTagModel = Application.videoTagModel;
    if (videoTagModel == null) {
      showBackTopBoxHeight = 20;
    } else {
      showBackTopBoxHeight = topTitleItemHeight * 4;
    }
    loadingStatus = LoadingStatus.STATUS_LOADING;
    getLiveModelData();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("课程库"),
        centerTitle: true,
        actions: [
          Container(
            width: 80,
            height: double.infinity,
            child: IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                ToastShow.show(msg: "搜索界面", context: context);
              },
            ),
          )
        ],
      ),
      body: _buildSuggestions(),
    );
  }

  //判断获取什么布局
  Widget _buildSuggestions() {
    if (loadingStatus == LoadingStatus.STATUS_COMPLETED) {
      return Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            Positioned(
              child: _getListBoxUi(),
              left: 0,
              top: 0,
            ),
            Positioned(
              child: _getTopBackItemBoxUi(),
            ),
          ],
        ),
      );
    } else {
      var columnArray = <Widget>[];
      if (videoTagModel != null) {
        columnArray.add(
          _getScreenTitleUi(),
        );
      }
      if (loadingStatus == LoadingStatus.STATUS_LOADING) {
        columnArray.add(Expanded(
            child: SizedBox(
          child: UnconstrainedBox(
            child: CircularProgressIndicator(),
          ),
        )));
      } else {
        columnArray.add(Expanded(
            child: SizedBox(
          child: UnconstrainedBox(
            child: Text("暂无数据"),
          ),
        )));
      }
      return Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: columnArray,
        ),
      );
    }
  }

  //获取滑动列表的框架
  Widget _getListBoxUi() {
    var sliverToBoxAdapterArray = <Widget>[];
    if (videoTagModel != null) {
      sliverToBoxAdapterArray.add(
        SliverToBoxAdapter(
          child: _getScreenTitleUi(),
        ),
      );
    }
    sliverToBoxAdapterArray.add(SliverToBoxAdapter(
      child: _getLiveBroadcastUI(videoModelArray),
    ));

    return NotificationListener<ScrollNotification>(
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: CustomScrollView(
          controller: scrollController,
          scrollDirection: Axis.vertical,
          slivers: sliverToBoxAdapterArray,
        ),
      ),
      onNotification: (ScrollNotification notification) {
        ScrollMetrics metrics = notification.metrics;

        if (metrics.axisDirection == AxisDirection.up ||
            metrics.axisDirection == AxisDirection.down) {
          // 注册通知回调
          if (notification is ScrollStartNotification) {
            // 滚动开始
            // print('滚动开始');
          } else if (notification is ScrollUpdateNotification) {
            // 滚动位置更新
            // print('滚动位置更新');
            // 当前位置
            print("当前位置${metrics.pixels}");
            if (metrics.pixels > showBackTopBoxHeight) {
              if (metrics.pixels - showBackTopBoxHeight > topItemHeight) {
                topItemOpacity = 1.0;
              } else {
                topItemOpacity =
                    (metrics.pixels - showBackTopBoxHeight) /
                        topTitleItemHeight;
                if (topItemOpacity > 1) {
                  topItemOpacity = 1.0;
                }
              }
            } else {
              topItemOpacity = 0.0;
            }
            setState(() {
              if (topItemOpacity == 0) {
                topItemHeight = 0;
              } else if (metrics.pixels > showBackTopBoxHeight &&
                  topItemHeight == 0) {
                topItemHeight = topItemHeight1;
                topItemOpacity = 0.0;
              }
            });
          } else if (notification is ScrollEndNotification) {
            // 滚动结束
            // print('滚动结束');
          }
        }
        return false;
      },
    );
  }

  //顶部返回列表顶部按的box
  Widget _getTopBackItemBoxUi() {
    print(
        "topItemOpacity---${topItemOpacity}:*****topItemHeight:${topItemHeight}");
    return Opacity(
      opacity: topItemOpacity,
      child: GestureDetector(
        child: Container(
          color: Colors.cyanAccent,
          width: double.infinity,
          height: topItemHeight,
        ),
        onTap: () {
          scrollController.animateTo(0.0,
              duration: Duration(milliseconds: 300), curve: Curves.ease);
        },
      ),
    );
  }

  //顶部筛选的列表
  Widget _getScreenTitleUi() {
    return Column(
      children: [
        _firstTopTimeItemView(),
        _getTopTitleItem(_targetTitleItemString, videoTagModel.target),
        _getTopTitleItem(_partTitleItemString, videoTagModel.part),
        _getTopTitleItem(_levelTitleItemString, videoTagModel.level),
      ],
    );
  }

  //每一条筛选的item
  Widget _getTopTitleItem(
      String title, List<VideoSubTagModel> videoSubTagList) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: topTitleItemHeight,
      child: Row(
        children: [
          SizedBox(
            width: 16,
          ),
          Text(
            title,
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
              child: SizedBox(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: videoSubTagList.length,
              itemBuilder: (context, pos) {
                return initItemView(videoSubTagList[pos], pos,
                    videoSubTagList.length, topTitleItemHeight);
              },
            ),
          ))
        ],
      ),
    );
  }

  //每一个筛选的按钮
  Widget initItemView(
      VideoSubTagModel value, int pos, int itemCount, double itemHeight) {
    return GestureDetector(
      child: Container(
        margin: marginCommonly,
        child: Center(
          child: Container(
            padding: topTitleItem,
            decoration: _titleItemList.contains(value)
                ? topTitleItemSelect
                : topTitleItemNoSelect,
            child: Text(
              value.name,
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
      ),
      onTap: () {
        print(value.name);
        if (_titleItemList.contains(value)) {
          _titleItemList.remove(value);
        } else {
          _titleItemList.add(value);
        }
        resetScreenData();
      },
    );
  }

  //已经选择的筛选列表
  Widget _firstTopTimeItemView() {
    var rowItemArray = <Widget>[];
    for (int i = 0; i < _titleItemList.length; i++) {
      rowItemArray.add(Center(
        child: _firstTopTitleItem(_titleItemList[i], i, _titleItemList.length),
      ));
    }
    return Container(
      width: double.infinity,
      height: topTitleItemHeight,
      margin: const EdgeInsets.only(left: 16, right: 16),
      child: Center(
        child: Row(
          children: [
            Text(
              _titleItemString,
              style: TextStyle(fontSize: 18),
            ),
            Expanded(
                child: SizedBox(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: rowItemArray,
                ),
              ),
            )),
            GestureDetector(
              child: Row(
                children: [
                  Icon(Icons.delete_forever),
                  Text(
                    "清空",
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
              onTap: () {
                print("点击事件");
                print("_titleItemList:${_titleItemList.length}");
                _titleItemList.clear();
                resetScreenData();
              },
            )
          ],
        ),
      ),
    );
  }

  //已经选择的筛选列表的item
  Widget _firstTopTitleItem(VideoSubTagModel value, int index, int count) {
    return GestureDetector(
      child: Container(
        margin: marginCommonly,
        padding: topTitleItem,
        decoration: topTitleItemSelect,
        child: Text(
          value.name,
          style: TextStyle(fontSize: 18),
        ),
      ),
      onTap: () {
        if (_titleItemList.contains(value)) {
          _titleItemList.remove(value);
        }
        setState(() {});
      },
    );
  }

  //获取列表ui
  Widget _getLiveBroadcastUI(List<LiveModel> liveList) {
    var imageWidth = 120;
    var imageHeight = 90;
    var columnArray = <Widget>[];
    heroTagArray.clear();
    for (int i = 0; i < liveList.length; i++) {
      columnArray.add(GestureDetector(
        child: Container(
          color: AppColor.transparent,
          height: imageHeight.toDouble(),
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.only(left: 16, right: 16, top: 6, bottom: 6),
          child: Row(
            children: [
              _getItemLeftImageUi(liveList[i], imageWidth, imageHeight, i),
              _getRightDataUi(liveList[i], imageWidth, imageHeight, i),
            ],
          ),
        ),
        onTap: () {
          VideoCourseListPage.videoModel = liveList[i];
          AppRouter.navigateToVideoDetail(
              context, heroTagArray[i], liveList[i].id, liveList[i].courseId);
        },
      ));
    }

    columnArray.add(SizedBox(
      height: 160,
    ));
    return Container(
      child: Column(
        children: columnArray,
      ),
    );
  }

  //获取left的图片
  Widget _getItemLeftImageUi(
      LiveModel value, int imageWidth, int imageHeight, int index) {
    return Container(
      width: imageWidth.toDouble(),
      child: Hero(
        child: Image.asset(
          "images/test/bg.png",
          width: imageWidth.toDouble(),
          height: imageHeight.toDouble(),
          fit: BoxFit.cover,
        ),
        tag: getHeroTag(value, index),
      ),
    );
  }

  //获取右边数据的ui
  Widget _getRightDataUi(
      LiveModel value, int imageWidth, int imageHeight, int index) {
    return Expanded(
        child: SizedBox(
      child: Container(
        margin: const EdgeInsets.only(left: 12),
        height: imageHeight.toDouble(),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              child: Text(
                value.name,
                style: TextStyle(
                  fontSize: 15,
                  color: AppColor.textPrimary1,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
                child: SizedBox(
              child: Container(
                padding: const EdgeInsets.only(top: 6),
                width: double.infinity,
                height: double.infinity,
                child: Stack(
                  children: [
                    Positioned(
                      child: Row(
                        children: [
                          Container(
                            //类型
                            child: Text(
                              value.coursewareDto?.targetDto?.name,
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColor.textPrimary1,
                              ),
                            ),
                            padding: const EdgeInsets.only(
                                top: 1, bottom: 1, left: 5, right: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(1),
                              color: AppColor.textHint.withOpacity(0.34),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Container(
                            child: Text(
                              "${value.coursewareDto?.calories}千卡",
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColor.textPrimary1,
                              ),
                            ),
                            padding: const EdgeInsets.only(
                                top: 1, bottom: 1, left: 5, right: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(1),
                              color: AppColor.textHint.withOpacity(0.34),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Container(
                            child: Text(
                              "${value.coursewareDto?.levelDto?.name}",
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColor.textPrimary1,
                              ),
                            ),
                            padding: const EdgeInsets.only(
                                top: 1, bottom: 1, left: 5, right: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(1),
                              color: AppColor.textHint.withOpacity(0.34),
                            ),
                          ),
                        ],
                      ),
                      top: 0,
                      left: 0,
                    ),
                    Positioned(
                      child: Text(
                        value.coachDto?.nickName,
                        style: TextStyle(
                            fontSize: 12, color: AppColor.textPrimary2),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      bottom: 0,
                      left: 0,
                      right: 8,
                    )
                  ],
                ),
              ),
            )),
          ],
        ),
      ),
    ));
  }

// 获取指定日期的直播日程
  getLiveModelData() async {
    if (videoModelArray != null && videoModelArray.length > 0) {
      return;
    }
    //title
    if (videoTagModel == null) {
      try {
        Map<String, dynamic> videoCourseTagMap = await getAllTags();
        Application.videoTagModel = VideoTagModel.fromJson(videoCourseTagMap);
        videoTagModel = Application.videoTagModel;
        if (videoTagModel == null) {
          showBackTopBoxHeight = 20;
        } else {
          showBackTopBoxHeight = topTitleItemHeight * 4;
        }
      } catch (e) {
        videoTagModel = null;
        showBackTopBoxHeight = 20;
      }
    }

    try {
      List<int> _level = <int>[];
      List<int> _part = <int>[];
      List<int> _target = <int>[];
      for (int i = 0; i < _titleItemList.length; i++) {
        if (_titleItemList[i].type == 0) {
          _level.add(_titleItemList[i].id);
        } else if (_titleItemList[i].type == 1) {
          _part.add(_titleItemList[i].id);
        } else if (_titleItemList[i].type == 2) {
          _target.add(_titleItemList[i].id);
        }
      }
      Map<String, dynamic> model = await getVideoCourseList(
          size: pageSize, target: _target, part: _part, level: _level);
      if (model != null && model["list"] != null) {
        model["list"].forEach((v) {
          videoModelArray.add(LiveModel.fromJson(v));
        });
      }
    } catch (e) {}

    if (videoModelArray.length > 0) {
      loadingStatus = LoadingStatus.STATUS_COMPLETED;
      setState(() {});
    } else {
      loadingStatus = LoadingStatus.STATUS_IDEL;
      Future.delayed(Duration(seconds: 1), () {
        setState(() {});
      });
    }
  }

  //给hero的tag设置唯一的值
  Object getHeroTag(LiveModel liveModel, index) {
    String string =
        "heroTag_${DateUtil.getNowDateMs()}_${Random().nextInt(
        100000)}_${liveModel.id}_${index}";
    heroTagArray.add(string);
    return string;
  }


  resetScreenData() async {
    loadingStatus = LoadingStatus.STATUS_LOADING;
    setState(() {

    });
    videoModelArray.clear();
    try {
      List<int> _level = <int>[];
      List<int> _part = <int>[];
      List<int> _target = <int>[];
      for (int i = 0; i < _titleItemList.length; i++) {
        if (_titleItemList[i].type == 0) {
          _level.add(_titleItemList[i].id);
        } else if (_titleItemList[i].type == 1) {
          _part.add(_titleItemList[i].id);
        } else if (_titleItemList[i].type == 2) {
          _target.add(_titleItemList[i].id);
        }
      }
      Map<String, dynamic> model = await getVideoCourseList(
          size: pageSize, target: _target, part: _part, level: _level);
      if (model != null && model["list"] != null) {
        model["list"].forEach((v) {
          videoModelArray.add(LiveModel.fromJson(v));
        });
      }
    } catch (e) {}
    if (videoModelArray.length > 0) {
      loadingStatus = LoadingStatus.STATUS_COMPLETED;
      setState(() {});
    } else {
      loadingStatus = LoadingStatus.STATUS_IDEL;
      Future.delayed(Duration(seconds: 1), () {
        setState(() {});
      });
    }
  }
}
