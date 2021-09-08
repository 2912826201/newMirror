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
import 'package:mirror/page/test/activation_test_page.dart';
import 'package:mirror/page/test/agora_input_page.dart';
import 'package:mirror/page/test/download_test_page.dart';
import 'package:mirror/page/test/echarts_test/echarts_test.dart';
import 'package:mirror/page/test/listview_test_page.dart';
import 'package:mirror/page/test/media_test_page.dart';
import 'package:mirror/page/test/pull_down_iamge_test.dart';
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
  bool get wantKeepAlive => true; //必须重写
  String url = "https://down.qq.com/qqweb/QQ_1/android_apk/Android_8.5.5.5105_537066978.apk";
  String TestText =
      "交通指引成都天府新区华天兴能燃气有限责任公司华阳客服中心附近的公交站:广都上街华阳大道口、广都中街华阳大道口、输气大厦、广都上街、南阳盛世、华阳地税所、广都上街华阳大道口、华阳大道广都中街口、华阳大道广都中街口、华阳大道广都中街、广都上街、南阳盛世、丽都街东、广都中街、正东中街、华阳大市场。成都天府新区华天兴能燃气有限责任公司华阳客服中心附近的公交车:815路、829路、T102路环线、517路、T101路、华阳4A路、501路、801路、813路、825B路、823路、825A路、826路、821路、827路、828路、843路、T103路、华阳2A路、T106路、815A路、华阳5路、807路等。打车去成都天府新区华天兴能燃气有限责任公司华阳客服中心多少钱：成都市出租车的起步价是8.0元、起步距离2.0公里、 每公里1.9元、无燃油附加费 ，请参考。自驾去成都天府新区华天兴能燃气有限责任公司华阳客服中心怎么走：请输入您的出发点，帮您智能规划驾车线路。";
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
    print("测试页生命周期变化：$state");
  }

  Future<void> pop() async {
    await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    print("测试页");
    print("build");
    print("底部条高度：${ScreenUtil.instance.bottomBarHeight}");
    return Scaffold(
      appBar: CustomAppBar(
        titleString: "测试页",
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("测试用页面，可随意添加组件"),

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
                      child: Text("组件设置偏移"),
                    ),
                  )
                ],
              ),
              //watch会监听全部数据
              Text("用户ID：${context.watch<ProfileNotifier>().profile.uid}"),
              Text("用户名：${context.watch<ProfileNotifier>().profile.nickName}"),
              Text("用户头像地址：${context.watch<ProfileNotifier>().profile.avatarUri}"),
              //select只监听想要的数据 当其他数据发生变化时不会触发更新
              Text("用户ID：${context.select((ProfileNotifier value) => value.profile.uid)}"),
              Text("用户名：${context.select((ProfileNotifier value) => value.profile.nickName)}"),
              Text("用户头像地址：${context.select((ProfileNotifier value) => value.profile.avatarUri)}"),
              //用consumer的方式监听数据
              Consumer<ProfileNotifier>(
                builder: (context, notifier, child) {
                  return Column(
                    children: [
                      Text("用户ID：${notifier.profile.uid}"),
                      Text("用户名：${notifier.profile.nickName}"),
                      Text("用户头像地址：${notifier.profile.avatarUri}"),
                    ],
                  );
                },
              ),
              //用Selector的方式监听数据
              Selector<ProfileNotifier, int>(builder: (context, uid, child) {
                return Text("用户ID：$uid");
              }, selector: (context, notifier) {
                return notifier.profile.uid;
              }),
              Selector<ProfileNotifier, String>(builder: (context, nickName, child) {
                return Text("用户名：$nickName");
              }, selector: (context, notifier) {
                return notifier.profile.nickName;
              }),
              Selector<ProfileNotifier, String>(builder: (context, avatarUri, child) {
                return Text("用户头像地址：$avatarUri");
              }, selector: (context, notifier) {
                return notifier.profile.avatarUri;
              }),
              Builder(
                builder: (context) {
                  return RaisedButton(
                    onPressed: () => _changeUser(context),
                    child: Text("换个用户(不会上报或入库)"),
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
                        //       "跑马灯样式文本样式文本样式文本"
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
                                "跑马灯样式文本样式文本样式文本",
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
                    child: Text("换个用户名(不会上报或入库)"),
                  );
                },
              ),
              RaisedButton(
                onPressed: () {
                  AppRouter.navigateToLoginTestPage(context);
                },
                child: Text("登录入口"),
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
                    child: Text("七牛上传测试"),
                  ),
                  RaisedButton(
                    onPressed: () {
                      Size c = getTextSize("查询数据库", TextStyle(fontSize: 16), 1);
                      print("++++++++++++++++$c+++++++++++++++++++++++");
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return MediaTestPage();
                      }));
                    },
                    child: Text("图片视频测试"),
                  ),
                ],
              ),
              RaisedButton(
                onPressed: () {
                  AppRouter.navigateToRCTestPage(context, context.read<ProfileNotifier>().profile);
                },
                child: Text("Fluro跳转融云测试页"),
              ),
              RaisedButton(
                onPressed: () {
                  openSerialPopupBottom(context: context);
                },
                // openSerialPopupBottom
                child: Text("连续弹窗测试"),
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
                    child: Text("声网测试"),
                  ),
                  RaisedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return ActivationTestPage();
                      }));
                    },
                    child: Text("激活登录测试"),
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
                    child: Text("直播日程页"),
                  ),
                  RaisedButton(
                    onPressed: () {
                      AppRouter.navigateToVideoCourseList(context);
                    },
                    child: Text("视频课程页"),
                  ),
                  RaisedButton(
                    onPressed: () {
                      jumpChatPageTest(context);
                    },
                    child: Text("聊天界面"),
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
                  child: Text("直播"),
                ),
                RaisedButton(
                  onPressed: () async {
                    Map<String, String> result = await _videoDownloadCheck();
                    if (result == null) {
                      ToastShow.show(msg: "还没有下载完视频，先去下载测试页下载", context: context);
                    } else {
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return VideoCoursePlayPage(result, null);
                      }));
                    }
                  },
                  child: Text("视频1"),
                ),
                RaisedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return VideoCoursePlayPage2();
                    }));
                  },
                  child: Text("视频2"),
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
                child: Text("直播测试页"),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RaisedButton(
                    onPressed: () {
                      bool isFirst = AppPrefs.isFirstLaunch();
                      print(isFirst);
                    },
                    child: Text("从SP中取值"),
                  ),
                  RaisedButton(
                    onPressed: () {
                      AppPrefs.setIsFirstLaunch(false);
                    },
                    child: Text("将isFirstLaunch设置为false"),
                  ),
                ],
              ),
              RaisedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return DownloadTestPage();
                  }));
                },
                child: Text("下载测试页"),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                RaisedButton(
                  onPressed: () {
                    showAppDialog(context,
                        title: "测试标题",
                        info: "测试内容多一点多一点测试内容多一点多一点测试内容多一点多一点测试内容多一点多一点",
                        cancel: AppDialogButton("取消", () {
                          print("点了取消");
                          return true;
                        }),
                        confirm: AppDialogButton("确定", () {
                          print("点了确定");
                          return true;
                        }));
                  },
                  child: Text("提示框1"),
                ),
                RaisedButton(
                  onPressed: () {
                    showAppDialog(context,
                        title: "今天吃什么",
                        info: "必须选一个，不选不能关弹窗",
                        barrierDismissible: false,
                        buttonList: [
                          AppDialogButton("乡村基", () {
                            print("点了乡村基");
                            return true;
                          }),
                          AppDialogButton("喜多米", () {
                            print("点了喜多米");
                            return true;
                          }),
                          AppDialogButton("猪脚饭", () {
                            print("点了猪脚饭");
                            return true;
                          }),
                        ]);
                  },
                  child: Text("提示框2"),
                ),
                RaisedButton(
                  onPressed: () {
                    // showAppDialog(context,
                    //     info: "确认退出当前试听课程吗？",
                    //     topImageUrl: "assets/png/unfinished_training_png.png",
                    //     isTransparentBack:true,
                    //     cancel: AppDialogButton("仍要退出", () {
                    //       //先暂停再退出页面 避免返回到上一个界面后仍在播放一小段时间
                    //       // _controller?.pause();
                    //       // Navigator.pop(context);
                    //       return true;
                    //     }),
                    //     confirm: AppDialogButton("继续训练", () {
                    //       return true;
                    //     }));

                    showAppDialog(
                      context,
                      circleImageUrl: "",
                      topImageUrl: "",
                      title: "有图的版本",
                      info: "还没有做加载图片，只是占位图",
                      confirm: AppDialogButton("我知道了", () {
                        print("点了我知道了");
                        return true;
                      }),
                    );
                  },
                  child: Text("提示框3"),
                ),
                RaisedButton(
                  onPressed: () {
                    showVolumePopup(context);
                  },
                  child: Text("音量"),
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
              //     child: Text("视频课结果页"),
              //   ),
              // ]),
              RaisedButton(
                onPressed: () {
                  Navigator.of(context).push(new MaterialPageRoute(builder: (context) {
                    //     return SliverListDemoPage();
                    return ExplosionImageTest();
                  }));
                },
                child: Text("粒子爆炸"),
              ),
              RaisedButton(
                onPressed: () {
                  Navigator.of(context).push(new MaterialPageRoute(builder: (context) {
                    //     return SliverListDemoPage();
                    return TiktokHome();
                  }));
                },
                child: Text("左滑测试"),
              ),
              RaisedButton(
                onPressed: () {
                  Navigator.of(context).push(new MaterialPageRoute(builder: (context) {
                    //     return SliverListDemoPage();
                    return TagCloudPage();
                  }));
                },
                child: Text("标签云测试"),
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
                            content: "这是描述\n该版本修复了。。。。\n解决了。。。\n解决了。。。\n解决了。。。\n解决了。。。\n解决了。。。",
                            strong: false,
                            context: context,
                            url: url);
                      },
                      child: Text("获取最新版本"),
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
                    SizedBox(height: 50),
                  ]),
              RaisedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return JpushTestPage();
                  }));
                },
                child: Text("极光测试页"),
              ),
              RaisedButton(
                  onPressed: () {
                    JPush().getLaunchAppNotification().then((value) {
                      print("getLaunchAppNotification:$value");
                      ToastShow.show(msg: "getLaunchAppNotification:$value", context: context);
                    });
                  },
                  child: Text("iOS获取打开APP的推送内容")),
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
                  child: Text("ListView性能测试")),
              RaisedButton(
                  onPressed: () async {
                    ToastShow.show(
                        msg: "判断手机厂商:${await CheckPhoneSystemUtil.init().getPhoneSystem()}", context: context);
                    print("判断手机厂商:${await CheckPhoneSystemUtil.init().getPhoneSystem()}");
                    print("是不是华为手机:${await CheckPhoneSystemUtil.init().isEmui()}");
                  },
                  child: Text("判断手机厂商")),
              RatingBar.builder(
                /// 定义要设置到评级栏的初始评级
                initialRating: 3,
                /// 设置最低评级默认为 0。
                minRating: 1,
                direction: Axis.horizontal,
                /// 默认为 false。 设置 true 启用半评级支持。
                allowHalfRating: true,
                // 如果设置为 true，将禁用评分栏上的任何手势。默认为false。
                ignoreGestures: false,
                /// 如果设置为 true，则评级栏项目在被触摸时会发光。默认为true。
                glow: false,
                // 设置大小
                itemSize: 24,
                itemCount: 5,
                itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
                itemBuilder: (context, index) {
                  return Icon(
                    Icons.star,
                    color: Colors.amber,
                  );
                },
                // 每当评级更新时返回当前评级。
                onRatingUpdate: (rating) {
                  print(rating);
                },
              ),

              RaisedButton(
                  onPressed: () async {
                    print("是否同意用户协议::${AppPrefs.isAgreeUserAgreement()}");
                    if (!AppPrefs.isAgreeUserAgreement()) {
                      print("11111111");
                      // Future.delayed(Duration.zero, () {
                      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                        showAppDialog(context,
                            confirm: AppDialogButton("同意", () {
                              return true;
                            }),
                            cancel: AppDialogButton("取消并退出", () {
                              // pop();
                              if (Platform.isIOS) {
                                // MoveToBackground.moveTaskToBack();
                                // MoveToBackground.moveTaskToBack();
                                exit(0);

                                ///以编程方式退出，彻底但体验不好
                              } else if (Platform.isAndroid) {
                                MoveToBackground.moveTaskToBack();
                                // SystemNavigator.pop(); //官方推荐方法，但不彻底
                              }
                              return true;
                            }),
                            title: "用户协议和隐私政策",
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
                  child: Text("用户协议和隐私政策")),
              RaisedButton(
                  onPressed: () {
                    // Loading.showLoading(context, infoText: "测试");
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
                  child: Text("开始时间结束时间选择")),
              _showSelectJoinTimePopupWindow(),
              RaisedButton(
                  onPressed: () {
                    openUserNumberPickerBottomSheet(
                        context: context,
                        start: 17,
                        end: 39,
                        onChoseCallBack: (number) {
                          print('---------------------返回的人数-$number');
                        });
                  },
                  child: Text("人数选择弹窗测试")),
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
      print('====================版本model有值');
      if (model.version != AppConfig.version) {
        ToastShow.show(msg: "当前版本${AppConfig.version}   最新版本${model.version}", context: context);
      } else {
        if (model.os == CheckPhoneSystemUtil.platform && url != null) {
          if (CheckPhoneSystemUtil.init().isAndroid()) {
            String oldPath = await FileUtil().getDownloadedPath(url);
            if (oldPath != null) {
              showAppDialog(
                context,
                title: "检测到新版本安装包，是否安装？",
                cancel: AppDialogButton("不安装", () {
                  return true;
                }),
                confirm: AppDialogButton("安装", () {
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
