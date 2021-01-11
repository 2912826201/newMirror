import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

class ChatTypeModel {
  //没有信息
  static const String NULL_COMMENT = "null_comment";

  //普通的字符串
  //包含：普通的字符串和超链接的字符串
  static const String MESSAGE_TYPE_TEXT = "RC:TxtMsg";
  static const String MESSAGE_TYPE_TEXT_NAME = "文字消息，该版本较低请升级版本再行查看";

  //图片
  static const String MESSAGE_TYPE_IMAGE = "RC:ImgMsg";
  static const String MESSAGE_TYPE_IMAGE_NAME = "图片消息，该版本较低请升级版本再行查看";

  //语音HQVCMsg
  static const String MESSAGE_TYPE_VOICE = "RC:HQVCMsg";
  static const String MESSAGE_TYPE_VOICE_NAME = "语音消息，该版本较低请升级版本再行查看";

  //自定义消息类型：短视频
  static const String MESSAGE_TYPE_VIDEO = "IF:VideoMessage";
  static const String MESSAGE_TYPE_VIDEO_NAME = "视频消息，该版本较低请升级版本再行查看";

  //自定义消息类型：动态消息
  static const String MESSAGE_TYPE_FEED = "IF:FeedMessage";
  static const String MESSAGE_TYPE_FEED_NAME = "动态消息，该版本较低请升级版本再行查看";

  //自定义消息类型：用户名片
  static const String MESSAGE_TYPE_USER = "IF:UserMessage";
  static const String MESSAGE_TYPE_USER_NAME = "用户名片消息，该版本较低请升级版本再行查看";

  //自定义消息类型：直播课
  static const String MESSAGE_TYPE_LIVE_COURSE = "IF:LiveCourseMessage";
  static const String MESSAGE_TYPE_LIVE_COURSE_NAME = "直播课程消息，该版本较低请升级版本再行查看";

  //自定义消息类型：视频课
  static const String MESSAGE_TYPE_VIDEO_COURSE = "IF:VideoCourseMessage";
  static const String MESSAGE_TYPE_VIDEO_COURSE_NAME = "视频课程消息，该版本较低请升级版本再行查看";

  // 撤回的消息
  static const String MESSAGE_TYPE_RECALL_MSG = "RC:RcNtf";
  static const String MESSAGE_TYPE_RECALL_MSG_NAME = "撤回消息，该版本较低请升级版本再行查看";

  //自定义消息类型：提示信息
  static const String MESSAGE_TYPE_ALERT = "MD:AlertMessage";
  static const String MESSAGE_TYPE_ALERT_NAME = "提示消息，该版本较低请升级版本再行查看";

  //自定义消息类型：提示信息-时间提示
  static const String MESSAGE_TYPE_ALERT_TIME = "MD:AlertTimeMessage";
  static const String MESSAGE_TYPE_ALERT_TIME_NAME = "时间提示消息，该版本较低请升级版本再行查看";

  //自定义消息类型：提示信息-邀请
  static const String MESSAGE_TYPE_ALERT_INVITE = "MD:AlertInviteMessage";
  static const String MESSAGE_TYPE_ALERT_INVITE_NAME = "邀请消息，该版本较低请升级版本再行查看";

  //自定义消息类型：提示信息-移除
  static const String MESSAGE_TYPE_ALERT_REMOVE = "MD:AlertRemoveMessage";
  static const String MESSAGE_TYPE_ALERT_REMOVE_NAME = "移除消息，该版本较低请升级版本再行查看";

  //自定义消息类型：提示信息-新的消息
  static const String MESSAGE_TYPE_ALERT_NEW = "MD:AlertNewMessage";
  static const String MESSAGE_TYPE_ALERT_NEW_NAME = "有新消息，该版本较低请升级版本再行查看";

  //管家聊天界面：底部-可操作列表
  static const String CHAT_SYSTEM_BOTTOM_BAR = "MD:chat_system_bottom_bar";
  static const String CHAT_SYSTEM_BOTTOM_BAR_NAME = "底部列表消息，该版本较低请升级版本再行查看";

  //管家聊天界面：可选择的列表
  static const String MESSAGE_TYPE_SELECT = "MD:SelectMessage";
  static const String MESSAGE_TYPE_SELECT_NAME = "列表消息，该版本较低请升级版本再行查看";

  //判断这个消息是不是提示消息
  static bool getIsAlertMessage(String chatTypeModel) {
    if (chatTypeModel == MESSAGE_TYPE_ALERT) {
      return true;
    } else if (chatTypeModel == MESSAGE_TYPE_ALERT_TIME) {
      return true;
    } else if (chatTypeModel == MESSAGE_TYPE_ALERT_INVITE) {
      return true;
    } else if (chatTypeModel == MESSAGE_TYPE_ALERT_REMOVE) {
      return true;
    } else if (chatTypeModel == MESSAGE_TYPE_ALERT_NEW) {
      return true;
    } else if (chatTypeModel == RecallNotificationMessage.objectName) {
      return true;
    }
    return false;
  }

}
