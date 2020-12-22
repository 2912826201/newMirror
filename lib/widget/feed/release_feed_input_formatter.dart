// TextInputFormatter
// import 'dart:js';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

// at回调
typedef TriggerAtCallback = Future<String> Function(String at);
// #回调
typedef TrigerTopicCallback = Future<String> Function(String topic);
// 输入框回调
typedef ValueChangedCallback = void Function(List<Rule> rules, String value, int atIndex, int topicIndex , String atSearchStr, String topicSearchStr);
// 关闭@和话题的回调
typedef ShutDownCallback = Future Function();

class ReleaseFeedInputFormatter extends TextInputFormatter {
  TriggerAtCallback _triggerAtCallback;
  ValueChangedCallback _valueChangedCallback;
  TrigerTopicCallback _triggerTopicCallback;
  ShutDownCallback _shutDownCallback;
  TextEditingController controller;
  List<Rule> rules;
  final String triggerAtSymbol;
  final String triggerTopicSymbol;

  // 记录@的光标
  int atIndex = 0;

  // @后跟随的实时搜索文本
  String atSearchStr = "";

  // 记录#的光标
  int topicIndex = 0;
  // #后跟随的实时搜索文本
  String topicSearchStr = "";

  List<Rule> delRules = [];

  ReleaseFeedInputFormatter({
    TriggerAtCallback triggerAtCallback,
    ValueChangedCallback valueChangedCallback,
    TrigerTopicCallback triggerTopicCallback,
    ShutDownCallback shutDownCallback,
    @required this.controller,
    this.triggerAtSymbol = "@",
    this.triggerTopicSymbol = "#",
    this.rules,
  })  : assert(triggerAtCallback != null && controller != null),
        _triggerAtCallback = triggerAtCallback,
        _valueChangedCallback = valueChangedCallback,
        _triggerTopicCallback = triggerTopicCallback,
        _shutDownCallback = shutDownCallback;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // 判断是删除还是新增

    bool isAdd = oldValue.text.length < newValue.text.length;
    print("新值$newValue");
    print("新值前光标${newValue.selection.start}");
    print("新值后光标${newValue.selection.end}");
    print("旧值$oldValue");
    print("旧值前光标${oldValue.selection.start}");
    print("旧值后光标${oldValue.selection.end}");
    // 如果是新增
    if (isAdd && oldValue.selection.start == oldValue.selection.end) {
      print("新增？？？？？");
      if (newValue.text.length - oldValue.text.length == 1 &&
          newValue.text.substring(newValue.selection.start - 1, newValue.selection.end) == triggerAtSymbol) {
        // 因为在多@时只响应最后一个@的光标位置。
        atIndex = newValue.selection.end;
        topicIndex = 0;
        print("at光标$atIndex");
        _triggerAtCallback(triggerAtSymbol);
      }
      if (newValue.text.length - oldValue.text.length == 1 &&
          newValue.text.substring(newValue.selection.start - 1, newValue.selection.end) == triggerTopicSymbol) {
        print("输入了#");
        topicIndex = newValue.selection.end;
        atIndex = 0;
        print("#光标$topicIndex");
        _triggerTopicCallback(triggerTopicSymbol);
      }
      // 输入空格换行关闭@#视图
      if (newValue.text.length - oldValue.text.length == 1 &&
          (newValue.text.substring(newValue.selection.start - 1, newValue.selection.end) == " " ||
              newValue.text.substring(newValue.selection.start - 1, newValue.selection.end) == "\n")) {
        atIndex = 0;
        topicIndex = 0;
        _shutDownCallback();
      }
      // 跟随@后面输入的实时搜索值
      if (atIndex > 0 && newValue.selection.start >= atIndex) {
        atSearchStr = newValue.text.substring(atIndex,newValue.selection.start);
        print(atSearchStr);
      }
      if (topicIndex > 0 && newValue.selection.start >= topicIndex) {
        topicSearchStr = newValue.text.substring(topicIndex,newValue.selection.start);
      }
      // 在删除操作中删除了rules中的数据，使用了provide后， 回调后会再次进入重走逻辑。在此阻止。
      if (delRules.isNotEmpty) {
        if (oldValue.text == newValue.text.substring(0,delRules[0].startIndex)) {
          delRules = [];
          return oldValue;
        }
      }
    } else {
      /// 删除或替换内容 （含直接delete、选中后输入别的字符替换）
      if (!oldValue.composing.isValid || oldValue.selection.start != oldValue.selection.end) {
        print("进了这里面");
        /// 直接delete情况 / 选中一部分替换的情况
        delRules = [];
        return checkRules(oldValue, newValue);
      }
    }

