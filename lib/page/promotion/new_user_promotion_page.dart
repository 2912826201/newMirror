

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/data/model/message/chat_type_model.dart';
import 'package:mirror/data/model/user_model.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/dialog.dart';
import 'package:mirror/page/message/message_chat_page_manager.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

class NewUserPromotionPage extends StatefulWidget {
  @override
  _NewUserPromotionPageState createState() => _NewUserPromotionPageState();
}

class _NewUserPromotionPageState extends State<NewUserPromotionPage> {
  String image = "assets/png/new_user_promotion_page_bg.png";
  String imageBtn = "assets/png/new_user_promotion_page_btn.png";

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          appBar: CustomAppBar(
            titleString: "活动界面",
          ),
          body:  getBodyUi(),
        ),
        onWillPop: _requestPop);
  }


  Widget getBodyUi(){
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xffDBD1FF),
            Color(0xff927AF0),
          ],
        ),
      ),
      child: Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: [
          // ScrollConfiguration(
          //     behavior: OverScrollBehavior(),
          //     child: SingleChildScrollView(
          //       physics: RangeMaintainingScrollPhysics(),
          //       child: Container(
          //         child: Image.asset(image,fit: BoxFit.cover),
          //       ),
          //     ),
          // ),
          SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: Container(
              child: Image.asset(image,fit: BoxFit.cover),
            ),
          ),
          Container(
            height: 117,
            margin: EdgeInsets.only(bottom: 12),
            width: ScreenUtil.instance.width,
            color: Colors.transparent,
            child: GestureDetector(
              child: Container(
                child: Image.asset(imageBtn),
              ),
              onTap: (){
                jumpPage();
              },
            ),
          ),
        ],
      ),
    );
  }

  // 监听返回事件
  Future<bool> _requestPop() {
    _exitPageListener();
    return new Future.value(false);
  }

  //退出界面
  _exitPageListener() {
    showAppDialog(context,
        info: "不再看一眼？报名后即可获得教练一对一指导和丰富福利哦",
        barrierDismissible: false,
        cancel: AppDialogButton("残忍离开", () {
          Navigator.of(context).pop();
          return true;
        }),
        confirm: AppDialogButton("再看看", () {
          return true;
        }));
  }

  jumpPage()async{
    Future.delayed(Duration(milliseconds: 100),()async{
      Navigator.of(context).pop();
      ProfileAddFollow(1002885);
      UserModel userModel=UserModel();
      userModel.nickName="大灰狼";
      userModel.uid=1002885;
      userModel.avatarUri="http://devpic.aimymusic.com/ifapp/1002885/1618397003729.jpg";
      jumpChatPageUser(context, userModel,textContent: "我要参加训练营");
    });
  }
}
