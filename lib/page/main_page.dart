import 'package:flutter/material.dart';
import 'package:mirror/page/home/home_page.dart';
import 'package:mirror/page/profile/profile_page.dart';
import 'package:mirror/page/message/message_page.dart';
import 'package:mirror/page/test_page.dart';

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
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        child: Row(children: <Widget>[
          Expanded(
            child: SizedBox(height: 49, width: itemWidth, child: tabbar(0)),
            flex: 1,
          ),
          Expanded(
            child: SizedBox(height: 49, width: itemWidth, child: tabbar(1)),
            flex: 1,
          ),
          Expanded(
            child: SizedBox(height: 49, width: itemWidth, child: tabbar(2)),
            flex: 1,
          ),
          Expanded(
            child: SizedBox(height: 49, width: itemWidth, child: tabbar(3)),
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
    TextStyle style = TextStyle(fontSize: 16, color: Colors.black);
    String imgUrl = normalImgUrls[index];
    if (currentIndex == index) {
      //选中的话
      style = TextStyle(fontSize: 16, color: Colors.white);
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
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
              color: currentIndex == index ? Colors.redAccent : Colors.transparent,
              child: Container(
                padding: EdgeInsets.all(8),
                child: Row(
                  children: [
                    Image.asset(imgUrl, width: 25, height: 25),
                    Container(
                        margin: EdgeInsets.only(left: 4),
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
