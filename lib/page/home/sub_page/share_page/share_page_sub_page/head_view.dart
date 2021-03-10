import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/profile/black_model.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:mirror/data/notifier/token_notifier.dart';
import 'package:mirror/page/profile/profile_detail_page.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/date_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/custom_button.dart';
import 'package:mirror/widget/dialog.dart';
import 'package:mirror/widget/feed/feed_more_popups.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

class HeadView extends StatefulWidget {
  HomeFeedModel model;

  // 是否显示关注按钮
  bool isShowConcern;

  // 删除动态
  ValueChanged<int> deleteFeedChanged;
  int isBlack;
  String pageName;

  // 取消关注
  ValueChanged<HomeFeedModel> removeFollowChanged;
  ValueChanged<bool> followChanged;
  int mineDetailId;

  HeadView({
    this.model,
    this.isShowConcern,
    this.deleteFeedChanged,
    this.removeFollowChanged,
    this.isBlack,
    this.mineDetailId,
    this.pageName,
  });

  @override
  State<StatefulWidget> createState() {
    return HeadViewState();
  }
}

class HeadViewState extends State<HeadView> {
  double opacity = 0;
  bool isMySelf = false;

  // 删除动态
  deleteFeed() async {
    Map<String, dynamic> map = await deletefeed(id: widget.model.id);
    if (map["state"]) {
      widget.deleteFeedChanged(widget.model.id);
      if (widget.isShowConcern) {
        context.read<FeedMapNotifier>().deleteContent(widget.model.id);
        Navigator.pop(context);
      }
    } else {
      print("删除失败");
    }
  }

  _checkBlackStatus(int id, BuildContext context, bool isCancel) async {
    if (isCancel) {
      removeFollowAndFollow(id, context, isCancel);
    } else {
      BlackModel blackModel = await ProfileCheckBlack(widget.model.pushId);
      if (widget.model != null) {
        print('inThisBlack===================${blackModel.inThisBlack}');
        print('inYouBlack===================${blackModel.inYouBlack}');
        if (blackModel.inYouBlack == 1) {
          Toast.show("你已将该用户拉黑", context);
        } else if (blackModel.inThisBlack == 1) {
          Toast.show("该用户已将你拉黑", context);
        } else {
          removeFollowAndFollow(id, context, isCancel);
        }
      }
    }
  }

  // 关注or取消关注
  removeFollowAndFollow(int id, BuildContext context, bool isCancel) async {
    if (isCancel) {
      int relation = await ProfileCancelFollow(id);
      if (relation == 0 || relation == 2) {
        if (!widget.isShowConcern) {
          widget.removeFollowChanged(widget.model);
        }
        context.read<ProfilePageNotifier>().changeIsFollow(true, true, widget.model.pushId);
        ToastShow.show(msg: "取消关注成功", context: context);
      } else {
        ToastShow.show(msg: "取消关注失败,请重试", context: context);
      }
    } else {
      int relation = await ProfileAddFollow(id);
      if (relation != null) {
        if (relation == 1 || relation == 3) {
          context.read<ProfilePageNotifier>().changeIsFollow(true, false, widget.model.pushId);
          ToastShow.show(msg: "关注成功!", context: context);
          opacity = 1;
          Future.delayed(Duration(milliseconds: 1000), () {
            opacity = 0;
            setState(() {});
          });
        } else {
          ToastShow.show(msg: "关注失败,请重试", context: context);
        }
      }
    }
  }

