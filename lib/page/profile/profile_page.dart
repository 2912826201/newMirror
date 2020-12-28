import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/user_extrainfo_model.dart';
import 'file:///F:/HD/AndroidCode4/mirror/lib/data/model/profile/profile_model.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:provider/provider.dart';
import 'package:r_scan/r_scan.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'profile_detail_page.dart';
import 'scan_code_page.dart';

enum ActionItems { DENGCHU, DENGLU }

class ProfilePage extends StatefulWidget {
  ProfilePage({Key key, this.panelController}) : super(key: key);
  PanelController panelController = new PanelController();

  @override
  ProfileState createState() => new ProfileState();
}

class ProfileState extends State<ProfilePage> with AutomaticKeepAliveClientMixin {
  var bgColor = Color(0xffcccccc);
  bool _isScroll = false;
  final String mIconFontFamily = "appIconFonts";
  int uid;
  int followingCount;
  int followerCount;
  int feedCount;
  int trainingSeconds;
  int weight;
  int albumNum;

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

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
    double width = ScreenUtil.instance.screenWidthDp;
    double height = ScreenUtil.instance.height;
    return Scaffold(
        appBar: null,
        body: _buildSuggestions(width,height),
      );
  }

  ///界面
  Widget _buildSuggestions(double width,double height) {
    return Container(
      color: AppColor.white,
      height: height,
      width: width,
      padding: EdgeInsets.only(left: 16,right: 16),
      child: Column(
        children: [
          Expanded(
              child: GestureDetector(
            onHorizontalDragStart: (details) {
              setState(() {
                _isScroll = false;
              });
            },
            onVerticalDragStart: (details) {
              setState(() {
                _isScroll = true;
              });
            },
            child: ListView(
              physics: _isScroll ? BouncingScrollPhysics() : NeverScrollableScrollPhysics(),
              children: [
                _blurrectAvatar(width,height),
                SizedBox(
                  height: height*0.05,
                ),
                Container(
                    child: Consumer<ProfileNotifier>(
                      builder: (context, notifier, child) {
                        return Row(
                          children: [
                            _secondData(Icons.access_alarms_sharp, trainingSeconds, "训练记录",height,width),
                            Expanded(child: Container()),
                            _secondData(Icons.access_alarms_sharp, weight, "体重记录",height,width),
                            Expanded(child: Container()),
                            _secondData(Icons.access_alarms_sharp, albumNum, "健身相册",height,width)
                          ],
                        );
                      },
                    )),
                _bottomSetting("我的课程"),
                _bottomSetting("我的订单"),
                _bottomSetting("我的成就"),
              ],
            ),
          ))
        ],
      ),
    );
  }

  ///这里设置高斯模糊和白蒙层
  Widget _blurrectAvatar(double width,double height) {
    return Stack(
      children: [
        Selector<ProfileNotifier, String>(builder: (context, avatar, child) {
          print("头像地址:$avatar");
          return CachedNetworkImage(
            height: height*0.16,
            width: width,
            imageUrl: avatar == null ? "" : avatar,
            fit: BoxFit.cover,
            placeholder: (context, url) => Image.asset("images/test.png", fit: BoxFit.cover,),
            errorWidget: (context, url, error) => Image.asset("images/test.png", fit: BoxFit.cover,),
          );
        }, selector: (context, notifier) {
          return notifier.profile.avatarUri;
        }),
        Positioned(
            child: Container(
          width: width,
          height: height*0.16,
          color: AppColor.white.withOpacity(0.6),
        )),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
          child: Column(
            children: [
              SizedBox(height: ScreenUtil.instance.statusBarHeight,),
              _getTopText(width,height),
              SizedBox(
                height: 17.5,
              ),
              _getUserImage(height,width),
            ],
          ),
        ),
      ],
    );
  }

  ///这是扫一扫
  Widget _getTopText(double width,double height) {
    return Container(
      height: height*0.05,
      width: width,
      child: Row(
        children: [
          Center(
            child: InkWell(
              onTap: () async {
                List<RScanCameraDescription> rScanCameras = await availableRScanCameras();
                setState(() {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                    ///这里将扫码相机初始化传过去
                    return ScanCodePage(
                      rScanCameras: rScanCameras,
                    );

                    ///通过then将扫码界面返回的信息接到，吐司出来
                  })).then((value) => {
                        if (value != null)
                          {
                            print('这是从扫码界面传回的数据:$value'),
                            Fluttertoast.showToast(
                                msg: value.toString(),
                                toastLength: Toast.LENGTH_SHORT,
                                fontSize: 16,
                                gravity: ToastGravity.CENTER,
                                backgroundColor: AppColor.textHint,
                                textColor: AppColor.white)
                          }
                      });
                });
              },
              child: Container(
                height: 20,
                width: 20,
                child: Image.asset("images/test/scancode.png"),
              ),
            ),
          ),
          Expanded(child: SizedBox()),
          InkWell(
            onTap: (){
            AppRouter.navigateToSettingHomePage(context);
            },
            child: Container(
            height: 20,
            width: 20,
           child: Icon(
             Icons.list,
           ),
          ),)
        ],
      ),
    );
  }
  ///这里是底部订单成就，为了代码复用写成一个布局，通过传值来改变
  Widget _bottomSetting(String text) {
    return Container(
      height: 48,
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
    );
  }

  ///这里因为头像和关注等是水平，所以放在一起
  Widget _getUserImage(double height,double width) {
    return Container(
        height: height*0.1,
        child: Row(
          children: [
            Center(
              child: _ImgAvatar(height,width),
            ),
            SizedBox(
              width: width*0.16,
            ),
            Container(
              ///把文字挤下去

              child: Column(children: [
                Expanded(child: SizedBox()),
              Row(children: [
                _TextAndNumber("关注", followingCount),
                SizedBox(width:width*0.13 ,),
                _TextAndNumber("粉丝", followerCount),
                SizedBox(width:width*0.13 ,),
                _TextAndNumber("动态", feedCount)
              ])],)
            )
          ],
        ));
  }

  ///这是头像
  Widget _ImgAvatar(double height,double width) {
    return Container(
      width: height*0.1,
      height: height*0.1,
      child: InkWell(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              ///这里传type来告知详情页该怎么展示
              return ProfileDetailPage(
                userId: uid,pcController: widget.panelController,
              );
            }));
          },
          child: Stack(
            children: [
              Selector<ProfileNotifier, String>(builder: (context, avatar, child) {
                print("头像地址:$avatar");
                return ClipOval(
                  child: CachedNetworkImage(
                    height: height*0.1,
                    width: height*0.1,
                    imageUrl: avatar == null ? "" : avatar,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Image.asset("images/test.png", fit: BoxFit.cover,),
                    errorWidget: (context, url, error) => Image.asset("images/test.png", fit: BoxFit.cover,),
                  ),
                );
              }, selector: (context, notifier) {
                return notifier.profile.avatarUri;
              }),
              Positioned(
                  bottom: width*0.01,
                  right: width*0.01,
                  child: Container(
                      width: height*0.02,
                      height: height*0.02,
                      decoration: BoxDecoration(
                        color: AppColor.black,
                        borderRadius: BorderRadius.all(Radius.circular(59)),
                      ),
                      child: Center(
                        child: Text(
                          "+",
                          style: TextStyle(fontSize: 12, color: Colors.white),
                        ),
                      )))
            ],
          )),
    );
  }

  ///这里是关注粉丝动态
  Widget _TextAndNumber(String text, int number) {
    print('__________________________$number');
    return Column(
          children: [
            Center(
              child: Text(
                "${_getNumber(number)}",
                style:AppStyle.textMedium18,
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
  Widget _secondData(IconData icon, int number, String text,double height,double width) {
    var _userPlate = Container(
      width: width*0.27,
      child: Column(
      children: [
        ///这里是固定的文字，直接用空格撑布局
        Row(
          children: [
            Container(
              child: Text(
                text,
                style: AppStyle.textSecondaryRegular12,
              ),),
            Expanded(child: SizedBox())
          ],
        ),
        SizedBox(
          height: 8,
        ),
        Container(
            height: width*0.27,
            width: width*0.27,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              border: Border.all(width: 0.5, color: AppColor.black),
            ),
            child: Stack(
              children: [
                Container(
                  height: height*0.15,
                  width: height*0.15,
                  child: Image.network("https://scpic.chinaz.net/files/pic/pic9/201911/zzpic21124.jpg"),
                ),
                Center(
                  child: Column(
                    children: [
                      Icon(icon),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        number != 0 && number != null ? "$number" : "— —",
                        style: AppStyle.textRegular14,
                      )
                    ],
                  ),
                )
              ],
            ))
      ],
    ),);
    return _userPlate;
  }
}
