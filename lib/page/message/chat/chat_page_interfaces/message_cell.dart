import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'chat_page_interfaces.dart';
//媒体类消息cell,支持手势点击以及媒体播放
abstract class MediaMessageCell implements MessageBaseCell,MediaPlay,ChatCell{
  //实例化
  Widget init(MessageObject object){
   switch (object.type){
     case MsgContentType.text:
       return _TextMessage().init(object);
       break;
     case MsgContentType.course:
       return _CourseMessage().init(object);
       break;
     case MsgContentType.image:
       return _ImageMessage().init(object);
       break;
     case MsgContentType.video:
       return _VideoMessage().init(object);
       break;
     case MsgContentType.voice:
       return _VoiceMessage().init(object);
       break;
     case MsgContentType.liveCourse:
       return _CourseMessage().init(object);
       break;
     default:
       throw ErrorDescription("无法区分的消息类型");
   }
  }
}
//图片类消息
class _ImageMessage extends StatefulWidget implements MediaMessageCell,CellHeight{
  @override
  Widget content;

  @override
  MsgDirection direction;

  @override
  double intrinsicHeight(){
    throw UnimplementedError();
  }

  @override
  var longPress;

  @override
  var tap;


  @override
  State<StatefulWidget> createState() {
  return _ImageMessageState();
  }

  @override
  T indicator<T extends StatusIndicator>() {
    // TODO: implement indicator
    throw UnimplementedError();
  }

  @override
  Widget init(MessageObject object) {
    // TODO: implement init
    throw UnimplementedError();
  }

  @override
  Widget name() {
    // TODO: implement name
    throw UnimplementedError();
  }

  @override
  void pause() {
    // TODO: implement pause
  }

  @override
  void play() {
    // TODO: implement play
  }

  @override
  Widget portrait() {
    // TODO: implement portrait
    throw UnimplementedError();
  }

  @override
  void stop() {
    // TODO: implement stop
  }

  @override
  double cellHeight() {
    return 79;
  }
}
//图片类消息State
class _ImageMessageState extends State<_ImageMessage>{
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }

}
//语音类消息
class _VoiceMessage extends StatelessWidget implements MediaMessageCell,CellHeight{
  //语音标记显示
  final _voiceIcon = "";
  final String mediaUrl;
  _VoiceMessage({Key key,@required this.mediaUrl}):super(key: key);
  @override
  LongPressCall longPress;

  @override
  TapCall tap;

  @override
  T indicator<T extends StatusIndicator>() {
    // TODO: implement indicator
    throw UnimplementedError();
  }

  @override
  Widget name() {
    // TODO: implement name
    throw UnimplementedError();
  }

  @override
  Widget portrait() {
    // TODO: implement portrait
    throw UnimplementedError();
  }

  @override
  Widget content;

  @override
  MsgDirection direction;

  @override
  double intrinsicHeight(){
    throw UnimplementedError();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }

  @override
  void pause() {
    // TODO: implement pause
  }

  @override
  void play() {
    // TODO: implement play
  }

  @override
  void stop() {
    // TODO: implement stop
  }

  @override
  Widget init(MessageObject object) {
    // TODO: implement init
    throw UnimplementedError();
  }

  @override
  double cellHeight() {
    return 37;
  }

}
//视频类消息
class _VideoMessage extends StatelessWidget implements MediaMessageCell,CellHeight{
  final _pauseIcon = "";
  final String mediaUrl ;
  _VideoMessage({Key key,@required this.mediaUrl}):super(key: key);
  @override
  LongPressCall longPress;

  @override
  TapCall tap;

  @override
  T indicator<T extends StatusIndicator>() {
    // TODO: implement indicator
    throw UnimplementedError();
  }

  @override
  Widget name() {
    // TODO: implement name
    throw UnimplementedError();
  }

  @override
  Widget portrait() {
    // TODO: implement portrait
    throw UnimplementedError();
  }

  @override
  Widget content;

  @override
  MsgDirection direction;

  @override
  double intrinsicHeight(){
    throw UnimplementedError();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }

  @override
  void pause() {
    // TODO: implement pause
  }

  @override
  void play() {
    // TODO: implement play
  }

  @override
  void stop() {
    // TODO: implement stop
  }

  @override
  Widget init(MessageObject object) {
    // TODO: implement init
    throw UnimplementedError();
  }

  @override
  double cellHeight() {
    return 79;
  }


}
//文字类消息
class _TextMessage extends StatelessWidget implements MediaMessageCell,CellHeight{
  final String contentString;
  _TextMessage({Key key,@required this.contentString}):super(key: key);
  @override
  LongPressCall longPress;

