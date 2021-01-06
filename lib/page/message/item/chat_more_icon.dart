import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mirror/util/string_util.dart';

import 'commom_button.dart';

//发送和图片按钮--消息界面底部
class ChatMoreIcon extends StatelessWidget {
  final bool isMore;
  final bool isComMomButton;
  final VoidCallback onTap;
  final GestureTapCallback moreTap;

  ChatMoreIcon({
    this.isMore = false,
    this.isComMomButton = false,
    this.onTap,
    this.moreTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isComMomButton) {
      return ComMomButton(
        text: '发送',
        height: 25,
        style: TextStyle(color: Colors.white),
        width: 50.0,
        margin: EdgeInsets.only(left: 6.0, right: 16),
        radius: 4.0,
        onTap: () {
          if (onTap != null) {
            onTap();
          }
        },
      );
    } else {
      return InkWell(
        child: new Container(
          width: 23,
          margin: EdgeInsets.only(left: 6.0, right: 16),
          child: Icon(
            Icons.photo_size_select_actual_outlined,
            size: 25,
          ),
        ),
        onTap: () {
          if (moreTap != null) {
            moreTap();
          }
        },
      );
    }
  }
}
