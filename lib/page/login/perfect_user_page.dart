import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jpush_flutter/jpush_flutter.dart';
import 'package:mirror/api/basic_api.dart';
import 'package:mirror/api/machine_api.dart';
import 'package:mirror/api/message_api.dart';
import 'package:mirror/api/push_api.dart';
import 'package:mirror/api/topic/topic_api.dart';
import 'package:mirror/api/user_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/config/runtime_properties.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/base_response_model.dart';
import 'package:mirror/data/model/data_response_model.dart';
import 'package:mirror/data/model/machine_model.dart';
import 'package:mirror/data/model/media_file_model.dart';
import 'package:mirror/data/model/message/no_prompt_uid_model.dart';
import 'package:mirror/data/model/message/top_chat_model.dart';
import 'package:mirror/data/model/topic/topic_background_config.dart';
import 'package:mirror/data/notifier/machine_notifier.dart';
import 'package:mirror/data/notifier/user_interactive_notifier.dart';
import 'package:mirror/im/message_manager.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/page/media_picker/media_picker_page.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/event_bus.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/icon.dart';
import 'package:mirror/widget/input_formatter/expression_team_delete_formatter.dart';
import 'package:mirror/widget/loading.dart';
import 'package:mirror/data/dto/token_dto.dart';
import 'package:mirror/data/dto/profile_dto.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:provider/provider.dart';
import 'package:mirror/data/database/profile_db_helper.dart';
import 'package:mirror/data/database/token_db_helper.dart';
import 'package:mirror/data/model/token_model.dart';
import 'package:mirror/data/model/user_model.dart';
import 'package:mirror/data/notifier/token_notifier.dart';

import 'package:mirror/widget/Input_method_rules/pin_yin_text_edit_controller.dart';
import 'package:umeng_common_sdk/umeng_common_sdk.dart';

///?????????????????????

class PerfectUserPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _PerfectUserState();
  }
}

