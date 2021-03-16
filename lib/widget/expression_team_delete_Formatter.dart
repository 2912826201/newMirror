

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class ExpressionTeamDeleteFormatter extends TextInputFormatter{

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if(oldValue.text.length>newValue.text.length&&(oldValue.text.length-newValue.text.length)<=oldValue.text.characters
        .last.length){
      print('------------------------------表情删除监听');
      return TextEditingValue(text:oldValue.text.characters.skipLast(1).string,selection: TextSelection
        (baseOffset:oldValue.text.characters.skipLast(1).string
          .length,extentOffset: oldValue.text.characters.skipLast(1).string.length,
      ));
    }
    return newValue;
  }
}