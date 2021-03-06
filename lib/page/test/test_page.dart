import 'dart:io';
import 'dart:math';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:lottie/lottie.dart';
import 'package:mirror/api/training/course_api.dart';
import 'package:mirror/api/version_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/config/config.dart';
import 'package:mirror/config/shared_preferences.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/dto/profile_dto.dart';
import 'package:mirror/data/model/training/course_mode.dart';
import 'package:mirror/data/model/training/course_model.dart';
import 'package:mirror/data/model/training/training_complete_result_model.dart';
import 'package:mirror/data/model/version_model.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:mirror/page/activity/activity_change_address_page.dart';
import 'package:mirror/page/test/activation_test_page.dart';
import 'package:mirror/page/test/agora_input_page.dart';
import 'package:mirror/page/test/download_test_page.dart';
import 'package:mirror/page/test/echarts_test/echarts_test.dart';
import 'package:mirror/page/test/listview_test_page.dart';
import 'package:mirror/page/test/media_test_page.dart';
import 'package:mirror/util/check_permissions_util.dart';
import '../../widget/activity_pull_down_refresh.dart';
import 'package:mirror/page/test/qiniu_test_page.dart';
import 'package:mirror/page/test/serial_popup_test.dart';
import 'package:mirror/page/test/tag_cloud/tag_cloud_page.dart';
import 'package:mirror/page/test/tik_tok_test/tik_tok_home.dart';
import 'package:mirror/page/training/live_broadcast/live_room_page.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/check_phone_system_util.dart';
import 'package:mirror/util/date_util.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/text_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/activity_time_chose_bottom_sheet.dart';
import 'package:mirror/widget/change_insert_user_bottom_sheet.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/dialog.dart';
import 'package:mirror/widget/icon.dart';
import 'package:mirror/widget/loading.dart';
import 'package:mirror/widget/version_update_dialog.dart';

import 'package:mirror/widget/volume_popup.dart';
import 'package:mirror/widget/week_pop_window.dart';
import 'package:move_to_background/move_to_background.dart';
import 'package:open_file/open_file.dart';
import 'package:popup_window/popup_window.dart';
import 'package:provider/provider.dart';
import '../message/util/message_chat_page_manager.dart';
import '../training/video_course/video_course_play_page2.dart';
import '../training/video_course/video_course_play_page.dart';
import 'badger_test_page.dart';
import 'explosion_image_test.dart';
import 'floating_botton_test.dart';
import 'jpush_test_page.dart';
import 'package:jpush_flutter/jpush_flutter.dart';

import 'listview_item_test_page.dart';
import 'marquee_text_test.dart';

/// test_page
/// Created by yangjiayi on 2020/10/27.

class TestPage extends StatefulWidget {
  @override
  _TestState createState() => _TestState();
}

