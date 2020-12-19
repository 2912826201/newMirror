import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:provider/provider.dart';

typedef VoidCallback = void Function(String content, BuildContext context);

Future openInputBottomSheet(
    {
      @required BuildContext context,
      @required VoidCallback voidCallback,
      String hintText,
    }) async {
  await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        FocusNode _commentFocus = FocusNode();
        return Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom), // !important
          child: Container(
            padding: EdgeInsets.only(top: 12, bottom: 12),
            child: UnconstrainedBox(
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: CommentInputBottomBar(
                  hintText:hintText,
                  voidCallback: voidCallback,
                  commentFocus: _commentFocus,
                ),
              ),
            ),
          ),
        );
      });
}

class CommentInputBottomBar extends StatefulWidget {
  CommentInputBottomBar({Key key, this.voidCallback,this.hintText,this.commentFocus}) : super(key: key);
  final VoidCallback voidCallback;
  String hintText;
  final FocusNode commentFocus;
  @override
  createState() {
    return CommentInputBottomBarState(voidCallback,hintText,commentFocus);
  }
}

class CommentInputBottomBarState extends State<CommentInputBottomBar> {
  CommentInputBottomBarState(this.voidCallback,this.hintText,this.commentFocus);
  final VoidCallback voidCallback;
  String hintText;
  final TextEditingController _textEditingController = TextEditingController();
  final FocusNode commentFocus;
  WidgetsBinding widgetsBinding;
  @override
  void initState() {
    super.initState();
    widgetsBinding=WidgetsBinding.instance;
    widgetsBinding.addPostFrameCallback((callback){
      FocusScope.of(context).requestFocus(commentFocus);
    });
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      child: ChangeNotifierProvider(
          create: (_) => CommentEnterNotifier(),
          builder: (context, _) {
            return Stack(
              children: [
                Container(
                  width: Platform.isIOS
                      ? ScreenUtil.instance.screenWidthDp - 32
                      : ScreenUtil.instance.screenWidthDp - 32 - 52 - 12,
                  margin: EdgeInsets.only(left: 16, right: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                    color: AppColor.bgWhite_65,
                  ),
                  child: Stack(
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(
                            maxHeight: 80.0,
                            minHeight: 16.0,
                            maxWidth: Platform.isIOS
                                ? ScreenUtil.instance.screenWidthDp - 32 - 32 - 64
                                : ScreenUtil.instance.screenWidthDp -
                                32 -
                                32 -
                                64 -
                                52 -
                                12),
                        child: TextField(
                          controller: _textEditingController,
                          focusNode: commentFocus,
                          // 多行展示
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          //不限制行数
                          // 光标颜色
                          cursorColor: Color.fromRGBO(253, 137, 140, 1),
                          scrollPadding: EdgeInsets.all(0),
                          style: TextStyle(
                              fontSize: 16, color: AppColor.textPrimary1),
                          //内容改变的回调
                          onChanged: (text) {
                            // 存入最新的值
                            context
                                .read<CommentEnterNotifier>()
                                .changeCallback(text);
                          },
                          // 装饰器修改外观
                          decoration: InputDecoration(
                            // 去除下滑线
                            border: InputBorder.none,
                            // 提示文本
                            hintText: hintText,
                            // 提示文本样式
                            hintStyle:
                            TextStyle(fontSize: 14, color: AppColor.textHint),
                            // 设置为true,contentPadding才会生效，TextField会有默认高度。
                            isCollapsed: true,
                            contentPadding:
                            EdgeInsets.only(top: 8, bottom: 8, left: 16),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 6,
                        right: 44,
                        child: Container(
                          width: 24,
                          height: 24,
                          color: Colors.redAccent,
                        ),
                      ),
                      Positioned(
                          right: 16,
                          bottom: 6,
                          child: Container(
                            width: 24,
                            height: 24,
                            color: Colors.redAccent,
                          )),
                      // MyIconBtn()
                    ],
                  ),
                ),
                Positioned(
                    right: 16,
                    bottom: 2,
                    child: Offstage(
                      offstage: Platform.isIOS,
                      child: GestureDetector(
                          onTap: () {
                            voidCallback(_textEditingController.text, context);
                            Navigator.of(context).pop(1);
                          },
                          child: IgnorePointer(
                            // 监听输入框的值==""使外层点击不生效。非""手势生效。
                            ignoring: context
                                .watch<CommentEnterNotifier>()
                                .textFieldStr ==
                                "",
                            child: Container(
                              // padding: EdgeInsets.only(top: 6,left: 12,bottom: 6,right: 12),
                              height: 32,
                              width: 52,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(16)),
                                // 监听输入框的值动态改变样式
                                color: context
                                            .watch<CommentEnterNotifier>()
                                            .textFieldStr !=
                                        ""
                                    ? AppColor.textPrimary1
                                    : AppColor.textSecondary,
                              ),
                              child: Center(
                                    child: Text(
                                      "发送",
                                      style: TextStyle(
                                          color: AppColor.white, fontSize: 14),
                                    ),
                                  )),
                            )),
                      ))
                ],
              );
            }));
  }
}

// 输入框输入文字的监听
class CommentEnterNotifier extends ChangeNotifier {
  CommentEnterNotifier({this.textFieldStr = ""});

  String textFieldStr = "";

  changeCallback(String str) {
    this.textFieldStr = str;
    notifyListeners();
  }
}
