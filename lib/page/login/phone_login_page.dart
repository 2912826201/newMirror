import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mirror/api/basic_api.dart';
import 'package:mirror/config/runtime_properties.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/base_response_model.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/string_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/icon.dart';

class PhoneLoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _PhoneLoginPageState();
  }
}

class _PhoneLoginPageState extends State<PhoneLoginPage> {
  //本页面的一些常量及文本
  String _titleOfSendTextBtn;

  final _conspicousGreeting = "Hello~";
  final _stringOfSubtitle = "此刻开始分享你的健身生活和经验吧~";
  final _placeholderOfInputField = "请输入你的手机号";
  final _sendingTitle = "发送中";
  final _sendSmsInitialtitle = "获取验证码";
  final _resendTitle = "重新发送";

  //
  //"高亮"时的按钮颜色
  final _sendSmsHighLightedColor = AppColor.mainYellow;

  //默认的按钮的颜色
  final _sendSmsOriginColor = AppColor.mainYellow.withOpacity(0.4);

  /////////////////////////////
  var _smsBtnColor;
  var _textField;

  bool sendMsging = false;

  //输入框控制器
  final TextEditingController inputController = TextEditingController();

  /////
  //初始化状态
  @override
  void initState() {
    super.initState();
    _titleOfSendTextBtn = _sendSmsInitialtitle;
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
    setState(() {
      _smsBtnColor = _sendSmsOriginColor;
    });
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
    setState(() {
      _smsBtnColor = _sendSmsHighLightedColor;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.mainBlack,
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(
        hasDivider: false,
      ),
      body: InkWell(
        highlightColor: AppColor.transparent,
        splashColor: AppColor.transparent,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
          padding: EdgeInsets.only(top: 40),
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
              ),
            ),
          ),
        ),
      ),
    );
  }

  //判断是否重新进入发送验证码的界面
  bool _reEnterSendSmsPage() {
    int currentTime = DateTime.now().millisecondsSinceEpoch;
    int lastTime = RuntimeProperties.smsCodeSendTime;
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
    if (_reEnterSendSmsPage() && RuntimeProperties.sendSmsPhoneNum == this.inputController.text) {
      print("发送验证码页面重入");
      setState(() {
        sendMsging = false;
      });
      AppRouter.navigateToSmsCodePage(context, inputController.text, true);
    }
    //下方是非重入验证码页面的情况，需要触发相应的接口
    if (this.mounted) {
      setState(() {
        _titleOfSendTextBtn = _sendingTitle;
      });
    }
    BaseResponseModel responseModel = await sendSms(inputController.text, 0);
    if (responseModel != null && responseModel.code == 200) {
      print("发送验证码成功");
      ToastShow.show(msg: "验证码发送成功！", context: context);
      _titleOfSendTextBtn = "发送";
      RuntimeProperties.smsCodeSendTime = DateTime.now().millisecondsSinceEpoch;
      AppRouter.navigateToSmsCodePage(context, inputController.text, true);
    } else {
      ToastShow.show(msg: "验证码发送失败，请重试", context: context);
      _titleOfSendTextBtn = _resendTitle;
      print("发送验证码失败");
    }
    sendMsging = false;
    setState(() {});
  }

  Widget _sloganArea() {
    var hellotext = Text(
      _conspicousGreeting,
      style:AppStyle.whiteMedium23,
    );
    var subtext = Text(
      _stringOfSubtitle,
      style:AppStyle.text1Regular14,
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
    if (inputController.text.isNotEmpty) {
      setState(() {
        inputController.text = "";
      });
    }
  }

  Widget _inputFields() {
    //输入框的样式
    var inputFieldDecoration = InputDecoration(
      counterText: "",
      // 不显示计数文字
      hintText: _placeholderOfInputField,
      hintStyle: AppStyle.text1Regular16,
      isDense: true,
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: AppColor.white.withOpacity(0.24), width: 0.5),
      ),
      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(width: 0.5, color: AppColor.white.withOpacity(0.24))),
    );
    if (_textField == null) {
      _textField = TextField(
        maxLength: 11,
        cursorColor: AppColor.white,
        controller: inputController,
        keyboardType: TextInputType.phone,
        autofocus: true,
        style: AppStyle.whiteRegular16,
        decoration: inputFieldDecoration,
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'\d+'))],
      );
    }
    var encapsulateBoxArea = Container(
      child: Stack(
        children: [
          _textField,
          Positioned(
            right: 0,
            child: inputController.text.isEmpty
                ? Container()
                : Container(
                    height: 44,
                    alignment: Alignment.center,
                    child: AppIconButton(
                      svgName: AppIcon.clear_circle_grey,
                      iconSize: 16,
                      bgColor: AppColor.mainBlack,
                      onTap: _clearAllText,
                    ),
                  ),
          ),
        ],
      ),
      margin: const EdgeInsets.only(top: 38, bottom: 32),
      height: 44,
    );
    return encapsulateBoxArea;
  }

  Widget _certificateBtn() {
    var smsBtn = InkWell(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
        if(sendMsging){
          return false;
        }
        if (_validationJudge()) {
          setState(() {
            sendMsging = true;
          });
          _sendMessage();
        } else {
          ToastShow.show(msg: "请输入正确的手机号", context: context);
          return false;
        }
      },
      child: Container(
          width: ScreenUtil.instance.screenWidthDp,
          height: 44,
          decoration: BoxDecoration(
            color: _smsBtnColor,
            borderRadius: BorderRadius.all(Radius.circular(3)),
          ),
          child: Row(
            children: [
              Spacer(),
              sendMsging
                  ? Container(
                      height: 17,
                      width: 17,
                      child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(AppColor.mainBlack),
                          backgroundColor: AppColor.mainBlack.withOpacity(0.16),
                          strokeWidth: 1.5))
                  : Container(),
              SizedBox(
                width: 2.5,
              ),
              Text(
                _titleOfSendTextBtn,
               style: AppStyle.textRegular16,
              ),
              Spacer()
            ],
          )),
    );
    var returns = Container(
      child: smsBtn,
    );
    return returns;
  }
}
