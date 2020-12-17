import 'dart:async';
import 'dart:math';

import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mirror/api/user_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/database/profile_db_helper.dart';
import 'package:mirror/data/database/token_db_helper.dart';
import 'package:mirror/data/dto/profile_dto.dart';
import 'package:mirror/data/dto/token_dto.dart';
import 'package:mirror/data/model/user_model.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:mirror/data/notifier/token_notifier.dart';
import 'package:mirror/page/message/delegate/callbacks.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/page/login/perfect_user_page.dart';
import 'package:provider/provider.dart';
import 'package:mirror/api/basic_api.dart';
import 'package:mirror/data/model/token_model.dart';

import 'login_base_page_state.dart';


final _maxCodeLength = 4;
///////////////////////////////////////////////////////////////////
//////////////////////////倒计时填写验证码页面/////////////////////////
class SmsCodePage extends StatefulWidget {

  final String phoneNumber;
  SmsCodePage({@required this.phoneNumber, Key key,sended:bool}) :this.sended = sended,super(key: key);
  bool sended ;
  @override
  State<StatefulWidget> createState() {
    return _SmsCodePageState(phoneNumber: phoneNumber,sended: this.sended);
  }
}

class _SmsCodePageState extends LoginBasePageState {
  final inputController = TextEditingController();
  final _titleOfSendTextBtn = "验证";
  final String phoneNumber;
  final String _textFieldPlaceholder = "输入验证码";
  //验证按钮的宽度
  final double certificateBtnWidth = 293.0;
  //验证按钮的高度
  final double certificateBtnHeight = 44;
  //"高亮"时的按钮颜色
  final _sendSmsHighLightedColor = AppColor.textPrimary1;
  //"高亮"时的标题颜色
  final _sendSmsHighLightedTitleColor = AppColor.white;
  var _smsBtnTitleColor;
  var _smsBtnColor;
  //是否一定调取后端发送了短信
  bool sended;
  //默认的按钮的颜色
  final _sendSmsOriginColor = AppColor.textPrimary1.withOpacity(0.06) ;
  //默认的标题颜色
  final _sendSmsOriginTitleColor = AppColor.textSecondary;
  bool _sendSmsValid = false;
  final _backImage = "images/test/cross.png";

  @override
  void initState() {
    //进行记录手机号
    Application.sendSmsPhoneNum = this.phoneNumber;
    backBtnImage = _backImage;
    _smsBtnTitleColor = _sendSmsOriginTitleColor;
    _smsBtnColor = _sendSmsOriginColor;
    super.initState();
    //对输入框的文本进行监听
    inputController.addListener(() {
      if (_validationJudge() == true) {
        _everythingReady();
      } else {
        _recoverUi();
      }
    });
  }

  //ui状态的恢复
  _recoverUi() {
    setState(() {
      _smsBtnColor = _sendSmsOriginColor;
      _smsBtnTitleColor = _sendSmsOriginTitleColor;
    });
  }

  //一切就绪之后
  _everythingReady() {
    _sendSmsValid = true;
    setState(() {
      print("ready to send sms text");
      _smsBtnColor = _sendSmsHighLightedColor;
      _smsBtnTitleColor = _sendSmsHighLightedTitleColor;
    });
  }

  //输入合法性的判断
  bool _validationJudge() {
    if ((inputController.text.length == _maxCodeLength) && (sended == true)) {
      return true;
    }
    return false;
  }

