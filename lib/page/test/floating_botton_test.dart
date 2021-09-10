import 'package:dough/dough.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mirror/constant/color.dart';
import 'dart:math' as math;

import 'package:mirror/page/activity/activity_page.dart';
import 'package:mirror/route/router.dart';

class FloatingBottonTestPage extends StatefulWidget {
  FloatingBottonTestPage({Key key}) : super(key: key);

  @override
  _FloatingBottonTestPageState createState() => new _FloatingBottonTestPageState();
}

class _FloatingBottonTestPageState extends State<FloatingBottonTestPage> {
  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dragball(
      withIcon: false,
      ball: Container(
        child: PressableDough(
            child: FloatingActionButton(
          child: const Icon(
            Icons.add,
            size: 25,
          ),
          foregroundColor: AppColor.mainBlack,
          backgroundColor: AppColor.white,
          elevation: 7.0,
          highlightElevation: 14.0,
          isExtended: false,
          onPressed: () {
            AppRouter.navigateCreateActivityPage(context);
          },
          mini: true,
        )),
      ),
      ballSize: 50,
      startFromRight: true,
      initialTop: MediaQuery.of(context).size.height * 0.75,
      onTap: () {
        print('点击了悬浮图标');
        Navigator.of(context).push(new MaterialPageRoute(builder: (context) {
          return ActivityPage();
        }));
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Dragball Example'),
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemBuilder: (BuildContext context, int index) {
            return Container(
              height: 200,
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
            );
          },
          itemCount: 15,
        ),
      ),
    );
  }
}

class Dragball extends StatefulWidget {
  const Dragball({
    Key key,
    @required this.child,
    @required this.ball,
    @required this.ballSize,
    @required this.onTap,
    this.marginTopBottom = 150,
    this.withIcon = true,
    this.icon,
    this.iconSize = 24,
    this.iconColor,
    this.iconPadding = 3,
    @Deprecated('This property don\'t work again, replace to backroundDecoration') this.backgroundIconColor,
    @Deprecated('This property don\'t work again, replace to backroundDecoration') this.borderRadiusBackgroundIcon,
    this.backgroundDecorationIcon,
    this.startFromRight = false,
    this.animationSizeDuration,
    this.curveSizeAnimation,
    this.initialTop,
  }) : super(key: key);

  /// 把你的屏幕放在这里
  /// 例如你的[脚手架]
  final Widget child;

  /// 这个小部件用于自定义你的球
  /// 图像示例
  /// 确保大小与 [ballSize] 属性相同
  final Widget ball;

  /// 调整你的球
  /// 请正确填写并与[ball]属性大小相同，这会影响计算过程
  final double ballSize;

  /// 当球被按下时会调用这个函数
  final Function onTap;

  /// 自定义保证金顶部底部
  /// 球不会在那个位置
  /// 默认 [marginTopBottom: 150]
  final double marginTopBottom;

  // 第一次调用时右侧的初始化位置
  /// 默认 [startFromRight: false]
  final bool startFromRight;

  /// 自定义图标隐藏/显示球
  /// 默认值：[Icons.navigate_before_rounded]
  final IconData icon;

  /// 图标的背景颜色
  /// 默认值：[Colors.white]
  final Color iconColor;

  /// 容器包装图标的背景颜色
  /// 默认值：[primaryColor]
  final Color backgroundIconColor;

  /// 容器包装图标的 BorderRadius
  /// 默认值：[0]
  final BorderRadius borderRadiusBackgroundIcon;

  /// 用于装饰图标背景的属性
  /// 默认情况下，它将根据您的原色进行着色，
  /// 和圆形
  final BoxDecoration backgroundDecorationIcon;

  /// 大小动画的自定义持续时间
  /// 默认 [持续时间：持续时间（毫秒：200）]
  final Duration animationSizeDuration;

  /// 曲线大小动画
  /// 默认 [曲线：Curves.easeIn]
  final Curve curveSizeAnimation;

  /// 曲线大小动画
  /// 默认 [曲线：Curves.easeIn]
  final double initialTop;

  /// 如果你想要自定义图标大小
  /// 根据需要更改值
  /// 默认[图标大小：24]
  final double iconSize;

  /// 这将调整图标和背景之间的距离
  /// 如果你想要自定义图标填充
  /// 根据需要更改值
  /// 默认[iconPadding: 3]
  final double iconPadding;

  /// 如果你不想显示带有图标的球，
  /// 将值更改为false
  /// 默认[withIcon: true]
  final bool withIcon;

  @override
  _DragballState createState() => _DragballState();
}

class _DragballState extends State<Dragball> with TickerProviderStateMixin {
  bool _isBallDraged = false, _isBallHide = false, _isPositionOnRight = false;
  double _top, _left = 0, _right, _bottom;
  IconData _icon;

