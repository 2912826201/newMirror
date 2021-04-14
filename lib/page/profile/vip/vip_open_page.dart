import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:mirror/page/profile/vip/vip_not_open_page.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/date_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/text_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/vip/vip_grid_list.dart';
import 'package:provider/provider.dart';

//会员已开通页
class VipOpenPage extends StatefulWidget {
  int vipState;
  VipOpenPage({this.vipState});
  @override
  State<StatefulWidget> createState() {
    return _VipOpenPage();
  }
}

class _VipOpenPage extends State<VipOpenPage> {
  double textWidth;
  int lastTime = 1432121322112;
  int vipState = VipState.EXPIRED;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    vipState =widget.vipState;
    TextPainter testSize =
        calculateTextWidth(context.read<ProfileNotifier>().profile.nickName, AppStyle.whiteMedium15, 150, 1);
    textWidth = testSize.width;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        backgroundColor: AppColor.black,
        brightness: Brightness.dark,
        titleString: "我的VIP会员",
      ),
      body: Container(
        height: ScreenUtil.instance.height,
        width: ScreenUtil.instance.screenWidthDp,
        child: ListView(
          children: [
            Stack(
              children: [
                //背景图和网格布局
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 88,
                        width: ScreenUtil.instance.screenWidthDp,
                        color: AppColor.black,
                      ),
                      Container(
                        height: 124,
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 16),
                        child: Text(
                          "会员尊享权益",
                          style: vipState == VipState.EXPIRED ? AppStyle.textSecondaryRegular16 : AppStyle.redMedium16,
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 16, right: 16),
                        child: VipGridList(
                          vipType: VipType.OPEN,
                          vipState: vipState,
                        ),
                      )
                    ],
                  ),
                ),
                //会员信息牌
                Positioned(
                    top: 20,
                    child: Container(
                      width: ScreenUtil.instance.screenWidthDp,
                      height: 160,
                      padding: EdgeInsets.only(left: 16, right: 16),
                      child: Container(
                          padding: EdgeInsets.only(top: 21, bottom: 17, right: 16, left: 16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: vipState == VipState.EXPIRED
                                    ? [
                                        AppColor.textHint,
                                        AppColor.textSecondary,
                                      ]
                                    : [AppColor.bgVip1,AppColor.bgVip2],
                                begin: FractionalOffset(0, 0.7),
                                end: FractionalOffset(0.7, 1)),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          child: Column(
                            children: [_userNameAvatar(), Spacer(), _vipLastTime()],
                          )),
                    ))
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _userNameAvatar() {
    return Row(
      children: [
        ClipOval(
          child: CachedNetworkImage(
            height: 38,
            width: 38,
            imageUrl: context.watch<ProfileNotifier>().profile.avatarUri,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: AppColor.bgWhite,
            ),
          ),
        ),
        SizedBox(
          width: 12,
        ),
        Container(
          width: 193,
          child: Row(
            children: [
              Container(
                width: textWidth < 150 ? textWidth : 150,
                child: Text(
                  context.watch<ProfileNotifier>().profile.nickName,
                  style: AppStyle.whiteMedium15,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                alignment: Alignment.topLeft,
                child: Image.asset(
                  vipState == VipState.EXPIRED
                      ? "images/resource/2.0x/vip_notopen_icon@2x.png"
                      : "images/resource/2.0x/vip_open_icon@2x.png",
                  width: 43,
                  height: 16,
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _vipLastTime() {
    return Row(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            vipState == VipState.EXPIRED ? "已过期56天" : "vip会员至${DateUtil.generateFormatDate(lastTime,true)}",
            style: vipState == VipState.EXPIRED ? AppStyle.whiteRegular12 : AppStyle.redRegular13,
          ),
        ),
        Spacer(),
        InkWell(
          onTap: () {
           AppRouter.navigateToVipPage(context,vipState,openOrNot: false);
          },
          child: Container(
            height: 31,
            width: 88,
            decoration: BoxDecoration(
              color: vipState == VipState.EXPIRED ? AppColor.textHint : AppColor.bgVip1,
              borderRadius: BorderRadius.all(Radius.circular(14)),
            ),
            child: Center(
              child: Text(
                "立即续费",
                style: vipState == VipState.EXPIRED ? AppStyle.whiteMedium14 : AppStyle.redMedium14,
              ),
            ),
          ),
        )
      ],
    );
  }
}
