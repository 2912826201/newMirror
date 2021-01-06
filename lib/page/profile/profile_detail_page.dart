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
import 'package:mirror/page/profile/profile_details_more.dart';
import 'package:mirror/page/profile/query_list/query_follow_list.dart';
import 'package:mirror/page/profile/sticky_tabBar.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/text_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/feed/feed_share_popups.dart';
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
  bool get wantKeepAlive => true;
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

  ///动态数
  int _dynmic;

  ///会改变的button里的内容
  String _buttonText = "+ 关注";
  TabController _mController;

  ///动态model
  List<HomeFeedModel> followModel = [];

  ///动态id
  List<int> _followListId = [];

  ///喜欢model
  List<HomeFeedModel> likeModel = [];

  ///喜欢id
  List<int> _likeListId = [];

  ///true是自己的页面，false是别人的页面
  bool isMselfId;

  ///用户信息
  UserModel userModel;

  ///该用户和我的关系
  int relation;

  ///关注否
  bool _isFllow = false;
  String loadingText = "加载中...";
  int likeDataPage = 1;
  int likeLastTime;
  int followDataPage = 1;
  int followlastTime;
  LoadingStatus loadStatus = LoadingStatus.STATUS_IDEL;
  StateResult fllowState = StateResult.RESULTNULL;
  RefreshController _refreshController = new RefreshController();
  double textHeight = 10;
  @override
  void initState() {
    super.initState();
    _mController = TabController(length: 2, vsync: this);

    ///判断是自己的页面还是别人的页面
    if (context.read<ProfileNotifier>().profile.uid == widget.userId) {
      isMselfId = true;
    } else {
      isMselfId = false;
    }
    ///区分接口
    if (isMselfId) {
      _getUserInfo();
      _getFollowCount();
      _getDynamicData(2);
      _getlikeData();
    } else {
      _getUserInfo(id: widget.userId);
      _getFollowCount(id: widget.userId);
      _getDynamicData(3, id: widget.userId);
    }
  }

  ///上拉加载
  _onLoadding() async {
    if (isMselfId) {
      if (_mController.index == 0) {
          followDataPage += 1;
          _getDynamicData(2);
      } else {
          likeDataPage += 1;
        _getlikeData();
      }
    } else {
        followDataPage += 1;
      _getDynamicData(3, id: widget.userId);
    }
  }

    _onRefresh(){
      if (isMselfId) {
        if (_mController.index == 0) {
          followDataPage = 1;
          followlastTime = null;
          _getDynamicData(2);
        } else {
          likeDataPage = 1;
          followlastTime = null;
          _getlikeData();
        }
        _getUserInfo();
      } else {
        likeLastTime = null;
        followDataPage = 1;
        _getDynamicData(3, id: widget.userId);
        _getUserInfo(id: widget.userId);
      }
    }
  ///获取关注、粉丝、动态数
  _getFollowCount({int id}) async {
    ProfileModel attentionModel = await ProfileFollowCount(id: id);
    print(
        'attentionModel========================${attentionModel.followingCount}${attentionModel.feedCount}${attentionModel.followerCount}${attentionModel.followingCount}');
    setState(() {
      _attention = attentionModel.followingCount;
      _fans = attentionModel.followerCount;
      _dynmic = attentionModel.feedCount;
    });
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
          textHeight = testSize.height;
          print('textHeight==============================$textHeight');
        }
        _textName = userModel.nickName;
        relation = userModel.relation;
        if (isMselfId) {
          _buttonText = "编辑资料";
        } else {
          print('判断relation=====================$relation');
          if (relation == 0 || relation == 2) {
            _buttonText = "+ 关注";
            _isFllow = true;
          } else if (relation == 1 || relation == 3) {
            _isFllow = false;
            _buttonText = "私聊";
          }
        }
      });
    }
  }

  _getlikeData() async {
    if (likeDataPage > 1 && likeLastTime == null) {
      _refreshController.loadNoData();
      return;
    }
    DataResponseModel model = await getPullList(type: 6, size: 20, lastTime: likeLastTime);
    setState(() {
      if (likeDataPage == 1) {
        likeModel.clear();
        _likeListId.clear();
        if (model.list.isNotEmpty) {
          model.list.forEach((result) {
            likeModel.add(HomeFeedModel.fromJson(result));
            _likeListId.add(HomeFeedModel.fromJson(result).id);
          });
          _likeListId.insert(0, -1);
          _refreshController.refreshCompleted();
          fllowState = StateResult.HAVARESULT;
        } else {
          _refreshController.resetNoData();
          fllowState = StateResult.RESULTNULL;
        }
      } else if (likeDataPage > 1 && likeLastTime != null) {
        if (model.list.isNotEmpty) {
          model.list.forEach((result) {
            likeModel.add(HomeFeedModel.fromJson(result));
            _likeListId.add(HomeFeedModel.fromJson(result).id);
          });
          _refreshController.loadComplete();
        }
      } else {
        _refreshController.loadNoData();
      }
    });
    likeLastTime = model.lastTime;
    context.read<FeedMapNotifier>().updateFeedMap(likeModel);
  }

  ///获取动态
  _getDynamicData(int type, {int id}) async {
    if (followDataPage > 1 && followlastTime == null) {
      _refreshController.loadNoData();
      return;
    }
    DataResponseModel model = await getPullList(type: type, size: 20, targetId: id, lastTime: followlastTime);
    setState(() {
      if (followDataPage == 1) {
        followModel.clear();
        _followListId.clear();
        if (model.list.isNotEmpty) {
          model.list.forEach((result) {
            followModel.add(HomeFeedModel.fromJson(result));
            _followListId.add(HomeFeedModel.fromJson(result).id);
          });
          _followListId.insert(0, -1);
          fllowState = StateResult.HAVARESULT;
          _refreshController.refreshCompleted();
        } else {
          fllowState = StateResult.RESULTNULL;
          _refreshController.resetNoData();
        }
      } else if (followDataPage > 1 && followlastTime != null) {
        if (model.list.isNotEmpty) {
          model.list.forEach((result) {
            followModel.add(HomeFeedModel.fromJson(result));
            _followListId.add(HomeFeedModel.fromJson(result).id);
          });
          _refreshController.loadComplete();

        }
      } else {
        _refreshController.loadNoData();
      }
    });
    followlastTime = model.lastTime;
    context.read<FeedMapNotifier>().updateFeedMap(followModel);
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
                    /*pc: SingletonForWholePages.singleton().panelController(),*/
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
          controller:  SingletonForWholePages.singleton().panelController(),
          minHeight: 0,
          body: _minehomeBody(width, height)),
    );
  }

  ///这是个人页面，使用TabBarView
  Widget _minehomeBody(double width, double height) {
    return NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            ///这里使用NestedScrollView的AppBar，设置pinned: true,表示不会跟随滚动消失
            SliverAppBar(
              pinned: true,
              leading: InkWell(
                onTap: () {
                  Navigator.pop(this.context,_isFllow);
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
                        context: context, map: userModel.toJson(), chatTypeModel: ChatTypeModel.MESSAGE_TYPE_USER);
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
                              isFollow: _isFllow,
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
                    : Container(width: 0,),
                !isMselfId?SizedBox(
                  width: 15.5,
                ):Container()
              ],
              backgroundColor: AppColor.white,
              expandedHeight: height * 0.41 - ScreenUtil.instance.statusBarHeight + textHeight,

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
                  _ListView(width, _followListId, fllowState, "发布你的第一条动态吧~"),
                  _ListView(width, _likeListId, fllowState, "发布你的第一条动态吧~")
                ],
              )
            : _ListView(width, _followListId, fllowState, "他还没有动态呢~"));
  }

  ///高斯模糊
  Widget mineHomeData(double height, double width) {
    return Container(
      height: height * 0.41 + textHeight,
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
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
            child: _MineDetailsData(height, width),
          ),
        ],
      ),
    );
  }

  ///资料展示
  Widget _MineDetailsData(double height, double width) {
    return Container(
        height: height * 0.41 + textHeight,
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
              height: textHeight,
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
                    child: _TextAndNumber("关注", _attention, height),
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
                    child: _TextAndNumber("粉丝", _fans, height),
                  ),
                  SizedBox(
                    width: 61,
                  ),
                  _TextAndNumber("动态", _dynmic, height),
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

  ///这是动态和喜欢展示的listView
  Widget _ListView(double width, List<int> listId, StateResult state, String nullText) {
    var _ListData = Container(
      width: width,
      color: AppColor.white,

      ///刷新控件
      child: SmartRefresher(
        enablePullUp: true,
        enablePullDown: true,
        footer: CustomFooter(
          builder: (BuildContext context, LoadStatus mode) {
            Widget body;
            if (mode == LoadStatus.loading) {
              body = Text("正在加载");
            } else if (mode == LoadStatus.idle) {
              body = Text("上拉加载更多");
            } else if (mode == LoadStatus.failed) {
              body = Text("加载失败,请重试");
            } else {
              body = Text("没有更多了");
            }
            return Container(
              child: Center(
                child: body,
              ),
            );
          },
        ),
        header: WaterDropHeader(
          complete: Text("刷新完成"),
          failed: Text(""),
        ),
        controller: _refreshController,
        onLoading: _onLoadding,
        onRefresh: _onRefresh,
        child: ListView.builder(
            shrinkWrap: true, //解决无限高度问题
            physics: AlwaysScrollableScrollPhysics(),
            itemCount: listId.length,
            itemBuilder: (context, index) {
              int id = listId[index];
              HomeFeedModel model = context.read<FeedMapNotifier>().feedMap[id];
              if (index == 0) {
                return Container(
                  height: 10,
                );
              } else {
                return DynamicListLayout(
                    index: index,
                    isShowRecommendUser: false,
                    model: model,
                    key: GlobalObjectKey("attention$index"));
              }
            }),
      ),
    );

    ///这里当model为null或者刚进来接口还没获取到的时候放一张图片
    switch (state) {
      case StateResult.RESULTNULL:
        return Expanded(
          child:Container(
            padding: EdgeInsets.only(top: 12),
            color: AppColor.white,
            child: ListView(
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
                    nullText,
                    style: AppStyle.textPrimary3Regular14,
                  ),
                )
              ],
            )));
        break;
      case StateResult.HAVARESULT:
        return _ListData;
        break;
    }
  }

  ///关注，编辑资料，私聊按钮
  Widget _mineButton(double height) {
    return InkWell(
        onTap: () {
          if (isMselfId) {
            ///这里跳转到编辑资料页
            AppRouter.navigationToEditInfomation(context, (result) {
                _getUserInfo();
            });
          } else {
            setState(() {
              if (_buttonText == "+ 关注") {
                _getAttention(true);
              } else if (_buttonText == "取消关注") {
                ///打开dialog
                _getAttention(false);
              } else {
                ///这里跳转到私聊界面
              }
            });
          }
        },
        child: Container(
          height: 28,
          width: 72,
          decoration: BoxDecoration(
              color: _isFllow ? AppColor.mainRed : AppColor.transparent,
              borderRadius: BorderRadius.all(Radius.circular(14)),
              border: Border.all(width: 0.5, color: AppColor.black)),

          ///判断是我的页面还是别人的页面
          child: isMselfId
              ? Center(
                  child: Text(
                    _buttonText,
                    style: AppStyle.textRegular12,
                  ),
                )
              : _buttonLayoutSelect(),
        ));
  }

  ///通过布尔值来判断该展示私聊按钮还是关注按钮
  Widget _buttonLayoutSelect() {
    if (_isFllow) {
      return Center(
          child: Text(
        _buttonText,
        style: TextStyle(color: AppColor.white, fontSize: 12),
      ));
    } else {
      return Center(
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
              _buttonText,
              style: AppStyle.textRegular12,
            ),
          ],
        ),
      );
    }
  }

  ///头像
  Widget _mineAvatar(double height) {
    return Container(
        child: ClipOval(
      child: CachedNetworkImage(
        height: height * 0.09,
        width: height * 0.09,
        imageUrl: _avatar,
        fit: BoxFit.cover,
        placeholder: (context, url) => Image.asset(
          "images/test.png",
          fit: BoxFit.cover,
        ),
      ),
    ));
  }

  ///数值大小判断
  String _getNumber(int number) {
    if (number == 0 || number == null) {
      return 0.toString();
    }
    if (number < 10000) {
      return number.toString();
    } else {
      String db = "${(number / 10000).toString()}";
      if (db.substring(db.indexOf("."), db.indexOf(".") + 2) != "0") {
        String doubleText = db.substring(0, db.indexOf(".") + 2);
        return doubleText + "W";
      } else {
        String intText = db.substring(0, db.indexOf("."));
        return intText + "W";
      }
    }
  }

  ///这是关注粉丝获赞
  Widget _TextAndNumber(String text, int number, double height) {
    return Container(
        child: Column(
      children: [
        Text(
          "${_getNumber(number)}",
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
  _getAttention(bool attention) async {
    int attntionResult = await ProfileAddFollow(widget.userId);
    print('关注监听=========================================$attntionResult');
    if (attntionResult == 1 || attntionResult == 3) {
      ToastShow.show(msg: "关注成功!", context: context);
      _getFollowCount(id: widget.userId);
      _getUserInfo(id: widget.userId);
    }
  }

  calculateTextHeight() {
    String value = "wwwwwwwwwwwwwww";
    TextPainter painter = TextPainter(

        ///AUTO：华为手机如果不指定locale的时候，该方法算出来的文字高度是比系统计算偏小的。
        maxLines: 2,
        textDirection: TextDirection.ltr,
        text: TextSpan(
            text: value,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            )));
    painter.layout(maxWidth: 262);

    ///文字的宽度:painter.width
    print('painter.width==========================${painter.width}');
    print('painter.height==========================${painter.height}');
  }
}
