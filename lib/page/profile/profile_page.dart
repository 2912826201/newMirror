import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/user_extrainfo_model.dart';
import 'package:mirror/data/model/user_model.dart';
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
  double avatarSize = 87;

  //关注，粉丝，点赞三块的尺寸
  double userDetaileIconSize = 73;

  //头像和按钮的row的高度
  double userAvatarAndButtonHeight = 100.5;

  //整个资料版高度
  double pageHeaderHeight;

  //高斯模糊高度
  double gaussianBlurHeight;
  ScrollController controller = ScrollController();
  double width = ScreenUtil.instance.width;
  double height = ScreenUtil.instance.height;

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
    pageHeaderHeight = ScreenUtil.instance.statusBarHeight + CustomAppBar.appBarHeight + 17 + userAvatarAndButtonHeight;
    gaussianBlurHeight = ScreenUtil.instance.statusBarHeight + CustomAppBar.appBarHeight + 45;
    getProfileModel();
    controller.addListener(() {
      if (controller.position.maxScrollExtent < controller.offset) {
        controller.animateTo(0, duration: Duration(milliseconds: 500), curve: Curves.ease);
      }
    });
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
          height: 28,
        ),
        Container(
          padding: EdgeInsets.only(left: 16, right: 16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: (width - 65) / 3,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "训练记录",
                      style: AppStyle.textRegular12,
                    ),
                  ),
                  SizedBox(
                    width: 16.5,
                  ),
                  Container(
                    width: (width - 65) / 3,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "体重记录",
                      style: AppStyle.textRegular12,
                    ),
                  ),
                  SizedBox(
                    width: 16.5,
                  ),
                  Container(
                    width: (width - 65) / 3,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "健身相册",
                      style: AppStyle.textRegular12,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 8,
              ),
              Row(
                children: [
                  _secondData(
                      AppIcon.getAppIcon(AppIcon.profile_record, 18),
                      DateTime.fromMillisecondsSinceEpoch(context.watch<ProfileNotifier>().trainingSeconds).minute,
                      "训练记录"),
                  Spacer(),
                  _secondData(
                      AppIcon.getAppIcon(AppIcon.profile_weight, 18), context.watch<ProfileNotifier>().weight, "体重记录"),
                  Spacer(),
                  _secondData(AppIcon.getAppIcon(AppIcon.profile_gallery, 18),
                      context.watch<ProfileNotifier>().albumNum, "健身相册"),
                ],
              ),
              SizedBox(
                height: 28,
              ),
              _bottomSetting(AppIcon.getAppIcon(AppIcon.profile_course, 24), "我的课程"),
              // _bottomSetting(AppIcon.getAppIcon(AppIcon.profile_course, 24), "测试"),
              Platform.isIOS ? _bottomSetting(AppIcon.getAppIcon(AppIcon.profile_course, 24), "融云") : Container()
              // _bottomSetting(AppIcon.getAppIcon(AppIcon.profile_order, 24), "我的订单"),,
              /*
              _bottomSetting(AppIcon.getAppIcon(AppIcon.profile_achievement, 24), "我的成就"),*/
            ],
          ),
        ),
      ],
    );
  }

  ///这里设置高斯模糊和白蒙层
  Widget _blurrectAvatar() {
    return Container(
      height: pageHeaderHeight,
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
            clipBehavior: Clip.hardEdge,
            // note Container 的属性clipBehavior不为Clip.none需要设置decoration不然会崩溃
            decoration: BoxDecoration(),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),

              ///这里是顶部appbar和头像关注
              child: Container(
                height: pageHeaderHeight,
                child: Column(
                  children: [
                    SizedBox(
                      height: ScreenUtil.instance.statusBarHeight,
                    ),
                    _getTopText(),
                    SizedBox(
                      height: 17,
                    ),
                    _getUserImage(),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  ///这是扫一扫
  Widget _getTopText() {
    return Container(
      padding: const EdgeInsets.only(
          left: CustomAppBar.appBarHorizontalPadding, right: CustomAppBar.appBarHorizontalPadding),
      height: CustomAppBar.appBarHeight,
      width: width,
      child: Center(
        child: Row(
          children: [
            CustomAppBarIconButton(
                svgName: AppIcon.nav_scan,
                iconColor: AppColor.black,
                onTap: () {
                  Permission.camera.request().then((value) {
                    if (value.isGranted) {
                      AppRouter.navigateToScanCodePage(context, showMyCode: true);
                    }
                  });
                }),
            Spacer(),
            CustomAppBarIconButton(
                svgName: AppIcon.nav_settings,
                iconColor: AppColor.black,
                onTap: () {
                  AppRouter.navigateToSettingHomePage(context);
                }),
          ],
        ),
      ),
    );
  }

  Widget _bottomSetting(Widget icon, String text) {
    return GestureDetector(
      child: Container(
        color: AppColor.transparent,
        height: 48,
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
    return Container(
        height: userAvatarAndButtonHeight,
        width: width,
        padding: EdgeInsets.only(left: 16, right: 16),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              child: _imgAvatar(),
            ),
            Positioned(
                right: 0,
                bottom: 0,
                child: Row(children: [
                  InkWell(
                    child: _textAndNumber(
                        "关注",
                        StringUtil.getNumber(context
                            .watch<UserInteractiveNotifier>()
                            .value
                            .profileUiChangeModel[context.watch<ProfileNotifier>().profile.uid]
                            .attentionModel
                            .followingCount)),
                    onTap: () {
                      AppRouter.navigateToQueryFollowList(context, 1, context.read<ProfileNotifier>().profile.uid);
                    },
                  ),
                  InkWell(
                    onTap: () {
                      AppRouter.navigateToQueryFollowList(context, 2, context.read<ProfileNotifier>().profile.uid);
                    },
                    child: _textAndNumber(
                        "粉丝",
                        StringUtil.getNumber(context
                            .watch<UserInteractiveNotifier>()
                            .value
                            .profileUiChangeModel[context.watch<ProfileNotifier>().profile.uid]
                            .attentionModel
                            .followerCount)),
                  ),
                  InkWell(
                    onTap: () {
                      jumpToUserProfilePage(context, context.read<ProfileNotifier>().profile.uid,
                          avatarUrl: context.read<ProfileNotifier>().profile.avatarUri,
                          userName: context.read<ProfileNotifier>().profile.nickName);
                    },
                    child: _textAndNumber(
                        "动态",
                        StringUtil.getNumber(context
                            .watch<UserInteractiveNotifier>()
                            .value
                            .profileUiChangeModel[context.watch<ProfileNotifier>().profile.uid]
                            .attentionModel
                            .feedCount)),
                  )
                ]))
          ],
        ));
  }

  ///这是头像
  Widget _imgAvatar() {
    return Container(
      width: avatarSize,
      height: avatarSize,
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
                  height: avatarSize,
                  width: avatarSize,
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
      fansCountSize = calculateTextWidth(number, AppStyle.textMedium18, userDetaileIconSize, 1).size;
    }
    return Container(
      height: userDetaileIconSize,
      width: userDetaileIconSize,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
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
    if ("训练记录" == title) {
      AppRouter.navigateToTrainingRecordPage(context);
    } else if ("体重记录" == title) {
      AppRouter.navigateToWeightRecordPage(context);
    } else if ("健身相册" == title) {
      AppRouter.navigateToTrainingGalleryPage(context);
    } else if ("我的课程" == title) {
      AppRouter.navigateToMeCoursePage(context);
    } else if ("我的订单" == title) {
      AppRouter.navigateToHeightAndWeigetPage(context);
      // AppRouter.navigateToVipPage(context, VipState.RENEW, openOrNot: true);
    } else if ("测试" == title) {
      showImageDialog(context, onClickListener: () {
        AppRouter.navigateNewUserPromotionPage(context);
      });
      // List<MachineModel> machineList = await getMachineStatusInfo();
      // if (machineList != null && machineList.isNotEmpty) {
      //   context.read<MachineNotifier>().setMachine(machineList.first);
      // } else {
      //   context.read<MachineNotifier>().setMachine(null);
      // }
    } else if ("融云" == title) {
      AppRouter.navigateToRCTestPage(context, context.read<ProfileNotifier>().profile);
    }
  }
}
