import 'package:flutter/services.dart';


///体重和身高的输入限制
///第四位不是小数点则为整数，则只能输入三位数
///第四位为小数点则不是整数，则可以输入六位
class PrecisionLimitFormatter extends TextInputFormatter {
  int _scale;

  PrecisionLimitFormatter(this._scale);

  RegExp exp = new RegExp("[0-9.]");
  static const String POINTER = ".";
  static const String DOUBLE_ZERO = "00";

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
          ///旧值新值都不存在小数点，并且长度大于三时直接返回旧值
      if(!oldValue.text.contains(POINTER)&&newValue.text.length>3&&!newValue.text.contains(POINTER)){
        return oldValue;
      }
      if (newValue.text.startsWith(POINTER) && newValue.text.length == 1) {
        //第一个不能输入小数点
        return oldValue;
      }



    ///输入完全删除
    if (newValue.text.isEmpty) {
      return TextEditingValue();
    }

    ///只允许输入小数
    if (!exp.hasMatch(newValue.text)) {
      return oldValue;
    }

    ///包含小数点的情况
    if (newValue.text.contains(POINTER)) {
      ///包含多个小数
      if (newValue.text.indexOf(POINTER) != newValue.text.lastIndexOf(POINTER)) {
        return oldValue;
      }
      String input = newValue.text;
      int index = input.indexOf(POINTER);

      ///小数点后位数
      int lengthAfterPointer = input.substring(index, input.length).length - 1;

      ///小数位大于精度
      if (lengthAfterPointer > _scale) {
        return oldValue;
      }
    } else if (newValue.text.startsWith(POINTER) || newValue.text.startsWith(DOUBLE_ZERO)) {
      ///不包含小数点,不能以“00”开头
      return oldValue;
    }
    return newValue;
  }
}