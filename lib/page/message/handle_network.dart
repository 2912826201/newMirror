import 'package:flutter/cupertino.dart';
import 'dart:io';

import 'package:flutter/material.dart';
enum IFitnessPlatform{
   IOS,
   ANDROID
}
abstract class PlateFormCheck{
  IFitnessPlatform platForm();
}
//网络情况报告页面
 class NetPage extends StatelessWidget implements PlateFormCheck{
   @mustCallSuper
   IFitnessPlatform platForm(){
    if(Platform.isIOS){
      return IFitnessPlatform.IOS;
    }
    else {
      return IFitnessPlatform.ANDROID;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (platForm() == IFitnessPlatform.IOS){
      return IOSNetPage().build(context);
    }
    else{
      return AndroidNetPage().build(context);
    }
  }
}
//安卓的网络情况页面
class AndroidNetPage extends NetPage implements PlateFormCheck{

 @override
 IFitnessPlatform platForm() {
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
//ios
class IOSNetPage extends  NetPage implements PlateFormCheck{

  @override
  IFitnessPlatform platForm() {
    return super.platForm();
  }

  @override
  Widget build(BuildContext context) {

  }

}
