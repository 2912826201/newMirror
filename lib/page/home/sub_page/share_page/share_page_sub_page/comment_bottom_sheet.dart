// 底部评论抽屉
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/page/home/sub_page/share_page/share_page_sub_page/commentInputBox.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/page/search/sub_page/should_build.dart';
import 'package:mirror/page/training/common/common_comment_page.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/string_util.dart';
import 'package:mirror/widget/icon.dart';
import 'package:mirror/widget/overscroll_behavior.dart';
import 'package:mirror/widget/smart_refressher_head_footer.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class CommentBottomSheet extends StatefulWidget {
  CommentBottomSheet({Key key, this.feedId, this.commentDtoModel}) : super(key: key);

  // 动态id
  final int feedId;
  final CommentDtoModel commentDtoModel;

  CommentBottomSheetState createState() => CommentBottomSheetState(feedId: feedId, commentDtoModel: commentDtoModel);
}

class CommentBottomSheetState extends XCState // State<CommentBottomSheet>
{
  CommentBottomSheetState({this.feedId, this.commentDtoModel});

  // 列表监听
  ScrollController _controller = new ScrollController();

  // 动态id
  int feedId;
  CommentDtoModel commentDtoModel;

  //上拉加载数据
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  GlobalKey<CommonCommentPageState> childKey = GlobalKey();

  @override
  void dispose() {
    _controller.dispose();
    print('================================底部弹窗dispose');
    super.dispose();
  }

  // 创建中间视图
  createMiddleView() {
    // print(context.select((FeedMapNotifier value) => value.feedMap[feedId].totalCount));
    return Expanded(
      child: NotificationListener<ScrollNotification>(
        onNotification: _onDragNotification,
        child: ScrollConfiguration(
        behavior: OverScrollBehavior(),
    child: SmartRefresher(
            enablePullDown: true,
            enablePullUp: true,
            header: SmartRefresherHeadFooter.init().getHeader(),
            footer: SmartRefresherHeadFooter.init().getFooter(isShowNoMore:false),
            controller: _refreshController,
            onLoading: () {
              childKey.currentState.onLoading();
            },
            onRefresh: (){
              childKey.currentState.onRefresh();
            },
            child: CustomScrollView(controller: _controller, physics: ClampingScrollPhysics(), slivers: <Widget>[
              SliverToBoxAdapter(
                child: CommonCommentPage(
                  key: childKey,
                  scrollController: _controller,
                  refreshController: _refreshController,
                  targetId: feedId,
                  commentDtoModel: commentDtoModel,
                  pushId: context.read<FeedMapNotifier>().value.feedMap[feedId].pushId,
                  targetType: 0,
                  isBottomSheetAndHomePage: true,
                  pageCommentSize: 20,
                  pageSubCommentSize: 3,
                  externalBoxHeight: MediaQuery.of(context).size.height * 0.75,
                ),
              )
            ]))),
      ),
    );
  }

  //滑动的回调
  bool _onDragNotification(ScrollNotification notification) {
    ScrollMetrics metrics = notification.metrics;
    childKey.currentState.scrollHeightOld = metrics.pixels;
    return false;
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Container(
  //     child: Column(
  //       children: <Widget>[
  //         Container(
  //           height: 48,
  //           decoration: BoxDecoration(
  //             border: Border(bottom: BorderSide(width: 0.5, color: Color(0xffe5e5e5))),
  //           ),
  //           child: Stack(
  //             overflow: Overflow.clip,
  //             children: [
  //               // context.watch<FeedMapNotifier>().feedMap[widget.feedId].totalCount != -1
  //               //     ?
  //               Positioned(
  //                       left: 16,
  //                       top: 17,
  //                       // DynamicModelNotifier
  //                       child: Selector<FeedMapNotifier, int>(builder: (context, totalCount, child) {
  //                         return Text(
  //                           "共${StringUtil.getNumber(totalCount)}条评论",
  //                           style: AppStyle.textRegular12,
  //                         );
  //                       }, selector: (context, notifier) {
  //                         return notifier.feedMap[widget.feedId].totalCount;
  //                       }),
  //                       // Text(
  //                       //    "共${commentModel != [] ?  commentModel[0].totalCount : 0}条评论",
  //                       //   style: TextStyle(fontSize: 14),
  //                       // )
  //                     )
  //                   // : Container()
  //               ,
  //               Positioned(
  //                   top: 15,
  //                   right: 16,
  //                   child: GestureDetector(
  //                     child: Image.asset("images/resource/2.0x/ic_big_nav_closepage@2x.png", width: 18, height: 18),
  //                     onTap: () {
  //                       Navigator.pop(context, true);
  //                     },
  //                   ))
  //             ],
  //           ),
  //         ),
  //         createMiddleView(),
  //         CommentInputBox(
  //           isUnderline: true,
  //           feedModel: context.watch<FeedMapNotifier>().feedMap[widget.feedId],
  //         ),
  //         SizedBox(
  //           height: ScreenUtil.instance.bottomHeight,
  //         )
  //       ],
  //     ),
  //   );
  // }

  @override
  Widget shouldBuild(BuildContext context) {
    print("底部弹窗抽屉");
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            height: 48,
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(width: 0.5, color:AppColor.dividerWhite8)),
            ),
            child: Stack(
              overflow: Overflow.clip,
              children: [
                // context.watch<FeedMapNotifier>().feedMap[widget.feedId].totalCount != -1
                //     ?
                Positioned(
                  left: 16,
                  top: 14,
                  // DynamicModelNotifier
                  child: Selector<FeedMapNotifier, int>(builder: (context, totalCount, child) {
                    return Text(
                      "共${StringUtil.getNumber(totalCount)}条评论",
                      style: AppStyle.whiteMedium14,
                    );
                  }, selector: (context, notifier) {
                    return notifier.value.feedMap[feedId].commentCount;
                  }),
                  // Text(
                  //    "共${commentModel != [] ?  commentModel[0].totalCount : 0}条评论",
                  //   style: TextStyle(fontSize: 14),
                  // )
                )
                // : Container()
                ,
                Positioned(
                  top: 6,
                  right: 7,
                  child: AppIconButton(
                    svgName: AppIcon.close_18,
                    iconSize: 18,
                    iconColor: AppColor.white,
                    buttonHeight: 36,
                    buttonWidth: 36,
                    onTap: () {
                      Navigator.pop(context, true);
                    },
                  ),
                ),
              ],
            ),
          ),
          createMiddleView(),
          CommentInputBox(
            isUnderline: true,
            feedModel: context.watch<FeedMapNotifier>().value.feedMap[feedId],
          ),
          SizedBox(
            height: ScreenUtil.instance.bottomHeight,
          )
        ],
      ),
    );
  }
}
