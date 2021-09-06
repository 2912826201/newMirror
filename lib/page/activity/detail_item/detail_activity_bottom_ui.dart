import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/activity/activity_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/activity/auth_data.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/dialog.dart';
import 'package:mirror/widget/input_formatter/expression_team_delete_formatter.dart';
import 'package:mirror/widget/input_method_rules/pin_yin_text_edit_controller.dart';

class DetailActivityBottomUi extends StatefulWidget {
  final bool isHaveMe;
  final int status;
  final int auth;
  final int activityId;
  final Function() onRestDataListener;

  DetailActivityBottomUi(this.activityId, this.status, this.auth, this.isHaveMe, this.onRestDataListener);

  @override
  _DetailActivityBottomUiState createState() => _DetailActivityBottomUiState();
}

class _DetailActivityBottomUiState extends State<DetailActivityBottomUi> {
  bool isAgree = false;
  final PinYinTextEditController _applyJoinController = PinYinTextEditController();

  @override
  Widget build(BuildContext context) {
    if (widget.status == 3) {
      return _endActivity();
    } else if (widget.isHaveMe) {
      return _haveMeUi();
    } else {
      return _noHaveMe();
    }
  }

  Widget _haveMeUi() {
    return Container(
      height: 40,
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColor.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          SizedBox(width: 12),
          Text("活动还未开始，发点动态吧", style: AppStyle.text1Regular14),
          Spacer(),
          Container(
            height: 40,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: AppColor.mainYellow,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text("发布动态", style: AppStyle.textRegular15),
          ),
        ],
      ),
    );
  }

  Widget _endActivity() {
    return Container(
      height: 40,
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColor.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          SizedBox(width: 12),
          Text("活动已结束", style: AppStyle.text1Regular14),
          Spacer(),
          Container(
            height: 40,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: AppColor.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text("活动已结束", style: AppStyle.whiteRegular15),
          ),
        ],
      ),
    );
  }

  //同意
  Widget _noHaveMe() {
    return Container(
      height: 40,
      width: ScreenUtil.instance.width - 32,
      decoration: BoxDecoration(
        color: AppColor.layoutBgGrey,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          GestureDetector(
            child: Container(
              width: 40,
              height: 40,
              padding: EdgeInsets.all(10),
              child: Container(
                decoration: BoxDecoration(
                  color: isAgree ? AppColor.mainRed : AppColor.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            onTap: () {
              isAgree = !isAgree;
              setState(() {});
            },
          ),
          Text("我已阅读并同意活动说明", style: AppStyle.whiteRegular12),
          Spacer(),
          GestureDetector(
            child: Container(
              height: 40,
              padding: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: AppColor.mainYellow,
                borderRadius: BorderRadius.circular(4),
              ),
              alignment: Alignment.centerLeft,
              child: Text("参见活动", style: AppStyle.textRegular15),
            ),
            onTap: () {
              judgeApplyJoin();
            },
          ),
        ],
      ),
    );
  }

  judgeApplyJoin() {
    if (!isAgree) {
      ToastShow.show(msg: "请先阅读互动说明", context: context);
    } else if (widget.status == 1) {
      ToastShow.show(msg: "活动人数已经筹集满了", context: context);
    } else if (AuthData.init().getString(widget.auth) == "所有人") {
      _applyJoinActivity("");
    } else if (AuthData.init().getString(widget.auth) == "受到邀请的人") {
      ToastShow.show(msg: "活动只允许收到邀请的人加入", context: context);
    } else {
      _showApplyJoinActivityDialog();
    }
  }

  //申请dialog
  Widget _applyJoinEditWidget() {
    return Container(
      height: 104,
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 40),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      decoration:
          BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(4)), color: AppColor.white.withOpacity(0.1)),
      child: TextField(
        controller: _applyJoinController,
        cursorColor: AppColor.white,
        style: AppStyle.whiteRegular12,
        maxLines: null,
        maxLength: 30,
        decoration: InputDecoration(
          isDense: true,
          counterText: '',
          hintText: "请输入理由...",
          hintStyle: AppStyle.text2Regular12,
          border: InputBorder.none,
        ),
        inputFormatters: [ExpressionTeamDeleteFormatter(maxLength: 30)],
      ),
    );
  }

  bool isShowApplyJoinActivityDialog = false;

  //申请加入dialog
  _showApplyJoinActivityDialog() {
    if (isShowApplyJoinActivityDialog) {
      ToastShow.show(msg: "正在操作中", context: context);
      return;
    }
    showAppDialog(context,
        title: "申请验证",
        info: "队长需要您填写验证信息，进行审核",
        infoStyle: AppStyle.text1Regular14,
        customizeWidget: _applyJoinEditWidget(),
        cancel: AppDialogButton("取消", () {
          _applyJoinController.text = "";
          return true;
        }),
        confirm: AppDialogButton("确定", () {
          if (_applyJoinController.text == null || _applyJoinController.text.length < 1) {
            ToastShow.show(msg: "申请理由不能为空", context: context);
          } else {
            _applyJoinActivity(_applyJoinController.text);
            _applyJoinController.text = "";
          }
          return true;
        }));
  }

  _applyJoinActivity(String message) async {
    if (isShowApplyJoinActivityDialog) {
      return;
    }
    isShowApplyJoinActivityDialog = true;

    bool isSuccess = await applyJoinActivity(widget.activityId, message);

    ToastShow.show(msg: isSuccess ? "申请成功" : "申请失败", context: context);
    isShowApplyJoinActivityDialog = false;

    if (isSuccess && widget.onRestDataListener != null) {
      widget.onRestDataListener();
    }
  }
}
