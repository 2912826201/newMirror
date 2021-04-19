import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:mirror/util/date_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/no_blue_effect_behavior.dart';
import 'package:mirror/widget/vip/vip_grid_list.dart';
import 'package:mirror/widget/vip/vip_horizontal_list.dart';
import 'package:provider/provider.dart';

class VipState {
  //续费
  static int RENEW = 1;

  //未开通
  static int NOTOPEN = 2;

  //已过期
  static int EXPIRED = 3;
}

//会员未开通页
class VipNotOpenPage extends StatefulWidget {
  int type;

  VipNotOpenPage({this.type});

  @override
  State<StatefulWidget> createState() {
    return _VipPageState();
  }
}

class _VipPageState extends State<VipNotOpenPage> {
  ScrollController controller = ScrollController();
  final String serviceText =
      "付款：自动续费商品包括“连续包年/连续包月”，您确认购买后，会从您的偏账号账户扣费； 取消续订：如果需要续订，请在当前订阅周期前24小时以前，手动关闭自动续费功能，到期前24小时内取消，将会收取订阅费用。";
  int lastTime = 12123434545455;
  bool wacthOffset = true;
  StreamController<double> streamController = StreamController<double>();

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      print("controller.offset：${controller.offset}");
      if (controller.offset >= 88) {
        streamController.sink.add(1);
      } else {
        streamController.sink.add(controller.offset * (1 / 88));
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        backgroundColor: AppColor.black,
        brightness: Brightness.dark,
        titleWidget: StreamBuilder<double>(
          initialData: 0,
          stream: streamController.stream,
          builder: (BuildContext stramContext, AsyncSnapshot<double> snapshot) {
            return Opacity(
              opacity: snapshot.data,
              child: Container(
                height: CustomAppBar.appBarHeight,
                width: 28,
                alignment: Alignment.center,
                child: ClipOval(
                  child: CachedNetworkImage(
                    height: 28,
                    width: 28,
                    imageUrl: context.read<ProfileNotifier>().profile.avatarUri,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppColor.bgWhite,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
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

  Widget _body() {
    return ScrollConfiguration(
      behavior: NoBlueEffectBehavior(),
      child: ListView(
        //禁止回弹效果
        physics: ClampingScrollPhysics(),
        controller: controller,
        children: [
          _avatarName(),
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
                widget.type == VipState.NOTOPEN
                    ? Text(
                        "这是文案文案文案文案文案文案文案文案",
                        style: AppStyle.textSecondaryRegular14,
                      )
                    : Container(),
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
          VipGridList(
            vipType: VipType.NOTOPEN,
          ),
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
    );
  }

  Widget _avatarName() {
    return Container(
      height: 88,
      color: AppColor.black,
      padding: EdgeInsets.only(left: 16),
      child: Center(
        child: Row(
          children: [
            Container(
              height: 38,
              width: 38,
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: context.watch<ProfileNotifier>().profile.avatarUri,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppColor.bgWhite,
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
                    context.watch<ProfileNotifier>().profile.nickName,
                    style: AppStyle.whiteMedium15,
                  ),
                  SizedBox(
                    height: 6,
                  ),
                  widget.type != VipState.RENEW
                      ? Text(
                          widget.type == VipState.NOTOPEN ? "未开通会员" : "已过期",
                          style: AppStyle.textHintRegular13,
                        )
                      : RichText(
                          text: TextSpan(
                              text: "${DateUtil.generateFormatDate(lastTime, true)}到期  ",
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: AppColor.bgVip2),
                              children: [
                              TextSpan(text: "购买后有效期延长", style: AppStyle.textHintRegular13),
                            ])),
                  Spacer(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
