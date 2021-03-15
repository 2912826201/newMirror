import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/profile/black_model.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:mirror/data/notifier/user_interactive_notifier.dart';
import 'package:mirror/page/profile/profile_detail_page.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/dialog.dart';
import 'package:provider/provider.dart';

///个人主页更多
class ProfileDetailsMore extends StatefulWidget {
  int userId;
  bool isFollow;
  String userName;

  ProfileDetailsMore({this.userId, this.isFollow, this.userName});

  @override
  State<StatefulWidget> createState() {
    return _detailsMoreState();
  }
}

class _detailsMoreState extends State<ProfileDetailsMore> {
  bool isBlack = false;
  @override
  void initState() {
    super.initState();
     _checkBlackStatus();
  }
  ///请求黑名单关系
  _checkBlackStatus() async {
    BlackModel model = await ProfileCheckBlack(widget.userId);
    if (model != null) {
      if (model.inYouBlack == 1) {
        isBlack = true;
        if(mounted){
          setState(() {
          });
        }
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    double width = ScreenUtil.instance.screenWidthDp;
    double height = ScreenUtil.instance.height;
    return Scaffold(
        appBar: CustomAppBar(
          titleString: "更多",
          leadingOnTap: () {
            Navigator.pop(this.context);
          },
        ),
        body: Container(
            height: height,
            width: width,
            color: AppColor.white,
            child: !context.watch<UserInteractiveNotifier>().profileUiChangeModel[widget.userId].isFollow
                ? _follow(width)
                : _notFollow(width)));
  }

  ///没关注的布局
  Widget _notFollow(double width) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            _showDialog(1);
          },
          child: _itemSelect(width, AppStyle.textRegular16, "举报"),
        ),
        Container(
          width: width,
          height: 0.5,
          color: AppColor.bgWhite.withOpacity(0.65),
        ),
        InkWell(
          onTap: () {
            if (isBlack) {
              _cancelBlack();
            } else {
              _showDialog(2);
            }
          },
          child: _itemSelect(width, AppStyle.textRegular16,
              isBlack ? "取消拉黑" : "拉黑"),
        ),
        Container(
          width: width,
          height: 0.5,
          color: AppColor.bgWhite.withOpacity(0.65),
        ),
      ],
    );
  }

  ///关注的布局
  Widget _follow(double width) {
    return Column(
      children: [
        Container(
          width: width,
          height: 0.5,
          color: AppColor.bgWhite.withOpacity(0.65),
        ),
        Container(
          width: width,
          height: 12,
          color: AppColor.bgWhite.withOpacity(0.65),
        ),
        InkWell(
          child: _itemSelect(width, AppStyle.textRegular16, "举报"),
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
            if (isBlack) {
              _cancelBlack();
            } else {
              _showDialog(2);
            }
          },
          child: _itemSelect(width, AppStyle.textRegular16,
              isBlack ? "取消拉黑" : "拉黑"),
        ),
        Container(
          width: width,
          height: 12,
          color: AppColor.bgWhite.withOpacity(0.65),
        ),
        InkWell(
          onTap: () {
            _cancelFollow();
          },
          child: !context.watch<UserInteractiveNotifier>().profileUiChangeModel[widget.userId].isFollow
              ? _itemSelect(width, AppStyle.redRegular16, "取消关注")
              : Container(),
        ),
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
      confirm: AppDialogButton(type==1?"必须举报!":type==2?"确认拉黑":"取消拉黑", () {
        if(type==1){
          _denounceUser();
        }else if(type==2){
          _pullBlack();
        }else{
          _cancelBlack();
        }
        return true;
      }),
      cancel: AppDialogButton("再想想", () {
        return true;
      }),
      title: type==1?"提交举报":type==2?"确认加入黑名单吗":"取消拉黑",
      info: type==1?"确认举报用户":"",
    );
  }

  Widget _itemSelect(double width, TextStyle style, String text) {
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
      context.read<UserInteractiveNotifier>().changeFollowCount(widget.userId, false);
      context.read<UserInteractiveNotifier>().changeIsFollow(true, true, widget.userId);
      Navigator.pop(context);
    }
  }

  ///拉黑
  _pullBlack() async {
    bool blackStatus = await ProfileAddBlack(widget.userId);
    print('拉黑是否成功====================================$blackStatus');
    if (blackStatus == true) {
      isBlack = true;
      setState(() {
      });
      context.read<UserInteractiveNotifier>().changeIsFollow(true, true, widget.userId);
      context.read<UserInteractiveNotifier>().removeListId(null);
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
        isBlack = false;
        setState(() {
        });
        context.read<UserInteractiveNotifier>().removeListId(widget.userId);
      } else {
        ToastShow.show(msg: "操作失败", context: context);
      }
    }
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