  ////////
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(top: 40),
        color: Colors.white,
        child: InkWell(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Column(
              children: [
                navigationBar(),
                //去除导航栏以外的地方
                Container(
                  margin:const EdgeInsets.only(top: 42.5),
                  //整体居中
                  child: Center(
                      child: Padding(
                        padding: EdgeInsets.only(left: 41, right: 41),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _statementArea(),
                            //文本和下方的输入框等小胡控件需要分开布局，因为文本的显示效果比较灵活
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                //输入框
                                _inputArea(),
                                //发送按钮区域
                                _submitArea()
                              ],
                            ),
                          ],
                        ),
                      )),
                )
              ],
            )),
      ),
    );
  }

  _SmsCodePageState({@required this.phoneNumber,@required this.sended});

  ///说明区域
  Widget _statementArea() {
    var mainTitle = Text(
      "输入验证码",
      style: TextStyle(fontFamily: 'PingFangSC', fontSize: 23, color: Colors.black, decoration: TextDecoration.none),
    );
    var prefixString = phoneNumber.substring(0, 3);
    var suffixString = phoneNumber.substring(phoneNumber.length - 5);
    var stars = "****";
    var subTitle = Text(
      "短信验证码已发送至 +86 " + prefixString + stars + suffixString,
      style: TextStyle(
          fontFamily: "PingFangSC",
          color: Color.fromRGBO(153, 153, 153, 1),
          fontSize: 14,
          decoration: TextDecoration.none),
    );
    var area1 = Container(
      child: mainTitle,
      margin:const EdgeInsets.only(bottom: 9),
    );
    var area2 = Container(
      child: subTitle,
    );
    var column = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [area1, area2],
    );
    var returndeValue = Container(child: column);
    return returndeValue;
  }

  ///输入区域
  Widget _inputArea() {
    var putfield = TextField(
      maxLength: _maxCodeLength,
      controller: inputController,
      keyboardType: TextInputType.number,
      showCursor: true,
      decoration: InputDecoration(
          counterText: "",
          //不显示字数计数文字
          hintText: _textFieldPlaceholder,
          hintStyle: TextStyle(color: Color.fromRGBO(204, 204, 204, 1), fontFamily: 'PingFangSC', fontSize: 16),
          suffixIcon: SmsCounterWidget(seconds: 60,requestTask:_smsSendApi, sended: sended,),
          suffixIconConstraints: BoxConstraints(minWidth: 70, maxHeight: 24.5),
          isDense: true,
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color.fromRGBO(196, 196, 196, 1), width: 0.5),
          )),
    );
    return Container(
        child: putfield,
        margin:const EdgeInsets.only(
          top: 38,
          bottom: 32,
        ));
  }

  _smsSendApi() async {
    bool result = await sendSms(phoneNumber, 0);
    if (result == true) {
      print("验证码已发送~");
      //跟新发送sms发送的时间
      Application.smsCodeSendTime = DateTime.now().millisecondsSinceEpoch;
      sended = true;
    } else {
      //失败页也暂时进行发送的时间记录
      Application.smsCodeSendTime = DateTime.now().millisecondsSinceEpoch;
      print("验证码发送失败");
    }
  }

  ///提交区域
  Widget _submitArea() {
    var btnStyle = RoundedRectangleBorder(borderRadius: BorderRadius.circular(3));
    var smsBtn = FlatButton(
      //FIXME 293这个数字哪来的
      minWidth: certificateBtnWidth,
      height: certificateBtnHeight,
      shape: btnStyle,
      //FIXME 没有做输入长度校验
      onPressed: _loginWithPhoneCode,
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

  // 验证验证码登录
  _loginWithPhoneCode() async {
    SmsCodePage phoneNumPage = widget;
    TokenModel token = await login("sms", phoneNumPage.phoneNumber, inputController.text, null);
    if (token != null) {
      print("登录成功");
      if (token.anonymous == 1 || token.uid == null) {
        //如果token是匿名的或者没有uid则token出了问题
        print("token错误");
      } else if (token.isPhone == 0) {
        print("没有绑定手机");
        Application.tempToken = token;
      } else if (token.isPerfect == 0) {
        print("没有完善资料");
        Application.tempToken = token;
        //FIXME 这里要去完善资料页 先写个请求完善资料接口的示例
        AppRouter.navigateToPerfectUserPage(context);
      } else {
        //所有都齐全的情况 登录完成
        await _afterLogin(token);
      }
    } else {
      print("登录失败");
    }
  }

  //TODO 完整的用户的处理方法 这个方法在登录页 绑定手机号页 完善资料页都会用到 需要单独提出来
  _afterLogin(TokenModel token) async{
    TokenDto tokenDto = TokenDto.fromTokenModel(token);
    await TokenDBHelper().insertToken(tokenDto);
    context.read<TokenNotifier>().setToken(tokenDto);
    //然后要去取一次个人用户信息
    UserModel user = await getUserInfo();
    ProfileDto profile = ProfileDto.fromUserModel(user);
    await ProfileDBHelper().insertProfile(profile);
    context.read<ProfileNotifier>().setProfile(profile);
    //TODO 页面跳转需要处理
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/', (route) => false,
      //true 保留当前栈 false 销毁所有 只留下RepeatLogin
      arguments: {},
    );
  }
}

class SmsCounterWidget extends StatefulWidget {

  final VoidCallback requestTask;
  final int seconds;
  var sended;

  SmsCounterWidget({this.seconds, this.requestTask, bool sended, Key key})
      : assert(seconds != null),
        this.sended = sended,
        super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SmsCounterWidgetState(requestTask, seconds: seconds);
  }
}

