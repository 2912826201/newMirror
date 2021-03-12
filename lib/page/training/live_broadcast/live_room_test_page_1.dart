

import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:text_span_field/text_span_field.dart';


class LiveRoomTestPageDialog extends StatefulWidget {
  @override
  _LiveRoomTestPageDialogState createState() => _LiveRoomTestPageDialogState();
}

class _LiveRoomTestPageDialogState extends State<LiveRoomTestPageDialog> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: ScreenUtil.instance.height*0.25,
          color: Colors.green.withOpacity(0.25),
          alignment: Alignment.bottomCenter,
          child: getEditUi(),
        ),
      ),
    );
  }



  Widget getEditUi(){
    return Container(
      height: 32,
      margin: const EdgeInsets.only(bottom: 16,left: 32,right: 32),
      color: AppColor.bgWhite,
      child: TextSpanField(
        // 多行展示
        keyboardType: TextInputType.multiline,
        //不限制行数
        maxLines: null,
        enableInteractiveSelection: true,
        // 光标颜色
        cursorColor: Color.fromRGBO(253, 137, 140, 1),
        scrollPadding: EdgeInsets.all(0),
        style: TextStyle(fontSize: 16, color: AppColor.textPrimary1),
        //内容改变的回调
        onChanged: (text) {
        },
        onSubmitted: (text) {
        },
        onTap: () {
        },
        // 装饰器修改外观
        decoration: InputDecoration(
          // 去除下滑线
          border: InputBorder.none,
          // 提示文本
          hintText: "hintText",
          // 提示文本样式
          hintStyle: TextStyle(fontSize: 14, color: AppColor.textHint),
          // 设置为true,contentPadding才会生效，TextField会有默认高度。
          isCollapsed: true,
          contentPadding: EdgeInsets.only(top: 8, bottom: 8, left: 16),
        ),

        textInputAction: TextInputAction.send,
      ),
    );
  }





}

class SimpleRoute extends PageRoute {
  SimpleRoute({
    @required this.name,
    @required this.title,
    @required this.builder,
  }) : super(
    settings: RouteSettings(name: name),
  );

  final String title;
  final String name;
  final WidgetBuilder builder;

  @override
  String get barrierLabel => null;

  @override
  bool get opaque => false;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => Duration(milliseconds: 0);

  @override
  Widget buildPage(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      ) {
    return Title(
      title: title,
      color: Theme.of(context).primaryColor,
      child: builder(context),
    );
  }

  /// 页面切换动画
  @override
  Widget buildTransitions(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
      ) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }

  @override
  Color get barrierColor => null;
}
