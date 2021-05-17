import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/string_util.dart';
import 'package:mirror/util/text_util.dart';
import 'package:mirror/widget/Input_method_rules/pin_yin_text_edit_controller.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/custom_button.dart';
import 'package:mirror/widget/input_formatter/expression_team_delete_formatter.dart';

class EditInformationIntroduction extends StatefulWidget {
  final String introduction;

  EditInformationIntroduction({this.introduction});

  @override
  _IntroductionState createState() {
    return _IntroductionState();
  }
}

class _IntroductionState extends State<EditInformationIntroduction> {
  //同步的输入框和上个界面带过来的简介
  String editText;

  //底部的提示int
  int textLength = 0;
  double textHeight;

  ///记录上次结果
  var lastInput = "";
  PinYinTextEditController controller = PinYinTextEditController();
  FocusNode _commentFocus = FocusNode();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    //先同步简介
    if (widget.introduction == null || widget.introduction == "去编辑") {
      editText = "";
    } else {
      editText = widget.introduction;
      textLength = widget.introduction.length;
      controller.text = editText;
      // 设置光标
      var setCursor = TextSelection(
        baseOffset: controller.text.length,
        extentOffset: controller.text.length,
      );
      controller.selection = setCursor;
    }
    controller.addListener(() {
      if (lastInput != controller.completeText) {
        lastInput = controller.completeText;

        ///通知onChanged
        setState(() {
          textLength = lastInput.length;
          editText = lastInput;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = ScreenUtil.instance.screenWidthDp;
    double height = ScreenUtil.instance.height;
    return Scaffold(
      appBar: CustomAppBar(
          backgroundColor: AppColor.white,
          leadingOnTap: () {
            _commentFocus.unfocus();
            Navigator.pop(context, widget.introduction);
          },
          titleString: "编辑简介",
          actions: [
            Container(
              padding:
                  const EdgeInsets.only(right: CustomAppBar.appBarIconPadding - CustomAppBar.appBarHorizontalPadding),
              child: CustomRedButton(
                "确定",
                CustomRedButton.buttonStateNormal,
                () {
                  _commentFocus.unfocus();
                  if (editText.length == 0) {
                    Navigator.pop(this.context, "");
                  } else {
                    print('---------------------${editText.replaceAll(new RegExp(r"\s+"), "").length}');
                    if (editText.replaceAll(new RegExp(r"\s+"), "").length != 0) {
                      Navigator.pop(this.context, editText.trim());
                    } else {
                      Navigator.pop(context, "");
                    }
                  }
                },
              ),
            ),
          ]),
      body: Container(
        color: AppColor.white,
        height: height - ScreenUtil.instance.statusBarHeight,
        width: width,
        child: Column(
          children: [
            Container(
              width: width,
              height: 0.5,
              color: AppColor.bgWhite.withOpacity(0.65),
            ),
            SizedBox(
              height: 21,
            ),
            _inputBox(width, height),
          ],
        ),
      ),
    );
  }

  //输入框
  Widget _inputBox(double width, double height) {
    return Container(
      height: 148,
      width: width,
      margin: EdgeInsets.only(left: 16, right: 16),
      padding: EdgeInsets.only(left: 16, right: 16, top: 8),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8)), border: Border.all(width: 0.5, color: AppColor.bgWhite)),
      child: Column(
        children: [
          TextField(
            focusNode: _commentFocus,
            autofocus: true,
            maxLength: 30,
            maxLines: 5,
            cursorColor: AppColor.black,
            style: AppStyle.textRegular16,
            //初始化值，设置光标始终在最后
            controller: controller,
            decoration: InputDecoration(
              counterText: '',
              hintText: "有意思的简介会吸引更多关注~",
              hintStyle: TextStyle(fontSize: 16, color: AppColor.textHint),
              border: InputBorder.none,
            ),
            inputFormatters: [ExpressionTeamDeleteFormatter(maxLength: 30,needFilter: true)],
          ),
          Container(
            alignment: Alignment.bottomRight,
            child: Text(
              "$textLength/30",
              style: AppStyle.textHintRegular12,
            ),
          )
        ],
      ),
    );
  }
}
