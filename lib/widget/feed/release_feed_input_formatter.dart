// TextInputFormatter
// import 'dart:js';

import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

// at回调
typedef TriggerAtCallback = Future<String> Function(String at);
// #回调
typedef TrigerTopicCallback = Future<String> Function(String topic);
// 输入框回调
typedef ValueChangedCallback = void Function(
    List<Rule> rules, String value, int atIndex, int topicIndex, String atSearchStr, String topicSearchStr, bool isAdd);
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
  // 是否监听#话题
  final bool isMonitorTop;
  final Function correctRulesListener;

  // 记录@的光标
 List<AtIndex> atCursorIndexs;
  int atIndex = 0;
  // @后跟随的实时搜索文本
  String atSearchStr = "";

  // 记录#的光标
  int topicIndex = 0;

  // #后跟随的实时搜索文本
  String topicSearchStr = "";



  ReleaseFeedInputFormatter({
    TriggerAtCallback triggerAtCallback,
    ValueChangedCallback valueChangedCallback,
    TrigerTopicCallback triggerTopicCallback,
    ShutDownCallback shutDownCallback,
    @required this.controller,
    this.triggerAtSymbol = "@",
    this.triggerTopicSymbol = "#",
    this.isMonitorTop = true,
    this.atCursorIndexs,
    this.correctRulesListener,
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
    // print("utf8.encode(inputText):${utf8.encode(newValue.text).length}");
    print("新值前光标${newValue.selection.start}");

    print("新值后光标${newValue.selection.end}");
    print("旧值$oldValue");
    print("旧值前光标${oldValue.selection.start}");
    print("旧值后光标${oldValue.selection.end}");
    print("at光标$atIndex");
    print("rules￥￥${rules.toString()}");
    if (!isMonitorTop) {
      print("atCursorIndex::::${atCursorIndexs.toString()}");
      if ( atCursorIndexs.length > 0) {
        atIndex = atCursorIndexs.first.index;
      }
    }
    // if (oldValue.text == newValue.text && Platform.isIOS) {
    //   return oldValue;
    // }
    // 如果是新增
    if (isAdd && oldValue.selection.start == oldValue.selection.end) {
      print("新增？？？？？");

      if (newValue.text.length - oldValue.text.length == 1 &&
          newValue.text.substring(newValue.selection.start - 1, newValue.selection.end) == triggerAtSymbol) {
        // 因为在多@时只响应最后一个@的光标位置。
        atIndex = newValue.selection.end;
        topicIndex = 0;
        print("+++++++++++++++++++++++++++at光标$atIndex，triggerAtSymbol$triggerAtSymbol");
        _triggerAtCallback(triggerAtSymbol);
      }
      if (newValue.text.length - oldValue.text.length == 1 &&
          newValue.text.substring(newValue.selection.start - 1, newValue.selection.end) == triggerTopicSymbol && isMonitorTop) {
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
        //关闭列表回调
        _shutDownCallback();
      }

      // 跟随@后面输入的实时搜索值
      if (atIndex > 0 && newValue.selection.start >= atIndex) {
        atSearchStr = newValue.text.substring(atIndex, newValue.selection.start);
        print(atSearchStr);
      }
      if (topicIndex > 0 && newValue.selection.start >= topicIndex && isMonitorTop) {
        topicSearchStr = newValue.text.substring(topicIndex, newValue.selection.start);
      }
    } else {
      /// 删除或替换内容 （含直接delete、选中后输入别的字符替换）
      print("删除");
      print("isValid:::${!oldValue.composing.isValid}");
      print(oldValue.selection.start);
      print(oldValue.selection.end);
      if (!oldValue.composing.isValid || oldValue.selection.start != oldValue.selection.end ) {
        print("进了这里面");

        /// 直接delete情况 / 选中一部分替换的情况
        return checkRules(oldValue, newValue);
      }
      if (Platform.isIOS &&  oldValue.isComposingRangeValid) {
        // 跟随@后面输入的实时搜索值
        if (atIndex > 0 && newValue.selection.start >= atIndex) {
          atSearchStr = newValue.text.substring(atIndex, newValue.selection.start);
          print(atSearchStr);
        }
        if (topicIndex > 0 && newValue.selection.start >= topicIndex) {
          topicSearchStr = newValue.text.substring(topicIndex, newValue.selection.start);
        }
      }
    }


    print("还调用了下面");
    // ios在输入中就要去修正索引
    if (Platform.isIOS && oldValue.isComposingRangeValid) {
      print("ios输入中");
      if (rules.isNotEmpty ) {
        _correctRules(oldValue.selection.start, oldValue.text.length, newValue.text.length);
      }
    }
    // 输入完成时安卓修正索引，ios再次修正
    if (!oldValue.composing.isValid ) {
      print("ios 安卓：：：： 输入完成");
      if (rules.isNotEmpty ) {
        _correctRules(oldValue.selection.start, oldValue.text.length, newValue.text.length);
      }
      // ios如果当前光标在高亮范围内，唤醒@或者话题视图重新搜索， 移除当前高亮效果
      if (Platform.isIOS ) {
        Rule b;
        for (Rule rule in rules) {
          // 点击的是@高亮文本
          if (newValue.selection.start < rule.endIndex && newValue.selection.start > rule.startIndex && rule.isAt) {
            // 唤醒
            _triggerAtCallback(triggerAtSymbol);
            b = rule;
          }
          // 点击话题高亮
          if (newValue.selection.start < rule.endIndex && newValue.selection.start > rule.startIndex && !rule.isAt) {
            // 唤醒
            _triggerAtCallback(triggerTopicSymbol);
            b = rule;
          }
        }
        // 删除在点击范围内的@规则
        if(b != null) {
          rules.removeWhere((element) => b.id == element.id);
          print("sdkfskdfs");
          print(rules.toString());
        }
      }
      // if (!Platform.isIOS) {
        _valueChangedCallback(rules, newValue.text, atIndex, topicIndex, atSearchStr, topicSearchStr, true);
      // }
      print("返回值++++++++++++++++${newValue.text}");
    }
    // 此是应对ios在输入中时也要回调回去。
    if (Platform.isIOS && oldValue.isComposingRangeValid) {
      print("ios输入中返回回去");
      _valueChangedCallback(rules, newValue.text, atIndex, topicIndex, atSearchStr, topicSearchStr, true);
    }
    return newValue;
  }

  /// 当长度发生变化需要对旧的受影响的rule修正索引
  void _correctRules(int oldStartIndex, int oldLength, int newLength) {
    /// old startIndex
    print("skkdskfksdkfksfs");
    print(newLength);
    print(oldStartIndex);
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
    if(correctRulesListener!=null){
      correctRulesListener();
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
    // int startIndex = newValue.selection.end;
    print("新光标$startIndex");
    int endIndex = oldValue.selection.end;
    // 删除@或者#时要关闭视图
    print('==========topicIndex$topicIndex');
      if (startIndex + 1 <= atIndex) {
        print('==================startIndex + 1 <= atIndex');
      atIndex = 0;
        _shutDownCallback();
      }
      if (startIndex + 1 <= topicIndex) {
        print('==================startIndex + 1 <= topicIndex');
        topicIndex = 0;
        _shutDownCallback();
      }
    if (atIndex > 0 && startIndex + 1 > atIndex) {
      print("111");
      print(oldValue.text);
      print(oldValue.text.substring(atIndex, startIndex));
      atSearchStr = oldValue.text.substring(atIndex, startIndex);
    }
    print("2");
    if (topicIndex > 0 && startIndex + 1 > topicIndex) {
      topicSearchStr = oldValue.text.substring(topicIndex, startIndex);
    }
    print("3");

    bool isRule=false;

    /// 用于迭代的时候不能删除@的处理
    print(rules);
    List<Rule> delRules = [];
    // 删除部分文字时
    for (int i = 0; i < rules.length; i++) {
      Rule rule = rules[i];
      print(rule);
      if ((startIndex >= rule.startIndex && startIndex <= rule.endIndex - 1) ||
          (endIndex > rule.startIndex && endIndex <= rule.endIndex)) {
        isRule=true;
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

    // if(!isRule) {
    //   print("提前返回了");
    //   return newValue;
    // }
    // 一次性全部删除时
   if(newValue.text.isEmpty) {
     print("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%全部删除了");
     rules.clear();
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
    print("middleValue::$middleValue");
    print("rightValue::$rightValue");

    /// 计算最终光标位置
    final TextSelection newSelection = newValue.selection.copyWith(
      baseOffset: leftValue.length + middleValue.length,
      extentOffset: leftValue.length + middleValue.length,
    );
    print("oldValue.selection.start:${oldValue.selection.start}");
    print(" oldValue.text.length:${oldValue.text.length}");
    print("newValue.text.length${newValue.text.length}");
    print(oldValue);
    print(newValue);

    print(delRules);
    // 因为之前把@和#的值改为了1删除时要还原
    if (delRules.isNotEmpty) {
      _correctRules(
          oldValue.selection.start, oldValue.text.length, newValue.text.length - (delRules[0].params.length - 1));
    } else {
      _correctRules(oldValue.selection.start, oldValue.text.length, newValue.text.length);
    }

    /// 为了解决小米note的兼容问题
    // _flag = true;
    // Future.delayed(Duration(milliseconds: 10), () => _flag = false);

    _valueChangedCallback?.call(rules, value, 0, 0, atSearchStr, topicSearchStr, false);
    if(isRule) {
      return TextEditingValue(
        text: value,
        selection: newSelection,
        composing: TextRange.empty,
      );
    }else{
        ///这是多选删除
        if(oldValue.text.characters.length-newValue.text.characters.length>1){
          return newValue;
        }
        ///这是单字符删除
        print('------------------------------删除监听${newValue.selection.baseOffset}---${oldValue.selection.baseOffset}');
        String backText = "";
        String beginText = "";
        String lastText = "";
        try{
          /*note 这里只处理以characters为单位的单个字符，已知删除前的光标必为老值的光标，删除后的光标不能用新值的光标(默认没删完)
          所以用老值的光标取值再去掉最后一位，可得到删除的内容*/

          beginText = oldValue.text.substring(0,oldValue.selection.baseOffset);
          beginText  = beginText.characters.getRange(0,beginText.characters
              .length-1).string;
          lastText = oldValue.text.characters.getRange(beginText.characters.length+1,oldValue.text.characters.length).string;
          backText = beginText+lastText;
        }catch(e){
          print('--------------------------------$e');
      }
        return TextEditingValue(
            text:backText,
            selection: TextSelection(
              baseOffset: beginText.length,
              extentOffset:  beginText.length,
            ));
      }

    // return newValue;
  }

  void PositioningDeleteChar(){

  }
  void clear() {
    rules.clear();
  }
}

/// @和#话题的规则
class Rule {
  // 起始的索引值
   int startIndex;

  // 结束的索引值
   int endIndex;

  // 元素
  String params;

  // 用于防重复添加
   int clickIndex;

  // 区分时at还是话题
   bool isAt;

  // atUid
   int id;

  Rule(this.startIndex, this.endIndex, this.params, this.clickIndex, this.isAt, [this.id]);

  Rule.fromJson(Map<String, dynamic> json){
    startIndex = json["startIndex"];
    endIndex = json["endIndex"];
    params = json["params"];
    clickIndex = json["clickIndex"];
    isAt = json["isAt"];
    id = json["id"];
  }
   Map<String, dynamic> toJson() {
     var map = <String, dynamic>{};
     map["startIndex"] = startIndex;
     map["endIndex"] = endIndex;
     map["params"] = params;
     map["clickIndex"] = clickIndex;
     map["isAt"] = isAt;
     map["id"] = id;
     return map;
   }
  Rule copy([startIndex, endIndex, params]) {
    return Rule(startIndex ?? this.startIndex, endIndex ?? this.endIndex, params ?? this.params,
        clickIndex ?? this.clickIndex, isAt ?? this.isAt, id ?? this.id);
  }

  @override
  String toString() {
    return "startIndex : $startIndex, endIndex : $endIndex, param :$params,clickIndex :$clickIndex, isAt:$isAt, id : $id";
  }
}

class AtIndex {
  final int index;
  AtIndex(this.index);
  @override
  String toString() {
    return "index : $index";
  }
}
