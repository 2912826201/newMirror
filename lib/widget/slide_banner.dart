import 'dart:async';

import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/util/screen_util.dart';
// 轮播图
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
 // 滑动回调
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

  /// 列表中的每个条目的Widget
  /// [index] 列表条目对应的索引
  buildOpenContainerItem(int index) {
    return OpenContainer(
      // 动画时长
      transitionDuration: const Duration(milliseconds: 700),
      transitionType: ContainerTransitionType.fade,
      //阴影
      closedElevation: 0.0,
      //圆角
      closedShape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(0.0)),
      ),
      ///将要打开的页面
      openBuilder:
          (BuildContext context, void Function({Object returnValue}) action) {
        return Item2Page(PhotoUrl: widget.list ,index: index,);
      },
      ///现在显示的页面
      closedBuilder: (BuildContext context, void Function() action) {
        ///条目显示的一张图片
        return buildShowItemContainer(index);
      },
    );
  }
  // 轮播图图片设置
  Container buildShowItemContainer(int index) {
    return Container(
      child: Image.asset(
        widget.list [index],
        fit: BoxFit.cover,
      ),
    );
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
                  return buildOpenContainerItem(index);
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

class Item2Page extends StatefulWidget {
  List<String> PhotoUrl;
  int index;
  Item2Page({Key key,this.PhotoUrl,this.index}) :super (key: key);
  @override
  State<StatefulWidget> createState() {
    return _Item2PageState();
  }
}

class _Item2PageState extends State<Item2Page> {
  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        Container(
          child: InkWell(
            onTap: () {
              Navigator.of(context).pop(true);
            },
            child: Image.asset(
              widget.PhotoUrl[widget.index],
              fit: BoxFit.cover,
            ),
          ),
        ),
        Container(
          height: 50,
          color: Colors.red,
        )
      ],
    );
    ///页面二中的Hero
  }
}