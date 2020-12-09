


import 'package:animations/animations.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:mirror/page/home/mine/mine_home.dart';
import 'package:mirror/page/home/mine/scancode.dart';
import 'package:mirror/util/app_style.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:r_scan/r_scan.dart';


class WoPage extends StatefulWidget {
  @override
  createState() => new WoPageState();
}

class WoPageState extends State<WoPage> with AutomaticKeepAliveClientMixin{
  String _ScanCodeResult = "";
  var bgColor=Color(0xffcccccc);
  bool _isScroll = false;
  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    super.build(context);
    return MaterialApp(
      home: Builder(builder: (context){
        double width =  MediaQuery.of(context).size.width;
        return Scaffold(
        appBar:null,
        body: _buildSuggestions(width),
        );})
    );
  }
  //界面
  Widget _buildSuggestions(double width){
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Container(
            color: bgColor,
            width: width,
            child: SizedBox(height: 28,),
          ),
          Expanded(child:
          SizedBox(child:GestureDetector(
            onHorizontalDragStart:(details){
                  setState(() {
                    _isScroll = false;
                  });
            },
            onVerticalDragStart: (details){
              setState(() {
                  _isScroll = true;
              });
            },
            child:  ListView(
              physics: _isScroll?BouncingScrollPhysics():NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.only(top: 0),
            children: [
              _getTopText(),
              Container(
                color: bgColor,
                child: Column(
                  children: [
                    _getUserImage(),
                    SizedBox(height: 20,),
                     Container(
                       child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children:[
                        _TextAndNumber("关注",12000),
                        _TextAndNumber("粉丝",1200),
                        _TextAndNumber("动态",120)
                      ] ,
                    ),),
                    _getVipData(),
                  ],
                ),
              ),
              _secondData(width),
              _getSettingWidget(width),
            ],
          ),)))
        ],
      ),
    );

  }



  //扫一扫
  Widget _getTopText(){
    return Container(
      color: bgColor,
      child: Row(
        children: [
          Expanded(child: SizedBox()),
          InkWell(
            onTap: () async {
              List<RScanCameraDescription> rScanCameras = await availableRScanCameras();
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return ScanCode(rScanCameras: rScanCameras,);
              }));
            },
            child: Container(
              padding: EdgeInsets.only(right: 8,bottom: 8,top: 10),
              child: Text("扫一扫",style: TextStyle(fontSize: 20),),
            ),
          )
        /*  OpenContainer(
            transitionDuration: const Duration(milliseconds: 500),
            closedBuilder: (BuildContext _, VoidCallback openContainer) {
              return Container(
                alignment: Alignment.centerLeft,
                child: Container(
                  child: Text("扫一扫",
                    style: TextStyle(fontSize: 20),),
                  padding: const EdgeInsets.only(right: 16,left: 16,top: 6,bottom: 6),
                ),
              );
            },
            openBuilder: (BuildContext context, VoidCallback _) {
              return  GestureDetector(
                child: Container(
                  child: Text("扫一扫",
                    style: TextStyle(fontSize: 20),),
                  padding: const EdgeInsets.only(right: 16,left: 16,top: 6,bottom: 6),
                ),
                onTap: (){
                      _scan();
                },
              );
            },
          ),*/
        ],
      ),
    );
  }

  //头像
  Widget _getUserImage(){
    return Container(
      child: InkWell(
        onTap: (){
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return MineDetails(type:1,);
          }));
        },
        child: Row(
        children: [
          SizedBox(width: 34,),
          Container(
            decoration: BoxDecoration(
              border:  new Border.all(width: 0.5, color: Colors.black),
              borderRadius: BorderRadius.circular(30),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Image.asset("images/aa.jpg",width: 60,height: 60,fit: BoxFit.cover,),
            ),
          ),
          SizedBox(width: 10,),
          Text("名字",style: TextStyle(fontSize: 28),),
          Expanded(child: SizedBox()),
          Container(
            child: Icon(Icons.chevron_right),
            margin: const EdgeInsets.only(right: 13),
          )
        ],
      ),
        )
    );
  }

  //第一条用户数据
  Widget _TextAndNumber(String text, int number) {
    return Container(
      child: Column(
        children: [
          Text(
            "${_getNumber(number)}",
            style: AppStyle.textRegular16,
          ),
          SizedBox(
            width: 10,
          ),
          Text(
            text,
            style: AppStyle.textRegular12,
          )
        ],
      ));
  }
  ///数值大小判断
  String _getNumber(int number){
    if (number < 1000) {
      return number.toString();
    } else {
      String db = "${(number / 1000).toString()}";
      String doubleText = db.substring(0, db.indexOf(".") + 2);
      return doubleText + "K";
    }
  }

  //vip数据
  Widget _getVipData(){
    return Container(
      child: Container(
        margin: const EdgeInsets.only(left: 20,right: 20,top: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(8),topRight: Radius.circular(8)),
          color: Colors.grey,
        ),
        child: Row(
          children: [
            Container(
              child: Text("VIP会员",style: TextStyle(fontSize: 17),),
              margin: const EdgeInsets.only(left: 16,top: 8,bottom: 6),
            ),
            Expanded(child: SizedBox()),
            Container(
              padding: const EdgeInsets.only(left: 16,right: 16,top: 6,bottom: 6),
              margin: const EdgeInsets.only(top: 8,bottom: 6,right: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.blue,
              ),
              child: Text("立即开通"),
            ),
          ],
        ),
      ),
    );
  }

  //第一个用户数据
  Widget _secondData(double width){
    var containerArray=<Widget>[];
    for(int i=0;i<3;i++){
      containerArray.add(
          Container(
            padding: const EdgeInsets.all(10),
            width: (width-5*16)/3,
            height:(width-5*16)/3,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              border: Border.all(width: 0.5,color: Colors.black),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: (width-4*20)/3,
                  child: Text("训练记录",textAlign: TextAlign.left,style: TextStyle(fontSize: 16),),
                ),
                Column(
                  children: [
                    Container(
                      width: (width-5*16)/3,
                      child: Text("总运动",textAlign: TextAlign.left,style: TextStyle(fontSize: 14,color: Colors.grey),),
                    ),
                    Row(
                      children: [
                        Text("41"),
                        SizedBox(width: 3,),
                        Container(
                          child: Text("分钟"),
                          margin: const EdgeInsets.only(top: 6),
                        )
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
      );
    }
    return Container(
      margin: const EdgeInsets.only(left: 20,right: 20,top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: containerArray,
      ),
    );
  }

//一些功能按钮
  Widget _getSettingWidget(double width){
    var settingBoxArray=["我的课程","我的订单","我的成就","设置","我的课程","我的订单","我的成就","设置",
      "我的课程","我的订单","我的成就","设置"];
    var columnArray=<Widget>[];
    var textTextStyle=TextStyle(fontSize: 20);
    columnArray.add(SizedBox(height: 20,));
    for (var value in settingBoxArray) {
      columnArray.add(
        Container(
          width: width,
          child: Text(value,style: textTextStyle,),
          padding: const EdgeInsets.only(top: 20,bottom: 20,left: 20),
        )
      );
    }
    return Container(
      child: Column(
        children: columnArray,
      ),
    );
  }



 /* _judgePermissions(var page,bool isCloseNewPage)async{
    if(await _requestPermissions()){
      _jumpPage(page,isCloseNewPage);
    }else{
      ToastCom.show("没有权限", context);
    }
  }*/

 /* _judgePermissions1(var page)async{
    if(await _requestPermissions()){
     return page;
    }else{
      ToastCom.show("没有权限", context);
    }
  }*/

  void _jumpPage(var page,bool isCloseNewPage){
    if(isCloseNewPage){
      //跳转并关闭当前页面
      Navigator.pushAndRemoveUntil(
        context,
        new MaterialPageRoute(builder: (context) => page),
            (route) => route == null,
      );
    }else{
      //跳转不关闭当前页面
      Navigator.of(context).push(
        new MaterialPageRoute(
          builder: (context) {
            return page;
          },
        ),
      );
    }
  }




}