    print("还调用了下面");
    print(delRules);
    _correctRules(oldValue.selection.start, oldValue.text.length, newValue.text.length);
    _valueChangedCallback(rules, newValue.text, atIndex, topicIndex,atSearchStr,topicSearchStr);
    return newValue;
  }

  /// 当长度发生变化需要对旧的受影响的rule修正索引
  void _correctRules(int oldStartIndex, int oldLength, int newLength) {
    /// old startIndex
    print("skkdskfksdkfksfs");
    print(newLength);
    int diffLength = newLength - oldLength;
    for (int i = 0; i < rules.length; i++) {
      print(rules[i]);
      if (rules[i].startIndex >= oldStartIndex) {
        int newStartIndex = rules[i].startIndex + diffLength;
        int newEndIndex = rules[i].endIndex + diffLength;
        rules.replaceRange(i, i + 1, <Rule>[rules[i].copy(newStartIndex, newEndIndex)]);
        print(rules[i]);
      }
    }
  }

  /// 检查被删除/替换的内容是否涉及到rules里的特殊segment并处理，另外作字符的处理替换
  TextEditingValue checkRules(TextEditingValue oldValue, TextEditingValue newValue) {
    /// 旧的文本的光标是否选中了部分
    bool isOldSelectedPart = oldValue.selection.start != oldValue.selection.end;
    print(isOldSelectedPart);
    print(newValue);
    print(oldValue);
    /// 因为选中删除 和 直接delete删除的开始光标位置不一，故作统一处理
    int startIndex = isOldSelectedPart ? oldValue.selection.start : oldValue.selection.start - 1;
    print("新光标$startIndex");
    int endIndex = oldValue.selection.end;
    // 删除@或者#时要关闭视图
    if (startIndex + 1 <= atIndex || startIndex + 1 <= topicIndex) {
      _shutDownCallback();
      if (startIndex + 1 <= atIndex) {
        atIndex = 0;
      }
      if (startIndex + 1 <= topicIndex) {
        topicIndex = 0;
      }
    }
    if (atIndex > 0 && startIndex + 1 > atIndex) {
      print("111");
      print(oldValue.text);
      print(oldValue.text.substring(atIndex,startIndex));
      atSearchStr = oldValue.text.substring(atIndex,startIndex);
    }
    print("2");
    if (topicIndex > 0 && startIndex + 1 > topicIndex) {
      topicSearchStr = oldValue.text.substring(topicIndex,startIndex);
    }
    print("3");
    /// 用于迭代的时候不能删除@的处理
     print(rules);

    for (int i = 0; i < rules.length; i++) {
      Rule rule = rules[i];
      print(rule);
      if ((startIndex >= rule.startIndex && startIndex <= rule.endIndex -1) ||
          (endIndex >= rule.startIndex && endIndex <= rule.endIndex)) {
        print("光标开始位置$startIndex");
        print("光标结束位置$endIndex");
        print(startIndex >= rule.startIndex && startIndex <= rule.endIndex);
        print(endIndex >= rule.startIndex && endIndex <= rule.endIndex);
        print(startIndex <= rule.endIndex);
        print(endIndex <= rule.endIndex);
        print("删除搜易");

        /// 原字符串选中的光标范围 与 rule的范围相交，命中
        delRules.add(rule);
        /// 对命中的rule 的边界与原字符串选中的光标边界比较，对原来的选中要被替换/删除的光标界限 进行扩展
        /// 用来自动覆盖@user 的全部字符
        startIndex = math.min(startIndex, rule.startIndex);
        endIndex = math.max(endIndex, rule.endIndex);
        print("用来自动覆盖$startIndex,,,,,,,,,,,$endIndex");
      }
    }

    /// 清除掉不需要的rule
    for (int i = 0; i < delRules.length; i++) {
      rules.remove(delRules[i]);
    }

    /// 对选中部分原字符串，键盘一次输入字符的替换处理，即找出新旧字符串之间的差异部分
    String newStartSelBeforeStr =
        newValue.text.substring(0, newValue.selection.start < 0 ? 0 : newValue.selection.start);
    String oldStartSelBeforeStr = oldValue.text.substring(0, oldValue.selection.start);
    String middleStr = "";
    if (newStartSelBeforeStr.length >= oldStartSelBeforeStr.length &&
        (oldValue.selection.end != oldValue.selection.start) &&
        newStartSelBeforeStr.compareTo(oldStartSelBeforeStr) != 0) {
      /// 此时为选中的删除时 有增加新的字符串的情况
      print("新增");
      middleStr = newValue.text.substring(oldValue.selection.start, newValue.selection.end);
    } else {
      /// 此时为选中的删除时 没有增加新的字符串的情况
      print("无新增");
    }

    int leftSubStringEndIndex = startIndex > oldValue.text.length ? oldValue.text.length : startIndex;
    print("leftSubStringEndIndex:$leftSubStringEndIndex");
    String leftValue = "${startIndex == 0 ? "" : oldValue.text.substring(0, leftSubStringEndIndex)}";
   print("leftValue&$leftValue");
    String middleValue = "$middleStr";
    String rightValue =
        "${endIndex == oldValue.text.length ? "" : oldValue.text.substring(endIndex, oldValue.text.length)}";
    String value = "$leftValue$middleValue$rightValue";
   print("value::$value");
    /// 计算最终光标位置
    final TextSelection newSelection = newValue.selection.copyWith(
      baseOffset: leftValue.length + middleValue.length,
      extentOffset: leftValue.length + middleValue.length,
    );
    print("oldValue.selection.start:${oldValue.selection.start}");
    print(" oldValue.text.length:${ oldValue.text.length}");
    print("newValue.text.length${newValue.text.length}");
    print(oldValue);
    print(newValue);

    print(delRules);
    // 因为之前把@和#的值改为了1删除时要还原
    if (delRules.isNotEmpty) {
      _correctRules(oldValue.selection.start, oldValue.text.length, newValue.text.length - (delRules[0].params.length - 1));
    } else {
      _correctRules(oldValue.selection.start, oldValue.text.length, newValue.text.length);
    }


    /// 为了解决小米note的兼容问题
    // _flag = true;
    // Future.delayed(Duration(milliseconds: 10), () => _flag = false);

    _valueChangedCallback?.call(rules, value, 0, 0,atSearchStr,topicSearchStr);
    return TextEditingValue(
      text: value,
      selection: newSelection,
      composing: TextRange.empty,
    );
  }

  void clear() {
    rules.clear();
  }
}

/// @和#话题的规则
class Rule {
  // 起始的索引值
  final int startIndex;

  // 结束的索引值
  final int endIndex;

  // 元素
  final String params;

  // 用于防重复添加
  final int clickIndex;

  // 区分时at还是话题
  final bool isAt;

  Rule(this.startIndex, this.endIndex, this.params, this.clickIndex, this.isAt);

  Rule copy([startIndex, endIndex, params]) {
    return Rule(startIndex ?? this.startIndex, endIndex ?? this.endIndex, params ?? this.params,
        clickIndex ?? this.clickIndex, isAt ?? this.isAt);
  }

  @override
  String toString() {
    return "startIndex : $startIndex , endIndex : $endIndex, param :$params ,clickIndex :$clickIndex , isAt:$isAt";
  }
}