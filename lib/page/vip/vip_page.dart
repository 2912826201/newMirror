import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:mirror/page/profile/profile_detail_page.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/vip_grid_list.dart';
import 'package:mirror/widget/vip_horizontal_list.dart';
import 'package:provider/provider.dart';

class VipPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _vipPageState();
  }
}

class _vipPageState extends State<VipPage> {
  ScrollController controller = ScrollController();
  final String whiteBack = "images/resource/2.0x/white_return@2x.png";
  final String blackBack = "images/resource/2.0x/return2x.png";
  final String serviceText =
      "付款：自动续费商品包括“连续包年/连续包月”，您确认购买后，会从您的偏账号账户扣费； 取消续订：如果需要续订，请在当前订阅周期前24小时以前，手动关闭自动续费功能，到期前24小时内取消，将会收取订阅费用。";

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      if (controller.offset >= 88) {
        context.read<ProfilePageNotifier>().changeBackImage(blackBack);
        context.read<ProfilePageNotifier>().changeTitleColor(AppColor.black);
      } else {
        context.read<ProfilePageNotifier>().changeBackImage(whiteBack);
        context.read<ProfilePageNotifier>().changeTitleColor(AppColor.transparent);
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    context.read<ProfilePageNotifier>().clearTitleColor();
    context.read<ProfilePageNotifier>().clearBackImage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      backgroundColor: AppColor.white,
      body: Container(
        height: ScreenUtil.instance.height,
        width: ScreenUtil.instance.screenWidthDp,
        child: Stack(
          children: [_body(), Positioned(bottom: 0, child: _bottomButton())],
        ),
      ),
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
                    style: AppStyle.textMediumRed16,
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

  Widget _body() {
    return NestedScrollView(
        controller: controller,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              title: Text(context.watch<ProfileNotifier>().profile.nickName,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: context.watch<ProfilePageNotifier>().titleColor)),
              pinned: true,
              forceElevated: false,
              leading: InkWell(
                  onTap: () {
                    Navigator.pop(this.context);
                  },
                  child: Container(
                    margin: EdgeInsets.only(left: 16),
                    child: Image.asset(context.watch<ProfilePageNotifier>().backImage),
                  )),
              backgroundColor: AppColor.white,
              expandedHeight: 132,
              flexibleSpace: FlexibleSpaceBar(background: _appBarBackGround()),
            ),
          ];
        },
        body: MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: Container(
            child: ListView(
              children: [
                SizedBox(
                  height: 24,
                ),
                Container(
                    margin: EdgeInsets.only(left: 16),
                    child: Text(
                      "开通会员",
                      style: AppStyle.textMedium14,
                    )),
                SizedBox(
                  height: 16.5,
                ),
                //包月包年list
                VipHorizontalList(),
                SizedBox(
                  height: 14,
                ),
                Container(
                  padding: EdgeInsets.only(left: 16, right: 16),
                  width: ScreenUtil.instance.screenWidthDp * 0.62,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "这是文案文案文案文案文案文案文案文案",
                        style: AppStyle.textSecondaryRegular14,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 14,
                ),
                Container(
                  width: ScreenUtil.instance.screenWidthDp,
                  height: 12,
                  color: AppColor.bgWhite,
                ),
                SizedBox(
                  height: 24,
                ),
                Container(
                  margin: EdgeInsets.only(left: 16),
                  child: Text(
                    "会员特权",
                    style: AppStyle.textMedium14,
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                //会员特权
                VipGridList(),
                SizedBox(
                  height: 24,
                ),
                Container(
                  margin: EdgeInsets.only(left: 16),
                  child: Text(
                    "自动续费服务声明",
                    style: AppStyle.textMedium14,
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                Container(
                  padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  child: Text(
                    serviceText,
                    style: AppStyle.textHintRegular12,
                    maxLines: 10,
                  ),
                ),
                SizedBox(
                  height: ScreenUtil.instance.bottomBarHeight + 49,
                ),
              ],
            ),
          ),
        ));
  }

  Widget _appBarBackGround() {
    return Container(
      height: 132 + ScreenUtil.instance.statusBarHeight,
      width: ScreenUtil.instance.width,
      padding: EdgeInsets.only(left: 16, right: 16),
      color: AppColor.black,
      child: Column(
        children: [
          SizedBox(
            height: 44 + ScreenUtil.instance.statusBarHeight,
          ),
          Container(
            height: 88,
            child: Center(
              child: Row(
                children: [
                  Container(
                    height: 38,
                    width: 38,
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: context.read<ProfileNotifier>().profile.avatarUri,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Image.asset(
                          "images/test.png",
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 12,
                  ),
                  Container(
                    width: ScreenUtil.instance.screenWidthDp * 0.64,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Spacer(),
                        Text(
                          context.read<ProfileNotifier>().profile.nickName,
                          style: AppStyle.whiteMedium15,
                        ),
                        SizedBox(
                          height: 6,
                        ),
                        Text(
                          "未开通会员",
                          style: AppStyle.whiteRegular12,
                        ),
                        Spacer(),
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
