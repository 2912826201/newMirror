import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

///定时类回调任务
typedef TimerCall = void Function();
typedef submitableCall = void Function();

/// 可交互协议
abstract class InteractiveProtocol {
  ///前提状态判断
  bool avalibleCondition();

  ///就绪
  Function completion();

  ///提供监听控制器
  ValueNotifier Observer();

  ///动作的激发
  signal(dynamic value);
}

///可交互的区域
abstract class InteractiveAreaWidget extends StatefulWidget implements InteractiveProtocol {
  final Widget child;

  InteractiveAreaWidget({Key key, this.child})
      : assert(child != null),
        super(key: key);
  final _state = _InteractiveAreaWidgetState();

  @override
  State<StatefulWidget> createState() {
    return _state;
  }

  @override
  signal(dynamic value) {
    _state.signal(value);
  }
}

class _InteractiveAreaWidgetState extends State<InteractiveAreaWidget> {
  ValueNotifier _observer;

  signal(dynamic value) {
    _observer.value = value;
  }

  @override
  void initState() {
    _observer = this.widget.Observer();
    _observer.addListener(() {
      if (this.widget.avalibleCondition() == true) {
        this.widget.completion();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget;
  }
}

abstract class RegisterInputTemplateState extends State<StatefulWidget> {
  @override
  void initState() {
    super.initState();
    themeExplanationStyle ??= _themeExplainStyle;
    themeStyle ??= _themeStyle;
    popButtonImage ??= _backImageUrl;
    submitTitleStyle ??= _submitTitleStyle;
    _backButton = FlatButton(onPressed: popBack, child: Image.asset(popButtonImage));
    inputController.addListener(() {
      if (inputJudgement() == true) {
        afterValidInput();
      } else {
        reSet();
      }
    });
  }

  ///构造函数
  RegisterInputTemplateState(this.theme, this.inputController, this.themeExplain,
      {themeStyle: TextStyle,
      themeExplanationStyle: TextStyle,
      inputPlaceholder: InputDecoration,
      clearAllImage: String,
      popButtonImage: String,
      Key key});

  /// ********************
  /// ********************

  @override
  @mustCallSuper
  Widget build(BuildContext context) {
  }

  /// 回退页面操作
  @mustCallSuper
  Function popBack() {
    Navigator.of(context).pop();
  }

  /// 导航栏生成
  @mustCallSuper
  Widget navigationBar() {
    var leftbackBtn;
    leftbackBtn = SizedBox(
      child: _backButton,
      height: 28,
      width: 28,
    );
    var bag = Row(
      children: [leftbackBtn],
    );
    return Container(
      child: bag,
      height: 48,
      padding: EdgeInsets.only(left: 16, top: 10, bottom: 10),
    );
  }

  ///右上方的"更多"可点击区域激发函数
  Function moreAction() {}

  /// **********************  ******* ******************* *****************  **  ///
  /// ***** ******************* 虚函数 ****************************************///
  ///告示区域
  @factory
  Widget statementArea();

  ///变化交互区域
  @factory
  InteractiveAreaWidget interactiveArea();

  ///提交交互区域
  @factory
  MaterialButton submitArea();

  ///输入判定(这里的输入指的是操作引发的某个状态的变化)
  @factory
  bool inputJudgement();

  /// input合法时的自动调用
  @factory
  Function afterValidInput();

  /// 下一页判定
  @factory
  bool submitable();

  /// 界面等的恢复
  Function reSet();

  ///提交动作
  @factory
  Function submitAction();

  /// **********************  ******* ******************* *****************  **  ///
  /// **********************  属性交代 ******* ******************* *****************  **  ///
  /// 计时事件
  TimerCall timecall;

  /// 主题
  final String theme;

  /// 主题说明
  final String themeExplain;

  /// 主题样式
  @protected
  TextStyle themeStyle;

  /// 主题说明样式
  @protected
  TextStyle themeExplanationStyle;

  /// 输入框默认说明文字
  @protected
  String inputPlaceholder;

  /// 输入框的样式
  @protected
  InputDecoration inputDecoration;

  ///返回按钮图标路径
  @protected
  String popButtonImage;

  ///后缀控件的初始值宽高
  @protected
  List<double> suffixInitialWH;

  ///相关事件触发（如果有的话）之后的后缀控件的宽高
  @protected
  List<double> suffixDidChangeWH;

  ///一键清除操作的控件的图片
  @protected
  String suffixImage;

  ///返回按钮
  @protected
  FlatButton _backButton;

  /// 提交按钮的标题显示
  @protected
  String submitTitle;

  /// 提交按钮的标题样式
  @protected
  TextStyle submitTitleStyle;

  /// 提交按钮的背景色
  @protected
  Color submitColor;

  /// 提交按钮的形状
  @protected
  ShapeBorder submitShape;

  /// 输入栏控制器 readonly
  final ValueNotifier inputController;

  /// 右上方的Widget的child
  @protected
  Widget moreActionWidget;

  /// 私有属性
  final _backImageUrl = "assets/images/back.png";
  final _themeExplainStyle = TextStyle(
      fontFamily: "PingFangSC", color: Color.fromRGBO(153, 153, 153, 1), fontSize: 14, decoration: TextDecoration.none);
  final _themeStyle =
      TextStyle(fontFamily: 'PingFangSC', fontSize: 23, color: Colors.black, decoration: TextDecoration.none);
  final _submitTitleStyle = TextStyle(fontFamily: "PingFangSC", fontSize: 16, color: Color.fromRGBO(153, 153, 153, 1));

  /// **********************************************
  /// ********************内部逻辑***************************
  /// ***********************************************
  /// 判定流数组针对的全局的情况是否具备完善（完备情况即可以做好相关工作然后直接跳转到下一页），和inputController的的listner不一样，
  /// inputController的内部的回调用于自身的的使用，它自己发出信号出来是其自己的事情，但其信号包括进了判定流数组用于全局完备情况的判定。
  ///判定流数组
  final Map<String, bool> _boolist = Map<String, bool>();

  /// true判定流（用于操作时触发）
  Map<String, bool> _validSignal(String uniqueIdf) {
    _boolist[uniqueIdf] = true;
    _trigger();
    return _boolist;
  }

  ///false判定流(用于操作时触发)
  Map<String, bool> _invalidSignal(String uniqueIdf) {
    _boolist[uniqueIdf] = false;
    _trigger();
    return _boolist;
  }

  /// 激发信号
  Function _trigger() {
    _triggerWithBool(_merge());
  }

  /// 指定bool激发信号
  Function _triggerWithBool(bool b) {
    inputController.value = b;
  }

  Function _controllerCallBackTriggerWithBool(bool b) {
    inputController.value = b;
  }

  /// 合并信号
  bool _merge() {
    int t = 1;
    bool begin = _boolist.values.first;
    begin ??= false;
    int lengh = _boolist.length;
    for (; t < lengh; t++) {
      begin = begin && _boolist[t];
    }
    return begin;
  }

  /// 判定流字典清空
  Function _clearJudgeConditions() {
    _boolist.clear();
  }
}
