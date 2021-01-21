
import 'dart:math';

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/version_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/config/config.dart';
import 'package:mirror/config/shared_preferences.dart';
import 'package:mirror/data/dto/profile_dto.dart';
import 'package:mirror/data/model/version_model.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:mirror/page/activation_test_page.dart';
import 'package:mirror/page/agora_input_page.dart';
import 'package:mirror/page/download_test_page.dart';
import 'package:mirror/page/media_test_page.dart';
import 'package:mirror/page/qiniu_test_page.dart';
import 'package:mirror/page/training/live_broadcast/live_room_page.dart';
import 'package:mirror/page/training/video_course/video_course_result_page.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/text_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/dialog.dart';
import 'package:mirror/widget/volume_popup.dart';
import 'package:provider/provider.dart';

import 'message/message_chat_page_manager.dart';
import 'profile/login_test_page.dart';
import 'training/video_course/video_course_play_page2.dart';
import 'training/video_course/video_course_play_page.dart';

/// test_page
/// Created by yangjiayi on 2020/10/27.

class TestPage extends StatefulWidget {
  @override
  _TestState createState() => _TestState();
}

class _TestState extends State<TestPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; //必须重写

  @override
  Widget build(BuildContext context) {
    print("测试页");
    print("build");
    print("底部条高度：${ScreenUtil.instance.bottomBarHeight}");
    return Scaffold(
      appBar: AppBar(
        title: Text("测试页"),
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
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                RaisedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return VideoCourseResultPage();
                    }));
                  },
                  child: Text("视频课结果页"),
                ),
              ]),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                RaisedButton(
                  onPressed: () {
                    _getNewVersion(context);
                  },
                  child: Text("获取最新版本"),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

void _getNewVersion(BuildContext context)async{
  VersionModel model = await getNewVersion();
  if(model!=null){
    print('====================版本model有值');
    if(model.version==AppConfig.version){
      ToastShow.show(msg: "当前版本${AppConfig.version}   最新版本${model.version}", context:context);
    }else{
      if(model.os==Application.platform){
          String path = await FileUtil().getDownloadedPath(model.url);
          if(path!=null){
            showAppDialog(context,
              title:"检测到新版本安装包，是否安装？",
              cancel:AppDialogButton("不安装",(){
                return true;
              }),
              confirm: AppDialogButton("安装",(){
                return true;
              }),
            );
          }else{
            showAppDialog(context, title:"获取到新版本，是否更新？",
              cancel:AppDialogButton("不更新",(){
                return true;
              }),
              progress: 7,
              confirm: AppDialogButton("更新",(){
                FileUtil().download(model.url, (taskId, received, total){
                    context.watch<AppDialogNotifier>().changeProgress(total/received);
                });
                return true;
              }),
            );
          }
      }
    }
  }else{
    print("======================版本model为空");
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
