import 'package:amap_location_muka/amap_location_muka.dart';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/activity/activity_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/activity/activity_model.dart';
import 'package:mirror/data/model/activity/auth_data.dart';
import 'package:mirror/data/notifier/token_notifier.dart';
import 'package:mirror/page/activity/util/activity_util.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/click_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/dialog.dart';
import 'package:mirror/widget/input_formatter/expression_team_delete_formatter.dart';
import 'package:mirror/widget/input_method_rules/pin_yin_text_edit_controller.dart';
import 'package:mirror/widget/loading.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class DetailActivityBottomUi extends StatefulWidget {
  final ActivityModel activityModel;
  final int inviterId;
  final Function() onRestDataListener;

  DetailActivityBottomUi(this.activityModel, this.inviterId, this.onRestDataListener);

  @override
  _DetailActivityBottomUiState createState() => _DetailActivityBottomUiState();
}

class _DetailActivityBottomUiState extends State<DetailActivityBottomUi> {
  bool isAgree = false;
  final PinYinTextEditController _applyJoinController = PinYinTextEditController();
  Location currentAddressInfo; //当前位置的信息
  @override
  Widget build(BuildContext context) {
    if (widget.activityModel.isJoin) {
      if (!widget.activityModel.isCanSignIn) {
        return _postFeedUi();
      } else if (widget.activityModel.isSignIn) {
        return _postFeedUi();
      } else {
        return _signInUi();
      }
    } else {
      if (widget.activityModel.status == 3) {
        return _endActivity();
      } else if (widget.activityModel.status == 2) {
        return _joinActivityCanNot();
      } else {
        return _joinActivity();
      }
    }
  }

