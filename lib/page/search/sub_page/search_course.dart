import 'dart:async';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/search/search_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/data_response_model.dart';
import 'package:mirror/data/model/live_video_model.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/page/home/sub_page/recommend_page.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/date_util.dart';
import 'package:mirror/util/integer_util.dart';

class SearchCourse extends StatefulWidget {
  SearchCourse({Key key, this.keyWord, this.textController, this.focusNode}) : super(key: key);
  FocusNode focusNode;
  TextEditingController textController;
  String keyWord;

  @override
  SearchCourseState createState() => SearchCourseState();
}

class SearchCourseState extends State<SearchCourse>  {


  // 声明定时器
  Timer timer;
  List<LiveVideoModel> liveVideoList = [];

  // 滑动控制器
  ScrollController _scrollController = new ScrollController();

  // 数据加载页数
  int dataPage = 1;

  // 请求下一页
  int lastTime;

  // 是否有下一页
  int hasNext;

  // 加载中默认文字
  String loadText = "加载中...";

  // 加载状态
  LoadingStatus loadStatus = LoadingStatus.STATUS_IDEL;
  String lastString;

  @override
  void initState() {
    requestSearchCourse();
    // 上拉加载
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        dataPage += 1;
        requestSearchCourse();
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
          if (liveVideoList.isNotEmpty) {
            liveVideoList.clear();
            lastTime = null;
            dataPage = 1;
          }
          requestSearchCourse();
        }
        lastString = widget.keyWord;
      });
    });
  }

  @override
  void dispose() {
    print("课程页销毁了页面");

    ///取消延时任务
    timer.cancel();
    super.dispose();
  }

  // 请求搜索课程接口
  requestSearchCourse() async {
    if (loadStatus == LoadingStatus.STATUS_IDEL) {
      // 先设置状态，防止下拉就直接加载
      setState(() {
        loadStatus = LoadingStatus.STATUS_LOADING;
      });
    }
    DataResponseModel model = DataResponseModel();
    if (hasNext != 0) {
      model = await searchCourse(key: widget.keyWord, size: 20, lastTime: lastTime);
      if (dataPage == 1) {
        if (model.list.isNotEmpty) {
          print(model.list.length);
          model.list.forEach((v) {
            liveVideoList.add(LiveVideoModel.fromJson(v));
          });
          if (model.hasNext == 0) {
            loadText = "";
            loadStatus = LoadingStatus.STATUS_COMPLETED;
          }
        }
      } else if (dataPage > 1 && lastTime != null) {
        if (model.list.isNotEmpty) {
          model.list.forEach((v) {
            liveVideoList.add(LiveVideoModel.fromJson(v));
          });
          loadStatus = LoadingStatus.STATUS_IDEL;
          loadText = "加载中...";
        }
      }
    }
    lastTime = model.lastTime;
    hasNext = model.hasNext;
    if (hasNext == 0) {
      loadText = "已加载全部课程";
      loadStatus = LoadingStatus.STATUS_COMPLETED;
      print("返回不请求数据");
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (liveVideoList.isNotEmpty) {
      return Container(
          child: RefreshIndicator(
              onRefresh: () async {
                liveVideoList.clear();
                lastTime = null;
                dataPage = 1;
                loadStatus = LoadingStatus.STATUS_LOADING;
                loadText = "加载中...";
                requestSearchCourse();
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
              ])));
    } else {
      return Container(
        margin: const EdgeInsets.only(top: 100),
        child: Center(
          child: Column(
            children: [
              Image.asset(
                "images/test/bg.png",
                fit: BoxFit.cover,
                width: 224,
                height: 224,
              ),
              SizedBox(
                height: 16,
              ),
              Text(
                "暂无视频课程，去看看其他的吧~",
                style: TextStyle(fontSize: 14, color: AppColor.textSecondary),
              )
            ],
          ),
        ),
      );
    }
  }
}

