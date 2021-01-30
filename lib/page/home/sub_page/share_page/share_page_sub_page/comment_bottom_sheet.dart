// 底部评论抽屉
import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/data/notifier/token_notifier.dart';
import 'package:mirror/page/feed/comment_bottom_list.dart';
import 'package:mirror/page/home/sub_page/recommend_page.dart';
import 'package:mirror/page/home/sub_page/share_page/share_page_sub_page/commentInputBox.dart';
import 'package:mirror/page/if_page.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/page/training/currency/currency_comment_page.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/date_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/string_util.dart';
import 'package:mirror/widget/comment_input_bottom_bar.dart';
import 'package:mirror/widget/feed/release_feed_input_formatter.dart';
import 'package:mirror/widget/post_comments.dart';
import 'package:mirror/widget/rich_text_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:provider/provider.dart';

class CommentBottomSheet extends StatefulWidget {
  CommentBottomSheet({Key key, this.feedId}) : super(key: key);

  // 动态id
  int feedId;

  CommentBottomSheetState createState() => CommentBottomSheetState();
}

class CommentBottomSheetState extends State<CommentBottomSheet> {
  // // 数据加载页数
  // int dataPage = 1;
  //
  // // 加载中默认文字
  // String loadText = "加载中...";
  //
  // // 加载状态
  // LoadingStatus loadStatus = LoadingStatus.STATUS_IDEL;

// //  数据源
//   List<CommentDtoModel> commentModel = [];

  // // 请求下一页
  // int hasNext = 0;

  // 列表监听
  ScrollController _controller = new ScrollController();

  //上拉加载数据
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  GlobalKey<CurrencyCommentPageState> childKey = GlobalKey();

  @override
  void dispose() {
    _controller.dispose();
    print('================================底部弹窗dispose');
    super.dispose();
  }

  // // 获取热门评论
  // getQueryListByHot() async {
  //   // 评论总数
  //   int totalCount = -1;
  //   if (loadStatus == LoadingStatus.STATUS_IDEL) {
  //     // 先设置状态，防止下拉就直接加载
  //     setState(() {
  //       loadStatus = LoadingStatus.STATUS_LOADING;
  //     });
  //   }
  //   List<CommentDtoModel> modelList =
  //   await queryListByHot(targetId: widget.feedId, targetType: 0, page: this.dataPage, size: 20);
  //
  //   print("打印返回值￥%${modelList.isNotEmpty}");
  //
  //   setState(() {
  //     totalCount = modelList[0].totalCount;
  //     modelList.removeAt(0);
  //     if (this.dataPage == 1) {
  //       if (modelList.isNotEmpty) {
  //         for (CommentDtoModel model in modelList) {
  //           if (model.replyCount > 0) {
  //             model.isShowInteractiveButton = true;
  //           } else {
  //             model.isShowInteractiveButton = false;
  //           }
  //         }
  //         commentModel.addAll(modelList);
  //         print("数据长度${commentModel.length}");
  //       }
  //     } else if (this.dataPage > 1 && this.hasNext != 0) {
  //       print("5data");
  //       for (CommentDtoModel model in modelList) {
  //         if (model.replyCount > 0) {
  //           model.isShowInteractiveButton = true;
  //         } else {
  //           model.isShowInteractiveButton = false;
  //         }
  //       }
  //       commentModel.addAll(modelList);
  //       print("数据长度${commentModel.length}");
  //       loadStatus = LoadingStatus.STATUS_IDEL;
  //       loadText = "加载中...";
  //     } else {
  //       // 加载完毕
  //       loadText = "已加载全部动态";
  //       loadStatus = LoadingStatus.STATUS_COMPLETED;
  //     }
  //     context.read<FeedMapNotifier>().commensAssignment(widget.feedId, commentModel, totalCount);
  //   });
  // }

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
        child: SmartRefresher(
            enablePullDown: false,
            enablePullUp: true,
            footer: footerWidget(),
            controller: _refreshController,
            onLoading: () {
              childKey.currentState.onLoading();
            },
            child: CustomScrollView(controller: _controller, physics: ClampingScrollPhysics(), slivers: <Widget>[
              SliverToBoxAdapter(
                child: CurrencyCommentPage(
                  key: childKey,
                  scrollController: _controller,
                  refreshController: _refreshController,
                  targetId: widget.feedId,
                  targetType: 0,
                  pageCommentSize: 20,
                  pageSubCommentSize: 3,
                ),
              )
            ])));
  }

  @override
  Widget build(BuildContext context) {
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
