import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/profile/black_model.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:mirror/data/notifier/token_notifier.dart';
import 'package:mirror/data/notifier/user_interactive_notifier.dart';
import 'package:mirror/page/profile/profile_detail_page.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/date_util.dart';
import 'package:mirror/util/event_bus.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/custom_button.dart';
import 'package:mirror/widget/dialog.dart';
import 'package:mirror/widget/feed/feed_more_popups.dart';
import 'package:mirror/widget/icon.dart';
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
      print('---------------------------------------删除动态');
      EventBus.getDefault().post(msg: widget.model.id, registerName: EVENTBUS_PROFILE_DELETE_FEED);
      widget.deleteFeedChanged(widget.model.id);
      if (widget.isShowConcern) {
        EventBus.getDefault()
            .post(msg: widget.model.id, registerName: EVENTBUS_INTERACTIVE_NOTICE_DELETE_COMMENT);
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
          Toast.show("关注失败，你已将对方加入黑名单", context);
        } else if (blackModel.inThisBlack == 1) {
          Toast.show("关注失败，你已被对方加入黑名单", context);
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
        context.read<UserInteractiveNotifier>().changeIsFollow(true, true, widget.model.pushId);
        context.read<UserInteractiveNotifier>().changeFollowCount(widget.model.pushId, false);

        ToastShow.show(msg: "取消关注成功", context: context);
      } else {
        ToastShow.show(msg: "取消关注失败,请重试", context: context);
      }
    } else {
      int relation = await ProfileAddFollow(id);
      if (relation != null) {
        if (relation == 1 || relation == 3) {
          context.read<UserInteractiveNotifier>().changeIsFollow(true, false, widget.model.pushId);
          context.read<UserInteractiveNotifier>().changeFollowCount(widget.model.pushId, true);
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
    return  Consumer<UserInteractiveNotifier>(builder: (context, notifier, child) {
      if (widget.isShowConcern &&
          notifier.profileUiChangeModel[widget.model.pushId].isFollow == true &&
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
            width: 64,
            decoration: BoxDecoration(
              border: new Border.all(color: AppColor.textPrimary1, width: 1),
              borderRadius: BorderRadius.circular((14.0)),
            ),
            child: Center(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Spacer(),
                  Icon(
                    Icons.add,
                    color: AppColor.textPrimary1,
                    size: 16,
                  ),
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
                  Spacer(),
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
              width: 64,
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
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
      if (widget.model.pushId == context.read<ProfileNotifier>().profile.uid) {
        isMySelf = true;
        context.read<UserInteractiveNotifier>().setFirstModel(widget.model.pushId);
        if (!context
            .read<UserInteractiveNotifier>()
            .profileUiChangeModel[widget.model.pushId]
            .feedStringList
            .contains("删除")) {
          context.read<UserInteractiveNotifier>().profileUiChangeModel[widget.model.pushId].feedStringList.add("删除");
        }
      } else {
        context.read<UserInteractiveNotifier>().setFirstModel(widget.model.pushId,
            isFollow: widget.model.isFollow == 1 || widget.model.isFollow == 3 ? false : true);
      }
  }

  @override
  Widget build(BuildContext context) {
    print("动态头部build");
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          print('头部点击响应-------头部点击响应--------------${widget.model.pushId}');
          if (widget.mineDetailId == widget.model.pushId) {
            return false;
          }
          if (!context.read<TokenNotifier>().isLoggedIn) {
            AppRouter.navigateToLoginPage(context);
          } else {
            FocusScope.of(context).requestFocus(FocusNode());
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
                    child: AppIconButton(
                      svgName: AppIcon.more_feed,
                      iconSize: 24,
                      onTap: () {
                        print("点击更多按钮了");
                        // if (context.read<ReleaseProgressNotifier>().postFeedModel != null &&
                        //     context.read<FeedMapNotifier>().value.feedMap[widget.model.id].id !=
                        //         Application.insertFeedId) {
                        //   // ToastShow.show(msg: "不响应", context: context);
                        // } else {
                        // ignore: missing_return
                        openMoreBottomSheet(
                            context: context,
                            lists: context.read<UserInteractiveNotifier>().profileUiChangeModel[widget.model.pushId].feedStringList,
                            onItemClickListener: (index) {
                              switch (context.read<UserInteractiveNotifier>()
                                  .profileUiChangeModel[widget.model.pushId]
                                  // ignore: missing_return
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
                        // }
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
