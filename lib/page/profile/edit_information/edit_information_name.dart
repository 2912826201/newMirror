import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/string_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/Input_method_rules/pin_yin_text_edit_controller.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/custom_button.dart';
import 'package:mirror/widget/expression_team_delete_Formatter.dart';
import 'package:mirror/widget/precision_limit_Formatter.dart';

///编辑昵称
class EditInformationName extends StatefulWidget {
  String userName;
  String title;

  EditInformationName({this.userName, this.title});

  @override
  State<StatefulWidget> createState() {
    return _EditInformationNameState();
  }
}

class _EditInformationNameState extends State<EditInformationName> {
  int textLength = 0;
  String _EditText;
  int _reciprocal = 15;
  int beforeLength = 0;

  ///记录上次结果
  var lastInput = "";
  PinYinTextEditController controller = PinYinTextEditController();
  FocusNode _commentFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.userName != null) {
      _EditText =StringUtil.maxLength(widget.userName,15,isOmit: false);
      controller.text = _EditText;
      textLength = _EditText.length;
      _reciprocal += beforeLength - textLength;
      beforeLength = textLength;
      // 设置光标
      var setCursor = TextSelection(
        baseOffset: controller.text.length,
        extentOffset: controller.text.length,
      );
      controller.selection = setCursor;

      widget.userName = null;
    }

    ///controller监听
    controller.addListener(() {
      if (lastInput != controller.completeText) {
        lastInput = controller.completeText;
        ///通知onChanged
        setState(() {
          _EditText = lastInput;
          textLength = lastInput.length;
          _reciprocal += beforeLength - textLength;
          beforeLength = textLength;
        });
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = ScreenUtil.instance.screenWidthDp;
    double height = ScreenUtil.instance.height;
    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: CustomAppBar(
        backgroundColor: AppColor.white,
        leadingOnTap: () {
          _commentFocus.unfocus();
          Navigator.pop(context);
        },
        titleString: widget.title??"编辑昵称",
        actions: [
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(right: CustomAppBar.appBarIconPadding),
            child: CustomRedButton(
              "确定",
              CustomRedButton.buttonStateNormal,
              () {
                if (_EditText.isEmpty||_EditText.replaceAll(new RegExp(r"\s+"), "").length==0) {
                 ToastShow.show(msg: "昵称不能为空", context: context);
                  return;
                }
                _commentFocus.unfocus();
                Navigator.pop(this.context,_EditText);
              },
            ),
          ),
        ],
      ),
      body: Container(
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
              height: 17,
            ),
            Container(width: width, margin: EdgeInsets.only(top: 29), child: _inputWidget(width)),
            Container(
              margin: EdgeInsets.only(left: 16, right: 16),
              width: width,
              height: 0.5,
              color: AppColor.bgWhite.withOpacity(0.65),
            ),
            SizedBox(
              height: 12,
            ),
            _bottomText(width),
          ],
        ),
      ),
    );
  }

  //底部提示字数文字
  Widget _bottomText(double width) {
    return Container(
      width: width,
      padding: EdgeInsets.only(left: 16, right: 16),
      child: Row(
        children: [
          Text(
            "0-15个字符，起个好听的名字吧~",
            style: AppStyle.textPrimary3Regular14,
          ),
          Expanded(child: Container()),
          Text(
            "$_reciprocal",
            style: AppStyle.textPrimary3Regular14,
          )
        ],
      ),
    );
  }

  Widget _inputWidget(double width) {
    var putFiled = TextField(
      autofocus: true,
      maxLength: 15,
      /*maxLines: 1,*/
      focusNode: _commentFocus,
      controller: controller,
      cursorColor: AppColor.black,
      style: AppStyle.textRegular16,
      decoration: InputDecoration(
        counterText: '',
        hintText: "戳这里输入${widget.title==null?"昵称":widget.title.contains("群聊")?"名称":"昵称"}",
        hintStyle: TextStyle(fontSize: 16, color: AppColor.textHint),
        border: InputBorder.none,
      ),
      inputFormatters: [
        ExpressionTeamDeleteFormatter(maxLength: 15)
         ],
    );
    return Container(padding: EdgeInsets.only(left: 16, right: 16), child: putFiled);
  }
}
