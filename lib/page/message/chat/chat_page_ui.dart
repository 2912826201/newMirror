
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/page/message/chat/chat_page_interfaces/message_cell.dart';
import 'chat_page_interfaces/chat_page_interfaces.dart';

class ChatPageUi implements ChatUI{
  static const TextStyle navigationBarTitleStyle = TextStyle(
      fontFamily: 'PingFangSC',
      fontSize: 18,
      fontWeight: FontWeight.w500,
      decoration: TextDecoration.none);
  static const String popAction = "popAction";
  static const String moreAction = "moreAction";

  @override
  Widget inputArea() {
  return Container(
    height: 48,
    color: Colors.green,
  );
  }
   //外层是一个column
  @override
  Widget mainContent() {
    print("ui delegate mainContent");
    //外层是一个column所以需要一个Expanded
   return
     Expanded(flex: 1, child:
      Container(
        color: AppColor.bgWhite,
        //需要考虑横向宽度的弹性布局，所以使用了Row搭配内层的Expanded
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 1,
              child: Container(
                color: Colors.red,
                child: ListView.builder(padding: EdgeInsets.all(0),itemCount: actions_dataSource.sentences().length,
                    itemBuilder: (BuildContext context, int index){
                  print("bulding listView");
                  ChatCell cell = ChatCell.init(actions_dataSource.sentences()[index]);
                  return Expanded(child: Container(child: cell,height: cell.cellHeight(),));
              }
              ),
            ),
            )
          ],
        ),
      )
     );

  }
  //点击事件外发
  _dispatchAction({String identifier,dynamic payload}){
    actions_dataSource.uiEvent(identifier: identifier,paylaod: payload);
  }
  @override
  Widget navigationBar() {
    return Container(
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: ()=>_dispatchAction(identifier: popAction),
                child: Container(child: SizedBox(child: Image.asset("images/resource/return.png"),width: 28,height: 28,),
                margin:const EdgeInsets.only(left: 16,top: 8,bottom: 8),),
              ),
              Spacer(),
              GestureDetector(
                onTap: ()=>_dispatchAction(identifier: moreAction),
                child: Container(
                  child: SizedBox(child: Image.asset("images/test/ic_big_dynamic_more.png"),),
                  margin: const EdgeInsets.only(right: 16,top: 8,bottom: 8),
                ),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                child: Text(this.actions_dataSource.navigationBarTitle(),style: navigationBarTitleStyle,)
              )],
          )
        ],
      ),
    );
  }

  @override
  void scrollTo({double location, int whichCell}) {
    // TODO: implement scrollTo
  }

  @override
  ChatUiDelegate actions_dataSource;

  @override
  Widget chinBar(BuildContext context) {
    return SizedBox(width: MediaQuery.of(context).size.width, height: 34);
  }

  @override
  Widget eyebrowBar(BuildContext context) {
   return SizedBox(width: MediaQuery.of(context).size.width, height: 44);
  }

}