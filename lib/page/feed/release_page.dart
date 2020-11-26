import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/custom_button.dart';

class ReleasePage extends StatelessWidget {
  FocusNode feedFocus = FocusNode();
  @override
  Widget build(BuildContext context) {
    // 头部布局
    headerWidget() {
      return Positioned(
          top: ScreenUtil.instance.statusBarHeight,
          child: Container(
            width: ScreenUtil.instance.screenWidthDp,
            height: 44,
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(width: 0.5, color: Color(0xffe5e5e5))),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.only(left: 16),
                  child: MyIconBtn(
                    width: 28,
                    height: 28,
                    iconSting: "images/resource/2.0x/shut_down@2x.png",
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                  ),
                ),
                Spacer(),
                GestureDetector(
                    onTap: () {
                      // 读取输入框最新的值
                      // print(context.read<CommentEnterNotifier>().textFieldStr);
                      print("点击生效");
                    },
                    child: IgnorePointer(
                      // 监听输入框的值==""使外层点击不生效。非""手势生效。
                      ignoring: false,
                      child: Container(
                          // padding: EdgeInsets.only(top: 6,left: 12,bottom: 6,right: 12),
                          height: 28,
                          width: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(14)),
                            // 监听输入框的值动态改变样式
                            color: AppColor.mainRed,
                          ),
                          child: Center(
                            child: Text(
                              "发布",
                              style: TextStyle(color: AppColor.white, fontSize: 14, decoration: TextDecoration.none),
                            ),
                          )),
                    )),
                SizedBox(
                  width: 16,
                )
              ],
            ),
          ));
    }
   // 动态输入框
    feedInput() {
      return Container(
        height: 143,
        child:TextField(
          // 管理焦点
          // focusNode:FocusNode(),
          // 多行展示
          keyboardType: TextInputType.multiline,
          // 不限制行数
          maxLines: null,
          // 光标颜色
          cursorColor: Color.fromRGBO(253, 137, 140, 1),
          // 装饰器修改外观
          decoration: InputDecoration(
            // 去除下滑线
            border: InputBorder.none,
            // 提示文本
            hintText: "分享此刻",
            // 提示文本样式
            hintStyle: TextStyle(fontSize: 14, color: AppColor.textHint),
            // 设置为true,contentPadding才会生效，TextField会有默认高度。
            isCollapsed: true,
            contentPadding: EdgeInsets.only(top: 14, bottom: 14, left: 16, right: 16),
          ),
        ),
      );

    }
    // return
    return Container(
      color: AppColor.white,
      child: Stack(
        children: [
          // 头部布局
          headerWidget(),
          // 中间主视图
          CustomScrollView(
            slivers: [
              // 输入框
              SliverToBoxAdapter(
                  // child:feedInput(),
              ),
              SliverToBoxAdapter(),
              // SliverList(delegate: null)
            ],
          )
        ],
      ),
    );
  }
}
