import 'dart:async';

import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/api.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/api/search/search_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/config/config.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/base_response_model.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/data_response_model.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/data/model/media_file_model.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:mirror/data/notifier/token_notifier.dart';
import 'package:mirror/page/feed/feed_flow.dart';
import 'package:mirror/page/home/sub_page/recommend_page.dart';
import 'package:mirror/page/home/sub_page/share_page/dynamic_list.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/event_bus.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/string_util.dart';
import 'package:mirror/util/text_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/feed_video_player.dart';
import 'package:mirror/widget/icon.dart';
import 'package:mirror/widget/overscroll_behavior.dart';
import 'package:mirror/widget/size_transition_view.dart';
import 'package:mirror/widget/sliding_element_exposure/exposure_detector.dart';
import 'package:mirror/widget/smart_refressher_head_footer.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';


class SearchFeed extends StatefulWidget {
  SearchFeed({Key key, this.keyWord, this.focusNode, this.textController, this.controller})
      : super(key: key);
  final FocusNode focusNode;
  final String keyWord;
  final TabController controller;
  final TextEditingController textController;

  @override
  SearchFeedState createState() => SearchFeedState();
}

class SearchFeedState extends State<SearchFeed> with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true; //必须重写
  int lastTime;

  // 声明定时器
  Timer timer;
  List<HomeFeedModel> feedList = [];

  // 滑动控制器
  ScrollController _scrollController = new ScrollController();

  // 是否存在下一页
  int hasNext;

// // 加载中默认文字
//   String loadText = "加载中...";
//
//   // 加载状态
//   LoadingStatus loadStatus = LoadingStatus.STATUS_IDEL;
  String lastString;
  RefreshController _refreshController = RefreshController();
  Map<int, AnimationController> animationMap = {};

  // 是否显示缺省图
  bool isShowDefaultMap;

