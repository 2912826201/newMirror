

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/constants.dart';
import 'package:mirror/data/model/user_model.dart';
import 'package:mirror/data/notifier/token_notifier.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/dialog.dart';
import 'package:mirror/page/message/message_chat_page_manager.dart';
import 'package:provider/provider.dart';

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
            leadingOnTap:_requestPop,
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
                if (!(mounted && context.read<TokenNotifier>().isLoggedIn)) {
                  ToastShow.show(msg: "请先登录app!", context: context);
                  AppRouter.navigateToLoginPage(context);
                  return;
                }
                if(Application.profile.uid==coachAccountId){
                  ToastShow.show(msg: "导师本人不能参加活动！", context: context);
                  return;
                }
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
        info: "不再看一眼？报名后，即可获得有效的燃脂的训练指导哟~",
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
      ProfileAddFollow(coachAccountId);
      UserModel userModel=UserModel();
      userModel.nickName="大灰狼";
      userModel.uid=coachAccountId;
      userModel.avatarUri="http://devpic.aimymusic.com/ifapp/1002885/1618397003729.jpg";
      jumpChatPageUser(context, userModel,textContent: "我要参加训练营");
    });
  }
}
