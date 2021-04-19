import 'package:flutter/material.dart';
/**
 * description
 *
 * @date 2020/11/30
 * @author:TaoSi
 */
import 'package:toast/toast.dart';

class ToastShow {
  static show({ @required String msg, @required context,int gravity = 0,int duration=1} ){
    Toast.show(
        msg, //必填
        context, //必填
        duration: duration,
        gravity: gravity,

            // .BOTTOM,
        backgroundRadius: 16);//规范圆角16
  }
}
