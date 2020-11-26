import 'package:flutter/cupertino.dart';
import 'dart:io';
enum IFPlatForm{
   IOS,
   ANDROID
}
abstract class PlateFormCheck{
  IFPlatForm platForm();
}
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
