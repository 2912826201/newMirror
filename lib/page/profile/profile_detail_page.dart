import 'dart:async';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart' hide NestedScrollView, NestedScrollViewState;
import 'package:flutter/material.dart' hide TabBar, TabBarView, NestedScrollView, NestedScrollViewState;
import 'package:interactiveviewer_gallery/hero_dialog_route.dart';
import 'package:keframe/frame_separate_widget.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/api/user_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/message/chat_type_model.dart';
import 'package:mirror/data/model/profile/black_model.dart';
import 'package:mirror/data/model/profile/profile_model.dart';
import 'package:mirror/data/model/user_model.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:mirror/data/notifier/token_notifier.dart';
import 'package:mirror/data/notifier/user_interactive_notifier.dart';
import 'package:mirror/widget/interactiveviewer/interactiveview_video_or_image_demo.dart';
import 'package:mirror/widget/interactiveviewer/interactiveviewer_gallery.dart';
import '../message/util/message_chat_page_manager.dart';
import 'package:mirror/page/profile/profile_detail_list.dart';
import 'package:mirror/page/profile/profile_page.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/event_bus.dart';
import 'package:mirror/util/image_cached_observer_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/string_util.dart';
import 'package:mirror/util/text_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/customize_tab_bar/customiize_tab_bar_view.dart';
import 'package:mirror/widget/customize_tab_bar/customize_tab_bar.dart' as Custom;
import 'package:mirror/widget/feed/feed_share_popups.dart';
import 'package:mirror/widget/icon.dart';
import 'package:mirror/widget/round_underline_tab_indicator.dart';
import 'package:provider/provider.dart';

Future<void> jumpToUserProfilePage(BuildContext context, int uId,
    {String avatarUrl, String userName, Function(dynamic result) callback}) async {
  UserModel userModel;
  if (avatarUrl == null || userName == null) {
    userModel = await getUserInfo(uid: uId);
    if (userModel != null) {
      avatarUrl = userModel.avatarUri;
      userName = userModel.nickName;
    }
  }
  AppRouter.navigateToMineDetail(context, uId,
      avatarUrl: avatarUrl, userName: userName, userModel: userModel, callback: callback);
}

class ProfileDetailPage extends StatefulWidget {
  final int userId;
  final String imageUrl;
  final String userName;
  UserModel userModel;

  ProfileDetailPage({this.userId, this.userName, this.imageUrl, this.userModel});

  @override
  _ProfileDetailState createState() {
    return _ProfileDetailState();
  }
}

class _ProfileDetailState extends State<ProfileDetailPage>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {

  //头像size
  final double avatarSize = 71;

  //昵称Id区域高度
  final double nameIdHeight = 53.5;

  //关注,粉丝,点赞高度
  final double followFansHeight = 44;

  //资料板高度
  double userDetailBoardHeight = 0;

  ///昵称
  String _textName;

  ///签名
  String _signature;

  ///头像
  String _avatar;

  TabController _mController;

  ///true是自己的页面，false是别人的页面
  bool isMselfId;

  ///用户信息
  UserModel userModel;

  bool isScroll = false;

  bool canOnClick = true;

  int userStatus;

  final double width = ScreenUtil.instance.screenWidthDp;
  final double height = ScreenUtil.instance.height;

  ///该用户和我的关系
  int relation;
  ScrollController scrollController = ScrollController();
  double _signatureHeight = 10;
  StreamController<bool> loadingStreamController;

  StreamController<double> appBarOpacityStreamController = StreamController<double>();
  bool isBlack = false;
  final GlobalKey<NestedScrollViewState> _key = GlobalKey<NestedScrollViewState>();
  StreamController<bool> needTouchCallBackStreamController = StreamController<bool>();

