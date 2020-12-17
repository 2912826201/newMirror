import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/page/home/sub_page/recommend_page.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:provider/provider.dart';

// 监听键盘高度打开的输入框
class CommentInputBar extends StatelessWidget {
  TextEditingController controller = TextEditingController();

  postComments(String text) async {
    print("评论类型￥${Application.commentTypes}");
    CommentDtoModel comModel;
    if (Application.commentTypes == CommentTypes.commentMainCom) {
      print("主评论${Application.commentDtoModel.id}");
      Map<String, dynamic> model =
          await publish(targetId: Application.commentDtoModel.id, targetType: 2, content: text);
      if (model != null) {
        comModel = (CommentDtoModel.fromJson(model));
        Application.commentDtoModel.initCount += 1;
      }
      print("评论评论返回$model");
      Application.commentDtoModel.replys.insert(0, comModel);
    } else if (Application.commentTypes == CommentTypes.commentFeed) {
      Map<String, dynamic> model = await publish(targetId: Application.feedModel.id, targetType: 0, content: text);
      // CommentDtoModel
      if (model != null) {
        comModel = (CommentDtoModel.fromJson(model));
        Application.feedModel.commentCount += 1;
      }
      print("发布接口返回$model");
      Application.feedModel.comments.insert(0, comModel);
    } else {
      Map<String, dynamic> model = await publish(
          targetId: Application.commentDtoModel.id,
          targetType: 2,
          content: text,
          replyId: Application.replysModel.uid,
          replyCommentId: Application.replysModel.id);
      if (model != null) {
        comModel = (CommentDtoModel.fromJson(model));
        Application.commentDtoModel.initCount += 1;
      }
      print("子评论返回$model");
      Application.commentDtoModel.replys.insert(0, comModel);
    }
    controller.clear();
    commentFocus.unfocus(); // 失去焦点,
    Application.isArouse = false;
  }

  @override
  Widget build(BuildContext context) {
    // ChangeNotifierProvider
    return ChangeNotifierProvider(
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
                              : ScreenUtil.instance.screenWidthDp - 32 - 32 - 64 - 52 - 12),
                      child: TextField(
                        controller: controller,
                        // 管理焦点
                        focusNode: commentFocus,
                        // 多行展示
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        //不限制行数
                        // 光标颜色
                        cursorColor: Color.fromRGBO(253, 137, 140, 1),
                        scrollPadding: EdgeInsets.all(0),
                        style: TextStyle(fontSize: 16, color: AppColor.textPrimary1),
                        //内容改变的回调
                        onChanged: (text) {
                          // 存入最新的值
                          context.read<CommentEnterNotifier>().changeCallback(text);
                        },
                        // 装饰器修改外观
                        decoration: InputDecoration(
                          // 去除下滑线
                          border: InputBorder.none,
                          // 提示文本
                          hintText: Application.hintText,
                          // 提示文本样式
                          hintStyle: TextStyle(fontSize: 14, color: AppColor.textHint),
                          // 设置为true,contentPadding才会生效，TextField会有默认高度。
                          isCollapsed: true,
                          contentPadding: EdgeInsets.only(top: 8, bottom: 8, left: 16),
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
                        ))
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
                          // 发布
                          postComments(context.read<CommentEnterNotifier>().textFieldStr);
                        },
                        child: IgnorePointer(
                          // 监听输入框的值==""使外层点击不生效。非""手势生效。
                          ignoring: context.watch<CommentEnterNotifier>().textFieldStr == "",
                          child: Container(
                              // padding: EdgeInsets.only(top: 6,left: 12,bottom: 6,right: 12),
                              height: 32,
                              width: 52,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(16)),
                                // 监听输入框的值动态改变样式
                                color: context.watch<CommentEnterNotifier>().textFieldStr != ""
                                    ? AppColor.textPrimary1
                                    : AppColor.textSecondary,
                              ),
                              child: Center(
                                child: Text(
                                  "发送",
                                  style: TextStyle(color: AppColor.white, fontSize: 14),
                                ),
                              )),
                        )),
                  ))
            ],
          );
        });
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
