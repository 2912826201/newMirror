
import 'dart:ui';

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
import 'package:mirror/data/model/profile_model.dart';
import 'package:mirror/data/model/user_model.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:mirror/page/home/sub_page/share_page/dynamic_list.dart';
import 'package:mirror/page/profile/profile_details_carousel.dart';
import 'package:mirror/page/profile/sticky_tabBar.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class ProfileDetailPage extends StatefulWidget {
  int type;
  int otherId;
  int myselfId;
  PanelController pc;
  ProfileDetailPage({this.type,this.otherId,this.myselfId,this.pc});

  @override
  _ProfileDetailState createState() {
    return _ProfileDetailState();
  }
}

class _ProfileDetailState extends State<ProfileDetailPage>
    with TickerProviderStateMixin {
  bool get wantKeepAlive => true;
  final String _imgAseet = "images/test/back.png";
  final String _imgShared = "images/test/分享.png";
  final _Panelcontroller = PanelController();
  var _pageIndex = 0;
  String _textName;
  int _id;
  String _signature;
  String _avatar;
  int _attention;
  int _fans;
  int _dynmic;
  String _buttonText = "";
  SwiperController _swiperControl = SwiperController();
  TabController _mController;
  List<HomeFeedModel> attentionModel = [];
  List<int> _listId = [];
  bool isMselfId;
  UserModel userModel;
  int relation;
  @override
  void initState() {
    super.initState();
      if(context.read<ProfileNotifier>().profile.uid==widget.otherId){
          isMselfId = true;
      }else if(widget.myselfId!=null){
          isMselfId = true;
      }else if(widget.otherId!=null){
        isMselfId = false;
      }
    if(isMselfId){
      _getUserInfo();
      _getFollowCount();
      _getDynamicData(2);
    }else{
      _getUserInfo(id: widget.otherId);
      _getFollowCount(id: widget.otherId);
      _getDynamicData(3,id: widget.otherId);
    }
    _textChange();
    _mController = TabController(length: 2, vsync:this );
    _swiperControl.addListener(() {
      if(_swiperControl.animation){
        setState(() {
          _pageIndex = _swiperControl.index;
        });
      }
    });
  }

  _textChange() {
    if (isMselfId){
      _buttonText = "编辑资料";
    } else {
      if(relation!=null){
        if(relation==0||relation==2){
          _buttonText = "+ 关注";
        }else if(relation==1){
          _buttonText = "取消关注";
        }else{
          _buttonText = "私聊";
        }
      }
    }
  }

  _getFollowCount({int id}) async {
    ProfileModel attentionModel =  await ProfileFollowCount(id: id);
    setState(() {
      _attention = attentionModel.feedCount;
      _fans = attentionModel.followerCount;
      _dynmic = attentionModel.followingCount;
    });
  }

  _getUserInfo({int id})async{
     userModel = await getUserInfo(uid: id);
     if(userModel!=null){
       setState(() {
         _avatar = userModel.avatarUri;
         _id = userModel.uid;
         _signature = userModel.description;
         _textName = userModel.nickName;
         relation = userModel.relation;
       });
     }
  }


  _getDynamicData(int type,{int id}) async{
   DataResponseModel model = await getPullList(type:type, size: 20,targetId: id);
    setState(() {
        if(model.list.isNotEmpty){
          model.list.forEach((result){
            attentionModel.add(HomeFeedModel.fromJson(result));
            _listId.add(HomeFeedModel.fromJson(result).id);
          });
        }
    });
    context.read<FeedMapNotifier>().updateFeedMap(attentionModel);
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(builder: (context) {
        double width = MediaQuery.of(context).size.width;
        double height = MediaQuery.of(context).size.height;
        return Scaffold(
          appBar: null,
          body: SlidingUpPanel(
            panel: Container(
              child: _bottomDialog(),
            ),
            maxHeight: height * 0.24,
            backdropEnabled: true,
            controller: _Panelcontroller,
            minHeight: 0,
            body: isMselfId?
            _minehomeBody(width, height)
              :Container(
              height: height,
              width: width,
              child: ListView(
                shrinkWrap: true,
              children: [
                mineHomeData(12,height,width),
               _ListView(width,false)
            ],),)
          ),
        );
      }),
    );
  }
    ///这是个人页面，使用TabBarView
  Widget _minehomeBody(double width, double height) {
    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled){
        return <Widget>[
          SliverAppBar(
            backgroundColor: AppColor.transparent,
            expandedHeight: height*0.42,
            flexibleSpace: FlexibleSpaceBar(
              background:Container(
                child: mineHomeData(44,height,width),)
            ),
          ),
          SliverPersistentHeader( // 可以吸顶的TabBar
            pinned: true,
            delegate: StickyTabBarDelegate(
              child: TabBar(
                unselectedLabelStyle: AppStyle.textMedium18,
                labelStyle: AppStyle.textRegular16,
                labelColor: Colors.black,
                unselectedLabelColor: AppColor.black,
                controller: _mController,
                tabs: <Widget>[
                  Tab(text: '动态'),
                  Tab(text: '喜欢'),
                ],
              ),
            ),
          ),
        ];
      },
      body:TabBarView(
      controller: _mController,
      children: <Widget>[
        _ListView(width,true),
        _ListView(width,true)
      ],
    ) ,
    );
  }

  ///顶部title，返回和分享
  Widget mineHomeTitle(double width) {
    return Container(
      width: width,
      height: 44,
      padding: EdgeInsets.only(left:22.5,right: 22.5),
      child: Row(
        children: [
          Center(
              child: InkWell(
            ///点击返回
            onTap: () {
              Navigator.pop(context);
            },
            child: Image.asset(_imgAseet,width: 24,height: 24,),
          )),
          Expanded(
              child: Container(
          )),
          Center(
              child: InkWell(
            ///这里是点击调用分享
            onTap: () {},
            child: Image.asset(
              _imgShared,
              width: 24,
              height: 24,
            ),
          ))
        ],
      ),
    );
  }
  ///高斯模糊
  Widget mineHomeData(double topHeight,double height, double width) {
    return Container(
      color: AppColor.white,
      child: Stack(
      children: [
        Container(
          height: height*0.3,
          width: width,
          child: _avatar!=null?Image.network(_avatar,fit: BoxFit.cover,):Expanded(child:SizedBox())
        ),
        Positioned(
          top: 0,
          child:Container(
            width: width,
            height: height*0.3,
            color: AppColor.white.withOpacity(0.6),
          )
        ),

        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
          child:  _MineDetailsData(topHeight,height, width),
        ),


      ],
    ),);
  }

  ///资料展示
  Widget _MineDetailsData(double topHeight,double height,double width){
    return Container(
      height: height *0.45,
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height:topHeight,),
          mineHomeTitle(width),
          ///头像和按钮
          Container(
            padding: EdgeInsets.only(left: 16, right: 16),
            margin: EdgeInsets.only(top: 10),
            width: width,
            child: Stack(
              children: [
                _mineAvatar(),
                Positioned(right: 0, bottom: 0, child: _mineButton())
              ],
            ),
          ),
          SizedBox(height: 16,),
          ///昵称
          Container(
            padding: EdgeInsets.only(left: 16, right: 16),
            child: Text(
              _textName!=null?_textName:"  ",
              style: TextStyle(fontSize: 20, color: AppColor.black),
            ),
          ),
          SizedBox(height: 12,),
          ///id
          Container(
            padding: EdgeInsets.only(left: 16, right: 16),
            child: Text("ID: $_id"),
          ),
          SizedBox(height: 6,),
          ///签名
         Container(
            padding: EdgeInsets.only(left: 16, right: 16),
              width: width*0.7,
              child: Text(
              _signature!=null?_signature:"      ",
               softWrap:true,
              style: AppStyle.textRegular14),
          ),
          SizedBox(height: 16,),
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
                _TextAndNumber("获赞", _dynmic),
              ],
            ),
          ),
          Expanded(child: (Container())),
          Container(color: AppColor.bgWhite_65,height: 12,width: width,)
        ],
      ));
  }
  ///这是动态和喜欢展示的listView
  Widget _ListView(double width,bool isScroll,) {
    var _ListData = Expanded(
        child: Container(
      width: width,
      color: AppColor.white,
      child: ListView.builder(
        shrinkWrap: true, //解决无限高度问题
        physics:isScroll?AlwaysScrollableScrollPhysics():NeverScrollableScrollPhysics(),
          itemCount: _listId.length,
          itemBuilder: (context, index) {
          int id = _listId[index];
          HomeFeedModel model = context.read<FeedMapNotifier>().feedMap[id];
          if(model!=null){
            return  DynamicListLayout(
              index: index,
              pc: widget.pc,
              isShowRecommendUser:false,
              model: attentionModel[index],
              key: GlobalObjectKey("attention$index"));
          }else{
            return Container(

            );
          }
          }),
    ));
    return _ListData;
  }
  ///关注，编辑资料，私聊按钮
  Widget _mineButton() {
    return Container(
      height: 30,
      width: 80,
      decoration: BoxDecoration(
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
              } else if(_buttonText == "取消关注"){
                ///打开dialog
                _Panelcontroller.open();
              }else{
                ///这里跳转到私聊界面
              }
            });
          }
        },
        child: Center(
            child: Container(
          child: Text(
            _buttonText,
            style: TextStyle(fontSize: 12, color: AppColor.black),
          ),
        )),
      ),
    );
  }

  ///取消关注时弹出dialog提醒用户确认取消关注
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
                _getAttention(false);
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
      width: 80,
      height: 80,
      child: CircleAvatar(
            backgroundImage: NetworkImage(_avatar==null?"https://scpic.chinaz.net/files/pic/pic9/201911/zzpic21124.jpg":_avatar),
            maxRadius: 59,
          )
    );
  }

  ///数值大小判断
  String _getNumber(int number) {
    if(number==0||number==null){
      return 0.toString();
    }
    if (number < 10000) {
      return number.toString();
    } else {
      String db = "${(number / 10000).toString()}";
      if(db.substring(db.indexOf("."),db.indexOf(".")+2)!=0){
        String doubleText = db.substring(0, db.indexOf(".") + 2);
        return doubleText + "W";
      }else{
        String intText = db.substring(0, db.indexOf("."));
        return intText +"W";
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
  Future<bool> _getAttention(bool attention)async{
    if(attention){
      int attntionResult = await ProfileAttention(_id);
      if(attntionResult==1){
        ToastShow.show(msg: "关注成功!", context: context);
        setState(() {
          _buttonText = "取消关注";
        });
      }else if(attntionResult==3){
        setState(() {
          _buttonText = "私聊";
        });
      }
    }else{
      int cancelResult = await ProfileCancelAttention(_id);
      if(cancelResult==0){
        ToastShow.show(msg: "已取消关注该用户", context: context);
        setState(() {
          _buttonText = "+ 关注";
        });
      }else{

      }
    }

  }
}
