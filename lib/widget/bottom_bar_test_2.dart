
import 'dart:async';
import 'dart:ffi';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';

void main() => runApp(MyApp());
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: BottomBarTest(),
    );
  }
}
class BottomBarTest extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {
   return _BottomBarTestState();
  }

}

class _BottomBarTestState extends State<BottomBarTest>{
  StreamController<int> streamController = StreamController<int>();
  List<int> expandWidth = [30,107,55,55,32];

  List<Color> itemColor = [AppColor.black,AppColor.black,AppColor.black,AppColor.black];
  int choseIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }
  @override
  Widget build(BuildContext context) {
    var physicalWidth = window.physicalSize.width;
    var physicalHeight = window.physicalSize.height;
    var dpr = window.devicePixelRatio;
    /*final width = physicalWidth / dpr;
    final height = physicalHeight / dpr;*/
     double width = physicalWidth / dpr;
    double height = physicalHeight / dpr;
   return StreamBuilder<int>(
       initialData: choseIndex,
       stream: streamController.stream,
       builder: (BuildContext stramContext, AsyncSnapshot<int> snapshot) {
         return Scaffold(
        bottomNavigationBar: BottomAppBar(
          child: Stack(
            children: [
              Container(height: 49,child: _animatoContainer(snapshot,width),),
              Container(height: 49,child: _textRow(snapshot),),
              Container(height: 49,child: _iconRow(width,height,snapshot),)
            ],
          ),
        ),
      );});
    }



   /* Widget _onClickRow(){
    return Row(
      children: [
        InkWell(
          child: Container(width: ,),
        )
      ],
    )
    }*/
  Widget _animatoContainer(AsyncSnapshot<int> snapshot,double width){
    int iconToIconWidth = (width-(90+32+32+(24*3)))~/3;
    int blackToIcon = (width-((32*2)+(24*3)+iconToIconWidth+90))~/2;
    int marginWidth = 0;
    if(snapshot.data==0){
      marginWidth = 16;
    }else if(snapshot.data==1){
      marginWidth = 32+24+blackToIcon;
    }else if(snapshot.data == 2){
      marginWidth = blackToIcon+(24*2)+iconToIconWidth+32;
    }else if(snapshot.data==3){
      marginWidth = (24*3)+blackToIcon+(iconToIconWidth*2)+32;
    }
    return Row(
      children: [
      AnimatedContainer(
        margin: EdgeInsets.only(left: marginWidth.toDouble()),
        duration: Duration(milliseconds: 200),
        child: Container(
          height: 32,
        width: 90,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16), color: AppColor.black),
      ),)
    ],);
  }
  Widget _textRow(AsyncSnapshot<int> snapshot){
    return Row(
      children: [
        SizedBox(width: 62,),
        AnimatedOpacity(opacity: snapshot.data==0?1:0, duration:Duration(milliseconds: 200) ,child: Text("首页",style:
            AppStyle.whiteMedium15,),),
        Spacer(),
        AnimatedOpacity(opacity: snapshot.data==1?1:0, duration: Duration(milliseconds: 200),child: Text("训练",style:
        AppStyle.whiteMedium15),),
        Spacer(),
        AnimatedOpacity(opacity: snapshot.data==2?1:0, duration: Duration(milliseconds: 200),child: Text("消息",style:
        AppStyle.whiteMedium15),),
        Spacer(),
        AnimatedOpacity(opacity: snapshot.data==3?1:0, duration: Duration(milliseconds: 200),child: Text("我的",style:
        AppStyle.whiteMedium15),),
        SizedBox(width: 30,)
      ],
    );
  }
Widget _iconRow(double width,double height,AsyncSnapshot<int> snapshot){
  int iconToIconWidth;
  int iconToside = 32;
  int blackIconToSide = 14+16;
  int iconToBlackSide =90-(24+14);
  iconToIconWidth = (width-(90+iconToside+iconToside+(24*3)))~/3;
  int blackToIcon = (width-((iconToside*2)+(24*3)+iconToIconWidth+90))~/2;
  int blackLeftWidth = 14;
  int blackRightWidth = 90-(blackLeftWidth+24);
  if(snapshot.data==0){
    expandWidth[0] = blackIconToSide;
    expandWidth[1] = blackRightWidth+iconToIconWidth;
    expandWidth[2] = iconToIconWidth;
    expandWidth[3] = iconToIconWidth;
    expandWidth[4] = iconToside;
  }else if(snapshot.data==1){
    expandWidth[0] = iconToside;
    expandWidth[1] = blackLeftWidth+blackToIcon;
    expandWidth[2] = blackRightWidth+blackToIcon;
    expandWidth[3] = iconToIconWidth;
    expandWidth[4] = iconToside;
  }else if(snapshot.data==2){
    expandWidth[0] = iconToside;
    expandWidth[1] = iconToIconWidth;
    expandWidth[2] = blackLeftWidth+blackToIcon;
    expandWidth[3] = blackRightWidth+blackToIcon;
    expandWidth[4] = iconToside;
  }else{
    expandWidth[0] = iconToside;
    expandWidth[1] = iconToIconWidth;
    expandWidth[2] = iconToIconWidth;
    expandWidth[3] = blackLeftWidth+iconToIconWidth;
    expandWidth[4] = blackRightWidth+16;
  }
          return Row(
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 200),
            curve: Curves.linear,
            width: expandWidth[0].toDouble(),
            child: Container(),),
          InkWell(
            onTap: (){
              streamController.sink.add(0);
            },
            child: Container(color:snapshot.data==0?AppColor.white:AppColor.black,width: 24,height: 24,),),
          AnimatedContainer(
            duration: Duration(milliseconds: 200),
            curve: Curves.linear,
            width: expandWidth[1].toDouble(),
            child: Container(),),
          InkWell(
            onTap: (){
              streamController.sink.add(1);
            },
            child: Container(color:snapshot.data==1?AppColor.white:AppColor.black,width: 24,height: 24,),),
          AnimatedContainer(
            duration: Duration(milliseconds: 200),
            curve: Curves.linear,
            width: expandWidth[2].toDouble(),
            child: Container(),),
          InkWell(
            onTap: (){
              streamController.sink.add(2);
            },
            child: Container(color:snapshot.data==2?AppColor.white:AppColor.black,width: 24,height: 24,),),
          AnimatedContainer(
            duration: Duration(milliseconds: 200),
            curve: Curves.linear,
            width: expandWidth[3].toDouble(),
            child: Container(),),
          InkWell(
            onTap: (){
              streamController.sink.add(3);
            },
            child: Container(color:snapshot.data==3?AppColor.white:AppColor.black,width: 24,height: 24,),),
          AnimatedContainer(
            duration: Duration(milliseconds: 200),
            curve: Curves.linear,
            width: expandWidth[4].toDouble(),
            child: Container(),),
        ],
      );
    }
}
