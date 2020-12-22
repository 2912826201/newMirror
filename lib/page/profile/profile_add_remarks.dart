

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/add_remarks_model.dart';
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
    return MaterialApp(
        home: Builder(builder: (context){
          double width = ScreenUtil.instance.screenWidthDp;
          double height = ScreenUtil.instance.height;
          return Scaffold(
          backgroundColor: AppColor.white,
          /*
           */
          body: Container(
            height: height,
            width: width,
            child: Column(
              children: [
                Container(
                  height: 44,
                ),
                _title(width),
                Container(
                  width: width,
                  height: 0.5,
                  color: AppColor.bgWhite_65,
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
                  color: AppColor.bgWhite_65,
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
        );},)
      );
  }

  Widget _title(double width){
   return Container(
      height: 44,
      width: width,
      padding: EdgeInsets.only(left: 16,right: 16),
      child: Row(
        children: [
          InkWell(
            onTap: (){
              Navigator.pop(this.context);
            },
            child: Image.asset("images/test/back.png"),
          ),
          Expanded(child: Center(child: Text("修改备注",style: AppStyle.textMedium18,),),),
          InkWell(
            onTap: (){
              if(_EditText!=null){
                _changeRemarks(remarks: _EditText);
              }else{
                _changeRemarks();
              }
            },
            child: Container(
              height: 28,
              width: 60,
              child: Center(child: Text("确定",style: TextStyle(fontSize: 14,color: AppColor.white),),),
              decoration: BoxDecoration(
                color: AppColor.mainRed,
                borderRadius: BorderRadius.all(Radius.circular(60)),
                border: Border.all(width: 1, color: AppColor.black))),)
        ],
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