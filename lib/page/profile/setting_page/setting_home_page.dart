import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/basic_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/database/profile_db_helper.dart';
import 'package:mirror/data/database/token_db_helper.dart';
import 'package:mirror/data/dto/profile_dto.dart';
import 'package:mirror/data/dto/token_dto.dart';
import 'package:mirror/data/model/token_model.dart';
import 'package:mirror/data/model/user_model.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:mirror/data/notifier/token_notifier.dart';
import 'package:mirror/im/message_manager.dart';
import 'package:mirror/util/screen_util.dart';

class SettingHomePage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
   return _settingHomePageState();
  }
}
class _settingHomePageState extends State<SettingHomePage>{
  @override
  Widget build(BuildContext context) {
    double width = ScreenUtil.instance.height;
    double height = ScreenUtil.instance.screenWidthDp;
    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: AppBar(
        backgroundColor: AppColor.white,
        leading: InkWell(
          child: Image.asset("images/test/back.png"),
          onTap: (){
            Navigator.pop(context);
          },
        ),
        title: Text("设置",style: AppStyle.textMedium18,),
      ),
      body: Container(
        height: height - ScreenUtil.instance.statusBarHeight,
        width: width,
        child: Column(
          children: [
            SizedBox(height: 12,),
            _rowItem(width, "账户与安全"),
            _rowItem(width, "黑名单"),
            Container(
              height: 12,
              color: AppColor.bgWhite,
              width: width,
            ),
            _rowItem(width, "通知设置"),
            _rowItem(width, "清除缓存"),
            _rowItem(width, "意见反馈"),
            _rowItem(width, "关于"),
            Container(
              height: 12,
              color: AppColor.bgWhite,
              width: width,
            ),
            _signOutRow(width)
          ],
        ),
      ),
    );
  }
  Widget _signOutRow(double width){
     return InkWell(
       onTap: ()async{
              //先取个匿名token
        TokenModel tokenModel = await login("anonymous", null, null, null);
        if (tokenModel != null) {
          TokenDto tokenDto = TokenDto.fromTokenModel(tokenModel);
          bool result = await logout();
          //TODO 这里先不处理登出接口的结果
          await TokenDBHelper().insertToken(tokenDto);
          context.read<TokenNotifier>().setToken(tokenDto);
          await ProfileDBHelper().clearProfile();
          context.read<ProfileNotifier>().setProfile(ProfileDto.fromUserModel(UserModel()));
          // 登出融云
          Application.rongCloud.disconnect();
          //TODO 处理登出后需要清掉的用户数据
          MessageManager.clearUserMessage(context);
          //跳转页面 移除所有页面 重新打开首页
          Navigator.pushNamedAndRemoveUntil(context, "/", (route) => false);
        } else {
          //失败的情况下 登出将无token可用 所以不能继续登出
        }
      },
      child: Container(
        height: 48,
        width: width,
        padding: EdgeInsets.only(left: 16,right: 16),
        child: Row(
          children: [
            Text("退出登录",style: AppStyle.textRegularRed16,),
            Expanded(child: SizedBox())
          ],
        ),
      ),
    );
  }
  Widget _rowItem(double width,String text){
    return Container(
      height: 48,
      width: width,
      padding: EdgeInsets.only(left: 16,right: 16),
      child: Row(
        children: [
          Text(text,style: AppStyle.textRegular16,),
          Expanded(child: SizedBox(),),
          Container(
            height: 18,
            width: 18,
            child:Icon(Icons.arrow_forward_ios,color: AppColor.textSecondary,),)
        ],
      ),
    );
  }
}