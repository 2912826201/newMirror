import 'package:flutter/cupertino.dart';

class PinYinTextEditController extends TextEditingController{
  ///拼音输入完成后的文字
  var completeText = '';

  @override
  TextSpan buildTextSpan({@required BuildContext context, TextStyle style , @required bool withComposing}) {
    ///拼音输入完成
    if (!value.composing.isValid || !withComposing) {
      if(completeText!=value.text){
        print("进入输入完成回调");
        completeText = value.text;
        WidgetsBinding.instance.addPostFrameCallback((_){
          notifyListeners();
        });
      }
      return TextSpan(style: style, text: text);
    }

    ///返回输入样式，可自定义样式
    final TextStyle composingStyle = style.merge(
      const TextStyle(decoration: TextDecoration.underline),
    );
    print("进入下一城");
    return TextSpan(
        style: style,
        children: <TextSpan>[
          TextSpan(text: value.composing.textBefore(value.text)),
          TextSpan(
            style: composingStyle,
            text:
            value.composing.isValid && !value.composing.isCollapsed?
            value.composing.textInside(value.text):"",
          ),
          TextSpan(text: value.composing.textAfter(value.text)),
        ]);
  }

}
