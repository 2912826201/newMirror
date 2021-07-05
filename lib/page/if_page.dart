import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/page/main_page.dart';
import 'package:mirror/page/search/sub_page/should_build.dart';
import 'package:mirror/util/event_bus.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/dialog.dart';
import 'package:notification_permissions/notification_permissions.dart';

import 'media_picker/media_picker_page.dart';
import 'package:visibility_detector/src/visibility_detector_controller.dart';

class IfPage extends StatefulWidget {
  IfPage({Key key}) : super(key: key);

  IfPageState createState() => IfPageState();
}

// 嵌套二层TabBar
class IfPageState extends XCState with TickerProviderStateMixin, WidgetsBindingObserver {
  TabController _controller;
  bool isInit = false;

  @override
  void initState() async {
    // 最外层TabBar 默认定位到第二页
    _controller = TabController(length: 2, vsync: this, initialIndex: 1);
    Application.ifPageController = _controller;
    VisibilityDetectorController.instance.updateInterval = Duration(milliseconds: 200);
    super.initState();
    //初始化
    WidgetsBinding.instance.addObserver(this);

    // Android申请通知权限
    if (Application.platform == 0) {
      // 检查是否已有通知的权限
      PermissionStatus permissionStatus = await NotificationPermissions.getNotificationPermissionStatus();
      bool status = permissionStatus != null && permissionStatus == PermissionStatus.granted;
      //判断如果还没拥有通知权限就申请获取权限
      if (!status) {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          //请求通知权限
          showAppDialog(
            context,
            title: "请求通知权限",
            info: "接收消息通知及活动通知",
            barrierDismissible: false,
            confirm: AppDialogButton("去设置", () {
              NotificationPermissions.requestNotificationPermissions();
              return true;
            }),
            cancel: AppDialogButton("下次一定", () {
              return true;
            }),
          );
        });
      }
    }
  }

  // //最初的滑动偏移
  // Offset _initialSwipeOffset;
  //
  // //最终的滑动偏移
  // Offset _finalSwipeOffset;
  //
  // //横向拖动的开始回调
  // void _onHorizontalDragStart(DragStartDetails details) {
  //   _initialSwipeOffset = details.globalPosition;
  //   print("拖动的开始回调：：：${_initialSwipeOffset}");
  // }
  //
  // //横向拖动中的回调
  // void _onHorizontalDragUpdate(DragUpdateDetails details) {
  //   _finalSwipeOffset = details.globalPosition;
  //   print("拖动中：：：${_finalSwipeOffset}");
  //   if (_initialSwipeOffset != null) {
  //     final offsetDifference = _initialSwipeOffset.dx - _finalSwipeOffset.dx;
  //     final direction = offsetDifference > 0;
  //     context.read<FeedMapNotifier>().storageIsSwipeLeft(direction);
  //   }
  // }
  //
  // void _onHorizontalDragEnd(DragEndDetails details) {
  //   if (_initialSwipeOffset != null) {
  //     final offsetDifference = _initialSwipeOffset.dx - _finalSwipeOffset.dx;
  //     final direction = offsetDifference > 0;
  //     context.read<FeedMapNotifier>().storageIsSwipeLeft(direction);
  //   }
  // }
  @override
  Future didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    Application.isBackGround = true;
    if (state == AppLifecycleState.paused) {
      FocusScope.of(context).requestFocus(FocusNode());
    } else if (state == AppLifecycleState.resumed) {
      Application.isBackGround = false;
      EventBus.getDefault().post(registerName: SHOW_IMAGE_DIALOG);
    }
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

    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        // child: Scaffold(
        //     resizeToAvoidBottomInset: false,
        child: MainPage()
        // NotificationListener<ScrollNotification>(
        //     onNotification: (ScrollNotification notification) {
        //       ScrollMetrics metrics = notification.metrics;
        // 注册通知回调
        // if (notification is ScrollStartNotification) {
        //   // 滚动开始
        //   // print('滚动开始');
        // print(notification.dragDetails.globalPosition);
        // print("viewportDimension::${metrics.viewportDimension}");
        // print("axisDirection::${metrics.axisDirection}");
        // if (metrics.axis == Axis.horizontal && notification.dragDetails != null) {
        //   _initialSwipeOffset = notification.dragDetails.globalPosition;
        // }
        // print("_initialSwipeOffset::${_initialSwipeOffset}");
        // } else if (notification is ScrollUpdateNotification) {
        //   print('滚动位置更新');
        //   // 滚动位置更新
        //   if (metrics.axis == Axis.horizontal && notification.dragDetails != null) {
        //     // 左滑
        //     print(notification.dragDetails.globalPosition.dx);
        //     if (_initialSwipeOffset.dx > notification.dragDetails.globalPosition.dx) {
        //       context.read<FeedMapNotifier>().storageIsSwipeLeft(false);
        //     } else {
        //       // 右滑
        //       context.read<FeedMapNotifier>().storageIsSwipeLeft(true);
        //     }
        //   }
        //   } else if (notification is ScrollEndNotification) {
        //     // 滚动结束
        //     print('滚动结束');
        //     print(ScreenUtil.instance.width);
        //   }
        // },
        // GestureDetector(
        //     onHorizontalDragStart:  _onHorizontalDragStart ,/*横向拖动的开始状态*/
        //     onHorizontalDragUpdate: _onHorizontalDragUpdate,/*横向拖动的状态*/
        // onHorizontalDragEnd:  _onHorizontalDragEnd,/*横向拖动的结束状态*/
        // Container(
        //  child:  Stack(
        //    children: [
        // ChangeNotifierProvider(
        //   create: (_) => SelectedbottomNavigationBarNotifier(0),
        //   builder: (context, _) {
        // 暂时屏蔽负一屏
        // MainPage()
        // return ScrollConfiguration(
        //   behavior: NoBlueEffectBehavior(),
        //   child: UnionOuterTabBarView(
        //     physics: context.watch<SelectedbottomNavigationBarNotifier>().selectedIndex == 0
        //         //ClampingScrollPhysics 禁止回弹效果 NeverScrollableScrollPhysics 禁止滚动效果
        //         ? ClampingScrollPhysics()
        //         : NeverScrollableScrollPhysics(),
        //     controller: _controller,
        //     children: _createTabContent(),
        //   ),
        // );
        // },
        // ),
        // ],
        // ),
        // ),
        // )
        );
  }

  List<Widget> _createTabContent() {
    List<Widget> tabContent = List();
    tabContent.add(MediaPickerPage(
      9,
      typeImageAndVideo,
      true,
      startPageGallery,
      false,
      publishMode: 2,
    ));
    //四个常规业务tabBar
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
          if (Application.keyboardHeightIfPage <= MediaQuery.of(this.context).viewInsets.bottom) {
            Application.keyboardHeightIfPage = MediaQuery.of(this.context).viewInsets.bottom;
          }
        }
      }
    });
  }
}
