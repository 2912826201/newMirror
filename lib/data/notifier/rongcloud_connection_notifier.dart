import 'package:flutter/material.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

class RongCloudStatusNotifier with ChangeNotifier{
 int status = 0;
  //触发通知的行为
  void setTStatus(int newvalue){
  status = newvalue;
   notifyListeners();
 }

}