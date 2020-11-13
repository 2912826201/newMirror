
// import 'package:flutter/dart:html';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/page/Log/PhoneLogPage.dart';
import 'package:mirror/page/Log/log_base_page.dart';


class LogPage extends StatefulWidget{
  @override
  _LogPageState createState() {
    return _LogPageState();
  }
}
class _LogPageState extends LogRegisterBasePageState {
  final double _backImageHeight = 1000.0;
  final _subTitleTextStyle = TextStyle(fontFamily: "PingFangSC",
      fontSize: 14,color: Color.fromRGBO(255, 255, 255, 0.65),
      decoration: TextDecoration.none);
  final double _btnBorderRadius = 20;
  final double imageWidthOnBtn = 28;
  final double btnWidth = 40;
  final _agreementStyle = TextStyle(
    fontFamily: "PingFangSC-Regular",
    fontSize: 12,
    decoration: TextDecoration.none,
    color: Color.fromRGBO(255, 255, 255, 0.65),);
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return  Stack(
        children: [
        //背景图
              _backImage(),
       //背景图上方的其他交互性UI元素集合
              _interactiveItems(),
                  ],
              );
  }
  Widget _backImage(){
    return Expanded(
        child: Image.asset("assets/images/bg.png",
          fit: BoxFit.cover,
          height: _backImageHeight,));
  }
  Widget _interactiveItems(){

    return Container(
      color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sloganArea(),
            _logOptions(),
            _agreementArea()
          ],
        ),
      padding: EdgeInsets.only(top: (484.0+100.0),left: 41),
    );

  }

  Widget _agreementArea(){
    var agreement = Text("登录即同意健身的",style: _agreementStyle,);
    var t = Container(
      child: agreement,
      margin: EdgeInsets.only(top: 12),
    );
    return t;
  }
  //
  Widget _sloganArea(){
    var  subTitle = Padding(child: Text("此刻开始分享你的健身生活和经验吧~",
      style: _subTitleTextStyle,textAlign: TextAlign.left,),
      padding: EdgeInsets.only(top: 9),);
    var  mainTitle = Container(child: Text("Hello~",
      style: TextStyle(fontFamily: "PingFangSC",
        fontSize: 23,color: Colors.white,
        decoration: TextDecoration.none,),
      textAlign: TextAlign.left,),);
    var textArea = Container(
    child: Column(crossAxisAlignment:CrossAxisAlignment.start ,
      children: [mainTitle,subTitle],)
    );
   
    return Padding(child: Column(children: [
      textArea,
    ]),padding: EdgeInsets.only(bottom: 37),);
  }
  //登录的更多选项
  Widget _logOptions(){
    double fixedWidth = 40;
    double fixedHeight = fixedWidth;
    var label = Text("选择用以下方式登录",style: _subTitleTextStyle,);
    var btns = Row(children: [
      Container(
        child: _phoneLogBtn(),
        color: Colors.transparent,
        margin: EdgeInsets.only(right: 12),
        width: btnWidth,height: btnWidth,),
      Container(
        child: _appleLogBtn(),
        color: Colors.transparent,
        margin: EdgeInsets.only(right: 12),
        width: btnWidth,height: btnWidth,),
      Container(
        child: _weChatLogBtn(),
        color: Colors.transparent,
        margin: EdgeInsets.only(right: 12),
        width: btnWidth,height: btnWidth,),
      Container(
        child: _qqLogBtn(),
        color: Colors.transparent,
        margin: EdgeInsets.only(right: 12),
        width: btnWidth,
        height: btnWidth,)
    ],);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
      Container(child: label,padding: EdgeInsets.only(bottom: 12),),
      btns
    ],);
  }
  //是否安装了微信
  bool _weChatReachable(){
    throw UnimplementedError();
  }
  //是否安装了QQ
  bool _qqReachable(){
    throw UnimplementedError();
  }
  
  Widget _phoneLogBtn(){
    var t = Container(child: Image.asset('assets/images/281.png',fit: BoxFit.contain,),
      width: imageWidthOnBtn,
      height: imageWidthOnBtn,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(_btnBorderRadius)),
      ),);
    var btn =
     FlatButton(onPressed:_phoneLog, child: t,
      color: Colors.black,
      shape:RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_btnBorderRadius)),height: btnWidth,padding: EdgeInsets.all(0),);

    return btn;
  }
  Widget _appleLogBtn(){
    var t = Container(child:Image.asset('assets/images/281.png',fit: BoxFit.cover,) ,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(_btnBorderRadius),),
      ),);
    var btn =
    FlatButton(onPressed: _appleLog, child: t,
      color: Colors.black,
      shape:RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_btnBorderRadius)),height: btnWidth,padding: EdgeInsets.all(0));
    return btn;
  }
  Widget _weChatLogBtn(){
    var t = Container(child:Image.asset('assets/images/ic_big_share_wechat.png',fit: BoxFit.cover,) ,
      width: imageWidthOnBtn,
      height: imageWidthOnBtn,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(_btnBorderRadius)),
      ),);
    var btn =
    FlatButton(onPressed: _weChatLog, child: t,
      color: Colors.black,
      shape:RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_btnBorderRadius)),height: btnWidth,padding: EdgeInsets.all(0),);
    return btn;
  }
  Widget _qqLogBtn(){
    var t = Container(child:Image.asset('assets/images/ic_big_share_qq.png',) ,
      width: imageWidthOnBtn,
      height: imageWidthOnBtn,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(_btnBorderRadius)),
          color: Colors.black
      ),);
    var btn =
    FlatButton(onPressed:_qqLog, child: t,
      color: Colors.black,
      shape:RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_btnBorderRadius)),height: btnWidth,padding: EdgeInsets.all(0),);
    return btn;
  }
  Function _qqLog(){
    print("qq");
  }
  Function _weChatLog(){
    print("wechat");
  }
  Function _phoneLog(){
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return PhoneLogPage();
    }));
  }
  Function _appleLog(){
    print("apple");
  }
}

