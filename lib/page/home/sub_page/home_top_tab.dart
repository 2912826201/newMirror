import 'package:flutter/material.dart';
import 'package:mirror/widget/round_underline_tab_indicator.dart';

class HomeTopTab extends StatefulWidget {
  HomeTopTab({Key key, this.callBack, this.controller}) : super(key: key);
  TabController controller;
  final callBack;

  _TopTabState createState() => _TopTabState();
}

class _TopTabState extends State<HomeTopTab> {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 23,
          child: GestureDetector(
            child: Image.asset(
              "images/resource/Nav_Camera_icon.png",
              width: 28,
              height: 28,
            ),
            onTap: () {
              print("点击了客服");
            },
          ),
        ),
        Expanded(
            flex: 100,
            child: Container(
              width: 240,
              padding: EdgeInsets.symmetric(horizontal: 50),
              child: TabBar(
                controller: widget.controller,
                tabs: [Text("关注"), Text("推荐")],
                labelStyle: TextStyle(fontSize: 18),
                labelColor: Colors.black,
                // indicatorPadding: EdgeInsets.symmetric(horizontal: 24),
                // unselectedLabelColor: Color.fromRGBO(153, 153, 153, 1),
                unselectedLabelStyle: TextStyle(fontSize: 16),
                indicator: RoundUnderlineTabIndicator(
                  borderSide: BorderSide(
                    width: 3,
                    color: Color.fromRGBO(253, 137, 140, 1),
                  ),
                  insets: EdgeInsets.only(bottom: -6),
                  wantWidth: 16,
                ),
              ),
            )),
        Expanded(
          flex: 23,
          child: GestureDetector(
            child: Image.asset("images/resource/Nav_search_icon .png", width: 28, height: 28),
            onTap: () {
              print("点击了搜索");
            },
          ),
        ),
      ],
    );
  }
}