class SearchCourseItem extends StatefulWidget {
  SearchCourseItem({Key key, this.index, this.count, this.videoModel}) : super(key: key);
  LiveVideoModel videoModel;
  int index;
  int count;

  @override
  SearchCourseItemState createState() => SearchCourseItemState();
}

class SearchCourseItemState extends State<SearchCourseItem> {
  EdgeInsetsGeometry firstMargin = const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 6);
  EdgeInsetsGeometry commonMargin = const EdgeInsets.only(left: 16, right: 16, top: 6, bottom: 6);
  EdgeInsetsGeometry endMargin = const EdgeInsets.only(left: 16, right: 16, top: 6, bottom: 50);

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
            _getItemLeftImageUi(widget.videoModel, widget.index),
            _getItemRightDataUi(widget.videoModel, 90, widget.index),
          ],
        ),
      ),
      onTap: () {
        //点击事件
        print("====heroTagArray[index]:${heroTagArray[widget.index]}");
        AppRouter.navigateToVideoDetail(context, heroTagArray[widget.index], widget.videoModel.id,
            widget.videoModel.coursewareId, widget.videoModel);
      },
    );
  }

  //获取left的图片
  Widget _getItemLeftImageUi(LiveVideoModel value, int index) {
    String imageUrl;
    if (value.picUrl != null) {
      imageUrl = value.picUrl;
    } else if (value.coursewareDto?.picUrl != null) {
      imageUrl = value.coursewareDto?.picUrl;
    } else if (value.coursewareDto?.previewVideoUrl != null) {
      imageUrl = value.coursewareDto?.previewVideoUrl;
    }

    return Container(
      width: 120,
      height: 90,
      child: Hero(
        child: CachedNetworkImage(
          height: 90,
          width: 120,
          imageUrl: imageUrl == null ? "" : imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Image.asset(
            "images/test/bg.png",
            fit: BoxFit.cover,
          ),
          errorWidget: (context, url, error) => Image.asset(
            "images/test/bg.png",
            fit: BoxFit.cover,
          ),
        ),
        tag: getHeroTag(value, index),
      ),
    );
  }

  //给hero的tag设置唯一的值
  Object getHeroTag(LiveVideoModel videoModel, index) {
    if (heroTagArray != null && heroTagArray.length > index) {
      return heroTagArray[index];
    } else {
      String string = "heroTag_video_${DateUtil.getNowDateMs()}_${Random().nextInt(100000)}_${videoModel.id}_$index";
      heroTagArray.add(string);
      return string;
    }
  }

  //获取右边数据的ui
  Widget _getItemRightDataUi(LiveVideoModel value, int imageHeight, int index) {
    TextStyle textStyleBold = TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColor.textPrimary2);
    TextStyle textStyleNormal = TextStyle(fontSize: 12, color: AppColor.textSecondary);

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
                value.title ?? "",
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
                      child: RichText(
                        text: TextSpan(children: [
                          TextSpan(text: value.levelDto?.ename, style: textStyleBold),
                          // ignore: null_aware_before_operator
                          TextSpan(
                              // ignore: null_aware_before_operator
                              text: value.levelDto?.name + " · ",
                              style: textStyleNormal),
                          TextSpan(
                              text: ((value.times ~/ 1000) ~/ 60 > 0
                                      ? (value.times ~/ 1000) ~/ 60
                                      : (value.times ~/ 1000))
                                  .toString(),
                              style: textStyleBold),
                          TextSpan(text: (value.times ~/ 1000) ~/ 60 > 0 ? "分钟 · " : "秒 · ", style: textStyleNormal),
                          TextSpan(text: value.calories.toString(), style: textStyleBold),
                          TextSpan(text: "千卡", style: textStyleNormal),
                        ]),
                      ),
                      top: 0,
                      left: 0,
                    ),
                    Positioned(
                      child: Text(
                        IntegerUtil.formatIntegerCn(value.joinAmount) + "人练过",
                        style: TextStyle(fontSize: 12, color: AppColor.textPrimary2),
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
}
