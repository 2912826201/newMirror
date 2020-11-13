

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/page/Log/LogBasePageState.dart';
import 'package:mirror/page/Log/receive_sms.dart';

class BindingPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _BindingPageState();
  }

}
class _BindingPageState extends LogBasePageState {

  ///发送短信的按钮激活颜色
  Color _sendSmsBtnColor;
  //发送短信按钮未激活颜色
  TextStyle _sendSmsBtnTitleStyle;
  ///主要的文本
  final  _circumstancialState = "应国家网信办《移动互联网应用程序信息服务管理规则定》要求，互联网账号使用需实名认证。请绑定手机号完成注册。";
  final  _mainTitle = "绑定手机号";
  ///主描述样式
  final  _mainTitleStyle  = TextStyle(fontFamily: "PingFangSC",fontSize: 23,
      color: Color.fromRGBO(17, 17, 17, 1),decoration: TextDecoration.none);
  ///副描述的样式
  final  _subTitleStyle = TextStyle(fontFamily: "PingFangSC",fontSize: 14,
      color: Color.fromRGBO(153, 153, 153, 1),decoration: TextDecoration.none);
  ///按钮上的标题样式 默认时
  final  _submitTitleStyle_default = TextStyle(color: Color.fromRGBO(153, 153, 153, 1),
      decoration: TextDecoration.none,fontFamily: "PingFangSC",fontSize: 16);
  ///按钮上的标题样式 选中时
  final  _submitTitleStyle_Hignlited = TextStyle(color:Colors.white ,
      decoration: TextDecoration.none,fontFamily: "PingFangSC",fontSize: 16);
  ///未选中的 发送验证码按钮颜色
  final  _submitColor_default = Color.fromRGBO(235, 235, 235, 1);
  ///发送验证码 选中颜色
  final  _submitColor_hignlited = Color.fromRGBO(17, 17, 17, 1);
  ///输入框的默认文本
  final _textfieldPlaceholder = "请输入手机号";
  ///发送短信按钮的标题
  final _smsButtonTitle = "发送验证码";
  ///输入控制器
  final  inputController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _sendSmsBtnColor = _submitColor_default;
    _sendSmsBtnTitleStyle = _submitTitleStyle_default;
    //输入内容的观察注册
    _inputCheckingRegister();

  }
  ///输入框的文本检测
  _inputCheckingRegister(){
    inputController.addListener(() {
      if (validationJudge()){
      _afterValidateInput();
      }else{
      _recoverUi();
      }
    });
  }
   ///发送短信的函数
    _sendSms()
    {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        print(this.inputController.text);
        return ReceiveSmsPage(phoneNumber:this.inputController.text,);
      }));
    }
    ///满足合法输入之后
   _afterValidateInput(){
    //ui的跟新
    setState(() {
      _sendSmsBtnColor = _submitColor_hignlited;
      _sendSmsBtnTitleStyle = _submitTitleStyle_Hignlited;
    });
   }
   ///不满足合法输入时ui的回退
    _recoverUi(){
    setState(() {
      _sendSmsBtnColor = _submitColor_default;
      _sendSmsBtnTitleStyle = _submitTitleStyle_default;
    });
    }
   ///如何合法性的检测
   bool validationJudge(){
    //FIXME:等待更改
     if (inputController.text.length > 14){return true;}
    return false;
   }
    @override
     Widget build(BuildContext context) {
      return Scaffold(
       body: Container(
        child: InkWell(
          onTap: (){
            FocusScope.of(context).unfocus();
          },
         child:Column(
          children: [
            //导航栏需要和页面上方具有间距
            Container(
              child:navigationBar(),
              margin: EdgeInsets.only(top: 40),
            ),
            _mainBody()
          ],
        ),
      ),
     ),
   );
  }
  ///////////////////////
  /////////
  //页面的主体部分
  Widget _mainBody(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stateMentArea(),
         Column(
           crossAxisAlignment: CrossAxisAlignment.center,
           children: [
            _inputArea(),
            _buttonArea(),
          ],
        )
      ],
    );
  }
    ///声明部分
    Widget _stateMentArea(){
    //文字包为一个整体
    var bag = Padding(padding: EdgeInsets.only(left: 41,right: 41,top: 42.5),
      child:Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //文字的上下间距
        Container(
          child: Text(_mainTitle,
            style: _mainTitleStyle,),
          margin: EdgeInsets.only(bottom: 9),
        ),
        Text(_circumstancialState,
         style: _subTitleStyle,),
      ],) ,
    );
      return bag;
    }
    ///输入部分
    Widget _inputArea(){
     var putfield = TextField(controller: inputController,showCursor: true,decoration: InputDecoration(
         hintText: _textfieldPlaceholder,
         hintStyle:  TextStyle(
             color: Color.fromRGBO(204, 204, 204, 1),
             fontFamily: 'PingFangSC',
             fontSize: 16),
         suffix: Container(
           child: null,
           padding: EdgeInsets.all(0),
           alignment: Alignment.centerRight,
           width: 16,
           height: 16,),
         suffixIconConstraints: BoxConstraints(minWidth: 1,maxHeight: 1),
         isDense: true,
         focusedBorder: UnderlineInputBorder(
           borderSide: BorderSide(
               color: Color.fromRGBO(243, 243, 243, 1),
               width: 0.5
           ),
         ),
       enabledBorder: UnderlineInputBorder(
         borderSide: BorderSide(
             color: Color.fromRGBO(243, 243, 243, 1),
             width: 0.5
         ),
     ),)
     );
    return Container(
      child: putfield,
      margin: EdgeInsets.only(top: 38,bottom: 32,left: 41,right: 41),
    );
    }
    ///按钮部分
    Widget _buttonArea(){
      var  btnStyle = RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3));
      var smsBtn = FlatButton(
        minWidth: 293,
        height: 44,
        shape: btnStyle,
        onPressed: _sendSms,
        child: Text(_smsButtonTitle,
          style: _sendSmsBtnTitleStyle),
        color: _sendSmsBtnColor,);
      var returns = Container(child: smsBtn,);
      return returns;
    }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
}





