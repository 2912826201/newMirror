import 'dart:html';
import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/config/shared_preferences.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/page/main_page.dart';
import 'package:mirror/page/search/sub_page/should_build.dart';
import 'package:mirror/util/check_phone_system_util.dart';
import 'package:mirror/util/event_bus.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/dialog.dart';
import 'package:mirror/widget/protocol_web_view.dart';
import 'package:move_to_background/move_to_background.dart';
import 'package:notification_permissions/notification_permissions.dart';
import 'package:rich_text_widget/rich_text_widget.dart';

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
  String TestText = "我们非常重视您的个人信息和隐私保护，为了更好的保障您的个人权益，在您使用前，请务必阅读我们的《使用条款》和《隐私协议》。如果您同意此协议，请点击“同意”。";

  @override
  void initState() {
    // 最外层TabBar 默认定位到第二页
    _controller = TabController(length: 2, vsync: this, initialIndex: 1);
    Application.ifPageController = _controller;
    VisibilityDetectorController.instance.updateInterval = Duration(milliseconds: 200);
    super.initState();
    //初始化
    WidgetsBinding.instance.addObserver(this);
    _getInformationGuide();
    //Fixme ifpage会重构两次 ，会走两次initState
    if (AppPrefs.isAgreeUserAgreement()) {
      _getNotificationStatus();
    }
  }

  _getNotificationStatus() async {
    // Android申请通知权限
    if (CheckPhoneSystemUtil.init().isAndroid() && AppPrefs.isAgreeUserAgreement()) {
      // 检查是否已有通知的权限
      PermissionStatus permissionStatus = await NotificationPermissions.getNotificationPermissionStatus();
      bool status = permissionStatus != null && permissionStatus == PermissionStatus.granted;
      //判断如果还没拥有通知权限就申请获取权限
      //note 调试时会出现ifPage重构两次，不影响正式体验
      if (!status) {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          //请求通知权限
          showAppDialog(
            context,
            title: "请求通知权限",
            info: "第一时间获取评论,私信,@我等信息通知",
            barrierDismissible: false,
            confirm: AppDialogButton("去打开", () {
              AppSettings.openNotificationSettings();
              return true;
            }),
            cancel: AppDialogButton("取消", () {
              return true;
            }),
          );
        });
      }
    }
  }

  // 信息引导弹窗
  _getInformationGuide() {
    print("信息引导弹窗");
    print("AppPrefs.isAgreeUserAgreement:::${AppPrefs.isAgreeUserAgreement()}");
    print("AppPrefs.IsOpenPopup:::${AppPrefs.IsOpenPopup()}");
    if (!AppPrefs.isAgreeUserAgreement()) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        showAppDialog(context,
            confirm: AppDialogButton("同意", () {
              // AppPrefs.isAgreeUserAgreement
              AppPrefs.setIsAgreeUserAgreement(true);
              _getNotificationStatus();
              reload();
              return true;
            }),
            cancel: AppDialogButton("不同意", () {
              // pop();
              if (CheckPhoneSystemUtil.init().isIos()) {
                // MoveToBackground.moveTaskToBack();
                exit(0);

                ///以编程方式退出，彻底但体验不好
              } else if (CheckPhoneSystemUtil.init().isAndroid()) {
                // MoveToBackground.moveTaskToBack();
                exit(0);
                // SystemNavigator.pop(); //官方推荐方法，但不彻底
              }
              return true;
            }),
            title: "欢迎使用春柠",
            customizeWidget: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.17,
              child: SingleChildScrollView(
                  child: RichTextWidget(
                // default Text
                Text(
                  TestText,
                  style: TextStyle(color: Colors.black),
                ),
                // rich text list
                richTexts: [
                  BaseRichText(
                    "《使用条款》",
                    style: TextStyle(color: AppColor.mainBlue),
                    onTap: () => {
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return ProtocolWebView(
                          type: 0,
                        );
                      }))
                    },
                  ),
                  BaseRichText(
                    "《隐私协议》",
                    style: TextStyle(color: AppColor.mainBlue),
                    onTap: () => {
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return ProtocolWebView(
                          type: 1,
                        );
                      }))
                    },
                  ),
                ],
              )),
            ),
            barrierDismissible: false);
      });
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

  ///监听用户回到app
  @override
  Future didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    Application.isBackGround = true;
    if (state == AppLifecycleState.paused) {
      FocusScope.of(context).requestFocus(FocusNode());
    } else if (state == AppLifecycleState.resumed) {
      Application.isBackGround = false;
      Application.jpush.clearAllNotifications();
      EventBus.getDefault().post(registerName: SHOW_IMAGE_DIALOG);
    }
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
        child: !AppPrefs.isAgreeUserAgreement() ? Scaffold(body: Container()) : MainPage()
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
}
