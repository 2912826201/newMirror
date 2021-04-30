import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/data_response_model.dart';
import 'package:mirror/data/model/home/feed_laud_list.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/no_blue_effect_behavior.dart';
import 'package:mirror/widget/pull_to_refresh/pull_to_refresh.dart';

class Like extends StatefulWidget {
  Like({Key key, this.model}) : super(key: key);
  HomeFeedModel model;

  LikeState createState() => LikeState();
}

class LikeState extends State<Like> {
  List<FeedLaudListModel> laudListModel = [];

  // 请求下一页参数
  int lastTime;
  String footerText = "没有更多了";

  // 是否存在下一页
  int feedLuadHasNext;
  RefreshController refreshController = RefreshController();
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    requestFeedLuadList(isFrist: true);
  }

  // 请求点赞列表
  requestFeedLuadList({bool isFrist = false}) async {
    if (feedLuadHasNext != 0) {
      DataResponseModel model = await getFeedLaudList(targetId: widget.model.id, size: 20, lastTime: lastTime);
      if (model != null) {
        feedLuadHasNext = model.hasNext;
        lastTime = model.lastTime;
        if (model.list.isNotEmpty) {
          model.list.forEach((v) {
            laudListModel.add(FeedLaudListModel.fromJson(v));
          });
          refreshController.loadComplete();
        } else {
          refreshController.loadNoData();
        }
      } else {
        refreshController.loadNoData();
      }
    } else {
      if (!isFrist) {
        refreshController.loadNoData();
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(
          titleString: "赞",
        ),
        body: Container(
          decoration: const BoxDecoration(color: Colors.white),
          child: Column(
            children: [
              Expanded(
                  child: AnimationLimiter(
                      child: MediaQuery.removePadding(
                          removeTop: true,
                          context: context,
                          child: ScrollConfiguration(
                              behavior: NoBlueEffectBehavior(),
                              child: SmartRefresher(
                                enablePullUp: true,
                                enablePullDown: false,
                                controller: refreshController,
                                footer: CustomFooter(
                                  onOffsetChange: (offset) {
                                    if (footerText != "" &&
                                        scrollController.offset > 0 &&
                                        offset >= scrollController.offset) {
                                      print('---------------------------页面数据不够多,不展示文字');
                                      setState(() {
                                        footerText = "";
                                      });
                                    }
                                  },
                                  builder: (BuildContext context, LoadStatus mode) {
                                    Widget body;
                                    if (mode == LoadStatus.loading) {
                                      body = const Text("正在加载");
                                    } else if (mode == LoadStatus.idle) {
                                      body = const Text("上拉加载更多");
                                    } else if (mode == LoadStatus.failed) {
                                      body = const Text("加载失败,请重试");
                                    } else {
                                      body = Text("$footerText");
                                    }
                                    return Container(
                                      child: Center(
                                        child: body,
                                      ),
                                    );
                                  },
                                ),
                                onLoading: () {
                                  requestFeedLuadList();
                                },
                                child: ListView.builder(
                                  controller: scrollController,
                                  itemCount: laudListModel.length,
                                  padding: const EdgeInsets.only(top: 14),
                                  itemBuilder: (context, index) {
                                    return AnimationConfiguration.staggeredList(
                                      position: index,
                                      duration: const Duration(milliseconds: 375),
                                      child: SlideAnimation(
                                        //滑动动画
                                        verticalOffset: 50.0,
                                        child: FadeInAnimation(
                                            //渐隐渐现动画
                                            child: LikeListViewItem(model: laudListModel[index])),
                                      ),
                                    );
                                  },
                                ),
                              )))))
            ],
          ),
        ));
  }
}

class LikeListViewItem extends StatelessWidget {
  FeedLaudListModel model;

  LikeListViewItem({this.model});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, top: 10),
      height: 48,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              height: 38,
              width: 38,
              child: ClipOval(
                  child: CachedNetworkImage(
                /// imageUrl的淡入动画的持续时间。
                // fadeInDuration: Duration(milliseconds: 0),
                imageUrl: FileUtil.getSmallImage(model.avatarUrl) ?? "",
                fit: BoxFit.cover,
                // 调整磁盘缓存中图像大小
                maxHeightDiskCache: 150,
                maxWidthDiskCache: 150,
                placeholder: (context, url) => Container(
                  color: AppColor.bgWhite,
                ),
                errorWidget: (context, url, e) {
                  return Container(
                    color: AppColor.bgWhite,
                  );
                },
              )),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: ScreenUtil.instance.width - 32.0 - 38.0 - 16.0 - 4.0,
                child: Text(
                  "${model.nickName}",
                  // '用户昵称显示',
                  style: const TextStyle(
                    color: AppColor.textPrimary1,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 2),
              Offstage(
                offstage: model.description == null,
                child: Container(
                  width: ScreenUtil.instance.screenWidthDp - 32 - 38 - 38 - 12,
                  child: Text(
                    "${model.description}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColor.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
