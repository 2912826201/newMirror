import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mirror/api/basic_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/page/login/sms_code_page.dart';
import 'package:mirror/util/string_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/custom_appbar.dart';

class PhoneLoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _PhoneLoginPageState();
  }
}

class _PhoneLoginPageState extends State<PhoneLoginPage> {
  //本页面的一些常量及文本
  String _titleOfSendTextBtn;

  final _conspicousGreeting = "Hello";
  final _stringOfSubtitle = "此刻开始分享你的健身生活和经验吧~";
  final _placeholderOfInputField = "请输入你的手机号";
  final _sendingTitle = "发送中";
  final _loggingTitle = "登录中";
  final _sendSmsInitialtitle = "发送验证码";
  final _sendFaildTitle = "发送失败";
  final _resendTitle = "重新发送";

  //
  //"高亮"时的按钮颜色
  final _sendSmsHighLightedColor = Color.fromRGBO(17, 17, 17, 1);

  //默认的按钮的颜色
  final _sendSmsOriginColor = Color.fromRGBO(235, 235, 235, 1);

  /////////////////////////////
  //默认的标题颜色
  final _sendSmsOriginTitleColor = Color.fromRGBO(153, 153, 153, 1);

  //"高亮"时的标题颜色
  final _sendSmsHighLightedTitleColor = Colors.white;
  var _smsBtnTitleColor;

  var _smsBtnColor;
  var _textField;

  //输入框控制器
  final TextEditingController inputController = TextEditingController();

  /////
  //初始化状态
  @override
  void initState() {
    super.initState();
    _titleOfSendTextBtn = _sendSmsInitialtitle;
    _smsBtnTitleColor = _sendSmsOriginTitleColor;
    _smsBtnColor = _sendSmsOriginColor;
    //对输入框的文本进行监听
    inputController.addListener(() {
      if (_validationJudge() == true) {
        _everythingReady();
      } else {
        _recoverUi();
      }
    });
  }

  //UI复位
  _recoverUi() {
    if (this.mounted) {
      setState(() {
        _smsBtnColor = _sendSmsOriginColor;
        _smsBtnTitleColor = _sendSmsOriginTitleColor;
      });
    }
  }

  //可发送短信的条件判断
  bool _validationJudge() {
    if (StringUtil.matchPhoneNumber(inputController.text) == true) {
      print('================可以发送');
      return true;
    }
    print('================不可以发送');
    return false;
  }

