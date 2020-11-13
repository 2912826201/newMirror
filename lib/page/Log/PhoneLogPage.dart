import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'file:///Users/imac/Desktop/flut/mirror/lib/page/Log/LogBasePageState.dart';
import 'file:///Users/imac/Desktop/flut/mirror/lib/page/Log/binding_page.dart';

class PhoneLogPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _PhoneLogPage();
  }

}
class _PhoneLogPage extends  LogBasePageState{
  //
  bool _sendSmsValid = false;
  //本页面的一些常量及文本
  final _titleOfSendTextBtn = "发送验证码";
  final _conspicousGreeting = "Hello";
  final _stringOfSubtitle = "此刻开始分享你的健身生活和经验吧~";
  final _placeholderOfInputField = "请输入你的手机号";
  //
 //"高亮"时的按钮颜色
  final _sendSmsHighLightedColor =  Color.fromRGBO(17, 17, 17, 1);
  //默认的按钮的颜色
  final _sendSmsOriginColor  = Color.fromRGBO(235, 235, 235, 1);
  /////////////////////////////
  //默认的标题颜色
  final _sendSmsOriginTitleColor = Color.fromRGBO(153, 153, 153, 1);
  //"高亮"时的标题颜色
  final _sendSmsHighLightedTitleColor = Colors.white;
  var _smsBtnTitleColor ;
  var _smsBtnColor;
  var _textField;
  //输入框控制器
 final TextEditingController  inputController = TextEditingController();
  /////
  //初始化状态
  @override
  void initState() {
    super.initState();
    _smsBtnTitleColor = _sendSmsOriginTitleColor;
    _smsBtnColor = _sendSmsOriginColor;
    //对输入框的文本进行监听
    inputController.addListener(() {
     if (_validationJudge()==true){
       _everythingReady();
     }else{
       _recoverUi();
     }
    });
  }
  //UI复位
  _recoverUi(){
    setState(() {
      _smsBtnColor = _sendSmsOriginColor;
      _smsBtnTitleColor = _sendSmsOriginTitleColor;
    });

  }
  //可发送短信的条件判断
  bool _validationJudge(){
    if (inputController.text.length >= 9){
     return true;
    }
    return false;
  }
  //条件满足时的需要做的事情
  Function _everythingReady(){
    _sendSmsValid = true;
    setState(() {
       _smsBtnColor = _sendSmsHighLightedColor;
      _smsBtnTitleColor = _sendSmsHighLightedTitleColor; 
    });

  }
  @override
  Widget build(BuildContext context) {
   return Scaffold(
     body:InkWell(
       onTap: (){
         FocusScope.of(context).unfocus();
       },
       child:  Container(
           padding: EdgeInsets.only(top: 40),
           color: Colors.white,
           child: Column(
             children: [
               navigationBar(),
               //去除导航栏以外的地方
               Container(
                 margin: EdgeInsets.only(top: 42.5),
                 //整体居中
                 child:Center(
                     child: Padding(
                       padding: EdgeInsets.only(left: 41,right: 41),
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           _sloganArea(),
                           //文本和下方的输入框等小胡控件需要分开布局，因为文本的显示效果比较灵活
                           Column(
                             crossAxisAlignment: CrossAxisAlignment.center,
                             children: [
                               //输入框
                               _inputFields(),
                               //发送按钮区域
                               _certificateBtn()
                             ],
                           ),
                         ],
                       ),
                     )
                 ) ,)
             ],)
       ),
     )
   );
  }
  //返回函数
  @override
  reverseAction() {
   super.reverseAction();
  }
  //发送验证码的函数
  void _sendMessage(){
    if(_sendSmsValid == false){

    }else{
      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return BindingPage();
      }));
    }
  }
  // Widget _navigationBar(){
  // var leftbackBtn;
  // leftbackBtn = SizedBox(child: backButton,height: 28,width: 28,);
  // var bag = Row(children: [leftbackBtn],);
  // return Container(child: bag,height: 48,
  //   padding: EdgeInsets.only(left: 16,top: 10,bottom: 10),);
  // }
  Widget _sloganArea(){
   var hellotext = Text(_conspicousGreeting,
     style: TextStyle(
         fontFamily: 'PingFangSC',
         fontSize: 23,
         color: Colors.black,
         decoration: TextDecoration.none),);
   var subtext = Text(_stringOfSubtitle,
     style: TextStyle(
         fontFamily: "PingFangSC",
         color: Color.fromRGBO(153, 153, 153, 1),
         fontSize: 14,
         decoration: TextDecoration.none),);
   var area1 = Container(child: hellotext,
     margin: EdgeInsets.only(bottom: 9),);
   var area2 = Container(child: subtext,);
   var column = Column(
   crossAxisAlignment: CrossAxisAlignment.start,
   children: [
     area1,area2
   ],);
   var returndeValue = Container(child: column);
   return returndeValue;
  }
  //一键清除输入框
  Function _clearAllText(){
    inputController.text = "";
    setState(() {
      inputController.text = "";
    });
  }
  Widget _inputFields(){
     Icon deleteIcon =  Icon(Icons.cancel,color: Color.fromRGBO(220, 221, 224, 1));
     // var btn = IconButton(icon: deleteIcon, onPressed: _clearAllText,iconSize: 24,color: Colors.green,);
     var clearBtn = FlatButton(
       onPressed: _clearAllText,
       child: SizedBox(child: deleteIcon,width: 16,height: 16,),
       padding: EdgeInsets.only(right: 4,bottom: 3),
       minWidth: 16,
       height: 16,
     );
     var palceholderTextStyle = TextStyle(
         color: Color.fromRGBO(204, 204, 204, 1),
         fontFamily: 'PingFangSC',
         fontSize: 16);
     //输入框的样式
     var inputfieldDecoration = InputDecoration(
         hintText: _placeholderOfInputField,
         hintStyle: palceholderTextStyle,
         suffix: Container(
           child: clearBtn,
           padding: EdgeInsets.all(0),
           alignment: Alignment.centerRight,
           width: 16,
          height: 16,),
         suffixIconConstraints: BoxConstraints(minWidth: 1,maxHeight: 1),
         isDense: true,
         focusedBorder: UnderlineInputBorder(
             borderSide: BorderSide(
                 color: Color.fromRGBO(196, 196, 196, 1),
                 width: 0.5
             ),

         )
         );
     if (_textField == null){
     _textField = TextField(
       controller: inputController,
       autofocus: true,
       decoration: inputfieldDecoration,);
     }
     var encapsulateBoxArea  = Container(
       child: _textField,
       margin: EdgeInsets.only(top: 38,bottom: 32),
       width: 292.75,
       height: 44,);
     return encapsulateBoxArea;
  }
  Widget _certificateBtn(){
    var  btnStyle = RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(3));
    var smsBtn = FlatButton(
      minWidth: 293,
      height: 44,
      shape: btnStyle,
      onPressed: _sendMessage,
      child: Text(_titleOfSendTextBtn,
        style: TextStyle(
            fontFamily: "PingFangSC",
            fontSize: 16,
            color: _smsBtnTitleColor),),
      color: _smsBtnColor,);
    var returns = Container(child: smsBtn,);
    return returns;
  }
}