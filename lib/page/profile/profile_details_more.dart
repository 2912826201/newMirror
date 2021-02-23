import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/profile/black_model.dart';
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
  @override
  void initState() {
    super.initState();
   /* _checkBlackStatus();*/
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
            child: !context.watch<ProfilePageNotifier>().profileUiChangeModel[widget.userId].isFollow ? _follow(width) :
        _notFollow
        (width)));
  }

  ///没关注的布局
  Widget _notFollow(double width) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            _showDialog();
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
            if (context.read<ProfilePageNotifier>()
                .profileUiChangeModel[widget.userId].isBlack == 1) {
              _cancelBlack();
            } else {
              _pullBlack();
            }
          },
          child: _itemSelect(width, AppStyle.textRegular16, context.watch<ProfilePageNotifier>()
              .profileUiChangeModel[widget.userId].isBlack == 1 ? "取消拉黑" : "拉黑"),
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
            _showDialog();
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
            if (context.read<ProfilePageNotifier>()
                .profileUiChangeModel[widget.userId].isBlack == 1) {
              _cancelBlack();
            } else {
              _pullBlack();
            }
          },
          child: _itemSelect(width, AppStyle.textRegular16, context.watch<ProfilePageNotifier>()
              .profileUiChangeModel[widget.userId].isBlack == 1? "取消拉黑" : "拉黑"),
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
          child: !context.watch<ProfilePageNotifier>().profileUiChangeModel[widget.userId].isFollow
              ?_itemSelect(width,
              AppStyle.redRegular16, "取消关注"):Container(),
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

  void _showDialog() {
   showAppDialog(context,
   confirm: AppDialogButton("必须举报!",(){
        _denounceUser();
        return true;
       }),
     cancel: AppDialogButton("再想想", (){
       return true;
     }),
      title: "提交举报",
      info: "确认举报用户",
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
      context.read<ProfilePageNotifier>().changeIsFollow(true, true, widget.userId);
      Navigator.pop(context);
    }
  }

  ///拉黑
  _pullBlack() async {
    bool blackStatus = await ProfileAddBlack(widget.userId);
    print('拉黑是否成功====================================$blackStatus');
    if (blackStatus == true) {
      context.read<ProfilePageNotifier>().changeIsFollow(true, true, widget.userId);
      context.read<ProfilePageNotifier>().changeBlack(true, widget.userId, 1);
      ToastShow.show(msg: "拉黑成功", context: context);
    }else{
      ToastShow.show(msg: "操作失败", context: context);
    }
  }

  ///取消拉黑
  _cancelBlack() async {
    bool blackStatus = await ProfileCancelBlack(widget.userId);
    print('取消拉黑是否成功====================================$blackStatus');
    if(blackStatus!=null){
      if (blackStatus == true) {
        ToastShow.show(msg: "解除拉黑成功", context: context);
        context.read<ProfilePageNotifier>().changeBlack(true, widget.userId, 0);
      }else{
        ToastShow.show(msg: "操作失败", context: context);
      }
    }

  }

  ///请求黑名单关系
  _checkBlackStatus() async {
    BlackModel model = await ProfileCheckBlack(widget.userId);
    if (model != null) {
      print('inThisBlack===================${model.inThisBlack}');
      print('inYouBlack===================${model.inYouBlack}');
      if (model.inYouBlack == 1) {
        context.read<ProfilePageNotifier>()
            .changeBlack(true, widget.userId, 1);
      } else if(model.inThisBlack==1){
        context.read<ProfilePageNotifier>()
            .changeBlack(true, widget.userId, 2);
      }else{
        context.read<ProfilePageNotifier>()
            .changeBlack(true, widget.userId, 0);
      }

    }
  }

  ///举报
  _denounceUser() async {
    bool isSucess = await ProfileMoreDenounce(widget.userId, 0);
    print('isSucess=======================================$isSucess');
    if (isSucess!=null&&isSucess) {
      ToastShow.show(msg: "感谢你的反馈，我们会尽快处理!", context: context);
    }
  }
}
