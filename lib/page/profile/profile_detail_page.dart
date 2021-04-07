import 'dart:async';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/api/user_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/message/chat_type_model.dart';
import 'package:mirror/data/model/profile/black_model.dart';
import 'package:mirror/data/model/profile/profile_model.dart';
import 'package:mirror/data/model/user_extrainfo_model.dart';
import 'package:mirror/data/model/user_model.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:mirror/data/notifier/token_notifier.dart';
import 'package:mirror/data/notifier/user_interactive_notifier.dart';
import 'package:mirror/page/message/message_chat_page_manager.dart';
import 'package:mirror/page/profile/profile_detail_list.dart';
import 'package:mirror/page/profile/profile_details_more.dart';
import 'package:mirror/page/profile/query_list/query_follow_list.dart';
import 'package:mirror/page/profile/sticky_tabbar.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/string_util.dart';
import 'package:mirror/util/text_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/feed/feed_share_popups.dart';
import 'package:mirror/widget/primary_scrollcontainer.dart';
import 'package:mirror/widget/round_underline_tab_indicator.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

enum StateResult { HAVERESULT, RESULTNULL }

class ProfileDetailPage extends StatefulWidget {
  final int userId;

  ProfileDetailPage({this.userId});

  @override
  _ProfileDetailState createState() {
    return _ProfileDetailState();
  }
}

class _ProfileDetailState extends State<ProfileDetailPage> with TickerProviderStateMixin {
  final String _imgShared = "images/test/分享.png";
  final String _imgMore = "images/test/ic_big_dynamic_more.png";

  ///昵称
  String _textName;

  ///签名
  String _signature;

  ///头像
  String _avatar = "";

  TabController _mController;

  ///true是自己的页面，false是别人的页面
  bool isMselfId;

  ///用户信息
  UserModel userModel;

  int isBlack = 0;

  bool isScroll = false;

  bool canOnClick = true;

  int userStatus;

  ///该用户和我的关系
  int relation;
  ScrollController scrollController = ScrollController();
  double _signatureHeight = 10;
  List<GlobalKey> scrollChildKeys;
  GlobalKey<PrimaryScrollContainerState> leftKey = GlobalKey();
  GlobalKey<PrimaryScrollContainerState> rightKey = GlobalKey();
  StreamController<Color> streamController = StreamController<Color>();
  StreamController<bool> loadingStreamController = StreamController<bool>();

