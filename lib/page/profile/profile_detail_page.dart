import 'dart:async';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/api/user_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/message/chat_type_model.dart';
import 'package:mirror/data/model/profile/black_model.dart';
import 'package:mirror/data/model/profile/profile_model.dart';
import 'package:mirror/data/model/user_model.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:mirror/data/notifier/user_interactive_notifier.dart';
import 'package:mirror/page/message/message_chat_page_manager.dart';
import 'package:mirror/page/profile/profile_detail_list.dart';
import 'package:mirror/page/profile/profile_details_more.dart';
import 'package:mirror/page/profile/profile_page.dart';
import 'package:mirror/page/profile/sticky_tabbar.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/event_bus.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/string_util.dart';
import 'package:mirror/util/text_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/feed/feed_share_popups.dart';
import 'package:mirror/widget/icon.dart';
import 'package:mirror/widget/primary_scrollcontainer.dart';
import 'package:mirror/widget/round_underline_tab_indicator.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

class ProfileDetailPage extends StatefulWidget {
  final int userId;
  final String imageUrl;
  final String userName;

  ProfileDetailPage({this.userId, this.userName, this.imageUrl});

  @override
  _ProfileDetailState createState() {
    return _ProfileDetailState();
  }
}

class _ProfileDetailState extends State<ProfileDetailPage> with TickerProviderStateMixin {
  //头像size
  final double avatarSize = 71;

  //昵称Id区域高度
  final double nameIdHeight = 53.5;

  //关注,粉丝,点赞高度
  final double followFansHeight = 44;

  //资料板高度
  double userDetailBoardHeight = 0;

  int firstTapTime;
  int beforTapType;

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
  List<GlobalKey> scrollChildKeys;
  GlobalKey<PrimaryScrollContainerState> leftKey = GlobalKey();
  GlobalKey<PrimaryScrollContainerState> rightKey = GlobalKey();
  StreamController<double> titleStreamController = StreamController<double>();
  StreamController<bool> loadingStreamController = StreamController<bool>();
  StreamController<double> appBarOpacityStreamController = StreamController<double>();
  StreamController<double> appBarHeightStreamController = StreamController<double>();