// Token can be shared with different requests.
  CancelToken token = CancelToken();

  @override
  void deactivate() {
    print("State 被暂时从视图树中移除时");
    super.deactivate();
  }

  @override
  void initState() {
    requestFeednIterface(refreshOrLoading: true);
    // 上拉加载
    // _scrollController.addListener(() {
    //   if (widget.focusNode.hasFocus) {
    //     print('-------------------focusNode---focusNode----focusNode--focusNode');
    //     widget.focusNode.unfocus();
    //   }
    //   if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
    //     requestFeednIterface(refreshOrLoading: false);
    //   }
    // });
    EventBus.getDefault().registerSingleParameter(_deleteFeedCallBack, EVENTBUS_SEARCH_FEED_PAGE,
        registerName: EVENTBUS_SEARCH_DELETED_FEED);
    int controllerIndex = 2;
    if (AppConfig.needShowTraining) {
      controllerIndex = 3;
    }
    widget.controller.addListener(() {
      print("widget.tabBarIndexList动态:::${Application.tabBarIndexList}");
      // 切换tab监听在当前tarBarView下
      if (widget.controller.index == controllerIndex) {
        print(Application.tabBarIndexList.contains(controllerIndex));
        // 初始化过的文本变化
        if (Application.tabBarIndexList.contains(controllerIndex)) {
          if (lastString != widget.keyWord) {
            lastTime = null;
            hasNext = null;
            requestFeednIterface(refreshOrLoading: true);
          }
        } else {
          Application.tabBarIndexList.add(controllerIndex);
        }
      }
    });
    widget.textController.addListener(() {
      if (widget.controller.index == controllerIndex) {
        // 取消延时
        if (timer != null) {
          timer.cancel();
        }
        // 延迟器:
        timer = Timer(Duration(milliseconds: 500), () {
          if (lastString != widget.keyWord) {
            lastTime = null;
            hasNext = null;
            requestFeednIterface(refreshOrLoading: true);
          }
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    print("销毁了页面");
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
  requestFeednIterface({bool refreshOrLoading}) async {
    if (hasNext != 0) {
      DataResponseModel model = await searchFeed(key: widget.keyWord, size: 20, lastTime: lastTime, token: token);
      if (refreshOrLoading) {
        feedList.clear();
        animationMap.clear();
      }
      if (model != null && model.list.isNotEmpty) {
        lastTime = model.lastTime;
        hasNext = model.hasNext;
        model.list.forEach((v) {
          feedList.add(HomeFeedModel.fromJson(v));
          animationMap[HomeFeedModel.fromJson(v).id] =
              AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
        });
        if (refreshOrLoading) {
          _refreshController.refreshCompleted();
        } else {
          _refreshController.loadComplete();
        }
      }
      try {
        //筛选首页关注页话题动态
        List<HomeFeedModel> homeFollowModel = [];
        context.read<FeedMapNotifier>().value.feedMap.forEach((key, value) {
          if (value.recommendSourceDto != null) {
            homeFollowModel.add(value);
          }
        });
        homeFollowModel.forEach((element) {
          feedList.forEach((v) {
            if (element.id == v.id) {
              v.recommendSourceDto = element.recommendSourceDto;
            }
          });
        });
        // 更新数据
        context.read<FeedMapNotifier>().updateFeedMap(feedList, needNotify: mounted);
      } catch (e) {
        print('-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~$e');
      }
    } else {
      if (refreshOrLoading) {
        _refreshController.refreshFailed();
      } else {
        _refreshController.loadFailed();
      }
    }
    if (hasNext == 0) {
      if (refreshOrLoading) {
        _refreshController.refreshCompleted();
        _refreshController.loadComplete();
      } else {
        _refreshController.loadNoData();
      }
      // 加载完毕
      // loadText = "已加载全部动态";
      // loadStatus = LoadingStatus.STATUS_COMPLETED;
    }
    if (refreshOrLoading) {
      lastString = widget.keyWord;
    }
    if (feedList.length > 0) {
      isShowDefaultMap = false;
    } else {
      isShowDefaultMap = true;
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    print("biubiu!@@###%%^^^&&&&****(((()))))_+++==--009");
    return isShowDefaultMap == null
        ? Container()
        : !isShowDefaultMap
            ? Container(
                margin: const EdgeInsets.only(top: 12),
                child: ScrollConfiguration(
                    behavior: OverScrollBehavior(),
                    child: SmartRefresher(
                        enablePullDown: true,
                        enablePullUp: true,
                        footer: SmartRefresherHeadFooter.init().getFooter(),
                        header: SmartRefresherHeadFooter.init().getHeader(),
                        controller: _refreshController,
                        onRefresh: () {
                          lastTime = null;
                          hasNext = null;
                          _refreshController.loadComplete();
                          requestFeednIterface(refreshOrLoading: true);
                        },
                        onLoading: () {
                          requestFeednIterface(refreshOrLoading: false);
                        },
                        child: CustomScrollView(
                            controller: PrimaryScrollController.of(context),
                            // _scrollController,
                            physics: AlwaysScrollableScrollPhysics(),
                            slivers: [
                              // SliverToBoxAdapter(
                              //     child: Container(
                              //   margin: EdgeInsets.only(left: 16, right: 16),
                              //   child: MediaQuery.removePadding(
                              //       removeTop: true,
                              //       context: context,
                              //       // 瀑布流
                              //       child: WaterfallFlow.builder(
                              //         primary: false,
                              //         shrinkWrap: true,
                              //         // controller: _scrollController,
                              //         gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                              //           crossAxisCount: 2,
                              //           // 上下间隔
                              //           mainAxisSpacing: 4.0,
                              //           //   // 左右间隔
                              //           crossAxisSpacing: 8.0,
                              //         ),
                              //         itemBuilder: (context, index) {
                              //           // 获取动态id
                              //           int id;
                              //           // 获取动态id指定model
                              //           HomeFeedModel model;
                              //           if (index < feedList.length) {
                              //             id = feedList[index].id;
                              //             model = context.read<FeedMapNotifier>().feedMap[id];
                              //           }
                              //           if (index == feedList.length) {
                              //             return LoadingView(
                              //               loadText: loadText,
                              //               loadStatus: loadStatus,
                              //             );
                              //           } else if (index == feedList.length + 1) {
                              //             return Container();
                              //           } else {
                              //             return SearchFeeditem(
                              //               model: model,
                              //               list: feedList,
                              //               index: index,
                              //               focusNode: widget.focusNode,
                              //               pageName: "searchFeed",
                              //               feedLastTime: lastTime,
                              //               searchKeyWords: widget.textController.text,
                              //               feedHasNext: hasNext,
                              //             );
                              //           }
                              //         },
                              //         itemCount: feedList.length + 1,
                              //       )
                              //      ),
                              // )),
                              SliverList(
                                  delegate: SliverChildBuilderDelegate((content, index) {
                                return _buildItem(index);
                              }, childCount: feedList.length))
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
                      style: TextStyle(fontSize: 14, color: AppColor.textSecondary),
                    ),
                    const Text("换一个试一试", style: TextStyle(color: AppColor.textSecondary, fontSize: 14)),
                  ],
                ),
              );
  }

  _deleteFeedCallBack(int id) {
    print("searchFeed删除动态");
    if (animationMap.containsKey(id)) {
      animationMap[id].forward().then((value) {
        feedList.removeWhere((v) => v.id == id);
        if (mounted) {
          setState(() {
            animationMap.removeWhere((key, value) => key == id);
          });
        }
        if (context.read<FeedMapNotifier>().value.feedMap.containsKey(id)) {
          context.read<FeedMapNotifier>().deleteFeed(id);
        }
        if (feedList.length == 0) {
          lastTime = null;
          hasNext = null;
          _refreshController.loadComplete();
          requestFeednIterface(refreshOrLoading: true);
        }
      });
    }
  }

  _buildItem(int index) {
    return SizeTransitionView(
        id: feedList[index].id,
        animationMap: animationMap,
        child: ExposureDetector(
          key: Key('searchFeed${feedList[index].id}'),
          child: DynamicListLayout(
            index: index,
            pageName: "searchFeed",
            isShowRecommendUser: false,
            isShowConcern: false,
            model: feedList[index],
            // 可选参数 子Item的个数
            key: GlobalObjectKey("searchFeed$index"),
          ),
          onExposure: (visibilityInfo) {
            // 如果没有显示
            if (context.read<FeedMapNotifier>().value.feedMap[feedList[index].id].isShowInputBox) {
              context.read<FeedMapNotifier>().showInputBox(feedList[index].id);
              print('第$index 块曝光,展示比例为${visibilityInfo.visibleFraction}');
            }
          },
        ));
  }
}

class SearchFeeditem extends StatefulWidget {
  FocusNode focusNode;
  HomeFeedModel model;
  List<HomeFeedModel> list;
  int index;
  String pageName;

  // 搜索动态关键词
  String searchKeyWords;

// 动态lastTime
  int feedLastTime;

  // 动态hasNext
  int feedHasNext;

  SearchFeeditem(
      {this.model,
      this.list,
      this.index,
      this.focusNode,
      this.pageName,
      this.searchKeyWords,
      this.feedLastTime,
      this.feedHasNext});

  @override
  SearchFeeditemState createState() =>
      SearchFeeditemState(model: model, list: list, index: index, focusNode: focusNode, pageName: pageName);
// [index] 列表条目对应的索引
// buildOpenContainerItem() {
// return OpenContainer(
//   // 动画时长
//   transitionDuration: const Duration(milliseconds: 700),
//   transitionType: ContainerTransitionType.fade,
//   //阴影
//   closedElevation: 0.0,
//   //圆角
//   closedShape: const RoundedRectangleBorder(
//     borderRadius: BorderRadius.all(Radius.circular(0.0)),
//   ),
//   ///将要打开的页面
//   openBuilder:
//       (BuildContext context, void Function({Object returnValue}) action) {
//         ///失去输入框焦点
//         focusNode.unfocus();
//     return Item2Page(model: model,);
//   },
//   ///现在显示的页面
//   closedBuilder: (BuildContext context, void Function() action) {
//     ///条目显示的一张图片
//     return buildShowItemContainer();
//   },
// );
// }

// ClipRRect buildShowItemContainer() {
//   return ClipRRect(
//     //圆角图片
//     borderRadius: BorderRadius.circular(2),
//     child: CachedNetworkImage(
//       height: setAspectRatio(1.0 * model.picUrls[0].height, 1.0 * model.picUrls[0].width),
//       // width: ((ScreenUtil.instance.screenWidthDp) / 2),
//       fit: BoxFit.cover,
//       placeholder: (context, url) => new Container(
//           child: new Center(
//         child: new CircularProgressIndicator(),
//       )),
//       imageUrl: model.picUrls[0].url != null ? model.picUrls[0].url : "",
//       errorWidget: (context, url, error) => new Image.asset("images/test.png"),
//     ),
//   );
// }

}

class SearchFeeditemState extends State<SearchFeeditem> {
  SearchFeeditemState({this.focusNode, this.model, this.list, this.index, this.pageName});

  String pageName;
  FocusNode focusNode;
  List<HomeFeedModel> list;
  HomeFeedModel model;
  int index;
  HomeFeedModel feedModel;

  // [index] 列表条目对应的索引
  buildOpenContainerItem() {
    return OpenContainer(
      // 动画时长
      transitionDuration: const Duration(milliseconds: 500),
      transitionType: ContainerTransitionType.fade,
      //阴影
      closedElevation: 0.0,
      //圆角
      closedShape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(0.0)),
      ),

      ///将要打开的页面
      openBuilder: (BuildContext context, void Function({Object returnValue}) action) {
        ///失去输入框焦点
        focusNode.unfocus();
      },

      ///现在显示的页面
      closedBuilder: (BuildContext context, void Function() action) {
        ///条目显示的一张图片
        return buildShowItemContainer();
      },
    );
  }

  ClipRRect buildShowItemContainer() {
    // print("我在搞事情吗？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？");
    return ClipRRect(
      //圆角图片
      borderRadius: BorderRadius.circular(2),
      child: CachedNetworkImage(
        height: setAspectRatio(1.0 * model.picUrls[0].height, 1.0 * model.picUrls[0].width),
        // width: ((ScreenUtil.instance.screenWidthDp) / 2),
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: AppColor.bgWhite,
        ),
        errorWidget: (context, url, e) {
          return Container(
            color: AppColor.bgWhite,
          );
        },
        imageUrl: model.picUrls[0].url != null ? model.picUrls[0].url : "",
      ),
    );
  }

  // 宽高比例高度
  double setAspectRatio(double height, double width) {
    if (index == 0) {
      return (((ScreenUtil.instance.screenWidthDp - 32) / 2 - 4) / width) * height - 20;
    }
    return (((ScreenUtil.instance.screenWidthDp - 32) / 2 - 4) / width) * height;
  }

  // 算出到置顶item的高度
  specifyItemHeight() {
    double itemHeight = 0.0;
    list.forEach((v) {
      // 头部
      itemHeight += 62;
      // 图片
      if (v.picUrls.isNotEmpty) {
        if (v.picUrls.first.height == 0) {
          itemHeight += ScreenUtil.instance.width;
        } else {
          itemHeight += (ScreenUtil.instance.width / v.picUrls[0].width) * v.picUrls[0].height;
        }
      }
      // 视频
      if (v.videos.isNotEmpty) {}
      // 转发评论点赞
      itemHeight += 48;

      //地址和课程
      if (v.address != null || v.courseDto != null) {
        itemHeight += 7;
        itemHeight += getTextSize("123", TextStyle(fontSize: 12), 1).height;
      }

      //文本
      if (v.content.length > 0) {
        itemHeight += 12;
        itemHeight += getTextSize(v.content, TextStyle(fontSize: 14), 2, ScreenUtil.instance.width - 32).height;
      }

      //评论文本
      if (v.comments != null && v.comments.length != 0) {
        itemHeight += 8;
        itemHeight += 6;
        itemHeight += getTextSize("共0条评论", AppStyle.textHintRegular12, 1).height;
        itemHeight += getTextSize("第一条评论", AppStyle.textHintRegular13, 1).height;
        if (v.comments.length > 1) {
          itemHeight += 8;
          itemHeight += getTextSize("第二条评论", AppStyle.textHintRegular13, 1).height;
        }
      }

      // 输入框
      itemHeight += 48;

      //分割块
      itemHeight += 18;
    });
  }

  // @override
  Widget build(BuildContext context) {
    if (model.videos.isNotEmpty) {
      print("视频model数据++++++++++++++++++++${model.videos.toString()}");
    }
    return Container(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        model.picUrls.isNotEmpty
            ? InkWell(
                onTap: () {
                  ///失去输入框焦点
                  if (focusNode != null) {
                    focusNode.unfocus();
                  }
                  // List<HomeFeedModel> result = [];
                  // print("点击查看格式");
                  // print(list.length);
                  // for (feedModel in list) {
                  //   feedModel = context.read<FeedMapNotifier>().feedMap[feedModel.id];
                  //   if (model.id != feedModel.id) {
                  //     result.add(feedModel);
                  //   }
                  // }
                  // result.insert(0, model);
                  // list = result;
                  // print(list.length);

                  Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (context) => FeedFlow(
                              feedList: list,
                              pageName: widget.pageName,
                              searchKeyWords: widget.searchKeyWords,
                              feedLastTime: widget.feedLastTime,
                              feedIndex: widget.index,
                              feedHasNext: widget.feedHasNext,
                            )),
                  );
                },
                child: Hero(
                  tag: pageName + "${model.id}",
                  child: buildShowItemContainer(),
                ),
              )
            // buildOpenContainerItem()
            // ClipRRect(
            //   //圆角图片
            //   borderRadius: BorderRadius.circular(2),
            //   child: CachedNetworkImage(
            //     height: setAspectRatio(1.0 * model.videos[0].height, 1.0 * model.videos[0].width),
            //     width: ((ScreenUtil.instance.screenWidthDp) / 2),
            //     fit: BoxFit.cover,
            //     placeholder: (context, url) => new Container(
            //         child: new Center(
            //           child: new CircularProgressIndicator(),
            //         )),
            //     imageUrl: model.videos[0].coverUrl,
            //     errorWidget: (context, url, error) => new Image.asset("images/test.png"),
            //   ),
            // )
            : Container(),
        model.videos.isNotEmpty ? getVideo(model.videos) : Container(),
        Container(
          width: ((ScreenUtil.instance.screenWidthDp - 32) / 2 - 4) - 16,
          margin: const EdgeInsets.only(top: 8),
          child: Text(
            '${model.content}',
            style: const TextStyle(
              fontSize: 13,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Container(
          width: ((ScreenUtil.instance.screenWidthDp - 32) / 2 - 4) - 16,
          // height: 16,
          padding: const EdgeInsets.only(
            bottom: 8,
            top: 6,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              CircleAvatar(
                backgroundImage: NetworkImage(model.avatarUrl),
                radius: 8,
              ),
              Container(
                margin: const EdgeInsets.only(left: 4),
                width: 81,
                child: Text(
                  model.name,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColor.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              Expanded(
                child: LaudItem(
                  model: model,
                ),
              ),
              // SizedBox(width: 1,)
            ],
          ),
        )
      ],
    ));
  }

  // 视频
  Widget getVideo(List<VideosModel> videos) {
    SizeInfo sizeInfo = SizeInfo();
    sizeInfo.width = videos.first.width;
    sizeInfo.height = videos.first.height;
    sizeInfo.duration = videos.first.duration;
    sizeInfo.offsetRatioX = videos.first.offsetRatioX ?? 0.0;
    sizeInfo.offsetRatioY = videos.first.offsetRatioY ?? 0.0;
    sizeInfo.videoCroppedRatio = videos.first.videoCroppedRatio;
    return FeedVideoPlayer(
      videos.first.url,
      sizeInfo,
      (ScreenUtil.instance.screenWidthDp - 32) / 2 - 4,
      isInListView: true,
    );
  }
}

class LaudItem extends StatefulWidget {
  LaudItem({Key key, this.model}) : super(key: key);
  HomeFeedModel model;

  @override
  LaudItemState createState() => LaudItemState();
}

class LaudItemState extends State<LaudItem> {
  // 点赞
  setUpLuad() async {
    bool isLoggedIn = context.read<TokenNotifier>().isLoggedIn;
    if (isLoggedIn) {
      BaseResponseModel model = await laud(id: widget.model.id, laud: widget.model.isLaud == 0 ? 1 : 0);
      if (model.code == CODE_BLACKED) {
        ToastShow.show(msg: "你已被拉黑", context: context, gravity: Toast.CENTER);
      } else {
        // 点赞/取消赞成功
        if (model.data["state"]) {
          context.read<FeedMapNotifier>().setLaud(
              context.read<FeedMapNotifier>().value.feedMap[widget.model.id].isLaud == 0 ? 1 : 0,
              context.read<ProfileNotifier>().profile.avatarUri,
              widget.model.id);
        } else {
          // 失败
          print("shib ");
        }
      }
    } else {
      // 去登录
      AppRouter.navigateToLoginPage(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            setUpLuad();
          },
          child: AppIcon.getAppIcon(
            (context.select((FeedMapNotifier value) => value.value.feedMap) != null &&
                    context.select((FeedMapNotifier value) => value.value.feedMap[widget.model.id]) != null &&
                    context.select((FeedMapNotifier value) => value.value.feedMap[widget.model.id].isLaud) != null &&
                    context.select((FeedMapNotifier value) => value.value.feedMap[widget.model.id].isLaud) == 1)
                ? AppIcon.like_red_12
                : AppIcon.like_12,
            12,
            containerWidth: 16,
            containerHeight: 16,
          ),
        ),
        const SizedBox(
          width: 2,
        ),
        Offstage(
          offstage: (context.select((FeedMapNotifier value) => value.value.feedMap) != null &&
              context.select((FeedMapNotifier value) => value.value.feedMap[widget.model.id]) != null &&
              context.select((FeedMapNotifier value) => value.value.feedMap[widget.model.id].laudCount) != null &&
              context.select((FeedMapNotifier value) => value.value.feedMap[widget.model.id].laudCount) == 0),
          child: //用Selector的方式监听数据
              Selector<FeedMapNotifier, int>(builder: (context, laudCount, child) {
            return Text(
              "${StringUtil.getNumber(laudCount)}",
              style: TextStyle(
                fontSize: 10,
                color: AppColor.textSecondary,
              ),
            );
          }, selector: (context, notifier) {
            return (notifier.value.feedMap != null &&
                    notifier.value.feedMap[widget.model.id] != null &&
                    notifier.value.feedMap[widget.model.id].laudCount != null)
                ? notifier.value.feedMap[widget.model.id].laudCount
                : 0;
          }),
        ),
        // SizedBox(width: 2,)
      ],
    );
  }
}
