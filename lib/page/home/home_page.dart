import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/course_model.dart';
import 'package:mirror/page/home/sub_page/attention_page.dart';
import 'package:mirror/page/home/sub_page/home_top_tab.dart';
import 'package:mirror/page/home/sub_page/recommend_page.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  // taBar和TabBarView必要的
  TabController controller;
  PanelController _pc = new PanelController();

  // 测试图片
  var coverUrls = [
    "https://img9.doubanio.com\/view\/photo\/s_ratio_poster\/public\/p2623955494.webp",
    "https://img9.doubanio.com\/view\/photo\/s_ratio_poster\/public\/p2615992304.webp",
    "https://img3.doubanio.com\/view\/photo\/s_ratio_poster\/public\/p2615642201.webp",
    "https://img2.doubanio.com\/view\/photo\/s_ratio_poster\/public\/p2599858573.webp",
    "https://img1.doubanio.com\/view\/photo\/s_ratio_poster\/public\/p2620104689.webp",
    "https://img3.doubanio.com\/view\/photo\/s_ratio_poster\/public\/p2620161520.webp",
    "https://img3.doubanio.com\/view\/photo\/s_ratio_poster\/public\/p2621884130.webp",
    "https://img9.doubanio.com\/view\/photo\/s_ratio_poster\/public\/p2622904695.webp",
    "https://img2.doubanio.com\/view\/photo\/s_ratio_poster\/public\/p2621751023.webp"
  ];
  List<CourseModel> courses = [];

  @override
  initState() {
    super.initState();
    controller = TabController(length: 2, vsync: this, initialIndex: 1);
    for (var i in coverUrls) {
      CourseModel a = new CourseModel(i, coverUrls.indexOf(i));
      courses.add(a);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 获取屏幕宽度，只能在home内才可调用。
    double screen_width = MediaQuery.of(context).size.width;
    double screen_top = MediaQuery.of(context).padding.top;
    double screen_bottom = ScreenUtil.instance.bottomBarHeight;
    double inputHeight = MediaQuery.of(context).viewInsets.bottom;

    print("首页");
    return Container(
      child: Stack(
        children: [
          SlidingUpPanel(
            panel: Center(
              child: CommentBottomSheet(
                pc: _pc,
              ),
            ),
            backdropEnabled: true,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10.0),
              topRight: Radius.circular(10.0),
            ),
            controller: _pc,
            minHeight: 0,
            body: Container(
              // 设置背景色
              decoration: BoxDecoration(color: Colors.white),
              // 层叠布局
              child: Stack(
                // 子布局定位
                children: [
                  Positioned(
                      top: screen_top,
                      height: 44,
                      width: screen_width,
                      child: Container(
                        child: HomeTopTab(controller: controller),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(bottom: BorderSide(width: 0.5, color: Color(0xffe5e5e5))),
                          // boxShadow: [
                          //   BoxShadow(
                          //       color: Colors.black12,
                          //       offset: Offset(0.0, 1.0), //阴影xy轴偏移量
                          //       blurRadius: 8.0, //阴影模糊程度
                          //       spreadRadius: 0.5 //阴影扩散程度
                          //   )
                          // ]
                        ),
                      )),
                  Container(
                    margin: EdgeInsets.only(top: 44 + screen_top),
                    child: TabBarView(
                      controller: this.controller,
                      // physics: new NeverScrollableScrollPhysics(),
                      children: [
                        // CustomScrollComState(urls: courses,),
                        AttentionPage(
                          coverUrls: courses,
                          pc: _pc,
                        ),
                        RecommendPage(
                          coverUrls: courses,
                          pc: _pc,
                        )
                        // RecommendPage()
                      ],
                    ),
                  ),
                ],
              ),
            ),
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
              bottom: inputHeight - 51 - screen_bottom,
              left: 0,
              child: Offstage(
                offstage: inputHeight == 0,
                child: Container(
                  width: ScreenUtil.instance.screenWidthDp,
                  color: AppColor.white,
                  padding: EdgeInsets.only(top: 8, bottom: 8),
                  child: commentInputBar(),
                ),
              ))
        ],
      ),
    );
    // return
  }
}
