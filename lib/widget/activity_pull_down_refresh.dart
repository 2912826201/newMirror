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

GlobalKey<_ActivityPullDownRefreshState> pullDownKey = GlobalKey();

class ActivityPullDownRefresh extends StatefulWidget {
  //图片
  String imageUrl;

  //图片高度
  double backGroundHeight;

  //刷新图标
  String refreshIcons;

  //刷新图标size
  double iconSize;

  //刷新图标颜色
  Color iconColor;

  //子组件
  List<Widget> children;

  //下拉刷新回调
  Function onrefresh;

  //是否需要appBar
  bool needAppBar;

//是否需要appBar右侧按钮
  bool needAction;

  //action按钮点击回调
  Function actionTap;

  //主要滚动控制器
  ScrollController scrollController;

  // String title;

  ActivityPullDownRefresh(
      {Key key,
      this.scrollController,
      this.backGroundHeight,
      this.children,
      this.refreshIcons,
      this.iconSize,
      this.iconColor,
      this.imageUrl,
      this.onrefresh,
      this.needAppBar,
      this.needAction,
      this.actionTap})
      : super(key: key);

  @override
  _ActivityPullDownRefreshState createState() => _ActivityPullDownRefreshState();
}

class _ActivityPullDownRefreshState extends State<ActivityPullDownRefresh> with TickerProviderStateMixin {
  //loading刷新时控制器
  AnimationController lodingAnimationController;

  //loading手指滑动时动画控制器
  StreamController lodingStreamController = StreamController<double>();

  //appBar显隐控制器
  StreamController appBarStreamController = StreamController<double>();

  //抬起的偏移值
  double upOffset = 0;

  //按下的偏移值
  double downOffset = 0;

  //主要控制器
  ScrollController scrollController;

  //刷新滚动控制器
  ScrollController lodingScrollController = ScrollController();

  //是否正在触摸
  bool isTauch = false;

  //刷新动画最大高度
  final double refreshHeight = 100;

  //图片超出屏幕的高度
  final double overflowHeight = 50;

  //动画是否结束(使用stop停止动画status没法正常拿来判断)
  bool refreshIsCompleted = true;
  @override
  void initState() {
    super.initState();
    _init();
  }

  //刷新完成(key调用)
  refreshCompleted() {
    print('refreshCompleted::::::::');
    lodingScrollController.animateTo(refreshHeight, duration: Duration(milliseconds: 250), curve: Curves.fastOutSlowIn);
    lodingAnimationController.stop(canceled: true);
    refreshIsCompleted = true;
  }

  //调用刷新(key调用)
  refresh() {
    print('refresh::::::::');
    lodingScrollController.animateTo(0, duration: Duration(milliseconds: 250), curve: Curves.fastOutSlowIn);
    lodingAnimationController.forward();
  }

