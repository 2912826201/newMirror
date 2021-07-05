//  点赞，转发，评论三连区域
import 'package:animated_digit/animated_digit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';
import 'package:mirror/api/api.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/base_response_model.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/message/chat_type_model.dart';
import 'package:mirror/data/model/profile/black_model.dart';
import 'package:mirror/data/model/profile/buddy_list_model.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:mirror/data/notifier/token_notifier.dart';
import 'package:mirror/data/notifier/user_interactive_notifier.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/util/string_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/feed/feed_comment_popups.dart';
import 'package:mirror/widget/feed/feed_share_popups.dart';
import 'package:mirror/widget/icon.dart';
import 'package:mirror/widget/post_comments.dart';
import 'package:provider/provider.dart';

typedef backCallBack = void Function();

class GetTripleArea extends StatefulWidget {
  HomeFeedModel model;
  int index;
  GlobalKey offsetKey;
  backCallBack back;

  GetTripleArea({Key key, this.model, this.index, this.offsetKey, this.back}) : super(key: key);

  GetTripleAreaState createState() => GetTripleAreaState();
}

class GetTripleAreaState extends State<GetTripleArea> with TickerProviderStateMixin {
  int myId;

  // 是否可点赞
  bool isSetUpLuad = true;

  // 是否可分享
  bool isShare = true;

