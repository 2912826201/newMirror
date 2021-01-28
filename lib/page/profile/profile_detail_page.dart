import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/api/user_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/data_response_model.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/data/model/message/chat_type_model.dart';
import 'package:mirror/data/model/profile/profile_model.dart';
import 'package:mirror/data/model/user_model.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:mirror/page/home/sub_page/recommend_page.dart';
import 'package:mirror/page/home/sub_page/share_page/dynamic_list.dart';
import 'package:mirror/page/home/sub_page/share_page/share_page_sub_page/comment_bottom_sheet.dart';
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
import 'package:mirror/widget/round_underline_tab_indicator.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../if_page.dart';

enum StateResult { HAVARESULT, RESULTNULL }

///判断lastTime，控件的controller冲突
class ProfileDetailPage extends StatefulWidget {
  int userId;

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

  ///id
  int _id;

  ///签名
  String _signature;

  ///头像
  String _avatar = "";

  ///关注数
  int _attention;

  ///粉丝数
  int _fans;

  ///获赞数
  int _lauded;

  ///会改变的button里的内容
  String _buttonText = "+ 关注";
  TabController _mController;

  ///true是自己的页面，false是别人的页面
  bool isMselfId;

  ///用户信息
  UserModel userModel;

  ///该用户和我的关系
  int relation;

  ScrollController scrollController = ScrollController();
  double _signatureHeight = 10;
  Color titleColor = AppColor.transparent;

  @override
  void initState() {
    super.initState();
    context.read<ProfilePageNotifier>().setFirstModel(widget.userId);
    _mController = TabController(length: 2, vsync: this);

    ///判断是自己的页面还是别人的页面
    if (context.read<ProfileNotifier>().profile.uid == widget.userId) {
      isMselfId = true;
    } else {
      isMselfId = false;
    }
    WidgetsBinding.instance.addPostFrameCallback((_){
      _getUserInfo(id: widget.userId);
      _getFollowCount(id: widget.userId);
    });
    scrollController.addListener(() {
      /* if (scrollController.hasClients) {*/
      if (scrollController.offset >=
          ScreenUtil.instance.height * 0.33 + _signatureHeight) {
        context.read<ProfilePageNotifier>().changeTitleColor(AppColor.bgBlack);
        context.read<ProfilePageNotifier>().changeOnClick(false);
      } else {
        context.read<ProfilePageNotifier>().changeTitleColor(AppColor.transparent);
        context.read<ProfilePageNotifier>().changeOnClick(true);
        /*  }*/
      }
    });
  }

  ///获取关注、粉丝、动态数
  _getFollowCount({int id}) async {
    ProfileModel attentionModel = await ProfileFollowCount(id: id);
    print(
        'attentionModel========================${attentionModel.followingCount}${attentionModel.feedCount}${attentionModel.laudedCount}');
    print('====关注数========================${attentionModel.followingCount}');
    print('====粉丝数========================${attentionModel.followerCount}');
    print('====点赞数========================${attentionModel.laudedCount}');

    if (attentionModel != null) {
      context.read<ProfilePageNotifier>().changeAttentionModel(attentionModel,widget.userId);
    }
  }

  ///获取用户信息
  _getUserInfo({int id}) async {
    userModel = await getUserInfo(uid: id);
    if (userModel != null) {
      print('获取relation=============================${userModel.relation}');
      print('获取用户签名==============================${userModel.description}');
      setState(() {
        _avatar = userModel.avatarUri;
        _id = userModel.uid;
        _signature = userModel.description;
        if (_signature != null) {
          ///判断文字的高度，动态改变
          TextPainter testSize = calculateTextWidth(_signature, AppStyle.textRegular14, 255, 5);
          _signatureHeight = testSize.height;
          print('textHeight==============================$_signatureHeight');
        }
        _textName = userModel.nickName;
        relation = userModel.relation;
        if (!isMselfId) {
          print('判断relation=====================$relation');
        }
      });
      if (relation == 0 || relation == 2) {
        context.read<ProfilePageNotifier>().changeIsFollow(true,widget.userId);
      } else if (relation == 1 || relation == 3) {
        context.read<ProfilePageNotifier>().changeIsFollow(false,widget.userId);
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    print('=======================================个人主页dispose');
    SingletonForWholePages.singleton().closePanelController();
  }

  @override
  Widget build(BuildContext context) {
    print('=======================================个人主页build');
    double width = ScreenUtil.instance.screenWidthDp;
    double height = ScreenUtil.instance.height;
    return Scaffold(
      appBar: null,
      body: SlidingUpPanel(
          panel: Container(
            child: context.watch<FeedMapNotifier>().feedId != null
                ? CommentBottomSheet(
                    feedId: context.select((FeedMapNotifier value) => value.feedId),
                  )
                : Container(),
          ),
          onPanelClosed: () {
            context.read<FeedMapNotifier>().clearTotalCount();

            /// 关闭视图后清空动态Id
            context.read<FeedMapNotifier>().changeFeeId(null);
          },
          maxHeight: ScreenUtil.instance.height * 0.75,
          backdropEnabled: true,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10.0),
            topRight: Radius.circular(10.0),
          ),
          controller: SingletonForWholePages.singleton().panelController(),
          minHeight: 0,
          body: _minehomeBody(width, height)),
    );
  }

