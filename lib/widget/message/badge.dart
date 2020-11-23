import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';

//消息数量提示视图

class MPBadge extends StatefulWidget{
  final int count;
  final int maxCount ;
  MPBadge({Key key,this.count,int maxNum}):this.maxCount = (maxNum ??= 99),super(key: key);
  @override
  State<StatefulWidget> createState() {
   return _MPBadgeState();
  }

}

class _MPBadgeState extends State<MPBadge>{

  @override
  Widget build(BuildContext context) {
   return Container(
     child: Text(_expectCount(),
       style: TextStyle(fontFamily: "PingFangSC-Regular",fontSize: 12,color: AppColor.white),),
     decoration: BoxDecoration(
       borderRadius: BorderRadius.all(Radius.circular(9)),
       color: AppColor.mainRed
     ),
   );
  }
  //数量生成
   String _expectCount(){
    if (widget.count >= 99)
      {
        return "99+";
      }
    return "${widget.count}";
   }
}