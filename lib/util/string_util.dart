import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';

/// string_util
/// Created by yangjiayi on 2020/11/24.
class StringUtil {
  //TODO 这个正则表达式需要可以更新
  static bool matchPhoneNumber(String phoneNum) {
    RegExp exp = RegExp(r"^(((\+86)|(86))?((13[0-9])|(14[0-9])|(15[0-9])|(16[0-9])|(19[0-9])|(17[0-9])|(18[0-9]))\d{8}"
        r"\,)*(((\+86)|(86))?((13[0-9])|(14[0-9])|(15[0-9])|(16[0-9])|(19[0-9])|(17[0-9])|(18[0-9]))\d{8})$");
    return exp.hasMatch(phoneNum);
  }

  /// 字符串不为空
  static bool strNoEmpty(String value) {
    if (value == null) return false;

    return value.trim().isNotEmpty;
  }

// md5 加密
  static String generateMd5(String data) {
    var content = new Utf8Encoder().convert(data);
    var digest = md5.convert(content);
    // 这里其实就是 digest.toString()
    return hex.encode(digest.bytes);
  }

  static RegExp _ipv4Maybe = new RegExp(r'^(\d?\d?\d)\.(\d?\d?\d)\.(\d?\d?\d)\.(\d?\d?\d)$');

  static RegExp _ipv6 = new RegExp(r'^::|^::1|^([a-fA-F0-9]{1,4}::?){1,7}([a-fA-F0-9]{1,4})$');

  /// check if the string [str] is a URL
  ///
  /// * [protocols] 设置允许的协议列表
  /// * [requireTld] 设置是否需要TLD
  /// * [requireProtocol] 是一个“ bool”，用于设置是否需要协议进行验证
  /// * [allowUnderscore] 设置是否允许使用下划线
  /// * [hostWhitelist] 设置允许的主机列表
  /// * [hostBlacklist] 设置不允许的主机列表
  static bool isURL(String str,
      {List<String> protocols = const ['http', 'https', 'ftp'],
      bool requireTld = true,
      bool requireProtocol = false,
      bool allowUnderscore = false,
      List<String> hostWhitelist = const [],
      List<String> hostBlacklist = const []}) {
    if (str == null || str.length == 0 || str.length > 2083 || str.startsWith('mailto:')) {
      return false;
    }

    var protocol, user, auth, host, hostname, port, port_str, path, query, hash, split;

    // check protocol
    split = str.split('://');
    if (split.length > 1) {
      protocol = shift(split);
      if (protocols.indexOf(protocol) == -1) {
        return false;
      }
    } else if (requireProtocol == true) {
      return false;
    }
    str = split.join('://');

    // check hash
    split = str.split('#');
    str = shift(split);
    hash = split.join('#');
    if (hash != null && hash != "" && new RegExp(r'\s').hasMatch(hash)) {
      return false;
    }

    // check query params
    split = str.split('?');
    str = shift(split);
    query = split.join('?');
    if (query != null && query != "" && new RegExp(r'\s').hasMatch(query)) {
      return false;
    }

    // check path
    split = str.split('/');
    str = shift(split);
    path = split.join('/');
    if (path != null && path != "" && new RegExp(r'\s').hasMatch(path)) {
      return false;
    }

    // check auth type urls
    split = str.split('@');
    if (split.length > 1) {
      auth = shift(split);
      if (auth.indexOf(':') >= 0) {
        auth = auth.split(':');
        user = shift(auth);
        if (!new RegExp(r'^\S+$').hasMatch(user)) {
          return false;
        }
        if (!new RegExp(r'^\S*$').hasMatch(user)) {
          return false;
        }
      }
    }

    // check hostname
    hostname = split.join('@');
    split = hostname.split(':');
    host = shift(split);
    if (split.length > 0) {
      port_str = split.join(':');
      try {
        port = int.parse(port_str, radix: 10);
      } catch (e) {
        return false;
      }
      if (!new RegExp(r'^[0-9]+$').hasMatch(port_str) || port <= 0 || port > 65535) {
        return false;
      }
    }

    if (!isIP(host) &&
        !isFQDN(host, requireTld: requireTld, allowUnderscores: allowUnderscore) &&
        host != 'localhost') {
      return false;
    }

    if (hostWhitelist.isNotEmpty && !hostWhitelist.contains(host)) {
      return false;
    }

    if (hostBlacklist.isNotEmpty && hostBlacklist.contains(host)) {
      return false;
    }

    return true;
  }

