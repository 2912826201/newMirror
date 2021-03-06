import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jpush_flutter/jpush_flutter.dart';
import 'package:mirror/api/api.dart';
import 'package:mirror/api/machine_api.dart';
import 'package:mirror/api/message_api.dart';
import 'package:mirror/api/push_api.dart';
import 'package:mirror/api/topic/topic_api.dart';
import 'package:mirror/api/user_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/config/runtime_properties.dart';
import 'package:mirror/config/shared_preferences.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/database/profile_db_helper.dart';
import 'package:mirror/data/database/token_db_helper.dart';
import 'package:mirror/data/dto/profile_dto.dart';
import 'package:mirror/data/dto/token_dto.dart';
import 'package:mirror/data/model/base_response_model.dart';
import 'package:mirror/data/model/data_response_model.dart';
import 'package:mirror/data/model/machine_model.dart';
import 'package:mirror/data/model/message/no_prompt_uid_model.dart';
import 'package:mirror/data/model/message/top_chat_model.dart';
import 'package:mirror/data/model/topic/topic_background_config.dart';
import 'package:mirror/data/model/user_model.dart';
import 'package:mirror/data/notifier/machine_notifier.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:mirror/data/notifier/token_notifier.dart';
import 'package:mirror/data/notifier/user_interactive_notifier.dart';
import 'package:mirror/im/message_manager.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/event_bus.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/dialog.dart';
import 'package:mirror/widget/icon.dart';
import 'package:provider/provider.dart';
import 'package:mirror/api/basic_api.dart';
import 'package:mirror/data/model/token_model.dart';
import 'package:umeng_common_sdk/umeng_common_sdk.dart';

final _maxCodeLength = 4;

///////////////////////////////////////////////////////////////////
//////////////////////////倒计时填写验证码页面/////////////////////////
class SmsCodePage extends StatefulWidget {
  SmsCodePage({
    @required this.phoneNumber,
    this.isSent,
    Key key,
  }) : super(key: key);

  final String phoneNumber;
  final bool isSent;

  @override
  State<StatefulWidget> createState() {
    return _SmsCodePageState();
  }
}

class _SmsCodePageState extends State<SmsCodePage> {
  final inputController = TextEditingController();
  final _titleOfSendTextBtn = "验证";
  final String _textFieldPlaceholder = "输入验证码";

  //验证按钮的宽度
  final double certificateBtnWidth = 293.0;

  //验证按钮的高度
  final double certificateBtnHeight = 44;

  //"高亮"时的按钮颜色
  final _sendSmsHighLightedColor = AppColor.mainYellow;

  var _smsBtnColor;

  //默认的按钮的颜色
  final _sendSmsOriginColor = AppColor.mainYellow.withOpacity(0.4);
  bool logining = false;
  bool isSent;

