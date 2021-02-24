
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/profile/black_model.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:mirror/page/profile/profile_detail_page.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/date_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/custom_button.dart';
import 'package:mirror/widget/dialog.dart';
import 'package:mirror/widget/feed/feed_more_popups.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:provider/provider.dart';

class HeadView extends StatefulWidget{
  HomeFeedModel model;
  // 是否显示关注按钮
  bool isShowConcern;
  // 删除动态
  ValueChanged<int> deleteFeedChanged;
  int isBlack;
  String pageName;
  // 取消关注
  ValueChanged<HomeFeedModel> removeFollowChanged;
  ValueChanged<bool> followChanged;
  int mineDetailId;
  bool isMySelf;
  HeadView({this.model,this.isShowConcern,this.deleteFeedChanged,this.removeFollowChanged,this.isBlack,this.mineDetailId,
    this.pageName,this.isMySelf});
  @override
  State<StatefulWidget> createState() {
   return HeadViewState(deleteFeedChanged: deleteFeedChanged,removeFollowChanged: removeFollowChanged,isShowConcern:
   isShowConcern,model: model,isBlack: isBlack,isMyself: isMySelf);
  }

}
class HeadViewState extends State<HeadView> {
  HeadViewState({Key key ,this.model, this.deleteFeedChanged,
    this.removeFollowChanged,this.isShowConcern = true,this.isBlack,this.isMyself});
  HomeFeedModel model;
  bool isShowConcern;
  // 删除动态
  ValueChanged<int> deleteFeedChanged;
  int isBlack;
  bool isMyself;
  double opacity = 0;
  // 取消关注
  ValueChanged<HomeFeedModel> removeFollowChanged;
  List<String> list = [];
  // 删除动态
  deleteFeed() async {
    Map<String, dynamic> map = await deletefeed(id: model.id);
    if (map["state"]) {
      deleteFeedChanged(model.id);
      if(isShowConcern){
        Navigator.pop(context,model.id);
      }
    } else {
      print("删除失败");
    }
  }
  _checkBlackStatus() async {
    BlackModel blackModel = await ProfileCheckBlack(widget.model.pushId);
    if (model != null) {
      print('inThisBlack===================${blackModel.inThisBlack}');
      print('inYouBlack===================${blackModel.inYouBlack}');
      if (blackModel.inYouBlack == 1) {
        context.read<ProfilePageNotifier>().changeBlack(true, model.pushId, 1);
      } else if (blackModel.inThisBlack == 1) {
        context.read<ProfilePageNotifier>().changeBlack(true, model.pushId, 2);
      } else {
        context.read<ProfilePageNotifier>().changeBlack(true, model.pushId, 0);
      }
    }
  }
  // 关注or取消关注
  removeFollowAndFollow( int id, BuildContext context,bool isCancel) async {
    if(isCancel){
      int relation = await ProfileCancelFollow(id);
      if(relation==0||relation==2){
        if(!isShowConcern){
          removeFollowChanged(model);
        }
        context.read<ProfilePageNotifier>().changeIsFollow(true,true,model.pushId);
        ToastShow.show(msg: "取消关注成功", context: context);
      }else{
        ToastShow.show(msg: "取消关注失败,请重试", context: context);
      }
    }else{
      int relation = await ProfileAddFollow(id);
      if(relation!=null){
        if(relation==1||relation==3){
          context.read<ProfilePageNotifier>().changeIsFollow(true,false,model.pushId);
          ToastShow.show(msg: "关注成功!", context: context);
          Future.delayed(Duration(milliseconds: 1000),(){
            opacity = 0;
            setState(() {
            });
          });
        }else{
          ToastShow.show(msg: "关注失败,请重试", context: context);
        }
      }
    }

  }


