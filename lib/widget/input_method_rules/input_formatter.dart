import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:mirror/util/toast_util.dart';

// 输入框回调
typedef InputChangedCallback = void Function(String value);

class InputFormatter extends TextInputFormatter {

  InputChangedCallback _inputChangedCallback;

  TextEditingController controller;
  // 最大字节数
  int maxNumberOfBytes;
  // 上下文
  BuildContext context;
  InputFormatter({
    @required this.controller,
    InputChangedCallback inputChangedCallback,
    this.context,
    this.maxNumberOfBytes,
  })  : assert( controller != null),
        _inputChangedCallback = inputChangedCallback;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // 需求要求按照字节数算超过好后不输入
    if (maxNumberOfBytes != null && utf8.encode(newValue.text).length > maxNumberOfBytes) {
      print("新值$newValue");
      print("旧值$oldValue");
      // 旧值文本
      String oldText = oldValue.text;
      // 后输入的文字
      String newInputText = utf8.decode(
          utf8.encode(newValue.text).sublist(utf8.encode(oldValue.text).length, utf8.encode(newValue.text).length));
      print("newInputText:::$newInputText");
      // 旧值文本长度
      int oldUtf8Length = utf8.encode(oldValue.text).length;
      print("oldUtf8Length:::1:::$oldUtf8Length");
      // 拼接没有超出限制的文本
      newInputText.characters.forEach((element) {
        oldUtf8Length += utf8.encode(element).length;
        print("oldUtf8Length:::2:::$oldUtf8Length");
        if (oldUtf8Length <= maxNumberOfBytes) {
          oldText += element;
        } else {
          print("跳出");
          ToastShow.show(msg: "字数超出限制", context: context, gravity: Toast.CENTER);
          return;
        }
      });
      return TextEditingValue(
          text: oldText,
          selection: TextSelection(
            baseOffset: oldText.length,
            extentOffset: oldText.length,
          ));
    }
    // 判断是删除还是新增
    bool isAdd = oldValue.text.length < newValue.text.length;
    // 如果是新增
    if (isAdd && oldValue.selection.start == oldValue.selection.end) {
    } else {
      /// 删除或替换内容 （含直接delete、选中后输入别的字符替换）
      if (!oldValue.composing.isValid || oldValue.selection.start != oldValue.selection.end) {
        return checkRules(oldValue, newValue);
      }
    }
    _inputChangedCallback( newValue.text);
    return newValue;
  }


  /// 检查被删除/替换的内容是否涉及到rules里的特殊segment并处理，另外作字符的处理替换
  TextEditingValue checkRules(TextEditingValue oldValue, TextEditingValue newValue) {
    if((oldValue.text.length-newValue.text.length)<=oldValue.text.characters
        .last.length){
      print('------------------------------表情删除监听');
      _inputChangedCallback?.call(oldValue.text.characters.skipLast(1).string);
      return TextEditingValue(text:oldValue.text.characters.skipLast(1).string,selection: TextSelection
        (baseOffset:oldValue.text.characters.skipLast(1).string
          .length,extentOffset: oldValue.text.characters.skipLast(1).string.length,
      ));
    }
    /// 旧的文本的光标是否选中了部分
    bool isOldSelectedPart = oldValue.selection.start != oldValue.selection.end;
    /// 因为选中删除 和 直接delete删除的开始光标位置不一，故作统一处理
    int startIndex = isOldSelectedPart ? oldValue.selection.start : oldValue.selection.start - 1;
    int endIndex = oldValue.selection.end;

    /// 对选中部分原字符串，键盘一次输入字符的替换处理，即找出新旧字符串之间的差异部分
    String newStartSelBeforeStr =
    newValue.text.substring(0, newValue.selection.start < 0 ? 0 : newValue.selection.start);
    String oldStartSelBeforeStr = oldValue.text.substring(0, oldValue.selection.start);
    String middleStr = "";
    if (newStartSelBeforeStr.length >= oldStartSelBeforeStr.length &&
        (oldValue.selection.end != oldValue.selection.start) &&
        newStartSelBeforeStr.compareTo(oldStartSelBeforeStr) != 0) {
      /// 此时为选中的删除时 有增加新的字符串的情况
      middleStr = newValue.text.substring(oldValue.selection.start, newValue.selection.end);
    } else {
      /// 此时为选中的删除时 没有增加新的字符串的情况
      print("无新增");
    }

    int leftSubStringEndIndex = startIndex > oldValue.text.length ? oldValue.text.length : startIndex;
    String leftValue = "${startIndex == 0 ? "" : oldValue.text.substring(0, leftSubStringEndIndex)}";
    String middleValue = "$middleStr";
    String rightValue =
        "${endIndex == oldValue.text.length ? "" : oldValue.text.substring(endIndex, oldValue.text.length)}";
    String value = "$leftValue$middleValue$rightValue";
    /// 计算最终光标位置
    final TextSelection newSelection = newValue.selection.copyWith(
      baseOffset: leftValue.length + middleValue.length,
      extentOffset: leftValue.length + middleValue.length,
    );
    /// 为了解决小米note的兼容问题
    // _flag = true;
    // Future.delayed(Duration(milliseconds: 10), () => _flag = false);

    _inputChangedCallback?.call( value);
    return TextEditingValue(
      text: value,
      selection: newSelection,
      composing: TextRange.empty,
    );
  }
}