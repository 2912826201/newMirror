import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/profile/black_model.dart';
import 'package:mirror/data/notifier/user_interactive_notifier.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/dialog.dart';
import 'package:mirror/widget/loading.dart';
import 'package:provider/provider.dart';

///个人主页更多
class ProfileDetailsMore extends StatefulWidget {
  int userId;
  bool isFollow;
  ProfileDetailsMore({this.userId, this.isFollow});

  @override
  _DetailsMoreState createState() {
    return _DetailsMoreState();
  }
}

class _DetailsMoreState extends State<ProfileDetailsMore> {
  final double width = ScreenUtil.instance.screenWidthDp;
  final double height = ScreenUtil.instance.height;
  @override
  void initState() {
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(
          titleString: "更多",
          leadingOnTap: () {
            Navigator.pop(this.context);
          },
        ),
        body: Container(height: height, width: width, color: AppColor.white, child: _columnLayOut()));
  }

  Widget _columnLayOut() {
    return Column(
      children: [
        Container(
          width: width,
          height: 0.5,
          color: AppColor.bgWhite.withOpacity(0.65),
        ),
        !context.watch<UserInteractiveNotifier>().value.profileUiChangeModel[widget.userId].isFollow
            ? Container(
                width: width,
                height: 12,
                color: AppColor.bgWhite.withOpacity(0.65),
              )
            : Container(),
        InkWell(
          child: _itemSelect( AppStyle.textRegular16, "举报"),
          onTap: () {
            _showDialog(1);
          },
        ),
        Container(
          padding: EdgeInsets.only(left: 16, right: 16),
          width: width,
          height: 0.5,
          color: AppColor.bgWhite.withOpacity(0.65),
        ),
        InkWell(
          onTap: () {
            if (context.read<UserInteractiveNotifier>().value.profileUiChangeModel[widget.userId].inMyBlack) {
              Loading.showLoading(context);
              _cancelBlack();
            } else {
              _showDialog(2);
            }
          },
          child: _itemSelect(AppStyle.textRegular16, context.watch<UserInteractiveNotifier>().value
              .profileUiChangeModel[widget.userId].inMyBlack ? "取消拉黑" : "拉黑"),
        ),
        !context.watch<UserInteractiveNotifier>().value.profileUiChangeModel[widget.userId].isFollow
            ? Container(
                width: width,
                height: 12,
                color: AppColor.bgWhite.withOpacity(0.65),
              )
            : Container(),
        !context.watch<UserInteractiveNotifier>().value.profileUiChangeModel[widget.userId].isFollow
            ? InkWell(
                onTap: () {
                  Loading.showLoading(context);
                  _cancelFollow();
                },
                child: _itemSelect( AppStyle.redRegular16, "取消关注"),
              )
            : Container(),
        Container(
          padding: EdgeInsets.only(left: 16, right: 16),
          width: width,
          height: 0.5,
          color: AppColor.bgWhite.withOpacity(0.65),
        ),
      ],
    );
  }

  void _showDialog(int type) {
    showAppDialog(
      context,
      confirm: AppDialogButton(
          type == 1
              ? "必须举报!"
              : type == 2
                  ? "确认拉黑"
                  : "取消拉黑", () {
        if (type == 1) {
          _denounceUser();
        } else if (type == 2) {
          _pullBlack();
        } else {
          _cancelBlack();
        }
        return true;
      }),
      cancel: AppDialogButton("再想想", () {
        return true;
      }),
      title: type == 1
          ? "提交举报"
          : type == 2
              ? "确认加入黑名单吗"
              : "取消拉黑",
      info: type == 1 ? "确认举报用户" : "",
    );
  }

  Widget _itemSelect( TextStyle style, String text) {
    return Container(
      height: 48,
      width: width,
      padding: EdgeInsets.only(left: 16, right: 16),
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: style,
      ),
    );
  }

  ///取消关注
  _cancelFollow() async {
    int cancelResult = await ProfileCancelFollow(widget.userId);
    print('取消关注监听==============================$cancelResult');
    if (cancelResult == 0 || cancelResult == 2) {
      ToastShow.show(msg: "已取消关注该用户", context: context);
      context.read<UserInteractiveNotifier>().changeIsFollow(true, true, widget.userId);
      context.read<UserInteractiveNotifier>().removeUserFollowId(widget.userId);
      Loading.hideLoading(context);
      Navigator.pop(context);
    }
  }

  ///拉黑
  _pullBlack() async {
    bool blackStatus = await ProfileAddBlack(widget.userId);
    print('拉黑是否成功====================================$blackStatus');
    if (blackStatus == true) {
      context.read<UserInteractiveNotifier>().changeBalckStatus(widget.userId, true);
      context.read<UserInteractiveNotifier>().changeIsFollow(true, true, widget.userId);
      context.read<UserInteractiveNotifier>().removeListId(widget.userId,isAdd: false);
      context.read<UserInteractiveNotifier>().removeUserFollowId(widget.userId);
      ToastShow.show(msg: "拉黑成功", context: context);
    } else {
      ToastShow.show(msg: "操作失败", context: context);
    }
  }

  ///取消拉黑
  _cancelBlack() async {
    bool blackStatus = await ProfileCancelBlack(widget.userId);
    print('取消拉黑是否成功====================================$blackStatus');
    if (blackStatus != null) {
      if (blackStatus == true) {
        ToastShow.show(msg: "解除拉黑成功", context: context);
        context.read<UserInteractiveNotifier>().changeBalckStatus(widget.userId, false);
        context.read<UserInteractiveNotifier>().removeListId(widget.userId);
      } else {
        ToastShow.show(msg: "操作失败", context: context);
      }
    }
    Loading.hideLoading(context);
  }

  ///举报
  _denounceUser() async {
    bool isSucess = await ProfileMoreDenounce(widget.userId, 0);
    print('isSucess=======================================$isSucess');
    if (isSucess != null && isSucess) {
      ToastShow.show(msg: "感谢你的反馈，我们会尽快处理!", context: context);
    }
  }
}
