
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mirror/api/basic_api.dart';
import 'package:mirror/api/training/live_api.dart';
import 'package:mirror/api/user_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/media_file_model.dart';
import 'package:mirror/data/model/video_tag_madel.dart';
import 'package:mirror/im/message_manager.dart';
import 'package:mirror/page/login/login_base_page_state.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/page/media_picker/media_picker_page.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/custom_button.dart';
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
import 'package:toast/toast.dart';
///这是完善资料页

class PerfectUserPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _PerfectUserState();
  }
}

class _PerfectUserState extends LoginBasePageState {
  final inputCotroller = TextEditingController();
  //输入的最长字符
  final maxTextLength = 15;
  final _hintText = "戳这里输入昵称";
  String username = "";
  int textLength = 0;
  Uint8List imageData;
  List<File> fileList = [];
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    double width = ScreenUtil.instance.screenWidthDp;
    double height = ScreenUtil.instance.height;
    return Scaffold(
        backgroundColor: AppColor.white,
        appBar: AppBar(
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
        ),
        body: Container(
                  width: width,
                  height: height,
                child:Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ///头像
                    SizedBox(height: 40,),
                    Center(
                      child:_avatarWidget(),
                    ),
                    SizedBox(height: 48),
                    Container(
                      padding: EdgeInsets.only(left: 41,right: 41),
                      child:Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ///输入框
                          _inputWidget(),
                          SizedBox(height: 32,),
                          ///完成按钮
                          _perfectUserBtn(width)
                        ],
                      )
                    )
                  ],
                )
            ),
      );
  }


  Widget _avatarWidget() {
    return Container(
        width: 90,
        height: 90,
        child: InkWell(
            onTap: () {
              AppRouter.navigateToMediaPickerPage(
                context, 1, typeImage, true, startPageGallery, true, false, (result) async {
                SelectedMediaFiles files = Application.selectedMediaFiles;
                if (result != true || files == null) {
                  print('===============================值为空退回');
                  return;
                }
                if (fileList.isNotEmpty) {
                  fileList.clear();
                }
                Application.selectedMediaFiles = null;
                MediaFileModel model = files.list.first;
                print(
                  'model croppedImageData 1=========================${model.croppedImageData}  ${model.croppedImage}   ${model.file}');
                if (model != null) {
                  print("开始获取ByteData" + DateTime.now().millisecondsSinceEpoch.toString());
                  ByteData byteData = await model.croppedImage.toByteData(format: ui.ImageByteFormat.png);
                  print("已获取到ByteData" + DateTime.now().millisecondsSinceEpoch.toString());
                  Uint8List picBytes = byteData.buffer.asUint8List();
                  print("已获取到Uint8List" + DateTime.now().millisecondsSinceEpoch.toString());
                  model.croppedImageData = picBytes;
                }
                String timeStr = DateTime.now().millisecondsSinceEpoch.toString();
                if (model.croppedImageData != null) {
                  print('==================================model.croppedImageData!=null');
                  File imageFile = await FileUtil().writeImageDataToFile(model.croppedImageData, timeStr);
                  print('imageFile==============================$imageFile');
                  fileList.add(imageFile);
                  print('===============================${fileList.length}');
                }
                print('model.croppedImageData 2===========================${model.croppedImageData}');
                // context.read<InformationImageNotifier>().setImage(model.croppedImageData);
                setState(() {
                  imageData = model.croppedImageData;
                });
              });
            },
            child: Stack(
              children: [
                Container(
                  height: 90,
                  width: 90,
                  child: ClipOval(
                  child: imageData != null
                    ? Image.memory(
                    imageData,
                    fit: BoxFit.cover,
                  ) : Container(
                    color: AppColor.black,
                  )
                ),),
                Positioned(
                    bottom: 0,
                    right: 6,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                          color: AppColor.black,
                          borderRadius: BorderRadius.all(Radius.circular(59)),
                          border: Border.all(width: 1, color: AppColor.white)),
                      child: Center(
                        child: Text(
                          "+",
                          style: AppStyle.whiteRegular16,
                        ),
                      ),
                    ))
              ],
            )));
  }
      ///输入框
    Widget _inputWidget(){
        return TextField(
          maxLength: maxTextLength,
          controller: inputCotroller,
          showCursor: true,
          cursorColor: AppColor.black,
          decoration: InputDecoration(
            hintText:_hintText,
            counterText: "",
            hintStyle: AppStyle.textHintRegular16,
            suffixText:"$textLength/$maxTextLength",
              enabledBorder: UnderlineInputBorder(
                borderSide:BorderSide(width: 0.5,color: AppColor.bgWhite)
              ),
              focusedBorder:UnderlineInputBorder(
                borderSide:BorderSide(width: 0.5,color: AppColor.bgWhite)
              )
          ),
          onChanged: (value){
             setState(() {
               textLength = value.length;
               username = value;
             });

        },
        );
    }
    ///完成按钮
  Widget _perfectUserBtn(double width) {
    FocusNode blankNode = FocusNode();
    return Container(
      width: width,
      child: ClickLineBtn(
        title: "下一步",
        height: 44.0,
        width: width,
        circular:3.0,
        textColor: fileList.isNotEmpty&&username!=""?AppColor.white:AppColor.textSecondary,
        fontSize: 16,
        backColor: fileList.isNotEmpty&&username!=""?AppColor.bgBlack:AppColor.bgWhite,
        color: AppColor.transparent,
        onTap: (){
          if(fileList.isNotEmpty&&username!=""){
            FocusScope.of(context).requestFocus(blankNode);
            _upDataUserInfo();
          }else{
            Toast.show("昵称和头像不能为空", context);
          }

        },
      ),
    );
  }

  _upDataUserInfo() async {
    String avataruri = "";
      print('=============================开始上传图片');
      var results = await FileUtil().uploadPics(fileList, (percent) {
        print('===========================正在上传');
      });
     avataruri = results.resultMap.values.first.url;
    _perfectUserInfo(context,avataruri,username);

  }
  //TODO 这个是临时的方法,完善信息(只是简单地传入了名字，头像的信息没有传入)
  _perfectUserInfo(BuildContext context,String portrait,String name) async{
    bool perfectResult = await perfectUserInfo(name, portrait);
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
    Map<String, dynamic> videoCourseTagMap = await getAllTags();
    Application.videoTagModel = VideoTagModel.fromJson(videoCourseTagMap);
    //连接融云
    Application.rongCloud.connect();
    //TODO 处理登录完成后的数据加载
    MessageManager.loadConversationListFromDatabase(context);
    AppRouter.navigateToLoginSucess(context);
  }
}
