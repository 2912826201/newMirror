import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mirror/api/activity/activity_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/user_model.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/dialog.dart';
import 'package:mirror/widget/icon.dart';
import 'package:mirror/widget/input_formatter/expression_team_delete_formatter.dart';
import 'package:mirror/widget/input_formatter/precision_limit_formatter.dart';
import 'package:mirror/widget/input_method_rules/pin_yin_text_edit_controller.dart';
import 'package:mirror/widget/user_avatar_image.dart';

///移除活动成员界面
class RemoveUserPage extends StatefulWidget {
  final int activityId;
  final List<UserModel> userList;

  RemoveUserPage({Key key, @required this.activityId, @required this.userList}) : super(key: key);

  @override
  _RemoveUserPageState createState() => _RemoveUserPageState();
}

class _RemoveUserPageState extends State<RemoveUserPage> {
  final PinYinTextEditController _inputController = PinYinTextEditController();
  final PinYinTextEditController _reasonController = PinYinTextEditController();
  final FocusNode _focusNode = FocusNode();

  List<int> selectUserList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleString: "踢出用户",
      ),
      body: Container(
        color: AppColor.mainBlack,
        padding: EdgeInsets.only(bottom: ScreenUtil.instance.bottomBarHeight),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: widget.userList.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _getEdit();
                  }
                  if (_inputController.text == null ||
                      _inputController.text.length < 1 ||
                      widget.userList[index - 1].nickName.contains(_inputController.text)) {
                    return item(widget.userList[index - 1], index - 1, () {
                      if (selectUserList.contains(index - 1)) {
                        selectUserList.remove(index - 1);
                        setState(() {});
                      } else {
                        if (selectUserList.length > 0) {
                          ToastShow.show(msg: "每次删除只能选择一个", context: context);
                        } else {
                          selectUserList.add(index - 1);
                          setState(() {});
                        }
                      }
                    });
                  } else {
                    return Container();
                  }
                },
              ),
            ),
            if (selectUserList.length > 0)
              _getBottomBtn("确定", AppColor.white.withOpacity(0.1), AppStyle.whiteRegular16, () {
                _showDialog();
              }),
            if (selectUserList.length > 0) SizedBox(height: 12),
            if (selectUserList.length > 0)
              _getBottomBtn("取消", AppColor.mainYellow, AppStyle.textRegular16, () {
                setState(() {
                  selectUserList.clear();
                });
              }),
          ],
        ),
      ),
    );
  }

  Widget item(UserModel model, int index, Function() onTap) {
    if (model.uid == Application.profile.uid) {
      return Opacity(
        opacity: 0.3,
        child: _getItem(model, index),
      );
    } else {
      return Material(
          color: AppColor.transparent,
          child: new InkWell(
            child: _getItem(model, index),
            splashColor: AppColor.layoutBgGrey,
            onTap: onTap,
          ));
    }
  }

  Widget _getItem(UserModel model, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      margin: const EdgeInsets.symmetric(vertical: 5),
      color: AppColor.transparent,
      height: 48,
      child: Row(
        children: [
          UserAvatarImageUtil.init().getUserImageWidget(model.avatarUri, model.uid.toString(), 32),
          SizedBox(width: 12),
          Expanded(child: Text(model.nickName, style: AppStyle.whiteRegular16)),
          getSingleChoiceUi(index),
        ],
      ),
    );
  }

  //单选按钮
  Widget getSingleChoiceUi(int index) {
    return Container(
      margin: const EdgeInsets.only(right: 14.5),
      width: 24,
      height: 24,
      child: AppIcon.getAppIcon(
          selectUserList.contains(index) ? AppIcon.selection_selected : AppIcon.selection_not_selected, 24),
    );
  }

  Widget _getBottomBtn(String title, Color color, TextStyle style, Function() onTap) {
    return GestureDetector(
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
        ),
        height: 44,
        width: ScreenUtil.instance.width - 32,
        margin: EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        child: Text(title, style: style, textAlign: TextAlign.center),
      ),
      onTap: onTap,
    );
  }

  Widget _getEdit() {
    return Container(
      height: 32,
      margin: const EdgeInsets.only(top: 20, left: 16, right: 16),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColor.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: TextField(
        style: AppStyle.whiteRegular16,
        controller: _inputController,
        focusNode: _focusNode,
        textInputAction: TextInputAction.search,
        onChanged: (value) {
          setState(() {});
        },
        decoration: InputDecoration(
            isCollapsed: true,
            contentPadding: EdgeInsets.only(top: 0, bottom: 0, left: 6),
            hintText: '搜索用户',
            hintStyle: AppStyle.text1Regular16,
            border: InputBorder.none),
        inputFormatters: [
          // WhitelistingTextInputFormatter(RegExp("[a-zA-Z]|[\u4e00-\u9fa5]|[0-9]")), //只能输入汉字或者字母或数字
          LengthLimitingTextInputFormatter(16),
        ],
      ),
    );
  }

  //移除的说明原因的dialog
  Widget _reasonEditWidget() {
    return Container(
      height: 104,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      decoration:
          BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(4)), color: AppColor.white.withOpacity(0.1)),
      child: TextField(
        controller: _reasonController,
        cursorColor: AppColor.white,
        style: AppStyle.whiteRegular12,
        maxLines: null,
        maxLength: 50,
        decoration: InputDecoration(
          isDense: true,
          counterText: '',
          hintText: "请输入理由...",
          hintStyle: AppStyle.text2Regular12,
          border: InputBorder.none,
        ),
        inputFormatters: [ExpressionTeamDeleteFormatter(maxLength: 50)],
      ),
    );
  }

  bool isRemoveMember = false;

  //移除的说明原因的dialog
  _showDialog() {
    if (isRemoveMember) {
      ToastShow.show(msg: "正在操作中", context: context);
      return;
    }
    showAppDialog(context,
        title: "请说明将他踢出小队的原因",
        customizeWidget: _reasonEditWidget(),
        cancel: AppDialogButton("取消", () {
          _reasonController.text = "";
          return true;
        }),
        confirm: AppDialogButton("确定", () {
          _removeMember();
          return true;
        }));
  }

  _removeMember() async {
    if (isRemoveMember) {
      return;
    }

    isRemoveMember = true;

    ToastShow.show(msg: "正在操作", context: context);

    bool isSuccess =
        await removeMember(widget.activityId, widget.userList[selectUserList.first].uid, _reasonController.text);
    _reasonController.text = "";

    ToastShow.show(msg: isSuccess ? "移除成功" : "移除失败", context: context);

    selectUserList.clear();

    setState(() {});
  }
}
