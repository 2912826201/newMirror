import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
// 输入框回调
typedef InputChangedCallback = void Function(String value);

class InputFormatter extends TextInputFormatter {

  InputChangedCallback _inputChangedCallback;

  TextEditingController controller;

  InputFormatter({
    @required this.controller,
    InputChangedCallback inputChangedCallback,
  })  : assert( controller != null),
        _inputChangedCallback = inputChangedCallback;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
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