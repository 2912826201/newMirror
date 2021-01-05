import 'dart:async';

import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound_lite/flutter_sound.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:mirror/data/notifier/token_notifier.dart';
import 'package:mirror/page/home/sub_page/share_page/dynamic_list.dart';
import 'package:mirror/page/search/sub_page/should_build.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:provider/provider.dart';

// 轮播图
class SlideBanner extends StatefulWidget {
  SlideBanner({Key key, this.height, this.model}) : super(key: key);
  HomeFeedModel model;
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
  double photoHeight;
  @override
  void initState() {
    photoHeight = setAspectRatio(widget.height);
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
    var num = widget.model.picUrls.length;
    if (num <= 5) {
      return 3 * 8.0 + 6 + 10;
    } else {
      if (zindex == 0 || zindex == 1 || zindex == 2 || zindex == num - 1 || zindex == num - 2 || zindex == num - 3) {
        return 3 * 8.0 + 6 + 10;
      }
      if (zindex >= 3 && zindex + 3 < num) {
        return 2 * 8.0 + 2 * 5.0 + 10 + 2;
      }
    }
    return 5 * 8.0;
  }

  // 通过代码滑动指示器位置。
  slidingPosition(int index) async {
    print("索引$index");
    if (widget.model.picUrls.length > 5) {
      if (index >= 3 && index + 2 < widget.model.picUrls.length) {
        await controller.scrollToIndex(index - 2, preferPosition: AutoScrollPosition.begin);
        controller.highlight(index - 2);
      }
      if (index == 2) {
        await controller.scrollToIndex(index, preferPosition: AutoScrollPosition.end);
        controller.highlight(index);
      }
    }
  }

  // 返回指示器内部元素size。
  double elementSize(int index) {
    if (widget.model.picUrls.length <= 5) {
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
      if (zindex >= 3 && zindex + 3 < widget.model.picUrls.length) {
        if (index == zindex) {
          return 7;
        } else if (zindex - index == 2 || index - zindex == 2) {
          return 3;
        } else {
          return 5;
        }
      }
      if (zindex == widget.model.picUrls.length - 1 ||
          zindex == widget.model.picUrls.length - 2 ||
          zindex == widget.model.picUrls.length - 3) {
        if (index == zindex) {
          return 7;
        } else if (index + 2 == zindex && zindex == widget.model.picUrls.length - 3) {
          return 3;
        } else if (index + 3 == zindex && zindex == widget.model.picUrls.length - 2) {
          return 3;
        } else if (index + 4 == zindex && zindex == widget.model.picUrls.length - 1) {
          return 3;
        } else {
          return 5;
        }
      }
    }
  }

  /// 列表中的每个条目的Widget
  /// [index] 列表条目对应的索引
  // buildOpenContainerItem(int index) {
  //   return OpenContainer(
  //     // 动画时长
  //     transitionDuration: const Duration(milliseconds: 700),
  //     transitionType: ContainerTransitionType.fade,
  //     //阴影
  //     closedElevation: 0.0,
  //     //圆角
  //     closedShape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.all(Radius.circular(0.0)),
  //     ),
  //     ///将要打开的页面
  //     openBuilder:
  //         (BuildContext context, void Function({Object returnValue}) action) {
  //       return Item2Page(photoUrl: widget.model.picUrls[index].url,);
  //     },
  //     ///现在显示的页面
  //     closedBuilder: (BuildContext context, void Function() action) {
  //       ///条目显示的一张图片
  //       return buildShowItemContainer(index);
  //     },
  //   );
  // }
  // 轮播图图片设置
  Container buildShowItemContainer(int index,double height) {
    return Container(
      // child: Image.network(
      //   widget.model.picUrls[index].url,
      //   fit: BoxFit.cover,
      // ),
      width: ScreenUtil.instance.width,
        height:height ,
        child: CachedNetworkImage(
          fit: BoxFit.cover,
          placeholder: (context, url) => new Container(
              child: new Center(
                child: new CircularProgressIndicator(),
              )),
          imageUrl:  widget.model.picUrls[index].url != null ?  widget.model.picUrls[index].url : "",
          errorWidget: (context, url, error) => new Image.asset("images/test.png"),
        )
    );
  }