  //条件满足时的需要做的事情
  _everythingReady() {
    if (this.mounted) {
      setState(() {
        _smsBtnColor = _sendSmsHighLightedColor;
        _smsBtnTitleColor = _sendSmsHighLightedTitleColor;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(hasDivider: false,),
        body: InkWell(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Container(
        padding: EdgeInsets.only(top: 40),
        color: Colors.white,
        child: Container(
          margin: const EdgeInsets.only(top: 42.5),
          //整体居中
          child: Center(
              child: Padding(
            padding: EdgeInsets.only(left: 41, right: 41),
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
          )),
        ),
      ),
    ));
  }

  //判断是否重新进入发送验证码的界面
  bool _reEnterSendSmsPage() {
    int currentTime = DateTime.now().millisecondsSinceEpoch;
    int lastTime = Application.smsCodeSendTime;
    lastTime ??= currentTime - 60 * 1000;
    //是否是重入发送验证码的情况
    if ((currentTime - lastTime) < 60 * 1000) {
      print("reEnter SmsPage true");
      return true;
    }
    print("reEnter SmsPage false");
    return false;
  }

  //发送验证码的函数
  _sendMessage() async {
    //如果是发送验证码可以重入的情况，则重新进入，此时不会触发相应的接口
    if (_reEnterSendSmsPage() == true) {
      String applicationPhone = Application.sendSmsPhoneNum;
      applicationPhone ??= this.inputController.text;
      //手机号前后对不上
      if (applicationPhone != this.inputController.text) {
        print("手机号前后对不上，无法发送验证码！");
        ToastShow.show(msg: "发送频繁，请稍候重试。", context: context);
        return;
      }
      print("发送验证码页面重入");
      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return SmsCodePage(
          phoneNumber: inputController.text,
          isSent: true,
        );
      }));
      return;
    }
    //下方是非重入验证码页面的情况，需要触发相应的接口
    if (this.mounted) {
      setState(() {
        _titleOfSendTextBtn = _sendingTitle;
      });
    }
    bool result = false;
    result = await sendSms(inputController.text, 0);
    // if (this.mounted) {
    //   setState(() {
    //     _titleOfSendTextBtn = _loggingTitle;
    //   });
    // }
    if (result) {
      print("发送验证码成功");
      _titleOfSendTextBtn = "发送";
      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return SmsCodePage(
          phoneNumber: inputController.text,
          isSent: true,
        );
      }));
    } else {
      if (this.mounted) {
        setState(() {
          _titleOfSendTextBtn = _sendFaildTitle;
        });
      }
      Timer.periodic(Duration(seconds: 1), (timer) {
        if (this.mounted) {
          setState(() {
            _titleOfSendTextBtn = _resendTitle;
          });
        }
      });
      print("发送验证码失败");
    }
  }


  Widget _sloganArea() {
    var hellotext = Text(
      _conspicousGreeting,
      style: TextStyle(fontFamily: 'PingFangSC', fontSize: 23, color: Colors.black, decoration: TextDecoration.none),
    );
    var subtext = Text(
      _stringOfSubtitle,
      style: TextStyle(
          fontFamily: "PingFangSC",
          color: Color.fromRGBO(153, 153, 153, 1),
          fontSize: 14,
          decoration: TextDecoration.none),
    );
    var area1 = Container(
      child: hellotext,
      margin: const EdgeInsets.only(bottom: 9),
    );
    var area2 = Container(
      child: subtext,
    );
    var column = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [area1, area2],
    );
    var returndeValue = Container(child: column);
    return returndeValue;
  }

  //一键清除输入框
  _clearAllText() {
    inputController.text = "";
    if (this.mounted) {
      setState(() {
        inputController.text = "";
      });
    }
  }

  Widget _inputFields() {
    Icon deleteIcon = Icon(Icons.cancel, color: Color.fromRGBO(220, 221, 224, 1));
    // var btn = IconButton(icon: deleteIcon, onPressed: _clearAllText,iconSize: 24,color: Colors.green,);
    var clearBtn = FlatButton(
      onPressed: _clearAllText,
      child: SizedBox(
        child: deleteIcon,
        width: 16,
        height: 16,
      ),
      padding: EdgeInsets.only(right: 4, bottom: 3),
      minWidth: 16,
      height: 16,
    );
    var palceholderTextStyle =
        TextStyle(color: Color.fromRGBO(204, 204, 204, 1), fontFamily: 'PingFangSC', fontSize: 16);
    //输入框的样式
    var inputFieldDecoration = InputDecoration(
        counterText: "",
        // 不显示计数文字
        hintText: _placeholderOfInputField,
        hintStyle: palceholderTextStyle,
        suffix: Container(
          child: clearBtn,
          padding: EdgeInsets.all(0),
          alignment: Alignment.centerRight,
          width: 16,
          height: 16,
        ),
        suffixIconConstraints: BoxConstraints(minWidth: 1, maxHeight: 1),
        isDense: true,
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColor.bgWhite, width: 0.5),
        ),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(width: 0.5, color: AppColor.bgWhite)),);
    if (_textField == null) {
      _textField = TextField(
        maxLength: 11,
        controller: inputController,
        keyboardType: TextInputType.phone,
        autofocus: true,
        decoration: inputFieldDecoration,
      );
    }
    var encapsulateBoxArea = Container(
      child: _textField,
      margin: const EdgeInsets.only(top: 38, bottom: 32),
      width: 292.75,
      height: 44,
    );
    return encapsulateBoxArea;
  }

  Widget _certificateBtn() {
    var btnStyle = RoundedRectangleBorder(borderRadius: BorderRadius.circular(3));
    var smsBtn = FlatButton(
      minWidth: 293,
      height: 44,
      shape: btnStyle,
      onPressed:(){
        if(_validationJudge()||_reEnterSendSmsPage()){
          _sendMessage();
        }else{
       ToastShow.show(msg:"请输入正确的手机号", context: context);
          return false;
        }

      },
      child: Text(
        _titleOfSendTextBtn,
        style: TextStyle(fontFamily: "PingFangSC", fontSize: 16, color: _smsBtnTitleColor),
      ),
      color: _smsBtnColor,
    );
    var returns = Container(
      child: smsBtn,
    );
    return returns;
  }
}
