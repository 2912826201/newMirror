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
  void registerSingleParameter<T>(Function(T event) listener, String pageName, {String registerName}) {
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
      if (null == msg) {
        print("EventBus:post广播需要一个参数!!!--目前没有参数,不进行广播:$pageName,$registerName");
      } else {
        listener(msg);
      }
    });
  }

  //注册广播的方法-回调的方法-需要广播的界面-广播的类型
  //无参数
  void registerNoParameter(Function() listener, String pageName, {String registerName}) {
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
      if (null == msg) {
        listener();
      } else {
        print("EventBus:post广播不需要参数!!!--请不要传参进入:$pageName,$registerName");
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
      if (_registerMap[registerName] != null && _registerMap[registerName][pageName] != null) {
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
// 发布动态页
const String EVENTBUS_POST_FEED_HEADER = "postFeedHeader";
// homePage页
const String EVENTBUS_HOME_PAGE = "homePage";
// 发布进度视图页
const String EVENTBUS_POST_PROGRESS_VIEW = "releaseProgressView";
// 底部bar
const String EVENTBUS_IF_TAB_BAR = "_IFTabBarState";
// 关注页
const String EVENTBUS_ATTENTION_PAGE = "AttentionPage";
// 推荐页
const String EVENTBUS_RECOMMEND_PAGE = "recommendpage";
//聊天界面
const String EVENTBUS_CHAT_PAGE = "eventbus_chat_page";
// 视频页
const String EVENTBUS_VIDEOWIGET_PAGE = "videoWigetPage";
// 直播页
const String EVENTBUS_LIVE_COURSE_PAGE = "live_course_page";
// 直播列表页
const String EVENTBUS_LIVE_COURSE_LIST_PAGE = "live_course_list_page";
// 训练界面
const String EVENTBUS_TRAINING_PAGE = "training_page";
// 机器遥控器页
const String EVENTBUS_REMOTE_CONTROLLER_PAGE = "remote_controller_page";
// 相册页
const String EVENTBUS_GALLERY_PAGE = "gallery_page";
// 视频课结果页
const String VIDEO_COURSE_RESULT_PAGE = "video_course_result_page";

///广播类型
//发布动态
const String EVENTBUS_POSTFEED_CALLBACK = "mainpage_postFeedCallBack";
//直播界面的退出
const String EVENTBUS_LIVEROOM_EXIT = "liveRoomTestPage_exit";
//直播界面接收弹幕功能
const String EVENTBUS_ROOM_RECEIVE_BARRAGE = "LiveRoomTestOperationPage_receive_barrage";
//直播界面接收系统通知
const String EVENTBUS_ROOM_RECEIVE_NOTICE = "LiveRoomTestOperationPage_receive_notice";
//直播界面弹出消息要清除焦点
const String EVENTBUS_ON_CLICK_BODY = "LiveRoomTestOperationPage_on_click_body";
//直播在线人数dailog刷新界面
const String EVENTBUS_BOTTOM_USER_PANEL_DIALOG_RESET = "BottomUserPanelDialogReset";
//个人主页删除动态
const String EVENTBUS_PROFILE_DELETE_FEED = "profileUserDetailDeleteFeed";
//互动通知删除评论动态
const String EVENTBUS_INTERACTIVE_NOTICE_DELETE_COMMENT = "interactiveNoticeDelete";
// 是否可发布动态和展示进度视图
const String EVENTBUS_POST_PORGRESS_VIEW = "postporgressview";
// 发布动态失败后是否获取数据库失败model
const String EVENTBUS_GET_FAILURE_MODEL = "getfailuremodel";
//底部bar未读数
const String EVENTBUS_IF_TAB_BAR_UNREAD = "_IFTabBarStateUnreadMessageNumber";
// 动态未读数
const String EVENTBUS__FEED_UNREAD = "_FEED_UNREAD";
// 视频播放暂停
const String EVENTBUS__VIDEO_PLAYORPAUSE = "video_play_or_pause";
//聊天界面的bar
const String EVENTBUS_CHAT_BAR = "eventbus_chat_bar";
//聊天界面的加入群聊或者离开群聊
const String CHAT_JOIN_EXIT = "eventbus_chat_join_exit";
//聊天界面刷新群聊人数
const String RESET_CHAR_GROUP_USER_LIST = "eventbus_reset_char_group_user_list";
//聊天界面的更新消息状态
const String RESET_MSG_STATUS = "reset_msg_status";
//聊天界面的消息列表更新
const String CHAT_PAGE_LIST_MESSAGE_RESET = "chat_page_list_message_reset";
//聊天界面的接收消息
const String CHAT_GET_MSG = "chat_get_msg";
//聊天界面的撤回消息
const String CHAT_WITHDRAW_MSG = "chat_withdraw_msg";
//聊天界面的at群成员
const String CHAT_AT_GROUP_PANEL = "eventbus_chat_at_group_panel";
//聊天界面的输入框旁边的发送按钮和图片按钮
const String CHAT_BOTTOM_MORE_BTN = "eventbus_chat_bottom_more_btn";
// 重新登录替换关注页布局
const String AGAIN_LOGIN_REPLACE_LAYOUT = "again_login_replace_layout";
// 直播状态变化
const String LIVE_COURSE_LIVE_START_OR_END = "live_course_live_start_or_end";
// 直播预约
const String LIVE_COURSE_BOOK_LIVE = "live_course_book_live";
// 主页跳转界面功能
const String MAIN_PAGE_JUMP_PAGE = "main_page_jump_page";
// 训练界面获取最近直播课程数据
const String TRAINING_PAGE_GET_DATA = "training_page_get_data";
// 机器训练结束
const String END_OF_TRAINING = "end_of_training";
// 机器开始训练
const String START_TRAINING = "start_training";
// 机器开始直播课件
const String START_LIVE_COURSE = "start_live_course";
// 机器训练中
const String SCHEDULE_TRAINING_VIDEO = "schedule_training_video";
//双击tabbar
const String DOUBLE_TAP_TABBAR = "double_tap_tabbar";
//获取设备信息
const String GET_MACHINE_STATUS_INFO = "get_machine_status_info";
//显示新用户dialog
const String SHOW_IMAGE_DIALOG = "show_new_user_image_dialog";
//相册页离开页面
const String GALLERY_LEAVE = "gallery_leave";
//视频课结果页
const String VIDEO_COURSE_RESULT = "video_course_result";
