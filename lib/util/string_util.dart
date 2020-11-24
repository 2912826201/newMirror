/// string_util
/// Created by yangjiayi on 2020/11/24.

class StringUtil {
  //TODO 这个正则表达式需要可以更新
  static bool matchPhoneNumber(String phoneNum) {
    RegExp exp = RegExp(r"^(((\+86)|(86))?((13[0-9])|(14[0-9])|(15[0-9])|(16[0-9])|(19[0-9])|(17[0-9])|(18[0-9]))\d{8}"
        r"\,)*(((\+86)|(86))?((13[0-9])|(14[0-9])|(15[0-9])|(16[0-9])|(19[0-9])|(17[0-9])|(18[0-9]))\d{8})$");
    return exp.hasMatch(phoneNum);
  }
}
