import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/util/screen_util.dart';
import 'triangle_painter.dart';

const double _kMenuScreenPadding = 8.0;

//消息的长按操作框
class LongClickPopupMenu extends StatefulWidget {
  LongClickPopupMenu({
    Key key,
    @required this.onValueChanged,
    @required this.actions,
    @required this.child,
    @required this.contentType,
    @required this.isMySelf,
    this.pressType = PressType.longPress,
    this.isCanLongClick = true,
    this.pageMaxChildCount = 5,
    this.backgroundColor = AppColor.textPrimary1,
    this.contentWidth = 180,
    this.contentHeight = 0,
    this.leftAndRightWidth = 112,
  });

  final ValueChanged<int> onValueChanged;
  final List<String> actions;
  final Widget child;
  final bool isCanLongClick;
  final PressType pressType; // 点击方式 长按 还是单击
  final int pageMaxChildCount;
  final Color backgroundColor;
  final double contentWidth;
  final double contentHeight;
  final double leftAndRightWidth;
  final String contentType;
  final bool isMySelf;

  @override
  _LongClickPopupMenuState createState() => _LongClickPopupMenuState();
}

class _LongClickPopupMenuState extends State<LongClickPopupMenu> {
  double width;
  double height;
  RenderBox button;
  RenderBox overlay;
  OverlayEntry entry;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((call) {
      try {
        if (context != null&&context.size!=null) {
          width = context.size.width;
          height = context.size.height;
          button = context.findRenderObject();
          overlay = Overlay.of(context).context?.findRenderObject();
        }
      } catch (e) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (entry != null) {
          removeOverlay();
        }
        return Future.value(true);
      },
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        child: widget.child,
        onTap: () {
          if (widget.pressType == PressType.singleClick && widget.isCanLongClick) {
            onTap();
          }
        },
        onLongPress: () {
          if (widget.pressType == PressType.longPress && widget.isCanLongClick) {
            onTap();
          }
        },
      ),
    );
  }

  void onTap() {
    Widget menuWidget = _MenuPopWidget(
      context,
      height,
      width,
      widget.actions,
      widget.pageMaxChildCount,
      widget.backgroundColor,
      button,
      overlay,
      (index) {
        if (index != -1) widget.onValueChanged(index);
        removeOverlay();
      },
      widget.contentWidth,
      widget.contentType,
      widget.isMySelf,
      widget.leftAndRightWidth,
      widget.contentHeight
    );

    entry = OverlayEntry(builder: (context) {
      return menuWidget;
    });
    Overlay.of(context).insert(entry);
  }

  void removeOverlay() {
    entry.remove();
    entry = null;
  }
}

enum PressType {
  // 长按
  longPress,
  // 单击
  singleClick,
}

class _MenuPopWidget extends StatefulWidget {
  final BuildContext btnContext;
  final List<String> actions;
  final int _pageMaxChildCount;
  final Color backgroundColor;
  final double _height;
  final double _width;
  final RenderBox button;
  final RenderBox overlay;
  final ValueChanged<int> onValueChanged;
  final double contentWidth;
  final String contentType;
  final bool isMySelf;
  final double leftAndRightWidth;
  final double contentHeight;

  _MenuPopWidget(
    this.btnContext,
    this._height,
    this._width,
    this.actions,
    this._pageMaxChildCount,
    this.backgroundColor,
    this.button,
    this.overlay,
    this.onValueChanged,
    this.contentWidth,
    this.contentType,
    this.isMySelf,
    this.leftAndRightWidth,
    this.contentHeight,
  );

  @override
  _MenuPopWidgetState createState() => _MenuPopWidgetState();
}

class _MenuPopWidgetState extends State<_MenuPopWidget> {
  int _curPage = 0;
  final double _arrowWidth = 40;
  final double _separatorWidth = 1;
  final double _triangleHeight = 10;

  double menuWidth = 57.0 * 3;
  final double menuHeight = 32.0;

  RelativeRect position;

