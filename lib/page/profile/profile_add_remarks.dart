

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/profile/add_remarks_model.dart';
import 'package:mirror/util/screen_util.dart';

///修改备注
class ProfileAddRemarks extends StatefulWidget{
  String userName;
  int  userId;
  ProfileAddRemarks({this.userId,this.userName});
  @override
  State<StatefulWidget> createState() {
   return _addRemarkState();
  }

}
class _addRemarkState extends State<ProfileAddRemarks>{
  int textLength = 0;
  String _EditText = "";
  String _remarks = "";
  @override
  Widget build(BuildContext context) {
    double width = ScreenUtil.instance.screenWidthDp;
    double height = ScreenUtil.instance.height;
    return Scaffold(
          backgroundColor: AppColor.white,
          appBar: AppBar(
            backgroundColor: AppColor.white,
            title: Text("修改备注",style: AppStyle.textMedium18,),
            centerTitle: true,
            leading:InkWell(
              child: Container(
                margin: EdgeInsets.only(left: 16),
                child: Image.asset("images/resource/2.0x/return2x.png"),),
              onTap: (){
                Navigator.pop(context);
              },
            ),
            leadingWidth: 44,
            actions: [
              Container(
                width: 60,
                margin: EdgeInsets.only(right: 16),
                child: Center(
                  child:Container(
                    decoration: BoxDecoration(
                      color: AppColor.mainRed,
                      borderRadius: BorderRadius.all(Radius.circular(14)),
                    ),
                    padding: EdgeInsets.only(left:16 ,right:16 ,top: 4,bottom:4 ),
                    child: Text(
                      "完成",
                      style: TextStyle(fontSize: 14, color: AppColor.white),
                    ),)
                ),
              )
            ],
          ),
          body: Container(
            height: height - ScreenUtil.instance.statusBarHeight,
            width: width,
            child: Column(
              children: [
                Container(
                  width: width,
                  height: 0.5,
                  color: AppColor.bgWhite.withOpacity(0.65),
                ),
                  SizedBox(height: 17,),
                  Container(
                    height:23,
                    width: width,
                    margin: EdgeInsets.only(top: 29),
                    child: _inputWidget()
                  ),
                Container(
                  margin: EdgeInsets.only(left: 16,right: 16),
                  width: width,
                  height: 0.5,
                  color: AppColor.bgWhite.withOpacity(0.65),
                ),
                Container(
                  padding: EdgeInsets.only(top: 12,left: 16),
                  width: width,
                  alignment: Alignment.bottomLeft,
                  child: Text("$textLength/15"),
                )
              ],
            ),
          ),
        );
  }

  Widget _inputWidget(){
    var putFiled = TextField(
      maxLength: 15,
      cursorColor:AppColor.black,
      style: AppStyle.textRegular16,
      decoration: InputDecoration(
        counterText: '',
        hintText: "戳这里输入备注",
        hintStyle:TextStyle(fontSize: 16,color: AppColor.textHint),
        border: InputBorder.none,),
        onChanged: (value){
        setState(() {
          _EditText = value;
          textLength = value.length;
        });

      },
    );
    return Container(
     padding: EdgeInsets.only(left: 16,right: 16),
      child: putFiled
    );
  }

  _changeRemarks({String remarks})async{
    AddRemarksModel model = await ChangeAddRemarks(widget.userId,remark: remarks);
    print('remark====================================================${model.remark}');
    if(model!=null){
      if(model.remark!=null){
        _remarks = model.remark;
      }
      Navigator.pop(context);
    }
  }

}