  static shift(List l) {
    if (l.length >= 1) {
      var first = l.first;
      l.removeAt(0);
      return first;
    }
    return null;
  }

  /// check if the string [str] is IP [version] 4 or 6
  ///
  /// * [version] is a String or an `int`.
  static bool isIP(String str, [/*<String | int>*/ version]) {
    version = version.toString();
    if (version == 'null') {
      return isIP(str, 4) || isIP(str, 6);
    } else if (version == '4') {
      if (!_ipv4Maybe.hasMatch(str)) {
        return false;
      }
      var parts = str.split('.');
      parts.sort((a, b) => int.parse(a) - int.parse(b));
      return int.parse(parts[3]) <= 255;
    }
    return version == '6' && _ipv6.hasMatch(str);
  }

  /// 检查字符串[str]是否为完全限定的域名（例如domain.com）
  static bool isFQDN(String str, {bool requireTld = true, bool allowUnderscores = false}) {
    var parts = str.split('.');
    if (requireTld) {
      var tld = parts.removeLast();
      if (parts.length == 0 || !new RegExp(r'^[a-z]{2,}$').hasMatch(tld)) {
        return false;
      }
    }

    for (var part in parts) {
      if (allowUnderscores) {
        if (part.contains('__')) {
          return false;
        }
      }
      if (!new RegExp(r'^[a-z\\u00a1-\\uffff0-9-]+$').hasMatch(part)) {
        return false;
      }
      if (part[0] == '-' || part[part.length - 1] == '-' || part.indexOf('---') >= 0) {
        return false;
      }
    }
    return true;
  }

  /*
  评论、分享、点赞数值显示规则：

  无则不显示数字

  小于1000直接显示

  小于10000，大于1000则末尾单位显示k；

  大于10000，则显示为w，采取末位舍去法保留小数点后一位，如：60400显示为6w，63500显示为6.3w
   */
  static String getNumber(int number) {
    if (number == 0 || number == null) {
      return 0.toString();
    }
    if (number < 10000) {
      if (number < 1000) {
        return number.toString();
      } else {
        String db = "${(number / 1000).toString()}";
        if (int.parse(db.substring(db.indexOf(".") + 1, db.indexOf(".") + 2)) != 0) {
          String doubleText = db.substring(0, db.indexOf(".") + 2);
          return doubleText + "k";
        } else {
          String intText = db.substring(0, db.indexOf("."));
          return intText + "k";
        }
      }
    } else {
      String db = "${(number / 10000).toString()}";
      if (int.parse(db.substring(db.indexOf(".") + 1, db.indexOf(".") + 2)) != 0) {
        String doubleText = db.substring(0, db.indexOf(".") + 2);
        return doubleText + "W";
      } else {
        String intText = db.substring(0, db.indexOf("."));
        return intText + "W";
      }
    }
  }

  /*
   overflow: TextOverflow.ellipsis,
   缺陷： 会将长字母、数字串整体显示省略
   现象： 分组-12333333333333333333333333，可能会显示成：分组-1…
   解决办法： 将每个字符串之间插入零宽空格
  */
  static String breakWord(String word) {
    if (word == null || word.isEmpty) {
      return word;
    }
    String breakWord = ' ';
    word.runes.forEach((element) {
      breakWord += String.fromCharCode(element);
      breakWord += '\u200B';
    });
    return breakWord;
  }
}
