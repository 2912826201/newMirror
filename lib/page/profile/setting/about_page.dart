

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/util/screen_util.dart';
//关于
class AboutPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
        return _AboutPageState();
  }

}
class _AboutPageState extends State<AboutPage>{
  @override
  Widget build(BuildContext context) {
    double width = ScreenUtil.instance.screenWidthDp;
    double height = ScreenUtil.instance.height;
        return Scaffold(
          backgroundColor: AppColor.white,
          appBar: AppBar(
            backgroundColor: AppColor.white,
            leading: InkWell(
              child: Container(
                margin: EdgeInsets.only(left: 16),
                child: Image.asset("images/resource/2.0x/return2x.png"),),
              onTap: (){
                Navigator.pop(context);
              },
            ),
            leadingWidth: 44,
            title: Text("关于iFitness",style: AppStyle.textMedium18,),
            centerTitle: true,
          ),
          body: Container(
            width: width,
            height: height-ScreenUtil.instance.statusBarHeight,
            padding: EdgeInsets.only(bottom: 16),
            child: Column(
              children: [
                Container(
                  height: 148,
                  width: width,
                  color: AppColor.bgWhite,
                  child: Center(
                    child: Container(
                      width: 64,
                      height: 64,
                      color: AppColor.bgBlack,
                    ),
                  ),
                ),
                _itemRow("用户协议"),
                _itemRow("隐私权政策"),
                Expanded(child: SizedBox()),
                Center(
                  child: Text("Copyright@2019 iFitness.All rights Reserved",style: AppStyle.textSecondaryRegular13,),
                )
              ],
            ),
          ),
        );
  }
      Widget _itemRow(String text){
        return Container(
          height: 48,
          width :ScreenUtil.instance.width,
          padding: EdgeInsets.only(left: 16,right: 16),
          child:Center(
            child: Row(
            children: [
              Text(text,style: AppStyle.textRegular16,),
              Expanded(child: SizedBox()),
              Container(
                height: 18,
                width: 18,
                child: Icon(Icons.arrow_forward_ios),
              )
            ],
          ),) ,
        );
  }
}