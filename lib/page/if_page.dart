import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/page/home/sub_page/recommend_page.dart';
import 'package:mirror/page/home/sub_page/share_page/share_page_sub_page/comment_bottom_sheet.dart';
import 'package:mirror/page/home/sub_page/share_page/share_page_sub_page/comment_ipunt_bar.dart';
import 'package:mirror/page/main_page.dart';
import 'package:mirror/page/search/search.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:union_tabs/union_tabs.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class IfPage extends StatefulWidget {
  IfPage({Key key}) : super(key: key);

  IfPageState createState() => IfPageState();
}

// 嵌套二层TabBar
class IfPageState extends State<IfPage> with TickerProviderStateMixin {
  TabController _controller;
  PanelController _pc = new PanelController();
  bool isInit = false;

  @override
  void initState() {
    // 最外层TabBar 默认定位到第二页
    _controller = TabController(length: 2, vsync: this, initialIndex: 1);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // 获取屏幕宽度，只能在home内才可调用。
    double screen_top = MediaQuery.of(context).padding.top;
    double screen_bottom = MediaQuery.of(context).padding.bottom;
    Size screen_size = MediaQuery.of(context).size;
    double inputHeight = MediaQuery.of(context).viewInsets.bottom;
    // 初始化获取屏幕数据
    if (isInit == false) {
      ScreenUtil.init(width: screen_size.width,height: screen_size.height,maxPhysicalSize: screen_size.width, bottomHeight: screen_bottom);
      isInit = true;
    };
    return Scaffold(
        // 此属性是重新计算布局空间大小
        // 内部元素要监听键盘高度必需要设置为false,
        resizeToAvoidBottomInset: false,
        // UnionOuterTabBarView ChangeNotifierProvider
        body: Container(
          child: Stack(
              children: [
                SlidingUpPanel(
                    panel: Container(
                      margin: EdgeInsets.only(bottom: ScreenUtil.instance.bottomBarHeight),
                      child: CommentBottomSheet(
                        pc: _pc,
                      ),
                    ),
                    maxHeight: ScreenUtil.instance.height*0.7,
                    backdropEnabled: true,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10.0),
                      topRight: Radius.circular(10.0),
                    ),
                    controller: _pc,
                    minHeight: 0,
                    body: ChangeNotifierProvider(
                        create: (_) => SelectedbottomNavigationBarNotifier(0),
                        builder: (context, _) {
                          return UnionOuterTabBarView(
                            physics: context.watch<SelectedbottomNavigationBarNotifier>().selectedIndex == 0
                                ? ClampingScrollPhysics()
                                : NeverScrollableScrollPhysics(),
                            controller: _controller,
                            children: _createTabContent(),
                          );
                        }
                    )
                ),
                // 键盘蒙层
                Positioned(
                    child: Offstage(
                        offstage: inputHeight == 0,
                        child: GestureDetector(
                            onTap: () => commentFocus.unfocus(), // 失去焦点,
                            // onDoubleTap: () => print("双击"),
                            // onLongPress: () => print("长按"),
                            // onTapCancel: () => print("取消"),
                            // onTapUp: (e) => print("松开"),
                            // onTapDown: (e) => print("按下"),
                            // onPanDown: (DragDownDetails e) {
                            // commentFocus.unfocus(); // 失去焦点
                            //   //打印手指按下的位置
                            //   print("手指按下：${e.globalPosition}");
                            // },
                            // //手指滑动
                            // onPanUpdate: (DragUpdateDetails e) {
                            //   print(e.delta.dx);
                            //   print(e.delta.dy);
                            // },
                            // onPanEnd: (DragEndDetails e) {
                            //   //打印滑动结束时在x、y轴上的速度
                            //   print(e.velocity);
                            // },
                            child: Container(
                              width: ScreenUtil.instance.screenWidthDp,
                              height: ScreenUtil.instance.screenHeightDp,
                              color: AppColor.black.withOpacity(0.24),
                            )))),
                // 唤起键盘
                Positioned(
                    bottom: inputHeight,
                    left: 0,
                    child: Offstage(
                      offstage: inputHeight == 0,
                      child: Container(
                        width: ScreenUtil.instance.screenWidthDp,
                        color: AppColor.white,
                        padding: EdgeInsets.only(top: 8, bottom: 8),
                        child: CommentInputBar(),
                      ),
                    ))
              ]
          )
        ),
    );
  }

  List<Widget> _createTabContent() {
    List<Widget> tabContent = List();
    tabContent.add(Search());
    tabContent.add(MainPage(
      pc: _pc,
    ));
    return tabContent;
  }

  @override
  void dispose() {
    _controller.dispose();
    // _childController.dispose();
    super.dispose();
  }
}
