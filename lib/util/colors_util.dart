import 'dart:ui';

class ColorsUtil {
  // 将十六进制颜色字符串转换为颜色
  static Color hexToColor(String code) {
    return new Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
  }
}
