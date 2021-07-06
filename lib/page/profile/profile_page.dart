// import 'dart:html';
import 'dart:async';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/api/version_api.dart';
import 'package:mirror/config/config.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/user_extrainfo_model.dart';
import 'package:mirror/data/model/user_model.dart';
import 'package:mirror/data/model/version_model.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/notifier/user_interactive_notifier.dart';
import 'package:mirror/page/profile/profile_detail_page.dart';
import 'package:mirror/page/scan_code/scan_code_page.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/string_util.dart';
import 'package:mirror/util/text_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/icon.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class DefaultImage {
  static String nodata = "assets/png/default_no_data.png";
  static String error = "assets/png/default_error.png";
  static String offline = "assets/png/default_offline.png";
}

class ProfilePage extends StatefulWidget {
  ProfilePage({Key key}) : super(key: key);

  @override
  ProfileState createState() => new ProfileState();
}

class ProfileState extends State<ProfilePage> with AutomaticKeepAliveClientMixin {
  int followingCount;
  int followerCount;
  int feedCount;
  UserModel userModel;

  //头像的高度
  double userAvatarHeight = 71;

  //高斯模糊高度
  double gaussianBlurHeight;
  ScrollController controller = ScrollController();
  double width = ScreenUtil.instance.width;
  double height = ScreenUtil.instance.height;
  bool haveNewVersion = false;
  String content;
  String url;
  StreamController<double> streamController = StreamController<double>();
  double beforOffset;
  double totalOffset;
  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    gaussianBlurHeight = ScreenUtil.instance.statusBarHeight + CustomAppBar.appBarHeight + 12 + userAvatarHeight;
    getProfileModel();
    if (!AppConfig.needShowTraining) _getNewVersion();
    controller.addListener(() {
      // print('我的页滚动=====================${controller.offset}');

    });
  }

  _getNewVersion() async {
    VersionModel model = await getNewVersion();
    if (model != null) {
      if (model.version != AppConfig.version) {
        haveNewVersion = true;
        content = model.description;
        url = model.url;
        if (mounted) {
          setState(() {});
        }
      }
    }
  }

  getProfileModel() async {
    UserExtraInfoModel extraInfoModel = await ProfileGetExtraInfo();
    if (extraInfoModel != null) {
      Future.delayed(Duration.zero, () {
        context.read<ProfileNotifier>().setExtraInfo(extraInfoModel);
      });
    }
  }


  bool notificationListener(ScrollNotification notification){
    print('-------------------${notification.metrics.axis}');
    print('-------------------${notification.metrics.pixels}');
    print('-------------------${notification.metrics.pixels}');
    return false;
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    super.build(context);
    context.watch<UserInteractiveNotifier>().setFirstModel(context.watch<ProfileNotifier>().profile.uid);
    print('===============================我的页build');

    return Scaffold(
      appBar: null,
      backgroundColor: AppColor.white,
      body:  Listener(
        // onNotification:notificationListener,
        onPointerDown: (PointerDownEvent event){
          beforOffset = event.position.dy;
        },
        onPointerUp: (PointerUpEvent event){
          beforOffset = null;
          streamController.sink.add(0);
        },
        onPointerMove: (PointerMoveEvent event){
          print('--------------------${event.position.dy}');
          if(beforOffset < event.position.dy){
            print('----------------------向下');
            double offset = event.position.dy-beforOffset;
            if(offset>200){
             return;
            }
            streamController.sink.add(offset);
          }
        },
        child: SingleChildScrollView(
        controller: controller,
        physics: ClampingScrollPhysics(),
        child: _buildSuggestions(),
      ),),
    );
  }

  ///界面
  Widget _buildSuggestions() {
    return Column(
      children: [
        _blurrectAvatar(),
        SizedBox(
          height: 20,
        ),
        Container(
          padding: EdgeInsets.only(left: 16, right: 16),
          child: Row(
            children: [
              if (AppConfig.needShowTraining)
                _secondRecordData("训练记录", context.watch<ProfileNotifier>().trainingSeconds,
                    AppIcon.getAppIcon(AppIcon.profile_record, 18)),
              if (AppConfig.needShowTraining)
                SizedBox(
                  width: 16,
                ),
              _secondRecordData(
                  "体重记录", context.watch<ProfileNotifier>().weight, AppIcon.getAppIcon(AppIcon.profile_weight, 18)),
              SizedBox(
                width: 16,
              ),
              _secondRecordData(
                  "健身相册", context.watch<ProfileNotifier>().albumNum, AppIcon.getAppIcon(AppIcon.profile_gallery, 18)),
            ],
          ),
        ),
        SizedBox(
          height: 36,
        ),
        if (AppConfig.needShowTraining) _bottomSetting(AppIcon.getAppIcon(AppIcon.profile_course, 24), "我的课程"),
        _bottomSetting(AppIcon.getAppIcon(AppIcon.profile_scan, 24), "扫一扫"),
        if (!AppConfig.needShowTraining) _bottomSetting(AppIcon.getAppIcon(AppIcon.profile_about, 24), "关于"),
        if (!AppConfig.needShowTraining) _bottomSetting(AppIcon.getAppIcon(AppIcon.profile_feedback, 24), "意见反馈"),
        _bottomSetting(AppIcon.getAppIcon(AppIcon.profile_setting, 24), "设置"),
        // Platform.isIOS ? _bottomSetting(AppIcon.getAppIcon(AppIcon.profile_course, 24), "融云") : Container()
        // _bottomSetting(AppIcon.getAppIcon(AppIcon.profile_order, 24), "我的订单"),,
        /*
     _bottomSetting(AppIcon.getAppIcon(AppIcon.profile_achievement, 24), "我的成就"),*/
        if (AppConfig.env == Env.DEV) _bottomSetting(AppIcon.getAppIcon(AppIcon.profile_course, 24), "测试"),
      ],
    );
  }

  Widget _secondRecordData(String title, num number, Widget icons) {
    double boxWidth;
    boxWidth = (width - 16 * 3) / 2;
    if (AppConfig.needShowTraining) boxWidth = (width - 16 * 4) / 3;
    return InkWell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$title",
            style: AppStyle.textMedium14,
          ),
          SizedBox(
            height: 7.5,
          ),
          Stack(
            children: [
              Container(
                height: (width - 65) / 3,
                width: boxWidth,
                child: Image.asset(
                  "assets/png/training_bg.png",
                  fit: BoxFit.cover,
                  height: (width - 65) / 3,
                  width: boxWidth,
                ),
              ),
              Container(
                height: (width - 65) / 3,
                width: boxWidth,
                padding: AppConfig.needShowTraining ? EdgeInsets.all(0) : EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: AppConfig.needShowTraining ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                  children: [
                    if (AppConfig.needShowTraining)
                      SizedBox(
                        height: 22,
                      ),
                    AppConfig.needShowTraining
                        ? icons
                        : Text(
                            number != 0 && number != null ? "$number" : "--",
                            style: AppStyle.textRegular14,
                          ),
                    SizedBox(
                      height: AppConfig.needShowTraining ? 6.5 : 31,
                    ),
                    AppConfig.needShowTraining
                        ? Text(
                            number != 0 && number != null ? "$number" : "--",
                            style: AppStyle.textRegular14,
                          )
                        : icons,
                  ],
                ),
              )
            ],
          )
        ],
      ),
      onTap: () {
        onClickListener(title);
      },
    );
  }

  ///这里设置高斯模糊和白蒙层
  Widget _blurrectAvatar() {
    return StreamBuilder<double>(
        initialData: 0,
        stream: streamController.stream,
        builder: (BuildContext stramContext, AsyncSnapshot<double> snapshot) {
          return AnimatedContainer(
            duration: Duration(milliseconds: snapshot.data==0?250:1),
            curve: Curves.linear,
            height: gaussianBlurHeight + 72 + snapshot.data,
            child: Container(
              height: gaussianBlurHeight + 72 + snapshot.data,
              width: width,
              child: Stack(
                children: [
                  Selector<ProfileNotifier, String>(builder: (context, avatar, child) {
                    print("头像地址:$avatar");
                    return AnimatedContainer(
                        duration: Duration(milliseconds: snapshot.data==0?250:1),
                    curve: Curves.linear,
                    height: gaussianBlurHeight +  snapshot.data,
                    child: CachedNetworkImage(
                      height: gaussianBlurHeight + snapshot.data,
                      width: width,
                      imageUrl: avatar != null ? avatar : "",
                      fit: BoxFit.none,
                      placeholder: (context, url) => Container(
                        color: AppColor.bgWhite,
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppColor.bgWhite,
                      ),
                    ));
                  }, selector: (context, notifier) {
                    return notifier.profile.avatarUri;
                  }),
                  Positioned(
                      child: AnimatedContainer(
                          duration: Duration(milliseconds: snapshot.data==0?250:1),
                          curve: Curves.linear,
                          height: gaussianBlurHeight +  snapshot.data,
                          child: Container(
                    width: width,
                    height: gaussianBlurHeight + snapshot.data,
                    color: AppColor.white.withOpacity(0.6),
                  ))),
              AnimatedContainer(
                duration: Duration(milliseconds: snapshot.data==0?250:1),
                curve: Curves.linear,
                height: gaussianBlurHeight + 72 +  snapshot.data,
                child:Container(
                    width: width,
                    height: gaussianBlurHeight + 72 + snapshot.data,
                    clipBehavior: Clip.hardEdge,
                    // note Container 的属性clipBehavior不为Clip.none需要设置decoration不然会崩溃
                    decoration: BoxDecoration(),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SizedBox(
                              height: ScreenUtil.instance.statusBarHeight,
                            ),
                            SizedBox(
                              height: CustomAppBar.appBarHeight,
                            ),
                            SizedBox(
                              height: 12,
                            ),
                            _getUserImage(),
                            SizedBox(
                              height: 12,
                            ),
                            _userFollowRow(),
                          ],
                        ),
                    ),
                  ))
                ],
              ),
            ),
          );
        });
  }

  //底部功能列表
  Widget _bottomSetting(Widget icon, String text) {
    return GestureDetector(
      child: Container(
        color: AppColor.transparent,
        height: 48,
        margin: EdgeInsets.only(left: 16, right: 16),
        child: Center(
          child: Row(
            children: [
              icon,
              SizedBox(
                width: 12,
              ),
              Text(
                text,
                style: AppStyle.textRegular16,
              ),
              Spacer(),
              text == "关于" && haveNewVersion
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 64,
                        height: 18,
                        color: AppColor.mainRed,
                        child: Center(
                          child: Text(
                            "有新版本",
                            style: AppStyle.whiteRegular12,
                          ),
                        ),
                      ),
                    )
                  : Container(),
              SizedBox(
                width: 12,
              ),
              AppIcon.getAppIcon(
                AppIcon.arrow_right_18,
                18,
                color: AppColor.textHint,
              ),
            ],
          ),
        ),
      ),
      onTap: () {
        onClickListener(text);
      },
    );
  }

  //头像昵称
  Widget _getUserImage() {
    return InkWell(
      onTap: () {
        jumpToUserProfilePage(context, context.read<ProfileNotifier>().profile.uid,
            avatarUrl: context.read<ProfileNotifier>().profile.avatarUri,
            userName: context.read<ProfileNotifier>().profile.nickName);
      },
      child: Container(
          height: userAvatarHeight,
          width: width,
          padding: EdgeInsets.only(left: 16, right: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _imgAvatar(),
              SizedBox(
                width: 12,
              ),
              Expanded(
                child: Text(
                  context.watch<ProfileNotifier>().profile.nickName,
                  style: AppStyle.textMedium18,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              SizedBox(
                width: 72.5,
              )
            ],
          )),
    );
  }

  //关注，粉丝，动态数
  Widget _userFollowRow() {
    return Container(
      child: Row(children: [
        _textAndNumber(
            "关注",
            StringUtil.getNumber(context
                .watch<UserInteractiveNotifier>()
                .value
                .profileUiChangeModel[context.watch<ProfileNotifier>().profile.uid]
                .attentionModel
                .followingCount)),
        _textAndNumber(
            "粉丝",
            StringUtil.getNumber(context
                .watch<UserInteractiveNotifier>()
                .value
                .profileUiChangeModel[context.watch<ProfileNotifier>().profile.uid]
                .attentionModel
                .followerCount)),
        _textAndNumber(
            "动态",
            StringUtil.getNumber(context
                .watch<UserInteractiveNotifier>()
                .value
                .profileUiChangeModel[context.watch<ProfileNotifier>().profile.uid]
                .attentionModel
                .feedCount)),
      ]),
    );
  }

  ///这是头像+
  Widget _imgAvatar() {
    return Container(
      width: userAvatarHeight,
      height: userAvatarHeight,
      child: Stack(
        children: [
          Selector<ProfileNotifier, String>(builder: (context, avatar, child) {
            print("头像地址:$avatar");
            return ClipOval(
              child: CachedNetworkImage(
                useOldImageOnUrlChange: true,
                height: userAvatarHeight,
                width: userAvatarHeight,
                memCacheWidth: 250,
                memCacheHeight: 250,
                imageUrl: avatar != null ? FileUtil.getMediumImage(avatar) : " ",
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppColor.bgWhite,
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppColor.bgWhite,
                ),
              ),
            );
          }, selector: (context, notifier) {
            return notifier.profile.avatarUri;
          }),
        ],
      ),
    );
  }

  ///这里是关注粉丝动态
  Widget _textAndNumber(String text, String number) {
    print('__________________________$number');
    Size fansCountSize;
    if (text == "粉丝") {
      fansCountSize = calculateTextWidth(number, AppStyle.textMedium18, width / 3, 1).size;
    }
    return InkWell(
      child: Container(
        height: 60,
        width: width / 3,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                Container(
                  width: text == "粉丝" ? fansCountSize.width + 6 : null,
                  child: Text(
                    number,
                    style: AppStyle.textMedium18,
                  ),
                ),
                Consumer<UserInteractiveNotifier>(builder: (context, notifier, child) {
                  return Positioned(
                      top: 0,
                      right: 0,
                      child: notifier.value.fansUnreadCount > 0 && text == "粉丝"
                          ? ClipOval(
                              child: Container(
                                height: 8,
                                width: 8,
                                color: AppColor.mainRed,
                              ),
                            )
                          : Container());
                })
              ],
            ),
            SizedBox(
              height: 2,
            ),
            Text(
              text,
              style: AppStyle.textRegular12,
            ),
          ],
        ),
      ),
      onTap: () {
        onClickListener(text);
      },
    );
  }

  //点击事件
  void onClickListener(String title) async {
    switch (title) {
      case "关注":
        AppRouter.navigateToQueryFollowList(context, 1, context.read<ProfileNotifier>().profile.uid);
        break;
      case "粉丝":
        AppRouter.navigateToQueryFollowList(context, 2, context.read<ProfileNotifier>().profile.uid);
        break;
      case "动态":
        jumpToUserProfilePage(context, context.read<ProfileNotifier>().profile.uid,
            avatarUrl: context.read<ProfileNotifier>().profile.avatarUri,
            userName: context.read<ProfileNotifier>().profile.nickName);
        break;
      case "训练记录":
        AppRouter.navigateToTrainingRecordPage(context);
        break;
      case "体重记录":
        AppRouter.navigateToWeightRecordPage(context);
        break;
      case "健身相册":
        AppRouter.navigateToTrainingGalleryPage(context);
        break;
      case "我的课程":
        AppRouter.navigateToMeCoursePage(context);
        break;
      case "我的订单":
        AppRouter.navigateToHeightAndWeigetPage(context);
        break;
      case "意见反馈":
        AppRouter.navigateToSettingFeedBack(context);
        break;
      case "关于":
        AppRouter.navigateToSettingAbout(context, url, haveNewVersion, content);
        break;
      case "扫一扫":
        gotoScanCodePage(context, showMyCode: true);
        break;
      case "设置":
        AppRouter.navigateToSettingHomePage(context);
        break;
      case "测试":
        /*jumpChatPageSystem(context);*/
        // showToast("这个flutter告诉android要展示的内容");
        AppRouter.navigateToTestPage(context);
        break;
      case "融云":
        AppRouter.navigateToRCTestPage(context, context.read<ProfileNotifier>().profile);
        break;
    }
  }
}