  AnimationController _animationController;
  AnimationController _offsetAnimationController;
  AnimationController _rotateIconAnimationController;
  Animation<double> _sizeAnimation;
  Animation<Offset> _offsetAnimation;
  Animation<double> _rotateIconAnimation;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: widget.animationSizeDuration ?? Duration(milliseconds: 200));
    _sizeAnimation = Tween<double>(begin: 1, end: 0).animate(CurvedAnimation(
      parent: _animationController,
      curve: widget.curveSizeAnimation ?? Curves.easeIn,
    ));
    _offsetAnimationController = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _offsetAnimation = Tween<Offset>(begin: Offset.zero, end: Offset(0.6, 0.0)).animate(CurvedAnimation(
      parent: _offsetAnimationController,
      curve: widget.curveSizeAnimation ?? Curves.easeIn,
    ));
    _rotateIconAnimationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _rotateIconAnimation = Tween<double>(begin: 0, end: -math.pi).animate(_rotateIconAnimationController);
    _icon = widget.icon ?? Icons.navigate_before_rounded;

    _initialPosition();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant Dragball oldWidget) {
    if (widget.icon != null) {
      if (widget.icon != _icon) {
        _icon = widget.icon ?? Icons.navigate_before_rounded;
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  /// 函数初始化位置
  /// 刚刚调用了 [initState]
  void _initialPosition() {
    _top = widget.initialTop ?? widget.marginTopBottom;
    if (widget.startFromRight) {
      _left = null;
      _right = 0;
      _isPositionOnRight = true;
      _rotateIconAnimationController.forward();
    }
  }

  /// 监控是否有滚动活动
  /// 如果有滚动活动这个函数将触发大小动画
  bool _onNotification(ScrollNotification scrollNotification) {
    if (scrollNotification == null) {
      return false;
    }
    if (scrollNotification is ScrollStartNotification) {
      if (scrollNotification.metrics.axis == Axis.vertical) {
        _animationController.forward();
      }
    }
    if (scrollNotification is ScrollEndNotification) {
      if (scrollNotification.metrics.axis == Axis.vertical) {
        _animationController.reverse();
      }
    }
    return false;
  }

  /// 此函数将隐藏球或显示球
  void _onHideOrShowBall() {
    if (!_isBallHide) {
      _offsetAnimationController.forward();
      if (_isPositionOnRight) {
        _rotateIconAnimationController.reverse();
      } else {
        _rotateIconAnimationController.forward();
      }
    } else {
      _offsetAnimationController.reverse();
      if (_isPositionOnRight) {
        _rotateIconAnimationController.forward();
      } else {
        _rotateIconAnimationController.reverse();
      }
    }
    setState(() {
      _isBallHide = !_isBallHide;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _offsetAnimationController.dispose();
    _rotateIconAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return NotificationListener<ScrollNotification>(
      onNotification: _onNotification,
      child: Stack(
        children: [
          RepaintBoundary(
            child: widget.child,
          ),
          Positioned(
            top: _top,
            left: _left,
            right: _right,
            bottom: _bottom,
            width: widget.ballSize + (widget.iconSize + widget.iconPadding) / 2,
            height: widget.ballSize,
            child: AnimatedBuilder(
              animation: _offsetAnimationController,
              builder: (context, child) {
                if (_isPositionOnRight) {
                  return FractionalTranslation(
                    translation: _offsetAnimation.value,
                    child: child,
                  );
                } else {
                  return FractionalTranslation(
                    translation: Offset(-_offsetAnimation.value.dx, 0.0),
                    child: child,
                  );
                }
              },
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _sizeAnimation.value,
                    child: child,
                  );
                },
                child: Visibility(
                  visible: !_isBallDraged,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        right: _isPositionOnRight ? 0 : null,
                        left: !_isPositionOnRight ? 0 : null,
                        child: MouseRegion(
                          cursor: MaterialStateMouseCursor.clickable,
                          child: GestureDetector(
                            child: widget.ball,
                            onTap: !_isBallHide
                                ? () {
                                    widget.onTap();
                                  }
                                : null,
                          ),
                        ),
                      ),
                      Visibility(
                        visible: widget.withIcon,
                        child: Positioned(
                          right: _isPositionOnRight ? null : 0,
                          left: !_isPositionOnRight ? null : 0,
                          child: GestureDetector(
                            onTap: () => _onHideOrShowBall(),
                            behavior: HitTestBehavior.translucent,
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: AnimatedBuilder(
                                animation: _rotateIconAnimationController,
                                builder: (context, icon) {
                                  return Transform.rotate(
                                    angle: _rotateIconAnimation.value,
                                    child: icon,
                                  );
                                },
                                child: Container(
                                  padding: EdgeInsets.all(widget.iconPadding),
                                  decoration: widget.backgroundDecorationIcon ??
                                      BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: theme.primaryColor,
                                      ),
                                  child: Icon(
                                    _icon,
                                    color: widget.iconColor ?? Colors.white,
                                    size: widget.iconSize,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
