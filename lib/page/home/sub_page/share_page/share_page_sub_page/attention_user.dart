// 推荐用户
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/text_util.dart';
import 'package:mirror/widget/custom_button.dart';

class AttentionUser extends StatefulWidget {
  AttentionUser({Key key}) : super(key: key);

  AttentionUserState createState() => AttentionUserState();
}

class AttentionUserState extends State<AttentionUser> {
  final List<String> list = [
    "0",
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
  ];

  @override
  Widget build(BuildContext context) {
    return Offstage(
      offstage: list.length == 0,
      child: Container(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(left: 16, right: 16),
              height: 25,
              width: ScreenUtil.instance.screenWidthDp,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "为你推荐",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppColor.textPrimary1),
                  ),
                  Spacer(),
                  Container(
                      width: getTextSize("查看全部", TextStyle(fontSize: 14),1).width + 20,
                      child: Row(children: [
                        Container(
                          margin: EdgeInsets.only(right: 4),
                          child: Text(
                            "查看全部",
                            style: TextStyle(fontSize: 14, color: AppColor.textPrimary3),
                          ),
                        ),
                        MyIconBtn(
                          width: 16,
                          height: 16,
                          iconSting: "images/resource/2.0x/return2x.png",
                          onPressed: () {},
                        )
                      ])),
                ],
              ),
            ),
            attentionList()
          ],
        ),
      ),
    );
  }

  // 横向listView
  attentionList() {
    return Container(
      margin: EdgeInsets.only(top: 18),
      height: 190,
      child: attentionUserAnimateList(
        itemCount: list.length,
        lists: list,
        onActionFinished: (index) {
          list.removeAt(index);
          if (list.length == 0) {
            setState(() {});
          }
          return list.length;
        },
      ),
    );
  }

  // 轮播样式
  slide() {
    Container(
      height: 190,
      margin: EdgeInsets.only(top: 18),
      child: Swiper(
        itemBuilder: (BuildContext context, int index) {
          return Container(
            margin: EdgeInsets.only(right: 10),
            color: Colors.red,
            // width: 151,
            height: 190,
          );
        },
        itemCount: 7,
        loop: false,
        viewportFraction: 0.4,
        scale: 0.9,
      ),
    );
  }
}

// 推荐用户内部自定义动画List
typedef OnActionFinished = int Function(int index); // 进行数据清除工作，并返回当前list的length
typedef AnimateFinishedCallBack = void Function(int index); // 动画结束通知列表进行刷新操作 --- 定义的item当中使用

class attentionUserAnimateList extends StatefulWidget {
  // final IndexedWidgetBuilder itemBuilder;
  final OnActionFinished onActionFinished;
  int itemCount;
  final Axis scrollDirection;
  final bool reverse;
  final ScrollController controller;
  final bool primary;
  final ScrollPhysics physics;
  final bool shrinkWrap;
  final EdgeInsetsGeometry padding;
  final List<String> lists;

  attentionUserAnimateList(
      {Key key,
        @required this.itemCount,
        // @required this.itemBuilder,
        @required this.onActionFinished,
        this.scrollDirection = Axis.horizontal,
        this.reverse = false,
        this.controller,
        this.primary,
        this.physics,
        this.shrinkWrap = false,
        this.padding,
        this.lists})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return attentionUserAnimateListState();
  }
}

class attentionUserAnimateListState<T> extends State<attentionUserAnimateList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: widget.itemCount,
        scrollDirection: widget.scrollDirection,
        reverse: widget.reverse,
        controller: widget.controller,
        primary: widget.primary,
        physics:
        (widget.physics != null ? widget.physics : BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics())),
        shrinkWrap: widget.shrinkWrap,
        padding: widget.padding,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.only(
              left: index > 0 ? 12 : 16,
              right: index == widget.lists.length - 1 ? 16 : 0,
            ),
            child: _ListItem(
              index,
              removeTargetItem,
              widget.lists[index],
            ),
          );
        });
  }

  // 刷新列表，替换数据
  void removeTargetItem(int index) {
    setState(() {
      widget.itemCount = widget.onActionFinished(index);
    });
  }
}

// 自定义动画Item
class _ListItem extends StatefulWidget {
  final String str;
  final int index;
  final AnimateFinishedCallBack onAnimateFinished;
  double dragStartPoint = 0.0;
  double draglength = 0.0;

  _ListItem(this.index, this.onAnimateFinished, this.str);

  @override
  State<StatefulWidget> createState() {
    return _ListItemState();
  }
}

