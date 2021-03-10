import 'package:flutter/material.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/icon.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  final double iconSize = 28;
  final double btnSize = 40;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        _backImage(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  EdgeInsets.only(top: ScreenUtil.instance.statusBarHeight, left: CustomAppBar.appBarHorizontalPadding),
              child: CustomAppBarIconButton(
                svgName: AppIcon.nav_return,
                iconColor: AppColor.black,
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ),
            Spacer(),
            _interactiveItems(),
          ],
        ),
      ],
    ));
  }

  //背景图片
  Widget _backImage() {
    return Container(
        child: Image.asset(
      "images/test/bg.png",
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    ));
  }

  //可选登录选项
  Widget _interactiveItems() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sloganArea(),
          _loginOptions(),
          SizedBox(
            height: 12,
          ),
          _agreementArea()
        ],
      ),
      margin: EdgeInsets.only(bottom: 93 + ScreenUtil.instance.bottomBarHeight, left: 41),
    );
  }

  Widget _agreementArea() {
    return Row(
      children: [
        Text(
          "登录即同意健身的",
          style: TextStyle(
            fontSize: 12,
            color: AppColor.textHint,
          ),
        ),
        GestureDetector(
          onTap: () {},
          child: Text(
            "使用条款",
            style: TextStyle(
              fontSize: 12,
              decoration: TextDecoration.underline,
              color: AppColor.textSecondary,
            ),
          ),
        ),
        Text(
          "和",
          style: TextStyle(
            fontSize: 12,
            color: AppColor.textHint,
          ),
        ),
        GestureDetector(
          onTap: () {},
          child: Text(
            "隐私政策",
            style: TextStyle(
              fontSize: 12,
              decoration: TextDecoration.underline,
              color: AppColor.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  //
  Widget _sloganArea() {
    var subTitle = Padding(
      child: Text(
        "此刻开始分享你的健身生活和经验吧~",
        style: TextStyle(
          fontSize: 14,
          color: AppColor.white.withOpacity(0.65),
        ),
        textAlign: TextAlign.left,
      ),
      padding: EdgeInsets.only(top: 9),
    );
    var mainTitle = Container(
      child: Text(
        "Hello~",
        style: TextStyle(
          fontSize: 23,
          color: Colors.white,
          decoration: TextDecoration.none,
        ),
        textAlign: TextAlign.left,
      ),
    );
    var textArea = Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [mainTitle, subTitle],
      ),
    );

    return Padding(
      child: Column(children: [
        textArea,
      ]),
      padding: EdgeInsets.only(bottom: 37),
    );
  }

  //登录的更多选项
  Widget _loginOptions() {
    var label = Text(
      "选择用以下方式登录",
      style: TextStyle(
        fontSize: 14,
        color: AppColor.textHint,
      ),
    );
    var btns = Row(
      children: [
        Container(
          child: AppIconButton(
            iconSize: iconSize,
            buttonWidth: btnSize,
            buttonHeight: btnSize,
            svgName: AppIcon.login_phone,
            iconColor: AppColor.white,
            bgColor: AppColor.black,
            onTap: _phoneLogin,
            isCircle: true,
          ),
          margin: const EdgeInsets.only(right: 12),
        ),
        Application.platform == 0
            ? Container()
            : Container(
                child: AppIconButton(
                  iconSize: iconSize,
                  buttonWidth: btnSize,
                  buttonHeight: btnSize,
                  svgName: AppIcon.login_apple,
                  iconColor: AppColor.white,
                  bgColor: AppColor.black,
                  onTap: _appleLogin,
                  isCircle: true,
                ),
                margin: const EdgeInsets.only(right: 12),
              ),
        Container(
          child: AppIconButton(
            iconSize: iconSize,
            buttonWidth: btnSize,
            buttonHeight: btnSize,
            svgName: AppIcon.login_wechat,
            iconColor: AppColor.white,
            bgColor: AppColor.black,
            onTap: _wechatLogin,
            isCircle: true,
          ),
          margin: const EdgeInsets.only(right: 12),
        ),
        Container(
          child: AppIconButton(
            iconSize: iconSize,
            buttonWidth: btnSize,
            buttonHeight: btnSize,
            svgName: AppIcon.login_qq,
            iconColor: AppColor.white,
            bgColor: AppColor.black,
            onTap: _qqLogin,
            isCircle: true,
          ),
          margin: const EdgeInsets.only(right: 12),
        ),
      ],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          child: label,
          padding: EdgeInsets.only(bottom: 12),
        ),
        btns
      ],
    );
  }

  _qqLogin() {
    print("qq");
  }

  _wechatLogin() {
    print("wechat");
  }

  _phoneLogin() {
    AppRouter.navigateToPhoneLoginPage(context);
  }

  _appleLogin() {
    print("apple");
  }
}
