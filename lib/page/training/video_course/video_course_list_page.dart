import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/training/live_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/training/live_video_model.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/data/model/video_tag_madel.dart';
import 'package:mirror/page/search/search.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/date_util.dart';
import 'package:mirror/util/integer_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

/// 视频课程列表-筛选页
class VideoCourseListPage extends StatefulWidget {
  @override
  createState() => new VideoCourseListPageState();
}

class VideoCourseListPageState extends State<VideoCourseListPage> {
  //选择的所有标签
  List<SubTagModel> _titleItemList = <SubTagModel>[];
  List<SubTagModel> _titleItemListTemp = <SubTagModel>[];
  List<String> _titleItemString = ["目标", "部位", "难度", "筛选"];
  int showScreenTitlePosition = -1;
  var titleItemSubSettingList = <TitleItemSubSetting>[];

  //当前显示的直播课程的list
  var videoModelArray = <LiveVideoModel>[];

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
  int pagePosition = 1;

  //上拉加载数据
  RefreshController _refreshController = RefreshController(initialRefresh: false);

  //是否还有更多的数据
  bool isHaveMoreData = true;

  double filterBoxHeight = 80;
  double filterBoxOpacity = 0.0;

  //一些通用的属性
  var marginCommonly = const EdgeInsets.only(left: 3, right: 3);
  var topTitleItem = const EdgeInsets.only(left: 10, right: 10, top: 2, bottom: 2);
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
    super.initState();
    videoTagModel = Application.videoTagModel;
    loadingStatus = LoadingStatus.STATUS_LOADING;
    _setTitleItemSubSettingData();
    _initData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleString: "课程库",
        actions: [
          CustomAppBarIconButton(
            Icons.search,
            AppColor.black,
            false,
            () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return SearchPage();
              }));
              print("点击了搜索");
            },
          ),
        ],
      ),
      body: _buildSuggestions(),
    );
  }

  //判断获取什么布局
  Widget _buildSuggestions() {
    var columnArray = <Widget>[];
    //判断有没有筛选栏
    if (videoTagModel != null) {
      columnArray.add(
        _getScreenTitleUi(),
      );
    }
    columnArray.add(Expanded(
        child: SizedBox(
      child: _bodyBox(),
    )));

    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      color: AppColor.white,
      child: Column(
        children: columnArray,
      ),
    );
  }

  //顶部筛选的列表
  Widget _getScreenTitleUi() {
    TextStyle textStyle = TextStyle(fontSize: 15, color: AppColor.textPrimary1, fontWeight: FontWeight.bold);
    var expandedArray = <Widget>[];
    for (int i = 0; i < _titleItemString.length; i++) {
      expandedArray.add(Expanded(
        flex: 1,
        child: InkWell(
          child: Container(
            height: 48,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _titleItemString[i],
                  style: textStyle,
                ),
                SizedBox(
                  width: 1,
                ),
                Icon(
                  i == _titleItemString.length - 1 ? Icons.filter_alt_outlined : Icons.arrow_drop_down_sharp,
                  color: AppColor.textHint,
                  size: 16,
                ),
              ],
            ),
          ),
          onTap: () {
            _screenTitleOnclick(i);
          },
        ),
      ));
    }
    return Container(
      width: double.infinity,
      child: Column(
        children: [
          Flex(
            direction: Axis.horizontal,
            children: expandedArray,
          ),
          Container(
            color: AppColor.textHint,
            height: 0.5,
            width: double.infinity,
          ),
        ],
      ),
    );
  }

  //主体框架
  Widget _bodyBox() {
    if (filterBoxOpacity > 0) {
      filterBoxHeight = MediaQuery.of(context).size.height * 0.75 - 150;
      if (showScreenTitlePosition < 0 || showScreenTitlePosition >= 3) {
        double itemHeight =
            titleItemSubSettingList[0].height + titleItemSubSettingList[1].height + titleItemSubSettingList[2].height;
        if (itemHeight + 20 < filterBoxHeight) {
          filterBoxHeight = itemHeight + 20;
        }
      } else {
        filterBoxHeight = titleItemSubSettingList[showScreenTitlePosition].height + 80;
      }
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          //list区域
          Container(
            width: double.infinity,
            height: double.infinity,
            child: _listBox(),
          ),

          //todo 目前是隐藏的 回归顶部按钮区域
          Offstage(
            offstage: true,
            child: _getTopBackItemBoxUi(),
          ),

          //筛选区域
          Offstage(
            offstage: showScreenTitlePosition < 0,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: AppColor.black.withOpacity(0.5),
              child: Column(
                children: [
                  AnimatedContainer(
                    height: filterBoxHeight,
                    duration: Duration(milliseconds: 300),
                    child: Opacity(
                      opacity: 1.0,
                      child: Container(
                        height: filterBoxHeight,
                        width: double.infinity,
                        color: AppColor.white,
                        child: _filterBox(),
                      ),
                    ),
                  ),
                  Expanded(
                      child: SizedBox(
                    child: GestureDetector(
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: AppColor.transparent,
                      ),
                      onTap: () {
                        _titleItemListTemp.clear();
                        showScreenTitlePosition = -1;
                        if (mounted) {
                          setState(() {});
                        }
                      },
                    ),
                  ))
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  //list box
  Widget _listBox() {
    if (loadingStatus == LoadingStatus.STATUS_COMPLETED && videoModelArray != null && videoModelArray.length > 0) {
      return _listContentBox();
    } else if (loadingStatus == LoadingStatus.STATUS_LOADING) {
      return UnconstrainedBox(
        child: CircularProgressIndicator(),
      );
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

  //list box
  Widget _listContentBox() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: NotificationListener<ScrollNotification>(
          child: SmartRefresher(
            enablePullDown: true,
            enablePullUp: isHaveMoreData,
            header: WaterDropHeader(
              complete: Text("刷新完成"),
              failed: Text(""),
            ),
            footer: CustomFooter(
              builder: (BuildContext context, LoadStatus mode) {
                Widget body;
                if (mode == LoadStatus.idle) {
                  body = Text("");
                } else if (mode == LoadStatus.loading) {
                  body = CircularProgressIndicator();
                } else if (mode == LoadStatus.failed) {
                  body = Text("");
                } else if (mode == LoadStatus.canLoading) {
                  body = Text("");
                } else {
                  body = Text("");
                }
                return Container(
                  height: 55.0,
                  child: Center(child: body),
                );
              },
            ),
            controller: _refreshController,
            onRefresh: _onRefresh,
            onLoading: _onLoading,
            child: ListView.builder(
                controller: scrollController,
                physics: BouncingScrollPhysics(),
                scrollDirection: Axis.vertical,
                itemCount: videoModelArray.length,
                itemBuilder: (context, index) {
                  return _getItem(videoModelArray[index], index, videoModelArray.length);
                }),
          ),
          onNotification: (ScrollNotification notification) {
            ScrollMetrics metrics = notification.metrics;
            if (metrics.axisDirection == AxisDirection.up || metrics.axisDirection == AxisDirection.down) {
              // 注册通知回调
              if (notification is ScrollStartNotification) {
                // 滚动开始
                print('滚动开始');
              } else if (notification is ScrollUpdateNotification) {
                // 当前位置
                print("当前位置${metrics.pixels}");
                if (metrics.pixels > showBackTopBoxHeight) {
                  if (metrics.pixels - showBackTopBoxHeight > topItemHeight) {
                    topItemOpacity = 1.0;
                  } else {
                    topItemOpacity = (metrics.pixels - showBackTopBoxHeight) / topTitleItemHeight;
                    if (topItemOpacity > 1) {
                      topItemOpacity = 1.0;
                    }
                  }
                } else {
                  topItemOpacity = 0.0;
                }
                if (mounted) {
                  setState(() {
                    if (topItemOpacity == 0) {
                      topItemHeight = 0;
                    } else if (metrics.pixels > showBackTopBoxHeight && topItemHeight == 0) {
                      topItemHeight = topItemHeight1;
                      topItemOpacity = 0.0;
                    }
                  });
                }
              } else if (notification is ScrollEndNotification) {
                // 滚动结束
                print('滚动结束');
              }
            }
            return false;
          }),
    );
  }

  //顶部返回列表顶部按的box
  Widget _getTopBackItemBoxUi() {
    return Opacity(
      opacity: topItemOpacity,
      child: GestureDetector(
        child: Container(
          color: Colors.cyanAccent,
          width: double.infinity,
          height: topItemHeight,
        ),
        onTap: () {
          scrollController.animateTo(0.0, duration: Duration(milliseconds: 300), curve: Curves.ease);
        },
      ),
    );
  }

  //筛选的box
  Widget _filterBox() {
    if (videoTagModel == null) {
      return Container();
    }
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        children: [
          //上半部分可滑动区域
          Expanded(
              child: SizedBox(
            child: _filterBoxItem(),
          )),
          //底部按钮
          _filterBoxBottomBtn(),
        ],
      ),
    );
  }

  //筛选的底部按钮
  Widget _filterBoxBottomBtn() {
    return Container(
      width: double.infinity,
      height: 80,
      color: AppColor.white,
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: Row(
        children: [
          Flexible(
            child: InkWell(
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                width: double.infinity,
                height: 34,
                decoration: BoxDecoration(
                  border: Border.all(width: 0.5, color: AppColor.mainRed),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Center(
                  child: Text(
                    "重置",
                    style: TextStyle(color: AppColor.mainRed, fontSize: 16),
                  ),
                ),
              ),
              onTap: () {
                if (showScreenTitlePosition == 3) {
                  _titleItemListTemp.clear();
                } else if (showScreenTitlePosition == 0) {
                  for (int i = 0; i < videoTagModel.target.length; i++) {
                    if (_titleItemListTemp.contains(videoTagModel.target[i])) {
                      _titleItemListTemp.remove(videoTagModel.target[i]);
                    }
                  }
                } else if (showScreenTitlePosition == 1) {
                  for (int i = 0; i < videoTagModel.part.length; i++) {
                    if (_titleItemListTemp.contains(videoTagModel.part[i])) {
                      _titleItemListTemp.remove(videoTagModel.part[i]);
                    }
                  }
                } else if (showScreenTitlePosition == 2) {
                  for (int i = 0; i < videoTagModel.level.length; i++) {
                    if (_titleItemListTemp.contains(videoTagModel.level[i])) {
                      _titleItemListTemp.remove(videoTagModel.level[i]);
                    }
                  }
                }
                if (mounted) {
                  setState(() {});
                }
              },
            ),
            flex: 1,
          ),
          Flexible(
            child: InkWell(
              child: Container(
                margin: const EdgeInsets.only(left: 8),
                width: double.infinity,
                height: 34,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(17),
                  color: AppColor.mainRed.withOpacity(0.06),
                ),
                child: Center(
                  child: Text(
                    "确定",
                    style: TextStyle(color: AppColor.mainRed, fontSize: 16),
                  ),
                ),
              ),
              onTap: () {
                _titleItemList.clear();
                _titleItemList.addAll(_titleItemListTemp);
                _titleItemListTemp.clear();
                showScreenTitlePosition = -1;
                if (mounted) {
                  setState(() {
                    loadingStatus = LoadingStatus.STATUS_LOADING;
                    _onRefresh();
                  });
                }
              },
            ),
            flex: 1,
          )
        ],
      ),
    );
  }

  //筛选区域的item box
  Widget _filterBoxItem() {
    var childrenArray = <Widget>[];
    var childrenArray1 = <Widget>[];
    var childrenArray2 = <Widget>[];
    var childrenArray3 = <Widget>[];
    var marginBox = const EdgeInsets.only(left: 16, right: 0);

    //目标
    childrenArray1 = _filterTitleArray("目标", videoTagModel.target, 0);
    //部位
    childrenArray2 = _filterTitleArray("部位", videoTagModel.part, 1);
    //难度
    childrenArray3 = _filterTitleArray("难度", videoTagModel.level, 2);

    childrenArray.add(Container(
      key: titleItemSubSettingList[0].globalKey,
      child: Column(
        children: childrenArray1,
      ),
    ));
    childrenArray.add(Container(
      key: titleItemSubSettingList[1].globalKey,
      child: Column(
        children: childrenArray2,
      ),
    ));
    childrenArray.add(Container(
      key: titleItemSubSettingList[2].globalKey,
      child: Column(
        children: childrenArray3,
      ),
    ));
    return Container(
      width: double.infinity,
      height: double.infinity,
      margin: marginBox,
      child: ListView(
        physics: BouncingScrollPhysics(),
        scrollDirection: Axis.vertical,
        children: childrenArray,
      ),
    );
  }

  //每一个筛选的块
  List<Widget> _filterTitleArray(String title, List<SubTagModel> list, int index) {
    var childrenArray = <Widget>[];
    var wrapArray = <Widget>[];

    var titleStyle = const TextStyle(fontSize: 14, color: AppColor.textSecondary);
    var marginTitleFirst = const EdgeInsets.only(top: 16, bottom: 12);
    var marginTitleCommon = const EdgeInsets.only(top: 0, bottom: 12);

    childrenArray.add(Offstage(
      offstage: !(showScreenTitlePosition == index || showScreenTitlePosition == 3),
      child: Container(
        width: double.infinity,
        child: Text(
          title,
          style: titleStyle,
        ),
        margin: index == 0 ? marginTitleFirst : (showScreenTitlePosition == 3 ? marginTitleCommon : marginTitleFirst),
      ),
    ));
    for (int i = 0; i < list.length; i++) {
      wrapArray.add(_filterTitleItem(list[i]));
    }
    childrenArray.add(Offstage(
      offstage: !(showScreenTitlePosition == index || showScreenTitlePosition == 3),
      child: Container(
        width: double.infinity,
        child: Wrap(
          alignment: WrapAlignment.start,
          children: wrapArray,
        ),
      ),
    ));
    return childrenArray;
  }

  //每一个筛选按钮
  Widget _filterTitleItem(SubTagModel model) {
    var marginItem = const EdgeInsets.only(right: 12, bottom: 12);
    var paddingItem = const EdgeInsets.only(left: 24, top: 4, right: 24, bottom: 4);
    var selectPaddingItem = const EdgeInsets.only(left: 23.5, top: 3.5, right: 23.5, bottom: 3.5);
    var decorationItem =
        const BoxDecoration(color: AppColor.bgWhite, borderRadius: BorderRadius.all(Radius.circular(14)));
    var styleItem = const TextStyle(fontSize: 14, color: AppColor.textPrimary2);
    var selectStyleItem = const TextStyle(fontSize: 14, color: AppColor.mainRed);
    var selectDecorationItem = BoxDecoration(
        color: AppColor.mainRed.withOpacity(0.06),
        borderRadius: BorderRadius.all(Radius.circular(14)),
        border: Border.all(width: 0.5, color: AppColor.mainRed));
    return InkWell(
      child: Container(
        child: Text(
          (model.ename == null ? "" : model.ename) + model.name,
          style: _titleItemListTemp.contains(model) ? selectStyleItem : styleItem,
        ),
        margin: marginItem,
        padding: _titleItemListTemp.contains(model) ? selectPaddingItem : paddingItem,
        decoration: _titleItemListTemp.contains(model) ? selectDecorationItem : decorationItem,
      ),
      onTap: () {
        if (_titleItemListTemp.contains(model)) {
          _titleItemListTemp.remove(model);
        } else {
          _titleItemListTemp.add(model);
        }
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  //item--每一个
  Widget _getItem(LiveVideoModel videoModel, int index, int count) {
    EdgeInsetsGeometry firstMargin = const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 6);
    EdgeInsetsGeometry commonMargin = const EdgeInsets.only(left: 16, right: 16, top: 6, bottom: 6);
    EdgeInsetsGeometry endMargin = const EdgeInsets.only(left: 16, right: 16, top: 6, bottom: 50);
    return GestureDetector(
      child: Container(
        color: AppColor.transparent,
        width: ScreenUtil.instance.screenWidthDp,
        margin: index == count - 1 ? endMargin : (index == 0 ? firstMargin : commonMargin),
        child: Row(
          children: [
            buildVideoCourseItemLeftImageUi(videoModel, getHeroTag(videoModel, index)),
            buildVideoCourseItemRightDataUi(videoModel, 90, false),
          ],
        ),
      ),
      onTap: () {
        //点击事件
        print("====heroTagArray[index]:${heroTagArray[index]}");
        AppRouter.navigateToVideoDetail(context, videoModel.id, heroTag: heroTagArray[index], videoModel: videoModel);
      },
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

  //初始化数据
  _initData() async {
    //判断该不该回去title
    await _getTitleValue();
    videoModelArray.clear();
    //获取展示数据
    _loadData();
  }

  //获取筛选title
  _getTitleValue() async {
    //title
    if (videoTagModel == null) {
      try {
        Map<String, dynamic> videoCourseTagMap = await getAllTags();
        Application.videoTagModel = VideoTagModel.fromJson(videoCourseTagMap);
        videoTagModel = Application.videoTagModel;
      } catch (e) {
        videoTagModel = null;
        return;
      }
      showBackTopBoxHeight = 20;
    }
  }

  //获取数据
  _loadData({bool isRefreshOrLoad = false}) async {
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
      size: pageSize,
      page: pagePosition,
      target: _target,
      part: _part,
      level: _level,
    );
    if (model != null && model["list"] != null) {
      int count = videoModelArray.length;

      print("videoModelArray.length1111:${videoModelArray.length}");
      model["list"].forEach((v) {
        videoModelArray.add(LiveVideoModel.fromJson(v));
        print('8888888888888888888888888888888888888------${v["id"]}');
      });

      print("videoModelArray.length222222:${videoModelArray.length}");

      Future.delayed(Duration(milliseconds: 500), () {
        if (isRefreshOrLoad) {
          _refreshController.refreshCompleted();
        } else {
          _refreshController.loadComplete();
        }
        if (mounted) {
          setState(() {
            loadingStatus = LoadingStatus.STATUS_COMPLETED;
            if (count == videoModelArray.length) {
              isHaveMoreData = false;
            } else {
              isHaveMoreData = true;
              pagePosition++;
            }
          });
        }
      });
    } else {
      Future.delayed(Duration(milliseconds: 500), () {
        if (isRefreshOrLoad) {
          _refreshController.refreshCompleted();
        } else {
          _refreshController.loadNoData();
        }
        if (mounted) {
          setState(() {
            loadingStatus = LoadingStatus.STATUS_IDEL;
          });
        }
      });
    }
    // try {
    // } catch (e) {
    //   print(e);
    //   Future.delayed(Duration(milliseconds: 500), () {
    //     if (isRefreshOrLoad) {
    //       _refreshController.refreshCompleted();
    //     } else {
    //       _refreshController.loadNoData();
    //     }
    //     setState(() {
    //       loadingStatus = LoadingStatus.STATUS_IDEL;
    //     });
    //   });
    // }
  }

  //刷新数据
  _onRefresh() async {
    videoModelArray.clear();
    topItemOpacity = 0.0;
    topItemHeight = 0;
    pagePosition = 1;
    await _loadData(isRefreshOrLoad: true);
  }

  //加载数据
  _onLoading() async {
    await _loadData(isRefreshOrLoad: false);
  }

  //设置高度监听的设置
  _setTitleItemSubSettingData() {
    for (int i = 0; i < 3; i++) {
      TitleItemSubSetting titleItemSubSetting = new TitleItemSubSetting();
      titleItemSubSetting.globalKey = new GlobalKey();
      titleItemSubSetting.height = 0;
      titleItemSubSettingList.add(titleItemSubSetting);
    }
  }

  //顶部的点击事件
  //todo 筛选的点击事件-如果没有item的高度是先透明 再延迟100毫秒 获取高度 显示
  _screenTitleOnclick(int index, {bool isSecond = false}) {
    if (showScreenTitlePosition == index && !isSecond) {
      showScreenTitlePosition = -1;
      return;
    }
    if (showScreenTitlePosition < 0) {
      _titleItemListTemp.clear();
      _titleItemListTemp.addAll(_titleItemList);
    }
    showScreenTitlePosition = index;

    //获取每一个筛序组的高度
    for (int j = 0; j < titleItemSubSettingList.length; j++) {
      if (titleItemSubSettingList[j].height < 1) {
        titleItemSubSettingList[j].height = titleItemSubSettingList[j].globalKey.currentContext.size.height;
      }
    }

    if (index < 3) {
      if (titleItemSubSettingList[index].height < 1) {
        filterBoxOpacity = 0.0;
        if (mounted) {
          setState(() {});
        }
        Future.delayed(Duration(milliseconds: 100), () {
          _screenTitleOnclick(index, isSecond: true);
        });
      } else {
        filterBoxOpacity = 1.0;
        if (mounted) {
          setState(() {});
        }
      }
    } else {
      if (titleItemSubSettingList[0].height < 1 ||
          titleItemSubSettingList[1].height < 1 ||
          titleItemSubSettingList[2].height < 1) {
        filterBoxOpacity = 0.0;
        if (mounted) {
          setState(() {});
        }
        Future.delayed(Duration(milliseconds: 100), () {
          _screenTitleOnclick(index, isSecond: true);
        });
      } else {
        filterBoxOpacity = 1.0;
        if (mounted) {
          setState(() {});
        }
      }
    }
  }
}

class TitleItemSubSetting {
  double height;
  GlobalKey globalKey;
}

//获取left的图片
Widget buildVideoCourseItemLeftImageUi(LiveVideoModel value, Object heroTag) {
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
      tag: heroTag,
    ),
  );
}

//获取右边数据的ui
Widget buildVideoCourseItemRightDataUi(LiveVideoModel value, int imageHeight, bool isMine) {
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
                            text:
                                ((value.times ~/ 1000) ~/ 60 > 0 ? (value.times ~/ 1000) ~/ 60 : (value.times ~/ 1000))
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
                      isMine ? "已完成${value.finishAmount}次" : IntegerUtil.formatIntegerCn(value.practiceAmount) + "人练过",
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
