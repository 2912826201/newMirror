import 'package:flutter/material.dart';

//信息界面-输入聊天信息的界面
class MessageInputBody extends StatelessWidget {
  MessageInputBody({
    this.child,
    this.color = const Color(0xfff4f4f4),
    this.decoration,
    this.onTap,
  });

  final Widget child;
  final Color color;
  final Decoration decoration;
  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    return decoration != null
        ? new Container(
            decoration: decoration,
            height: double.infinity,
            width: double.infinity,
            child: new GestureDetector(
              child: child,
              behavior: HitTestBehavior.translucent,
              onTap: () {
                FocusScope.of(context).requestFocus(new FocusNode());
                if (onTap != null) {
                  onTap();
                }
              },
            ),
          )
        : new Container(
      color: color,
      height: double.infinity,
      width: double.infinity,
      child: new GestureDetector(
        child: child,
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
          if (onTap != null) {
            onTap();
          }
        },
      ),
    );
  }

}
