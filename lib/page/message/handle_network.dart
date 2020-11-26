import 'package:flutter/cupertino.dart';
import 'dart:io';

import 'package:flutter/material.dart';
enum IFPlatForm{
   IOS,
   ANDROID
}
abstract class PlateFormCheck{
  IFPlatForm platForm();
}
//网络情况报告页面
 class NetPage extends StatelessWidget implements PlateFormCheck{
   @mustCallSuper
   IFPlatForm platForm(){
    if(Platform.isIOS){
      return IFPlatForm.IOS;
    }
    else {
      return IFPlatForm.ANDROID;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (platForm() == IFPlatForm.IOS){
      return IOSNetPage().build(context);
    }
    else{
      return AndroidNetPage().build(context);
    }
  }
}
class AndroidNetPage extends NetPage implements PlateFormCheck{

 @override
  IFPlatForm platForm() {
    return super.platForm();
  }
  @override
  Widget build(BuildContext context) {
   return Column(
     children: [
       //头部导航栏
       Row(
         children: [
           Stack(
             alignment: Alignment.center,
             children: [
              Row(children: [

              ],),


             ] ,
           )
         ],
       ),
       //文字显示区域
       Container(
         child: Wrap(

         ),
       )
     ],
   );
  }

}
class IOSNetPage extends  NetPage implements PlateFormCheck{

  @override
  IFPlatForm platForm() {
    return super.platForm();
  }

  @override
  Widget build(BuildContext context) {

  }

}
