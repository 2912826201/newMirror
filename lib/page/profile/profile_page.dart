import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mirror/api/basic_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/database/profile_db_helper.dart';
import 'package:mirror/data/database/token_db_helper.dart';
import 'package:mirror/data/dto/profile_dto.dart';
import 'package:mirror/data/dto/token_dto.dart';
import 'package:mirror/data/model/token_model.dart';
import 'package:mirror/data/model/user_model.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:mirror/data/notifier/token_notifier.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/app_style.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:r_scan/r_scan.dart';

import 'profile_detail_page.dart';
import 'scan_code_page.dart';
enum ActionItems{
  DENGCHU,DENGLU
}
class ProfilePage extends StatefulWidget {
  @override
  ProfileState createState() => new ProfileState();
}

class ProfileState extends State<ProfilePage> with AutomaticKeepAliveClientMixin {
  var bgColor = Color(0xffcccccc);
  bool _isScroll = false;
  final String mIconFontFamily = "appIconFonts";
  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    super.build(context);
    return MaterialApp(home: Builder(builder: (context) {
      double width = MediaQuery.of(context).size.width;
      return Scaffold(
        appBar: null,
        body: _buildSuggestions(width),
      );
    }));
  }

  ///界面
  Widget _buildSuggestions(double width) {
    return Container(
      color: AppColor.white,
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
              physics: _isScroll
                  ? BouncingScrollPhysics()
                  : NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.only(top: 0),
              children: [
                _blurrectAvatar(width),
                SizedBox(height: 41,),
                Container(
                  padding: EdgeInsets.only(left: 20,right: 20,bottom: 20),
                  child: Row(
                    children: [
                      _secondData(Icons.access_alarms_sharp,0,"训练记录"),
                      Expanded(child: Container()),
                      _secondData(Icons.access_alarms_sharp,244,"体重记录"),
                      Expanded(child: Container()),
                      _secondData(Icons.access_alarms_sharp,244,"健身相册")
                    ],
                  ),
                ),
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
  Widget _blurrectAvatar(double width){
    return Stack(
      children: [
        Container(
          height: 133,
          width: width,
          child: Selector<ProfileNotifier, String>(
            builder: (context, avatar, child) {
              print("头像地址:$avatar");
              return Image.network(avatar,fit: BoxFit.cover,);
            }, selector: (context, notifier) {
            return notifier.profile.avatarUri;
          }),
        ),
        Positioned(
          child:Container(
            width: width,
            height: 133,
            color: AppColor.white.withOpacity(0.6),
          )
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),child: Column(
          children: [
            SizedBox(height: 13,),
            _getTopText(width),
            SizedBox(height: 17.5,),
            _getUserImage(),
          ],

        ),),

      ],
    );

  }
  ///这是扫一扫
  Widget _getTopText(double width) {
    return Container(
      margin: EdgeInsets.only(top: 44),
      height: 44,
      width: width,
      padding: EdgeInsets.only(left: 20, ),
      child: Row(
        children: [
          Center(
            child: InkWell(
            onTap: () async {
              List<RScanCameraDescription> rScanCameras =
                  await availableRScanCameras();
              setState(() {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                      ///这里将扫码相机初始化传过去
                  return ScanCodePage(
                    rScanCameras: rScanCameras,
                  );///通过then将扫码界面返回的信息接到，吐司出来
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
          ),),
          Expanded(child: SizedBox()),
          Center(
            child: FlatButton(
            child: PopupMenuButton(
              onSelected: (ActionItems selects) async {
                if(selects == ActionItems.DENGCHU){
                  TokenModel tokenModel = await login("anonymous", null, null, null);
                  if (tokenModel != null) {
                    TokenDto tokenDto = TokenDto.fromTokenModel(tokenModel);
                    bool result = await logout();
                    //TODO 这里先不处理登出接口的结果
                    await TokenDBHelper().insertToken(tokenDto);
                    context.read<TokenNotifier>().setToken(tokenDto);
                    await ProfileDBHelper().clearProfile();
                    context.read<ProfileNotifier>().setProfile(ProfileDto.fromUserModel(UserModel()));
                  } else {
                    //失败的情况下 登出将无token可用 所以不能继续登出
                  }
                }else{
                  AppRouter.navigateToLoginPage(context);
                }
              },
              itemBuilder: (BuildContext context){
                return<PopupMenuItem<ActionItems>>[
                    PopupMenuItem(
                      child: _buildPopupMenuItem(0xe606,"登出"),
                      value: ActionItems.DENGCHU,
                    ),
                  PopupMenuItem(
                    child: _buildPopupMenuItem(0xe606, "登录"),value: ActionItems.DENGLU,),

                ];
              },
            ),
          ),)
        ],
      ),
    );
  }
  _buildPopupMenuItem(int iconName,String title){
    return Row(
      children: <Widget>[
        Icon(
          IconData(
            iconName,
            fontFamily: mIconFontFamily
          ),
          size: 22.0,
          color:AppColor.black.withOpacity(0.5),
        ),
        Container(),
        Text(
          title,
          style: TextStyle(
            color: AppColor.black.withOpacity(0.5)
          ),
        )
      ],
    );
  }
  ///这里是底部订单成就，为了代码复用写成一个布局，通过传值来改变
  Widget _bottomSetting(String text){
    return Container(
      height: 48,
      padding: EdgeInsets.only(left: 16,right: 16),
      child: Row(
        children: [
          Icon(Icons.account_balance_sharp),
          SizedBox(width: 12,),
          Text(text,style: AppStyle.textRegular16,),
          Expanded(child: Container()),
          Icon(Icons.arrow_forward_ios)
        ],
      ),
    );
  }

  ///这里因为头像和关注等是水平，所以放在一起
  Widget _getUserImage() {
    return Container(
      height: 87,
      padding: EdgeInsets.only(left: 18.5,right: 15.5),
        child: Row(
      children: [
        Center(child: _ImgAvatar(),),
        SizedBox(width: 40,),
        Container(
            ///把文字挤下去
            padding: EdgeInsets.only(top: 44),
          child:
            Consumer<ProfileNotifier>(
              builder: (context, notifier, child) {
                return Row(
                children: [
                    _TextAndNumber("关注", notifier.profile.followingCount),
                    _TextAndNumber("粉丝", notifier.profile.followerCount),
                    _TextAndNumber("动态", notifier.profile.feedCount)
                ]
                );
              },
            ),

          )
      ],
    ));
  }

  ///这是头像
  Widget _ImgAvatar(){
    return Container(
      width: 87,
      height: 87,
      child: InkWell(
    onTap: () {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) {
        ///这里传type来告知详情页该怎么展示
        return ProfileDetailPage(
          type: 2,
        );
      }));
    },
    child: Stack(
      children: [
        Selector<ProfileNotifier, String>(
          builder: (context, avatar, child) {
            print("头像地址:$avatar");
            return CircleAvatar(
              //头像半径
              radius: 45,
              //头像图片 -> NetworkImage网络图片，AssetImage项目资源包图片, FileImage本地存储图片
              backgroundImage: NetworkImage(avatar),
            );
          }, selector: (context, notifier) {
          return notifier.profile.avatarUri;
        }),
        Positioned(
          bottom: 5,
          right: 5,
          child: Container(
           width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: AppColor.black,
            borderRadius: BorderRadius.all(Radius.circular(59)),),
            child: Center(
            child: Text("+",style: TextStyle(fontSize: 20,color: Colors.white),),)
        )
        )
      ],)
  ),);
}
  ///这里是关注粉丝动态
  Widget _TextAndNumber(String text, int number) {
    print('__________________________$number');
    return Container(
          height: 73,
          width: 73,
        child: Column(
      children: [
        Center(child: Text(
          "${_getNumber(number)}",
          style: TextStyle(fontSize: 18,color: AppColor.black),
        ),),
        Center(
          child:
        Text(
          text,
          style: AppStyle.textRegular12,
        ),)
      ],
    ));
  }

  ///数值大小判断,过万用字符串拼接
  String _getNumber(int number) {
    if(number==null){
      number = 0;
    }
    if (number < 10000) {
      return number.toString();
    } else  {
      String db = (number / 10000).toString();
      String doubleText = db.substring(0, db.indexOf(".") );
      return doubleText + "W";
    }
  }

  ///这里暂时没用
  Widget _getVipData() {
    return Container(
      child: Container(
        margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8), topRight: Radius.circular(8)),
        ),
        child: Row(
          children: [
            Container(
              child: Text(
                "VIP会员",
                style: TextStyle(fontSize: 17),
              ),
              margin: const EdgeInsets.only(left: 16, top: 8, bottom: 6),
            ),
            Expanded(child: SizedBox()),
            Container(
              padding:
                  const EdgeInsets.only(left: 16, right: 16, top: 6, bottom: 6),
              margin: const EdgeInsets.only(top: 8, bottom: 6, right: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.blue,
              ),
              child: Text("立即开通"),
            ),
          ],
        ),
      ),
    );
  }
  ///这里是训练计划，体重记录，健身相册的
  ///                这是中间的图标| 这是数值   |这是title
  Widget _secondData(IconData icon,int number,String text) {
    var _userPlate = Column(
      children: [
        ///这里是固定的文字，直接用空格撑布局
        Text(text+"                    ",style: AppStyle.textSecondaryRegular12,),
        SizedBox(height: 8,),
        Container(
        height: 103.5,
        width: 103.5,
        padding: EdgeInsets.only(bottom: 10, top: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          border: Border.all(width: 0.5, color: AppColor.black),
        ),
        child: Stack(
          children: [
            Container(
              height: 120,
              width: 120,
              child: Image.network("https://scpic.chinaz.net/files/pic/pic9/201911/zzpic21124.jpg"),),
            Center(
          child: Column(
            children: [
                Icon(icon),
              SizedBox(
                height: 10,
              ),
              Text(
                number!=0?"$number":"— —",
                style: AppStyle.textRegular14,
              )
            ],
          ),
        )],))],);
    return _userPlate;
  }
}
