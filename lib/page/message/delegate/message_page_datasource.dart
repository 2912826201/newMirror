//消息页面的会话数据源代理类
import 'dart:collection';
import 'dart:ffi';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:mirror/api/message_page_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/data/database/conversation_db_helper.dart';
import 'package:mirror/data/dto/conversation_dto.dart';
import 'package:mirror/data/model/message/intercourse_model.dart';
import 'package:mirror/page/message/delegate/callbacks.dart';
import 'package:mirror/page/message/delegate/message_page_ui_provider.dart';
import 'package:mirror/page/message/delegate/regular_events.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'message_interfaces.dart';
//普通的官方消息的消息id
const OFFICIAL = 1;
//直播消息
const LIVE_OFFICIAL = 2;
//运动消息
const EXERCISE_OFFICIAL = 3;
//官方消息枚举
enum Authorizeds{
  //运动
  ExerciseMsg,
  //系统
  SysMsg,
  //直播
  LiveMsg,
  //未知
  UnKnow
}
class MessagePageDataSource implements MPDataProxy {
  //事件key常量
  static const String REFRESH_A_CHAT = "REFRESH_A_CHAT";
  static const String REFRESH_A_CHAT_1 = "REFRESH_A_CHAT_1";
  static const String REFRESH_ALL_LIST = "REFRESH_ALL_LIST";

  //消息的种类常量
  static const String RCText = "RC:TxtMsg";
  static const String RCVoice = "RC:VcMsg";
  static const String RCImage = "RC:ImgMsg";
  static const String RCHighVoice = "RC:HQVCMsg";
  static const String RCGif = "RC:GIFMsg";
  static const String RCImage_Text = "RC:ImgTextMsg";
  static const String RCFile = "RC:FileMsg";
  static const String RCLocation = "RC:LBSMsg";
  static const String RCSight = "RC:SightMsg";
  static const String RCPSMsg = "RC:PSImgTxtMsg";
  static const String RCMUTIPS = "RC:PSMultiImgTxtMsg";

  //固定的头像
  static const String _fixedPortrait = "images/test/yxlm4.jpg";
  //系统会话的默认的最新消息
  static const String _fixedLatestMsg = "暂无最新消息";
  MessagePageDataSource() {
    _initialization();
  }

  //初始化的工作
  _initialization() {
    _initializationForIM();
    _initializationForInterCourse();
  }

  //及时通讯部分的初始化(涉及到从数据库取出历史的会话数据)
  _initializationForIM() async {
    print("initialize three empty arrays");
    _latestUnreadAuthorizeds[Authorizeds.LiveMsg] = List<ConversationDto>();
    _latestUnreadAuthorizeds[Authorizeds.LiveMsg].add(ConversationDto());
    _latestUnreadAuthorizeds[Authorizeds.SysMsg] = List<ConversationDto>();
    _latestUnreadAuthorizeds[Authorizeds.SysMsg].add(ConversationDto());
    _latestUnreadAuthorizeds[Authorizeds.ExerciseMsg] = List<ConversationDto>();
    _latestUnreadAuthorizeds[Authorizeds.ExerciseMsg].add(ConversationDto());
    //非置顶的会话读取
    List<ConversationDto> notPinnied = await ConversationDBHelper().queryConversation(Application.profile.uid, 0);
    //置顶的会话读取
    List<ConversationDto> pinned = await ConversationDBHelper().queryConversation(Application.profile.uid, 1);
    _pinnedConversation.addAll(pinned);
    _notpinnedConversation.addAll(notPinnied);
    _conversations.addAll(_pinnedConversation+_notpinnedConversation);
    print("get Stored Messages ${_conversations}");
    // //如果系统会话不存在则创建三个系统会话
    // if(_sysChatsExist(_pinnedConversation+_notpinnedConversation)==false){
    //   print("syschat not exsit");
    //   List<ConversationDto> sysChats = _createSysChatsIfNotExist();
    //   print("before add ${sysChats}");
    //   _conversations.addAll(sysChats);
    //   print("conversations is ${_conversations}");
    // }else{
    //   print("");
    // }
    //添加进入数据源
    _conversations.forEach((element) {
      ConversationDto dto = element;
      _chatData[dto.conversationId] = dto;
    });
    Map<String,dynamic> _placeholderMap = Map<String,dynamic>();
    _placeholderMap[MessagePageDataSource.REFRESH_ALL_LIST] = null;
     delegate.signals(payload: _placeholderMap);
  }

