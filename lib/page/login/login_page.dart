import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/page/login/phone_login_page.dart';
import 'package:mirror/page/login/login_base_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends LoginBasePageState {
  final double _backImageHeight = 1000.0;
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
       _interactiveItems(),
     ],
    ));
  }
  //背景图片
  Widget _backImage() {
    return Container(
      child: Image.asset("images/test/bg.png",
      fit: BoxFit.fill,
      width: double.infinity,
      height: double.infinity,)
    );
  }
  //可选登录选项
  Widget _interactiveItems() {
    return Container(
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_sloganArea(), _loginOptions(), _agreementArea()],
      ),
      padding: EdgeInsets.only(top: (484.0 + 100.0), left: 41),
    );
  }

  Widget _agreementArea() {
    var agreement = Text(
      "登录即同意健身的",
      style: _agreementStyle,
    );
    var t = Container(
      child: agreement,
      margin: EdgeInsets.only(top: 12),
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
          margin: EdgeInsets.only(right: 12),
          width: btnWidth,
          height: btnWidth,
        ),
        Container(
          child: _appleLoginBtn(),
          color: Colors.transparent,
          margin: EdgeInsets.only(right: 12),
          width: btnWidth,
          height: btnWidth,
        ),
        Container(
          child: _wechatLoginBtn(),
          color: Colors.transparent,
          margin: EdgeInsets.only(right: 12),
          width: btnWidth,
          height: btnWidth,
        ),
        Container(
          child: _qqLoginBtn(),
          color: Colors.transparent,
          margin: EdgeInsets.only(right: 12),
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

  Function _qqLogin() {
    print("qq");
  }

  Function _wechatLogin() {
    print("wechat");
  }

  Function _phoneLogin() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return PhoneLoginPage();
    }));
  }

  Function _appleLogin() {
    print("apple");
  }
}
