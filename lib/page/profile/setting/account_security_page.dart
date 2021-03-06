import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/icon.dart';
import 'package:provider/provider.dart';

//账号与安全
class AccountSecurityPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AccouontSecurityState();
  }
}

class _AccouontSecurityState extends State<AccountSecurityPage> {
  String phoneNumber;
  String qQNumber;
  String weChatNumber;
  String weiboNumber;
  String appleId;
  bool isIos = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    String phone = context.read<ProfileNotifier>().profile.phone;
    phoneNumber = phone.replaceFirst(RegExp(r'\d{4}'), "****", 3);
    if (Platform.isIOS) {
      isIos = true;
    } else if (Platform.isAndroid) {
      isIos = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = ScreenUtil.instance.screenWidthDp;
    double height = ScreenUtil.instance.height;
    return Scaffold(
      backgroundColor: AppColor.mainBlack,
      appBar: CustomAppBar(
        titleString: "账号与安全",
      ),
      body: Container(
        height: height,
        child: Column(
          children: [
            SizedBox(
              height: 12,
            ),
            _itemRow("手机号", phoneNumber),
            Container(
                height: 44,
                width: width,
                color: AppColor.mainBlack,
                padding: EdgeInsets.only(top: 12, left: 16),
                child: Container(
                  height: 32,
                  width: width,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "其他方式登录",
                    style: AppStyle.text1Regular14,
                  ),
                )),
            SizedBox(
              height: 16,
            ),
            _itemRow("QQ", qQNumber ?? "去绑定"),
            _itemRow("微信绑定", weChatNumber ?? "去绑定"),
            _itemRow("微博绑定", weiboNumber ?? "去绑定"),
            isIos ? _itemRow("Apple ID", appleId ?? "去绑定") : Container(),
          ],
        ),
      ),
    );
  }

  Widget _itemRow(String title, String content) {
    return Container(
      height: 48,
      width: ScreenUtil.instance.width,
      padding: EdgeInsets.only(left: 16, right: 16),
      child: Center(
        child: Row(
          children: [
            Text(
              title,
              style: AppStyle.whiteRegular16,
            ),
            Spacer(),
            Text(
              content,
              style: content == "去绑定" ? AppStyle.text1Regular16 : AppStyle.whiteRegular16,
            ),
            SizedBox(
              width: 12,
            ),
            AppIcon.getAppIcon(
              AppIcon.arrow_right_18,
              18,
              color: AppColor.textWhite60,
            ),
          ],
        ),
      ),
    );
  }
}