  // 数字动画控制器
  AnimatedDigitController animatedDigitController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    myId = context.read<ProfileNotifier>().profile.uid;
    new Future.delayed( Duration.zero, () {
      animatedDigitController = AnimatedDigitController(context.read<FeedMapNotifier>().value.feedMap[widget.model.id].laudCount);
    });
    //
  }

  @override
  Widget build(BuildContext context) {
    // print("打印model的值￥${widget.model}");
    print(" 点赞，转发，评论三连区域build");
    return Container(
        key: widget.offsetKey,
        height: 48,
        color: AppColor.white,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 头像布局
            Selector<FeedMapNotifier, List<BuddyModel>>(builder: (context, laudUserInfo, child) {
              return GestureDetector(
                onTap: () {
                  jumpLike(context);
                },
                child: Container(
                    width: laudUserInfo.length == 1
                        ? 21
                        : laudUserInfo.length == 2
                            ? 31
                            : laudUserInfo.length >= 3
                                ? 41
                                : 21,
                    height: 21,
                    margin: const EdgeInsets.only(left: 16),
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: const FractionalOffset(0, 0.5),
                      children: avatarOverlap(context, laudUserInfo),
                    )),
              );
            }, selector: (context, notifier) {
              return (notifier.value.feedMap == null || notifier.value.feedMap[widget.model.id] == null)
                  ? []
                  : notifier.value.feedMap[widget.model.id].laudUserInfo;
            }),
            const SizedBox(width: 5),
            // 几次点赞
            Selector<FeedMapNotifier, List<BuddyModel>>(builder: (context, laudUserInfo, child) {
              return laudUserInfo.length == 0 ? Container() : roundedLikeNum(context);
            }, selector: (context, notifier) {
              return (notifier.value.feedMap == null ||
                      notifier.value.feedMap[widget.model.id] == null ||
                      notifier.value.feedMap[widget.model.id].laudUserInfo == null)
                  ? <BuddyModel>[]
                  : notifier.value.feedMap[widget.model.id].laudUserInfo;
            }),
            // widget.model.laudUserInfo.length > 0 ? roundedLikeNum(context) : Container(),
            const Spacer(),
            // 横排三连布局
            Container(
              width: Application.slideFeedLike ? 108 : 104,
              margin: const EdgeInsets.only(right: 16),
              child: roundedTriple(),
            )
          ],
        ));
  }

  // 横排重叠头像
  avatarOverlap(BuildContext context, List<BuddyModel> laudUserInfo) {
    List<Widget> avatarList = [];
    List<BuddyModel> userInfo = [];
    // 只展示前三个点赞头像
    for (int i = 0; i < laudUserInfo.length; i++) {
      if (i < 4) {
        userInfo.add(laudUserInfo[i]);
      }
    }
    bool isShow = false;
    // 默认用户的头像点赞了显示用户本人头像
    if (context.select((TokenNotifier tokenNotifier) => tokenNotifier.isLoggedIn)) {
      for (BuddyModel item in userInfo) {
        int index = userInfo.indexOf(item);
        if (index != 0 && item.uid == myId) {
          isShow = true;
          break;
        }
      }
      if (!isShow) {
        avatarList.add(
          AnimatedContainer(
              height: (context.select((FeedMapNotifier value) => value.value.feedMap) != null &&
                      context.select((FeedMapNotifier value) => value.value.feedMap[widget.model.id]) != null &&
                      context.select((FeedMapNotifier value) => value.value.feedMap[widget.model.id].isLaud) != null &&
                      context.select((FeedMapNotifier value) => value.value.feedMap[widget.model.id].isLaud) == 1)
                  ? 21
                  : 0,
              width: (context.select((FeedMapNotifier value) => value.value.feedMap) != null &&
                      context.select((FeedMapNotifier value) => value.value.feedMap[widget.model.id]) != null &&
                      context.select((FeedMapNotifier value) => value.value.feedMap[widget.model.id].isLaud) != null &&
                      context.select((FeedMapNotifier value) => value.value.feedMap[widget.model.id].isLaud) == 1)
                  ? 21
                  : 0,
              alignment: Alignment.center,
              child: roundedAvatar(
                context,
                context.read<ProfileNotifier>().profile.avatarUri,
              ),
              duration: const Duration(milliseconds: 200)),
        );
      }
    }
    bool haveMyAvatar = false;
    userInfo.forEach((element) {
      if (element.uid == myId) {
        haveMyAvatar = true;
      }
    });
    // 其他用户点赞的头像
    for (BuddyModel item in userInfo) {
      int index = userInfo.indexOf(item);
      // 这里判断去掉了用户本人的显示
      if (isShow) {
        avatarList.add(AnimatedPositioned(
            left: avatarOffset(index),
            duration: const Duration(milliseconds: 200),
            child: animatedZoom(haveMyAvatar, userInfo, index, item: item.avatarUri)));
      } else if (item.uid != myId) {
        avatarList.add(AnimatedPositioned(
            left: avatarOffset(index),
            duration: const Duration(milliseconds: 200),
            child: animatedZoom(haveMyAvatar, userInfo, index, item: item.avatarUri)));
      }
    }
    return avatarList;
  }

  // 内部缩放动画
  animatedZoom(bool haveMyAvatar, List<BuddyModel> userInfo, int index, {String item}) {
    // 当存在用户本人点赞时，第4个头像缩放
    if (haveMyAvatar && index == 3) {
      return AnimatedContainer(
          height: context.read<FeedMapNotifier>().value.feedMap[widget.model.id].isLaud == 0 ? 21 : 0,
          width: context.read<FeedMapNotifier>().value.feedMap[widget.model.id].isLaud == 0 ? 21 : 0,
          alignment: Alignment.center,
          child: roundedAvatar(
            context,
            userInfo[index].avatarUri,
          ),
          duration: const Duration(milliseconds: 200));
      // 不存在用户本人点赞时，第3个头像缩放
    } else if (!haveMyAvatar && index == 2) {
      return AnimatedContainer(
          height: context.read<FeedMapNotifier>().value.feedMap[widget.model.id].isLaud == 0 ? 21 : 0,
          width: context.read<FeedMapNotifier>().value.feedMap[widget.model.id].isLaud == 0 ? 21 : 0,
          alignment: Alignment.center,
          child: roundedAvatar(
            context,
            userInfo[index].avatarUri,
          ),
          duration: const Duration(milliseconds: 200));
    } // 只展示前三个头像
    else if (index < 3) {
      return roundedAvatar(
        context,
        item,
      );
    } else {
      return Container();
    }
  }

  // 头像动画偏移位置
  avatarOffset(int index) {
    if (index == 3) {
      return 20.5 + (index - 1) * 10.0;
    } else {
      return 10.5 + (index - 1) * 10.0;
    }
  }

  // 跳转点赞页
  jumpLike(BuildContext context) {
    AppRouter.navigateToLikePage(context, widget.model);
  }

  // 点赞动画
  Future<bool> onLikeButtonTapped(bool isLiked) async {
    print("isLiked::::::$isLiked");
    bool isLoggedIn = context.read<TokenNotifier>().isLoggedIn;
    print("000000000000000000");
    if (isLoggedIn) {
      print("11111111111111111");
      if (isSetUpLuad) {
        print("22222222222");
        isSetUpLuad = false;
        BaseResponseModel model = await laud(
            id: widget.model.id,
            laud: context.read<FeedMapNotifier>().value.feedMap[widget.model.id].isLaud == 0 ? 1 : 0);
        if (model != null) {
          if (model.code == CODE_BLACKED) {
            ToastShow.show(msg: "你已被对方加入黑名单，成为好友才能互动哦~", context: context, gravity: Toast.CENTER);
            isSetUpLuad = true;
          } else {
            print("进了！！！！！！！！！！！");
            context.read<FeedMapNotifier>().setLaud(
                context.read<FeedMapNotifier>().value.feedMap[widget.model.id].isLaud == 0 ? 1 : 0,
                context.read<ProfileNotifier>().profile.avatarUri,
                widget.model.id);
            // model
            context.read<UserInteractiveNotifier>().laudedChange(
                widget.model.pushId, context.read<FeedMapNotifier>().value.feedMap[widget.model.id].isLaud);
            isSetUpLuad = true;
            if(context.read<FeedMapNotifier>().value.feedMap[widget.model.id].isLaud == 0 ) {
              animatedDigitController.addValue(1);
            } else {
              animatedDigitController.resetValue(context.read<FeedMapNotifier>().value.feedMap[widget.model.id].laudCount);
            }
            return !isLiked;
          }
        }
      }
    } else {
      // 去登录
      AppRouter.navigateToLoginPage(context);
    }
  }

  // 点赞
  setUpLuad() async {
    bool isLoggedIn = context.read<TokenNotifier>().isLoggedIn;
    if (isLoggedIn) {
      if (isSetUpLuad) {
        isSetUpLuad = false;
        BaseResponseModel model = await laud(
            id: widget.model.id,
            laud: context.read<FeedMapNotifier>().value.feedMap[widget.model.id].isLaud == 0 ? 1 : 0);
        if (model != null) {
          if (model.code == CODE_BLACKED) {
            ToastShow.show(msg: "你已被对方加入黑名单，成为好友才能互动哦~", context: context, gravity: Toast.CENTER);
          } else {
            context.read<FeedMapNotifier>().setLaud(
                context.read<FeedMapNotifier>().value.feedMap[widget.model.id].isLaud == 0 ? 1 : 0,
                context.read<ProfileNotifier>().profile.avatarUri,
                widget.model.id);
            // model
            context.read<UserInteractiveNotifier>().laudedChange(
                widget.model.pushId, context.read<FeedMapNotifier>().value.feedMap[widget.model.id].isLaud);
          }
        }
        isSetUpLuad = true;
      }
    } else {
      // 去登录
      AppRouter.navigateToLoginPage(context);
    }
  }

  // 横排头像默认值
  roundedAvatar(BuildContext context, String url, {double radius = 10.5}) {
    return ClipOval(
      child: CachedNetworkImage(
            height: 21,
            width: 21,
            // 调整磁盘缓存中图像大小
            // maxHeightDiskCache: 150,
            // maxWidthDiskCache: 150,
            // 指定缓存宽高
            useOldImageOnUrlChange: true,
            memCacheWidth: 150,
            memCacheHeight: 150,
            imageUrl: url != null ? FileUtil.getSmallImage(url) : "",
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: AppColor.bgWhite,
            ),
            errorWidget: (context, url, e) {
              return Container(
                color: AppColor.bgWhite,
              );
            },
          ) ??
          AssetImage("images/test/yxlm9.jpeg"),
    );
  }

  // 横排
  roundedLikeNum(BuildContext context) {
    // AnimatedDigitController

    return GestureDetector(
      onTap: () {
        jumpLike(context);
      },
      child: Container(
          // margin: EdgeInsets.only(left: 6),
          child: Offstage(
        offstage: context.select((FeedMapNotifier value) => value.value.feedMap[widget.model.id].laudCount) == null,
        child: //用Selector的方式监听数据
        // AnimatedDigitWidget(
        //   controller: animatedDigitController,
        //   textStyle: TextStyle(fontSize: 12),
        // ),
        Selector<FeedMapNotifier, int>(builder: (context, laudCount, child) {
          return Text(
            "${StringUtil.getNumber(laudCount)}次赞",
            style: const TextStyle(fontSize: 12),
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
        Application.slideFeedLike
            ? Container(
                height: 24,
                child: LikeButton(
                  likeBuilder: (bool isLiked) {
                    return isLiked
                        ? AppIcon.getAppIcon(
                            AppIcon.like_red_24,
                            24,
                            containerHeight: 24,
                            containerWidth: 24,
                          )
                        : AppIcon.getAppIcon(
                            AppIcon.like_24,
                            24,
                            containerHeight: 24,
                            containerWidth: 24,
                          );
                  },
                  isLiked: (context.select((FeedMapNotifier value) => value.value.feedMap) != null &&
                          context.select((FeedMapNotifier value) => value.value.feedMap[widget.model.id]) != null &&
                          context.select((FeedMapNotifier value) => value.value.feedMap[widget.model.id].isLaud) !=
                              null &&
                          context.select((FeedMapNotifier value) => value.value.feedMap[widget.model.id].isLaud) == 1)
                      ? true
                      : false,
                  size: 24,
                  onTap: onLikeButtonTapped,
                ),
              )
            : AppIconButton(
                svgName: (context.select((FeedMapNotifier value) => value.value.feedMap) != null &&
                        context.select((FeedMapNotifier value) => value.value.feedMap[widget.model.id]) != null &&
                        context.select((FeedMapNotifier value) => value.value.feedMap[widget.model.id].isLaud) !=
                            null &&
                        context.select((FeedMapNotifier value) => value.value.feedMap[widget.model.id].isLaud) == 1)
                    ? AppIcon.like_red_24
                    : AppIcon.like_24,
                iconSize: 24,
                onTap: () {
                  setUpLuad();
                },
              ),
        Container(
          margin: const EdgeInsets.only(left: 16),
          child: AppIconButton(
            svgName: AppIcon.comment_feed,
            iconSize: 24,
            onTap: () {
              openFeedCommentBottomSheet(
                  context: context,
                  feedId: widget.model.id,
                  callback: () {
                    if (widget.back != null) {
                      widget.back();
                    }
                  });
            },
          ),
        ),
        Container(
          margin: const EdgeInsets.only(left: 16),
          child: AppIconButton(
            svgName: AppIcon.share_feed,
            iconSize: 24,
            onTap: () {
              if (!context.read<TokenNotifier>().isLoggedIn) {
                openShareBottomSheet(
                    context: context,
                    map: widget.model.toJson(),
                    chatTypeModel: ChatTypeModel.MESSAGE_TYPE_FEED,
                    sharedType: 1);
                return;
              }

              if (isShare) {
                isShare = false;
                InquireCheckBlack(
                    checkId: widget.model.pushId,
                    inquireCheckBlackCallback: (BlackModel blackModel) {
                      String promptText = "";
                      if (blackModel.inThisBlack == 1) {
                        promptText = "分享失败，你已被对方加入黑名单";
                      }
                      if (promptText != "") {
                        ToastShow.show(msg: promptText, context: context, gravity: Toast.CENTER);
                        isShare = true;
                        return;
                      }
                      openShareBottomSheet(
                          context: context,
                          map: widget.model.toJson(),
                          chatTypeModel: ChatTypeModel.MESSAGE_TYPE_FEED,
                          sharedType: 1,
                          callback: () {
                            isShare = true;
                          });
                    });
              }
            },
          ),
        ),
      ],
    );
  }
}
