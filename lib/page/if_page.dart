import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/page/home/sub_page/share_page/share_page_sub_page/comment_bottom_sheet.dart';
import 'package:mirror/page/main_page.dart';
import 'package:mirror/page/message/message_page.dart';
import 'package:mirror/page/search/search.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:union_tabs/union_tabs.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'media_picker/media_picker_page.dart';

class IfPage extends StatefulWidget {
  IfPage({Key key}) : super(key: key);

  IfPageState createState() => IfPageState();
}

// 嵌套二层TabBar
class IfPageState extends State<IfPage> with TickerProviderStateMixin {
  TabController _controller;
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
      ScreenUtil.init(
          width: screen_size.width,
          height: screen_size.height,
          maxPhysicalSize: screen_size.width,
          bottomHeight: screen_bottom);
      isInit = true;
    }
    ;
    return Scaffold(
        // 此属性是重新计算布局空间大小
        // 内部元素要监听键盘高度必需要设置为false,
        resizeToAvoidBottomInset: false,
        body: Container(
            child: Stack(children: [
          SlidingUpPanel(
              panel: Container(
                margin: EdgeInsets.only(bottom: ScreenUtil.instance.bottomBarHeight),
                child: SingletonForWholePages.singleton().panelWidget(context),
              ),
              onPanelClosed: () {
                context.read<FeedMapNotifier>().clearTotalCount();
                // 关闭视图后清空动态Id
                context.read<FeedMapNotifier>().changeFeeId(null);
              },
              maxHeight: ScreenUtil.instance.height * 0.75,
              backdropEnabled: true,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10.0),
                topRight: Radius.circular(10.0),
              ),
              controller: SingletonForWholePages.singleton().panelController(),
              minHeight: 0,
              body: ChangeNotifierProvider(
                  create: (_) => SelectedbottomNavigationBarNotifier(0),
                  builder: (context, _) {
                    return UnionOuterTabBarView(
                      physics: context.watch<SelectedbottomNavigationBarNotifier>().selectedIndex == 0
                          ? BouncingScrollPhysics()
                          : NeverScrollableScrollPhysics(),
                      controller: _controller,
                      children: _createTabContent(),
                    );
                  })),
        ])));
  }

  List<Widget> _createTabContent() {
    List<Widget> tabContent = List();
    //四个常规业务tabBar
    tabContent.add(MediaPickerPage(9,typeImageAndVideo,true,startPagePhoto,false,true));
    tabContent.add(MainPage(
      pc: SingletonForWholePages.singleton().panelController(),
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

class SingletonForWholePages {
  //ifPage的key
  GlobalKey IfPagekey;
  PanelController ifPagePc = PanelController();
  PanelController messagePagePc = PanelController();

  //MessagePage的key
  GlobalKey messagePageKey;

  //记录tabbar的索引
  int index = 0;
  static SingletonForWholePages _me;

  //单例方法
  static SingletonForWholePages singleton() {
    if (_me == null) {
      _me = SingletonForWholePages();
    }
    return _me;
  }

  Widget panelWidget(BuildContext context) {
    print("panelWidget  $index");
    switch (index) {
      case 0:
        return context.watch<FeedMapNotifier>().feedId != null
            ? CommentBottomSheet(
                pc: SingletonForWholePages.singleton().panelController(),
                feedId: context.select((FeedMapNotifier value) => value.feedId),
              )
            : Container();
        break;
      case 1:
        break;
      case 2:
        return Container(child: CreateGroupChatWidget());
        break;
      case 3:
        break;
    }
  }

  PanelController panelController() {
    return ifPagePc;
  }
}