class _ListItemState extends State<_ListItem> with TickerProviderStateMixin {
  bool _slideEnd = false;
  bool _sizeEnd = false;
  var _opacity = 1.0;
  Size _size;
  AnimationController _slideController;
  AnimationController _sizeController;

  Animation<Offset> _slideAnimation;
  Animation<double> _sizeAnimation;

  @override
  void initState() {
    super.initState();
    initSlideAnimation();
    initSizeAnimation();
    WidgetsBinding.instance.addPostFrameCallback(onAfterRender);
  }

  @override
  void didUpdateWidget(_ListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback(onAfterRender);
  }

  // 从上向下的动画
  void initSlideAnimation() {
    _slideController = AnimationController(vsync: this, duration: Duration(milliseconds: 250));
    _slideAnimation = Tween(begin: Offset(0.0, 0.0), end: Offset(0.0, 1.0))
        .animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
  }

  void initSizeAnimation() {
    _sizeController = AnimationController(vsync: this, duration: Duration(milliseconds: 250));
    _sizeAnimation =
        Tween(begin: 1.0, end: 0.0).animate(CurvedAnimation(parent: _sizeController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    super.dispose();
    _slideController.dispose();
    _sizeController.dispose();
  }

  void onAfterRender(Duration timeStamp) {
    _size = context.size;
  }

  bool isToggle = false;

  toggleutton() {
    isToggle = !isToggle;
    setState(() {});
  }

  Widget itemBuilder(BuildContext context) {
    return AnimatedOpacity(
        opacity: _opacity,
        onEnd: () {
          _slideController.forward().whenComplete(() {
            _opacity = 1.0;
            setState(() {
              _slideEnd = true;
              _sizeController.forward().whenComplete(() {
                _sizeEnd = true;
                // 通知list 进行数据刷新操作
                widget.onAnimateFinished(widget.index);
              });
            });
          });
        },
        duration: Duration(milliseconds: 250),
        child: Container(
          height: 190,
          width: 151,
          decoration: BoxDecoration(
            //背景
            color: Colors.white,
            //设置四周圆角 角度
            borderRadius: BorderRadius.all(Radius.circular(4.0)),
            //设置四周边框
            border: new Border.all(width: 0.5, color: AppColor.bgWhite),
          ),
          child: Stack(
            children: [
              Container(
                margin: EdgeInsets.only(top: 6, left: 127),
                child: MyIconBtn(
                  width: 18,
                  height: 18,
                  iconSting: "images/resource/2.0x/ic_recommend_Close_small@2x.png",
                  onPressed: () {
                    // _slideController.forward().whenComplete(() {
                    //   setState(() {
                    //     _slideEnd = true;
                    //     _sizeController.forward().whenComplete(() {
                    //       _sizeEnd = true;
                    //       // 通知list 进行数据刷新操作
                    //       widget.onAnimateFinished(widget.index);
                    //     });
                    //   });
                    // });
                    setState(() {
                      _opacity = 0;
                    });
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 18),
                width: 151,
                height: 172,
                // child: Expanded(
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      // backgroundImage: NetworkImage("https://pic2.zhimg.com/v2-639b49f2f6578eabddc458b84eb3c6a1.jpg"),
                      backgroundImage: AssetImage("images/test/yxlm1.jpeg"),
                      maxRadius: 23.5,
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 8),
                      child: Text(
                        "金卡卡西${widget.str}",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColor.textPrimary1),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 2, bottom: 12),
                      width: 100,
                      child: Text(
                        "夕柚和其他2位用户关注了",
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: AppColor.textSecondary),
                      ),
                    ),
                    Container(
                      width: 119,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isToggle ? AppColor.textHint : Colors.black,
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          toggleutton();
                        },
                        child: Container(
                          alignment: Alignment.center,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                child: Image.asset(
                                  isToggle
                                      ? "images/resource/2.0x/ic_recommend_Followed@2x.png"
                                      : "images/resource/2.0x/ic_recommend_follow@2x.png",
                                  fit: BoxFit.cover,
                                ),
                              ),
                              SizedBox(
                                width: 4,
                              ),
                              Container(
                                child: Text(
                                  isToggle ? "已关注" : "关注",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColor.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                // ),
              )
            ],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    if (_slideEnd && _sizeEnd) {
      _slideController.value = 0.0;
      _sizeController.value = 0.0;
      _slideEnd = false;
      _sizeEnd = false;
    }
    return (_slideEnd
        ? SizeTransition(
      axis: Axis.horizontal,
      sizeFactor: _sizeAnimation,
      child: Container(
        color: Colors.transparent,
        height: 190,
        width: 151,
      ),
    )
        : SlideTransition(
      position: _slideAnimation,
      child: itemBuilder(context),
    ));
  }
}