  @override
  void initState() {
    super.initState();
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
      if (scrollController.offset >= ScreenUtil.instance.height * 0.33 + _signatureHeight) {
        if (!isScroll) {
          streamController.sink.add(AppColor.black);
          canOnClick = false;
          isScroll = true;
        }
      } else {
        if (isScroll) {
          streamController.sink.add(AppColor.transparent);
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
    }else{
      loadingStreamController.sink.add(false);
    }
    canOnClick = true;
  }

  ///获取用户信息
  _getUserInfo({int id}) async {
    userModel = await getUserInfo(uid: id);
    if (userModel != null) {
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
      if (mounted) {
        setState(() {});
      }
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
    double width = ScreenUtil.instance.screenWidthDp;
    double height = ScreenUtil.instance.height;
    return Scaffold(
      appBar: null,
      body: _minehomeBody(width, height),
    );
  }

  ///这是个人页面，使用TabBarView
  Widget _minehomeBody(double width, double height) {
    return NestedScrollView(
        controller: scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          print('=====================innerBoxIsScrolled$innerBoxIsScrolled');
          return <Widget>[
            ///这里使用NestedScrollView的AppBar，设置pinned: true,表示不会跟随滚动消失
            SliverAppBar(
              brightness: Brightness.light,
              pinned: true,
              forceElevated: false,
              elevation: 0.5,
              centerTitle: true,
              title: StreamBuilder<Color>(
                  initialData: AppColor.transparent,
                  stream: streamController.stream,
                  builder: (BuildContext stramContext, AsyncSnapshot<Color> snapshot) {
                    return Text(
                      "$_textName",
                      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18, color: snapshot.data),
                    );
                  }),

              leading: InkWell(
                onTap: () {
                  Navigator.pop(this.context,
                      context.read<UserInteractiveNotifier>().profileUiChangeModel[widget.userId].isFollow);
                },
                child: Image.asset(
                  "images/test/back.png",
                  width: 24,
                  height: 24,
                ),
              ),
              actions: [
                InkWell(
                  onTap: () {
                    openShareBottomSheet(
                        context: context,
                        map: userModel.toJson(),
                        chatTypeModel: ChatTypeModel.MESSAGE_TYPE_USER,
                        sharedType: 1);
                  },
                  child: Image.asset(
                    _imgShared,
                    width: 24,
                    height: 24,
                  ),
                ),
                SizedBox(
                  width: 16,
                ),
                !isMselfId
                    ? InkWell(
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
                        child: Image.asset(
                          _imgMore,
                          width: 24,
                          height: 24,
                        ),
                      )
                    : Container(
                        width: 0,
                      ),
                !isMselfId
                    ? SizedBox(
                        width: 15.5,
                      )
                    : Container()
              ],
              backgroundColor: AppColor.white,
              expandedHeight: height * 0.41 - ScreenUtil.instance.statusBarHeight + _signatureHeight,

              ///这里是资料展示页,写在这个里面相当于是appBar的背景板
              flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                child: mineHomeData(height, width),
              )),
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
                        indicatorSize: TabBarIndicatorSize.label,
                        indicator: RoundUnderlineTabIndicator(
                            insets: EdgeInsets.only(bottom: 0),
                            wantWidth: 20,
                            borderSide: BorderSide(
                              width: 2,
                              color: AppColor.black,
                            )),
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
                        color: AppColor.bgWhite.withOpacity(0.65),
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

  ///高斯模糊
  Widget mineHomeData(double height, double width) {
    return Container(
      height: height * 0.41 + _signatureHeight,
      color: AppColor.white,
      child: Stack(
        children: [
          Container(
            height: height * 0.33,
            width: width,
            child: CachedNetworkImage(
              height: height * 0.33,
              width: height * 0.33,
              imageUrl: _avatar,
              fit: BoxFit.cover,
              placeholder: (context, url) => Image.asset(
                "images/test.png",
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
              top: 0,
              child: Container(
                width: width,
                height: height * 0.33,
                color: AppColor.white.withOpacity(0.6),
              )),
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
              child: _mineDetailsData(height, width),
            ),
          ),
        ],
      ),
    );
  }

  ///资料展示
  Widget _mineDetailsData(double height, double width) {
    return Container(
        height: height * 0.41 + _signatureHeight,
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: ScreenUtil.instance.statusBarHeight + height * 0.07,
            ),

            ///头像和按钮
            Container(
              padding: EdgeInsets.only(left: 16, right: 16),
              width: width,
              child: Stack(
                children: [_mineAvatar(height), Positioned(right: 0, top: 24, child: _mineButton(height))],
              ),
            ),
            Spacer(),

            ///昵称
            Container(
              padding: EdgeInsets.only(left: 16, right: 16),
              child: Text(
                _textName != null ? _textName : "  ",
                style: AppStyle.textMedium18,
              ),
            ),
            Spacer(),

            ///id
            Container(
              padding: EdgeInsets.only(left: 16, right: 16),
              child: Text("ID: ${widget.userId}"),
            ),
            Spacer(),

            ///签名
            Container(
              height: _signatureHeight,
              padding: EdgeInsets.only(left: 16, right: 16),
              width: width * 0.7,
              child: Text(_signature != null ? _signature : "      ", softWrap: true, style: AppStyle.textRegular14),
            ),
            Spacer(),

            ///关注，获赞，粉丝
            Consumer<UserInteractiveNotifier>(builder: (context, notifier, child) {
              return Container(
                padding: EdgeInsets.only(left: 16, right: 16),
                child: Row(
                  children: [
                    InkWell(
                      child: _textAndNumber(
                          "关注",
                          StringUtil.getNumber(
                              notifier.profileUiChangeModel[widget.userId].attentionModel.followingCount),
                          height),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                          return QueryFollowList(
                            type: 1,
                            userId: widget.userId,
                          );
                        }));
                      },
                    ),
                    SizedBox(
                      width: 61,
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                          return QueryFollowList(
                            type: 2,
                            userId: widget.userId,
                          );
                        }));
                      },
                      child: _textAndNumber(
                          "粉丝",
                          StringUtil.getNumber(
                              notifier.profileUiChangeModel[widget.userId].attentionModel.followerCount),
                          height),
                    ),
                    SizedBox(
                      width: 61,
                    ),
                    _textAndNumber(
                        "获赞",
                        StringUtil.getNumber(notifier.profileUiChangeModel[widget.userId].attentionModel.laudedCount),
                        height),
                  ],
                ),
              );
            }),
            Spacer(),
            Container(
              color: AppColor.bgWhite.withOpacity(0.65),
              height: height * 0.01,
              width: width,
            )
          ],
        ));
  }

  ///关注，编辑资料，私聊按钮
  Widget _mineButton(double height) {
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
            } else {
              return false;
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
   return  StreamBuilder<bool>(
        initialData: false,
        stream: loadingStreamController.stream,
        builder: (BuildContext stramContext, AsyncSnapshot<bool> snapshot) {
         return !snapshot.data
             ?Center(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Spacer(),
                !notifier.profileUiChangeModel[widget.userId].isFollow ?Icon(Icons.message,size: 14,):Icon(Icons.add,
                  color:
                AppColor.white,size: 14),
                SizedBox(
                  width: 2,
                ),
                Text(
                  notifier.profileUiChangeModel[widget.userId].isFollow?"关注":"私聊",
                  style:notifier.profileUiChangeModel[widget.userId].isFollow?TextStyle(color: AppColor.white, fontSize: 12):AppStyle.textRegular12,
                ),
                Spacer(),
              ],
            ),
          ):Center(
           child: Container(
             height: 16,
             width: 16,
             child: CircularProgressIndicator(
                 valueColor: AlwaysStoppedAnimation(AppColor.mainRed), backgroundColor: AppColor.white, strokeWidth: 1.5)),)
         ;});
  }

  ///头像
  Widget _mineAvatar(double height) {
    return Container(
      child: ClipOval(
        child: CachedNetworkImage(
            height: height * 0.09,
            width: height * 0.09,
            imageUrl: isMselfId ? context.read<ProfileNotifier>().profile.avatarUri : _avatar,
            fit: BoxFit.cover,
            placeholder: (context, url) => CircularProgressIndicator()),
      ),
    );
  }

  ///这是关注粉丝获赞
  Widget _textAndNumber(String text, String number, double height) {
    return Container(
        child: Column(
      children: [
        Text(
          number,
          style: AppStyle.textMedium18,
        ),
        SizedBox(
          height: height * 0.008,
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
    if(attntionResult!=null){
      if (attntionResult == 1 || attntionResult == 3) {
        context.read<UserInteractiveNotifier>().changeIsFollow(true, false, widget.userId);
        context.read<UserInteractiveNotifier>().changeFollowCount(widget.userId, true);
        ToastShow.show(msg: "关注成功!", context: context);
      }
    }
    loadingStreamController.sink.add(false);
  }
}