  @override
  void initState() {
    EventBus.init()
        .registerNoParameter(loginRefreashPage, EVENTBUS_PROFILE_PAGE, registerName: AGAIN_LOGIN_REFREASH_USERPAGE);
    loadingStreamController = StreamController.broadcast();
    _textName = widget.userName ?? "";
    _avatar = widget.imageUrl ?? "";
    print('==============================个人主页initState');
    context.read<UserInteractiveNotifier>().setFirstModel(widget.userId);

    ///判断是自己的页面还是别人的页面

    if (context.read<ProfileNotifier>().profile.uid == widget.userId) {
      isMselfId = true;
    } else {
      isMselfId = false;
      _initBlackStatus();
    }
    _mController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PrimaryScrollController.of(context).addListener(() {
        if (!PrimaryScrollController.of(context).hasClients) return;
        if (PrimaryScrollController.of(context).offset >= userDetailBoardHeight) {
          if (!isScroll) {
            canOnClick = false;
            isScroll = true;
          }
        } else {
          double offset = PrimaryScrollController.of(context).offset /
              (userDetailBoardHeight - ScreenUtil.instance.statusBarHeight - CustomAppBar.appBarHeight);
          if (offset <= 1) {
            appBarOpacityStreamController.sink.add(offset);
          }
          if (isScroll) {
            canOnClick = true;
            isScroll = false;
          }
        }
      });
      print('=========================个人主页addPostFrameCallback');
      Future.delayed(Duration(milliseconds: 250), () {
        _getUserInfo(id: widget.userId);
        _getFollowCount(id: widget.userId);
      });
    });
    super.initState();
  }

  void loginRefreashPage() {
    context.read<UserInteractiveNotifier>().setFirstModel(widget.userId);
    if (context.read<ProfileNotifier>().profile.uid == widget.userId) {
      isMselfId = true;
    } else {
      isMselfId = false;
      _initBlackStatus();
    }
    _getUserInfo(id: widget.userId);
    _getFollowCount(id: widget.userId);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('----------------------------个人主页didChangeDependencies');
  }

  ///获取关注、粉丝、获赞数数
  _getFollowCount({int id}) async {
    ProfileModel attentionModel = await ProfileFollowCount(id: id);
    if (attentionModel != null && mounted) {
      context.read<UserInteractiveNotifier>().changeAttentionModel(attentionModel, widget.userId);
    }
  }

  ///请求黑名单关系
  _initBlackStatus() async {
    BlackModel model = await ProfileCheckBlack(widget.userId);
    if (model != null) {
      if (model.inYouBlack == 1) {
        context.read<UserInteractiveNotifier>().changeBlackStatus(widget.userId, true, needNotify: true);
      } else {
        context.read<UserInteractiveNotifier>().changeBlackStatus(widget.userId, false, needNotify: true);
      }
    }
  }

  ///请求黑名单关系
  _checkBlackStatus() async {
    BlackModel model = await ProfileCheckBlack(widget.userId);
    if (model != null) {
      if (model.inYouBlack == 1) {
        Toast.show("关注失败，你已将对方加入黑名单", context);
        loadingStreamController.sink.add(false);
      } else if (model.inThisBlack == 1) {
        Toast.show("关注失败，你已被对方加入黑名单", context);
        loadingStreamController.sink.add(false);
      } else {
        _getAttention();
      }
    } else {
      loadingStreamController.sink.add(false);
    }
    canOnClick = true;
  }

  ///获取用户信息
  _getUserInfo({int id}) async {
    if (widget.userModel == null) {
      userModel = await getUserInfo(uid: id);
    } else {
      userModel = widget.userModel;
      widget.userModel = null;
    }
    if (userModel != null) {
      _avatar = userModel.avatarUri;
      _signature = userModel.description;
      userStatus = userModel.status;
      print('-------------------------userStatus = ${userModel.status}');
      if (_signature != null) {
        ///判断文字的高度，动态改变
        TextPainter testSize = calculateTextWidth(_signature, AppStyle.textRegular14, width * 0.7, 10);
        _signatureHeight = testSize.height;
      }
      _textName = userModel.nickName;
      if (mounted) {
        setState(() {});
      }
      if (userModel.relation == 0 || userModel.relation == 2) {
        if (mounted && context != null) {
          context.read<UserInteractiveNotifier>().changeIsFollow(true, true, widget.userId);
        }
      } else if (userModel.relation == 1 || userModel.relation == 3) {
        if (mounted && context != null) {
          context.read<UserInteractiveNotifier>().changeIsFollow(true, false, widget.userId);
        }
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    print('=======================================个人主页dispose');
  }

  @override
  void deactivate() {
    // TODO: implement deactivate
    super.deactivate();
    ImageCachedObserverUtil.clearPendingCacheImage();
    print('--------------------------------个人主页deactivate');
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    print('=======================================个人主页build');
    //资料板高度，各部分高度加间距
    userDetailBoardHeight = ScreenUtil.instance.statusBarHeight +
        CustomAppBar.appBarHeight +
        avatarSize +
        nameIdHeight +
        _signatureHeight +
        followFansHeight +
        12 +
        16.5 +
        16 +
        6 +
        16 +
        5;
    return Scaffold(
      backgroundColor: AppColor.mainBlack,
      body: Container(
          height: height,
          width: width,
          child: Stack(
            children: [
              _minehomeBody(),
              Positioned(top: 0, child: _appBar()),
              Positioned(
                  top: 0,
                  child: StreamBuilder<bool>(
                      initialData: true,
                      stream: needTouchCallBackStreamController.stream,
                      builder: (BuildContext stramContext, AsyncSnapshot<bool> snapshot) {
                        if (!snapshot.data) {
                          return Container(
                            color: AppColor.transparent,
                            height: height,
                            width: width,
                          );
                        } else {
                          return Container();
                        }
                      })),
            ],
          )),
    );
  }

  ///这是个人页面，使用TabBarView
  Widget _minehomeBody() {
    return NestedScrollView(
        key: _key,
        controller: PrimaryScrollController.of(context),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        pinnedHeaderSliverHeightBuilder: () {
          return ScreenUtil.instance.statusBarHeight + CustomAppBar.appBarHeight;
        },
        innerScrollPositionKeyBuilder: () {
          String index = 'Tab';

          index += _mController.index.toString();

          return Key(index);
        },
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverToBoxAdapter(
              child: _mineDetailsData(userDetailBoardHeight),
            ),
          ];
        },

        ///根据布尔值返回body
        body: Column(
          children: [
            isMselfId
                ?  Container(
                      color: AppColor.mainBlack,
                      padding: EdgeInsets.only(left: width / 4, right: width / 4),
                      child: Custom.TabBar(
                        unselectedLabelStyle:
                            AppStyle.text1Regular16,
                        unselectedLabelColor: AppColor.textSecondary,
                        labelStyle:
                            AppStyle.whiteMedium16,
                        labelColor: AppColor.white,
                        controller: _mController,
                        onDoubleTap: (index) async {
                          print(
                              'PrimaryScrollController.of(context).offset====${PrimaryScrollController.of(context).offset}------$userDetailBoardHeight-----${(userDetailBoardHeight - ScreenUtil.instance.statusBarHeight - CustomAppBar.appBarHeight)}');
                          if (PrimaryScrollController.of(context).offset != 0 &&
                              PrimaryScrollController.of(context).offset >=
                                  (userDetailBoardHeight -
                                      ScreenUtil.instance.statusBarHeight -
                                      CustomAppBar.appBarHeight)) {
                            needTouchCallBackStreamController.sink.add(false);
                            _key.currentState.currentInnerPosition
                                .animateTo(0.0, duration: Duration(milliseconds: 250), curve: Curves.linear)
                                .then((value) {
                              needTouchCallBackStreamController.sink.add(true);
                            });
                          }
                          // EventBus.getDefault().post(msg: index == 0 ? 2 : 6, registerName: DOUBLE_TAP_TABBAR);
                        },
                        indicatorSize: Custom.TabBarIndicatorSize.label,
                        indicator: RoundUnderlineTabIndicator(
                            insets: EdgeInsets.only(bottom: 0),
                            wantWidth: 20,
                            borderSide: BorderSide(width: 2, color: AppColor.white)),
                        tabs: <Widget>[
                          Tab(text: '动态'),
                          Tab(text: '喜欢'),
                        ],
                      ),
                    )
                : Container(),
            Expanded(
                child: userStatus != 1
                    ? isMselfId
                        ? TabBarView(
                            controller: _mController,
                            physics: ClampingScrollPhysics(),
                            children: <Widget>[
                              ProfileDetailsList(
                                type: 2,
                                id: widget.userId,
                                isMySelf: isMselfId,
                                pageKey: Key("Tab0"),
                              ),
                              ProfileDetailsList(
                                type: 6,
                                isMySelf: isMselfId,
                                id: widget.userId,
                                pageKey: Key("Tab1"),
                              )
                            ],
                          )
                        : ProfileDetailsList(type: 3, isMySelf: isMselfId, id: widget.userId)
                    : Container(
                        padding: EdgeInsets.only(top: 12),
                        color: AppColor.white,
                        child: Column(
                          children: [
                            Center(
                              child: Container(
                                width: 224,
                                height: 224,
                                child: Image.asset(DefaultImage.error),
                              ),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            Center(
                              child: Text(
                                "该账号封禁中·",
                                style: AppStyle.text1Regular14,
                              ),
                            )
                          ],
                        )))
          ],
        ));
  }

  Widget _appBar() {

    double userNameWidth = 0;
    userNameWidth = width - (CustomAppBar.appBarButtonWidth * 2 + 32);
    if (!isMselfId) {
      //居中所以其实左右都是两个icon的宽度
      userNameWidth = width - (CustomAppBar.appBarButtonWidth * 4 + 8 + 32);
    }
    return StreamBuilder<double>(
        initialData: 0,
        stream: appBarOpacityStreamController.stream,
        builder: (BuildContext stramContext, AsyncSnapshot<double> snapshot) {
          return Container(
            color: AppColor.mainBlack.withOpacity(snapshot.data),
            height: CustomAppBar.appBarHeight + ScreenUtil.instance.statusBarHeight,
            width: width,
            padding: EdgeInsets.only(top: ScreenUtil.instance.statusBarHeight),
            child: Center(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                      child: Align(
                    alignment: Alignment.centerLeft,
                    child: CustomAppBarIconButton(
                      svgName: AppIcon.nav_return,
                      iconColor: AppColor.white,
                      onTap: () {
                        Navigator.pop(this.context,
                            context.read<UserInteractiveNotifier>().value.profileUiChangeModel[widget.userId].isFollow);
                      },
                    ),
                  )),
                  Container(
                    width: userNameWidth,
                    child: Center(
                      child: Text(
                        _textName ?? "",
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                            color: AppColor.white.withOpacity(snapshot.data)),
                      ),
                    ),
                  ),
                  Expanded(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CustomAppBarIconButton(
                        svgName: AppIcon.nav_share,
                        iconColor: AppColor.white,
                        onTap: () {
                          openShareBottomSheet(
                              context: context,
                              map: userModel.toJson(),
                              chatTypeModel: ChatTypeModel.MESSAGE_TYPE_USER,
                              sharedType: 1);
                        },
                      ),
                      !isMselfId
                          ? CustomAppBarIconButton(
                              svgName: AppIcon.nav_more,
                              iconColor: AppColor.white,
                              onTap: () {
                                AppRouter.navigateToProfileDetailMore(
                                    context, widget.userId, (result) => _getFollowCount(id: widget.userId));
                              },
                            )
                          : Container(
                              width: 0,
                            ),
                      !isMselfId
                          ? SizedBox(
                              width: 8,
                            )
                          : Container(
                              width: 0,
                            )
                    ],
                  ))
                ],
              ),
            ),
          );
        });
  }

  ///高斯模糊
  Widget profileDetailData(double backGroundHeight) {
    return Container(
      height: backGroundHeight,
      width: width,
      color: AppColor.white,
      child: Stack(
        children: [
          Container(
              height: backGroundHeight - followFansHeight - 28.5,
              width: width,
              child: CachedNetworkImage(
                height: backGroundHeight - followFansHeight - 28.5,
                width: backGroundHeight - followFansHeight - 28.5,
                imageUrl: _avatar != null ? _avatar : "",
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppColor.imageBgGrey,
                ),
                /* errorWidget: (context, url, e) {
                return Image.asset(
                  "images/test.png",
                  fit: BoxFit.cover,
                );
              },*/
              )),
          Positioned(
              top: 0,
              child: Container(
                width: width,
                height: backGroundHeight - followFansHeight - 28.5,
                color: AppColor.white.withOpacity(0.6),
              )),
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
              child: _mineDetailsData(backGroundHeight),
            ),
          ),
        ],
      ),
    );
  }

  ///资料展示
  Widget _mineDetailsData(double containerHeight) {
    return Container(
        height: containerHeight,
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: ScreenUtil.instance.statusBarHeight + CustomAppBar.appBarHeight,
            ),

            ///头像和按钮
            Container(
              padding: EdgeInsets.only(left: 16, right: 16),
              width: width,
              height: avatarSize,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [_mineAvatar(), Spacer(), _mineButton()],
              ),
            ),
            SizedBox(
              height: 16,
            ),
            Container(
              height: nameIdHeight,
              padding: EdgeInsets.only(left: 16, right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ///昵称
                  Text(
                    _textName ?? "  ",
                    style: AppStyle.whiteMedium18,
                  ),
                  Spacer(),

                  ///id
                  Text("ID: ${widget.userId}",style: AppStyle.text1Regular12,),
                ],
              ),
            ),
            SizedBox(
              height: 6,
            ),

            ///签名
            Container(
              padding: EdgeInsets.only(left: 16, right: 16),
              width: width * 0.7,
              child: Text(_signature ?? " ", softWrap: true, style: AppStyle.text1Regular12),
            ),
            SizedBox(
              height: 14,
            ),

            ///关注，获赞，粉丝
            Consumer<UserInteractiveNotifier>(builder: (context, notifier, child) {
              return Container(
                height: followFansHeight,
                padding: EdgeInsets.only(left: 16, right: 16),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        AppRouter.navigateToProfileFollowListPage(context, widget.userId, 1);
                      },
                      child: _textAndNumber(
                          "关注",
                          StringUtil.getNumber(
                              notifier.value.profileUiChangeModel[widget.userId].attentionModel.followingCount)),
                    ),
                    SizedBox(
                      width: 61,
                    ),
                    InkWell(
                      onTap: () {
                        AppRouter.navigateToProfileFollowListPage(context, widget.userId, 2);
                      },
                      child: _textAndNumber(
                          "粉丝",
                          StringUtil.getNumber(
                              notifier.value.profileUiChangeModel[widget.userId].attentionModel.followerCount)),
                    ),
                    SizedBox(
                      width: 61,
                    ),
                    _textAndNumber(
                        "获赞",
                        StringUtil.getNumber(
                            notifier.value.profileUiChangeModel[widget.userId].attentionModel.laudedCount)),
                  ],
                ),
              );
            }),
            Spacer(),
          ],
        ));
  }

  ///关注，编辑资料，私聊按钮
  Widget _mineButton() {
    return Consumer<UserInteractiveNotifier>(builder: (context, notifier, child) {
      return GestureDetector(
          onTap: () {
            if (canOnClick) {
              if (!context.read<TokenNotifier>().isLoggedIn) {
                AppRouter.navigateToLoginPage(context);
                return;
              }
              if (isMselfId) {
                ///这里跳转到编辑资料页
                AppRouter.navigateToEditInfomation(context, (result) {
                  _getUserInfo();
                });
              } else {
                if (notifier.value.profileUiChangeModel[widget.userId].isFollow) {
                  loadingStreamController.sink.add(true);
                  canOnClick = false;
                  _checkBlackStatus();
                } else {
                  ///这里跳转到私聊界面
                  jumpChatPageUser(context, userModel);
                }
              }
            }
          },
          child: Container(
            height: 28,
            width: 72,
            decoration: BoxDecoration(
                color: !isMselfId
                    ? AppColor.mainYellow
                    : AppColor.transparent,
                borderRadius: BorderRadius.all(Radius.circular(14)),
                border: Border.all(
                    width: 0.5,
                    color: isMselfId
                        ? AppColor.black
                        :  AppColor.transparent)),

            ///判断是我的页面还是别人的页面
            child: isMselfId
                ? Center(
                    child: Text(
                      "编辑资料",
                      style: AppStyle.whiteRegular12,
                    ),
                  )
                : _buttonLayoutSelect(notifier),
          ));
    });
  }

  Widget _buttonLayoutSelect(UserInteractiveNotifier notifier) {
    return StreamBuilder<bool>(
        initialData: false,
        stream: loadingStreamController.stream,
        builder: (BuildContext stramContext, AsyncSnapshot<bool> snapshot) {
          return !snapshot.data
              ? Center(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Spacer(),
                      !notifier.value.profileUiChangeModel[widget.userId].isFollow
                          ? AppIcon.getAppIcon(AppIcon.chat_16, 16,color: AppColor.mainBlack)
                          : AppIcon.getAppIcon(AppIcon.add_follow, 16, color: AppColor.mainBlack),
                      SizedBox(
                        width: 2,
                      ),
                      Text(
                        notifier.value.profileUiChangeModel[widget.userId].isFollow ? "关注" : "私聊",
                        style: notifier.value.profileUiChangeModel[widget.userId].isFollow
                            ? TextStyle(color: AppColor.mainBlack, fontSize: 12)
                            : AppStyle.textRegular12,
                      ),
                      Spacer(),
                    ],
                  ),
                )
              : Center(
                  child: Container(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(AppColor.mainRed),
                          backgroundColor: AppColor.white,
                          strokeWidth: 1.5)),
                );
        });
  }

  // 大图预览内部的Item
  Widget itemBuilder(BuildContext context, int index, bool isFocus, Function(Function(bool isFocus), int) setFocus) {
    DemoSourceEntity sourceEntity = DemoSourceEntity(
      widget.userId.toString(),
      " image",
      _avatar,
    );
    print("____sourceEntity:${sourceEntity.toString()}");
    return DemoImageItem(sourceEntity, isFocus, index, setFocus);
  }

  ///头像
  Widget _mineAvatar() {
    return ClipOval(
        child: Hero(
      tag: widget.userId.toString(),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            HeroDialogRoute<void>(builder: (BuildContext context) {
              return InteractiveviewerGallery(sources: [_avatar], initIndex: 0, itemBuilder: itemBuilder);
            }),
          );
        },
        child: CachedNetworkImage(
          height: avatarSize,
          width: avatarSize,
          memCacheHeight: 250,
          memCacheWidth: 250,
          // useOldImageOnUrlChange: true,
          imageUrl: _avatar ?? " ",
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: AppColor.imageBgGrey,
          ),
          errorWidget:(context, url, e) {
            return Container(color: AppColor.imageBgGrey,);
          },
        ),
      ),
    ));
  }

  ///这是关注粉丝获赞
  Widget _textAndNumber(String text, String number) {
    return Container(
        child: Column(
      children: [
        Text(
          number,
          style: AppStyle.whiteMedium18,
        ),
        SizedBox(
          height: 2.5,
        ),
        Text(
          text,
          style: AppStyle.text1Regular12,
        )
      ],
    ));
  }

  _getAttention() async {
    int attntionResult = await ProfileAddFollow(widget.userId);
    if (attntionResult != null) {
      if (attntionResult == 1 || attntionResult == 3) {
        context.read<UserInteractiveNotifier>().changeIsFollow(true, false, widget.userId);
        context.read<UserInteractiveNotifier>().changeFollowCount(widget.userId, true);
        context.read<UserInteractiveNotifier>().removeUserFollowId(widget.userId, isAdd: false);
        ToastShow.show(msg: "关注成功!", context: context);
      }
    }
    loadingStreamController.sink.add(false);
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
