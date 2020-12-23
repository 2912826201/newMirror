import 'package:flutter/cupertino.dart';
import 'package:mirror/util/toast_util.dart';

void JumpShareMessage(Map<String, dynamic> map, String chatType, String name,
    BuildContext context) {
  ToastShow.show(msg: "点击了$name", context: context);
}
