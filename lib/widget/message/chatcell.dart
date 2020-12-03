import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/dto/conversation_dto.dart';
import 'package:mirror/data/model/message/chat_model.dart';



abstract class ChatCellBehaviors{
  void refresh(ChatModel model);
  //消息到来
  void msgsWithCount(int newMsgs);
  //cell被点击
  void cellDidTap();
  //发生了@事件
  void atEvent({payload:Map});
}

//单个会话显示单元
class MPChatCell extends StatefulWidget implements ChatCellBehaviors{

  final ConversationDto model;
  _MPChatCellState _state = _MPChatCellState();
  MPChatCell({Key key,this.model}):super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _state;
  }

  @override
  void cellDidTap() {
    _state.cellDidTap();
  }

  @override
  void msgsWithCount(int newMsgs) {
    _state.msgsWithCount(newMsgs);
  }

  @override
  void atEvent({payload = Map}) {
    _state.atEvent(payload: payload);
  }

  @override
  void refresh(ChatModel model) {
    _state.refresh(model);
  }


}
class _MPChatCellState extends State<MPChatCell> implements ChatCellBehaviors{
  //未读消息数
  int _unreadMsgCount = 0;
  //决定展示何种类型的未读提示样式
  int _unreadStyle = _IndicateConditons._rawBinary;
  //是否有@事件来临
  bool _atEvent = false;
  //头像宽高
  final portraitWH =45.0;
  //官方会话头像右下角自带的一个标记图标
  final officialSign = "";
  //官方会话的右下角图标宽高
  final officialSignWH = 16.0;
  //主标题的文字样式
  final TextStyle nameStyle = TextStyle(color: AppColor.textPrimary1,fontFamily: "PingFangSC",fontSize: 16,
  fontWeight: FontWeight.w400,decoration: TextDecoration.none);
  //副标题的字体样式
  final TextStyle detailDesStyle = TextStyle(color:AppColor.textSecondary,fontFamily: "PingFangSC",fontSize: 13,
  fontWeight: FontWeight.w400,decoration: TextDecoration.none);
  //时间的字体样式
  final TextStyle dateStyle = TextStyle(color: AppColor.textHint,fontWeight: FontWeight.w400,fontFamily: "PingFangSC",fontSize: 12,
  decoration: TextDecoration.none);
  //主要内容展示区域高度
  final mainContentHeight = 69.0;
  @override
  Widget build(BuildContext context) {
   ConversationDto model = widget.model;
   return Row(
     children: [
       Expanded(child:  Container(
         margin: EdgeInsets.only(left: 16,right: 16),
         height: mainContentHeight,
         color: Colors.yellow,
         child: Row(
           children: [
             //头像区域
             Container(
               alignment: Alignment.center,
               margin: EdgeInsets.only(top: 12,bottom: 12,right: 12),
               width: portraitWH,
               child:
               OverflowBox(
                 maxHeight: portraitWH,
                 maxWidth: portraitWH,
                 alignment: Alignment.bottomRight,
                 child: Container(
                   width: officialSignWH,
                   height: officialSignWH,
                   child: Image.asset(officialSign),
                   decoration: BoxDecoration(
                       color: Colors.red,
                       borderRadius: BorderRadius.all(Radius.circular(officialSignWH/2))
                   ),
                 ),
               ),
               decoration: BoxDecoration(
                   borderRadius: BorderRadius.all(Radius.circular(0.5*portraitWH)),
                   image: DecorationImage(
                       fit: BoxFit.fill,
                       image: NetworkImage(model.avatarUri)
                   )
               ),
             ),
             //文本显示区域
             Expanded(child: Container(
               padding: EdgeInsets.only(top: 12,bottom: 13),
               child: Column(
                 children: [
                   Row(
                     children: [
                       //主名字
                       Text(model.name,style: nameStyle,),
                       Spacer(),
                       //时间
                       Text(_transferRawDate(model.updateTime),style: dateStyle,)
                     ],
                   ),
                   Container(
                       margin: EdgeInsets.only(top: 3),
                       child: Row(
                         children: [
                           //附加说明
                           _detailDes(detailDesStyle),
                            Spacer(),
                           //尾部的消息指示视图
                           _tailWidget()
                         ],
                       )
                   )
                 ],
               ),
             )),
           ],
         ),
       )),
     ],
   );
  }
  //unix时间转化为本地时间
  String _transferRawDate(int time){
    return "2020.11.22";
  }
  //尾部的消息指示视图
  Widget _tailWidget(){
    //不显示
    if(_unreadStyle==_IndicateConditons._rawBinary){
     return  Container();
    }
    //显示小红点
    else if(_unreadStyle == _IndicateConditons.tinyDot){
     return Container(color: AppColor.mainRed,
       width: 16,
       height: 16,
       decoration:BoxDecoration(
         borderRadius: BorderRadius.all(Radius.circular(8))
       ) ,);
    }
    //展示数字未读
    else{
     return Container(
       alignment: Alignment.center,
       child: Text("${_unreadMsgCount}+",style: TextStyle(color: AppColor.white,fontFamily: "PingFangSC-Regular",
       fontSize: 12,fontWeight: FontWeight.w400,decoration: TextDecoration.none),),
     );
    }
  }
  //说明文本
  Text _detailDes(TextStyle textStyle){
   if(_atEvent == true){
     return Text("[有人@你"+_cachedLatestChatData(),style: TextStyle());
   }
   else{
     return Text(_cachedLatestChatData(),style: textStyle,);
   }
  }
  //读取本地上次缓存的最新的会话记录
  String _cachedLatestChatData(){
    return widget.model.content;
  }
  @override
  void cellDidTap() {
    // TODO: implement cellDidTap
  }
  //这个方法为_tailWidget()做铺垫
  @override
  void msgsWithCount(int newMsgs) {
    if(newMsgs>99){
      _unreadMsgCount = 99;
      _unreadStyle = _IndicateConditons.tinyDot;
    }else{
      _unreadStyle = _IndicateConditons.numDot;
      _unreadMsgCount = newMsgs;
    }
  }
  //这个方法会影响到_detailDes(）的执行效果
  @override
  void atEvent({payload = Map}) {
    _atEvent = true;
  }

  @override
  void refresh(ChatModel model) {
    setState(() {
    });
  }
}
class _IndicateConditons{
  static const int _rawBinary = 0x0;
  //展示小红点
  static const tinyDot = _rawBinary<<1;
  //展示数字提示
  static const numDot = _rawBinary<<2;
}