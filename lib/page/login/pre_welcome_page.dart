import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/screen_util.dart';

class PreWelComePage extends StatelessWidget{
  PreWelComePage({@required this.avatarUrl,@required this.nickName,Key key}):super(key: key);
  //主标题的样式
  final TextStyle largeTitleStyle = TextStyle(decoration: TextDecoration.none,
    color: AppColor.textPrimary1,
    fontFamily: "PingFangSC",
    fontWeight: FontWeight.w500,
    fontSize: 23,
  );
  //副标题的样式
  final subTitleStyle = TextStyle(decoration: TextDecoration.none,
      fontSize: 14,
      fontFamily: "PingFangSC",
      fontWeight: FontWeight.w400,
     );
  //头像
  final dynamic avatarUrl;
  //昵称
  final String nickName;
  @override
  Widget build(BuildContext context) {
    print("PreWelComePage building");
    return Scaffold(
      body: Container(
        child: Column(
          children: [
            //"跳过"所在的区域
            Row(
              children: [
                 Expanded(child:
                   Container(
                          height: 48,
                          child: Row(
                            children: [
                              Spacer(),
                              GestureDetector(
                                onTap: ()=>_skip(),
                                child: Container(child: Text("跳过",style: TextStyle(decoration: TextDecoration.none,
                                    color: AppColor.textPrimary2,
                                    fontFamily: "PingFangSC",
                                    fontWeight: FontWeight.w400),
                                  ),
                                  margin: const EdgeInsets.only(right: 16,top: 13.5,bottom: 13.5),
                                  height: 48,
                                ),
                              )
                            ],
                          ),
                          //状态栏的高度预留
                          margin:  EdgeInsets.only(top: ScreenUtil.instance.statusBarHeight),
                   )
                )
               ],
            ),
            Spacer(
              //下方同理根据ui图的比例给出
              flex: 1,
            ),
            //内容区域
            Container(
             height: 228.5,
              child: Column(
              children: [
                //头像区域
                Row(children: [
                  Spacer(flex: 41,),
                  Container(width: 60,height: 60,
                   child: ClipRRect(child: _loadImage(),borderRadius: BorderRadius.all(Radius.circular(30)),),
                 ),Spacer(flex: 274,)
                ],),
                //主标题
                Row(children: [
                  Spacer(flex: 41,),
                  Expanded(child:
                   Container(child: Text("欢迎回来${_getNickName(nickName)},登录成功！",
                    style: largeTitleStyle,),
                     height: 31,
                     margin: const EdgeInsets.only(top: 10),
                   ),
                      flex: 297,
                    ),
                  Spacer(flex: 41,)
                ],),
                //副标题
                Row(children: [
                  Spacer(flex: 41,),
                  Expanded(child:
                   Container(child: Text("为了确保让你获得出色的体验，我们需要对你做出进一步的了解。",
                    style: subTitleStyle,),
                    height: 43.5,
                    margin: const EdgeInsets.only(top: 12),
                  ),
                    flex: 297,
                  ),
                  Spacer(flex: 41,)
                ],),
                //开始按钮
                Row(children: [
                  Spacer(flex: 41,),
                  Expanded(child:
                   GestureDetector(
                     child: Container(margin: const EdgeInsets.only(top: 28),
                       height: 44,
                       child: Center(child: Text("立即开始",style: TextStyle(decoration: TextDecoration.none,
                           fontFamily: "PingFangSC",
                           fontSize: 16,
                           fontWeight:FontWeight.w400,
                           color: AppColor.white),),),
                       decoration: BoxDecoration(
                         color: AppColor.black,
                         borderRadius: BorderRadius.all(Radius.circular(3))
                       ),
                     ),
                     onTap: ()=>{_completeInformation()},
                   ),
                    flex: 293,
                  ),
                  Spacer(flex: 41,)
                ],)
              ],
              ),
           ),
            Spacer(
              flex: 2,
            )
          ],
        ),
        margin: EdgeInsets.only(bottom: ScreenUtil.instance.bottomHeight),
      ),
    );
  }
  String _getNickName(String nickName){
    if(nickName.length>3){
      return nickName.substring(0,2) +"...";
    }
    return nickName;
  }
  //加载图片(区分网络和本地路径)
  dynamic _loadImage(){
    String avatar = this.avatarUrl;
    if(avatar.contains("http")){
     return Image.network(avatar,fit: BoxFit.cover,);
    }else{
      return Image.asset(avatar,fit: BoxFit.cover,);
    }
  }

  //立即开始
  _completeInformation(){
    print("立即开始");
  }
  _skip(){
   print("跳过");
  }
}