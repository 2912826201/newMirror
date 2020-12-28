
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/setting_api/setting_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/profile/black_list_model.dart';
import 'package:mirror/util/screen_util.dart';

class BlackListPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
   return _blackListState();
  }

}
class _blackListState extends State<BlackListPage>{
  List<BlackListModel> modelList = [];

  _getBlackList()async{
    modelList = await SettingBlackList();
    setState(() {
    });
  }
  @override
  Widget build(BuildContext context) {
    double width = ScreenUtil.instance.height;
    double height = ScreenUtil.instance.screenWidthDp;
    return Scaffold(
      appBar:  AppBar(
        backgroundColor: AppColor.white,
        leading:  InkWell(
          child: Image.asset(
            "images/test/back.png",
          ),
          onTap: (){
            Navigator.pop(context);
          },
        ),
        title: Text("黑名单",style: AppStyle.textMedium18,),
        centerTitle: true,
      ),
      body:Container(
        padding: EdgeInsets.only(left: 16,right: 16),
        height: height,
        width: width,
        child: ListView.builder(
          itemBuilder:(context,index){

          } ),
      ),
    );
  }
  Widget _item(double width,int index){
    return Container(
      width: width,
      height: 48,
      child: Row(
        children: [
          ClipOval(
            child: CachedNetworkImage(
              height: 38,
              width: 38,
              imageUrl:modelList[index].avatarUri,
              fit: BoxFit.cover,
              placeholder: (context, url) => Image.asset(
                "images/test.png",
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Text(modelList[index].nickName,style:AppStyle.textRegular16 ,),
          )
        ],
      ),
    );
  }
}