  Widget _signInUi() {
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
          Text("还没有签到,赶快签到吧", style: AppStyle.text1Regular14),
          Spacer(),
          GestureDetector(
            child: Container(
              height: 40,
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: AppColor.mainYellow,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text("签到", style: AppStyle.textRegular15),
            ),
            onTap: () {
              _signInClickListener();
            },
          ),
        ],
      ),
    );
  }

  Widget _postFeedUi() {
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
          GestureDetector(
            child: Container(
              height: 40,
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: AppColor.mainYellow,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text("发布动态", style: AppStyle.textRegular15),
            ),
            onTap: () {
              if (!context
                  .read<TokenNotifier>()
                  .isLoggedIn) {
                AppRouter.navigateToLoginPage(context);
                return;
              }
              AppRouter.navigateToMediaPickerPage(
                  context,
                  9,
                  1,
                  true,
                  0,
                  false, (result) {},
                  publishMode: 1,
                  activityModel: widget.activityModel);
            },
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

  //参加活动
  Widget _joinActivity() {
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
                child: isAgree ? Image.asset("assets/png/select_icon_red.png", width: 20, height: 20) : Container(),
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
              child: Text("参加活动", style: AppStyle.textRegular15),
            ),
            onTap: () {
              judgeApplyJoin();
            },
          ),
        ],
      ),
    );
  }

  //活动进行中
  Widget _joinActivityCanNot() {
    return Container(
      height: 40,
      width: ScreenUtil.instance.width - 32,
      decoration: BoxDecoration(
        color: AppColor.layoutBgGrey,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          SizedBox(width: 12),
          Text("活动进行中", style: AppStyle.text1Regular14),
          Spacer(),
          Container(
            height: 40,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: AppColor.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text("活动进行中", style: AppStyle.whiteRegular15),
          ),
        ],
      ),
    );
  }

  judgeApplyJoin() {
    if (!isAgree) {
      ToastShow.show(msg: "请先阅读互动说明", context: context);
    } else if (widget.activityModel.status == 1) {
      ToastShow.show(msg: "活动人数已经筹集满了", context: context);
    } else if (AuthData.init().getString(widget.activityModel.auth) == "所有人") {
      if (widget.inviterId != null) {
        _joinByInvitationActivity();
      } else {
        _applyJoinActivity("");
      }
    } else if (AuthData.init().getString(widget.activityModel.auth) == "受到邀请的人") {
      if (widget.inviterId != null) {
        _joinByInvitationActivity();
      } else {
        ToastShow.show(msg: "活动只允许收到邀请的人加入", context: context);
      }
    } else {
      _showApplyJoinActivityDialog();
    }
  }

  //申请dialog
  Widget _applyJoinEditWidget() {
    return Container(
      height: 104,
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 16),
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


  //申请加入dialog
  _showApplyJoinActivityDialog() {
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
            Future.delayed(Duration(microseconds: 100), () {
              _applyJoinActivity(_applyJoinController.text);
              _applyJoinController.text = "";
            });
          }
          return true;
        }));
  }

  //申请加入活动
  _applyJoinActivity(String message) async {
    Loading.showLoading(context, infoText: "正在加入活动");
    List list;
    await Future.delayed(Duration(microseconds: 300), () async {
      list = await applyJoinActivity(widget.activityModel.id, message);
    });

    Loading.hideLoading(context);
    if (list[0] && widget.onRestDataListener != null) {
      widget.onRestDataListener();
      ToastShow.show(msg: "申请成功", context: context);
    } else {
      ToastShow.show(msg: list[1], context: context);
    }
  }

  //参加邀请的活动
  _joinByInvitationActivity() async {
    Loading.showLoading(context, infoText: "正在加入活动");
    if (ClickUtil.isFastClick()) {
      return;
    }
    List list = await ActivityUtil.init().joinByInvitationActivity(context, widget.activityModel.id, widget.inviterId);
    if (list[0] && widget.onRestDataListener != null) {
      widget.onRestDataListener();
    } else {
      ToastShow.show(msg: list[1], context: context);
    }
    Loading.hideLoading(context);
  }

  //签到
  _signInClickListener() async {
    bool isPermissions = await locationPermissions();
    if (!isPermissions) {
      return;
    }
    ActivityModel model = await getActivityDetailApi(widget.activityModel.id);
    if (!widget.activityModel.isJoin) {
      ToastShow.show(msg: "不是这个活动的成员不能签到", context: context);
    } else if (!model.isCanSignIn) {
      ToastShow.show(msg: "已经过了签到时间", context: context);
    } else if (model.isSignIn) {
      ToastShow.show(msg: "已经签过到了", context: context);
    } else {
      Loading.showLoading(context);

      bool isSignInActivity = await signInActivity(
          widget.activityModel.id, currentAddressInfo.longitude.toString(), currentAddressInfo.latitude.toString());
      Loading.hideLoading(context);
      if (isSignInActivity) {
        ToastShow.show(msg: "签到成功", context: context);
      } else {
        ToastShow.show(msg: "签到失败", context: context);
      }
    }
    if (widget.onRestDataListener != null) {
      widget.onRestDataListener();
    }
  }

  // 获取定位权限
  Future<bool> locationPermissions() async {
    // 获取定位权限
    PermissionStatus permissions = await Permission.locationWhenInUse.status;
    print("下次寻问permissions：：：：$permissions");
    // 已经获取了定位权限
    if (permissions.isGranted) {
      currentAddressInfo = await AmapLocation.fetch(iosAccuracy: AmapLocationAccuracy.HUNDREE_METERS);
      return true;
    } else {
      // 请求定位权限
      permissions = await Permission.locationWhenInUse.request();
      print("permissions::::$permissions");
      if (permissions.isGranted) {
        currentAddressInfo = await AmapLocation.fetch(iosAccuracy: AmapLocationAccuracy.HUNDREE_METERS);
        return true;
      } else {
        _locationFailPopUps();
        return false;
      }
    }
  }

  // 定位失败弹窗
  _locationFailPopUps() {
    return showAppDialog(context,
        title: "位置信息",
        info: "你没有开通位置权限，您可以通过系统\"设置\"进行权限管理",
        confirmColor: AppColor.white,
        cancel: AppDialogButton("返回", () {
          return true;
        }),
        confirm: AppDialogButton("去设置", () {
          AppSettings.openLocationSettings();
          return true;
        }));
  }
}