  @override
  void initState() {
    super.initState();
    if (widget.userName != null) {
      _textName = widget.userName;
    }
    if (widget.imageUrl != null) {
      _avatar = widget.imageUrl;
    }
    print('==============================个人主页initState');
    context.read<UserInteractiveNotifier>().setFirstModel(widget.userId);

    ///判断是自己的页面还是别人的页面

    if (context.read<ProfileNotifier>().profile.uid == widget.userId) {
      isMselfId = true;
    } else {
      isMselfId = false;
    }
    _mController = TabController(length: 2, vsync: this);
    if (isMselfId) {
      scrollChildKeys = [leftKey, rightKey];
      _mController.addListener(() {
        for (int i = 0; i < scrollChildKeys.length; i++) {
          GlobalKey<PrimaryScrollContainerState> key = scrollChildKeys[i];
          if (key.currentState != null) {
            key.currentState.onPageChange(_mController.index == i); //控制是否当前显示
          }
        }
      });
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('=========================个人主页addPostFrameCallback');
      Future.delayed(Duration(milliseconds: 250), () {
        _getUserInfo(id: widget.userId);
        _getFollowCount(id: widget.userId);
      });
    });
    scrollController.addListener(() {
      if (scrollController.offset >= userDetailBoardHeight) {
        appBarOpacityStreamController.sink.add(1);
        if (!isScroll) {
          appBarHeightStreamController.sink.add(ScreenUtil.instance.statusBarHeight + CustomAppBar.appBarHeight);
          canOnClick = false;
          isScroll = true;
        }
      } else {
        if (scrollController.offset <= ScreenUtil.instance.statusBarHeight + CustomAppBar.appBarHeight) {
          ///这里是因为快速滑动会出现负的offset，会报size.height<0为true的错
          if (scrollController.offset > 0) {
            appBarHeightStreamController.sink.add(scrollController.offset);
          } else {
            appBarHeightStreamController.sink.add(0);
          }
        }
        if (scrollController.offset >= ScreenUtil.instance.statusBarHeight + CustomAppBar.appBarHeight &&
            scrollController.offset < userDetailBoardHeight) {
          double offset =
              (scrollController.offset - (ScreenUtil.instance.statusBarHeight + CustomAppBar.appBarHeight)) /
                  (userDetailBoardHeight - (ScreenUtil.instance.statusBarHeight + CustomAppBar.appBarHeight));
          appBarOpacityStreamController.sink.add(offset);
        } else {
          appBarOpacityStreamController.sink.add(0);
        }
        if (isScroll) {
          canOnClick = true;
          isScroll = false;
        }
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('----------------------------个人主页didChangeDependencies');
  }

  ///获取关注、粉丝、获赞数数
  _getFollowCount({int id}) async {
    ProfileModel attentionModel = await ProfileFollowCount(id: id);
    if (attentionModel != null) {
      context.read<UserInteractiveNotifier>().changeAttentionModel(attentionModel, widget.userId);
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
    userModel = await getUserInfo(uid: id);
    if (userModel != null) {
      setState(() {
        _avatar = userModel.avatarUri;
        _signature = userModel.description;
        userStatus = userModel.status;
        print('-------------------------userStatus = ${userModel.status}');
        if (_signature != null) {
          ///判断文字的高度，动态改变
          TextPainter testSize = calculateTextWidth(_signature, AppStyle.textRegular14, 255, 10);
          _signatureHeight = testSize.height;
        }
        _textName = userModel.nickName;
      });
      if (userModel.relation == 0 || userModel.relation == 2) {
        context.read<UserInteractiveNotifier>().changeIsFollow(true, true, widget.userId);
      } else if (userModel.relation == 1 || userModel.relation == 3) {
        context.read<UserInteractiveNotifier>().changeIsFollow(true, false, widget.userId);
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
    print('--------------------------------个人主页deactivate');
  }

  @override
  Widget build(BuildContext context) {
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
      body: Container(
          height: height,
          width: width,
          child: Stack(
            children: [_minehomeBody(), Positioned(top: 0, child: appBar())],
          )),
    );
  }

  ///这是个人页面，使用TabBarView
  Widget _minehomeBody() {
    return NestedScrollView(
        controller: scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          print('=====================innerBoxIsScrolled$innerBoxIsScrolled');
          return <Widget>[
            ///这里使用NestedScrollView的AppBar，设置pinned: true,表示不会跟随滚动消失
            StreamBuilder<double>(
                initialData: 0,
                stream: appBarHeightStreamController.stream,
                builder: (BuildContext stramContext, AsyncSnapshot<double> snapshot) {
                  return SliverPersistentHeader(
                    pinned: true,
                    delegate: fillingContainerDelegate(
                        height: snapshot.data,
                        color: AppColor.transparent,
                        child: Container(
                          height: snapshot.data,
                        )),
                  );
                }),
            SliverToBoxAdapter(
              child: profileDetailData(userDetailBoardHeight),
            ),

            ///根据布尔值返回视图
            isMselfId
                ? SliverPersistentHeader(
                    /// 可以吸顶的TabBar
                    pinned: true,
                    delegate: StickyTabBarDelegate(
                      width: width,
                      child: TabBar(
                        unselectedLabelStyle: AppStyle.textHintRegular16,
                        unselectedLabelColor: AppColor.textSecondary,
                        labelStyle: AppStyle.textMedium18,
                        labelColor: AppColor.black,
                        indicatorColor: AppColor.black,
                        controller: _mController,
                        onTap: (value) {
                          print('---------------------点击了tab');
                          if (firstTapTime == null) {
                            beforTapType = value;
                            firstTapTime = DateTime.now().millisecondsSinceEpoch;
                          } else {
                            if(beforTapType !=value){
                              firstTapTime = null;
                              beforTapType = value;
                              return;
                            }
                            if (DateTime.now().millisecondsSinceEpoch - firstTapTime <= 250) {
                              print('-----------------------111111111111111111111');
                              EventBus.getDefault().post(msg: value == 0 ? 2 : 6, registerName: DOUBLE_TAP_TABBAR);
                              firstTapTime = null;
                            } else {
                              print('-------------------------222222222222222222222');
                              firstTapTime = DateTime.now().millisecondsSinceEpoch;
                            }
                          }
                        },
                        indicatorSize: TabBarIndicatorSize.label,
                        indicator: RoundUnderlineTabIndicator(
                            insets: EdgeInsets.only(bottom: 0),
                            wantWidth: 20,
                            borderSide: BorderSide(width: 2, color: AppColor.black)),
                        tabs: <Widget>[
                          Tab(text: '动态'),
                          Tab(text: '喜欢'),
                        ],
                      ),
                    ),
                  )
                : SliverToBoxAdapter(
                    child: Container(),
                  )
          ];
        },

        ///根据布尔值返回body
        body: userStatus != 1
            ? isMselfId
                ? TabBarView(
                    controller: _mController,
                    children: <Widget>[
                      PrimaryScrollContainer(
                        scrollChildKeys[0],
                        ProfileDetailsList(
                          type: 2,
                          id: widget.userId,
                          isMySelf: isMselfId,
                        ),
                      ),
                      PrimaryScrollContainer(
                        scrollChildKeys[1],
                        ProfileDetailsList(
                          type: 6,
                          isMySelf: isMselfId,
                          id: widget.userId,
                        ),
                      ),
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
                        style: AppStyle.textPrimary3Regular14,
                      ),
                    )
                  ],
                )));
  }