  @override
  void initState() {
    super.initState();
    try{
      position = RelativeRect.fromRect(
        Rect.fromPoints(
          widget.button.localToGlobal(Offset.zero, ancestor: widget.overlay),
          widget.button.localToGlobal(Offset.zero, ancestor: widget.overlay),
        ),
        Offset.zero & widget.overlay.size,
      );
    }catch(e){}
  }

  @override
  Widget build(BuildContext context) {
    menuWidth = 57.0 * widget.actions?.length;

    // 这里计算出来 当前页的 child 一共有多少个
    int _curPageChildCount =
        (_curPage + 1) * widget._pageMaxChildCount > widget.actions.length
            ? widget.actions.length % widget._pageMaxChildCount
            : widget._pageMaxChildCount;

    double _curArrowWidth = 0;
    int _curArrowCount = 0; // 一共几个箭头

    if (widget.actions.length > widget._pageMaxChildCount) {
      // 数据长度大于 widget._pageMaxChildCount
      if (_curPage == 0) {
        // 如果是第一页
        _curArrowWidth = _arrowWidth;
        _curArrowCount = 1;
      } else {
        // 如果不是第一页 则需要也显示左箭头
        _curArrowWidth = _arrowWidth * 2;
        _curArrowCount = 2;
      }
    }

    double _curPageWidth = menuWidth +
        (_curPageChildCount - 1 + _curArrowCount) * _separatorWidth +
        _curArrowWidth;

    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            GestureDetector(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.transparent,
              ),
              onTapDown: (v) {
                widget.onValueChanged(-1);
              },
            ),
            Container(
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                removeBottom: true,
                removeLeft: true,
                removeRight: true,
                child: Builder(
                  builder: (BuildContext context) {
                    // var isInverted=false;
                    //
                    // if(position.top<(menuHeight + _triangleHeight)*2){
                    //   isInverted=true;
                    // }

                    var isInverted1 = position.top-ScreenUtil.instance.statusBarHeight-44< 80;
                    print("isInverted:${isInverted1}");
                    print("isInverted1:${position.top-ScreenUtil.instance.statusBarHeight-44}");
                    // print("1:${MediaQuery.of(context).size.height}");
                    // print("1:${position.bottom}");
                    // print("1:${(MediaQuery.of(context).size.height -
                    //     position.top -
                    //     position.bottom)/2.0}");
                    // print("height1:${(position.top +
                    //     (MediaQuery.of(context).size.height -
                    //         position.top -
                    //         position.bottom) /
                    //         2.0 -
                    //     (menuHeight + _triangleHeight))}");
                    //
                    // print("heiught2:${(menuHeight + _triangleHeight)}");

                    var alignment = Alignment.center;
                    var customPaintWidth = menuWidth;
                    var widgetContentWidth = widget.contentWidth;

                    //当长按框的最大宽度小于内容的宽度
                    //设置内容的宽度是最大宽度
                    if (widget.contentWidth >
                        MediaQuery.of(context).size.width -
                            widget.leftAndRightWidth) {
                      widgetContentWidth = MediaQuery.of(context).size.width -
                          widget.leftAndRightWidth;
                    }

                    //长按框距离用户头像的另一边的宽度
                    var marginLeftOrRightWidth =
                        (MediaQuery.of(context).size.width -
                            widget.leftAndRightWidth / 2 -
                            widgetContentWidth +
                            20);

                    //如果内容的宽度小于长按框的宽度-则对齐用户头像位置
                    if (MediaQuery.of(context).size.width -
                            marginLeftOrRightWidth -
                            widget.leftAndRightWidth / 2 <
                        _curPageWidth) {
                      print("如果内容的宽度小于长按框的宽度-则对齐用户头像位置");
                      marginLeftOrRightWidth = 0;
                      customPaintWidth = widgetContentWidth;
                    }

                    //长按框距离左右的值
                    var marginNoMySelf =
                        EdgeInsets.only(left: 0, right: marginLeftOrRightWidth);
                    var marginMySelf =
                        EdgeInsets.only(right: 0, left: marginLeftOrRightWidth);

                    return CustomSingleChildLayout(
                      // 这里计算偏移量
                      delegate: _PopupMenuRouteLayout(
                          position,
                          menuHeight + 13, //这里是间距的高度
                          Directionality.of(widget.btnContext),
                          widget._width,
                          menuWidth,
                          widget._height,
                          widget.contentHeight,
                          widget.contentWidth,
                          isInverted1,
                          widget.isMySelf,),
                      child: Container(
                        color: Colors.deepPurple.withOpacity(0.245),
                        alignment: widget.isMySelf ? Alignment.topRight : Alignment.topLeft,
                        height: menuHeight + _triangleHeight,
                        // margin: widget.isMySelf ? marginMySelf : marginNoMySelf,
                        width: double.infinity,
                        child: UnconstrainedBox(
                          child: GestureDetector(
                            child: SizedBox(
                              height: menuHeight + _triangleHeight,
                              child: Material(
                                color: Colors.transparent,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    isInverted1
                                        ? Container(
                                            width: menuWidth,
                                            alignment: alignment,
                                            child: UnconstrainedBox(
                                              child: Container(
                                                child: CustomPaint(
                                                  size: Size(_curPageWidth,
                                                      _triangleHeight),
                                                  painter: TrianglePainter(
                                                    color:
                                                    widget.backgroundColor,
                                                    position: position,
                                                    isInverted: true,
                                                    size: widget.button.size,
                                                    screenWidth:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        : Container(),
                                    Expanded(
                                        child: Container(
                                      child: Stack(
                                        children: <Widget>[
                                          ClipRRect(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(5)),
                                            child: Container(
                                              color: widget.backgroundColor,
                                              height: menuHeight,
                                            ),
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              // 左箭头：判断是否是第一页，如果是第一页则不显示
                                              _curPage == 0
                                                  ? Container(
                                                      height: menuHeight,
                                                    )
                                                  : InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          _curPage--;
                                                        });
                                                      },
                                                      child: Container(
                                                        width: _arrowWidth,
                                                        height: menuHeight,
                                                        child: Image.asset(
                                                          'images/left_white.png',
                                                          fit: BoxFit.none,
                                                        ),
                                                      ),
                                                    ),
                                              // 左箭头：判断是否是第一页，如果是第一页则不显示
                                              _curPage == 0
                                                  ? Container(
                                                      height: menuHeight,
                                                    )
                                                  : Container(
                                                      width: 1,
                                                      height: menuHeight,
                                                      color: Colors.grey,
                                                    ),

                                              // 中间是ListView
                                              _buildList(
                                                  _curPageChildCount,
                                                  _curPageWidth,
                                                  _curArrowWidth,
                                                  _curArrowCount),

                                              // 右箭头：判断是否有箭头，如果有就显示，没有就不显示
                                              _curArrowCount > 0
                                                  ? Container(
                                                      width: 1,
                                                      color: Colors.grey,
                                                      height: menuHeight,
                                                    )
                                                  : Container(
                                                      height: menuHeight,
                                                    ),
                                              _curArrowCount > 0
                                                  ? InkWell(
                                                      onTap: () {
                                                        if ((_curPage + 1) *
                                                                widget
                                                                    ._pageMaxChildCount <
                                                            widget
                                                                .actions.length)
                                                          setState(() {
                                                            _curPage++;
                                                          });
                                                      },
                                                      child: Container(
                                                        width: _arrowWidth,
                                                        height: menuHeight,
                                                        child: Image.asset(
                                                          (_curPage + 1) *
                                                                      widget
                                                                          ._pageMaxChildCount >=
                                                                  widget.actions
                                                                      .length
                                                              ? 'images/right_gray.png'
                                                              : 'images/right_white.png',
                                                          fit: BoxFit.none,
                                                        ),
                                                      ),
                                                    )
                                                  : Container(
                                                      height: menuHeight,
                                                    ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColor.textPrimary1,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    )),
                                    isInverted1
                                        ? Container()
                                        : Container(
                                        width: menuWidth,
                                        alignment: alignment,
                                        child: UnconstrainedBox(
                                          child: Container(
                                            width: menuWidth,
                                            child: CustomPaint(
                                              size: Size(_curPageWidth,
                                                  _triangleHeight),
                                              painter: TrianglePainter(
                                                color:
                                                widget.backgroundColor,
                                                position: position,
                                                size: widget.button.size,
                                                screenWidth:
                                                MediaQuery
                                                        .of(context)
                                                        .size
                                                        .width,
                                                  ),
                                                ),
                                              ),
                                            ))
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ));
  }

  Widget _buildList(int _curPageChildCount, double _curPageWidth,
      double _curArrowWidth, int _curArrowCount) {
    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      scrollDirection: Axis.horizontal,
      itemCount: _curPageChildCount,
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          onTap: () {
            widget.onValueChanged(_curPage * widget._pageMaxChildCount + index);
          },
          onTapDown: (v) {},
          child: SizedBox(
            width: (_curPageWidth -
                    _curArrowWidth -
                    (_curPageChildCount - 1 + _curArrowCount) *
                        _separatorWidth) /
                _curPageChildCount,
            height: menuHeight,
            child: Center(
              child: Text(
                widget.actions[_curPage * widget._pageMaxChildCount + index],
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return Container(
          width: 1,
          height: menuHeight,
        );
      },
    );
  }
}

// Positioning of the menu on the screen.
class _PopupMenuRouteLayout extends SingleChildLayoutDelegate {
  _PopupMenuRouteLayout(this.position, this.selectedItemOffset,
      this.textDirection, this.width, this.menuWidth, this.height
      ,this.contentHeight,this.contentWidth,this.isInverted,this.isMySelf);

  // Rectangle of underlying button, relative to the overlay's dimensions.
  final RelativeRect position;

  // The distance from the top of the menu to the middle of selected item.
  //
  // This will be null if there's no item to position in this way.
  final double selectedItemOffset;

  // Whether to prefer going to the left or to the right.
  final TextDirection textDirection;

  final double width;
  final double height;
  final double menuWidth;
  final double contentHeight;
  final double contentWidth;
  final bool isInverted;
  final bool isMySelf;

  // We put the child wherever position specifies, so long as it will fit within
  // the specified parent size padded (inset) by 8. If necessary, we adjust the
  // child's position so that it fits.

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    // The menu can be at most the size of the overlay minus 8.0 pixels in each
    // direction.
    return BoxConstraints.loose(constraints.biggest -
        const Offset(_kMenuScreenPadding * 2.0, _kMenuScreenPadding * 2.0));
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    // size: The size of the overlay.
    // childSize: The size of the menu, when fully open, as determined by
    // getConstraintsForChild.

    // Find the ideal vertical position.



    // print("contentHeight:${contentHeight}");
    // print("contentWidth:${contentWidth}");
    // print("childSize.height:${childSize.height}");
    // print("childSize.width:${childSize.width}");
    // print("position.top:${position.top}");
    // print("position.bottom:${position.bottom}");
    // print("position.left:${position.left}");
    // print("position.right:${position.right}");
    // print("size.height:${size.height}");
    // print("size.width:${size.width}");
    // print("selectedItemOffset:$selectedItemOffset");
    // print("isInverted:$isInverted");



    double y=0;
    double x=0;


    y=position.top;

    if(isMySelf) {
      x = -48.0;
    }else{
      x= 60.0;
    }

    if(isInverted){
      y+=contentHeight+11;
    }else{
      y-=selectedItemOffset;
    }

    // print("x:$x");
    // print("y:$y");

    return Offset(x, y);
  }

  @override
  bool shouldRelayout(_PopupMenuRouteLayout oldDelegate) {
    return position != oldDelegate.position;
  }
}
