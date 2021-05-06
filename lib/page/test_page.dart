import 'dart:io';
import 'dart:math';

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/version_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/config/config.dart';
import 'package:mirror/config/shared_preferences.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/dto/profile_dto.dart';
import 'package:mirror/data/model/training/training_complete_result_model.dart';
import 'package:mirror/data/model/version_model.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:mirror/page/activation_test_page.dart';
import 'package:mirror/page/agora_input_page.dart';
import 'package:mirror/page/download_test_page.dart';
import 'package:mirror/page/media_test_page.dart';
import 'package:mirror/page/qiniu_test_page.dart';
import 'package:mirror/page/training/live_broadcast/live_room_page.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/text_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/dialog.dart';
import 'package:mirror/widget/icon.dart';
import 'package:mirror/widget/version_update_dialog.dart';

import 'package:mirror/widget/volume_popup.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'message/message_chat_page_manager.dart';
import 'training/video_course/video_course_play_page2.dart';
import 'training/video_course/video_course_play_page.dart';

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
              //     onPressed: () {
              //       TrainingCompleteResultModel result = TrainingCompleteResultModel();
              //       result.synthesisRank = 0.67;
              //       result.upperRank = 1.0;
              //       result.lowerRank = 0.8;
              //       result.coreRank = 0.33;
              //       result.completionDegree = 0.57;
              //       result.no = 233;
              //       result.calorie = 198;
              //       result.mseconds = 2040000;
              //       result.synthesisScore = 12894;
              //       AppRouter.navigateToVideoCourseResult(context, result);
              //     },
              //     child: Text("视频课结果页"),
              //   ),
              // ]),
              Container(
                color: AppColor.mainRed,
                child: Text(
                  "12345:67890",
                  style: TextStyle(fontSize: 32, fontFamily: "BebasNeue"),
                ),
              ),
              Container(
                color: AppColor.textHint,
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
                        _getNewVersion(context);
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
                  ]),Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.lightBlue,width: 1),
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 50),
                  ]),
            ],
          ),
        ),
      ),
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
        if (model.os == Application.platform && url != null) {
          if (Application.platform == 0) {
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
