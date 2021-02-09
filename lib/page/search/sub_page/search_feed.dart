import 'dart:async';

// import 'dart:html';
import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/api/search/search_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/data_response_model.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/data/model/media_file_model.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:mirror/data/notifier/token_notifier.dart';
import 'package:mirror/page/feed/feed_flow.dart';
import 'package:mirror/page/home/sub_page/recommend_page.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/string_util.dart';
import 'package:mirror/widget/Input_method_rules/pin_yin_text_edit_controller.dart';
import 'package:mirror/widget/feed_video_player.dart';
import 'package:mirror/widget/slide_banner.dart';
import 'package:provider/provider.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

class SearchFeed extends StatefulWidget {
  SearchFeed({Key key, this.keyWord, this.focusNode, this.textController}) : super(key: key);
  FocusNode focusNode;
  String keyWord;
  TextEditingController textController;

  @override
  SearchFeedState createState() => SearchFeedState();
}

class SearchFeedState extends State<SearchFeed> with AutomaticKeepAliveClientMixin {
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
  bool useSubstance() {
    return true;
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
      // 取消延时
      if (timer != null) {
        timer.cancel();
      }
      // 延迟器:
      timer = Timer(Duration(milliseconds: 700), () {
        if (lastString != widget.keyWord) {
          if (feedList.isNotEmpty) {
            feedList.clear();
            lastTime = null;
            hasNext = null;
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
    _scrollController.dispose();

    ///取消延时任务
    timer.cancel();
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
      DataResponseModel model = await searchFeed(key: widget.keyWord, size: 20, lastTime: lastTime);
      lastTime = model.lastTime;
      hasNext = model.hasNext;
      if (model.list.isNotEmpty) {
        model.list.forEach((v) {
          feedList.add(HomeFeedModel.fromJson(v));
        });
        loadStatus = LoadingStatus.STATUS_IDEL;
        loadText = "加载中...";
      }
      List<HomeFeedModel> feedModel = [];
      context.read<FeedMapNotifier>().feedMap.forEach((key, value) {
        feedModel.add(value);
      });
      // 更新全局内没有的数据
      context.read<FeedMapNotifier>().updateFeedMap(StringUtil.followModelFilterDeta(feedList, feedModel));
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
    print("biubiu!@@###%%^^^&&&&****(((()))))_+++==--009");
    print(feedList.isNotEmpty);
    if (feedList.isNotEmpty) {
      return Container(
          margin: EdgeInsets.only(top: 12),
          child: RefreshIndicator(
              onRefresh: () async {
                feedList.clear();
                lastTime = null;
                hasNext = null;
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
                      child: WaterfallFlow.builder(
                        primary: false,
                        shrinkWrap: true,
                        // controller: _scrollController,
                        gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          // 上下间隔
                          mainAxisSpacing: 4.0,
                          //   // 左右间隔
                          crossAxisSpacing: 8.0,
                        ),
                        itemBuilder: (context, index) {
                          // 获取动态id
                          int id;
                          // 获取动态id指定model
                          HomeFeedModel model;
                          if (index < feedList.length) {
                            id = feedList[index].id;
                            model = context.read<FeedMapNotifier>().feedMap[id];
                          }
                          if (index == feedList.length) {
                            return LoadingView(
                              loadText: loadText,
                              loadStatus: loadStatus,
                            );
                          } else if (index == feedList.length + 1) {
                            return Container();
                          } else {
                            return SearchFeeditem(
                              model: model,
                              list: feedList,
                              index: index,
                              focusNode: widget.focusNode,
                              pageName: "searchFeed",
                              feedLastTime: lastTime,
                              searchKeyWords: widget.textController.text,
                              feedHasNext: hasNext,
                            );
                          }
                        },
                        itemCount: feedList.length + 1,
                      )
                      // child: StaggeredGridView.countBuilder(
                      //   shrinkWrap: true,
                      //   itemCount: feedList.length + 1,
                      //   primary: false,
                      //   crossAxisCount: 4,
                      //   // 上下间隔
                      //   mainAxisSpacing: 4.0,
                      //   // 左右间隔
                      //   crossAxisSpacing: 8.0,
                      //   controller: _scrollController,
                      //   itemBuilder: (context, index) {
                      //     // 获取动态id
                      //     int id;
                      //     // 获取动态id指定model
                      //     HomeFeedModel model;
                      //     if (index < feedList.length) {
                      //       id = feedList[index].id;
                      //       model = context.read<FeedMapNotifier>().feedMap[id];
                      //     }
                      //     // if (feedList.isNotEmpty) {
                      //     if (index == feedList.length) {
                      //       return LoadingView(
                      //         loadText: loadText,
                      //         loadStatus: loadStatus,
                      //       );
                      //     } else if (index == feedList.length + 1) {
                      //       return Container();
                      //     } else {
                      //       return SearchFeeditem(
                      //         model: model,
                      //         list: feedList,
                      //         index: index,
                      //         focusNode: widget.focusNode,
                      //         pageName: "searchFeed",
                      //         feedLastTime: lastTime,
                      //         searchKeyWords: widget.textController.text,
                      //         feedHasNext: hasNext,
                      //       );
                      //     }
                      //     // }
                      //   },
                      //   staggeredTileBuilder: (index) => StaggeredTile.fit(2),
                      // )
                      ),
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
        placeholder: (context, url) => new Container(
            child: new Center(
          child: new CircularProgressIndicator(),
        )),
        imageUrl: model.picUrls[0].url != null ? model.picUrls[0].url : "",
        errorWidget: (context, url, error) => new Image.asset("images/test.png"),
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
          margin: EdgeInsets.only(top: 8),
          child: Text(
            '${model.content}',
            style: TextStyle(
              fontSize: 13,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Container(
          width: ((ScreenUtil.instance.screenWidthDp - 32) / 2 - 4) - 16,
          // height: 16,
          padding: EdgeInsets.only(
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
                margin: EdgeInsets.only(left: 4),
                width: 81,
                child: Text(
                  model.name,
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColor.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(
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
      Map<String, dynamic> model = await laud(id: widget.model.id, laud: widget.model.isLaud == 0 ? 1 : 0);
      // 点赞/取消赞成功
      if (model["state"]) {
        context
            .read<FeedMapNotifier>()
            .setLaud(widget.model.isLaud, context.read<ProfileNotifier>().profile.avatarUri, widget.model.id);
      } else {
        // 失败
        print("shib ");
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
          child: Icon(
            Icons.favorite,
            color: context.select((FeedMapNotifier value) => value.feedMap[widget.model.id].isLaud) == 1
                ? Colors.red
                : Colors.grey,
            size: 16,
          ),
        ),
        SizedBox(
          width: 2,
        ),
        Offstage(
          offstage: context.select((FeedMapNotifier value) => value.feedMap[widget.model.id].laudCount) == 0,
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
            return notifier.feedMap[widget.model.id].laudCount;
          }),
        ),
        // SizedBox(width: 2,)
      ],
    );
  }
}