  // 是否显示关注按钮
  isShowFollowButton(BuildContext context) {
    if (isShowConcern && context.watch<ProfilePageNotifier>().profileUiChangeModel[model.pushId].isFollow == true&&model
        .pushId!=context
        .watch<ProfileNotifier>()
        .profile
        .uid) {
      opacity = 1;
      return  GestureDetector(
        onTap: () {
          if( context.read<ProfilePageNotifier>().profileUiChangeModel[model.pushId].isBlack==1){
            ToastShow.show(msg: "该用户已被你拉黑", context: context);
          }else if(context.read<ProfilePageNotifier>().profileUiChangeModel[model.pushId].isBlack==2){
            ToastShow.show(msg: "你已被该用户拉黑", context: context);
          }else{
            removeFollowAndFollow(model.pushId, context,false);
          }
        },
        child: Container(
          margin: EdgeInsets.only(right: 6),
          height: 28,
          padding: EdgeInsets.only(left: 12,top: 6,right: 12,bottom: 6),
          alignment: Alignment(0,0),
          decoration:  BoxDecoration(
            border: new Border.all(color: AppColor.textPrimary1, width: 1),
            borderRadius:BorderRadius.circular((14.0)),
          ),
          child: Row(
            children: [
              Icon(Icons.add,color: AppColor.textPrimary1,size: 16,),
              // Container(
              //   width: 16,
              //   height: 16,
              //   child: Image.asset(name),
              // ),
              SizedBox(
                width: 4,
              ),
              Container(
                child: Text(
                  "关注",
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColor.textPrimary1,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return AnimatedOpacity(
        opacity: opacity,
        duration: Duration(milliseconds: 2000),
        child: Container(
        margin: EdgeInsets.only(right: 6),
        height: 28,
        padding: EdgeInsets.only(left: 12,top: 6,right: 12,bottom: 6),
        alignment: Alignment(0,0),
        decoration:  BoxDecoration(
        border: new Border.all(color: AppColor.textPrimary1, width: 1),
        borderRadius:BorderRadius.circular((14.0)),
        ),
        child:Text("已关注",style: AppStyle.textRegular12,)),
      );
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('===========================================model.isFollow==${model.isFollow}');
    if (model.pushId == context.read<ProfileNotifier>().profile.uid) {
      if(!context.read<ProfilePageNotifier>().profileUiChangeModel.containsKey(model.pushId)){
        context.read<ProfilePageNotifier>().setFirstModel(model.pushId);
      }
      if(!context.read<ProfilePageNotifier>().profileUiChangeModel[model.pushId].dynmicStringList.contains("删除")){
        context.read<ProfilePageNotifier>().profileUiChangeModel[model.pushId].dynmicStringList.add("删除");
      }
    } else {
        if(!context.read<ProfilePageNotifier>().profileUiChangeModel.containsKey(model.pushId)){
          context.read<ProfilePageNotifier>().setFirstModel(model.pushId);
          context.read<ProfilePageNotifier>().changeIsFollow(true,model.isFollow == 1||model.isFollow==3?false:true,
              model
              .pushId);
          _checkBlackStatus();
        }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Container(
        height: 62,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
              Container(
                margin: EdgeInsets.only(left: 16, right: 11),
                child: CircleAvatar(
                  // backgroundImage: AssetImage("images/test/yxlm1.jpeg"),
                  backgroundImage:
                  model.avatarUrl != null ? NetworkImage(model.avatarUrl) : NetworkImage("images/test.png"),
                  maxRadius: 19,
                ),
              ),
            Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // GestureDetector(
                    //   child:
                      Text(
                        model.name ?? "空名字",
                        style: TextStyle(fontSize: 15),
                      ),
                      // onTap: () {},
                    // ),
                    Container(
                      padding: EdgeInsets.only(top: 2),
                      child: Text("${DateUtil.generateFormatDate(model.createTime,false)}",
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColor.textSecondary,
                          )),
                    )
                  ],
                )),
            isShowFollowButton(context),
            Container(
              margin: EdgeInsets.only(right: 16),
              child: GestureDetector(
                child: Image.asset("images/test/ic_big_dynamic_more.png", fit: BoxFit.cover, width: 24, height: 24),
                onTap: () {
                  openMoreBottomSheet(
                      context: context,
                      lists: context.read<ProfilePageNotifier>().profileUiChangeModel[model
                          .pushId].dynmicStringList,
                      onItemClickListener: (index) {
                        switch(context.read<ProfilePageNotifier>().profileUiChangeModel[model
                            .pushId].dynmicStringList[index]){
                          case "删除":
                            deleteFeed();
                            break;
                          case "取消关注":
                            removeFollowAndFollow(model.pushId, context,true);
                            break;
                          case "举报":
                            _showDialog();
                            break;
                        }
                      });
                },
              ),
            )
          ],
        ));
  }
  void _showDialog() {
    showAppDialog(context,
      confirm: AppDialogButton("必须举报!",(){
        _denounceUser();
        return true;
      }),
      cancel: AppDialogButton("再想想", (){
        return true;
      }),
      title: "提交举报",
      info: "确认举报用户",
    );
  }
  _denounceUser() async {
    bool isSucess = await ProfileMoreDenounce(model.pushId, 1);
    print('isSucess=======================================$isSucess');
    if (isSucess!=null&&isSucess) {
      ToastShow.show(msg: "举报成功", context: context);
    }
  }
}