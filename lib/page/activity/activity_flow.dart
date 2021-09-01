import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/config/runtime_properties.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/icon.dart';

class ActivityFlow extends StatefulWidget {
  ActivityFlow(
      {Key key,
        this.feedList,
        this.pageName,
        this.feedLastTime,
        this.searchKeyWords,
        this.feedHasNext,
        this.feedIndex,
        this.listHeight})
      : super(key: key);

  @override
  _ActivityFlowState createState() => _ActivityFlowState();

  // 搜索动态出入列表
  List<HomeFeedModel> feedList;

  // hero动画key,页面名加动态id加索引值
  String pageName;

// 搜索动态关键词
  String searchKeyWords;

// 动态lastTime
  int feedLastTime;

  // 是否存在下一页
  int feedHasNext;

  //  列表的索引值
  int feedIndex;

  // 列表的高度
  double listHeight;
}

class _ActivityFlowState extends State<ActivityFlow> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleString: "活动动态",
        hasLeading: true,
      ),
      body: Stack(
        children: [
          Container(
            color: Colors.amberAccent,
          ),
          Positioned(
            bottom: ScreenUtil.instance.bottomBarHeight + 28,
            left: (ScreenUtil.instance.width - 127) / 2,
            right: (ScreenUtil.instance.width - 127) / 2,
            child: _gotoRelease(),
          )
        ],
      ),
    );
  }
  Widget _gotoRelease() {
    return InkWell(
      // onTap: () {
      //   if (!context.read<TokenNotifier>().isLoggedIn) {
      //     AppRouter.navigateToLoginPage(context);
      //     return;
      //   }
      //   RuntimeProperties.topicMap[model.id] = model;
      //   AppRouter.navigateToMediaPickerPage(context, 9, typeImageAndVideo, true, startPageGallery, false, (result) {},
      //       publishMode: 1, topicId: model.id);
      // },
      child: Container(
        width: 127,
        height: 43,
        decoration: const BoxDecoration(
          color: AppColor.imageBgGrey,
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
        padding: const EdgeInsets.only(left: 12, right: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 27,
              width: 27,
              decoration: const BoxDecoration(
                color: AppColor.white,
                borderRadius: BorderRadius.all(Radius.circular(24)),
              ),
              child: Center(
                child: AppIcon.getAppIcon(
                  AppIcon.camera_27,
                  27,
                ),
              ),
            ),
            const Spacer(),
            const Text(
              "发布动态",
              style: AppStyle.whiteRegular16,
            )
          ],
        ),
      ),
    );
  }
}