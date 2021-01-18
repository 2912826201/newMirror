
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/api/setting_api/setting_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/profile/black_list_model.dart';
import 'package:mirror/page/profile/profile_detail_page.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
//黑名单
class BlackListPage extends StatefulWidget{
  PanelController pc;
  BlackListPage({this.pc});
  @override
  State<StatefulWidget> createState() {
   return _BlackListState();
  }

}
class _BlackListState extends State<BlackListPage>{
  List<blackUserModel> blackList = [];

  _getBlackList()async{
    BlackListModel modelList = await SettingBlackList();
    if(modelList!=null){
      modelList.list.forEach((element) {
        blackList.add(element);
        print('黑名單名字--------------------------${element.nickName}');
        print('黑名單頭像--------------------------${element.avatarUri}');
      });
    }
    setState(() {
    });
  }
  @override
  void initState() {
    super.initState();
    _getBlackList();
  }
  @override
  Widget build(BuildContext context) {
    double width = ScreenUtil.instance.screenWidthDp;
    double height = ScreenUtil.instance.height;
    return Scaffold(
      backgroundColor: AppColor.white,
      appBar:  AppBar(
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
        title: Text("黑名单",style: AppStyle.textMedium18,),
        centerTitle: true,
      ),
      body:Container(
        padding: EdgeInsets.only(left: 16,right: 16),
        height: height,
        width: width,
        child: ListView.builder(
          itemCount: blackList.length,
          itemBuilder:(context,index){
                  return Column(
                    children: [
                    SizedBox(height: 12,),
                    _item(width, index)
                  ],);
          } ),
      ),
    );
  }
  Widget _item(double width,int index){
    print('item==========================${blackList[index].nickName}');
    return Container(
      width: width,
      height: 48,
      child: Row(
        children: [
          InkWell(
            onTap: (){
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return ProfileDetailPage(
                  userId: blackList[index].uid,
                );
              }));
            },
            child: ClipOval(
            child: CachedNetworkImage(
              height: 38,
              width: 38,
              imageUrl:blackList[index].avatarUri,
              fit: BoxFit.cover,
              placeholder: (context, url) => Image.asset(
                "images/test.png",
                fit: BoxFit.cover,
              ),
            ),
          ),),
          SizedBox(width: 12,),
          Center(
            child: Text(blackList[index].nickName,style:AppStyle.textRegular16,),
          ),
          Expanded(child: SizedBox()),
           Center(
              child:InkWell(
                onTap: (){
                  _cancelBlack(index);
                },
                child: Container(
                width: 56,
                height: 24,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(14)),
                  border: Border.all(width: 0.5, color: AppColor.mainRed),
                ),
                child:Center(child:Text(
                  "移除",
                  style: TextStyle(fontSize: 12, color: AppColor.mainRed),
                ),),),)
            ),
        ],
      ),
    );
  }

  ///取消拉黑
  _cancelBlack(int index)async{
    bool blackStatus = await ProfileCancelBlack(blackList[index].uid);
    print('取消拉黑是否成功====================================$blackStatus');
    if(blackStatus==true){
      Application.rongCloud.removeFromBlackList(blackList[index].uid.toString(), (code) {});
      blackList.removeAt(index);
    }
    setState(() {
    });
  }
}