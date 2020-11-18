import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/util/screen_util.dart';

class SlideBanner extends StatefulWidget {
  SlideBanner({Key key, this.list, this.height}) : super(key: key);
  List<String> list;
  double height;

  @override
  _SlideBannerState createState() => _SlideBannerState();
}

class _SlideBannerState extends State<SlideBanner> {
  int zindex = 0; //要移入的下标
  Timer timer;

  autoPlay(int index) {
    print("轮播图回调");
    setState(() {
      zindex = index;
    });
  }

  double getWidth() {
    var num = widget.list.length;
    return num * 8.0;
  }

  @override
  Widget build(BuildContext context) {
    final width = ScreenUtil.instance.screenWidthDp;
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: width,
              height: widget.height,
              child: Swiper(
                itemCount: widget.list.length,
                itemBuilder: (BuildContext context, int index) {
                  return new Image.asset(widget.list[index], fit: BoxFit.cover);
                },
                loop: widget.list.length > 1,
                onIndexChanged: (index) {
                  autoPlay(index);
                },
                onTap: (index) {
                  print("点击了第$index个图片");
                },
              ),
            ),
            Positioned(
              top: 13,
              right: 16,
              child: Offstage(
                offstage: widget.list.length == 1,
                child: Container(
                  padding: EdgeInsets.only(left: 6, top: 3, right: 6, bottom: 3),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(12)), color: AppColor.textPrimary1_50),
                  child: Text(
                    "${zindex + 1}/${widget.list.length}",
                    style: TextStyle(color: AppColor.white, fontSize: 12),
                  ),
                ),
              ),
              // child:
            )
          ],
        ),
        Offstage(
          offstage: widget.list.length == 1,
          child:Container(
            width: getWidth(),
            margin: EdgeInsets.only(top: 5),
            // color: Colors.orange,
            child: Row(
                children: widget.list
                    .asMap()
                    .keys
                    .map((i) => Container(
                    width: 5,
                    height: 5,
                    margin: EdgeInsets.only(right: 3),
                    decoration:
                    BoxDecoration(color: i == zindex ? Colors.black : Colors.grey, shape: BoxShape.circle)))
                    .toList()),
          ),
        )

      ],
    );
  }
}
