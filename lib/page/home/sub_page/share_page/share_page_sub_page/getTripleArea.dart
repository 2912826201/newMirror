//  点赞，转发，评论三连区域
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/api.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/data/model/base_response_model.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/message/chat_type_model.dart';
import 'package:mirror/data/model/profile/black_model.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:mirror/data/notifier/release_progress_notifier.dart';
import 'package:mirror/data/notifier/token_notifier.dart';
import 'package:mirror/data/notifier/user_interactive_notifier.dart';
import 'package:mirror/page/feed/like.dart';
import 'package:mirror/page/home/sub_page/share_page/dynamic_list.dart';
import 'package:mirror/page/if_page.dart';
import 'package:mirror/page/profile/profile_detail_page.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/string_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/feed/feed_comment_popups.dart';
import 'package:mirror/widget/feed/feed_share_popups.dart';
import 'package:mirror/widget/icon.dart';
import 'package:mirror/widget/post_comments.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

typedef backCallBack = void Function();

class GetTripleArea extends StatefulWidget {
  HomeFeedModel model;
  int index;
  GlobalKey offsetKey;
  backCallBack back;

  GetTripleArea({Key key, this.model, this.index, this.offsetKey, this.back}) : super(key: key);

  GetTripleAreaState createState() => GetTripleAreaState();
}

