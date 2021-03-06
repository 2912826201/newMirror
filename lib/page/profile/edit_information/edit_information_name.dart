import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/string_util.dart';
import 'package:mirror/widget/Input_method_rules/pin_yin_text_edit_controller.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/custom_button.dart';
import 'package:mirror/widget/input_formatter/expression_team_delete_formatter.dart';

///编辑昵称
class EditInformationName extends StatefulWidget {
  String userName;
  String title;

  EditInformationName({this.userName, this.title});

  @override
  _EditInformationNameState createState() => _EditInformationNameState();
}

class _EditInformationNameState extends State<EditInformationName> {
  int textLength = 0;
  String _editText;
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
      _editText = StringUtil.maxLength(widget.userName, 15, isOmit: false);
      controller.text = _editText;
      textLength = _editText.length;
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
          _editText = lastInput;
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
      backgroundColor: AppColor.mainBlack,
      appBar: CustomAppBar(
        backgroundColor: AppColor.mainBlack,
        leadingOnTap: () {
          _commentFocus.unfocus();
          Navigator.pop(context);
        },
        titleString: widget.title ?? "编辑昵称",
        actions: [
          Container(
            padding: const EdgeInsets.only(right: CustomAppBar.appBarIconPadding - CustomAppBar.appBarHorizontalPadding),
            child: CustomYellowButton(
              "确定",
              CustomYellowButton.buttonStateNormal,
              () {
                _commentFocus.unfocus();
                if (_editText.isEmpty) {
                  return;
                }
                Navigator.pop(this.context, _editText);
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
            SizedBox(
              height: 17,
            ),
            Container(width: width, margin: EdgeInsets.only(top: 29), child: _inputWidget(width)),
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
            style: AppStyle.text1Regular14,
          ),
          Spacer(),
          Text(
            "$_reciprocal",
            style: AppStyle.text1Regular14,
          )
        ],
      ),
    );
  }

  Widget _inputWidget(double width) {
    var putFiled = TextField(
      autofocus: true,
      maxLength: 15,
      maxLines: 1,
      focusNode: _commentFocus,
      controller: controller,
      cursorColor: AppColor.textWhite60,
      style: AppStyle.whiteRegular16,
      decoration: InputDecoration(
          counterText: '',
          hintText: "戳这里输入${widget.title == null ? "昵称" : widget.title.contains("群聊") ? "名称" : "昵称"}",
          hintStyle: AppStyle.text1Regular14,
          border: InputBorder.none,
         ),
      inputFormatters: [ExpressionTeamDeleteFormatter(maxLength: 15, needFilter: true)],
    );
    return Container(padding: EdgeInsets.only(left: 16, right: 16), child: putFiled);
  }
}
