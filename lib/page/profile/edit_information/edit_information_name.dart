

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/add_remarks_model.dart';
import 'package:mirror/util/screen_util.dart';

///编辑昵称
class EditInformationName extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
   return _editInformationNameState();
  }

}
class _editInformationNameState extends State<EditInformationName>{
  int textLength = 0;
  String _EditText = "";
  String _newName = "";
  int _reciprocal = 15;
  int nowLength = 0;
  @override
  Widget build(BuildContext context) {
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
                    child: _inputWidget(width)
                  ),
                Container(
                  margin: EdgeInsets.only(left: 16,right: 16),
                  width: width,
                  height: 0.5,
                  color: AppColor.bgWhite_65,
                ),
                  SizedBox(height: 12,),
                  _bottomText(width)
              ],
            ),
          ),
        );
  }

  Widget _bottomText(double width){
    return Container(
      width: width,
      padding: EdgeInsets.only(left: 16,right: 16),
      child: Row(
        children: [
          Text("0-15个字符，起个好听的，名字吧~",style: AppStyle.textPrimary3Regular14,),
          Expanded(child: Container()),
          Text("$_reciprocal",style: AppStyle.textPrimary3Regular14,)
        ],
      ),
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
          Expanded(child: Center(child: Text("编辑昵称",style: AppStyle.textMedium18,),),),
          InkWell(
            onTap: (){

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
  Widget _inputWidget(double width){
    var putFiled = TextField(
      maxLength: 15,
      cursorColor:AppColor.black,
      style: AppStyle.textRegular16,
      decoration: InputDecoration(
        counterText: '',
        hintText: "戳这里输入昵称",
        hintStyle:TextStyle(fontSize: 16,color: AppColor.textHint),
        border: InputBorder.none,),
        onChanged: (value){

        setState(() {
          _EditText = value;
          textLength = value.length;
          _reciprocal+= nowLength - textLength;
          nowLength = textLength;
        });

      },
    );
    return Container(
     padding: EdgeInsets.only(left: 16,right: 16),
      child: putFiled
    );
  }

}