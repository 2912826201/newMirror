import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/page/profile/profile_details_carousel.dart';
import 'package:mirror/util/app_style.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class ProfileDetailPage extends StatefulWidget {
  int type;

  ProfileDetailPage({this.type});

  @override
  _ProfileDetailState createState() {
    return _ProfileDetailState();
  }
}

class _ProfileDetailState extends State<ProfileDetailPage>
    with SingleTickerProviderStateMixin {
  final String _imgAseet = "images/test/back.png";
  final String _imgShared = "images/test/分享.png";
  TabController _tabController;
  PageController _pageController = PageController();
  List<String> _tabLsit = ["动态", "喜欢"];
  final _Panelcontroller = PanelController();
  String _imgAvatar = "";
  String _textName = "";
  int _id = 0;
  String _signature = "";
  int _attention = 0;
  int _fans = 0;
  int _getGreat = 0;
  String _buttonText = "";
  int _pageIndex = 1;
  SwiperController _swiperControl = SwiperController();
  ///这里是暂时的type,如果是2就是别人的页面，1是自己的页面
  int StateType = 2;
  String _imageUrl =
      "https://ss0.bdstatic.com/70cFuHSh_Q1YnxGkpoWK1HF6hhy/it/u=3412286164,295662108&fm=26&gp=0.jpg";

  @override
  void initState() {
    super.initState();
    _textTest();
    _swiperControl.addListener(() {
      if(_swiperControl.animation){
        setState(() {
          _pageIndex = _swiperControl.index;
        });
      }

    });
    _tabController = TabController(length: _tabLsit.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        onPageChanges(_tabController.index);
      }
    });
    _pageController = PageController();
  }

  _textTest() {
    StateType = widget.type;
    if (StateType == 1) {
      _buttonText = "编辑资料";
      // ignore: unnecessary_statements
    } else {
      (_buttonText = "+ 关注");
    }
    _textName = "夕柚";
    _id = 121211212;
    _signature = "这是一条签名，很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长很长";
    _attention = 10000;
    _fans = 1121211;
    _getGreat = 150000;
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
              child: _bottomDialog("+ 关注"),
            ),
            maxHeight: height * 0.24,
            backdropEnabled: true,
            controller: _Panelcontroller,
            minHeight: 0,
            body: _minehomeBody(width, height),
          ),
        );
      }),
    );
  }

  Widget _minehomeBody(double width, double height) {
    return Container(
      color: AppColor.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          mineHomePage(width, height)
        ],
      ),
    );
  }

  ///顶部title，返回和分享
  Widget mineHomeTitle(double width) {
    return Container(
      color: AppColor.white,
      width: width,
      height: 44,
      padding: EdgeInsets.only(left: 6.5,right: 6.5),
      child: Row(
        children: [
          Center(
              child: InkWell(
            ///点击返回
            onTap: () {
              Navigator.pop(context);
            },
            child: Image.asset(_imgAseet),
          )),
          Expanded(
              child: Container(
            color: AppColor.white,
          )),
          Center(
              child: InkWell(
            ///这里是点击调用分享
            onTap: () {},
            child: Image.asset(
              _imgShared,
              width: 20,
              height: 20,
            ),
          ))
        ],
      ),
    );
  }

  ///主要展示页面
  Widget mineHomePage(double width, double height) {
    return Container(
        width: width,
        height: height,
        child: ListView(
          children: [
            mineHomeData(height, width),
            _pageBottomList(width, height)
          ],
        ));
  }

  ///资料展示部分
  Widget mineHomeData(double height, double width) {
    return Stack(
      children: [
          _MineDetailsData(height, width),
      ],
    );
  }


  Widget _MineDetailsData(double height,double width){
    return Container(
      height: height * 0.4,
      width: width,
      padding: EdgeInsets.only(left: 16, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          mineHomeTitle(width),
          SizedBox(height: 5,),
          ///头像和按钮
          Container(
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
            child: Text(
              _textName,
              style: TextStyle(fontSize: 20, color: AppColor.black),
            ),
          ),
          SizedBox(height: 12,),
          ///id
          Container(
            child: Text("ID: $_id"),
          ),
          SizedBox(height: 6,),
          ///签名
          Container(
            child: Text(_signature, style: AppStyle.textRegular14),
          ),
          SizedBox(height: 16,),
          ///关注，获赞，粉丝
          Container(
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
                _TextAndNumber("获赞", _getGreat),
              ],
            ),
          ),
        ],
      ));
  }
  Widget _pageBottomList(double width, double height) {
    List<String> _List = ["动态", "喜欢"];

    ///tabBar
    var _tabBar = Container(
      child: TabBar(
        isScrollable: true,
        controller: _tabController,
        labelColor: AppColor.mainRed,
        unselectedLabelColor: AppColor.black,
        labelStyle: AppStyle.textRegular16,
        indicatorColor: AppColor.black,
        indicatorWeight: 1,
        tabs: [
          Text("                       动态          "),
          Text("          喜欢                       ")
        ],
      ),
    );

    ///ViewPage
    var _ViewPage = Container(
      width: width,
      child: PageView.builder(
        itemCount: 2,
        itemBuilder: (context, index) {
          return _ListView(width, height);
        },
        controller: _pageController,
        onPageChanged: (index) {
          onTabChanges(index);
        },
      ),
    );

    ///这里判断状态判定是进入的自己的页面还是别人的页面
    if (StateType == 1) {
      return Expanded(child: Column(children: [_tabBar, _ViewPage]));
    } else {
      return Expanded(child: _ListView(width, height));
    }
  }

  ///这是动态和喜欢展示的listView
  Widget _ListView(double width, double height) {
    var _ListData = Expanded(
        child: Container(
      width: width,
      child: ListView.builder(
          shrinkWrap: true, //解决无限高度问题
        physics: NeverScrollableScrollPhysics(),
          itemCount: 20,
          itemBuilder: (context, index) {
            return Column(
              children: [
                _AvatarRow(_imageUrl, "名字", "3小时前"),
                SizedBox(height: 20,),
                ProFileDetailesCarousel(height: 500,)

              ],
            );
          }),
    ));
    return _ListData;
  }

  Widget _AvatarRow(String imgUrl, String name, String time) {
    return Container(
      padding: EdgeInsets.only(left: 15,right: 15),
      child: Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundImage: NetworkImage(imgUrl),
        ),
        SizedBox(
          width: 10,
        ),
        Column(
          children: [
            Text(
              name,
              style: AppStyle.textRegular14,
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              time,
              style: AppStyle.textRegular12,
            )
          ],
        ),
        Expanded(child: Container()),
      ],
    ),);
  }

  onPageChanges(int index) {
    _pageController.animateToPage(index,
        duration: Duration(milliseconds: 300), curve: Curves.ease);
  }

  onTabChanges(int index) {
    _tabController.animateTo(index, duration: Duration(milliseconds: 300));
  }

  ///关注，编辑资料，私聊按钮
  Widget _mineButton() {
    return Container(
      height: 30,
      width: 80,
      decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.all(Radius.circular(50)),
          border: Border.all(width: 1, color: AppColor.black)),
      child: FlatButton(
        onPressed: () {
          if (StateType == 1) {
          } else {
            setState(() {
              if (_buttonText == "+ 关注") {
                Fluttertoast.showToast(
                    msg: "关注成功!",
                    toastLength: Toast.LENGTH_SHORT,
                    fontSize: 16,
                    gravity: ToastGravity.CENTER,
                    backgroundColor: AppColor.textHint,
                    textColor: AppColor.white);
                _buttonText = "取消关注";
              } else {
                ///打开dialog
                _Panelcontroller.open();
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
  Widget _bottomDialog(String text) {
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
                setState(() {
                  _buttonText = text;
                });
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
        backgroundImage: AssetImage(_imageView()),
        maxRadius: 59,
      ),
    );
  }

  ///数值大小判断
  String _getNumber(int number) {
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

  ///头像选择
  String _imageView() {
    if (_imgAvatar != null) {
      return _imgAvatar;
    } else {
      return "images/test/avatar.png";
    }
  }
}