  _init() {
    scrollController = widget.scrollController;
    //初始化loading图标和图片偏移位置
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
        height: ScreenUtil.instance.height,
        width: ScreenUtil.instance.width,
        child: Listener(
          onPointerDown: _onPointerDown,
          onPointerUp: _onPointerUp,
          onPointerMove: _onPointerMove,
          child: Stack(
            children: [
              Positioned(top: 0, child: _list()),
              Positioned(
                top: 0,
                child: _topLoding(),
              ),
              widget.needAppBar
                  ? Positioned(
                      child: _appBar(),
                      top: 0,
                    )
                  : Container()
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
            height: 44 + ScreenUtil.instance.statusBarHeight,
            width: ScreenUtil.instance.width,
            color: AppColor.mainBlack.withOpacity(snapshot.data),
            padding: EdgeInsets.only(left: 8, right: 8, top: ScreenUtil.instance.statusBarHeight),
            child: Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: CustomAppBarIconButton(
                      svgName: AppIcon.nav_return,
                      iconColor: AppColor.white.withOpacity(snapshot.data),
                      onTap: () {
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
                widget.needAction
                    ? Expanded(
                        child: Align(
                            alignment: Alignment.centerRight,
                            child: CustomAppBarIconButton(
                                svgName: AppIcon.nav_more, iconColor: AppColor.white, onTap: widget.actionTap)),
                        flex: 1,
                      )
                    : Spacer(),
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
      imageUrl: widget.imageUrl ?? "",
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
        height: ScreenUtil.instance.height,
        width: ScreenUtil.instance.width,
        child: SingleChildScrollView(
          controller: scrollController,
          child: Column(
            children: List.generate(list.length, (index) {
              return list[index];
            }),
          ),
        ));
  }

  Widget _topLoding() {
    //触摸穿透
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
              Container(height: refreshHeight - widget.iconSize),
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
    upOffset = scrollController.position.pixels;
    //图片回到初始位置
    if (scrollController.position.pixels < overflowHeight && scrollController.position.maxScrollExtent > 150) {
      scrollController.animateTo(overflowHeight, duration: Duration(milliseconds: 450), curve: Curves.ease);
    }
    if(!refreshIsCompleted) return;
    //条件达成开始刷新
    if (lodingScrollController.position.pixels < 3) {
      lodingAnimationController.forward();
      widget.onrefresh();
    } else {
      //回到初始位置
      lodingScrollController.animateTo(refreshHeight, duration: Duration(milliseconds: 250), curve: Curves.ease);
    }
  }

  _onPointerMove(PointerMoveEvent event) {
    if (scrollController.position.axisDirection == AxisDirection.down &&
        scrollController.position.pixels < overflowHeight &&
        refreshIsCompleted) {
      double moveOffset = 0.0;
      //loding跟随图片滑动比例
      if (scrollController.position.maxScrollExtent > refreshHeight) {
        moveOffset = (refreshHeight / overflowHeight) * (overflowHeight - scrollController.position.pixels);
      } else if (scrollController.position.pixels == scrollController.position.minScrollExtent) {
        moveOffset = downOffset - event.position.dy;
      }
      //////////////loading跟随手指偏移旋转(随便写的频率)////////////////////
      double angle = ((event.position.dy - downOffset) % 30) / 30;
      lodingStreamController.sink.add(angle);
      ////////////loading跟随手指偏移///////////////
      if (refreshHeight - moveOffset >= 0) {
        lodingScrollController.jumpTo(refreshHeight - moveOffset);
      } else {
        lodingScrollController.jumpTo(lodingScrollController.position.minScrollExtent);
      }
    }
  }

  _controllerListener() {
    scrollController.addListener(() {
      //快速惯性滚动阻尼
      if (!isTauch &&
          upOffset > overflowHeight &&
          scrollController.position.axisDirection == AxisDirection.down &&
          scrollController.position.pixels <= overflowHeight) {
        scrollController.animateTo(scrollController.position.pixels,
            duration: Duration(milliseconds: 150), curve: Curves.fastOutSlowIn);
      }

      ///////////////appBar显隐控制//////////////
      if (scrollController.position.pixels >= overflowHeight &&
          scrollController.position.pixels <= widget.backGroundHeight) {
        double nowHeight = scrollController.position.pixels - overflowHeight;
        double totalHeight = widget.backGroundHeight - overflowHeight;
        if (nowHeight / totalHeight >= 0 && nowHeight / totalHeight <= 1) {
          appBarStreamController.sink.add(nowHeight / totalHeight);
        }
      } else if (scrollController.position.pixels < overflowHeight) {
        appBarStreamController.sink.add(0.0);
      }
    });
    lodingAnimationController = AnimationController(duration: Duration(milliseconds: 250), vsync: this);
    lodingAnimationController.addStatusListener((status) {
      //动画无限循环
      if (status == AnimationStatus.completed) {
        refreshIsCompleted = false;
        lodingAnimationController.reset();
        lodingAnimationController.forward();
      }
    });
  }
}
