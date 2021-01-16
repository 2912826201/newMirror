



import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/profile/black_model.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/toast_util.dart';
///个人主页更多
class ProfileDetailsMore extends StatefulWidget{
  int userId;
  bool isFollow;
  String userName;
  ProfileDetailsMore({this.userId,this.isFollow,this.userName});
  @override
  State<StatefulWidget> createState() {
    return _detailsMoreState();
  }
}

class _detailsMoreState extends State<ProfileDetailsMore>{
  String _smarks = "未设置";
  bool isBlack = false;
  bool isNoChange = true;
  bool isSucess = false;
  @override
  void initState() {
    super.initState();
    _checkBlackStatus();
  }
  @override
  Widget build(BuildContext context) {
        double width = ScreenUtil.instance.screenWidthDp;
        double height = ScreenUtil.instance.height;
        return Scaffold(
            appBar: AppBar(
              backgroundColor: AppColor.white,
              title: Text("更多",style: AppStyle.textRegular18,),
              centerTitle: true,
              leading:InkWell(
                child: Container(
                  margin: EdgeInsets.only(left: 16),
                  child: Image.asset("images/resource/2.0x/return2x.png"),),
                onTap: (){
                  if(!isNoChange){
                    Navigator.pop(this.context,true);
                  }else{
                    Navigator.pop(this.context);
                  }
                },
              ),
              leadingWidth: 44,
            ),
            body:Container(
              height: height,
              width: width,
              color: AppColor.white,
              child:!widget.isFollow?_follow(width):_notFollow(width))
          );
  }
  ///没关注的布局
  Widget _notFollow(double width){
    return Column(
      children: [
        InkWell(
          onTap: (){
            _showDialog();
          },
          child: _itemSelect(width, AppStyle.textRegular16, "举报"),),

        Container(
          width: width,
          height: 0.5,
          color: AppColor.bgWhite.withOpacity(0.65),
        ),
        InkWell(
          onTap: (){
              if(isBlack){
                _cancelBlack();
              }else{
                _pullBlack();
              }
          },
          child: _itemSelect(width, AppStyle.textRegular16, isBlack?"取消拉黑":"拉黑"),),
        Container(
          width: width,
          height: 0.5,
          color: AppColor.bgWhite.withOpacity(0.65),
        ),
      ],
    );
  }
  ///关注的布局
  Widget _follow(double width){
    return Column(
      children: [
        Container(
          width: width,
          height: 0.5,
          color: AppColor.bgWhite.withOpacity(0.65),
        ),
        _remarks(width),
        Container(
          width: width,
          height: 12,
          color: AppColor.bgWhite.withOpacity(0.65),
        ),
        InkWell(
          child: _itemSelect(width, AppStyle.textRegular16, "举报"),
          onTap: (){
            _showDialog();
          },
        ),
        Container(
          padding: EdgeInsets.only(left: 16,right: 16),
          width: width,
          height: 0.5,
          color: AppColor.bgWhite.withOpacity(0.65),
        ),
        InkWell(
          onTap: (){
            if(isBlack){
              _cancelBlack();
            }else{
              _pullBlack();
            }
          },
          child: _itemSelect(width, AppStyle.textRegular16,isBlack?"取消拉黑":"拉黑"),),
        Container(
          width: width,
          height: 12,
          color: AppColor.bgWhite.withOpacity(0.65),
        ),
        InkWell(
          onTap: (){
            _cancelFollow();
          },
          child:  _itemSelect(width, AppStyle.textRegularRed16, "取消关注"),
        ),

        Container(
          padding: EdgeInsets.only(left: 16,right: 16),
          width: width,
          height: 0.5,
          color: AppColor.bgWhite.withOpacity(0.65),
        ),
      ],
    );
  }
  void _showDialog(){
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text('提交举报'),
          content: Text('确认举报该用户'),
          actions: <Widget>[
            CupertinoDialogAction(child: Text('再想想',style: AppStyle.textRegular16,),onPressed: (){
              Navigator.pop(context);
            },),
            CupertinoDialogAction(child: Text('必须举报！',style: AppStyle.textRegularRed16,),onPressed: (){
             _denounceUser(context);
            },),
          ],
        );
      });
  }

  Widget _itemSelect(double width,TextStyle style,String text){
    return Container(
      height: 48,
      width: width,
      padding: EdgeInsets.only(left: 16,right: 16),
      alignment: Alignment.centerLeft,
      child: Text(text,style: style,),
    );
  }

  Widget _remarks(double width){
    return  Container(
      width: width,
      height: 48,
      padding: EdgeInsets.only(left: 16,right: 16),
      child: InkWell(
        onTap: (){
          AppRouter.navigateToProfileAddRemarks(context,widget.userName,widget.userId);
        },
        child: Row(
        children: [
          Center(
            child: Text("修改备注",style: AppStyle.textRegular16,),
          ),
          Expanded(child: Container()),
          Center(
            child:Text(_smarks,style: AppStyle.textHintRegular16,) ,),
          SizedBox(width: 17,),
          Center(
            child: Text(">",style: AppStyle.textHintRegular16,),
          )
        ],
      ),)
    );
  }
    ///取消关注
  _cancelFollow()async{
    int cancelResult = await ProfileCancelFollow(widget.userId);
    print('取消关注监听==============================$cancelResult');
    if (cancelResult == 0||cancelResult==2) {
      ToastShow.show(msg: "已取消关注该用户", context: context);
      Navigator.pop(context,true);
    }
  }
  ///拉黑
  _pullBlack()async{
    bool blackStatus = await ProfileAddBlack(widget.userId);
    print('拉黑是否成功====================================$blackStatus');
    if(blackStatus==true){
      _checkBlackStatus();
      if(widget.isFollow){
        setState(() {
          isNoChange = false;
        });

      }
    }
  }
  ///取消拉黑
  _cancelBlack()async{
    bool blackStatus = await ProfileCancelBlack(widget.userId);
    print('取消拉黑是否成功====================================$blackStatus');
    if(blackStatus==true){
      _checkBlackStatus();
    }
  }
  ///请求黑名单关系
  _checkBlackStatus()async{
    BlackModel model = await ProfileCheckBlack(widget.userId);
    if(model!=null){
      print('inThisBlack===================${model.inThisBlack}');
      print('inYouBlack===================${model.inYouBlack}');
        if(model.inYouBlack==1){
          isBlack = true;
        }else{
          isBlack = false;
        }
        setState(() {
        });
    }
  }
  ///举报
  _denounceUser(WidgetContext)async{
    bool isSucess = await ProfileMoreDenounce(widget.userId,0);
    print('isSucess=======================================$isSucess');
    if(isSucess){
      ToastShow.show(msg:"举报成功" , context: context);
    }
    Navigator.pop(WidgetContext);
  }
}