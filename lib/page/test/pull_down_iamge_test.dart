import 'dart:async';
import 'dart:math' as math;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/util/event_bus.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/icon.dart';

/*= "https://img2.baidu.com/it/u=3355464299,584008140&fm=26&fmt=auto&gp=0
      .jpg"*/
class ActivityPullDownRefresh extends StatefulWidget {
  String imageUrl;
  double backGroundHeight;
  String refreshIcons;
  double iconSize;
  Color iconColor;
  List<Widget> children;
  Function onrefresh;
  Function actionTap;
  double height;
  double width;
  // String title;

  ActivityPullDownRefresh(
      {this.height,
      this.width,
      this.backGroundHeight,
      this.children,
      this.refreshIcons,
      this.iconSize,
      this.iconColor,
      this.imageUrl,
      this.onrefresh,
      this.actionTap});

  @override
  _ActivityPullDownRefreshState createState() => _ActivityPullDownRefreshState();
}

class _ActivityPullDownRefreshState extends State<ActivityPullDownRefresh> with TickerProviderStateMixin {
  AnimationController lodingAnimationController;
  StreamController lodingStreamController = StreamController<double>();
  StreamController appBarStreamController = StreamController<double>();
  double upPosition = 0;
  ScrollController scrollController = ScrollController();
  ScrollController lodingScrollController = ScrollController();
  bool isTauch = false;
  double refreshHeight;
  double downOffset = 0;
  double downPixels = 0;
  final double overflowHeight = 50;
  @override
  void initState() {
    super.initState();
    EventBus.getDefault()
        .registerNoParameter(_refreshOver, EVENTBUS_ACTIVITY_DETAILS, registerName: ACTIVITY_REFRESH_OVER);
    _init();
  }

