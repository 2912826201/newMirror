import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/page/home/sub_page/share_page/dynamic_list.dart';
import 'package:mirror/widget/custom_appbar.dart';

class FeedFlow extends StatefulWidget {
  FeedFlow({Key key, this.feedList, this.pageName}) : super(key: key);

  @override
  FeedFlowState createState() => FeedFlowState();
  List<HomeFeedModel> feedList;
  String pageName;
}

class FeedFlowState extends State<FeedFlow> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: CustomAppBar(
            titleString: "动态流",
        ),
        body: Container(
            color: AppColor.white,
            child: CustomScrollView(physics: AlwaysScrollableScrollPhysics(), slivers: [
              SliverList(
                delegate: SliverChildBuilderDelegate((content, index) {
                  return DynamicListLayout(
                    index: index,
                    pageName: widget.pageName,
                    isShowRecommendUser: false,
                    model: widget.feedList[index],
                    // 可选参数 子Item的个数
                    key: GlobalObjectKey("attention$index"),
                    // deleteFeedChanged: (id) {
                    //   setState(() {
                    //     attentionIdList.remove(id);
                    //     context.read<FeedMapNotifier>().deleteFeed(id);
                    //   });
                    // },
                    // removeFollowChanged: (model) {
                    //   int pushId = model.pushId;
                    //   Map<int, HomeFeedModel> feedMap = context.read<FeedMapNotifier>().feedMap;
                    //
                    //   ///临时的空数组
                    //   List<int> themList = [];
                    //   feedMap.forEach((key, value) {
                    //     if (value.pushId == pushId) {
                    //       themList.add(key);
                    //     }
                    //   });
                    //   setState(() {
                    //     attentionIdList = arrayDate(attentionIdList, themList);
                    //     loadStatus = LoadingStatus.STATUS_IDEL;
                    //     loadText = "";
                    //   });
                    // },
                  );
                }, childCount: widget.feedList.length),
              )
            ])));
  }
}
