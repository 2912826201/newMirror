import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/api/user_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/data_response_model.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/data/model/profile_model.dart';
import 'package:mirror/data/model/user_model.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:mirror/page/home/sub_page/recommend_page.dart';
import 'package:mirror/page/home/sub_page/share_page/dynamic_list.dart';
import 'package:mirror/page/home/sub_page/share_page/share_page_sub_page/comment_bottom_sheet.dart';
import 'package:mirror/page/profile/profile_details_more.dart';
import 'package:mirror/page/profile/sticky_tabBar.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/feed/feed_share_popups.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

enum  StateResult{
  HAVARESULT,
  RESULTNULL
}


///判断lastTime，控件的controller冲突
class ProfileDetailPage extends StatefulWidget {
  int userId;
  ProfileDetailPage({this.userId});

  @override
  _ProfileDetailState createState() {
    return _ProfileDetailState();
  }
}

class _ProfileDetailState extends State<ProfileDetailPage>
    with TickerProviderStateMixin {
  bool get wantKeepAlive => true;
  final String _imgShared = "images/test/分享.png";
  final String _imgMore = "images/test/ic_big_dynamic_more.png";
  final _Panelcontroller = PanelController();
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
  String _buttonText = "";
  TabController _mController;
  ///动态model
  List<HomeFeedModel> attentionModel = [];
  ///动态id
  List<int> _listId = [];
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
  int fllowDataPage = 1;
  int lastTime;
  LoadingStatus loadStatus = LoadingStatus.STATUS_IDEL;
  StateResult fllowState = StateResult.RESULTNULL;
  RefreshController _refreshController = new RefreshController();
  @override
  void initState() {
    super.initState();
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
    } else {
      _getUserInfo(id: widget.userId);
      _getFollowCount(id: widget.userId);
      _getDynamicData(3, id: widget.userId);
    }
    _mController = TabController(length: 2, vsync: this);
  }
    ///上拉加载
  _onLoadding()async{
    if(isMselfId){
      if(_mController.index==0){
        fllowDataPage+=1;
        _getDynamicData(2);
      }else{
      }
    }else{
      fllowDataPage+=1;
      _getDynamicData(3, id: widget.userId);
    }
  }
    ///获取关注、粉丝、动态数
  _getFollowCount({int id}) async {
    ProfileModel attentionModel = await ProfileFollowCount(id: id);
    print('attentionModel========================${attentionModel.followingCount}${attentionModel.feedCount}${attentionModel.followerCount}${attentionModel.followingCount}');
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
        _textName = userModel.nickName;
        relation = userModel.relation;
        if (isMselfId) {
          _buttonText = "编辑资料";
        } else {
          print('判断relation=====================$relation');
          if (relation == 0 || relation == 2){
            _buttonText = "+ 关注";
            _isFllow = true;
          } else{
            _isFllow = false;
            _buttonText = "私聊";
          }
        }
      });
    }
  }
    ///获取动态
  _getDynamicData(int type, {int id}) async {
    if(fllowDataPage>1&&lastTime==null){
      _refreshController.loadNoData();
      return;
    }
    DataResponseModel model =
        await getPullList(type: type, size: 20, targetId: id,lastTime:lastTime);
    setState(() {
      if(fllowDataPage==1){
        if (model.list.isNotEmpty) {
          model.list.forEach((result) {
              attentionModel.add(HomeFeedModel.fromJson(result));
            _listId.add(HomeFeedModel.fromJson(result).id);
          });
          _listId.insert(0,-1);
          fllowState = StateResult.HAVARESULT;
        }else{
          fllowState = StateResult.RESULTNULL;
        }
      }else if(fllowDataPage>1&&lastTime!=null){
        if (model.list.isNotEmpty) {
          model.list.forEach((result) {
            attentionModel.add(HomeFeedModel.fromJson(result));
            _listId.add(HomeFeedModel.fromJson(result).id);
          });
          _refreshController.loadComplete();
        }
      }else{
        _refreshController.loadNoData();
      }

    });
    lastTime = model.lastTime;
    context.read<FeedMapNotifier>().updateFeedMap(attentionModel);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(builder: (context) {
        double width =ScreenUtil.instance.screenWidthDp;
        double height =ScreenUtil.instance.height;
        return Scaffold(
          appBar: null,
          body: SlidingUpPanel(
              panel: Container(
                child:context.watch<FeedMapNotifier>().feedId !=null?
                CommentBottomSheet(
                  pc: _Panelcontroller,
                  feedId: context.select((FeedMapNotifier value) => value.feedId),
                ):Container(),
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
              controller: _Panelcontroller,
              minHeight: 0,
              body:  _minehomeBody(width, height)
           ),
        );
      }),
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
              onTap: (){
                Navigator.pop(this.context);
              },
              child: Image.asset("images/test/back.png",width: 24,height: 24,),
            ),
            actions: [
              InkWell(
                onTap: (){
                  openShareBottomSheet(context: context);
                },
                child: Image.asset(_imgShared, width: 24, height: 24,),),
              SizedBox(width: 16,),
              !isMselfId?InkWell(
                onTap: (){
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                          return ProfileDetailsMore(userId: widget.userId,isFollow:_isFllow,userName: _textName,);
                  })).then((value) {
                        if(value){
                          _getUserInfo(id: widget.userId);
                          _getFollowCount(id: widget.userId);
                        }
                  });
                },
                child: Image.asset(_imgMore,width: 24, height: 24,) ,):Container(),
              SizedBox(width: 15.5,)
            ],
            backgroundColor: AppColor.white,
            expandedHeight: height * 0.42,
            ///这里是资料展示页,写在这个里面相当于是appBar的背景板
            flexibleSpace: FlexibleSpaceBar(
                background: Container(
              child: mineHomeData( height, width),
            )),
          ),
          ///根据布尔值返回视图
          isMselfId?SliverPersistentHeader(
            /// 可以吸顶的TabBar
            pinned: true,
            delegate: StickyTabBarDelegate(
              child: TabBar(
                unselectedLabelStyle: AppStyle.textHintRegular16,
                unselectedLabelColor: AppColor.textSecondary,
                labelStyle: AppStyle.textRegular16,
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
          ):SliverToBoxAdapter(child:Container() ,)
        ];
      },
      ///根据布尔值返回body
      body: isMselfId?TabBarView(
        controller: _mController,
        children: <Widget>[_ListView(width,_listId,fllowState,"发布你的第一条动态吧~"),
          _ListView(width,_listId,fllowState,"发布你的第一条动态吧~")],
      ):_ListView(width,_listId, fllowState,"他还没有动态呢~")
    );
  }
  ///高斯模糊
  Widget mineHomeData(double height, double width) {
    return Container(
      padding: EdgeInsets.only(top: 15),
      color: AppColor.white,
      child: Stack(
        children: [
          Container(
              height: ScreenUtil.instance.height*0.3,
              width: width,
              child: ClipOval(
                  child:CachedNetworkImage(
                    height: 90,
                    width: 90,
                    imageUrl:_avatar != null ? _avatar: "",
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Image.asset("images/test.png", fit: BoxFit.cover,),
                    /*errorWidget: (context, url, error) => Image.asset("images/test.png", fit: BoxFit.cover,),*/
                  ),
              )
              ),
          Positioned(
              top: 0,
              child: Container(
                width: width,
                height: ScreenUtil.instance.height*0.3,
                color: AppColor.white.withOpacity(0.7),
              )),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
            child: _MineDetailsData( height, width),
          ),
        ],
      ),
    );
  }

  ///资料展示
  Widget _MineDetailsData( double height, double width) {
    return Container(
        height: height * 0.45,
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 49,),
            ///头像和按钮
            Container(
              padding: EdgeInsets.only(left: 16, right: 16),
              margin: EdgeInsets.only(top: 10),
              width: width,
              child: Stack(
                children: [
                  _mineAvatar(),
                  Positioned(right: 0,top: 26.5, child: _mineButton())
                ],
              ),
            ),
            SizedBox(
              height: 16,
            ),

            ///昵称
            Container(
              padding: EdgeInsets.only(left: 16, right: 16),
              child: Text(
                _textName != null ? _textName : "  ",
                style: TextStyle(fontSize: 20, color: AppColor.black),
              ),
            ),
            SizedBox(
              height: 12,
            ),

            ///id
            Container(
              padding: EdgeInsets.only(left: 16, right: 16),
              child: Text("ID: $_id"),
            ),
            SizedBox(
              height: 6,
            ),

            ///签名
            Container(
              padding: EdgeInsets.only(left: 16, right: 16),
              width: width * 0.7,
              child: Text(_signature != null ? _signature : "      ",
                  softWrap: true, style: AppStyle.textRegular14),
            ),
            SizedBox(
              height: 16,
            ),

            ///关注，获赞，粉丝
            Container(
              padding: EdgeInsets.only(left: 16, right: 16),
              child: Row(
                children: [
                  _TextAndNumber("关注", _attention),
                  SizedBox(
                    width: 61,
                  ),
                  _TextAndNumber("粉丝", _fans),
                  SizedBox(
                    width: 61,
                  ),
                  _TextAndNumber("动态", _dynmic),
                ],
              ),
            ),
            Expanded(child: (Container())),
            Container(
              color: AppColor.bgWhite_65,
              height: 12,
              width: width,
            )
          ],
        ));
  }

  ///这是动态和喜欢展示的listView
  Widget _ListView(
    double width,
    List<int> listId,
    StateResult state,
    String nullText
  ) {
    var _ListData = Expanded(
        child: Container(
      width: width,
      color: AppColor.white,
          ///刷新控件
        child: SmartRefresher(
          enablePullUp: true,
          enablePullDown: false,
          footer: CustomFooter(
            builder: (BuildContext context,LoadStatus mode){
              Widget body;
              if(mode==LoadStatus.loading){
                body = Text("正在加载");
              }else if(mode==LoadStatus.idle){
                body = Text("上拉加载更多");
              }else if(mode==LoadStatus.failed){
                body = Text("加载失败,请重试");
              }else{
                body = Text("没有更多了");
              }
              return Container(child: Center(child: body,),);
            },
          ),
          controller: _refreshController,
          onLoading: _onLoadding,
          child: ListView.builder(
          shrinkWrap: true, //解决无限高度问题
          physics: AlwaysScrollableScrollPhysics(),
          itemCount: listId.length,
          itemBuilder: (context, index) {
            int id = listId[index];
            HomeFeedModel model = context.read<FeedMapNotifier>().feedMap[id];
              if(index == listId.length){
                return LoadingView(loadText: loadingText,loadStatus:loadStatus ,);
              }else{
                if(index==0){
                  return Container(height: 10,);
                }else{
                  return DynamicListLayout(
                    index: index,
                    pc: _Panelcontroller,
                    isShowRecommendUser: false,
                    model: model,
                    key: GlobalObjectKey("attention$index"));
                }

              }

          }),),
    ));
    ///这里当model为null或者刚进来接口还没获取到的时候放一张图片
    switch (state){
      case StateResult.RESULTNULL:
        return Container(
          padding: EdgeInsets.only(top: 12),
          color: AppColor.white,
          child: Column(
              children: [
                Center(
                  child: Container(
                 width: 224,
                 height: 224,
                 color: AppColor.bgWhite_65,
               ),
                ),
                SizedBox(height: 16,),
                Center(
                  child: Text(nullText,style: AppStyle.textPrimary3Regular14,),
                )
              ],)

        );
       break;
      case StateResult.HAVARESULT:
        return _ListData;
        break;
    }

  }

  ///关注，编辑资料，私聊按钮
  Widget _mineButton() {
    return Container(
      height: 30,
      width: 80,
      decoration: BoxDecoration(
          color: _isFllow?AppColor.mainRed:AppColor.transparent,
          borderRadius: BorderRadius.all(Radius.circular(50)),
          border: Border.all(width: 1, color: AppColor.black)),
      child: FlatButton(
        onPressed: () {
          if (isMselfId) {
            ///这里跳转到编辑资料页
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
        ///判断是我的页面还是别人的页面
        child:isMselfId?Center(
                child:Text(
                        _buttonText,
                        style:
                            TextStyle(fontSize: 12, color: AppColor.black),
                      )
                    )
          :_buttonLayoutSelect(),
      ),
    );
  }

  ///通过布尔值来判断该展示私聊按钮还是关注按钮
  Widget _buttonLayoutSelect(){
    if(_isFllow){
      return Center(
        child:Text(
          _buttonText,
          style:
          TextStyle(fontSize: 12, color: AppColor.white),
        )
      );
    }else{
      return Row(
        children: [
         Image.asset("images/test/comment-filling.png",width:12,height:12 ,),
          SizedBox(width: 2,),
          Text(
            _buttonText,
            style:AppStyle.textRegular12,
          ),
        ],
      );
    }
  }
  ///取消关注时弹出dialog提醒用户确认取消关注(暂时没用先留着)
  Widget _bottomDialog() {
    return Container(
      child: Column(
        children: [
          Container(
              height: 50,
              child: Center(
                child: Text("确定要取消关注该用户吗?", style: AppStyle.textRegular16),
              )),
          InkWell(
              onTap: () {
                _Panelcontroller.close();
              },
              child: Container(
                  height: 50,
                  child: Center(
                    child: Text("确定", style: AppStyle.textRegular16),
                  ))),
          Container(
            color: AppColor.bgWhite,
            height: 12,
          ),
          InkWell(
              onTap: () {
                _Panelcontroller.close();
              },
              child: Container(
                  height: 50,
                  child: Center(
                      child: Text(
                    "取消",
                    style: AppStyle.textRegular16,
                  ))))
        ],
      ),
    );
  }

  ///头像
  Widget _mineAvatar() {
    return Container(
        child: ClipOval(
      child: CachedNetworkImage(
        height: 90,
        width: 90,
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
      if (db.substring(db.indexOf("."), db.indexOf(".") + 2) != 0) {
        String doubleText = db.substring(0, db.indexOf(".") + 2);
        return doubleText + "W";
      } else {
        String intText = db.substring(0, db.indexOf("."));
        return intText + "W";
      }
    }
  }

  ///这是关注粉丝获赞
  Widget _TextAndNumber(String text, int number) {
    return Container(
        child: Column(
      children: [
        Text(
          "${_getNumber(number)}",
          style: AppStyle.textRegular18,
        ),
        SizedBox(
          height: 6.5,
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
      if (attntionResult == 1||attntionResult==3) {
        ToastShow.show(msg: "关注成功!", context: context);
        _getFollowCount(id: widget.userId);
        _getUserInfo(id: widget.userId);
      }

  }
}

