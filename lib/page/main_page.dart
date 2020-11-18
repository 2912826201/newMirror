import 'package:flutter/material.dart';
import 'package:mirror/page/home/home_page.dart';
import 'package:mirror/page/profile/profile_page.dart';
import 'package:mirror/page/message/message_page.dart';
import 'package:mirror/page/test_page.dart';
import 'package:mirror/util/screen_util.dart';

class MainPage extends StatefulWidget {
  MainPage({Key key}) : super(key: key);

  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  int currentIndex;
  final pages = [HomePage(), TestPage(), MessagePage(), ProfilePage()];
  List titles = ["首页", "训练", "消息", "我的"];
  List normalImgUrls = [
    "images/test/home-filling1.png",
    "images/test/work-filling.png",
    'images/test/comment-filling.png',
    'images/test/user-filling.png'
  ];
  List selectedImgUrls = [
    "images/test/home-filling.png",
    "images/test/work-filling1.png",
    "images/test/comment-filling1.png",
    "images/test/user-filling1.png",
  ];

  @override
  void initState() {
    super.initState();
    currentIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    double itemWidth = MediaQuery.of(context).size.width / 5;
    // 初始化获取屏幕数据
    ScreenUtil.init(maxPhysicalSize: MediaQuery.of(context).size.width);
    print(ScreenUtil.instance.screenWidthDp);
    print("加那架飞机安检房价按房间安静房价按房间安静房间啊");
    return Scaffold(
      // 此属性是重新计算布局空间大小
      // 内部元素要监听键盘高度必需要设置为false,
      resizeToAvoidBottomInset:false,
      bottomNavigationBar: BottomAppBar(
        child: Row(children: <Widget>[
          Expanded(
            child: SizedBox(height: 51, width: itemWidth, child: tabbar(0)),
            flex: 1,
          ),
          Expanded(
            child: SizedBox(height: 51, width: itemWidth, child: tabbar(1)),
            flex: 1,
          ),
          Expanded(
            child: SizedBox(height: 51, width: itemWidth, child: tabbar(2)),
            flex: 1,
          ),
          Expanded(
            child: SizedBox(height: 51, width: itemWidth, child: tabbar(3)),
            flex: 1,
          )
        ]),
      ),
      body: pages[currentIndex],
    );
  }

  // 自定义BottomAppBar
  Widget tabbar(int index) {
    //设置默认未选中的状态
    TextStyle style = TextStyle(fontSize: 15, color: Colors.black);
    String imgUrl = normalImgUrls[index];
    if (currentIndex == index) {
      //选中的话
      style = TextStyle(fontSize: 15, color: Colors.white);
      imgUrl = selectedImgUrls[index];
    }
    //构造返回的Widget
    Widget item = Container(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          GestureDetector(
            child: Card(
              elevation: 0,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16.0))),
              color: currentIndex == index ? Colors.redAccent : Colors.transparent,
              child: Container(
                padding: EdgeInsets.only(top:2,bottom: 2,left: 7.5,right: 7.5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(imgUrl, width: 28, height: 28),
                    Container(
                        margin: EdgeInsets.only(left: 6),
                        child: Offstage(
                          offstage: currentIndex != index,
                          child: Text(
                            titles[index],
                            style: style,
                          ),
                        ))
                  ],
                ),
              ),
            ),
            onTap: () {
              if (currentIndex != index) {
                setState(() {
                  currentIndex = index;
                });
              }
            },
          ),
        ],
      ),
    );
    return item;
  }
}
