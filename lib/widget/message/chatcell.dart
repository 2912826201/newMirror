import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/dto/conversation_dto.dart';
import 'package:intl/intl.dart';



abstract class ChatCellBehaviors{
  //对cell的内容进行刷新
  void refresh({@required ConversationDto model,int newBadges});
  //消息到来
  void msgsUnread(int newMsgs);
  //cell被点击
  void cellDidTap();
  //发生了@事件
  void atEvent({payload:Map});
}

//单个会话显示单元
// ignore: must_be_immutable
class MPChatCell extends StatefulWidget {
  MPChatCell({Key key,@required this.model,this.unreadMsgCount}):super(key: key);
  int unreadMsgCount = 0;
  final ConversationDto model;
  @override
  State<StatefulWidget> createState() {
    return  MPChatCellState();
  }

}
class MPChatCellState extends State<MPChatCell> implements ChatCellBehaviors{
  //未读消息数
  int _unreadMsgCount = 0;
  //决定展示何种类型的未读提示样式（有具体的显示数字的样式，也有那种一个小红点的情况）
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
  //最近一条消息的内容
  String _latestMsg = "";
  //会话名
  String _chatName = "";
  //会话头像路径
  String  _portrait = "";
  int _updateTime = 0;
  // //默认的会话头像地址
  // String _fixedPortrait = "images/test/yxlm4.jpg";
  @override
  void initState() {
  _latestMsg = widget.model.content ??= "暂无最新消息";
  _chatName = widget.model.name ??= "未知";
  _unreadMsgCount = widget.unreadMsgCount ??= 0 ;
  _portrait = widget.model.avatarUri ??="images/resources/yxlm4.jpg";
  _updateTime = widget.model.updateTime ??= DateTime.now().millisecondsSinceEpoch;
    super.initState();
  }

