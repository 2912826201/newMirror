import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/profile/profile_model.dart';
import 'package:mirror/data/model/user_extrainfo_model.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/page/profile/fitness_information_entry/height_and_weight_page.dart';
import 'package:mirror/page/profile/query_list/query_follow_list.dart';
import 'package:mirror/page/vip/vip_not_open_page.dart';
import 'package:mirror/page/vip/vip_open_page.dart';

import 'package:mirror/route/router.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/string_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'profile_detail_page.dart';

enum ActionItems { DENGCHU, DENGLU }

class ProfilePage extends StatefulWidget {
  ProfilePage({Key key}) : super(key: key);

  @override
  ProfileState createState() => new ProfileState();
}

class ProfileState extends State<ProfilePage> with AutomaticKeepAliveClientMixin {
  int uid;
  int followingCount;
  int followerCount;
  int feedCount;
  int trainingSeconds;
  double weight;
  int albumNum;

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
  }

  getProfileModel() async {
    ProfileModel attentionModel = await ProfileFollowCount();
    UserExtraInfoModel extraInfoModel = await ProfileGetExtraInfo();
    print('resultModel============================${attentionModel == null}');
    if (attentionModel != null || extraInfoModel != null) {
      print('uid========================${attentionModel.uid}'
          'followingCount============================${attentionModel.followingCount}'
          'feedCount==========${attentionModel.feedCount}'
          'followerCount=======${attentionModel.followerCount}');
      setState(() {
        uid = attentionModel.uid;
        followingCount = attentionModel.followingCount;
        followerCount = attentionModel.followerCount;
        print('个人主页粉丝数================================$followerCount');
        feedCount = attentionModel.feedCount;
        trainingSeconds = extraInfoModel.trainingSeconds;
        weight = extraInfoModel.weight;
        albumNum = extraInfoModel.albumNum;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    super.build(context);
    print('===============================我的页build');
    double width = ScreenUtil.instance.screenWidthDp;
    double height = ScreenUtil.instance.height;
    return Scaffold(
      appBar: null,
      body: _buildSuggestions(width, height),
    );
  }

  ///界面
  Widget _buildSuggestions(double width, double height) {
    return Container(
      color: AppColor.white,
      height: height,
      width: width,
      child: Column(
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
                      "训练计划",
                      style: AppStyle.textRegular12,
                    ),),
                    Expanded(child: Container()),
                 Container(
                   width: width * 0.27,
                   alignment: Alignment.centerLeft,
                   child:Text(
                      "体重记录",
                      style: AppStyle.textRegular12,
                    ) ,),
                    Expanded(child: Container()),
                    Container(
                      width: width * 0.27,
                      alignment: Alignment.centerLeft,
                      child:Text(
                      "健身相册",
                      style: AppStyle.textRegular12,
                    ) ,),
                  ],
                ),
                SizedBox(
                  height: 8,
                ),
                Row(
                  children: [
                    _secondData(Icons.access_alarms_sharp, trainingSeconds, "训练记录", height, width),
                    Expanded(child: Container()),
                    _secondData(Icons.access_alarms_sharp, weight ,"体重记录", height, width),
                    Expanded(child: Container()),
                    _secondData(Icons.access_alarms_sharp, albumNum, "健身相册", height, width),
                  ],
                ),
                SizedBox(
                  height: 28,
                ),
                _bottomSetting("我的课程"),
                InkWell(
                  onTap: (){
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                      return VipOpenPage();
                    }));
                  },
                  child:
                _bottomSetting("我的订单"),
                ),
                InkWell(
                  onTap: (){
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                      return HeightAndWeightPage();
                    }));
                  },
                  child: _bottomSetting("我的成就"),
                )
              ],
            ),
          )
        ],
      ),
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
            imageUrl: avatar,
            fit: BoxFit.cover,
            placeholder: (context, url) => Image.asset(
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
      height: 44,
      width: width,
      padding: EdgeInsets.only(left: 16, right: 16),
      child: Center(
          child: Row(
        children: [
          InkWell(
              onTap: () async {
                AppRouter.navigateToScanCodePage(context);
              },
              child: Container(
                height: 20,
                width: 20,
                child: Icon(Icons.settings_overscan),
              ),
            ),

          Expanded(child: SizedBox()),
          InkWell(
            onTap: () {
              AppRouter.navigateToSettingHomePage(context);
            },
            child: Container(
              height: 20,
              width: 20,
              child: Icon(
                Icons.list,
              ),
            ),
          )
        ],
      )),
    );
  }

  ///这里是底部订单成就，为了代码复用写成一个布局，通过传值来改变
  Widget _bottomSetting(String text) {
    return Container(
      height: 48,
      child: Center(
        child: Row(
          children: [
            Icon(Icons.account_balance_sharp),
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
              child: _ImgAvatar(height, width),
            ),
            Positioned(
                left: width * 0.38,
                bottom: 0,
                child: Row(children: [
                  InkWell(
                    child: _TextAndNumber("关注",StringUtil.getNumber(followingCount)),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                        return QueryFollowList(
                          type: 1,
                          userId: uid,
                        );
                      }));
                    },
                  ),
                  SizedBox(
                    width: width * 0.12,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                        return QueryFollowList(
                          type: 2,
                          userId: uid,
                        );
                      }));
                    },
                    child: _TextAndNumber("粉丝", StringUtil.getNumber(followerCount)),
                  ),
                  SizedBox(
                    width: width * 0.12,
                  ),
                  _TextAndNumber("动态", StringUtil.getNumber(feedCount))
                ]))
          ],
        ));
  }

  ///这是头像
  Widget _ImgAvatar(double height, double width) {
    return Container(
      width: height * 0.11,
      height: height * 0.11,
      child: InkWell(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              ///这里传type来告知详情页该怎么展示
              return ProfileDetailPage(
                userId: uid,
              );
            }));
          },
          child: Stack(
            children: [
              Selector<ProfileNotifier, String>(builder: (context, avatar, child) {
                print("头像地址:$avatar");
                return ClipOval(
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
                );
              }, selector: (context, notifier) {
                return notifier.profile.avatarUri;
              }),
              Positioned(
                  bottom: height * 0.11 * 0.04,
                  right: height * 0.11 * 0.04,
                  child: Container(
                    width: height * 0.11 * 0.26,
                    height: height * 0.11 * 0.26,
                    decoration: BoxDecoration(
                      color: AppColor.black,
                      borderRadius: BorderRadius.all(Radius.circular(59)),
                    ),
                  ))
            ],
          )),
    );
  }

  ///这里是关注粉丝动态
  Widget _TextAndNumber(String text, String number) {
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

  ///数值大小判断,过万用字符串拼接
  String _getNumber(int number) {
    if (number == 0 || number == null) {
      return 0.toString();
    }
    if (number < 10000) {
      return number.toString();
    } else {
      String db = "${(number / 10000).toString()}";
      if (int.parse(db.substring(db.indexOf(".") + 1, db.indexOf(".") + 2)) != 0) {
        String doubleText = db.substring(0, db.indexOf(".") + 2);
        return doubleText + "W";
      } else {
        String intText = db.substring(0, db.indexOf("."));
        return intText + "W";
      }
    }
  }

  ///这里是训练计划，体重记录，健身相册的
  ///                这是中间的图标| 这是数值   |这是title
  Widget _secondData(IconData icon, number, String text, double height, double width) {
    var _userPlate = Stack(
      children: [
        Container(
          height: width * 0.27,
          width: width * 0.27,
          color: AppColor.bgWhite,
        ),
        Container(
          height: width * 0.27,
          width: width * 0.27,
          child: Center(
            child: Column(
              children: [
                Expanded(child: SizedBox()),
                Icon(icon),
                SizedBox(
                  height: 10,
                ),
                Text(
                  number != 0 && number != null ? "$number" : "— —",
                  style: AppStyle.textRegular14,
                ),
                Expanded(child: SizedBox()),
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
    ToastShow.show(msg: "点击了：" + title, context: context);
    if ("训练记录" == title) {
      AppRouter.navigateToTrainingRecordPage(context);
    } else if ("体重记录" == title) {
      AppRouter.navigateToWeightRecordPage(context);
    } else if ("健身相册" == title) {
      AppRouter.navigateToTrainingGalleryPage(context);
    }
  }
}