  //非即时通讯部分的初始化
  _initializationForInterCourse() {

  }
  String _sysChatName(int sys){
    switch(sys){
      case OFFICIAL:
        return "系统消息";
      case EXERCISE_OFFICIAL:
        return "运动消息";

      case LIVE_OFFICIAL:
        return "直播消息";
     default:
      return "未知消息";
     }
  }
  //创建系统三个会话
  List<ConversationDto> _createSysChatsIfNotExist(){
    List<ConversationDto> list = List<ConversationDto>();
    for(int i = 0;i<3;i++){
     ConversationDto dto = ConversationDto();
     dto.createTime = DateTime.now().millisecondsSinceEpoch;
     dto.updateTime = dto.createTime;
     dto.isTop = 0;
     dto.uid = Application.profile.uid;
     if(i==0){
       dto.type = OFFICIAL;
       dto.conversationId = "$OFFICIAL";
     }
     else if(i==1){
       dto.type = LIVE_OFFICIAL;
       dto.conversationId = "$LIVE_OFFICIAL";
     }
     else if (i ==2){
       dto.type = EXERCISE_OFFICIAL;
       dto.conversationId = "$EXERCISE_OFFICIAL";
     }
     dto.avatarUri = _fixedPortrait;
     dto.content = _fixedLatestMsg;
     dto.name = _sysChatName(dto.type);
     list.add(dto);
    }
    print("_createSysChatsIfNotExist ${list}");
    return list;
  }
  bool _sysChatsExist(List<ConversationDto> existDtos){
  Map<Authorizeds,bool> map = Map<Authorizeds,bool>();
  map[Authorizeds.SysMsg] = false;
  map[Authorizeds.ExerciseMsg] = false;
  map[Authorizeds.LiveMsg] = false;
    existDtos.forEach((element) {
      if(element.type == OFFICIAL){
        map[Authorizeds.SysMsg] = true;
      }
      if(element.type == EXERCISE_OFFICIAL){
        map[Authorizeds.ExerciseMsg] = true;
      }
      if(element.type == LIVE_OFFICIAL){
        map[Authorizeds.LiveMsg] = true;
      }
    });
   bool rs = true;
   map.keys.forEach((element) {
    rs = map[element] && rs;
   });
   return rs;
  }
  //接收及时消息的暂存(融云SDK会自动保存消息，这里为了减少访问数据库的次数)
  List<Message> _msgs = List<Message>();

  //保存会话数据
  LinkedHashMap<String, ConversationDto> _chatData = LinkedHashMap<String, ConversationDto>();

  //置顶的会话
  List<ConversationDto> _pinnedConversation = List<ConversationDto>();

  //非置顶会话
  List<ConversationDto> _notpinnedConversation = List<ConversationDto>();

  //放置会话的排列顺序
  List<ConversationDto>  _conversations = List<ConversationDto>();

  //最新消息的暂存数组
  Map<Authorizeds, List<ConversationDto>> _latestUnreadAuthorizeds = Map<Authorizeds, List<ConversationDto>>();
  Map<int, ConversationDto> _mapping = Map<int, ConversationDto>();

  //保存社交事件未读数
  Map _unreads = Map<MPIntercourses, int>();

  //为显示的不同index的cell提供高度
  @override
  double cellHeightAtIndex(int index) {
    return 69.0;
  }

  //为会话cell提供数据
  @override
  List<ConversationDto> imCellData() {
    List<ConversationDto> list = List<ConversationDto>();
   _chatData.keys.forEach((element) {
     list.add(_chatData[element]);
   });
   return list;
  }

  //提供交互事件的未读数量信息
  @override
  Future<Map<MPIntercourses, int>> unreadOfIntercources(MPCallbackWithValue callback) async {
    Unreads t = await getUnReads();
    _netBeanParsing(t);
    UnreadInterCourses rt = _netBeanParsing(t.interCourses);
    callback(()=>rt);
  }

