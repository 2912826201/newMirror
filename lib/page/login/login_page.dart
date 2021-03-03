import 'package:flutter/material.dart';
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
  final _subTitleTextStyle = TextStyle(
      fontFamily: "PingFangSC",
      fontSize: 14,
      color: Color.fromRGBO(255, 255, 255, 0.65),
      decoration: TextDecoration.none);
  final double _btnBorderRadius = 20;
  final double imageWidthOnBtn = 28;
  final double btnWidth = 40;
  final _agreementStyle = TextStyle(
    fontFamily: "PingFangSC-Regular",
    fontSize: 12,
    decoration: TextDecoration.none,
    color: Color.fromRGBO(255, 255, 255, 0.65),
  );

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
        children: [_sloganArea(), _loginOptions(), _agreementArea()],
      ),
      margin: const EdgeInsets.only(bottom: 63, left: 41),
    );
  }

  Widget _agreementArea() {
    var agreement = Text(
      "登录即同意健身的",
      style: _agreementStyle,
    );
    var t = Container(
      child: agreement,
      margin: const EdgeInsets.only(top: 12),
    );
    return t;
  }

  //
  Widget _sloganArea() {
    var subTitle = Padding(
      child: Text(
        "此刻开始分享你的健身生活和经验吧~",
        style: _subTitleTextStyle,
        textAlign: TextAlign.left,
      ),
      padding: EdgeInsets.only(top: 9),
    );
    var mainTitle = Container(
      child: Text(
        "Hello~",
        style: TextStyle(
          fontFamily: "PingFangSC",
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
    ));

    return Padding(
      child: Column(children: [
        textArea,
      ]),
      padding: EdgeInsets.only(bottom: 37),
    );
  }

  //登录的更多选项
  Widget _loginOptions() {
    double fixedWidth = 40;
    double fixedHeight = fixedWidth;
    var label = Text(
      "选择用以下方式登录",
      style: _subTitleTextStyle,
    );
    var btns = Row(
      children: [
        Container(
          child: _phoneLoginBtn(),
          color: Colors.transparent,
          margin: const EdgeInsets.only(right: 12),
          width: btnWidth,
          height: btnWidth,
        ),
        Container(
          child: _appleLoginBtn(),
          color: Colors.transparent,
          margin: const EdgeInsets.only(right: 12),
          width: btnWidth,
          height: btnWidth,
        ),
        Container(
          child: _wechatLoginBtn(),
          color: Colors.transparent,
          margin: const EdgeInsets.only(right: 12),
          width: btnWidth,
          height: btnWidth,
        ),
        Container(
          child: _qqLoginBtn(),
          color: Colors.transparent,
          margin: const EdgeInsets.only(right: 12),
          width: btnWidth,
          height: btnWidth,
        )
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

  //是否安装了微信
  bool _weChatReachable() {
    throw UnimplementedError();
  }

  //是否安装了QQ
  bool _qqReachable() {
    throw UnimplementedError();
  }

  Widget _phoneLoginBtn() {
    var t = Container(
      child: Image.asset(
        'images/test/281.png',
        fit: BoxFit.contain,
      ),
      width: imageWidthOnBtn,
      height: imageWidthOnBtn,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(_btnBorderRadius)),
      ),
    );
    var btn = FlatButton(
      onPressed: _phoneLogin,
      child: t,
      color: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_btnBorderRadius)),
      height: btnWidth,
      padding: EdgeInsets.all(0),
    );

    return btn;
  }

  Widget _appleLoginBtn() {
    var t = Container(
      child: Image.asset(
        'images/test/281.png',
        fit: BoxFit.cover,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(_btnBorderRadius),
        ),
      ),
    );
    var btn = FlatButton(
        onPressed: _appleLogin,
        child: t,
        color: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_btnBorderRadius)),
        height: btnWidth,
        padding: EdgeInsets.all(0));
    return btn;
  }

  Widget _wechatLoginBtn() {
    var t = Container(
      child: Image.asset(
        'images/test/ic_big_share_wechat.png',
        fit: BoxFit.cover,
      ),
      width: imageWidthOnBtn,
      height: imageWidthOnBtn,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(_btnBorderRadius)),
      ),
    );
    var btn = FlatButton(
      onPressed: _wechatLogin,
      child: t,
      color: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_btnBorderRadius)),
      height: btnWidth,
      padding: EdgeInsets.all(0),
    );
    return btn;
  }

  Widget _qqLoginBtn() {
    var t = Container(
      child: Image.asset(
        'images/test/ic_big_share_qq.png',
      ),
      width: imageWidthOnBtn,
      height: imageWidthOnBtn,
      decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(_btnBorderRadius)), color: Colors.black),
    );
    var btn = FlatButton(
      onPressed: _qqLogin,
      child: t,
      color: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_btnBorderRadius)),
      height: btnWidth,
      padding: EdgeInsets.all(0),
    );
    return btn;
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