  // 是否显示关注按钮
  isShowFollowButton(BuildContext context) {
    if (widget.isShowConcern &&
        context.watch<ProfilePageNotifier>().profileUiChangeModel[widget.model.pushId].isFollow == true &&
        widget.model.pushId != context.watch<ProfileNotifier>().profile.uid) {
      return GestureDetector(
        onTap: () {
          if (!context.read<TokenNotifier>().isLoggedIn) {
            AppRouter.navigateToLoginPage(context);
          }
          _checkBlackStatus(widget.model.pushId, context, false);
        },
        child: Container(
          margin: EdgeInsets.only(right: 6),
          height: 28,
          padding: EdgeInsets.only(left: 12, top: 6, right: 12, bottom: 6),
          decoration: BoxDecoration(
            border: new Border.all(color: AppColor.textPrimary1, width: 1),
            borderRadius: BorderRadius.circular((14.0)),
          ),
          child: Center(
            child: Row(
              children: [
                Icon(
                  Icons.add,
                  color: AppColor.textPrimary1,
                  size: 16,
                ),
                // Container(
                //   width: 16,
                //   height: 16,
                //   child: Image.asset(name),
                // ),
                SizedBox(
                  width: 4,
                ),
                Container(
                  child: Text(
                    "关注",
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColor.textPrimary1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return AnimatedOpacity(
        opacity: opacity,
        duration: Duration(milliseconds: 2000),
        child: Container(
            margin: EdgeInsets.only(right: 6),
            height: 28,
            padding: EdgeInsets.only(left: 12, top: 6, right: 12, bottom: 6),
            decoration: BoxDecoration(
              border: new Border.all(color: AppColor.textPrimary1, width: 1),
              borderRadius: BorderRadius.circular((14.0)),
            ),
            child: Center(
              child: Text(
                "已关注",
                style: AppStyle.textRegular12,
              ),
            )),
        onEnd: () {},
      );
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.model.pushId == context.watch<ProfileNotifier>().profile.uid) {
      isMySelf = true;
      if (!context.watch<ProfilePageNotifier>().profileUiChangeModel.containsKey(widget.model.pushId)) {
        context.watch<ProfilePageNotifier>().setFirstModel(widget.model.pushId);
      }
      if (!context
          .watch<ProfilePageNotifier>()
          .profileUiChangeModel[widget.model.pushId]
          .feedStringList
          .contains("删除")) {
        context.watch<ProfilePageNotifier>().profileUiChangeModel[widget.model.pushId].feedStringList.add("删除");
      }
    } else if (!context.watch<ProfilePageNotifier>().profileUiChangeModel.containsKey(widget.model.pushId)) {
      context.watch<ProfilePageNotifier>().setFirstModel(widget.model.pushId,
          isFollow: widget.model.isFollow == 1 || widget.model.isFollow == 3 ? false : true);
    }
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (widget.mineDetailId == widget.model.pushId) {
            return false;
          }
          if (!context.read<TokenNotifier>().isLoggedIn) {
            AppRouter.navigateToLoginPage(context);
          } else {
            AppRouter.navigateToMineDetail(context, widget.model.pushId);
          }
        },
        child: Container(
            height: 62,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.only(left: 16, right: 11),
                  child: CircleAvatar(
                    // backgroundImage: AssetImage("images/test/yxlm1.jpeg"),
                    backgroundImage: widget.model.avatarUrl != null
                        ? NetworkImage(
                            isMySelf ? context.watch<ProfileNotifier>().profile.avatarUri : widget.model.avatarUrl)
                        : NetworkImage("images/test.png"),
                    maxRadius: 19,
                  ),
                ),
                Expanded(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // GestureDetector(
                    //   child:
                    Text(
                      isMySelf ? context.watch<ProfileNotifier>().profile.nickName : widget.model.name ?? "空名字",
                      style: TextStyle(fontSize: 15),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    // onTap: () {},
                    // ),
                    Container(
                      padding: EdgeInsets.only(top: 2),
                      child: Text("${DateUtil.generateFormatDate(widget.model.createTime, false)}",
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColor.textSecondary,
                          )),
                    )
                  ],
                )),
                isShowFollowButton(context),
                Container(
                  margin: EdgeInsets.only(right: 16),
                  child: GestureDetector(
                    child: Image.asset("images/resource/2.0x/ic_dynamic_Set up@2x.png",
                        fit: BoxFit.cover, width: 24, height: 24),
                    onTap: () {
                      if (context.read<FeedMapNotifier>().postFeedModel != null) {
                        ToastShow.show(msg: "不响应", context: context);
                      } else {
                        openMoreBottomSheet(
                            context: context,
                            lists: context
                                .read<ProfilePageNotifier>()
                                .profileUiChangeModel[widget.model.pushId]
                                .feedStringList,
                            onItemClickListener: (index) {
                              switch (context
                                  .read<ProfilePageNotifier>()
                                  .profileUiChangeModel[widget.model.pushId]
                                  .feedStringList[index]) {
                                case "删除":
                                  deleteFeed();
                                  break;
                                case "取消关注":
                                  _checkBlackStatus(widget.model.pushId, context, true);
                                  break;
                                case "举报":
                                  _showDialog();
                                  break;
                              }
                            });
                      }
                    },
                  ),
                )
              ],
            )));
  }

  void _showDialog() {
    showAppDialog(context,
        confirm: AppDialogButton("必须举报!", () {
          _denounceUser();
          return true;
        }),
        cancel: AppDialogButton("再想想", () {
          return true;
        }),
        title: "提交举报",
        info: "确认举报用户",
        barrierDismissible: false);
  }

  _denounceUser() async {
    bool isSucess = await ProfileMoreDenounce(widget.model.id, 1);
    print('isSucess=======================================$isSucess');
    if (isSucess) {
      ToastShow.show(msg: "感谢你的反馈，我们会尽快处理!", context: context);
    }
  }
}
