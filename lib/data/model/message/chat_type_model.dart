class ChatTypeModel {
  //没有信息
  static const String NULL_COMMENT = "null_comment";

  //普通的字符串
  //包含：普通的字符串和超链接的字符串
  static const String MESSAGE_TYPE_TEXT = "RC:TxtMsg";

  //图片
  static const String MESSAGE_TYPE_IMAGE = "RC:ImgMsg";

  //语音
  static const String MESSAGE_TYPE_VOICE = "RC:VcMsg";

  //自定义消息类型：短视频
  static const String MESSAGE_TYPE_VIDEO = "MD:VideoMessage";

  //自定义消息类型：动态消息
  static const String MESSAGE_TYPE_FEED = "MD:MomentMessage";

  //自定义消息类型：用户名片
  static const String MESSAGE_TYPE_USER = "MD:UserMessage";

  //自定义消息类型：圈子名片
  static const String MESSAGE_TYPE_CIRCLE = "MD:CircleMessage";

  //自定义消息类型：圈子邀请消息
  static const String MESSAGE_TYPE_INVITE = "MD:GroupInviteMessage";

  //自定义消息类型：系统消息
  static const String MESSAGE_TYPE_SYSTEM = "MD:SystemMessage";

  //自定义消息类型：聊天里面的系统消息
  static const String MESSAGE_TYPE_SYSTEM_CHAT = "MD:ChatSystemMessage";

  // 撤回的消息
  static const String MESSAGE_TYPE_RECALL_MSG = "RC:RcNtf";

  //群聊通知消息
  static const String MESSAGE_TYPE_GROUP_NOTIFICATION_MSG = "RC:GrpNtf";

  //命令类型的消息
  static const String MESSAGE_TYPE_CMD_MSG = "RC:CmdNtf";

  //自定义消息类型：表情消息
  static const String MESSAGE_TYPE_STICKER = "MD:StickerMessage";

  //自定义消息类型：以后的所有自定义消息类型都是这个
  static const String MESSAGE_TYPE_OAA = "MD:OAAMessage";

  //自定义消息类型：未知消息类型
  static const String MESSAGE_TYPE_UNKNOWN = "MD:UnknownMessage";

  //自定义消息类型：合并消息记录的消息类型
  static const String MESSAGE_TYPE_HISTORY_MERGE = "MD:HistoryMessage";

  //自定义消息类型：回复消息
  static const String MESSAGE_TYPE_REPLY = "MD:ReplyMessage";
}
