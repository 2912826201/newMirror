import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/string_util.dart';
import 'package:mirror/util/text_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/custom_button.dart';
import 'package:provider/provider.dart';

class LoginSucessPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginSucessState();
  }
}

class _LoginSucessState extends State<LoginSucessPage> {
  String username = "";
  double textLeftWidth;
  double textRightWidth;
  double textWidth;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    //todo 第一次注册,以后改了重新录入个人信息后，摇修改第一次注册的鉴别方式
    Application.isShowNewUserDialog=true;

    //note 这里需求为固定宽度内展示文字，超过固定宽度则省略
    String name = context.read<ProfileNotifier>().profile.nickName;
    textLeftWidth = calculateTextWidth("欢迎回来",AppStyle.textMedium23,ScreenUtil.instance.width,1).width+41;
    textRightWidth = calculateTextWidth(", 登陆成功!",AppStyle.textMedium23,ScreenUtil.instance.width,1).width+41;
    textWidth = ScreenUtil.instance.width-textLeftWidth-textRightWidth;
    if(calculateTextWidth(name,AppStyle.textMedium23,ScreenUtil.instance.width,1).width>textWidth){
      name.characters.toList().forEach((element) {
        if(calculateTextWidth(username+element+"...",AppStyle.textMedium23,ScreenUtil.instance.width,1)
            .width<=textWidth){
          username += element;
        }
      });
      username+="...";
    }else{
      username = name;
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = ScreenUtil.instance.screenWidthDp;
    double height = ScreenUtil.instance.height;
    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: CustomAppBar(
        hasDivider: false,
        leading:Container(),
        actions: [
          CustomAppBarTextButton("跳过", AppColor.textPrimary2, () {
            AppRouter.popToBeforeLogin(context);
          }),
        ],
      ),
      body: Container(
        height: height,
        width: width,
        padding: EdgeInsets.only(left: 41, right: 41),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 148,
            ),
            ClipOval(
              child: CachedNetworkImage(
                height: 60,
                width: 60,
                imageUrl: context.watch<ProfileNotifier>().profile.avatarUri,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppColor.bgWhite,
                ),
              ),
            ),
            SizedBox(
              height: 9,
            ),
            Text(
              "欢迎回来$username, 登陆成功!",
              maxLines: 1,
              style: AppStyle.textMedium23,
            ),
            SizedBox(
              height: 12,
            ),
            Text(
              "为了确保让你获得出色的体验,我们需要对你做出进一步的了解。",
              maxLines: 2,
              style: AppStyle.textPrimary3Regular14,
            ),
            SizedBox(
              height: 28,
            ),
            ClickLineBtn(
              title: "立即开始",
              height: 44.0,
              width: width,
              circular: 3.0,
              textColor: AppColor.white,
              fontSize: 16,
              backColor: AppColor.bgBlack,
              color: AppColor.transparent,
              onTap: () {
                AppRouter.navigateToHeightAndWeigetPage(context);
              },
            )
          ],
        ),
      ),
    );
  }
}