  // 宽高比
  double setAspectRatio(double height) {
    return (ScreenUtil.instance.width / widget.model.picUrls[0].width) * height;
  }

  // 点赞
  setUpLuad() async {
    bool isLoggedIn = context.read<TokenNotifier>().isLoggedIn;
    if (isLoggedIn) {
      Map<String, dynamic> model = await laud(id: widget.model.id, laud: widget.model.isLaud == 0 ? 1 : 0);
      // 点赞/取消赞成功
      print("state:${model["state"]}");
      if (model["state"]) {
        context.read<FeedMapNotifier>().setLaud(widget.model.isLaud,context.read<ProfileNotifier>().profile.avatarUri,widget.model.id);
      } else {
        // 失败
        print("shib ");
      }
    } else {
      // 去登录
      AppRouter.navigateToLoginPage(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = ScreenUtil.instance.screenWidthDp;
    return Container(
      child: Column(
        children: [
          Stack(
      children: [
              GestureDetector(
                onDoubleTap: () {
                  // 获取是否点赞
                  int isLaud = widget.model.isLaud;
                  if (isLaud != 1) {
                    setUpLuad();
                  }
                  // 动画
                },
                child: Container(
                  width: width,
                  height: photoHeight
                  // setAspectRatio(widget.height)
                  ,
                  child: Swiper(
                    itemCount: widget.model.picUrls.length,
                    itemBuilder: (BuildContext context, int index) {
                      return buildShowItemContainer(index,photoHeight);
                      // buildOpenContainerItem(index);
                    },
                    loop: false,
                    onIndexChanged: (index) {
                      autoPlay(index);
                    },
                    onTap: (index) {
                      print("点击了第$index个图片");
                    },
                  ),
                ),
              ),
              Positioned(
                top: 13,
                right: 16,
                child: Offstage(
                  offstage: widget.model.picUrls.length == 1,
                  child: Container(
                    padding: EdgeInsets.only(left: 6, top: 3, right: 6, bottom: 3),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(12)), color: AppColor.textPrimary1.withOpacity(0.5)),
                    child: Text(
                      "${zindex + 1}/${widget.model.picUrls.length}",
                      style: TextStyle(color: AppColor.white, fontSize: 12),
                    ),
                  ),
                ),
                // child:
              )
            ],
          ),
          Offstage(
            offstage: widget.model.picUrls.length == 1,
            child: Container(
              width: getWidth(),
              height: 10,
              margin: const EdgeInsets.only(top: 5),
              // color: Colors.orange,
              child: ListView.builder(
                  scrollDirection: scrollDirection,
                  controller: controller,
                  itemCount: widget.model.picUrls.length,
                  // 禁止手动滑动
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return AutoScrollTag(
                        key: ValueKey(index),
                        controller: controller,
                        index: index,
                        child: Container(
                            width: elementSize(index),
                            height: elementSize(index),
                            margin: const EdgeInsets.only(right: 3),
                            decoration: BoxDecoration(
                                color: index == zindex ? Colors.black : Colors.grey, shape: BoxShape.circle)));
                  }),
            ),
          )
        ],
      ),
    );
  }
}

class Item2Page extends StatefulWidget {

  String photoUrl;
  HomeFeedModel model;
  int index;
  bool isComplex;
  Item2Page({Key key, this.photoUrl,this.model,this.index,this.isComplex}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _Item2PageState();
  }
}

class _Item2PageState extends State<Item2Page> {
  @override
  Widget shouldBuild(BuildContext context) {


    ///页面二中的Hero
  }

  @override
  Widget build(BuildContext context) {
    print("第${widget.index}个元素的动态ID：：：：${widget.model.id}");
    return  Scaffold(
        backgroundColor: Colors.white,
        body:
        Column(
          children: [
            Container(
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child:Hero (
                  tag: widget.isComplex ? "complex${widget.model.id}" : "${widget.model.id}:${widget.index}",
                  child: Image.network(widget.model.picUrls[0].url),
                  // SlideBanner(height: model.picUrls[0].height.toDouble(),model: model,),
                ),
                // ,
              ),
            ),
            Container(
              height: 50,
              color: Colors.red,
            )
          ],
        )
    );
  }
}
