//消息页面的会话数据源代理类
import 'dart:collection';
import 'package:mirror/config/application.dart';
import 'package:mirror/data/database/conversation_db_helper.dart';
import 'package:mirror/data/dto/conversation_dto.dart';
import 'package:mirror/page/message/delegate/regular_events.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'message_interfaces.dart';


class MessagePageDataSource implements MPDataSourceProxy {
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
  MessagePageDataSource() {
    _initialization();
  }
  _initialization() async{
    //非置顶的会话
    List<ConversationDto> notPinnied =  await ConversationDBHelper().queryConversation(Application.profile.uid, 0);
    //置顶的会话
    List<ConversationDto> pinned = await ConversationDBHelper().queryConversation(Application.profile.uid, 1);
    _pinnedConversation.addAll(pinned);
    _notpinnedConversation.addAll(notPinnied);
    _conversations.forEach((element) {
      ConversationDto dto = element;
      _chatData[dto.conversationId] = dto;
    });
  }
  //接收消息的暂存
  List<Message> _msgs = List<Message>();
  //保存会话数据
  LinkedHashMap<String,ConversationDto> _chatData = LinkedHashMap<String,ConversationDto>();
  //置顶的会话
  List<ConversationDto> _pinnedConversation = List<ConversationDto>();
  //非置顶会话
  List<ConversationDto> _notpinnedConversation  = List<ConversationDto>();
  //放置消息的排列顺序
  List<ConversationDto> get _conversations  => _pinnedConversation + _notpinnedConversation;
  Map<int,ConversationDto> _mapping = Map<int,ConversationDto>();
  //保存社交事件未读数
  Map _unreads = Map<MPIntercourses,int>();
  //为显示的不同index的cell提供高度
  @override
  double cellHeightAtIndex(int index) {
    return 69.0;
  }
  //为会话cell提供数据
  @override
  List<ConversationDto> imCellData() {
   List<ConversationDto> imData = List<ConversationDto>();
   int k = -1;
   for(String key in _chatData.keys){
     ++k;
     imData.add(_chatData[key]);
   }
   // print("datasource imCellData  ${imData.length}");
   return imData;
  }
  //提供交互事件的未读数量信息
  @override
  Map<MPIntercourses, int> unreadOfIntercources() {
    if(_unreads.isEmpty){
      _unreads[MPIntercourses.Thumb] = 1;
      _unreads[MPIntercourses.At] = 2;
      _unreads[MPIntercourses.Comment] = 100;
    }
    return _unreads;
  }
  //新消息来临后走这个函数加入到消息集合当中
  @override
  void newMsgsArrive(Set<Message> msgs) {
    print(" just in datasource newMsgsArrive");
    print("msg count:  ${msgs.length}");
    //暂存消息
    _msgs.addAll(msgs);
    for(Message msg in msgs){
      int potentialIndex = -1;
      //在_isExistRelevantChat()就已经对消息到达的不同情况所需要的数据跟新等准备工作做好
      potentialIndex = _isExistRelevantChat(msg);
      //是否已存在消息对应的会话
      print("potentialindex $potentialIndex");
      switch(potentialIndex != -1){
        case true:
          if(delegate==null){return;}
          delegate.signals(payload:{REFRESH_A_CHAT:potentialIndex});
          break;
        default:
          if(delegate==null){return;}
          delegate.signals(payload: {REFRESH_ALL_LIST:null});
          break;
      }
    }
    //每回来新的数据的时候，可能需要进行排序
    _sortChats();
  }
  void dispose(){
   this.delegate = null;
  }
  //
  _sortChats(){
   
  }
  //是否存在"已有会话",若已存在则跟新对应的会话的最新的消息内容，否则建立一个新的会话,返回-1表示全新的会话
  int _isExistRelevantChat(Message msg){
    print("_isExistRelevantChat");
    int k = -1;
    if(_chatData.keys.contains(msg.targetId)){
      _chatData.keys.forEach((element) {
        ++k;
        if(element == msg.targetId){
          _updateExistConversation("content", msg, _chatData[element]);
          return k;
        }
      });
      // int index =-1;
      // _conversations.forEach((element) {
      //   ++index;
      //   ConversationDto t = element;
      //   //会话存在则直接跟新model内的最新的一条的消息内容
      //   if("${t.uid}" == msg.senderUserId){
      //     _updateExistConversation("content", msg, t);
      //     return index;
      //   }
      //   else{
      //     _newConversation(msg);
      //     return -1;
      //   }
      // });
    }else{
      _newConversation(msg);
      return -1;
    }
    return k;
  }
  //跟新已有的会话的信息
  void _updateExistConversation(String fieldName,Message msg,ConversationDto dto){
    print("_updateExistConversation");
    if(fieldName == "content"){
      dto.content = _getPlainText(msg);
    }
    dto.updateTime = DateTime.now().millisecondsSinceEpoch;
  }
  //建立一个新的会话
  void _newConversation(Message msg){
    print("_newConversation");
    ConversationDto  newConv = ConversationDto();
    newConv.avatarUri = _fixedPortrait;
    newConv.content = _getPlainText(msg);
    newConv.createTime = DateTime.now().millisecondsSinceEpoch;
    newConv.updateTime = newConv.createTime;
    //新会话默认不置顶
    newConv.isTop = 0;
    newConv.conversationId = msg.targetId;
    newConv.type = _getMsgType(msg);
    newConv.name = msg.senderUserId;
    this._conversations.add(newConv);
    _chatData[newConv.conversationId] = newConv;
  }
  //获取消息的类型
  int _getMsgType(Message msg){
    return msg.conversationType;
  }
  //获取到各种类型信息中的普通文字信息的字符串
  String _getPlainText(Message msg){
    if (msg.objectName == RCText){
      TextMessage tmsg = msg.content;
      return tmsg.content;
    }
    return null;
  }
  //向delegate报告数据的情况
  @override
  MPIMDataSourceAction delegate;
}