  ///这是个人页面，使用TabBarView
  Widget _minehomeBody(double width, double height) {
    return NestedScrollView(
        controller: scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            ///这里使用NestedScrollView的AppBar，设置pinned: true,表示不会跟随滚动消失
            SliverAppBar(
              pinned: true,
              forceElevated: false,
              centerTitle: true,
              title: Text(
                "$_textName",
                style: TextStyle(
                    fontWeight: FontWeight.w500, fontSize: 18, color: context.watch<ProfilePageNotifier>().titleColor),
              ),
              leading: InkWell(
                onTap: () {
                  context.read<ProfilePageNotifier>().clearTitleColor();
                  Navigator.pop(this.context, context.read<ProfilePageNotifier>().isFollow);
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
                              isFollow: context.watch<ProfilePageNotifier>().isFollow[widget.userId],
                              userName: _textName,
                            );
                          })).then((value) {
                            if (value) {
                              _getUserInfo(id: widget.userId);
                              _getFollowCount(id: widget.userId);
                            }
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
        body: isMselfId
            ? TabBarView(
                controller: _mController,
                children: <Widget>[
                  ProfileDetailsList(
                    type: 2,
                    id: widget.userId,
                  ),
                  ProfileDetailsList(
                    type: 6,
                    id: widget.userId,
                  )
                ],
              )
            : ProfileDetailsList(type: 3, id: widget.userId));
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
              child: ClipOval(
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
              )),
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
            SizedBox(
              height: height * 0.02,
            ),

            ///昵称
            Container(
              padding: EdgeInsets.only(left: 16, right: 16),
              child: Text(
                _textName != null ? _textName : "  ",
                style: AppStyle.textMedium18,
              ),
            ),
            SizedBox(
              height: height * 0.02,
            ),

            ///id
            Container(
              padding: EdgeInsets.only(left: 16, right: 16),
              child: Text("ID: $_id"),
            ),
            SizedBox(
              height: height * 0.007,
            ),

            ///签名
            Container(
              height: _signatureHeight,
              padding: EdgeInsets.only(left: 16, right: 16),
              width: width * 0.7,
              child: Text(_signature != null ? _signature : "      ", softWrap: true, style: AppStyle.textRegular14),
            ),
            SizedBox(
              height: height * 0.01,
            ),

            ///关注，获赞，粉丝
            Container(
              padding: EdgeInsets.only(left: 16, right: 16),
              child: Row(
                children: [
                  InkWell(
                    child: _textAndNumber(
                        "关注",
                        StringUtil.getNumber(context.read<ProfilePageNotifier>().attentionModel[widget.userId].followingCount),
                        height),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                        return QueryFollowList(
                          type: 1,
                          userId: _id,
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
                          userId: _id,
                        );
                      }));
                    },
                    child: _textAndNumber("粉丝",
                        StringUtil.getNumber(context.read<ProfilePageNotifier>().attentionModel[widget.userId].followerCount), height),
                  ),
                  SizedBox(
                    width: 61,
                  ),
                  _textAndNumber("获赞",
                      StringUtil.getNumber(context.read<ProfilePageNotifier>().attentionModel[widget.userId].laudedCount), height),
                ],
              ),
            ),
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
    return InkWell(
        onTap: () {
          if(context.read<ProfilePageNotifier>().canOnClick){
            if (isMselfId) {
              ///这里跳转到编辑资料页
              AppRouter.navigateToEditInfomation(context, (result) {
                _getUserInfo();
              });
            } else {
              print('isFollow================================${context.read<ProfilePageNotifier>().isFollow}');
              if (context.read<ProfilePageNotifier>().isFollow[widget.userId]) {
                _getAttention();
              } else {
                ///这里跳转到私聊界面
                jumpChatPageUser(context, userModel);
              }
            }
          }else{
            return false;
          }
        },
        child: Container(
          height: 28,
          width: 72,
          decoration: BoxDecoration(
              color: !isMselfId
                  ? context.read<ProfilePageNotifier>().isFollow[widget.userId]
                      ? AppColor.mainRed
                      : AppColor.transparent
                  : AppColor.transparent,
              borderRadius: BorderRadius.all(Radius.circular(14)),
              border: Border.all(width: 0.5, color: AppColor.black)),

          ///判断是我的页面还是别人的页面
          child: isMselfId
              ? Center(
                  child: Text(
                    "编辑资料",
                    style: AppStyle.textRegular12,
                  ),
                )
              : _buttonLayoutSelect(),
        ));
  }

  ///通过布尔值来判断该展示私聊按钮还是关注按钮
  Widget _buttonLayoutSelect() {
    return Stack(
      children: [
        ///关注按钮
        Opacity(
          opacity: context.read<ProfilePageNotifier>().isFollow[widget.userId] ? 1 : 0,
          child: Center(
              child: Text(
            "+ 关注",
            style: TextStyle(color: AppColor.white, fontSize: 12),
          )),
        ),

        ///私聊按钮
        Opacity(
          opacity: context.read<ProfilePageNotifier>().isFollow[widget.userId] ? 0 : 1,
          child: Center(
            child: Row(
              children: [
                SizedBox(
                  width: 15,
                ),
                Image.asset(
                  "images/test/comment-filling.png",
                  width: 12,
                  height: 12,
                ),
                SizedBox(
                  width: 2,
                ),
                Text(
                  "私聊",
                  style: AppStyle.textRegular12,
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  ///头像
  Widget _mineAvatar(double height) {
    return Container(
        child: Hero(
          tag: "我的头像",
          child: ClipOval(
      child: CachedNetworkImage(
          height: height * 0.09,
          width: height * 0.09,
          imageUrl: _avatar,
          fit: BoxFit.cover,
          placeholder: (context, url) => CircularProgressIndicator()),
    ),));
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

  ///这是取消关注和关注的方法，true为关注，false为取消关注
  _getAttention() async {
    int attntionResult = await ProfileAddFollow(widget.userId);
    print('关注监听=========================================$attntionResult');
    if (attntionResult == 1 || attntionResult == 3) {
      context.read<ProfilePageNotifier>().changeIsFollow(false,widget.userId);
      _getFollowCount(id: widget.userId);
      ToastShow.show(msg: "关注成功!", context: context);
    }
  }
}

class ProfilePageNotifier extends ChangeNotifier {
  Color titleColor = AppColor.transparent;

  String backImage = "images/resource/2.0x/white_return@2x.png";

  Map<int,ProfileModel> attentionModel = {};

  Map<int,bool> isFollow = {};

  bool canOnClick = true;

  void setFirstModel(int id){
    attentionModel[id] = ProfileModel();
    isFollow[id] = false;
    notifyListeners();
  }
  void changeIsFollow(bool bl,int id) {
    isFollow[id] = bl;
    print('changeIsFollow============================$isFollow');
    notifyListeners();
  }
  void changeOnClick(bool canClick){
    canOnClick = canClick;
    notifyListeners();
  }
  void changeAttentionModel(ProfileModel model,int id) {
    attentionModel[id] = model;
    notifyListeners();
  }

  void clearAttentionModel(){
    attentionModel = null;

  }

  void changeTitleColor(Color color) {
    titleColor = color;
    notifyListeners();
  }

  void clearTitleColor() {
    titleColor = AppColor.transparent;
    notifyListeners();
  }

  void changeBackImage(String image) {
    backImage = image;
    notifyListeners();
  }

  void clearBackImage() {
    backImage = "images/resource/2.0x/white_return@2x.png";
    notifyListeners();
  }
}
