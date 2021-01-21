import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:mirror/page/vip/vip_not_open_page.dart';
import 'package:mirror/util/date_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/text_util.dart';
import 'package:mirror/widget/vip/vip_grid_list.dart';
import 'package:provider/provider.dart';
//会员已开通页
class VipOpenPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _VipOpenPage();
  }
}

class _VipOpenPage extends State<VipOpenPage> {
  double textWidth;
  int lastTime = 1432121322112;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    TextPainter testSize =
        calculateTextWidth(context.read<ProfileNotifier>().profile.nickName, AppStyle.whiteMedium15, 150, 1);
    textWidth = testSize.width;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.black,
        leading: InkWell(
          child: Container(
            margin: EdgeInsets.only(left: 16),
            child: Image.asset("images/resource/2.0x/white_return@2x.png"),
          ),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "我的VIP会员",
          style: AppStyle.whiteMedium18,
        ),
        centerTitle: true,
      ),
      body: Container(
        height: ScreenUtil.instance.height,
        width: ScreenUtil.instance.screenWidthDp,
        child: ListView(
          children: [
            Stack(
              children: [
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
                        style: AppStyle.redMedium16,
                      ),),
                      SizedBox(
                        height: 16,
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 16, right: 16),
                        child: VipGridList(
                          vipType: VipType.OPEN,
                        ),
                      )
                    ],
                  ),
                ),
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
                                colors: [AppColor.lightGreen, AppColor.textVipPrimary1],
                                begin: FractionalOffset(0.6, 0),
                                end: FractionalOffset(1, 0.6)),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          child: Column(
                            children: [
                              _userNameAvatar(),
                              Spacer(),
                              _vipLastTime()
                            ],
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
            placeholder: (context, url) => Image.asset(
              "images/test.png",
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(
          width: 12,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                      "images/resource/2.0x/vip_logo@2x.png",
                      width: 43,
                      height: 16,
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 7,
            ),
            Text(
              "管理制度续费 >",
              style: AppStyle.whiteRegular12,
            ),
          ],
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
          "vip会员至${DateUtil.generateFormatDate(lastTime)}",
          style: AppStyle.redRegular13,
        ),),
        Spacer(),
        InkWell(
          onTap: (){
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return VipNotOpenPage(type: VipState.RENEW,);
            }));
          },
          child: Container(
          height: 31,
          width: 88,
          decoration: BoxDecoration(
              color: AppColor.bgVip1,
              borderRadius: BorderRadius.all(Radius.circular(14)),),
          child: Center(
            child: Text("立即续费",style: AppStyle.redMedium14,),
          ),
        ),)
      ],
    );
  }
}
