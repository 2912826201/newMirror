import 'package:flutter/services.dart';

class CheckPhoneSystemUtil {
  static final String _badgerChannel = "com.aimymusic.mirror/phone_system";

  static MethodChannel _channel;

  static CheckPhoneSystemUtil _util;

  //系统平台 0-android 1-ios
  static int platform;

  //ios
  static const String rom_ios = "ios";

  //android
  static const String rom_android = "android";

  //小米
  static const String rom_xiaomi = "xiaomi";

  //索尼
  static const String rom_sony = "sony";

  //三星
  static const String rom_samsung = "samsung";
  static const String rom_lg = "lg";

  //htc
  static const String rom_htc = "htc";

  //oppo
  static const String rom_oppo = "OPPO";

  //乐视
  static const String rom_lemobile = "LeMobile";
  static const String rom_letv = "letv";

  //vivo
  static const String rom_vivo = "vivo";

  //华为
  static const String rom_huawei1 = "HUAWEI";
  static const String rom_huawei2 = "Huawei";

  //华为-nova
  static const String rom_nova = "nova";

  //荣耀
  static const String rom_honor = "HONOR";

  //魅族
  static const String rom_meizu = "Meizu";

  //一加
  static const String rom_oneplus = "OnePlus";

  //三星
  static const String rom_smartisan = "smartisan";

  //联想
  static const String rom_lenovo = "lenovo";

  //360
  static const String rom_qiku = "QIKU";

  //其他类型
  static const String rom_other = "other";

  static CheckPhoneSystemUtil init() {
    if (_util == null) {
      _util = CheckPhoneSystemUtil();
    }
    if (_channel == null) {
      _channel = MethodChannel(_badgerChannel);
    }
    return _util;
  }

  //判断是不是ios手机
  //系统平台 0-android 1-ios
  Future<bool> isIos() async {
    return platform == 0;
  }

  //判断是不是android手机
  //系统平台 0-android 1-ios
  Future<bool> isAndroid() async {
    return platform == 0;
  }

  //判断是不是小米手机
  Future<bool> isMiui() async {
    return await _check(rom_xiaomi);
  }

  //判断是不是华为手机-统称
  Future<bool> isHuawei() async {
    return await _check(rom_huawei1) || await _check(rom_huawei2) || await _check(rom_nova) || await _check(rom_honor);
  }

  //判断是不是华为手机
  Future<bool> isEmui() async {
    return await _check(rom_huawei1) || await _check(rom_huawei2);
  }

  //判断是不是华为nova手机
  Future<bool> isNova() async {
    return await _check(rom_nova);
  }

  //判断是不是荣耀手机
  Future<bool> isHonor() async {
    return await _check(rom_honor);
  }

  //判断是不是魅族手机
  Future<bool> isFlyme() async {
    return await _check(rom_meizu);
  }

  //判断是不是oppo手机
  Future<bool> isOppo() async {
    return await _check(rom_oppo);
  }

  //判断是不是锤子手机
  Future<bool> isSmartisan() async {
    return await _check(rom_smartisan);
  }

  //判断是不是vivo手机
  Future<bool> isVivo() async {
    return await _check(rom_vivo);
  }

  //判断是不是360手机
  Future<bool> is360() async {
    return await _check(rom_qiku) || await _check("360");
  }

  //判断是不是索尼手机
  Future<bool> isSony() async {
    return await _check(rom_sony);
  }

  //判断是不是三星手机
  Future<bool> isSamsung() async {
    return await _check(rom_samsung) || await _check(rom_lg);
  }

  //判断是不是htc手机
  Future<bool> isHtc() async {
    return await _check(rom_htc);
  }

  //判断是不是乐视手机
  Future<bool> isLeMobile() async {
    return await _check(rom_lemobile) || await _check(rom_letv);
  }

  //判断是不是一加手机
  Future<bool> isOneplus() async {
    return await _check(rom_oneplus);
  }

  //判断是不是联想手机
  Future<bool> isLenovo() async {
    return await _check(rom_lenovo);
  }

  //获取手机是什么系统
  Future<String> getPhoneSystem() async {
    String phoneSystem;
    if (platform == 1) {
      phoneSystem = rom_ios;
    } else if (platform == 0) {
      phoneSystem = await _channel.invokeMethod('getPhoneSystem');
    } else {
      phoneSystem = rom_other;
    }
    return phoneSystem;
  }

  //判断手机系统厂商
  Future<bool> _check(String rom) async {
    if (rom == null || !(rom is String)) {
      return false;
    }
    String phoneSystem = await getPhoneSystem();
    if (phoneSystem == null || !(phoneSystem is String)) {
      return false;
    }
    return phoneSystem.toLowerCase() == rom.toLowerCase();
  }
}
