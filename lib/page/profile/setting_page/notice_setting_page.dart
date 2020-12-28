
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/util/screen_util.dart';

class NoticeSettingPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _noticeSettingState();
  }

}

class _noticeSettingState extends State<NoticeSettingPage>{
  bool getNoticeIsOpen = false;
  bool notFollow = false;
  bool FollowBuddy = false;
  bool mentionedMe = false;
  bool comment = false;
  @override
  Widget build(BuildContext context) {
    double width = ScreenUtil.instance.height;
    double height = ScreenUtil.instance.screenWidthDp;
      return Scaffold(
        backgroundColor: AppColor.white,
        appBar: AppBar(
          backgroundColor: AppColor.white,
          leading:  InkWell(
            child: Image.asset(
              "images/test/back.png",
            ),
            onTap: (){
              Navigator.pop(context);
            },
          ),
          title: Text("通知设置",style: AppStyle.textMedium18,),
          centerTitle: true,
        ),
        body:Container(
          padding: EdgeInsets.only(left: 16,right: 16),
          width: width,
          height: height,
          child:  Column(
          children: [
            _getNotice(),
            Container(height: 0.5,color: AppColor.bgWhite,width: width,),
            SizedBox(height: 12,),
            Container(
              height: 32,
              width: width,
              child: Container(
                alignment: Alignment.centerLeft,
                child: Text("私信通知",style: AppStyle.textSecondaryRegular14,),
              ),
            ),
            _switchRow(width, 1,notFollow, "未关注私信人"),
            _switchRow(width, 2,FollowBuddy, "我关注及好友私信"),
            SizedBox(height: 12,),
            Container(
              height: 32,
              width: width,
              child: Container(
                alignment: Alignment.centerLeft,
                child: Text("互动通知",style: AppStyle.textSecondaryRegular14,),
              ),
            ),
            _switchRow(width, 3, mentionedMe,"@我"),
            _switchRow(width, 4,comment, "评论"),
          ],
        ),),
      );
  }
  ///接收通知设置
  Widget _getNotice(){
      return Container(
        height: 48,
        child: Center(
          child:Row(
          children: [
            Text("接收推送通知",style: AppStyle.textRegular16,),
            Expanded(child: Container()),
            Text(getNoticeIsOpen?"已开启":"未开启",style: AppStyle.textHintRegular16,),
            SizedBox(width: 12,),
            Icon(Icons.arrow_forward_ios)
          ],
        ) ,),
      );
  }
  Widget _switchRow(double width,int type,bool isOpen,String title){
    return Container(
      height: 48,
      width: width,
      child: Center(
        child: Row(
        children: [
            Text(title,style: AppStyle.textRegular16,),
          Expanded(child: SizedBox()),
          CupertinoSwitch(
            activeColor: AppColor.mainRed,
            value: isOpen,
            onChanged: (bool value) {
              setState(() {
                switch(type){
                  case 1:
                    notFollow = value;
                    break;
                  case 2:
                    FollowBuddy = value;
                    break;
                  case 3:
                    mentionedMe = value;
                    break;
                  case 4:
                    comment = value;
                    break;
                }
              });
            },
          ),
        ],
      ),),
    );
  }
}