  @override
  TapCall tap;

  @override
  T indicator<T extends StatusIndicator>() {
// TODO: implement indicator
    throw UnimplementedError();
  }

  @override
  Widget name() {
// TODO: implement name
    throw UnimplementedError();
  }

  @override
  Widget portrait() {
// TODO: implement portrait
    throw UnimplementedError();
  }

  @override
  Widget content;

  @override
  MsgDirection direction;

  @override
  double intrinsicHeight(){
    throw UnimplementedError();
  }

  @override
  Widget build(BuildContext context) {
// TODO: implement build
    throw UnimplementedError();
  }

  @override
  Widget init(MessageObject object) {
    // TODO: implement init
    throw UnimplementedError();
  }

  @override
  void pause() {
    // TODO: implement pause
  }

  @override
  void play() {
    // TODO: implement play
  }

  @override
  void stop() {
    // TODO: implement stop
  }

  @override
  double cellHeight() {
    return 37;
  }

}
//课程类消息
class _CourseMessage extends StatefulWidget implements MediaMessageCell,CellHeight{
  final _pauseIcon = "";
  final String mediaUrl ;
  final String description;
  _CourseMessage({Key key,@required this.mediaUrl,@required this.description}):super(key: key);
  @override
  LongPressCall longPress;

  @override
  TapCall tap;

  @override
  T indicator<T extends StatusIndicator>() {
    // TODO: implement indicator
    throw UnimplementedError();
  }

  @override
  Widget name() {
    // TODO: implement name
    throw UnimplementedError();
  }

  @override
  Widget portrait() {
    // TODO: implement portrait
    throw UnimplementedError();
  }

  @override
  Widget content;

  @override
  MsgDirection direction;

  @override
  double intrinsicHeight(){
    throw UnimplementedError();
  }

  @override
  State<StatefulWidget> createState() {
    return _CourseMessageState();
  }
  @override
  void pause() {
    // TODO: implement pause
  }

  @override
  void play() {
    // TODO: implement play
  }

  @override
  void stop() {
    // TODO: implement stop
  }

  @override
  Widget init(MessageObject object) {
    // TODO: implement init
    throw UnimplementedError();
  }

  @override
  double cellHeight() {
    return 254.5;
  }

}
class _CourseMessageState extends State<_CourseMessage>{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }

}
/////////////////////////////////////////////////////////////////////////////////////////////////////
//辅助显示类消息cell
abstract class SupplementaryCell extends StatelessWidget implements SupplementaryBaseCell,CellHeight,ChatCell{
  SupplementaryCell init(MessageObject object){
   switch(object.eventType){
     case EventMsgType.invite:
     case EventMsgType.kick:
       return _GroupChatEventCell().init(object);
       break;
     case EventMsgType.retract:
       return _MessageReEditCell().init(object);
       break;
     default:
       break;
   }
  }
}
//时间显示cell,按照固定的节拍去出现及显示
class _TimeLabelCell  extends StatelessWidget implements SupplementaryCell{
  final int unixTimeStamp ;
  _TimeLabelCell({Key key,@required this.unixTimeStamp}):super(key: key);
  @override
  Widget content;

  @override
  MsgDirection direction;

  @override
  double intrinsicHeight(){
    throw UnimplementedError();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }

  @override
  SupplementaryCell init(MessageObject object) {
    // TODO: implement init
    throw UnimplementedError();
  }

  @override
  double cellHeight() {
    return 16.5;
  }

}

//群聊的成员事件增减情况显示cell
class _GroupChatEventCell extends StatelessWidget implements SupplementaryCell{

  @override
  Widget content;

  @override
  MsgDirection direction;

  @override
  double intrinsicHeight(){
    throw UnimplementedError();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }

  SupplementaryCell init(MessageObject object){
    throw UnimplementedError();
  }

  @override
  double cellHeight() {
   return 20.0;
  }
}

//"重新编辑"的消息提示
class _MessageReEditCell extends StatelessWidget implements SupplementaryCell,Touchable{

  @override
  Widget content;

  @override
  MsgDirection direction;

  @override
  double intrinsicHeight(){
    throw UnimplementedError();
  }

  @override
  LongPressCall longPress;

  @override
  TapCall tap;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }

  SupplementaryCell init(MessageObject object){
    throw UnimplementedError();
  }

  @override
  double cellHeight() {
   return 20.0;
  }
}

