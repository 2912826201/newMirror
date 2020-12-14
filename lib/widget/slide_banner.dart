import 'dart:async';

import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
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
  // scroll_to_index定位
  AutoScrollController controller;
  // 指示器横向布局
  final scrollDirection = Axis.horizontal;
  @override
  void initState() {
    super.initState();
    controller = AutoScrollController(
        viewportBoundaryGetter: () => Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: scrollDirection);
  }
 // 滑动回调
  autoPlay(int index) {
    slidingPosition(index);
    print("轮播图回调");
    setState(() {
      zindex = index;
    });
  }

  // 返回指示器的总宽度
  double getWidth() {
    var num = widget.list.length;
    if (num <= 5) {
      return 3 * 8.0 + 6 + 10;
    } else {
      if (zindex == 0 || zindex == 1 || zindex == 2 || zindex == num -1 || zindex == num - 2 || zindex == num - 3) {
        return 3 * 8.0 + 6 + 10;
      }
      if (zindex >= 3 && zindex+3 < num ) {
        return 2 * 8.0 + 2 * 5.0 + 10 + 2;
      }
    }
    return 5 * 8.0;
  }
  // 通过代码滑动指示器位置。
  slidingPosition(int index) async {
    print("索引$index");
    if (widget.list.length > 5) {
      if (index >= 3 && index+2 < widget.list.length ) {
        await controller.scrollToIndex(index - 2, preferPosition: AutoScrollPosition.begin);
        controller.highlight(index - 2);
      }
      if (index == 2) {
        await controller.scrollToIndex(index , preferPosition: AutoScrollPosition.end);
        controller.highlight(index);
      }
    }
  }
  // 返回指示器内部元素size。
  double elementSize(int index) {
    if (widget.list.length <= 5) {
      if (index == zindex) {
        return 7;
      } else {
        return 5;
      }
    } else {
      if (zindex == 0 || zindex == 1 || zindex == 2) {
        if (index == zindex) {
          return 7;
        } else if (index == 4) {
          return 3;
        } else {
          return 5;
        }
      }
      if (zindex >= 3 && zindex+3 < widget.list.length ) {
        if (index == zindex) {
          return 7;
        } else if (zindex - index == 2 ||  index -zindex == 2) {
          return 3;
        }else {
          return 5;
        }
      }
      if (zindex == widget.list.length -1 || zindex == widget.list.length - 2 || zindex == widget.list.length - 3) {
        if (index == zindex) {
          return 7;
        } else if (index+2 == zindex && zindex == widget.list.length - 3) {
          return 3;
        } else if (index+3 == zindex && zindex == widget.list.length - 2) {
          return 3;
        } else if (index+4 == zindex && zindex == widget.list.length - 1) {
          return 3;
        }else {
          return 5;
        }
      }
    }
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
                  loop: false,
                onIndexChanged: (index) {
                  autoPlay(index);
                },
                // onTap: (index) {
                //   print("点击了第$index个图片");
                // },
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
            height: 10,
            margin: const EdgeInsets.only(top: 5),
            // color: Colors.orange,
            child: ListView.builder(
                scrollDirection: scrollDirection,
                controller: controller,
                itemCount: widget.list.length,
                // 禁止手动滑动
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return AutoScrollTag(
                      key: ValueKey(index),
                      controller: controller,
                      index: index,
                      child: Container(
                          width: elementSize(index) ,
                          height: elementSize(index),
                          margin: const EdgeInsets.only(right: 3),
                          decoration: BoxDecoration(
                              color: index == zindex ? Colors.black : Colors.grey, shape: BoxShape.circle)));
                }),
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