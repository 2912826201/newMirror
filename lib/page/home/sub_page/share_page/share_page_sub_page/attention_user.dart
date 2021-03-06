// 推荐用户
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/page/test/verification_codeInput_demo_page.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/text_util.dart';
import 'package:mirror/widget/custom_button.dart';
import 'package:mirror/widget/icon.dart';
import 'package:mirror/widget/smart_refressher_head_footer.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class AttentionUser extends StatefulWidget {
  AttentionUser({Key key}) : super(key: key);

  AttentionUserState createState() => AttentionUserState();
}

class AttentionUserState extends State<AttentionUser> {
  List<String> list = [
    "5",
    "4",
    "3",
    "2",
    "1",
    "0",
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      width: ScreenUtil.instance.width,
      height: list.length == 0 ? 0 : 251,
      duration: const Duration(milliseconds: 250),
      // color: AppColor.color707070,
      curve: Curves.linear,
      //NOTE 此用list布局不用Column是因为使用AnimatedContainer动态改变高度时Column的高度不受限制会导致界面UI底部溢出
      child: MediaQuery.removePadding(
        removeTop: true,
        context: context,
        child: ListView.builder(
          itemCount: 2,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            if (index == 0) {
              return Container(
                margin: const EdgeInsets.only(left: 16, right: 16, top: 18),
                height: 25,
                width: ScreenUtil.instance.width,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "为你推荐",
                      style: AppStyle.whiteMedium18,
                    ),
                    const Spacer(),
                    Container(
                        width: getTextSize("查看全部", TextStyle(fontSize: 14), 1).width + 20,
                        child: GestureDetector(
                          child: Row(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(right: 4),
                                child: const Text(
                                  "查看全部",
                                  style: AppStyle.text1Regular14,
                                ),
                              ),
                              AppIcon.getAppIcon(AppIcon.arrow_right_16, 16, color: AppColor.textWhite40),
                            ],
                          ),
                        )),
                  ],
                ),
              );
            } else {
              return attentionList();
            }
          },
        ),
      ),
    );
  }

  // 横向listView
  attentionList() {
    return Container(
      margin: const EdgeInsets.only(top: 18),
      height: 190,
      child: attentionUserAnimateList(
        itemCount: list.length,
        lists: list,
        shrinkWrap: true,
        onActionFinished: (index) {
          list.removeAt(index);
          if (list.length == 2) {
            List<String> listString = [];
            listString.add(list.last);
            listString.add(list.first);
            list = listString;
            setState(() {});
            print("翻转数组了吗：：：：${listString.toString()}");
          }
          if (list.length == 0) {
            setState(() {});
          }
          return list.length;
        },
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
  RefreshController _refreshController = RefreshController();
  ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Future.delayed(Duration.zero, () {
        _controller.jumpTo(_controller.position.maxScrollExtent + 16);
        print("列表的最大偏移：：：：${_controller.position.maxScrollExtent}");
      });
    });
  }

  // 列表间距
  ListSpacing(bool isLeft, int index) {
    double spacing = 0.0;
    // 左边距
    if (isLeft) {
      // 之前是翻转列表小于三个时翻转回来间距调整
      if (widget.itemCount < 3) {
        if (index > 0) {
          spacing = 12;
        } else {
          spacing = 16;
        }
      } else {
        if (index == widget.lists.length - 1) {
          spacing = 16;
        } else {
          spacing = 0;
        }
      }
      // 右边距
    } else {
      if (widget.itemCount < 3) {
        if (index == widget.lists.length - 1) {
          spacing = 16;
        } else {
          spacing = 0;
        }
      } else {
        if (index > 0) {
          spacing = 12;
        } else {
          spacing = 16;
        }
      }
    }
    return spacing;
  }

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
        enablePullUp: false,
        enablePullDown: widget.itemCount < 3 ? false : true,
        controller: _refreshController,
        header: SmartRefresherHeadFooter.init().getAttentionUserFooter(),
        onRefresh: () {
          _refreshController.refreshCompleted();
          Navigator.of(context).push(new MaterialPageRoute(builder: (context) {
            return VerificationCodeInputDemoPage2();
          }));
        },
        child: ListView.builder(
            itemCount: widget.itemCount,
            scrollDirection: widget.scrollDirection,
            reverse: widget.itemCount < 3 ? false : true,
            controller: _controller,
            primary: widget.primary,
            physics: (widget.physics != null
                ? widget.physics
                : BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics())),
            shrinkWrap: widget.shrinkWrap,
            padding: widget.padding,
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.only(
                  left: ListSpacing(true, index),
                  right: ListSpacing(false, index),
                ),
                child: _ListItem(
                  index,
                  removeTargetItem,
                  widget.lists[index],
                ),
              );
            }));
  }

  // 刷新列表，替换数据
  void removeTargetItem(int index) {
    widget.itemCount = widget.onActionFinished(index);
    print("widget.itemCount::${widget.itemCount}");
    print("widget.lists::${widget.lists.length}");
    setState(() {});
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
  AnimationController _opacityController;

  Animation<Offset> _slideAnimation;
  Animation<double> _sizeAnimation;
  Animation<double> _opacityAnimation;
  static final _opacityTween = new Tween<double>(begin: 0.1, end: 1.0);
  bool isToggle = false;
  Color buttonCollor;

  @override
  void initState() {
    super.initState();
    if (isToggle) {
      buttonCollor = AppColor.mainYellow.withOpacity(0.6);
    } else {
      buttonCollor = AppColor.mainYellow;
    }
    initSlideAnimation();
    initSizeAnimation();
    WidgetsBinding.instance.addPostFrameCallback(onAfterRender);
  }

  @override
  void didUpdateWidget(_ListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback(onAfterRender);
  }

  // 从右到左的平移动画
  void initSlideAnimation() {
    _slideController = AnimationController(vsync: this, duration: Duration(milliseconds: 250));
    _slideAnimation = Tween(begin: Offset(0.0, 0.0), end: Offset(-1.0, 0.0))
        .animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
  }

  //
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
    // _size = context.size;
  }

  toggleutton() {
    isToggle = !isToggle;
    followButtonColor();
  }

  followButtonColor({bool isTapDown = false, bool isTapCancel = false, bool isTapUp = false}) {
    if (!isTapCancel || !isTapUp) {
      if (isTapDown) {
        buttonCollor = AppColor.mainYellow.withOpacity(0.4);
        setState(() {});
        return;
      }
    }
    if (isToggle) {
      buttonCollor = AppColor.mainYellow.withOpacity(0.6);
    } else if (!isToggle) {
      buttonCollor = AppColor.mainYellow;
    }
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
            color: AppColor.layoutBgGrey,
            //设置四周圆角 角度
            borderRadius: const BorderRadius.all(Radius.circular(4.0)),
            //设置四周边框
            border: new Border.all(width: 0.5, color: AppColor.layoutBgGrey),
          ),
          child: Stack(
            children: [
              Positioned(
                right: 0,
                child: AppIconButton(
                  svgName: AppIcon.close_18,
                  iconSize: 18,
                  buttonWidth: 30,
                  buttonHeight: 30,
                  iconColor: AppColor.textWhite60,
                  onTap: () {
                    setState(() {
                      _opacity = 0;
                    });
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 18),
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
                      margin: const EdgeInsets.only(top: 8),
                      child: Text(
                        "金卡卡西${widget.str}",
                        style: AppStyle.whiteMedium15,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 2, bottom: 12),
                      width: 100,
                      child: Text(
                        "夕柚和其他2位用户关注了",
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        style: AppStyle.text1Regular13,
                      ),
                    ),
                    Container(
                      width: 119,
                      height: 28,
                      decoration: BoxDecoration(
                        color: buttonCollor,
                        borderRadius: const BorderRadius.all(Radius.circular(16)),
                      ),
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          toggleutton();
                        },
                        onTapDown: (TapDownDetails details) {
                          followButtonColor(isTapDown: true);
                        },
                        onTapUp: (TapUpDetails details) {
                          followButtonColor(isTapUp: true);
                        },
                        onTapCancel: () {
                          followButtonColor(isTapCancel: true);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              isToggle
                                  ? AppIcon.getAppIcon(AppIcon.check_follow, 16, color: AppColor.mainBlack)
                                  : AppIcon.getAppIcon(AppIcon.add_follow, 16, color: AppColor.mainBlack),
                              const SizedBox(
                                width: 4,
                              ),
                              Container(
                                child: Text(
                                  isToggle ? "已关注" : "关注",
                                  style: AppStyle.textRegular14,
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