//倒计时按钮
class _SmsCounterWidgetState extends State<SmsCounterWidget> {
  final MPCallbackWithValueNoPara _requestTask;
  ///初始状态常量
  final _resendText = Text(
    "重新获取",
    style: TextStyle(
        color: Color.fromRGBO(17, 17, 17, 1), fontFamily: "PingFangSC", fontSize: 13, decoration: TextDecoration.none),
  );

  final BoxDecoration _initialBorderStyle = BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(3)),
      border: Border.all(width: 1, color: Color.fromRGBO(17, 17, 17, 1)));
  final _resendWidth = 70.0;
  final _resendHeight = 24.5;
  final _countingWidth = 40.0;
  final _countingHeight = 24.5;

  ///、、、、、、、、、、、、激活状态的常量
  final BoxDecoration _activatingBorderStyle = BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(3)),
      border: Border.all(width: 1, color: Color.fromRGBO(204, 204, 204, 1)));

  ///************************************
  ///是否已经发送了短信,初始即开始计时
  bool _uiForCounting = true;
  var contentRefer;
  ///计时器
  static Timer _timer ;
  int _storedSeconds;

  /// 按钮上的倒计时改变的文字
  Text _countText() {
    return Text(
      '${_getTimeGap()}S',
      style: TextStyle(
          color: Color.fromRGBO(204, 204, 204, 1),
          fontSize: 13,
          fontFamily: "PingFangSC",
          decoration: TextDecoration.none),
    );
  }
  //时间差值
  int _getTimeGap(){
    int previousTime = Application.smsCodeSendTime;
    int currentTime = DateTime.now().millisecondsSinceEpoch;
    //第一次
    if(previousTime == null){
      previousTime = currentTime ;
      Application.smsCodeSendTime = previousTime;
    }
    int deviation = (currentTime - previousTime);
    //此处用于解决点击"重新发送"按钮时，计数瞬间显示出现负数的情况
    if(60.0 - (deviation/1000.0)<0){ print("gap below zero"); return 59;}
    return  (60.0 - (deviation/1000.0)).toInt();
  }

  _SmsCounterWidgetState(this._requestTask, {int seconds}) : _storedSeconds = seconds;

  @override
  void initState() {
    _concatenateConstants();
    _initialReservations();
    super.initState();
  }

  ///////////////////////
  //"重新发送"样式按钮
  Widget _creatResendWidget() {
    return Container(
      child: FlatButton(
        child: _resendText,
        onPressed: (){ _sendSmsOperations();},
        padding: EdgeInsets.all(0),
      ),
      decoration: _initialBorderStyle,
      width: _resendWidth,
      height: _resendHeight,
    );
  }

  //倒计时按钮
  Widget _creatCountingWidget() {
    return Container(
      child: FlatButton(
        child: _countText(),
        onPressed: null,
        padding: EdgeInsets.all(0),
      ),
      decoration: _activatingBorderStyle,
      width: _countingWidth,
      height: _countingHeight,
    );
  }

  void _initialReservations() {
    print("initialReservations");
    _storedSeconds ??= 60;
    /// 激活计时器
    _activateTimer();
  }

  ///初始状态的常量引用设定
  void _concatenateConstants() {}

  ///////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    return Container(
      child: _getContent(),
    );
  }

  Widget _getContent() {
    if (_uiForCounting == true) {
      return _creatCountingWidget();
    }
    return _creatResendWidget();
  }

  ///发送短信的操作集合(点击重新发送也走这里)
  _sendSmsOperations()  async{
    setState(() {
      _uiForCounting = true;
    });
    //请求接口
   bool result = await _correspRequest();
   if(result == true){
     //后台返回结果表示已经发送了短信则置此变量为true，允许发送按钮的ui能进行对应的变化以表示
     //能够进行验证
     widget.sended = true;
   }else{
     widget.sended = false;
   }
    //调取接口前的一些准备
    _reSendSmsPreparation();
  }

  ///发送短信的本地准备
  _reSendSmsPreparation() {
    _activateTimer();
  }

  ///激活计时器
  _activateTimer() {
       print("activating time");
       print("Appliation smsCodeTime is ${_getTimeGap()}");
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        int timeGap = _getTimeGap();
        if (timeGap < 60*1000&&timeGap>0) {
         setState(() {
         });
        } else {
          print("stop counting");
          setState(() {
            _timer.cancel();
            _resetUI();
          });
        }
      });



  }

  ///重置UI，但是没有调用setState()
  _resetUI() {
    print("resetUi");
    _uiForCounting = false;
    this.widget.sended = false;
  }

  ///调取接口
  Future<bool> _correspRequest() async{
  return await _requestTask();
  }

  @override
  void dispose() {
    _timer.cancel();
    _timer =null;
    super.dispose();
  }
}

