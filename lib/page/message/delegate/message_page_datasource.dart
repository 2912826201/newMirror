//消息页面的会话数据源代理类
import 'dart:collection';
import 'package:mirror/config/application.dart';
import 'package:mirror/data/database/conversation_db_helper.dart';
import 'package:mirror/data/dto/conversation_dto.dart';
import 'package:mirror/data/model/message/chat_model.dart';
import 'package:mirror/page/message/delegate/regular_events.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'message_interfaces.dart';


class MessagePageDataSource implements MPDataSourceProxy {
  static const String REFRESH_A_CHAT = "REFRESH_A_CHAT";
  static const String REFRESH_ALL_LIST = "REFRESH_ALL_LIST";

  MessagePageDataSource() {
    _initialization();
  }
  _initialization() async{
    //非置顶的会话
    List<ConversationDto> notPinnied =  await ConversationDBHelper().queryConversation(Application.profile.uid, 0);
    //置顶的会话
    List<ConversationDto> pinned = await ConversationDBHelper().queryConversation(Application.profile.uid, 1);
    _pinnedConv.addAll(pinned);
    _notpinned.addAll(notPinnied);
  }
  //接收消息的暂存
  List<Message> _msgs = List<Message>();
  //保存会话数据
  LinkedHashMap<int,ConversationDto> _chatData = LinkedHashMap<int,ConversationDto>();
  //置顶的会话
  List<ConversationDto> _pinnedConv = List<ConversationDto>();
  //非置顶会话
  List<ConversationDto> _notpinned  = List<ConversationDto>();
  //放置消息的排列顺序
  List<ConversationDto> get _conversations  => _pinnedConv + _notpinned;
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
   for(int key in _chatData.keys){
     imData.add(imData[key]);
   }
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
    _msgs.addAll(msgs);
    for(Message msg in msgs){
      //是否已存在消息对应的会话
      switch(_isExistRelevantChat(msg)){
        case true:
          if(delegate==null){return;}
          delegate.signals(payload:{REFRESH_A_CHAT:_indexOf_A_ChatByMessage(msg)});
          break;
        default:
          if(delegate==null){return;}
          delegate.signals(payload: {REFRESH_ALL_LIST:null});
          break;
      }
    }
    //每回来新的数据的时候，都需要进行排序
    _sortChats();
  }
  //根据消息找对对应的会话
  int _indexOf_A_ChatByMessage(Message msg){

  }
  //对会话的数据进行按照时间的顺序来进行排序，新到的顺序较高
  _sortChats(){

  }
  //是否存在"已有会话"
  bool _isExistRelevantChat(Message msg){

  }
  //向delegate报告数据的情况
  @override
  MPIMDataSourceAction delegate;
}