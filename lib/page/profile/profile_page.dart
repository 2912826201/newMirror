import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
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
import 'package:mirror/route/router.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/string_util.dart';
import 'package:mirror/util/text_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/dialog_image.dart';
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
    _getNewVersion();
    controller.addListener(() {
      if (controller.position.maxScrollExtent < controller.offset) {
        controller.animateTo(0, duration: Duration(milliseconds: 500), curve: Curves.ease);
      }
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

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    super.build(context);
    context.watch<UserInteractiveNotifier>().setFirstModel(context.watch<ProfileNotifier>().profile.uid);
    print('===============================我的页build');

    return Scaffold(
      appBar: null,
      body: SingleChildScrollView(
        controller: controller,
        physics: BouncingScrollPhysics(),
        child: _buildSuggestions(),
      ),
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
        _bottomSetting(AppIcon.getAppIcon(AppIcon.nav_scan, 24), "扫一扫"),
        _bottomSetting(AppIcon.getAppIcon(AppIcon.profile_course, 24), "关于"),
        _bottomSetting(AppIcon.getAppIcon(AppIcon.profile_course, 24), "意见反馈"),
        _bottomSetting(AppIcon.getAppIcon(AppIcon.profile_course, 24), "设置"),
        Platform.isIOS ? _bottomSetting(AppIcon.getAppIcon(AppIcon.profile_course, 24), "融云") : Container()
        // _bottomSetting(AppIcon.getAppIcon(AppIcon.profile_order, 24), "我的订单"),,
        /*
     _bottomSetting(AppIcon.getAppIcon(AppIcon.profile_achievement, 24), "我的成就"),*/
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
                color: AppColor.bgWhite,
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
    return Container(
      height: gaussianBlurHeight + 72,
      width: width,
      child: Stack(
        children: [
          Selector<ProfileNotifier, String>(builder: (context, avatar, child) {
            print("头像地址:$avatar");
            return CachedNetworkImage(
              height: gaussianBlurHeight,
              width: width,
              imageUrl: avatar != null ? avatar : "",
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: AppColor.bgWhite,
              ),
              errorWidget: (context, url, error) => Container(
                color: AppColor.bgWhite,
              ),
            );
          }, selector: (context, notifier) {
            return notifier.profile.avatarUri;
          }),
          Positioned(
              child: Container(
            width: width,
            height: gaussianBlurHeight,
            color: AppColor.white.withOpacity(0.6),
          )),
          Container(
            width: width,
            height: gaussianBlurHeight + 72,
            clipBehavior: Clip.hardEdge,
            // note Container 的属性clipBehavior不为Clip.none需要设置decoration不然会崩溃
            decoration: BoxDecoration(),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
              child: Container(
                height: gaussianBlurHeight,
                child: Column(
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
            ),
          )
        ],
      ),
    );
  }

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

  ///这里因为头像和关注等是水平，所以放在一起
  Widget _getUserImage() {
    double nameMaxWidth = width - userAvatarHeight - 12 - 24 - 49 - 32;
    double textWidth =
        calculateTextWidth(context.watch<ProfileNotifier>().profile.nickName, AppStyle.textMedium18, nameMaxWidth, 1)
            .width;
    if (textWidth > nameMaxWidth) {
      textWidth = nameMaxWidth;
    }
    return Container(
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
            Container(
              width: textWidth,
              child: Text(
                context.watch<ProfileNotifier>().profile.nickName,
                style: AppStyle.textMedium18,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            Container(
              height: 24,
              width: 24,
              color: AppColor.bgBlack,
            ),
          ],
        ));
  }

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

  ///这是头像
  Widget _imgAvatar() {
    return Container(
      width: userAvatarHeight,
      height: userAvatarHeight,
      child: InkWell(
        onTap: () {
          jumpToUserProfilePage(context, context.read<ProfileNotifier>().profile.uid,
              avatarUrl: context.read<ProfileNotifier>().profile.avatarUri,
              userName: context.read<ProfileNotifier>().profile.nickName);
        },
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

  ///这里是训练计划，体重记录，健身相册的
  ///                这是中间的图标| 这是数值   |这是title
  Widget _secondData(Widget icon, number, String text) {
    var _userPlate = Stack(
      children: [
        Container(
          height: (width - 65) / 3,
          width: (width - 65) / 3,
          color: AppColor.bgWhite,
        ),
        Container(
          height: (width - 65) / 3,
          width: (width - 65) / 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 22,
              ),
              icon,
              SizedBox(
                height: 6.5,
              ),
              Text(
                number != 0 && number != null ? "$number" : "--",
                style: AppStyle.textRegular14,
              ),
            ],
          ),
        )
      ],
    );
    return GestureDetector(
      child: _userPlate,
      onTap: () {
        onClickListener(text);
      },
    );
  }

  //点击事件Training record
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
      case "扫码":
        Permission.camera.request().then((value) {
          if (value.isGranted) {
            AppRouter.navigateToScanCodePage(context, showMyCode: true);
          }
        });
        break;
      case "设置":
        AppRouter.navigateToSettingHomePage(context);
        break;
      case "测试":
        break;
      case "融云":
        AppRouter.navigateToRCTestPage(context, context.read<ProfileNotifier>().profile);
        break;
    }
  }
}
