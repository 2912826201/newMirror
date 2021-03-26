import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:mirror/util/string_util.dart';

class ExpressionTeamDeleteFormatter extends TextInputFormatter {
  int maxLength;
  ExpressionTeamDeleteFormatter({this.maxLength});
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    print('------------------------------formatEditUpdate');
    if (newValue.text.length > oldValue.text.length&&maxLength!=null) {
      if (newValue.text.length>maxLength&&oldValue.text.length<maxLength) {
        ///还可以输入多少字符
        int needCount =maxLength-oldValue.text.length;
        ///输入前的光标位置
        int inputFristIndex = newValue.text.substring(0,oldValue.selection.baseOffset).characters.length;
        ///输入后的光标位置
        int inputLastIndex = newValue.text.substring(0,newValue.selection.baseOffset).characters
            .length;
        ///输入的字符
        String inputText = newValue.text.characters.getRange(inputFristIndex,inputLastIndex).string;
        print('-----------------inputText$inputText');
        print('----------------------------预输入拦截');
        ///这是需要返回的字符
        String backText = "";
        ///这里先将新输入的文字之前的字符加进去
        backText += newValue.text.substring(0,oldValue.selection.baseOffset);
        ///这里用写好的通用截取字符方法去将新输入的字符截取成我们想要的格式
        String interceptInputText = StringUtil.maxLength(inputText,needCount);
        backText += interceptInputText;
        backText +=  newValue.text.substring(newValue.selection.baseOffset,newValue.text.length);
        print('------------------------backText$backText');
        return TextEditingValue(
            text: backText,
            selection: TextSelection(
              baseOffset: oldValue.selection.baseOffset+interceptInputText.length,
              extentOffset:oldValue.selection.baseOffset+interceptInputText.length,
            ));
      }
      if(newValue.text.length>maxLength){
        print('----------------------------正常拦截');
        return oldValue;
      }
    }
        ///这是删除的监听
    if (oldValue.text.length > newValue.text.length) {
      ///这是多选删除
      if(oldValue.text.characters.length-newValue.text.characters.length>1){
        return newValue;
      }

      ///这是单字符删除
      print('------------------------------删除监听${newValue.selection.baseOffset}---${oldValue.selection.baseOffset}');
      String backText = "";
      int choseIndex;
      for(int i = 0;i<oldValue.text.characters
          .toList().length;i++){
        if(oldValue.text.characters
            .toList()[i].length+backText.length-1<newValue.selection.baseOffset){
          backText += oldValue.text.characters
              .toList()[i];
          print('--------------------${backText}');
        }else if(choseIndex==null){
          choseIndex = i;
        }else if(choseIndex!=i){
          backText += oldValue.text.characters.toList()[i];
        }
      }
      return TextEditingValue(
          text:backText,
          selection: TextSelection(
            baseOffset: oldValue.text.characters
                .getRange(0,choseIndex).string.length,
            extentOffset:  oldValue.text.characters
                .getRange(0,choseIndex).string.length,
          ));
    }
    return newValue;
  }
}
