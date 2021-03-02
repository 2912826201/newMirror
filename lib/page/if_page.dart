import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/page/main_page.dart';
import 'package:mirror/page/search/sub_page/should_build.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/no_blue_effect_behavior.dart';
import 'package:union_tabs/union_tabs.dart';
import 'package:provider/provider.dart';

import 'media_picker/media_picker_page.dart';

class IfPage extends  StatefulWidget {
  IfPage({Key key}) : super(key: key);

  IfPageState createState() => IfPageState();
}

// 嵌套二层TabBar
class IfPageState extends XCState with TickerProviderStateMixin,WidgetsBindingObserver  {
  TabController _controller;
  bool isInit = false;

  @override
  void initState() {
    // 最外层TabBar 默认定位到第二页
    _controller = TabController(length: 2, vsync: this, initialIndex: 1);
    Application.ifPageController = _controller;
    super.initState();
    // _controller.addListener(() {
    //   if(context.watch<FeedMapNotifier>().postFeedModel != null) {
    //     _controller.
    //   }
    // });
    //初始化
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Widget shouldBuild(BuildContext context) {
    print("if_page_____________________________________________build");
    // 获取屏幕宽度，只能在home内才可调用。
    double screen_bottom = MediaQuery.of(context).padding.bottom;
    Size screen_size = MediaQuery.of(context).size;
    // if (context.watch<FeedMapNotifier>().postFeedModel != null) {
    //   _controller.index = 1;
    // }
    // 初始化获取屏幕数据
    if (isInit == false) {
      ScreenUtil.init(
          width: screen_size.width,
          height: screen_size.height,
          maxPhysicalSize: screen_size.width,
          bottomHeight: screen_bottom);
      isInit = true;
    }
    ;
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        // child: Scaffold(
        //     resizeToAvoidBottomInset: false,

        child: Container(
          child: Stack(children: [
            ChangeNotifierProvider(
                create: (_) => SelectedbottomNavigationBarNotifier(0),
                builder: (context, _) {
                  return ScrollConfiguration(
                    behavior: NoBlueEffectBehavior(),
                    child: UnionOuterTabBarView(
                      physics: context.watch<SelectedbottomNavigationBarNotifier>().selectedIndex == 0
                      //ClampingScrollPhysics 禁止回弹效果 NeverScrollableScrollPhysics 禁止滚动效果
                          ? ClampingScrollPhysics()
                          : NeverScrollableScrollPhysics(),
                      controller: _controller,
                      children: _createTabContent(),
                    ),
                  );
                })
          ]),
        )
      // )
    );
  }

  List<Widget> _createTabContent() {
    List<Widget> tabContent = List();
    //四个常规业务tabBar
    tabContent.add(MediaPickerPage(
      9,
      typeImageAndVideo,
      true,
      startPageGallery,
      false,
      publishMode: 2,
    ));
    tabContent.add(MainPage());
    return tabContent;
  }

  @override
  void dispose() {
    _controller.dispose();
    print("IFPage销毁了页面");
    //销毁
    WidgetsBinding.instance.removeObserver(this);
    // _childController.dispose();
    super.dispose();
  }

  // @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //fixme 弹起键盘上下文报错
      if (this.context != null) {
        if (MediaQuery.of(this.context).viewInsets.bottom == 0) {
          //关闭键盘
        } else {
          //显示键盘
          if (Application.keyboardHeight <= MediaQuery.of(this.context).viewInsets.bottom) {
            Application.keyboardHeight = MediaQuery.of(this.context).viewInsets.bottom;
          }
        }
      }
    });
  }
}

