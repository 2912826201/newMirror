import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:mirror/page/profile/profile_detail_page.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/icon.dart';
import 'package:mirror/widget/triangle_path.dart';
import 'package:mirror/widget/vip/vip_nameplate_horazontal_list.dart';
import 'package:mirror/widget/vip/vip_nameplate_pageview.dart';
import 'package:provider/provider.dart';

//会员特权页
class VipNamePlatePage extends StatefulWidget {
  int index;

  VipNamePlatePage({this.index});

  @override
  State<StatefulWidget> createState() {
    return _VipNamePlateState();
  }
}

class _VipNamePlateState extends State<VipNamePlatePage> {
  PageController pageController;
  ScrollController scrollController;
  int oldIndex;
  final List<String> itemName = [
    "身份铭牌",
    "定制计划",
    "饮食指导",
    "专属指导",
    "AI智能纠正",
    "无限次训练",
    "在线互动",
    "视频通话",
    "训练统计",
    "群内答疑",
  ];

  @override
  void initState() {
    super.initState();
    //这里将上个页面点击的索引给到初始索引
    pageController = PageController(initialPage: widget.index);
    if (widget.index < 2) {
      scrollController = ScrollController();
    } else {
      double i = (ScreenUtil.instance.screenWidthDp-namePlateWidth)/2;
      double offset = namePlateWidth * widget.index - i;
      scrollController = ScrollController(initialScrollOffset: offset);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChangeNotifierProvider(
        create: (_) => VipMoveNotifier(choseIndex: widget.index),
        child: Container(
            height: ScreenUtil.instance.height,
            width: ScreenUtil.instance.height,
            child: Stack(
              children: [
                Positioned(
                    child: Container(
                  height: 132 + ScreenUtil.instance.statusBarHeight,
                  width: ScreenUtil.instance.screenWidthDp,
                  color: AppColor.mainBlue,
                )),
                Positioned(top: ScreenUtil.instance.statusBarHeight, child: _title()),
                Positioned(
                    top: 44 + ScreenUtil.instance.statusBarHeight,
                    child: VipNamePlateHorazontalList(
                      index: widget.index,
                      scrollController: scrollController,
                      pageController: pageController,
                    )),
                Positioned(
                    top: 132 + ScreenUtil.instance.statusBarHeight,
                    child: VipNamePlatePageView(
                      namePlateList: itemName,
                      pageController: pageController,
                      scrollController: scrollController,
                    )),
                Positioned(bottom: 0, child: _bottomButton())
              ],
            )),
      ),
    );
  }

  Widget _title() {
    return Container(
      height: 44,
      width: ScreenUtil.instance.screenWidthDp,
      padding: EdgeInsets.only(left: 16, right: 16),
      child: Center(
          child: Row(
        children: [
          Expanded(
            flex: 1,
            child:  Container(
               /* height: 20,
                width: 20,*/
                alignment: Alignment.centerLeft,
                child: CustomAppBarIconButton(
                  svgName: AppIcon.nav_return,
                  iconColor: AppColor.mainBlack,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                "会员特权",
                style: AppStyle.textMedium18,
              ),
            ),
          ),
          Spacer()
        ],
      )),
    );
  }

  Widget _bottomButton() {
    return Container(
      height: ScreenUtil.instance.bottomBarHeight + 49,
      width: ScreenUtil.instance.screenWidthDp,
      decoration: BoxDecoration(
        boxShadow: [
          //阴影效果
          BoxShadow(
            offset: Offset(0, 0.5),
            color: AppColor.textSecondary,
            blurRadius: 3.0, //阴影程度
            spreadRadius: 0, //阴影扩散的程度 取值可以正数,也可以是负数
          ),
        ],
        color: Colors.white,
      ),
      child: Column(
        children: [
          Container(
            height: 49,
            child: Center(
              child: Container(
                height: 40,
                width: ScreenUtil.instance.screenWidthDp * 0.91,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [AppColor.lightGreen, AppColor.textVipPrimary1],
                      begin: FractionalOffset(0.6, 0),
                      end: FractionalOffset(1, 0.6)),
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: Center(
                  child: Text(
                    "立即开通",
                    style: AppStyle.redMedium16,
                  ),
                ),
              ),
            ),
          ),
          Container(
            height: ScreenUtil.instance.bottomBarHeight,
          )
        ],
      ),
    );
  }
}

class VipMoveNotifier extends ChangeNotifier {
  int choseIndex;

  VipMoveNotifier({this.choseIndex});

  void changeListOldIndex(int index) {
    choseIndex = index;
    notifyListeners();
  }
}