  Widget _portraitArea(int type){
    if(type == PRIVATE_CHAT_TYPE){
    return Container(
      alignment: Alignment.center,
      margin:const EdgeInsets.only(top: 12,bottom: 12,right: 12),
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
            image: NetworkImage(_portrait),
          )
      ),
    );
    }
    else if(type == GROUP_CHAT_TYPE){
      return Container(
        alignment: Alignment.topCenter,
        margin:const EdgeInsets.only(top: 12,bottom: 12,right: 12),
        width: portraitWH,
        child:Stack(
          children: [
            Container(child: Row(
              children: [
                Spacer(),
                Container(
                  alignment: Alignment.topRight,
                  width: 27.86,
                  height: 27.86,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(0.5*27.86)),
                      color: AppColor.mainRed,
                      image: DecorationImage(
                        fit: BoxFit.fill,
                        image: NetworkImage(_parseImageUrl(0)),
                      )
                  ),
                )
              ],
            ),
            margin: const EdgeInsets.only(left: 15.5),),
           Container(
             margin: const EdgeInsets.only(top: 13),
             child: Row(children: [
               Stack(
                 alignment: Alignment.center,
                 children: [
                   Container(
                     width: 33.86,
                     height: 33.86,
                     decoration: BoxDecoration(
                         borderRadius: BorderRadius.all(Radius.circular(0.5*33.86)),
                         color: AppColor.white
                     ),
                   )
                   ,Container(
                     alignment: Alignment.bottomLeft,
                     width: 27.86,
                     height: 27.86,
                     decoration: BoxDecoration(
                         color: Colors.yellow,
                         borderRadius: BorderRadius.all(Radius.circular(0.5*27.86)),
                         image: DecorationImage(
                           fit: BoxFit.fill,
                           image: NetworkImage(_parseImageUrl(1)),
                         )
                     ),
                   )
                 ],
               ),
               Spacer()
             ],),
           )
          ],
        )
      );
    }
  }
  String _parseImageUrl(int index){
    assert(index==0||index == 1);
    String mixedString = widget.model.avatarUri;
    int indexOfComma = mixedString.indexOf(",");
    if(index == 0){
      return mixedString.substring(0,indexOfComma);
    }else{
      return mixedString.substring(indexOfComma+1,mixedString.length);
    }
  }
  @override
  Widget build(BuildContext context) {
   ConversationDto model = widget.model;
   return Row(
     children: [
       Expanded(child:  Container(
         margin:const EdgeInsets.only(left: 16,right: 16),
         height: mainContentHeight,
         child: Row(
           children: [
             //头像区域
             _portraitArea(model.type),
             //文本显示区域
             Expanded(child: Container(
               color: AppColor.transparent,
               padding: EdgeInsets.only(top: 12,bottom: 13),
               child: Column(
                 children: [
                   Row(
                     children: [
                       //主名字
                       Text(_chatName,style: nameStyle,),
                       Spacer(),
                       //时间
                       Text(_transferRawDate(_updateTime),style: dateStyle,)
                     ],
                   ),
                   Container(
                       margin: const EdgeInsets.only(top: 3),
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
    var formatOfHM = new DateFormat('HH:mm');
    var formatOfMD = new DateFormat('MM-dd');
    String strTimePrefix = formatOfMD.format(DateTime.fromMicrosecondsSinceEpoch(time*1000));
    String strTimeSuffix = formatOfHM.format(DateTime.fromMicrosecondsSinceEpoch(time*1000));
    return strTimePrefix+" "+strTimeSuffix;
  }
  //尾部的消息指示视图
  Widget _tailWidget(){
       //根据当前未读数设置未读数的显示样式
       msgsUnread(_unreadMsgCount);
      //不显示
      if (_unreadStyle == _IndicateConditons._rawBinary ) {
        return Container();
      }
      //显示小红点
      else if (_unreadStyle == _IndicateConditons.tinyDot ) {
        return Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(8))
            ,color: AppColor.mainRed,
          ),
         );
      }
      //展示数字未读
      else {
        return Container(
          decoration: BoxDecoration(
            color: AppColor.mainRed,
            borderRadius: BorderRadius.all(Radius.circular(9))
          ),
          width: 18,
          height: 18,
          alignment: Alignment.center,
          child: Text("${_unreadMsgCount}",
            style: TextStyle(color: AppColor.white,
                fontFamily: "PingFangSC-Regular",
                fontSize: 12,
                fontWeight: FontWeight.w400,
                decoration: TextDecoration.none),
                textAlign: TextAlign.center,),
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
    return _latestMsg;
  }
  @override
  void cellDidTap() {
    // TODO: implement cellDidTap
  }
  //这个方法为_tailWidget()做铺垫
  @override
  void msgsUnread(int newMsgs) {
    print("~~~~~~~~~msgsWithCount~~~~~~~~~~~~");
    if(newMsgs>99){
      print("msgsWithCount >99 ${newMsgs}");
      _unreadMsgCount = 99;
      _unreadStyle = _IndicateConditons.tinyDot;
    }
    else if(newMsgs == 0){
      print("msgsWithCount ==0 ${newMsgs}");
      _unreadStyle = _IndicateConditons._rawBinary;
    }
    else{
      print("msgsWithCount >0 <99  ${newMsgs}");
      _unreadStyle = _IndicateConditons.numDot;
      print("_unreadStyle $_unreadStyle");
      _unreadMsgCount = newMsgs;
    }
  }
  //这个方法会影响到_detailDes(）的执行效果
  @override
  void atEvent({payload = Map}) {
    _atEvent = true;
  }

  @override
  void refresh({ConversationDto model, int newBadges}) {
    print("chatCell State refresh");
    if(newBadges != null){
      if(newBadges == 0){
        print("newbadget 0");
        _unreadStyle = _IndicateConditons._rawBinary;
        _unreadMsgCount = 0;
      }else {
        print("newBadgets ${newBadges}");
        _unreadStyle = _IndicateConditons.numDot;
        _unreadMsgCount += newBadges;
      }
     }
     if(model == null){
     }else{
      if(model.updateTime !=null){
      _updateTime = model.updateTime;
     }
      if (model.avatarUri != null) {
      _portrait = model.avatarUri;
     }
      if(model.name != null){
      _chatName = model.name;
     }
      if(model.content != null){
      _latestMsg = model.content;
     }
      if(model.unread != null){
        _unreadMsgCount = model.unread;
      }
    }
    setState(() {
    });
  }


}

class _IndicateConditons{
  static const int _rawBinary = 1;
  //展示小红点
  static const int tinyDot = 2;
  //展示数字提示
  static const int numDot = 3;
}