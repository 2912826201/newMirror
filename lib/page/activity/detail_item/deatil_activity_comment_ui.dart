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
import 'package:mirror/widget/smart_refressher_head_footer.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:flutter/cupertino.dart';

typedef ValueChangedCallback = void Function();

Future openActivityCommentBottomSheet(
    {@required BuildContext context,
    @required int activityId,
    @required int pushId,
    CommentDtoModel commentDtoModel,
    ValueChangedCallback callback}) async {
  await showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: AppColor.mainBlack,
      context: context,
      // 圆角
      shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10))),
      builder: (BuildContext context) {
        return SizedBox(
          height: ScreenUtil.instance.height * 0.75,
          child: ActivityCommentBottomSheet(
            activityId: activityId,
            pushId: pushId,
            commentDtoModel: commentDtoModel,
          ),
        );
      }).then((value) {
    if (callback != null) {
      callback();
    }
  });
}

class ActivityCommentBottomSheet extends StatefulWidget {
  final int activityId;
  final int pushId;
  final CommentDtoModel commentDtoModel;

  ActivityCommentBottomSheetState createState() =>
      ActivityCommentBottomSheetState(activityId: activityId, commentDtoModel: commentDtoModel);

  ActivityCommentBottomSheet({this.activityId, this.pushId, this.commentDtoModel});
}

class ActivityCommentBottomSheetState extends XCState // State<CommentBottomSheet>
{
  ActivityCommentBottomSheetState({this.activityId, this.pushId, this.commentDtoModel});

  final int pushId;

  // 列表监听
  ScrollController _controller = new ScrollController();

  int activityId;
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

  //滑动的回调
  bool _onDragNotification(ScrollNotification notification) {
    ScrollMetrics metrics = notification.metrics;
    childKey.currentState.scrollHeightOld = metrics.pixels;
    return false;
  }

  @override
  Widget shouldBuild(BuildContext context) {
    print("底部弹窗抽屉");
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            height: 48,
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(width: 0.5, color: AppColor.dividerWhite8)),
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
                    child: Text(
                      "讨论区",
                      style: AppStyle.whiteRegular16,
                    )),
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
          SizedBox(
            height: ScreenUtil.instance.bottomHeight,
          )
        ],
      ),
    );
  }

  // 创建中间视图
  createMiddleView() {
    return Expanded(
      child: NotificationListener<ScrollNotification>(
        onNotification: _onDragNotification,
        child: SmartRefresher(
            enablePullDown: true,
            enablePullUp: true,
            header: SmartRefresherHeadFooter.init().getHeader(),
            footer: SmartRefresherHeadFooter.init().getFooter(isShowNoMore: false),
            controller: _refreshController,
            onLoading: () {
              childKey.currentState.onLoading();
            },
            onRefresh: () {
              childKey.currentState.onRefresh();
            },
            child: CustomScrollView(controller: _controller, physics: ClampingScrollPhysics(), slivers: <Widget>[
              SliverToBoxAdapter(
                child: CommonCommentPage(
                  key: childKey,
                  scrollController: _controller,
                  refreshController: _refreshController,
                  targetId: activityId,
                  commentDtoModel: commentDtoModel,
                  pushId: pushId,
                  targetType: 4,
                  isBottomSheetAndHomePage: true,
                  isVideoCoursePage: true,
                  pageCommentSize: 20,
                  pageSubCommentSize: 3,
                  isShowHotOrTime: true,
                  isInteractiveIn: false,
                  isShowAt: false,
                  isActivity: true,
                  externalBoxHeight: MediaQuery.of(context).size.height * 0.75,
                ),
              )
            ])),
      ),
    );
  }
}
