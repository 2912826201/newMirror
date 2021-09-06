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
import 'package:mirror/widget/custom_button.dart';
import 'package:mirror/widget/dialog.dart';
import 'package:mirror/widget/icon.dart';
import 'package:mirror/widget/input_formatter/expression_team_delete_formatter.dart';
import 'package:mirror/widget/input_formatter/precision_limit_formatter.dart';
import 'package:mirror/widget/input_method_rules/pin_yin_text_edit_controller.dart';
import 'package:mirror/widget/user_avatar_image.dart';

///活动成员界面
class ActivityUserPage extends StatefulWidget {
  final int activityId;
  final int type; //0-查看活动成员 1 -移除活动成员  2-举报成员
  final List<UserModel> userList;

  ActivityUserPage({Key key, @required this.activityId, this.type = 0, @required this.userList}) : super(key: key);

  @override
  _ActivityUserPageState createState() => _ActivityUserPageState();
}

class _ActivityUserPageState extends State<ActivityUserPage> {
  final PinYinTextEditController _inputController = PinYinTextEditController();
  final PinYinTextEditController _reasonController = PinYinTextEditController();
  final FocusNode _focusNode = FocusNode();

  List<int> selectUserList = [];
  double bottomOpacity = 0.4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleString: getTitleString(),
      ),
      body: Container(
        color: AppColor.mainBlack,
        padding: EdgeInsets.only(bottom: ScreenUtil.instance.bottomBarHeight),
        child: Column(
          children: [
            Expanded(
              child: getList(),
            ),
            if (widget.type != 0) _getBottomBtn(),
          ],
        ),
      ),
    );
  }

  Widget getList() {
    return ListView.builder(
      itemCount: widget.userList.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _getEdit();
        }
        if (_inputController.text == null ||
            _inputController.text.length < 1 ||
            widget.userList[index - 1].nickName.contains(_inputController.text)) {
          return item(widget.userList[index - 1], index - 1, () {
            deleteUserOnClickListener(index - 1);
          });
        } else {
          return Container();
        }
      },
    );
  }

  Widget item(UserModel model, int index, Function() onTap) {
    if (widget.type != 0 && model.uid == Application.profile.uid) {
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
          UserAvatarImageUtil.init()
              .getUserImageWidget(model.avatarUri, model.uid.toString(), widget.type != 0 ? 32 : 38),
          SizedBox(width: 12),
          Expanded(
              child: Column(
            children: [
              Text(model.nickName ?? "", style: AppStyle.whiteRegular16),
              if (model.description != null) Text(model.description ?? "", style: AppStyle.text1Regular12),
            ],
          )),
          if (widget.type != 0) getSingleChoiceUi(index),
          if (widget.type == 0) getItemUserBtnUi(model, index),
        ],
      ),
    );
  }

  //按钮
  Widget getItemUserBtnUi(UserModel model, int index) {
    return FollowButton(
      id: model.uid,
      relation: model.relation,
      buttonType: FollowButtonType.COACH,
      resetDataListener: () {},
      onClickAttention: (int relation) {
        setState(() {
          model.relation = relation;
        });
      },
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

  Widget _getBottomBtn() {
    return GestureDetector(
      child: Opacity(
        opacity: bottomOpacity,
        child: Container(
          decoration: BoxDecoration(
            color: AppColor.mainYellow,
            borderRadius: BorderRadius.circular(4),
          ),
          height: 44,
          width: ScreenUtil.instance.width - 32,
          margin: EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          child: Text("确定", style: AppStyle.textRegular16, textAlign: TextAlign.center),
        ),
      ),
      onVerticalDragDown: (details) {
        setState(() {
          bottomOpacity = 0.6;
        });
      },
      onVerticalDragEnd: (_) {
        setState(() {
          bottomOpacity = 1;
        });
      },
      onTap: () {
        _showDialog();
      },
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

  //删除模式下的item点击
  deleteUserOnClickListener(int index) {
    if (selectUserList.contains(index)) {
      selectUserList.remove(index);
      bottomOpacity = 0.4;
      setState(() {});
    } else {
      selectUserList.clear();
      selectUserList.add(index);
      bottomOpacity = 1;
      setState(() {});
    }
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

  String getTitleString() {
    if (widget.type == 1) {
      return "踢出用户";
    } else if (widget.type == 2) {
      return "举报成员";
    } else {
      return "查看活动成员";
    }
  }
}
