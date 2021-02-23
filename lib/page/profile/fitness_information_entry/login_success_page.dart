import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:mirror/page/profile/fitness_information_entry/height_and_weight_page.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/screen_util.dart';
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
  String username;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    String name = context.read<ProfileNotifier>().profile.nickName;
    if (name.length > 2) {
      name = name.substring(0, 2);
      username = name + "...";
    } else {
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
        actions: [
          CustomAppBarTextButton("跳过", AppColor.textPrimary2, false, () {
            AppRouter.popToBeforeLogin(context);
          }),
        ],
      ),
      body: Container(
        height: height,
        width: width,
        padding: EdgeInsets.only(left: width * 0.11, right: width * 0.11),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: height * 0.18,
            ),
            ClipOval(
              child: CachedNetworkImage(
                height: 60,
                width: 60,
                imageUrl: context.watch<ProfileNotifier>().profile.avatarUri,
                fit: BoxFit.cover,
                placeholder: (context, url) => Image.asset(
                  "images/test.png",
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(
              height: 9,
            ),
            Text(
              "欢迎回来$username,登陆成功!",
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