class _PerfectUserState extends State<PerfectUserPage> {
  //?????????????????????
  final maxTextLength = 15;
  final _hintText = "?????????????????????";
  String username = "";
  int textLength = 0;
  Uint8List imageData;
  List<File> fileList = [];
  bool onClicking = false;
  double width = ScreenUtil.instance.screenWidthDp;
  double height = ScreenUtil.instance.height;
  PinYinTextEditController controller = PinYinTextEditController();
  String lastInput = "";

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      if (lastInput != controller.completeText) {
        lastInput = controller.completeText;

        ///??????onChanged
        setState(() {
          username = lastInput;
          textLength = lastInput.length;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(

        value: SystemUiOverlayStyle.light, //?????????dark ?????????light
        child: Scaffold(
          backgroundColor: AppColor.mainBlack,
          resizeToAvoidBottomInset: false,
          appBar: null,
          body: Container(
            width: width,
            height: height,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ///??????
                SizedBox(
                  height: 40 + CustomAppBar.appBarHeight + ScreenUtil.instance.statusBarHeight,
                ),
                Center(
                  child: _avatarWidget(),
                ),

                SizedBox(height: 48),
                Container(
                  padding: EdgeInsets.only(left: 41, right: 41),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ///?????????
                      _inputWidget(),
                      SizedBox(
                        height: 32,
                      ),

                      ///????????????
                      _perfectUserBtn()
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _avatarWidget() {
    return Container(
      width: 90,
      height: 90,
      child: InkWell(
        highlightColor: AppColor.transparent,
        splashColor: AppColor.transparent,
        onTap: () {
          AppRouter.navigateToMediaPickerPage(context, 1, typeImage, true, startPageGallery, true, (result) async {
            SelectedMediaFiles files = RuntimeProperties.selectedMediaFiles;
            if (result != true || files == null) {
              print('===============================???????????????');
              return;
            }
            if (fileList.isNotEmpty) {
              fileList.clear();
            }
            RuntimeProperties.selectedMediaFiles = null;
            MediaFileModel model = files.list.first;
            print(
                'model croppedImageData 1=========================${model.croppedImageData}  ${model.croppedImage}   ${model.file}');
            if (model != null) {
              print("????????????ByteData" + DateTime.now().millisecondsSinceEpoch.toString());
              ByteData byteData = await model.croppedImage.toByteData(format: ui.ImageByteFormat.png);
              print("????????????ByteData" + DateTime.now().millisecondsSinceEpoch.toString());
              Uint8List picBytes = byteData.buffer.asUint8List();
              print("????????????Uint8List" + DateTime.now().millisecondsSinceEpoch.toString());
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
                        )
                      : Container(
                          color: AppColor.imageBgGrey,
                        )),
            ),
            Positioned(
              bottom: 0,
              right: 4.5,
              child: AppIcon.getAppIcon(AppIcon.add_avatar_big, 25.5),
            ),
          ],
        ),
      ),
    );
  }

  ///?????????
  Widget _inputWidget() {
    return TextField(
      maxLength: maxTextLength,
      controller: controller,
      showCursor: true,
      style: AppStyle.whiteRegular16,
      cursorColor: AppColor.white,
      decoration: InputDecoration(
          hintText: _hintText,
          counterText: "",
          hintStyle: AppStyle.text1Regular16,
          suffixText: "$textLength/$maxTextLength",
          suffixStyle: AppStyle.text1Regular14,
          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(width: 0.5, color: AppColor.white.withOpacity(0.24))),
          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(width: 0.5, color: AppColor.white.withOpacity(0.24)))),
      inputFormatters: [ExpressionTeamDeleteFormatter(maxLength: maxTextLength, needFilter: true)],
    );
  }

  ///????????????
  Widget _perfectUserBtn() {
    FocusNode blankNode = FocusNode();
    return InkWell(
      onTap: () {
        FocusScope.of(context).requestFocus(blankNode);
        if(onClicking){
          return;
        }
        if (fileList.isNotEmpty && username != "") {
          setState(() {
            onClicking = true;
          });
          _upDataUserInfo();
        }
      },
      child: Container(
          width: width,
          height: 44,
          padding: EdgeInsets.only(left: 41, right: 41),
          decoration: BoxDecoration(
            color: fileList.isNotEmpty && username != "" ?AppColor.mainYellow:AppColor.mainYellow.withOpacity(0.4),
            borderRadius: BorderRadius.all(Radius.circular(3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Spacer(),
              onClicking
                  ? Container(
                      height: 17,
                      width: 17,
                      child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(AppColor.mainBlack),
                          backgroundColor: AppColor.mainBlack.withOpacity(0.16),
                          strokeWidth: 1.5))
                  : Container(),
              SizedBox(
                width: 2.5,
              ),
              Text(
                "??????",
                style:AppStyle.textRegular16,
              ),
              Spacer()
            ],
          )),
    );
  }

  _upDataUserInfo() async {
    String avataruri = "";
    print('=============================??????????????????');
    var results = await FileUtil().uploadPics(fileList, (percent) {
      print('===========================????????????');
    });
    avataruri = results.resultMap.values.first.url;
    _perfectUserInfo(context, avataruri, username);
  }

  //TODO ????????????????????????,????????????(????????????????????????????????????????????????????????????)
  _perfectUserInfo(BuildContext context, String portrait, String name) async {
    bool perfectResult = await perfectUserInfo(name, portrait);
    if (perfectResult) {
      //???????????????????????????????????????
      RuntimeProperties.smsCodeSendTime = null;
      print("????????????????????????");
      //?????????????????????token
      Loading.hideLoading(context);
      BaseResponseModel responseModel = await login("refresh_token", null, null, Application.tempToken.refreshToken);
      if (responseModel != null && responseModel.code == 200) {
        TokenModel token = TokenModel.fromJson(responseModel.data);
        print("????????????token??????");
        await _afterLogin(token, context);
      } else {
        ToastShow.show(msg: responseModel.message, context: context);
        print("????????????token??????");
      }
    } else {
      print("????????????????????????");
      Loading.hideLoading(context);
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/', (route) => false,
        //true ??????????????? false ???????????? ?????????RepeatLogin
        arguments: {},
      );
    }
    setState(() {
      onClicking = false;
    });
  }

  //TODO ?????????????????????????????? ???????????????????????? ?????????????????? ??????????????????????????? ?????????????????????
  _afterLogin(TokenModel token, BuildContext context) async {
    TokenDto tokenDto = TokenDto.fromTokenModel(token);
    await TokenDBHelper().insertToken(tokenDto);
    context.read<TokenNotifier>().setToken(tokenDto);
    //???????????????????????????????????????
    UserModel user = await getUserInfo();
    ProfileDto profile = ProfileDto.fromUserModel(user);
    await ProfileDBHelper().insertProfile(profile);
    context.read<ProfileNotifier>().setProfile(profile);
    context.read<UserInteractiveNotifier>().clearProfileUiChangeModel();
    //????????????
    Application.rongCloud.connect();
    //TODO ????????????????????????????????????
    MessageManager.loadConversationListFromDatabase(context);
    //???????????????????????????
    _getMoreInfo();
    EventBus.init().post(msg: true, registerName: AGAIN_LOGIN_REPLACE_LAYOUT);
    EventBus.init().post(registerName: SHOW_IMAGE_DIALOG);
    // ??????????????????????????????
    Application.topicBackgroundConfig.clear();
    DataResponseModel dataResponseModel = await getBackgroundConfig();
    if (dataResponseModel != null && dataResponseModel.list != null) {
      dataResponseModel.list.forEach((v) {
        Application.topicBackgroundConfig.add(TopicBackgroundConfigModel.fromJson(v));
      });
    }
    // ????????????????????????
    UmengCommonSdk.onProfileSignIn("${Application.profile.uid}");
    //??????????????????RegistrationID
    JPush().getRegistrationID().then((rid) {
      uploadDeviceId(rid);
    });
    AppRouter.navigateToLoginSucess(context);
  }

  _getMoreInfo() async {
    //todo ???????????????????????????
    try {
      List<MachineModel> machineList = await getMachineStatusInfo();
      if (machineList != null && machineList.isNotEmpty) {
        context.read<MachineNotifier>().setMachine(machineList.first);
      } else {
        context.read<MachineNotifier>().setMachine(null);
      }
    } catch (e) {}
    //todo ???????????????????????????????????????
    try {
      MessageManager.topChatModelList.clear();
      Map<String, dynamic> topChatModelMap = await getTopChatList();
      if (topChatModelMap != null && topChatModelMap["list"] != null) {
        topChatModelMap["list"].forEach((v) {
          MessageManager.topChatModelList.add(TopChatModel.fromJson(v));
        });
      }
    } catch (e) {}
    //todo ??????????????????????????????????????????
    try {
      MessageManager.queryNoPromptUidList.clear();
      Map<String, dynamic> queryNoPromptUidListMap = await queryNoPromptUidList();
      if (queryNoPromptUidListMap != null && queryNoPromptUidListMap["list"] != null) {
        queryNoPromptUidListMap["list"].forEach((v) {
          MessageManager.queryNoPromptUidList.add(NoPromptUidModel.fromJson(v));
        });
      }
    } catch (e) {}
  }
}
