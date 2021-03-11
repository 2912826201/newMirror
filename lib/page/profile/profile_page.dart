import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/api/user_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/profile/profile_model.dart';
import 'package:mirror/data/model/user_extrainfo_model.dart';
import 'package:mirror/data/model/user_model.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/page/profile/vip/vip_not_open_page.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/string_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/icon.dart';
import 'package:provider/provider.dart';
import 'profile_detail_page.dart';

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
  ScrollController controller = ScrollController();
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
      context.read<ProfileNotifier>().setExtraInfo(extraInfoModel);
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    super.build(context);
    context.watch<ProfilePageNotifier>().setFirstModel(context.watch<ProfileNotifier>().profile.uid);
    print('===============================我的页build');
    double width = ScreenUtil.instance.screenWidthDp;
    double height = ScreenUtil.instance.height;
    return Scaffold(
      appBar: null,
      body: SingleChildScrollView(
        controller: controller,
        physics: BouncingScrollPhysics(),
        child: _buildSuggestions(width, height),
      ),
    );
  }

  ///界面
  Widget _buildSuggestions(double width, double height) {
    return Column(
      children: [
        _blurrectAvatar(width, height),
        SizedBox(
          height: height * 0.05,
        ),
        Container(
          padding: EdgeInsets.only(left: 16, right: 16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: width * 0.27,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "训练计录",
                      style: AppStyle.textRegular12,
                    ),
                  ),
                  Spacer(),
                  Container(
                    width: width * 0.27,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "体重记录",
                      style: AppStyle.textRegular12,
                    ),
                  ),
                  Spacer(),
                  Container(
                    width: width * 0.27,
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
                  _secondData(Icons.timer, context.watch<ProfileNotifier>().trainingSeconds, "训练记录"),
                  Spacer(),
                  _secondData(Icons.poll, context.watch<ProfileNotifier>().weight, "体重记录"),
                  Spacer(),
                  _secondData(Icons.photo, context.watch<ProfileNotifier>().albumNum, "健身相册"),
                ],
              ),
              SizedBox(
                height: 28,
              ),
              _bottomSetting(Icon(Icons.menu_book), "我的课程"),
              _bottomSetting(Icon(Icons.article_outlined), "我的订单"),
              _bottomSetting(Icon(Icons.emoji_events_outlined), "我的成就"),
            ],
          ),
        ),
      ],
    );
  }

  ///这里设置高斯模糊和白蒙层
  Widget _blurrectAvatar(double width, double height) {
    return Stack(
      children: [
        Selector<ProfileNotifier, String>(builder: (context, avatar, child) {
          print("头像地址:$avatar");
          return CachedNetworkImage(
            height: height * 0.16,
            width: width,
            imageUrl: avatar!=null?avatar:"",
            fit: BoxFit.cover,
            placeholder: (context, url) => Image.asset(
              "images/test.png",
              fit: BoxFit.cover,
            ),
            errorWidget:(context, url, error) => Image.asset(
              "images/test.png",
              fit: BoxFit.cover,
            ),
          );
        }, selector: (context, notifier) {
          return notifier.profile.avatarUri;
        }),
        Positioned(
            child: Container(
          width: width,
          height: height * 0.16,
          color: AppColor.white.withOpacity(0.6),
        )),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),

          ///这里是顶部appbar和头像关注
          child: Container(
            height: height * 0.11 + 61 + ScreenUtil.instance.statusBarHeight,
            child: Column(
              children: [
                SizedBox(
                  height: ScreenUtil.instance.statusBarHeight,
                ),
                _getTopText(width, height),
                SizedBox(
                  height: 17,
                ),
                _getUserImage(height, width),
              ],
            ),
          ),
        ),
      ],
    );
  }

  ///这是扫一扫
  Widget _getTopText(double width, double height) {
    return Container(
      padding: const EdgeInsets.only(
          left: CustomAppBar.appBarHorizontalPadding, right: CustomAppBar.appBarHorizontalPadding),
      height: CustomAppBar.appBarHeight,
      width: width,
      child: Center(
          child: Row(
        children: [
          CustomAppBarIconButton(
              svgName: AppIcon.qrcode_scan,
              iconColor: AppColor.black,
              onTap: () {
                AppRouter.navigateToScanCodePage(context);
              }),
          Spacer(),
          CustomAppBarIconButton(
              icon: Icons.menu,
              iconColor: AppColor.black,
              onTap: () {
                AppRouter.navigateToSettingHomePage(context);
              }),
        ],
      )),
    );
  }

  Widget _bottomSetting(Icon icon, String text) {
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
              Expanded(child: Container()),
              Icon(Icons.arrow_forward_ios)
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
  Widget _getUserImage(double height, double width) {
    return Container(
        height: height * 0.11,
        padding: EdgeInsets.only(left: 16, right: 16),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              child: _imgAvatar(height, width),
            ),
            Positioned(
                left: width * 0.38,
                bottom: 0,
                child: Row(children: [
                  InkWell(
                    child: _textAndNumber(
                        "关注",
                        StringUtil.getNumber(context
                            .watch<ProfilePageNotifier>()
                            .profileUiChangeModel[context.watch<ProfileNotifier>().profile.uid]
                            .attentionModel
                            .followingCount)),
                    onTap: () {
                      AppRouter.navigateToQueryFollowList(context, 1, context.read<ProfileNotifier>().profile.uid);
                    },
                  ),
                  SizedBox(
                    width: width * 0.12,
                  ),
                  InkWell(
                    onTap: () {
                      AppRouter.navigateToQueryFollowList(context, 2, context.read<ProfileNotifier>().profile.uid);
                    },
                    child: _textAndNumber(
                        "粉丝",
                        StringUtil.getNumber(context
                            .watch<ProfilePageNotifier>()
                            .profileUiChangeModel[context.watch<ProfileNotifier>().profile.uid]
                            .attentionModel
                            .followerCount)),
                  ),
                  SizedBox(
                    width: width * 0.12,
                  ),
                  InkWell(
                    onTap: () {
                      AppRouter.navigateToMineDetail(context, context.read<ProfileNotifier>().profile.uid);
                    },
                    child: _textAndNumber(
                        "动态",
                        StringUtil.getNumber(context
                            .watch<ProfilePageNotifier>()
                            .profileUiChangeModel[context.watch<ProfileNotifier>().profile.uid]
                            .attentionModel
                            .feedCount)),
                  )
                ]))
          ],
        ));
  }

  ///这是头像
  Widget _imgAvatar(double height, double width) {
    return Container(
      width: height * 0.11,
      height: height * 0.11,
      child: InkWell(
          onTap: () {
            AppRouter.navigateToMineDetail(context, context.read<ProfileNotifier>().profile.uid);
          },
          child: Stack(
            children: [
              Selector<ProfileNotifier, String>(builder: (context, avatar, child) {
                print("头像地址:$avatar");
                return Hero(
                    tag: "我的头像",
                    child: ClipOval(
                      child: CachedNetworkImage(
                        height: height * 0.11,
                        width: height * 0.11,
                        imageUrl: avatar == null ? "" : avatar,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Image.asset(
                          "images/test.png",
                          fit: BoxFit.cover,
                        ),
                        errorWidget: (context, url, error) => Image.asset(
                          "images/test.png",
                          fit: BoxFit.cover,
                        ),
                      ),
                    ));
              }, selector: (context, notifier) {
                return notifier.profile.avatarUri;
              }),
            ],
          )),
    );
  }

  ///这里是关注粉丝动态
  Widget _textAndNumber(String text, String number) {
    print('__________________________$number');
    return Column(
      children: [
        Center(
          child: Text(
            number,
            style: AppStyle.textMedium18,
          ),
        ),
        Center(
          child: Text(
            text,
            style: AppStyle.textRegular12,
          ),
        )
      ],
    );
  }

  ///这里是训练计划，体重记录，健身相册的
  ///                这是中间的图标| 这是数值   |这是title
  Widget _secondData(IconData icon, number, String text) {
    var _userPlate = Stack(
      children: [
        Container(
          height: ScreenUtil.instance.screenWidthDp * 0.27,
          width: ScreenUtil.instance.screenWidthDp * 0.27,
          color: AppColor.bgWhite,
        ),
        Container(
          height: ScreenUtil.instance.screenWidthDp * 0.27,
          width: ScreenUtil.instance.screenWidthDp * 0.27,
          child: Center(
            child: Column(
              children: [
                Expanded(
                  child: SizedBox(),
                  flex: 2,
                ),
                Icon(
                  icon,
                  size: 24,
                ),
                SizedBox(
                  height: 8,
                ),
                Text(
                  number != 0 && number != null ? "$number" : "--",
                  style: AppStyle.textRegular14,
                ),
                Expanded(
                  child: SizedBox(),
                  flex: 3,
                ),
              ],
            ),
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
  void onClickListener(String title) {
    if ("训练记录" == title) {
      AppRouter.navigateToTrainingRecordPage(context);
    } else if ("体重记录" == title) {
      AppRouter.navigateToWeightRecordPage(context);
    } else if ("健身相册" == title) {
      AppRouter.navigateToTrainingGalleryPage(context);
    } else if ("我的课程" == title) {
      AppRouter.navigateToMeCoursePage(context);
    } else if ("我的订单" == title) {
      /*ScanCodeResultModel model = ScanCodeResultModel();
      model.type = ScanCodeResultType.CODE_INVALID;
      AppRouter.navigateToScanCodeResultPage(context, model);*/
      if (userModel.isVip != 0) {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return VipNotOpenPage(type: VipState.NOTOPEN);
        }));
      } else {
        AppRouter.navigateToVipOpenPage(context);
      }
    }
  }
}
