import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class ExpressionTeamDeleteFormatter extends TextInputFormatter {
  int maxLength;
  ExpressionTeamDeleteFormatter({this.maxLength});
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.length > oldValue.text.length&&maxLength!=null) {
      if (newValue.text.length>maxLength&&newValue.text.length - oldValue.text.length > 1 &&
          (newValue.text.characters.getRange(oldValue.text.characters.length, newValue.text.characters.length).string.characters.length >
              1)) {
        print('----------------------------预输入拦截');
        int needCount =maxLength-oldValue.text.length;
        return TextEditingValue(
            text: oldValue.text+newValue.text.characters.getRange(oldValue.text.characters.length, newValue.text
                .characters.length).string.substring(0,needCount),
            selection: TextSelection(
              baseOffset: "${oldValue.text+newValue.text.characters.getRange(oldValue.text.characters.length,
                  newValue.text
                  .characters.length).string.substring(0, needCount)}".length,
              extentOffset: "${oldValue.text+newValue.text.characters.getRange(oldValue.text.characters.length,
                  newValue.text
                      .characters.length).string.substring(0, needCount)}".length,
            ));
      }
      if(newValue.text.length>15){
        print('----------------------------正常拦截');
        return oldValue;
      }
    }

    if (oldValue.text.length > newValue.text.length &&
        (oldValue.text.length - newValue.text.length) <= oldValue.text.characters.last.length) {
      print('------------------------------删除监听');
      return TextEditingValue(
          text: oldValue.text.characters.skipLast(1).string,
          selection: TextSelection(
            baseOffset: oldValue.text.characters.skipLast(1).string.length,
            extentOffset: oldValue.text.characters.skipLast(1).string.length,
          ));
    }
    return newValue;
  }
}
