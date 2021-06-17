import 'package:flutter/material.dart';
import 'package:mirror/widget/round_underline_tab_indicator.dart';

import 'camera_page.dart';

class TikTokHeader extends StatefulWidget {
  final Function onSearch;

  // taBar和TabBarView必要的
  final TabController controller;

  const TikTokHeader({
    Key key,
    this.controller,
    this.onSearch,
  }) : super(key: key);

  @override
  _TikTokHeaderState createState() => _TikTokHeaderState();
}

class _TikTokHeaderState extends State<TikTokHeader> {
  int currentSelect = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.black.withOpacity(0.3),
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Tapped(
              child: Container(
                color: Colors.black.withOpacity(0),
                padding: EdgeInsets.all(4),
                alignment: Alignment.centerLeft,
                child: Icon(
                  Icons.search,
                  color: Colors.white.withOpacity(0.66),
                ),
              ),
              onTap: widget.onSearch,
            ),
          ),
          Expanded(
            flex: 2,
            child: TabBar(
              controller: widget.controller,
              tabs: [
                Text("关注"),
                Text(
                  "推荐",
                )
              ],
              labelStyle: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              labelColor: Colors.black,
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
            // Container(
            //   color: Colors.black.withOpacity(0),
            //   alignment: Alignment.center,
            //   child: headSwitch,
            // ),
          ),
          Expanded(
            child: Tapped(
              child: Container(
                color: Colors.black.withOpacity(0),
                padding: EdgeInsets.all(4),
                alignment: Alignment.centerRight,
                child: Icon(
                  Icons.tv,
                  color: Colors.white.withOpacity(0.66),
                ),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
