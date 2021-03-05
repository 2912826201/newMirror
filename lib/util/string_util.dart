import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:mirror/constant/constants.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/media_file_model.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/text_util.dart';

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
    if (number == null||number == 0 || number<0) {
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
  /** 全局动态和请求数据比较
   * 比较两数组 取出不同的，
   * array1 数组一
   * array2 数组二
   * **/
  static List<HomeFeedModel>  followModelFilterDeta(List<HomeFeedModel> array1, List<HomeFeedModel> array2) {
    List<HomeFeedModel> result = [];
    for (var i = 0; i < array1.length; i++) {
      var obj = array1[i].id;
      var isExist = false;
      for (var j = 0; j < array2.length; j++) {
        var aj = array2[j].id;
        if (obj == aj) {
          isExist = true;
          continue;
        }
      }
      if (!isExist) {
        result.add(array1[i]);
      }
    }
    print("result${result.toString()}");
    return result;
  }

  //计算每一个动态流的item的高度区间
  static List<HomeFeedModel> getFeedItemHeight(double initHeight, List<HomeFeedModel>  models) {
    double itemHeight = initHeight;
    for(int i = 0; i < models.length; i ++) {
      HomeFeedModel v =  models[i];
      v.headOffset = itemHeight;
      // 头部
      itemHeight += 62;
      if (v.selectedMediaFiles == null) {
        // 图片
        if (v.picUrls.isNotEmpty) {
          if (v.picUrls.first.height == 0) {
            itemHeight += ScreenUtil.instance.width;
          } else {
            itemHeight += (ScreenUtil.instance.width / v.picUrls[0].width) * v.picUrls[0].height;
          }
        }
        // 视频
        if (v.videos.isNotEmpty) {
          itemHeight += calculateHeight(feedModel: v);
        }
      } else {
        // 图片
        if(v.selectedMediaFiles.type == mediaTypeKeyImage ) {
          if (v.selectedMediaFiles.list.first.sizeInfo.height == 0) {
            itemHeight += ScreenUtil.instance.width;
          } else {
            itemHeight += (ScreenUtil.instance.width / v.selectedMediaFiles.list.first.sizeInfo.width) * v.selectedMediaFiles.list.first.sizeInfo.height;
          }
        }
        // 视频
        if (v.selectedMediaFiles.type == mediaTypeKeyVideo) {
          itemHeight += calculateHeight(selectedMediaFiles: v.selectedMediaFiles);
        }
      }
      // 转发评论点赞
      itemHeight += 48;

      //地址和课程
      if (v.address != null || v.courseDto != null) {
        itemHeight += 7;
        itemHeight += getTextSize("123", TextStyle(fontSize: 12), 1).height;
      }

      //文本
      if (v.content.length > 0) {
        itemHeight += 12;
        itemHeight += getTextSize(v.content, TextStyle(fontSize: 14), 2, ScreenUtil.instance.width - 32).height;
      }

      //评论文本
      if (v.comments != null && v.comments.length != 0) {
        itemHeight += 8;
        itemHeight += 6;
        itemHeight += getTextSize("共0条评论", AppStyle.textHintRegular12, 1).height;
        itemHeight += getTextSize("第一条评论", AppStyle.textHintRegular13, 1).height;
        if (v.comments.length > 1) {
          itemHeight += 8;
          itemHeight += getTextSize("第二条评论", AppStyle.textHintRegular13, 1).height;
        }
      }

      // 输入框
      itemHeight += 48;

      //分割块
      itemHeight += 18;
      v.bottomOffset = itemHeight - 1;
      print("v.headOffset::::${v.headOffset}");
      print("v.bottomOffset::::${v.bottomOffset}");
    }
    return models;
  }
  // 计算视屏的高度
  static calculateHeight({HomeFeedModel feedModel, SelectedMediaFiles selectedMediaFiles}) {
    double containerWidth = ScreenUtil.instance.width;
    double containerHeight;
    double videoRatio = 0.0;
    if(selectedMediaFiles != null) {
      videoRatio = selectedMediaFiles.list.first.sizeInfo.width / selectedMediaFiles.list.first.sizeInfo.height;
    }
    if(feedModel != null) {
      videoRatio = feedModel.videos.first.width / feedModel.videos.first.height;
    }
    double containerRatio;

    //如果有裁剪的比例 则直接用该比例

    if (feedModel != null && feedModel.videos.first.videoCroppedRatio != null) {
      containerRatio = feedModel.videos.first.videoCroppedRatio;
    } else if (selectedMediaFiles != null && selectedMediaFiles.list.first.sizeInfo.videoCroppedRatio != null) {
      containerRatio = selectedMediaFiles.list.first.sizeInfo.videoCroppedRatio;
    } else {
      if (videoRatio < minMediaRatio) {
        containerRatio = minMediaRatio;
      } else if (videoRatio > maxMediaRatio) {
        containerRatio = maxMediaRatio;
      } else {
        containerRatio = videoRatio;
      }
    }
    containerHeight = containerWidth / containerRatio;
    return containerHeight;
  }
}