  @override
  void initState() {
    isSent = widget.isSent;
    //进行记录手机号
    RuntimeProperties.sendSmsPhoneNum = widget.phoneNumber;
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
    });
  }

  //一切就绪之后
  _everythingReady() {
    setState(() {
      print("ready to send sms text");
      _smsBtnColor = _sendSmsHighLightedColor;
    });
  }

  //输入合法性的判断
  bool _validationJudge() {
    if ((inputController.text.length == _maxCodeLength) && (isSent == true)) {
      return true;
    }
    return false;
  }

  ////////
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.mainBlack,
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(
        leading: CustomAppBarIconButton(
          svgName: AppIcon.nav_close,
          iconColor: AppColor.white,
          onTap: () {
            Navigator.pop(context);
          },
        ),
        hasDivider: false,
      ),
      body: Container(
        padding: EdgeInsets.only(top: 40),
        child: InkWell(
          highlightColor: AppColor.transparent,
          splashColor: AppColor.transparent,
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Container(
            margin: const EdgeInsets.only(top: 42.5),
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
          ),
        ),
      ),
    );
  }

  ///说明区域
  Widget _statementArea() {
    var mainTitle = Text(
      "输入验证码",
      style: AppStyle.whiteMedium23,
    );
    String phoneNumber = widget.phoneNumber.replaceFirst(RegExp(r'\d{4}'), "****", 3);
    var subTitle = Text(
      "短信验证码已发送至 +86 " + phoneNumber,
      style: AppStyle.text1Regular14,
    );
    var area1 = Container(
      child: mainTitle,
      margin: const EdgeInsets.only(bottom: 9),
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
      cursorColor: AppColor.white,
      style: AppStyle.whiteRegular16,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'\d+'))],
      decoration: InputDecoration(
          counterText: "",
          //不显示字数计数文字
          hintText: _textFieldPlaceholder,
          hintStyle: AppStyle.text1Regular16,
          suffixIcon: SmsCounterWidget(
            seconds: 60,
            requestTask: _smsSendApi,
            sended: isSent,
          ),
          suffixIconConstraints: BoxConstraints(minWidth: 70, maxHeight: 24.5),
          isDense: true,
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColor.white.withOpacity(0.24), width: 0.5),
          ),
          enabledBorder:
              UnderlineInputBorder(borderSide: BorderSide(width: 0.5, color: AppColor.white.withOpacity(0.24)))),
    );
    return Container(
        child: putfield,
        margin: const EdgeInsets.only(
          top: 38,
          bottom: 32,
        ));
  }

  _smsSendApi() async {
    BaseResponseModel responseModel = await sendSms(widget.phoneNumber, 0);
    if (responseModel != null && responseModel.code == 200) {
      print("验证码已发送~");
      //跟新发送sms发送的时间
      RuntimeProperties.smsCodeSendTime = DateTime.now().millisecondsSinceEpoch;
      isSent = true;
    } else {
      //失败页也暂时进行发送的时间记录
      RuntimeProperties.smsCodeSendTime = DateTime.now().millisecondsSinceEpoch;
      print("验证码发送失败");
    }
  }

  ///提交区域
  Widget _submitArea() {
    var btnStyle = RoundedRectangleBorder(borderRadius: BorderRadius.circular(3));
    var smsBtn = InkWell(
      onTap: () {
        if (logining) {
          return;
        }
        FocusScope.of(context).requestFocus(FocusNode());
        if (inputController.text.length != 4) {
          ToastShow.show(msg: "请输入正确格式的验证码!", context: context);
        } else {
          setState(() {
            logining = true;
          });
          _loginWithPhoneCode();
        }
      },
      child: Container(
        height: certificateBtnHeight,
        decoration: BoxDecoration(
          color: _smsBtnColor,
          borderRadius: BorderRadius.all(Radius.circular(3)),
        ),
        child: Row(
          children: [
            Spacer(),
            logining
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
        ),
      ),
    );
    var returns = Container(
      child: smsBtn,
    );
    return returns;
  }

  // 验证验证码登录
  _loginWithPhoneCode() async {
    SmsCodePage phoneNumPage = widget;
    BaseResponseModel responseModel = await login("sms", phoneNumPage.phoneNumber, inputController.text, null);
    if (responseModel != null) {
      if (responseModel.code == CODE_SUCCESS) {
        print("登录成功");
        TokenModel token = TokenModel.fromJson(responseModel.data);
        if (token.anonymous == 1 || token.uid == null) {
          //如果token是匿名的或者没有uid则token出了问题
          print("token错误");
        } else if (token.isPhone == 0) {
          print("没有绑定手机");
          Application.tempToken = token;
        } else if (token.isPerfect == 0) {
          print("没有完善资料");
          Application.tempToken = token;

          AppRouter.navigateToPerfectUserPage(context);
        } else {
          //所有都齐全的情况 登录完成
          try {
            await _afterLogin(token);
          } catch (e) {
            print(e);
          }
        }

        EventBus.init().post(registerName: EVENTBUS_LOGIN_SUCCESSFUL);
      } else if (responseModel.code == CODE_USERBAN) {
        showAppDialog(context,
            confirm: AppDialogButton("我知道了", () {
              return true;
            }),
            title: "您的账号被封禁",
            info: "尊敬的用户您好，您的账号由于违反平台规定被封禁。\n" + "封禁时间为“${responseModel.message}”。\n" + "若您对此有疑问，可加入QQ群322292818进行咨询。");
      } else {
        ToastShow.show(msg: responseModel.message, context: context);
      }
    } else {
      ToastShow.show(msg: "登录失败！", context: context);
    }
    setState(() {
      logining = false;
    });
  }

  //TODO 完整的用户的处理方法 这个方法在登录页 绑定手机号页 完善资料页都会用到 需要单独提出来
  _afterLogin(TokenModel token) async {
    TokenDto tokenDto = TokenDto.fromTokenModel(token);
    await TokenDBHelper().insertToken(tokenDto);
    context.read<TokenNotifier>().setToken(tokenDto);
    //然后要去取一次个人用户信息
    UserModel user = await getUserInfo();
    if (user != null) {
      print('((((((((((((((((((((((((((${user.uid}))))))))))))))))))))))))))))))');
      ProfileDto profile = ProfileDto.fromUserModel(user);
      await ProfileDBHelper().insertProfile(profile);
      context.read<ProfileNotifier>().setProfile(profile);
      context.read<UserInteractiveNotifier>().clearProfileUiChangeModel();
      //连接融云
      Application.rongCloud.connect();
      //TODO 处理登录完成后的数据加载
      MessageManager.loadConversationListFromDatabase(context);
      //一些非关键数据获取
      _getMoreInfo();
      //页面跳转至登录前的页面
      // 存在发布失败数据通知homePage获取数据
      if (AppPrefs.getPublishFeedLocalInsertData(
              "${Application.postFailurekey}_${context.read<TokenNotifier>().token.uid}") !=
          null) {
        EventBus.init().post(registerName: EVENTBUS_GET_FAILURE_MODEL);
      }
      // 重新登录替换关注页布局
      EventBus.init().post(msg: true, registerName: AGAIN_LOGIN_REPLACE_LAYOUT);
      EventBus.init().post(registerName: SHOW_IMAGE_DIALOG);
      EventBus.init().post(registerName: AGAIN_LOGIN_REFREASH_USERPAGE);
      // 获取话题详情页背景色
      Application.topicBackgroundConfig.clear();
      DataResponseModel dataResponseModel = await getBackgroundConfig();
      if (dataResponseModel != null && dataResponseModel.list != null) {
        dataResponseModel.list.forEach((v) {
          Application.topicBackgroundConfig.add(TopicBackgroundConfigModel.fromJson(v));
        });
      }
      // 友盟上报登录账号
      UmengCommonSdk.onProfileSignIn("${Application.profile.uid}");
      //上报极光推送RegistrationID
      JPush().getRegistrationID().then((rid) {
        uploadDeviceId(rid);
      });
      AppRouter.popToBeforeLogin(context);
    } else {
      ToastShow.show(msg: "登录失败！", context: context);
      print('------------------用户信息请求失败');
    }
  }

  _getMoreInfo() async {
    //todo 获取登录的机器信息
    try {
      List<MachineModel> machineList = await getMachineStatusInfo();
      if (machineList != null && machineList.isNotEmpty) {
        context.read<MachineNotifier>().setMachine(machineList.first);
      } else {
        context.read<MachineNotifier>().setMachine(null);
      }
    } catch (e) {}
    //todo 获取有哪些消息是置顶的消息
    try {
      MessageManager.topChatModelList.clear();
      Map<String, dynamic> topChatModelMap = await getTopChatList();
      if (topChatModelMap != null && topChatModelMap["list"] != null) {
        topChatModelMap["list"].forEach((v) {
          MessageManager.topChatModelList.add(TopChatModel.fromJson(v));
        });
      }
    } catch (e) {}
    //todo 获取有哪些消息是免打扰的消息
    try {
      MessageManager.queryNoPromptUidList.clear();
      Map<String, dynamic> queryNoPromptUidListMap = await queryNoPromptUidList();
      if (queryNoPromptUidListMap != null && queryNoPromptUidListMap["list"] != null) {
        queryNoPromptUidListMap["list"].forEach((v) {
          MessageManager.queryNoPromptUidList.add(NoPromptUidModel.fromJson(v));
        });
      }
    } catch (e) {}
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
  final dynamic Function() _requestTask;

  ///初始状态常量
  final _resendText = Text(
    "重新获取",
    style: AppStyle.text1Regular13,
  );

  final BoxDecoration _initialBorderStyle = BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(3)), border: Border.all(width: 1, color: AppColor.textWhite60));
  final _resendWidth = 70.0;
  final _resendHeight = 24.5;
  final _countingWidth = 40.0;
  final _countingHeight = 24.5;

  ///、、、、、、、、、、、、激活状态的常量
  final BoxDecoration _activatingBorderStyle = BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(3)), border: Border.all(width: 1, color: AppColor.textWhite60));

  ///************************************
  ///是否已经发送了短信,初始即开始计时
  bool _uiForCounting = true;
  var contentRefer;

  ///计时器
  static Timer _timer;

  int _storedSeconds;

  /// 按钮上的倒计时改变的文字
  Text _countText() {
    return Text(
      '${_getTimeGap()}s',
      style: AppStyle.text1Regular13,
    );
  }

  //时间差值
  int _getTimeGap() {
    int previousTime = RuntimeProperties.smsCodeSendTime;
    int currentTime = DateTime.now().millisecondsSinceEpoch;
    //第一次
    if (previousTime == null) {
      previousTime = currentTime;
      RuntimeProperties.smsCodeSendTime = previousTime;
    }
    int deviation = (currentTime - previousTime);
    //此处用于解决点击"重新发送"按钮时，计数瞬间显示出现负数的情况
    if (60.0 - (deviation / 1000.0) < 0) {
      print("gap below zero");
      return 59;
    }
    return (60.0 - (deviation / 1000.0)).toInt();
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
        onPressed: () {
          _sendSmsOperations();
        },
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
  _sendSmsOperations() async {
    setState(() {
      _uiForCounting = true;
    });
    //请求接口
    bool result = await _correspRequest();
    if (result == true) {
      //后台返回结果表示已经发送了短信则置此变量为true，允许发送按钮的ui能进行对应的变化以表示
      //能够进行验证
      widget.sended = true;
    } else {
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
      if (timeGap < 60 * 1000 && timeGap > 0) {
        setState(() {});
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
  Future<bool> _correspRequest() async {
    return await _requestTask();
  }

  @override
  void dispose() {
    _timer.cancel();
    _timer = null;
    super.dispose();
  }
}
