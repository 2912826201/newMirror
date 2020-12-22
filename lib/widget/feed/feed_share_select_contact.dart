import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:sticky_headers/sticky_headers.dart';

import '../custom_button.dart';

class FeedShareSelectContact extends StatefulWidget {
  @override
  FeedShareSelectContactState createState() => FeedShareSelectContactState();
}

class FeedShareSelectContactState extends State<FeedShareSelectContact> {
  List data = [
    {
      "latter": "A",
      "group": ["A分组1", "A分组1", "A分组1", "A分组1", "A分组1", "A分组1"]
    },
    {
      "latter": "B",
      "group": ["B分组1", "B分组1", "B分组1", "B分组1", "B分组1", "B分组1"]
    },
    {
      "latter": "C",
      "group": ["C分组1", "C分组1", "C分组1", "C分组1", "C分组1", "C分组1"]
    },
    {
      "latter": "D",
      "group": ["D分组1", "D分组1", "D分组1", "D分组1", "D分组1", "D分组1"]
    },
    {
      "latter": "E",
      "group": ["E分组1", "E分组1", "E分组1", "E分组1", "E分组1", "E分组1"]
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "选择联系人",
          style: TextStyle(color: AppColor.textPrimary1, fontSize: 18, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: AppColor.white,
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pop(true);
          },
          child: Image.asset(
            "images/resource/2.0x/return2x.png",
            width: 28,
            height: 28,
          ),
        ),
        leadingWidth: 28.0,
        // MyIconBtn(
        //   // width: 28,
        //   // height: 28,
        //   iconSting: "images/resource/2.0x/return2x.png",
        //   onPressed: () {
        //     Navigator.of(context).pop(true);
        //   },
        // ),
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.only(left: 16, right: 16, top: 18, bottom: 10),
            height: 32,
            color: AppColor.bgWhite_65,
            width: ScreenUtil.instance.screenWidthDp,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 12,
                ),
                Image.asset(
                  "images/resource/2.0x/search_icon_gray@2x.png",
                  width: 21,
                  height: 21,
                ),
                Expanded(
                  child: Container(
                    height: 32,
                    alignment: Alignment.center,
                    child: TextField(
                      textInputAction: TextInputAction.search,
                      decoration: new InputDecoration(
                          isCollapsed: true,
                          contentPadding: EdgeInsets.only(top: 0, bottom: 0, left: 6),
                          hintText: '搜索用户',
                          hintStyle: TextStyle(
                            color: AppColor.textSecondary
                          ),
                          border: InputBorder.none),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
              child: ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    // StickyHeader
                    return StickyHeader(
                      header: Container(
                        height: 28.5,
                        color: AppColor.bgWhite,
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          data[index]['latter'],
                          style: const TextStyle(color: AppColor.textPrimary3, fontSize: 14),
                        ),
                      ),
                      content: Column(
                        children: buildGroup(data[index]['group']),
                      ),
                      callback: (double stuckAmount) {
                        print("回调是哪个$stuckAmount");
                      },
                    );
                  }))
        ],
      ),
    );
  }

  List<Widget> buildGroup(List group) {
    return group.map((item) {
      return Container(
        child:Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundImage:
              NetworkImage("https://pic2.zhimg.com/v2-639b49f2f6578eabddc458b84eb3c6a1.jpg" ),
              maxRadius: 19,
            ),
           SizedBox(width: 12,),
           Text(
              item,
              style: const TextStyle(
                color: AppColor.textPrimary1,
                fontSize: 15,
              ),
            )
          ],
        ),
          height: 48,
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(left: 16),
          );
    }).toList();
  }
}