  Widget appBar() {
    return StreamBuilder<double>(
        initialData: 0,
        stream: appBarOpacityStreamController.stream,
        builder: (BuildContext stramContext, AsyncSnapshot<double> snapshot) {
          return Container(
            color: AppColor.white.withOpacity(snapshot.data),
            height: CustomAppBar.appBarHeight + ScreenUtil.instance.statusBarHeight,
            width: width,
            padding: EdgeInsets.only(top: ScreenUtil.instance.statusBarHeight),
            child: Center(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CustomAppBarIconButton(
                    svgName: AppIcon.nav_return,
                    iconColor: AppColor.black,
                    onTap: () {
                      Navigator.pop(this.context,
                          context.read<UserInteractiveNotifier>().profileUiChangeModel[widget.userId].isFollow);
                    },
                  ),
                  Spacer(),
                  Text(
                    "$_textName",
                    style: TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 18, color: AppColor.black.withOpacity(snapshot.data)),
                  ),
                  Spacer(),
                  CustomAppBarIconButton(
                    svgName: AppIcon.nav_share,
                    iconColor: AppColor.black,
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
                          iconColor: AppColor.black,
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                              return ProfileDetailsMore(
                                userId: widget.userId,
                                userName: _textName,
                              );
                            })).then((value) {
                              _getFollowCount(id: widget.userId);
                            });
                          },
                        )
                      : Container(
                          width: 0,
                        ),
                  !isMselfId
                      ? SizedBox(
                          width: 8,
                        )
                      : Container()
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
                  color: AppColor.bgWhite,
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
                    _textName != null ? _textName : "  ",
                    style: AppStyle.textMedium18,
                  ),
                  Spacer(),

                  ///id
                  Text("ID: ${widget.userId}"),
                ],
              ),
            ),
            SizedBox(
              height: 6,
            ),

            ///签名
            Container(
              height: _signatureHeight,
              padding: EdgeInsets.only(left: 16, right: 16),
              width: width * 0.7,
              child: Text(_signature != null ? _signature : "      ", softWrap: true, style: AppStyle.textRegular14),
            ),
            SizedBox(
              height: 16,
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
                              notifier.profileUiChangeModel[widget.userId].attentionModel.followingCount)),
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
                              notifier.profileUiChangeModel[widget.userId].attentionModel.followerCount)),
                    ),
                    SizedBox(
                      width: 61,
                    ),
                    _textAndNumber("获赞",
                        StringUtil.getNumber(notifier.profileUiChangeModel[widget.userId].attentionModel.laudedCount)),
                  ],
                ),
              );
            }),
            Spacer(),
            Container(
              color: AppColor.bgWhite.withOpacity(0.65),
              height: 12,
              width: width,
            )
          ],
        ));
  }

  ///关注，编辑资料，私聊按钮
  Widget _mineButton() {
    return Consumer<UserInteractiveNotifier>(builder: (context, notifier, child) {
      return GestureDetector(
          onTap: () {
            if (canOnClick) {
              if (isMselfId) {
                ///这里跳转到编辑资料页
                AppRouter.navigateToEditInfomation(context, (result) {
                  _getUserInfo();
                });
              } else {
                if (notifier.profileUiChangeModel[widget.userId].isFollow) {
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
                    ? notifier.profileUiChangeModel[widget.userId].isFollow
                        ? AppColor.mainRed
                        : AppColor.transparent
                    : AppColor.transparent,
                borderRadius: BorderRadius.all(Radius.circular(14)),
                border: Border.all(
                    width: 0.5,
                    color: isMselfId
                        ? AppColor.black
                        : !notifier.profileUiChangeModel[widget.userId].isFollow
                            ? AppColor.black
                            : AppColor.transparent)),

            ///判断是我的页面还是别人的页面
            child: isMselfId
                ? Center(
                    child: Text(
                      "编辑资料",
                      style: AppStyle.textRegular12,
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
                      !notifier.profileUiChangeModel[widget.userId].isFollow
                          ? Icon(
                              Icons.message,
                              size: 16,
                            )
                          : AppIcon.getAppIcon(AppIcon.add_follow, 16, color: AppColor.white),
                      SizedBox(
                        width: 2,
                      ),
                      Text(
                        notifier.profileUiChangeModel[widget.userId].isFollow ? "关注" : "私聊",
                        style: notifier.profileUiChangeModel[widget.userId].isFollow
                            ? TextStyle(color: AppColor.white, fontSize: 12)
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

  ///头像
  Widget _mineAvatar() {
    return Container(
      child: ClipOval(
        child: CachedNetworkImage(
          height: avatarSize,
          width: avatarSize,
          useOldImageOnUrlChange: true,
          imageUrl: _avatar != null ? FileUtil.getMediumImage(_avatar) : " ",
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: AppColor.bgWhite,
          ),
          /*errorWidget:(context, url, e) {
            return Container(color: AppColor.bgWhite,);
          },*/
        ),
      ),
    );
  }

  ///这是关注粉丝获赞
  Widget _textAndNumber(String text, String number) {
    return Container(
        child: Column(
      children: [
        Text(
          number,
          style: AppStyle.textMedium18,
        ),
        SizedBox(
          height: 2.5,
        ),
        Text(
          text,
          style: AppStyle.textSecondaryRegular12,
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
        ToastShow.show(msg: "关注成功!", context: context);
      }
    }
    loadingStreamController.sink.add(false);
  }
}