class _TestState extends State<TestPage> with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  double nowProgress = 0;

  @override
  bool get wantKeepAlive => true; //????????????
  String url = "https://down.qq.com/qqweb/QQ_1/android_apk/Android_8.5.5.5105_537066978.apk";
  String TestText =
      "??????????????????????????????????????????????????????????????????????????????????????????????????????:???????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????:815??????829??????T102????????????517??????T101????????????4A??????501??????801??????813??????825B??????823??????825A??????826??????821??????827??????828??????843??????T103????????????2A??????T106??????815A????????????5??????807???????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????8.0??????????????????2.0????????? ?????????1.9???????????????????????? ????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????";
  DateTime choseDateTime = DateTime.now();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("??????????????????????????????$state");
  }

  Future<void> pop() async {
    await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    print("?????????");
    print("build");
    print("??????????????????${ScreenUtil.instance.bottomBarHeight}");
    return Scaffold(
      appBar: CustomAppBar(
        titleString: "?????????",
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("???????????????????????????????????????"),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    color: Colors.redAccent,
                    // width: ScreenUtil.instance.setWidth(28.0),
                    width: 28.0,
                    height: 28.0,
                    // height:ScreenUtil.instance.setHeight(28.0),
                    margin: const EdgeInsets.only(right: 10),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 12),
                    child: Container(
                      child: Text("??????????????????"),
                    ),
                  )
                ],
              ),
              //watch?????????????????????
              Text("??????ID???${context.watch<ProfileNotifier>().profile.uid}"),
              Text("????????????${context.watch<ProfileNotifier>().profile.nickName}"),
              Text("?????????????????????${context.watch<ProfileNotifier>().profile.avatarUri}"),
              //select???????????????????????? ????????????????????????????????????????????????
              Text("??????ID???${context.select((ProfileNotifier value) => value.profile.uid)}"),
              Text("????????????${context.select((ProfileNotifier value) => value.profile.nickName)}"),
              Text("?????????????????????${context.select((ProfileNotifier value) => value.profile.avatarUri)}"),
              //???consumer?????????????????????
              Consumer<ProfileNotifier>(
                builder: (context, notifier, child) {
                  return Column(
                    children: [
                      Text("??????ID???${notifier.profile.uid}"),
                      Text("????????????${notifier.profile.nickName}"),
                      Text("?????????????????????${notifier.profile.avatarUri}"),
                    ],
                  );
                },
              ),
              //???Selector?????????????????????
              Selector<ProfileNotifier, int>(builder: (context, uid, child) {
                return Text("??????ID???$uid");
              }, selector: (context, notifier) {
                return notifier.profile.uid;
              }),
              Selector<ProfileNotifier, String>(builder: (context, nickName, child) {
                return Text("????????????$nickName");
              }, selector: (context, notifier) {
                return notifier.profile.nickName;
              }),
              Selector<ProfileNotifier, String>(builder: (context, avatarUri, child) {
                return Text("?????????????????????$avatarUri");
              }, selector: (context, notifier) {
                return notifier.profile.avatarUri;
              }),
              Builder(
                builder: (context) {
                  return RaisedButton(
                    onPressed: () => _changeUser(context),
                    child: Text("????????????(?????????????????????)"),
                  );
                },
              ),
              Container(
                  width: ScreenUtil.instance.width - 70,
                  height: 22,
                  child: Center(
                    child: YYMarquee(
                        // ColorizeAnimatedTextKit(
                        //     text: [
                        //       "?????????????????????????????????????????????"
                        //     ],
                        //     textStyle: TextStyle(
                        //         fontSize: 15.0,
                        //         fontFamily: "Horizon"
                        //     ),
                        //     colors: [
                        //       Colors.purple,
                        //       Colors.blue,
                        //       Colors.yellow,
                        //       Colors.red,
                        //     ],
                        //     textAlign: TextAlign.start,
                        // ),
                        DefaultTextStyle(
                          textAlign: TextAlign.start,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                          ),
                          child: AnimatedTextKit(
                            repeatForever: true,
                            pause: Duration(milliseconds: 100),
                            animatedTexts: [
                              ColorizeAnimatedText(
                                "?????????????????????????????????????????????",
                                colors: [
                                  Colors.grey,
                                  Colors.blue,
                                  Colors.yellow,
                                  Colors.red,
                                ],
                                textStyle: const TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                            ],
                            // totalRepeatCount: 10000,
                          ),
                        ),
                        150.0,
                        new Duration(seconds: 2),
                        130.0),
                  )),
              Builder(
                builder: (context) {
                  return RaisedButton(
                    onPressed: () => _changeNickName(context),
                    child: Text("???????????????(?????????????????????)"),
                  );
                },
              ),
              RaisedButton(
                onPressed: () {
                  AppRouter.navigateToLoginTestPage(context);
                },
                child: Text("????????????"),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RaisedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return QiniuTest();
                      }));
                    },
                    child: Text("??????????????????"),
                  ),
                  RaisedButton(
                    onPressed: () {
                      Size c = getTextSize("???????????????", TextStyle(fontSize: 16), 1);
                      print("++++++++++++++++$c+++++++++++++++++++++++");
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return MediaTestPage();
                      }));
                    },
                    child: Text("??????????????????"),
                  ),
                ],
              ),
              RaisedButton(
                onPressed: () {
                  AppRouter.navigateToRCTestPage(context, context.read<ProfileNotifier>().profile);
                },
                child: Text("Fluro?????????????????????"),
              ),
              RaisedButton(
                onPressed: () {
                  openSerialPopupBottom(context: context);
                },
                // openSerialPopupBottom
                child: Text("??????????????????"),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RaisedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return AgoraInputPage();
                      }));
                    },
                    child: Text("????????????"),
                  ),
                  RaisedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return ActivationTestPage();
                      }));
                    },
                    child: Text("??????????????????"),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RaisedButton(
                    onPressed: () {
                      AppRouter.navigateToLiveBroadcast(context);
                    },
                    child: Text("???????????????"),
                  ),
                  RaisedButton(
                    onPressed: () {
                      AppRouter.navigateToVideoCourseList(context);
                    },
                    child: Text("???????????????"),
                  ),
                  RaisedButton(
                    onPressed: () {
                      jumpChatPageTest(context);
                    },
                    child: Text("????????????"),
                  ),
                ],
              ),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                RaisedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return LiveRoomPage();
                    }));
                  },
                  child: Text("??????"),
                ),
                RaisedButton(
                  onPressed: () async {
                    Map<String, String> result = await _videoDownloadCheck();
                    if (result == null) {
                      ToastShow.show(msg: "??????????????????????????????????????????????????????", context: context);
                    } else {
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return VideoCoursePlayPage(result, null);
                      }));
                    }
                  },
                  child: Text("??????1"),
                ),
                RaisedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return VideoCoursePlayPage2();
                    }));
                  },
                  child: Text("??????2"),
                ),
              ]),

              RaisedButton(
                onPressed: () {
                  // Navigator.push(context, MaterialPageRoute(builder: (context) {
                  //   return LiveRoomTestPage();
                  // }));
                  // Navigator.of(context).push(SimpleRoute(
                  //   name: 'aaa',
                  //   title: 'aaa',
                  //   builder: (_) {
                  //     return LiveRoomTestPageDialog();
                  //   },
                  // ));
                },
                child: Text("???????????????"),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RaisedButton(
                    onPressed: () {
                      bool isFirst = AppPrefs.isFirstLaunch();
                      print(isFirst);
                    },
                    child: Text("???SP?????????"),
                  ),
                  RaisedButton(
                    onPressed: () {
                      AppPrefs.setIsFirstLaunch(false);
                    },
                    child: Text("???isFirstLaunch?????????false"),
                  ),
                ],
              ),
              RaisedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return DownloadTestPage();
                  }));
                },
                child: Text("???????????????"),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                RaisedButton(
                  onPressed: () {
                    showAppDialog(context,
                        title: "????????????",
                        info: "????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????",
                        cancel: AppDialogButton("??????", () {
                          print("????????????");
                          return true;
                        }),
                        confirm: AppDialogButton("??????", () {
                          print("????????????");
                          return true;
                        }));
                  },
                  child: Text("?????????1"),
                ),
                RaisedButton(
                  onPressed: () {
                    showAppDialog(context,
                        title: "???????????????",
                        info: "???????????????????????????????????????",
                        barrierDismissible: false,
                        buttonList: [
                          AppDialogButton("?????????", () {
                            print("???????????????");
                            return true;
                          }),
                          AppDialogButton("?????????", () {
                            print("???????????????");
                            return true;
                          }),
                          AppDialogButton("?????????", () {
                            print("???????????????");
                            return true;
                          }),
                        ]);
                  },
                  child: Text("?????????2"),
                ),
                RaisedButton(
                  onPressed: () {
                    // showAppDialog(context,
                    //     info: "????????????????????????????????????",
                    //     topImageUrl: "assets/png/unfinished_training_png.png",
                    //     isTransparentBack:true,
                    //     cancel: AppDialogButton("????????????", () {
                    //       //???????????????????????? ????????????????????????????????????????????????????????????
                    //       // _controller?.pause();
                    //       // Navigator.pop(context);
                    //       return true;
                    //     }),
                    //     confirm: AppDialogButton("????????????", () {
                    //       return true;
                    //     }));

                    showAppDialog(
                      context,
                      circleImageUrl: "",
                      topImageUrl: "",
                      title: "???????????????",
                      info: "??????????????????????????????????????????",
                      confirm: AppDialogButton("????????????", () {
                        print("??????????????????");
                        return true;
                      }),
                    );
                  },
                  child: Text("?????????3"),
                ),
                RaisedButton(
                  onPressed: () {
                    showVolumePopup(context);
                  },
                  child: Text("??????"),
                ),
              ]),
              // Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              //   RaisedButton(
              //     onPressed: () async {
              //       TrainingCompleteResultModel result = TrainingCompleteResultModel();
              //       result.synthesisRank = 67;
              //       result.upperRank = 100;
              //       result.lowerRank = 80;
              //       result.coreRank = 33;
              //       result.completionDegree = 57;
              //       result.no = 233;
              //       result.calorie = 198;
              //       result.mseconds = 2040000;
              //       result.synthesisScore = 12894;
              //       CourseModel course = await getCourseModel(courseId: 77, type: mode_video);
              //       AppRouter.navigateToVideoCourseResult(context, result, course);
              //     },
              //     child: Text("??????????????????"),
              //   ),
              // ]),
              RaisedButton(
                onPressed: () {
                  Navigator.of(context).push(new MaterialPageRoute(builder: (context) {
                    //     return SliverListDemoPage();
                    return ExplosionImageTest();
                  }));
                },
                child: Text("????????????"),
              ),
              RaisedButton(
                onPressed: () {
                  Navigator.of(context).push(new MaterialPageRoute(builder: (context) {
                    //     return SliverListDemoPage();
                    return TiktokHome();
                  }));
                },
                child: Text("????????????"),
              ),
              RaisedButton(
                onPressed: () {
                  Navigator.of(context).push(new MaterialPageRoute(builder: (context) {
                    //     return SliverListDemoPage();
                    return TagCloudPage();
                  }));
                },
                child: Text("???????????????"),
              ),
              RaisedButton(
                onPressed: () {
                  Navigator.of(context).push(new MaterialPageRoute(builder: (context) {
                    return EchartsView();
                  }));
                },
                child: Text("Echarts"),
              ),
              Container(
                color: AppColor.mainRed,
                child: Text(
                  "12345:67890",
                  style: TextStyle(fontSize: 32, fontFamily: "BebasNeue"),
                ),
              ),
              Container(
                color: AppColor.mainBlack,
                child: Text(
                  "12345:67890",
                  style: TextStyle(fontSize: 32, fontFamily: "BebasNeue", fontWeight: FontWeight.w500),
                ),
              ),
              Container(
                color: AppColor.mainBlue,
                child: Text(
                  "12345:67890",
                  style: TextStyle(fontSize: 32),
                ),
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    RaisedButton(
                      onPressed: () {
                        // _getNewVersion(context);
                        showVersionDialog(
                            barrierDismissible: false,
                            content: "????????????\n??????????????????????????????\n??????????????????\n??????????????????\n??????????????????\n??????????????????\n??????????????????",
                            strong: false,
                            context: context,
                            url: url);
                      },
                      child: Text("??????????????????"),
                    ),
                    AppIconButton(
                      iconSize: 22,
                      buttonHeight: 44,
                      buttonWidth: 44,
                      iconColor: AppColor.mainBlue,
                      svgName: AppIcon.nav_return,
                      onTap: () {
                        AppRouter.navigateToLoginSucess(context);
                      },
                    ),
                    Lottie.asset(
                      'assets/lottie/loading_refresh_black.json',
                      width: 48,
                      height: 48,
                      fit: BoxFit.fill,
                      delegates: LottieDelegates(
                        values: [
                          ValueDelegate.color(
                            const ['Shape Layer 1', 'Rectangle', 'Fill 1'],
                            value: Colors.red,
                          ),
                        ],
                      ),
                    ),
                    Lottie.asset(
                      'assets/lottie/loading_refresh_yellow.json',
                      width: 48,
                      height: 48,
                      fit: BoxFit.fill,
                      delegates: LottieDelegates(
                        values: [
                          ValueDelegate.color(
                            const ['Shape Layer 1', 'Rectangle', 'Fill 1'],
                            value: Colors.red,
                          ),
                        ],
                      ),
                    ),
                  ]),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 30,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.lightBlue, width: 1),
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 50, width: 32,),
                  AppIcon.getAppIcon(AppIcon.gender_male_14, 14,
                      color: AppColor.white, bgColor: AppColor.mainRed, isCircle: true),
                  SizedBox(height: 50, width: 32,),
                  AppIcon.getAppIcon(AppIcon.gender_female_14, 14,
                      color: AppColor.white, bgColor: AppColor.mainRed, isCircle: true),
                ],
              ),
              RaisedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return JpushTestPage();
                  }));
                },
                child: Text("???????????????"),
              ),
              RaisedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return FloatingBottonTestPage();
                  }));
                },
                child: Text("??????????????????"),
              ),
              RaisedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return ActivityChangeAddressPage();
                  }));
                },
                child: Text("?????????????????????"),
              ),
              RaisedButton(
                  onPressed: () {
                    JPush().getLaunchAppNotification().then((value) {
                      print("getLaunchAppNotification:$value");
                      ToastShow.show(msg: "getLaunchAppNotification:$value", context: context);
                    });
                  },
                  child: Text("iOS????????????APP???????????????")),
              RaisedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return BadgerTestPage();
                    }));
                  },
                  child: Text("BadgerTestPage")),
              RaisedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return ListViewTestPage();
                    }));
                  },
                  child: Text("ListView????????????")),
              RaisedButton(
                  onPressed: () async {
                    ToastShow.show(
                        msg: "??????????????????:${await CheckPhoneSystemUtil.init().getPhoneSystem()}", context: context);
                    print("??????????????????:${await CheckPhoneSystemUtil.init().getPhoneSystem()}");
                    print("?????????????????????:${await CheckPhoneSystemUtil.init().isEmui()}");
                  },
                  child: Text("??????????????????")),
              RatingBar.builder(
                /// ??????????????????????????????????????????
                initialRating: 3,

                /// ??????????????????????????? 0???
                minRating: 1,
                direction: Axis.horizontal,

                /// ????????? false??? ?????? true ????????????????????????
                allowHalfRating: true,
                // ??????????????? true???????????????????????????????????????????????????false???
                ignoreGestures: false,

                /// ??????????????? true?????????????????????????????????????????????????????????true???
                glow: false,
                // ????????????
                itemSize: 24,
                itemCount: 5,
                itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
                itemBuilder: (context, index) {
                  return Icon(
                    Icons.star,
                    color: Colors.amber,
                  );
                },
                // ??????????????????????????????????????????
                onRatingUpdate: (rating) {
                  print(rating);
                },
              ),

              RaisedButton(
                  onPressed: () async {
                    print("????????????????????????::${AppPrefs.isAgreeUserAgreement()}");
                    if (!AppPrefs.isAgreeUserAgreement()) {
                      print("11111111");
                      // Future.delayed(Duration.zero, () {
                      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                        showAppDialog(context,
                            confirm: AppDialogButton("??????", () {
                              return true;
                            }),
                            cancel: AppDialogButton("???????????????", () {
                              // pop();
                              if (Platform.isIOS) {
                                // MoveToBackground.moveTaskToBack();
                                // MoveToBackground.moveTaskToBack();
                                exit(0);

                                ///?????????????????????????????????????????????
                              } else if (Platform.isAndroid) {
                                MoveToBackground.moveTaskToBack();
                                // SystemNavigator.pop(); //?????????????????????????????????
                              }
                              return true;
                            }),
                            title: "???????????????????????????",
                            customizeWidget: Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height * 0.3,
                              child: SingleChildScrollView(
                                child: Text(TestText),
                              ),
                            ),
                            barrierDismissible: false);
                      });
                    }
                  },
                  child: Text("???????????????????????????")),
              RaisedButton(
                  onPressed: () {
                    // Loading.showLoading(context, infoText: "??????");
                    openActivityTimePickerBottomSheet(
                        context: context,
                        firstTime: DateTime.now(),
                        onStartAndEndTimeChoseCallBack: (start, end) {
                          print('----------onStartAndEndTimeChoseCallBack----------------$start-----$end');
                        });
                    // Navigator.push(context, MaterialPageRoute(builder: (context) {
                    //   return ListviewItemPage();
                    // }));
                  },
                  child: Text("??????????????????????????????")),
              _showSelectJoinTimePopupWindow(),
              RaisedButton(
                  onPressed: () {
                    openUserNumberPickerBottomSheet(
                        context: context,
                        start: 17,
                        end: 39,
                        onChoseCallBack: (number) {
                          print('---------------------???????????????-$number');
                        });
                  },
                  child: Text("????????????????????????")),
              RaisedButton(
                  onPressed: () {
                    locationPermissions1(context);
                  },
                  child: Text("??????????????????")),
            ],
          ),
        ),
      ),
    );
  }

  Widget _showSelectJoinTimePopupWindow() {
    return PopupWindowButton(
      offset: Offset(0, 24),
      buttonBuilder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColor.mainBlack, width: 0.5),
          ),
          padding: EdgeInsets.symmetric(horizontal: 6),
          width: 104,
          height: 24,
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              Text(DateUtil.formatDateNoYearString(choseDateTime), style: AppStyle.textRegular15),
              Spacer(),
              RotatedBox(
                quarterTurns: 1,
                child: AppIcon.getAppIcon(
                  AppIcon.arrow_right_18,
                  16,
                  color: AppColor.textWhite60,
                ),
              ),
            ],
          ),
        );
      },
      windowBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
        return FadeTransition(
          opacity: animation,
          child: SizeTransition(
              sizeFactor: animation,
              child: Container(
                child: WeekPopWindow(
                  initDateTime: choseDateTime,
                  onTapChoseCallBack: (dateTime) {
                    choseDateTime = dateTime;
                    setState(() {});
                  },
                ),
                width: ScreenUtil.instance.width,
                padding: EdgeInsets.only(right: 16),
              )),
        );
      },
      onWindowShow: () {
        print('PopupWindowButton window show');
      },
      onWindowDismiss: () {
        print('PopupWindowButton window dismiss');
      },
    );
  }

  void _getNewVersion(BuildContext context) async {
    String url = "https://caaceed4aeaf2.cdn.sohucs.com/moyu_apk/%E6%91%B8%E9%B1%BCkik.apk";
    VersionModel model = await getNewVersion();
    if (model != null) {
      print('====================??????model??????');
      if (model.version != AppConfig.version) {
        ToastShow.show(msg: "????????????${AppConfig.version}   ????????????${model.version}", context: context);
      } else {
        if (model.os == CheckPhoneSystemUtil.platform && url != null) {
          if (CheckPhoneSystemUtil.init().isAndroid()) {
            String oldPath = await FileUtil().getDownloadedPath(url);
            if (oldPath != null) {
              showAppDialog(
                context,
                title: "?????????????????????????????????????????????",
                cancel: AppDialogButton("?????????", () {
                  return true;
                }),
                confirm: AppDialogButton("??????", () {
                  OpenFile.open(oldPath).then((value) {
                    print('=======================${value.message}');
                  });
                  return true;
                }),
              );
            } else {
              showVersionDialog(
                  barrierDismissible: false,
                  content: model.description,
                  strong: model.isForceUpdate == 0 ? false : true,
                  context: context,
                  url: url);
            }
          } else {
            showVersionDialog(
              barrierDismissible: false,
              content: model.description,
              strong: model.isForceUpdate == 0 ? false : true,
              context: context,
            );
          }
        }
      }
    } else {
      return;
    }
  }
}

Future<Map<String, String>> _videoDownloadCheck() async {
  Map<String, String> map = {};
  for (String videoUrl in testVideoUrls) {
    String result = await FileUtil().getDownloadedPath(videoUrl);
    if (result == null) {
      return null;
    } else {
      map[videoUrl] = result;
    }
  }
  return map;
}

void _changeUser(BuildContext context) {
  int randomNum = Random().nextInt(10000);
  WordPair pair = WordPair.random();
  String nickName = pair.first;
  String avatarUri = "http://www.abc.com/${pair.second}.png";
  ProfileDto profile = context.read<ProfileNotifier>().profile;
  profile.uid = randomNum;
  profile.nickName = nickName;
  profile.avatarUri = avatarUri;
  context.read<ProfileNotifier>().setProfile(profile);
}

void _changeNickName(BuildContext context) {
  context.read<ProfileNotifier>().setNickName(WordPair.random().first);
}
