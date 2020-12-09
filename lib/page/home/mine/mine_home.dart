import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/util/app_style.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

void main() {
  runApp(MineDetails());
}

class MineDetails extends StatefulWidget {
  int type;
  MineDetails({this.type});
  @override
  State<StatefulWidget> createState() {
    return _mineDetailState();
  }
}

class _mineDetailState extends State<MineDetails>
    with SingleTickerProviderStateMixin {
  final String _imgAseet = "images/test/back.png";
  final Color _titleColors = Colors.white;
  final String _imgShared = "images/test/分享.png";
  TabController _tabController;
  final PageController _pageController = PageController();
  List<String> _tabLsit = ["动态", "喜欢"];
  final _Panelcontroller = PanelController();
  bool _isTabChanges;
  bool _isPageChanges;
  String _imgAvatar = "";
  String _textName = "";
  int _id = 0;
  String _signature = "";
  int _attention = 0;
  int _fans = 0;
  int _getGreat = 0;
  String _buttonText = "";
  int StateType = 2;

  @override
  void initState() {
    super.initState();
    _textTest();
    _tabController = TabController(length: _tabLsit.length, vsync: this);
    _tabController.addListener(
      () {
        if (_tabController.indexIsChanging) {
          print('tabBar改变状态');
          onPageChanges(_tabController.index, p: _pageController);
        }
      },
    );
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
      color: _titleColors,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Colors.white,
            width: width,
            child: SizedBox(
              height: 40,
            ),
          ),
          mineHomeTitle(width),
          mineHomePage(width, height)
        ],
      ),
    );
  }

  ///顶部title，返回和分享
  Widget mineHomeTitle(double width) {
    return Container(
      color: _titleColors,
      width: width,
      height: 40,
      padding: EdgeInsets.only(left: 10, right: 10),
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
            color: _titleColors,
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
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Container(
        width: width,
        height: height - 80,
        child: Column(
          children: [
            mineHomeData(height, width),
            _pageBottomList(width, height)
          ],
        ),
      ),
    );
  }

  ///资料展示部分
  Widget mineHomeData(double height, double width) {
    return Container(
        height: height * 0.3,
        width: width,
        padding: EdgeInsets.only(left: 20, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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

            ///昵称
            Container(
              padding: EdgeInsets.only(left: 20, top: 10),
              child: Text(
                _textName,
                style: TextStyle(fontSize: 20, color: Colors.black),
              ),
            ),

            ///id
            Container(
              padding: EdgeInsets.only(left: 20, top: 10),
              child: Text("ID: $_id"),
            ),

            ///签名
            Container(
              padding: EdgeInsets.only(left: 20, top: 10),
              child: Text(_signature, style: AppStyle.textRegular14),
            ),

            ///关注，获赞，粉丝
            Container(
              padding: EdgeInsets.only(
                left: 20,
                top: 10,
              ),
              child: Row(
                children: [
                  _TextAndNumber("关注", _attention),
                  SizedBox(
                    width: 15,
                  ),
                  _TextAndNumber("粉丝", _fans),
                  SizedBox(
                    width: 15,
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
        labelColor: AppColor.black,
        unselectedLabelColor: AppColor.mainRed,
        labelStyle: AppStyle.textRegular16,
        indicatorColor: AppColor.black,
        indicatorWeight: 1,
        tabs: [
          Text("               动态          "),
          Text("          喜欢               ")
        ],
      ),
    );

    ///ViewPage
    var _ViewPage = Container(
      height: height / 2,
      width: width,
      child: PageView.builder(
        itemCount: 2,
        itemBuilder: (context, index) {
          return _ListView(_List[index]);
        },
        controller: _pageController,
        onPageChanged: (index) {
          onPageChanges(index, t: _tabController);
        },
      ),
    );

    ///这里判断状态判定是进入的自己的页面还是别人的页面
    if (StateType == 1) {
      return Column(children: [_tabBar, _ViewPage]);
    } else {
      return _ListView("动态");
    }
  }

  ///这是动态和喜欢展示的listView
  Widget _ListView(String text) {
    var _ListData = Expanded(
        child: Container(
      child: ListView.builder(
          itemCount: 20,
          itemBuilder: (context, index) {
            return Center(
              child: Text(
                "这是第$index条$text",
                style: TextStyle(fontSize: 25),
              ),
            );
          }),
    ));
    return _ListData;
  }

  ///关联tab
  onPageChanges(int index, {PageController p, TabController t}) async {
    if (p != null) {
      _isPageChanges = false;
      await _pageController.animateToPage(index,
          duration: Duration(milliseconds: 0), curve: Curves.ease);
      _isPageChanges = true;
    } else {
      _tabController.animateTo(index);
    }
  }

  ///关注，编辑资料，私聊按钮
  Widget _mineButton() {
    return Container(
      height: 30,
      width: 80,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(50)),
          border: Border.all(width: 1, color: Colors.black)),
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
            style: TextStyle(fontSize: 12, color: Colors.black),
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
                    child: Text("取消",
                        style: TextStyle(
                            color: Color.fromRGBO(0xFF, 0x40, 0x59, 1.0),
                            fontSize: 16)),
                  )))
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
    if (number < 1000) {
      return number.toString();
    } else {
      String db = "${(number / 1000).toString()}";
      String doubleText = db.substring(0, db.indexOf(".") + 2);
      return doubleText + "K";
    }
  }

  ///这是关注粉丝获赞
  Widget _TextAndNumber(String text, int number) {
    return Container(
        child: Row(
      children: [
        Text(
          "${_getNumber(number)}",
          style: AppStyle.textRegular16,
        ),
        SizedBox(
          width: 10,
        ),
        Text(
          text,
          style: AppStyle.textRegular12,
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
