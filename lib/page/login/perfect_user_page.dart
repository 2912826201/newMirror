import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mirror/api/basic_api.dart';
import 'package:mirror/api/user_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/im/message_manager.dart';
import 'package:mirror/page/login/login_base_page_state.dart';
import 'package:mirror/constant/style.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:mirror/data/dto/token_dto.dart';
import 'package:mirror/data/dto/profile_dto.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:provider/provider.dart';
import 'package:mirror/data/database/profile_db_helper.dart';
import 'package:mirror/data/database/token_db_helper.dart';
import 'package:mirror/data/model/token_model.dart';
import 'package:mirror/data/model/user_model.dart';
import 'package:mirror/data/notifier/token_notifier.dart';
///这是完善资料页

class PerfectUserPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _PerfectUserState();
  }
}

class _PerfectUserState extends LoginBasePageState {
  //头像路径
  var _imgPath;
  //
  final _controller = PanelController();
  final inputCotroller = TextEditingController();
  //输入的最长字符
  final maxTextLength = 15;
  final _hintText = "戳这里输入昵称";
  //按钮本身的颜色
  final carryOutOriginColor = AppColor.textPrimary1.withOpacity(0.06);
  //按钮的标题初始颜色
  final btnTitileOriginColor = AppColor.textSecondary;
  //按钮的高亮背景色
  final btnLightColor = AppColor.bgBlack;
  //按钮标题的高亮颜色
  final btntitleLightColor = AppColor.white;
  //按钮的固定的标题
  final _btnText = "完成";
  int textLength = 0;
  //按钮颜色
  var _carryOutBtnColor;
  var _btnTitleColors ;
  bool _canClick;
  @override
  void initState() {
    super.initState();
    //默认无法点击"完成"
    _canClick = false;
    _carryOutBtnColor = carryOutOriginColor;
    _btnTitleColors = btnTitileOriginColor;
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Builder(builder: (context) {
      var _height = MediaQuery.of(context).size.height;
      return Scaffold(
        body: SlidingUpPanel(
          panel: Container(
            child: _bottomDialog(),
          ),
          maxHeight: _height * 0.24,
          backdropEnabled: true,
          controller: _controller,
          minHeight: 0,
          body: Container(
              child: InkWell(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
               child: Column(
                children: [
                Container(
                  child: navigationBar(),
                  padding: EdgeInsets.only(top: 40),
                ),
                SizedBox(
                  height: 40,
                ),
                _perfectHome(_controller)
              ],
            ),
          )),
        ),
      );
    }));
  }

  Widget _perfectHome(PanelController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ///头像
        Center(
          child:_avatarWidget(controller),
        ),
        SizedBox(height: 40),
        Center(child:Container(
          margin: EdgeInsets.only(left: 41,right: 41),
          child:Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ///输入框
            _inputWidget(),
            SizedBox(height: 32,),
            ///完成按钮
            _perfectUserBtn()
            ],
        )
        )
        )
      ],
    );
  }

  Widget _avatarWidget(PanelController controller) {
    return Container(
        width: 90,
        height: 90,
        child: InkWell(
          ///点击时出现dialog
            onTap: () {
              controller.open();
            },
            child: Stack(
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage(_imageView()),
                  maxRadius: 59,
                ),
                Positioned(
                    top: 66,
                    right: 6,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.all(Radius.circular(59)),
                          border: Border.all(width: 1, color: Colors.white)),
                      child: Center(
                        child: Text(
                          "+",
                          style: TextStyle(fontSize: 13.5, color: Colors.white),
                        ),
                      ),
                    ))
              ],
            )));
  }
    ///dialog
  Widget _bottomDialog() {
    return Container(
      child: Column(
        children: [
          InkWell(
              onTap: () {
                _takePhoto();
                _controller.close();
              },
              child: Container(
                  height: 50,
                  child: Center(
                    child: Text("拍摄", style: AppStyle.textRegular16),
                  ))),
          InkWell(
              onTap: () {
                _openPhoto();
                _controller.close();
              },
              child: Container(
                  height: 50,
                  child: Center(
                    child: Text("相册", style: AppStyle.textRegular16),
                  ))),
          Container(
            color: AppColor.bgWhite,
            height: 12,
          ),
          InkWell(
              onTap: () {
                _controller.close();
              },
              child: Container(
                  height: 50,
                  child: Center(
                    child: Text("取消",
                        style: TextStyle(
                            color: Color.fromRGBO(0xFF, 0x40, 0x59, 1.0),
                            fontSize: 16)),
                  )))
        ],
      ),
    );
  }
      ///输入框
    Widget _inputWidget(){
        var putFiled = TextField(
          maxLength: maxTextLength,
          controller: inputCotroller,
          showCursor: true,
          decoration: InputDecoration(
            hintText:_hintText,
            counterText: "",
            hintStyle: TextStyle(color: Color.fromRGBO(204, 204, 204, 1), fontFamily: 'PingFangSC', fontSize: 16),
            suffixText:"$textLength/$maxTextLength",
            suffixStyle: TextStyle(color: Color.fromRGBO(204, 204, 204, 1), fontFamily: 'PingFangSC', fontSize: 16),
          ),
          onChanged: (value){
             setState(() {
               textLength = value.length;
               if(value.isNotEmpty){
                  _canClick = true;
                 _carryOutBtnColor = btnLightColor;
                 _btnTitleColors = btntitleLightColor;
                 if(textLength>15){
                   value = value.substring(0,16);
                 }
               }else{
                 _canClick = false;
                 _carryOutBtnColor = carryOutOriginColor;
                 _btnTitleColors = btnTitileOriginColor;
               }
             });

        },
        );
        return Container(
          width: 293,
          child: putFiled
        );
    }
    ///完成按钮
  Widget _perfectUserBtn() {
    var btnStyle = RoundedRectangleBorder(borderRadius: BorderRadius.circular(3));
    var carryOutBtn = FlatButton(
      minWidth: 293,
      height: 44,
      shape: btnStyle,
      onPressed:(){
          if(_canClick){
            //调取完善资料的接口
            _perfectUserInfo(context,_imageView(),  this.inputCotroller.text);
          }else{

          }
      },
      child: Text(
        _btnText,
        style: TextStyle(fontFamily: "PingFangSC", fontSize: 16, color: _btnTitleColors),
      ),
      color: _carryOutBtnColor,
    );
    var returns = Container(
      child: carryOutBtn,
    );
    return returns;
  }
  ///判断是否选择了图片，如果没有则使用默认图片
  String _imageView() {
    if (_imgPath != null) {
      return _imgPath;
    } else {
      return "images/test/avatar.png";
    }
  }
    ///打开相机
  _takePhoto() async {
    var pickedImg = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      _imgPath = pickedImg.path;
    });
  }
    ///打开相册
  _openPhoto() async {
    var pickedFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imgPath = pickedFile.path;
    });
  }
  //TODO 这个是临时的方法,完善信息(只是简单地传入了名字，头像的信息没有传入)
  _perfectUserInfo(BuildContext context,String portrait,String name) async{
    bool perfectResult = await perfectUserInfo("$name" + Random().nextInt(10000).toString(), "https://i1.hdslb"
        ".com/bfs/archive/eb4d6aed7800003da1c6bdfa1c8476d4b6f567db.jpg");
    if(perfectResult){
      //登录成功之后则要清除掉计数
      Application.smsCodeSendTime = null;
      print("完善用户资料成功");
      //成功后重新刷新token
      TokenModel token = await login("refresh_token", null, null, Application.tempToken.refreshToken);
      if(token != null){
        print("刷新用户token成功");
        await _afterLogin(token, context);
      }else{
        print("刷新用户token失败");
      }
    }else{
      print("完善用户资料失败");
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/', (route) => false,
        //true 保留当前栈 false 销毁所有 只留下RepeatLogin
        arguments: {},
      );
    }
  }
  //TODO 完整的用户的处理方法 这个方法在登录页 绑定手机号页 完善资料页都会用到 需要单独提出来
  _afterLogin(TokenModel token, BuildContext context) async{
    TokenDto tokenDto = TokenDto.fromTokenModel(token);
    await TokenDBHelper().insertToken(tokenDto);
    context.read<TokenNotifier>().setToken(tokenDto);
    //然后要去取一次个人用户信息
    UserModel user = await getUserInfo();
    ProfileDto profile = ProfileDto.fromUserModel(user);
    await ProfileDBHelper().insertProfile(profile);
    context.read<ProfileNotifier>().setProfile(profile);
    //连接融云
    Application.rongCloud.connect();
    //TODO 处理登录完成后的数据加载
    MessageManager.loadConversationListFromDatabase(context);

    //TODO 页面跳转需要处理
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/', (route) => false,
      //true 保留当前栈 false 销毁所有 只留下RepeatLogin
      arguments: {},
    );
  }
}
