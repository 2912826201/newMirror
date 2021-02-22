// 底部评论抽屉
import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/page/home/sub_page/share_page/share_page_sub_page/commentInputBox.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/page/training/common/common_comment_page.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/string_util.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:provider/provider.dart';

class CommentBottomSheet extends StatefulWidget {
  CommentBottomSheet({Key key, this.feedId}) : super(key: key);

  // 动态id
  int feedId;

  CommentBottomSheetState createState() => CommentBottomSheetState();
}

class CommentBottomSheetState extends State<CommentBottomSheet> {

  // 列表监听
  ScrollController _controller = new ScrollController();

  //上拉加载数据
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  GlobalKey<CommonCommentPageState> childKey = GlobalKey();

  @override
  void dispose() {
    _controller.dispose();
    print('================================底部弹窗dispose');
    super.dispose();
  }

  //底部或滑动
  Widget footerWidget() {
    return CustomFooter(
      builder: (BuildContext context, LoadStatus mode) {
        Widget body;
        if (mode == LoadStatus.idle) {
          body = Text("");
        } else if (mode == LoadStatus.loading) {
          body = Container(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(),
          );
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
    );
  }

  // 创建中间视图
  createMiddleView() {

    print(context.select((FeedMapNotifier value) => value.feedMap[widget.feedId].totalCount));
    return Expanded(
      child:NotificationListener<ScrollNotification>(
        onNotification: _onDragNotification,
        child:SmartRefresher(
            enablePullDown: false,
            enablePullUp: true,
            footer: footerWidget(),
            controller: _refreshController,
            onLoading: () {
              childKey.currentState.onLoading();
            },
            child: CustomScrollView(controller: _controller, physics: ClampingScrollPhysics(), slivers: <Widget>[
              SliverToBoxAdapter(
                child: CommonCommentPage(
                  key: childKey,
                  scrollController: _controller,
                  refreshController: _refreshController,
                  targetId: widget.feedId,
                  pushId: context.watch<FeedMapNotifier>().feedMap[widget.feedId].pushId,
                  targetType: 0,
                  pageCommentSize: 20,
                  pageSubCommentSize: 3,
                  externalBoxHeight:MediaQuery.of(context).size.height*0.75,
                ),
              )
            ])),
      ),
    );
  }

  //滑动的回调
  bool _onDragNotification(ScrollNotification notification) {
    ScrollMetrics metrics = notification.metrics;
    childKey.currentState.scrollHeightOld=metrics.pixels;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    print('**********************************评论抽屉build、');
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            height: 48,
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(width: 0.5, color: Color(0xffe5e5e5))),
            ),
            child: Stack(
              overflow: Overflow.clip,
              children: [
                // context.watch<FeedMapNotifier>().feedMap[widget.feedId].totalCount != -1
                //     ?
                Positioned(
                        left: 16,
                        top: 17,
                        // DynamicModelNotifier
                        child: Selector<FeedMapNotifier, int>(builder: (context, totalCount, child) {
                          return Text(
                            "共${StringUtil.getNumber(totalCount)}条评论",
                            style: AppStyle.textRegular12,
                          );
                        }, selector: (context, notifier) {
                          return notifier.feedMap[widget.feedId].totalCount;
                        }),
                        // Text(
                        //    "共${commentModel != [] ?  commentModel[0].totalCount : 0}条评论",
                        //   style: TextStyle(fontSize: 14),
                        // )
                      )
                    // : Container()
                ,
                Positioned(
                    top: 15,
                    right: 16,
                    child: GestureDetector(
                      child: Image.asset("images/resource/2.0x/ic_big_nav_closepage@2x.png", width: 18, height: 18),
                      onTap: () {
                        Navigator.pop(context, true);
                      },
                    ))
              ],
            ),
          ),
          createMiddleView(),
          CommentInputBox(
            isUnderline: true,
            feedModel: context.watch<FeedMapNotifier>().feedMap[widget.feedId],
          ),
          SizedBox(
            height: ScreenUtil.instance.bottomHeight,
          )
        ],
      ),
    );
  }
}
