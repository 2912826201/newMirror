import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/util/string_util.dart';

class ExpressionTeamDeleteFormatter extends TextInputFormatter {
  int maxLength;
  //这是用于判断是否可以输入换行但是需要筛选
  bool needFilter;
  ExpressionTeamDeleteFormatter({this.maxLength,this.needFilter = false});

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    print('------------------------------formatEditUpdate');
    print("00000000000000000");
    String inputText;

    if (newValue.text.length > oldValue.text.length) {
      print("111111111111111");
      if(maxLength != null&&!newValue.composing.isValid){
        print('22222222222222222222222');
          ///还可以输入多少字符
        int needCount = maxLength - oldValue.text.length;

        ///输入前的光标位置
        int inputFristIndex = newValue.text.substring(0, oldValue.selection.baseOffset).characters.length;

        ///输入后的光标位置
        int inputLastIndex = newValue.text.substring(0, newValue.selection.baseOffset).characters.length;

        ///输入的字符
        inputText = newValue.text.characters.getRange(inputFristIndex, inputLastIndex).string;
        print('-----------------inputText$inputText');
        print('----------------------------预输入拦截');
        ///这是需要返回的字符
        String backText = "";

        ///这里先将新输入的文字之前的字符加进去
        backText += newValue.text.substring(0, oldValue.selection.baseOffset);
        ///这里用写好的通用截取字符方法去将新输入的字符截取成我们想要的格式
        String interceptInputText = "";
        if(needFilter){
          print('4444444444444444444444444444$inputText');
          inputText = StringUtil.textWrapMatch(inputText,wantWrapCount: 0);
          print('5555555555555555555555555555$inputText');
        }
        if(inputText!=null){
         interceptInputText = StringUtil.maxLength(inputText, needCount, isOmit: false);
          backText += interceptInputText;
        }
        backText += newValue.text.substring(newValue.selection.baseOffset, newValue.text.length);
        print('------------------------backText$backText');
        newValue = TextEditingValue(text: backText,selection: TextSelection(
          baseOffset: oldValue.selection.baseOffset + interceptInputText.length,
          extentOffset: oldValue.selection.baseOffset + interceptInputText.length,
        ));
        return newValue;
      }
    }
    print("oldValue::::$oldValue");
    print("newValue::::$newValue");

    ///这是删除的监听
    if (oldValue.text.length > newValue.text.length&&!newValue.composing.isValid) {
      print('5555555555555555555555555555555555');

      ///这是多选删除
      if (oldValue.text.characters.length - newValue.text.characters.length > 1) {
        print('66666666666666666666666666666666666666666');
        return newValue;
      }

      ///这是单字符删除
      print('------------------------------删除监听${newValue.selection.baseOffset}---${oldValue.selection.baseOffset}');
      String backText = "";
      int choseIndex;
      for (int i = 0; i < oldValue.text.characters.toList().length; i++) {
        if (oldValue.text.characters.toList()[i].length - 1 + backText.length < newValue.selection.baseOffset) {
          backText += oldValue.text.characters.toList()[i];
          print('--------------------${backText}');
        } else if (choseIndex == null) {
          choseIndex = i;
          print('-----------------------被删掉的内容${oldValue.text.characters.toList()[i]}');
        } else if (choseIndex != i) {
          backText += oldValue.text.characters.toList()[i];
        }
      }
      return TextEditingValue(
          text: backText,
          selection: TextSelection(
            baseOffset: oldValue.text.characters.getRange(0, choseIndex).string.length,
            extentOffset: oldValue.text.characters.getRange(0, choseIndex).string.length,
          ));
    }
    print("newValue::::::$newValue");
    print('end--end--end--end--end--end--end--end--end--end--');
    return newValue;
  }
}