  //网络到达数据mdoel的处理
  UnreadInterCourses _netBeanParsing<T>(T input) {
    print(input.runtimeType);
    //做好对系统类型消息的最新一条消息的的内容准备
    if (input is Unreads) {
      _latestUnreadAuthorizeds[Authorizeds.ExerciseMsg] = _defaultLatestMessage(input.exerciseMsgList);
      _latestUnreadAuthorizeds[Authorizeds.SysMsg] = _defaultLatestMessage(input.sysMsgList);
      _latestUnreadAuthorizeds[Authorizeds.LiveMsg] = _defaultLatestMessage(input.liveMsgList);
      print("_latestUreadAuthorized ${ _latestUnreadAuthorizeds[Authorizeds.ExerciseMsg]}");
      print("_latestUreadAuthorized ${ _latestUnreadAuthorizeds[Authorizeds.SysMsg]}");
      print("_latestUreadAuthorized ${ _latestUnreadAuthorizeds[Authorizeds.LiveMsg]}");
    }
     if (input is UnreadInterCourses) {
      return input;
    }
  }
  //会提供默认的最新消息或者解析最新的消息
  List<ConversationDto> _defaultLatestMessage(List<SystemMessageModel> list){
    if(list.isEmpty){
      ConversationDto dto = ConversationDto();
      dto.content = _fixedLatestMsg;
      return [dto];
    }
    print("_defaultLatestMessage${list.first}");
    List<SystemMessageModel> rt = list ;
    List<ConversationDto> t = List<ConversationDto>();
    rt.forEach((element) {
      ConversationDto dto = ConversationDto();
      print(element.toString());
      dto.content = element.content["data"];
      dto.updateTime = int.parse(element.msgTimestamp);
      dto.type = int.parse(element.fromUserId);
      t.add(dto);
    });
    return t;
  }
  ////////////////////////////
  /////////////////////////////
  /////////////////////////////
  ////////////////////////////
  //新消息来临后走这个函数加入到消息集合当中
  @override
  void newMsgsArrive(Set<Message> msgs) {
    //暂存消息
    _msgs.addAll(msgs);
    for (Message msg in msgs) {
      int potentialIndex = -1;
      //在_isExistRelevantChat()就已经对消息到达的不同情况所需要的数据跟新等准备工作做好
      potentialIndex = _isExistRelevantChat(msg);
      //每回来新的数据的时候，可能需要进行排序
      _sortChats();
      //是否已存在消息对应的会话
      switch (potentialIndex != -1) {
        case true:
          if (delegate == null) {
            return;
          }
          delegate.signals(payload: {REFRESH_A_CHAT: potentialIndex});
          break;
        default:
          if (delegate == null) {
            return;
          }
          delegate.signals(payload: {REFRESH_ALL_LIST: null});
          break;
      }
    }

  }
  ///////////////////////////
  //////////////////////////
  /////////////////////////
  //////////////////////////////
  void dispose() {
    this.delegate = null;
  }

  //
  _sortChats() {

  }

  //是否存在"已有会话",若已存在则跟新对应的会话的最新的消息内容，否则建立一个新的会话,返回-1表示全新的会话
  int _isExistRelevantChat(Message msg) {
    int k = -1;
    if (_chatData.keys.contains(msg.targetId)) {
      print("refresh a conversation");
      _chatData.keys.forEach((element) {
        ++k;
        if (element == msg.targetId) {
          _updateExistConversation("content", msg, _chatData[element]);
          return k;
        }
      });
    } else {
      print("create new Conversation");
      _newConversation(msg);
      return -1;
    }
    return k;
  }

  //跟新已有的会话的信息
  void _updateExistConversation(String fieldName, Message msg, ConversationDto dto) {
    print("_updateExistConversation");
    if (fieldName == "content") {
      dto.content = _getPlainText(msg);
    }
    dto.unread += 1;
    dto.updateTime = DateTime.now().millisecondsSinceEpoch;
  }

  //建立一个新的会话
  void _newConversation(Message msg) {
    ConversationDto newConv = ConversationDto();
    newConv.avatarUri = _fixedPortrait;
    newConv.content = _getPlainText(msg);
    newConv.createTime = DateTime
        .now()
        .millisecondsSinceEpoch;
    newConv.updateTime = newConv.createTime;
    //新会话默认不置顶
    newConv.isTop = 0;
    newConv.uid = Application.profile.uid;
    newConv.conversationId = msg.targetId;
    newConv.type = int.parse(msg.senderUserId);
    newConv.name = msg.senderUserId;
    newConv.unread = 1;
    this._conversations.add(newConv);
    _chatData[newConv.conversationId] = newConv;
  }

  //获取消息的类型
  Authorizeds _getMsgType(Message msg) {
    switch(int.parse(msg.senderUserId)){
      case OFFICIAL:
        return Authorizeds.SysMsg;
      case LIVE_OFFICIAL:
        return Authorizeds.LiveMsg;
      case EXERCISE_OFFICIAL:
        return Authorizeds.ExerciseMsg;
      default:
       return Authorizeds.UnKnow;
    }
  }

  //获取到各种类型信息中的普通文字信息的字符串
  String _getPlainText(Message msg) {
    if (msg.objectName == RCText) {
      TextMessage tmsg = msg.content;
      return tmsg.content;
    }
    return null;
  }

  @override
  Map<Authorizeds, List<ConversationDto>> latestAuthorizedMsgs() {
    return _latestUnreadAuthorizeds;
  }

  //向controller通知数据的到达等或者进行刷新界面
  @override
  MPIMDataSourceAction delegate;

  @override
  //存储会话数据
  saveChats() async{
    List<ConversationDto> list = List<ConversationDto>();
    _chatData.keys.forEach((element) {
      list.add(_chatData[element]);
    });
   bool rs = await ConversationDBHelper().insertConversations(list);
    print("saving chats  ${rs}");
  }
  //增加一个新的会话
  @override
  createNewConversation(ConversationDto dto) {
    print("数据源开始添加新会话 ${dto.toStirng()}");
   _chatData[dto.conversationId] = dto;
   print("after create NewChat: $_chatData");
   delegate.signals(payload: {MessagePageDataSource.REFRESH_ALL_LIST:null});
  }
}