  _refreshOver() {
    // lodingScrollController.animateTo(refreshHeight, duration: Duration(milliseconds: 250), curve: Curves.fastOutSlowIn);
    lodingAnimationController.stop();
  }
  _init() {
    refreshHeight = overflowHeight + widget.iconSize;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      scrollController.jumpTo(overflowHeight);
      lodingScrollController.jumpTo(refreshHeight);
    });
    if (widget.children == null) {
      widget.children = [];
    }

    _controllerListener();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
          height: widget.height,
          width:  widget.width,
          child: Listener(
            onPointerDown: _onPointerDown,
            onPointerUp: _onPointerUp,
            onPointerMove: _onPointerMove,
            child: Stack(
            children: [
              Positioned(
                  top: 0,
                  child: _list()),
              Positioned(
                top: 0,
                child: _topLoding(),
              ),
              Positioned(child: _appBar(),top: 0,)
            ],
          ),
        ));
  }

  Widget _appBar() {
    return StreamBuilder<double>(
        initialData: 1,
        stream: appBarStreamController.stream,
        builder: (BuildContext stramContext, AsyncSnapshot<double> snapshot) {
          return Container(
            height: 44+ScreenUtil.instance.statusBarHeight,
            width: ScreenUtil.instance.width,
            color: AppColor.mainBlack.withOpacity(snapshot.data),
            padding: EdgeInsets.only(left: 8,right: 8,top: ScreenUtil.instance.statusBarHeight),
            child: Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: CustomAppBarIconButton(
                      svgName: AppIcon.nav_return,
                      iconColor: AppColor.white.withOpacity(snapshot.data),
                      onTap: (){
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  flex: 1,
                ),
                Text(
                  "活动详情",
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w500, color: AppColor.white.withOpacity(snapshot.data)),
                ),
                Expanded(
                  child: Align(
                      alignment: Alignment.centerRight,
                      child: CustomAppBarIconButton(
                          svgName: AppIcon.nav_more, iconColor: AppColor.white, onTap: widget.actionTap)),
                  flex: 1,
                ),
              ],
            ),
          );
        });
  }

  Widget _list() {
    List<Widget> list = [];
    Widget backGroundImage = CachedNetworkImage(
      height: widget.backGroundHeight,
      width: ScreenUtil.instance.width,
      imageUrl: widget.imageUrl??"",
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: AppColor.imageBgGrey,
      ),
    );
    if (widget.imageUrl != null) {
      list.insert(0, backGroundImage);
    }
    list.addAll(widget.children);
    return Container(
      height: widget.height,
      width: widget.width,
      child:SingleChildScrollView(
        controller: scrollController,
        child: Column(
          children: List.generate(list.length, (index) {
            return list[index];
          }),
        ),
      )
    );
  }

  Widget _topLoding() {
    return IgnorePointer(
      child: Container(
        height: refreshHeight,
        width: ScreenUtil.instance.width,
        color: AppColor.transparent,
        padding: EdgeInsets.only(left: 16),
        child: SingleChildScrollView(
          controller: lodingScrollController,
          physics: ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: overflowHeight),
              RotationTransition(
                alignment: Alignment.center,
                turns: lodingAnimationController,
                child: StreamBuilder<double>(
                    initialData: 0.0,
                    stream: lodingStreamController.stream,
                    builder: (BuildContext stramContext, AsyncSnapshot<double> snapshot) {
                      return Transform.rotate(
                        angle: math.pi * snapshot.data,
                        child: AppIconButton(
                          svgName: widget.refreshIcons,
                          iconSize: widget.iconSize,
                          iconColor: widget.iconColor,
                        ),
                      );
                    }),
              ),
              Container(
                height: refreshHeight,
              )
            ],
          ),
          // controller: scrollController,
        ),
      ),
    );
  }

  _onPointerDown(PointerDownEvent event) {
    isTauch = true;
    downOffset = event.position.dy;
  }

  _onPointerUp(PointerUpEvent event) {
    isTauch = false;
    upPosition = scrollController.position.pixels;
    if (scrollController.position.pixels < overflowHeight && scrollController.position.maxScrollExtent > 150) {
      scrollController.animateTo(overflowHeight, duration: Duration(milliseconds: 450), curve: Curves.ease);
    }
    if (lodingScrollController.position.pixels < 3) {
      lodingAnimationController.forward();
      widget.onrefresh();
    } else {
      lodingScrollController.animateTo(refreshHeight, duration: Duration(milliseconds: 250), curve: Curves.ease);
    }
  }

  _onPointerMove(PointerMoveEvent event) {
    if (scrollController.position.axisDirection == AxisDirection.down && scrollController.position.pixels < overflowHeight) {
      double moveOffset = 0.0;
      if (scrollController.position.maxScrollExtent > refreshHeight) {
        moveOffset = ((scrollController.position.pixels - overflowHeight));
      } else if (scrollController.position.pixels == scrollController.position.minScrollExtent) {
        moveOffset = downOffset - event.position.dy;
      }
      if (refreshHeight + moveOffset >= 0) {
        lodingScrollController.jumpTo(refreshHeight + moveOffset);
        double angle = 0.0;
        if ((refreshHeight + moveOffset - widget.iconSize) / widget.iconSize <= 1) {
          angle = (refreshHeight + moveOffset - overflowHeight) / widget.iconSize;
        } else {
          angle = (refreshHeight + moveOffset - overflowHeight) / widget.iconSize - 1;
        }
        lodingStreamController.sink.add(angle);
      } else {
        lodingScrollController.jumpTo(lodingScrollController.position.minScrollExtent);
      }
    }
  }

  _controllerListener() {
    scrollController.addListener(() {
     if (!isTauch &&
          upPosition > overflowHeight &&
          scrollController.position.axisDirection == AxisDirection.down &&
          scrollController.position.pixels <= overflowHeight) {
        scrollController.animateTo(scrollController.position.pixels,
            duration: Duration(milliseconds: 150), curve: Curves.fastOutSlowIn);
      }
      if(scrollController.position.pixels>=overflowHeight&& scrollController.position.pixels <= widget
          .backGroundHeight){
        double nowHeight = scrollController.position.pixels - overflowHeight;
        double totalHeight = widget.backGroundHeight - overflowHeight;
        if(nowHeight/totalHeight>=0&&nowHeight/totalHeight<=1){
          appBarStreamController.sink.add(nowHeight/totalHeight);
        }
      }else if(scrollController.position.pixels<overflowHeight){
        appBarStreamController.sink.add(0.0);
      }
    });
    lodingAnimationController = AnimationController(duration: Duration(milliseconds: 250), vsync: this);
    lodingAnimationController.addStatusListener((status) {
      print('-------------------$status');
      if (status == AnimationStatus.completed) {
        lodingAnimationController.reset();
        lodingAnimationController.forward();
      }
    });
  }
}