class GetTripleAreaState extends State<GetTripleArea> {
  @override
  Widget build(BuildContext context) {
    // print("打印model的值￥${widget.model}");
    return Container(
        key: widget.offsetKey,
        height: 48,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Selector<FeedMapNotifier, List<String>>(builder: (context, laudUserInfo, child) {
              return laudUserInfo.length == 0 ? Container() : avatarOverlap(laudUserInfo.length, context, laudUserInfo);
            }, selector: (context, notifier) {
              return (notifier.value.feedMap == null ||
                      notifier.value.feedMap[widget.model.id] == null ||
                      notifier.value.feedMap[widget.model.id].laudUserInfo == null)
                  ? <String>[]
                  : notifier.value.feedMap[widget.model.id].laudUserInfo;
            }),
            // context
            // widget.model.laudUserInfo.length > 0 ? avatarOverlap(widget.model.laudUserInfo.length, context,widget.model.laudUserInfo) : Container(),
            SizedBox(width: 5),
            Selector<FeedMapNotifier, List<String>>(builder: (context, laudUserInfo, child) {
              return laudUserInfo.length == 0 ? Container() : roundedLikeNum(context);
            }, selector: (context, notifier) {
              return (notifier.value.feedMap == null ||
                      notifier.value.feedMap[widget.model.id] == null ||
                      notifier.value.feedMap[widget.model.id].laudUserInfo == null)
                  ? <String>[]
                  : notifier.value.feedMap[widget.model.id].laudUserInfo;
            }),
            // widget.model.laudUserInfo.length > 0 ? roundedLikeNum(context) : Container(),
            Spacer(),
            Container(
              width: 104,
              margin: EdgeInsets.only(right: 16),
              child: roundedTriple(),
            )
          ],
        ));
  }

  // 横排重叠头像
  avatarOverlap(int num, BuildContext context, List<String> laudUserInfo) {
    // print("num:$num");
    if (num == 1) {
      return Container(
        width: 37,
        child: Stack(
          overflow: Overflow.clip,
          children: [
            Positioned(left: 16, top: 13.5, child: roundedAvatar(context, laudUserInfo[0])),
          ],
        ),
      );
    } else if (num == 2) {
      return Container(
          width: 48,
          child: Stack(
            overflow: Overflow.clip,
            children: [
              Positioned(left: 16, top: 13.5, child: roundedAvatar(context, laudUserInfo[0])),
              Positioned(
                child: roundedAvatar(context, laudUserInfo[1]),
                left: 27,
                top: 13.5,
              ),
            ],
          ));
    } else {
      return Container(
          width: 59,
          child: Stack(
            overflow: Overflow.clip,
            children: [
              Positioned(top: 13.5, left: 16, child: roundedAvatar(context, laudUserInfo[0])),
              Positioned(child: roundedAvatar(context, laudUserInfo[1]), top: 13.5, left: 27),
              Positioned(child: roundedAvatar(context, laudUserInfo[2]), top: 13.5, left: 38),
            ],
          ));
    }
  }

  // 跳转点赞页
  jumpLike(BuildContext context) {
    AppRouter.navigateToLikePage(context, widget.model);
  }

  // 点赞
  setUpLuad() async {
    bool isLoggedIn = context.read<TokenNotifier>().isLoggedIn;
    print("是否点赞了￥${context.read<FeedMapNotifier>().value.feedMap[widget.model.id].isLaud}");
    if (isLoggedIn) {
      if (context.read<ReleaseProgressNotifier>().postFeedModel != null &&
          context.read<FeedMapNotifier>().value.feedMap[widget.model.id].id != Application.insertFeedId) {
        // ToastShow.show(msg: "不响应", context: context);
      } else {
        BaseResponseModel model = await laud(
            id: widget.model.id,
            laud: context.read<FeedMapNotifier>().value.feedMap[widget.model.id].isLaud == 0 ? 1 : 0);
        if (model.code == CODE_BLACKED) {
          ToastShow.show(msg: "你已被对方加入黑名单，成为好友才能互动哦~", context: context, gravity: Toast.CENTER);
        } else {
          // 点赞/取消赞成功
          // print("state:${model.data["state"]}");
          // if (model.data["state"]) {
          context
              .read<FeedMapNotifier>()
              .setLaud(widget.model.isLaud, context.read<ProfileNotifier>().profile.avatarUri, widget.model.id);
          context
              .read<UserInteractiveNotifier>()
              .laudedChange(widget.model.pushId, context.read<FeedMapNotifier>().value.feedMap[widget.model.id].isLaud);
          // } else { // 失败
          //   print("shib ");
          // }
        }
      }
    } else {
      // 去登录
      AppRouter.navigateToLoginPage(context);
    }
  }

  // 横排头像默认值
  roundedAvatar(BuildContext context, String url) {
    return GestureDetector(
      onTap: () {
        jumpLike(context);
      },
      child: CircleAvatar(
        backgroundImage: NetworkImage(url) ?? AssetImage("images/test/yxlm9.jpeg"),
        maxRadius: 10.5,
      ),
    );
  }

  // 横排
  roundedLikeNum(BuildContext context) {
    return GestureDetector(
      onTap: () {
        jumpLike(context);
      },
      child: Container(
          // margin: EdgeInsets.only(left: 6),
          child: Offstage(
        offstage: context.select((FeedMapNotifier value) => value.value.feedMap[widget.model.id].laudCount) == null,
        child: //用Selector的方式监听数据
            Selector<FeedMapNotifier, int>(builder: (context, laudCount, child) {
          return Text(
            "${StringUtil.getNumber(laudCount)}次赞",
            style: TextStyle(fontSize: 12),
          );
        }, selector: (context, notifier) {
          return notifier.value.feedMap[widget.model.id].laudCount;
        }),
      )),
    );
  }

  // 横排三连布局
  roundedTriple() {
    return Row(
      children: [
        AppIconButton(
          svgName: (context.select((FeedMapNotifier value) => value.value.feedMap) != null &&
                  context.select((FeedMapNotifier value) => value.value.feedMap[widget.model.id]) != null &&
                  context.select((FeedMapNotifier value) => value.value.feedMap[widget.model.id].isLaud) != null &&
                  context.select((FeedMapNotifier value) => value.value.feedMap[widget.model.id].isLaud) == 1)
              ? AppIcon.like_red_24
              : AppIcon.like_24,
          iconSize: 24,
          onTap: () {
            setUpLuad();
          },
        ),
        Container(
          margin: EdgeInsets.only(left: 16),
          child: AppIconButton(
            svgName: AppIcon.comment_feed,
            iconSize: 24,
            onTap: () {
              bool isLoggedIn = context.read<TokenNotifier>().isLoggedIn;
              if (isLoggedIn) {
                if (context.read<ReleaseProgressNotifier>().postFeedModel != null &&
                    context.read<FeedMapNotifier>().value.feedMap[widget.model.id].id != Application.insertFeedId) {
                  ToastShow.show(msg: "不响应", context: context);
                } else {
                  openFeedCommentBottomSheet(
                      context: context,
                      feedId: widget.model.id,
                      callback: () {
                        if (widget.back != null) {
                          widget.back();
                        }
                      });
                }
              } else {
                // 去登录
                AppRouter.navigateToLoginPage(context);
              }
            },
          ),
        ),
        Container(
          margin: EdgeInsets.only(left: 16),
          child: AppIconButton(
            svgName: AppIcon.share_feed,
            iconSize: 24,
            onTap: () {
              if (context.read<TokenNotifier>().isLoggedIn) {
                if (context.read<ReleaseProgressNotifier>().postFeedModel != null &&
                    context.read<FeedMapNotifier>().value.feedMap[widget.model.id].id != Application.insertFeedId) {
                  ToastShow.show(msg: "不响应", context: context);
                } else {
                  InquireCheckBlack(
                      checkId: widget.model.pushId,
                      inquireCheckBlackCallback: (BlackModel blackModel) {
                        String promptText = "";
                        if (blackModel.inYouBlack == 1) {
                          promptText = "分享失败，你已将对方加入黑名单";
                        } else if (blackModel.inThisBlack == 1) {
                          promptText = "分享失败，你已被对方加入黑名单";
                        }
                        if (promptText != "") {
                          ToastShow.show(msg: promptText, context: context, gravity: Toast.CENTER);
                          return;
                        }
                        openShareBottomSheet(
                            context: context,
                            map: widget.model.toJson(),
                            chatTypeModel: ChatTypeModel.MESSAGE_TYPE_FEED,
                            sharedType: 1);
                      });
                }
              } else {
                // 去登录
                AppRouter.navigateToLoginPage(context);
              }
            },
          ),
        ),
      ],
    );
  }
}
