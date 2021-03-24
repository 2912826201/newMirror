import 'dart:async';

///2021-3-5---shipk
/// 模拟android的EventBus
///
/// 列子
///
/// 广播类型参数可以不写-不写是默认广播
/// 需要参数返回时:请使用有参数的注册方法
/// 不需要参数返回时：请使用无参数注册方法
/// 在发送广播时请注意自己注册的方法是否有参数
///
/// 发送广播
/// EventBus.getDefault().post(回调的参数-看回调的方法是否有参数,registerName: "广播类型");
///
/// 注册广播
/// @override
/// void initState() {
///   super.initState();
///   有一个返回参数 任意类型
///   EventBus.getDefault().registerSingleParameter(Function(T event),"界面名称-保证独一无二",registerName: "广播类型");
///   没有返回参数
///   EventBus.getDefault().registerNoParameter(Function(),"界面名称-保证独一无二",registerName: "广播类型");
/// }
///
/// 取消广播
/// @override
/// void dispose() {
///   super.dispose();
///   EventBus.getDefault().unRegister(pageName:"界面名称-保证独一无二",registerName: "广播类型");
/// }
///
///
///

class EventBus {
  static EventBus _eventBus;
  final Map<String, Map<String, StreamController>> _registerMap = new Map<String, Map<String, StreamController>>();

  //默认的广播类型
  final String defName = "default";

  EventBus._();

  static EventBus getDefault() {
    if (_eventBus == null) {
      _eventBus = new EventBus._();
    }
    return _eventBus;
  }

  //注册广播的方法-回调的方法-需要广播的界面-广播的类型
  //单个参数
  void registerSingleParameter<T>(Function(T event) listener,String pageName, {String registerName}) {
    if (null == registerName) {
      registerName = defName;
    }
    if (_registerMap[registerName] == null) {
      Map<String, StreamController> map = Map();
      map[pageName] = StreamController.broadcast();
      _registerMap[registerName] = map;
    } else if (_registerMap[registerName][pageName] == null) {
      _registerMap[registerName][pageName] = StreamController.broadcast();
    }
    _registerMap[registerName][pageName].stream.listen((msg) {
      if(null == msg){
        print("EventBus:post广播需要一个参数!!!--目前没有参数,不进行广播");
      }else{
        listener(msg);
      }
    });
  }

  //注册广播的方法-回调的方法-需要广播的界面-广播的类型
  //无参数
  void registerNoParameter(Function() listener,String pageName, {String registerName}) {
    if (null == registerName) {
      registerName = defName;
    }
    if (_registerMap[registerName] == null) {
      Map<String, StreamController> map = Map();
      map[pageName] = StreamController.broadcast();
      _registerMap[registerName] = map;
    } else if (_registerMap[registerName][pageName] == null) {
      _registerMap[registerName][pageName] = StreamController.broadcast();
    }
    _registerMap[registerName][pageName].stream.listen((msg) {
      if(null == msg){
        listener();
      }else{
        print("EventBus:post广播不需要参数!!!--请不要传参进入");
        listener();
      }
    });
  }

  //移除广播的方法-广播的类型-需要广播的界面
  void unRegister({String registerName, String pageName}) {
    if (null == registerName) {
      registerName = defName;
    }
    if (null == pageName) {
      if (_registerMap[registerName] != null) {
        _registerMap[registerName].clear();
        _registerMap.remove(registerName);
      }
    } else {
      if (_registerMap[registerName][pageName] != null) {
        _registerMap[registerName][pageName].close();
        _registerMap[registerName].remove(pageName);
      }
    }
  }

  //发送广播-msg消息-广播的类型
  void post<T>({T msg, String registerName}) {
    if (null == registerName) {
      registerName = defName;
    }
    if (_registerMap.containsKey(registerName)) {
      _registerMap[registerName].forEach((key, value) {
        if (_registerMap[registerName][key] != null) {
          _registerMap[registerName][key].add(msg);
        }
      });
    }
  }
}

///页面名称
const String EVENTBUS_MAIN_PAGE = "main_page";
//直播界面-播放界面
const String EVENTBUS_LIVEROOM_TESTPAGE = "LiveRoomTestPage";
//直播界面-功能界面
const String EVENTBUS_ROOM_OPERATION_PAGE = "LiveRoomTestOperationPage";
//直播在线人数dialog面板
const String EVENTBUS_BOTTOM_USER_PANEL_DIALOG = "BottomUserPanelDialog";
//个人主页
const String EVENTBUS_PROFILE_PAGE = "profilePage";
//互动通知页
const String EVENTBUS_INTERACTIVE_NOTICE_PAGE = "interactiveNoticePage";

///广播类型
//发布动态
const String EVENTBUS_POSTFEED_CALLBACK = "mainpage_postFeedCallBack";
//直播界面的退出
const String EVENTBUS_LIVEROOM_EXIT = "liveRoomTestPage_exit";
//直播界面接收弹幕功能
const String EVENTBUS_ROOM_RECEIVE_BARRAGE = "LiveRoomTestOperationPage_receive_barrage";
//直播在线人数dailog刷新界面
const String EVENTBUS_BOTTOM_USER_PANEL_DIALOG_RESET = "BottomUserPanelDialogReset";
//个人主页删除动态
const String EVENTBUS_PROFILE_DELETE_FEED = "profileUserDetailDeleteFeed";
//互动通知删除评论动态
const String EVENTBUS_INTERACTIVE_NOTICE_DELETE_COMMENT = "interactiveNoticeDelete";
