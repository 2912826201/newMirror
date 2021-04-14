import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/config/shared_preferences.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/feed/post_feed.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/media_file_model.dart';
import 'package:mirror/data/model/peripheral_information_entity/peripheral_information_entify.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/event_bus.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/dialog.dart';
import 'package:mirror/widget/feed/release_feed_input_formatter.dart';
import 'package:flutter/cupertino.dart';
import 'package:mirror/widget/icon.dart';
import 'dart:io';
import 'package:provider/provider.dart';

import 'package:toast/toast.dart';

import '../release_page.dart';

class FeedHeader extends StatelessWidget {
  SelectedMediaFiles selectedMediaFiles;
  TextEditingController controller;

  FeedHeader({this.selectedMediaFiles, this.controller});

  // 发布动态
  pulishFeed(BuildContext context, String inputText, int uid, List<Rule> rules, PeripheralInformationPoi poi) async {
    // var a = utf8.encode(inputText);
    // print("encode:${a}");
    // var b = utf8.decode(a);
    // print("decode::$b");
    // 转换base64
    // String timeStr = DateTime.now().millisecondsSinceEpoch.toString();
    // int i = 0;
    // // 图片
    // if (selectedMediaFiles.type == mediaTypeKeyImage) {
    //   for (MediaFileModel v in selectedMediaFiles.list) {
    //     if (v.croppedImageData != null) {
    //       i++;
    //       File imageFile = await FileUtil().writeImageDataToFile(v.croppedImageData, timeStr + i.toString(),isPublish:true);
    //       v.file = imageFile;
    //     }
    //   }
    // } else if (selectedMediaFiles.type == mediaTypeKeyVideo) {
    //   for (MediaFileModel v in selectedMediaFiles.list) {
    //     if (v.thumb != null) {
    //       i++;
    //       File thumbFile = await FileUtil().writeImageDataToFile(v.thumb, timeStr + i.toString(),isPublish:true);
    //       v.thumbPath = thumbFile.path;
    //     }
    //   }
    // }
    print("打印一下规则$rules");

    // 获取当前时间戳
    int currentTimestamp = DateTime.now().millisecondsSinceEpoch;
    PostFeedModel feedModel = PostFeedModel();
    PostprogressModel postprogressModel = PostprogressModel();
    postprogressModel.showPulishView = true;
    postprogressModel.plannedSpeed = 0.0;
    List<AtUsersModel> atUsersModel = [];
    String address;
    String cityCode;
    String latitude;
    String longitude;
    List<TopicDtoModel> topics = [];
    feedModel.content = inputText;
    feedModel.uid = uid;
    feedModel.currentTimestamp = currentTimestamp;
    if (inputText.length > 0) {
      // 检测文本
      Map<String, dynamic> textModel = await feedTextScan(text: inputText);
      if (textModel["state"]) {
        print("feedModel.content${feedModel.content}");
        for (Rule rule in rules) {
          if (rule.isAt) {
            AtUsersModel atModel = AtUsersModel();
            atModel.index = rule.startIndex;
            atModel.len = rule.endIndex;
            atModel.uid = rule.id;
            atUsersModel.add(atModel);
          } else {
            print("查看发布话题动态——————————————————————————————");
            print(rule.toString());
            TopicDtoModel topicDtoModel = TopicDtoModel();

            if (rule.id != -1) {
              topicDtoModel.id = rule.id;
              topicDtoModel.index = rule.startIndex;
              topicDtoModel.len = rule.endIndex;
            } else {
              topicDtoModel.name = rule.params.substring(1, rule.params.length);
              topicDtoModel.index = rule.startIndex;
              topicDtoModel.len = rule.endIndex;
            }
            topics.add(topicDtoModel);
          }
        }
        if (poi != null) {
          address = poi.name;
          longitude = poi.location.split(",")[0];
          latitude = poi.location.split(",")[1];
          cityCode = poi.citycode;
        }
        feedModel.atUsersModel = atUsersModel;
        feedModel.address = address;
        feedModel.cityCode = cityCode;
        feedModel.latitude = latitude;
        feedModel.longitude = longitude;
        feedModel.topics = topics;

        feedModel.selectedMediaFiles = selectedMediaFiles;
        postprogressModel.postFeedModel = feedModel;
        print("打印一下￥￥${(feedModel.selectedMediaFiles.list.length)}");
        context.read<ReleaseFeedInputNotifier>().rules.clear();
        context.read<ReleaseFeedInputNotifier>().selectAddress = null;
        print('--------------Navigator------Navigator-------------Navigator------');
        // 传入发布动态model
        EventBus.getDefault().post(msg: postprogressModel, registerName: EVENTBUS_POST_PORGRESS_VIEW);
        Navigator.of(context).popUntil(ModalRoute.withName(AppRouter.pathIfPage));
        print("打印结束");
      } else {
        ToastShow.show(msg: "你发布的动态可能存在敏感内容", context: context, gravity: Toast.CENTER);
      }
    } else {
      for (Rule rule in rules) {
        if (rule.isAt) {
          AtUsersModel atModel = AtUsersModel();
          atModel.index = rule.startIndex;
          atModel.len = rule.endIndex;
          atModel.uid = rule.id;
          atUsersModel.add(atModel);
        } else {
          print(rule.toString());
          TopicDtoModel topicDtoModel = TopicDtoModel();

          if (rule.id != -1) {
            topicDtoModel.id = rule.id;
            topicDtoModel.index = rule.startIndex;
            topicDtoModel.len = rule.endIndex;
          } else {
            print('-------------------rule.id = -1');
            topicDtoModel.name = rule.params.substring(1, rule.params.length);
            topicDtoModel.index = rule.startIndex;
            topicDtoModel.len = rule.endIndex - 1;
          }
          topics.add(topicDtoModel);
          print('-------------topics------------${topics.toString()}');
        }
      }
      if (poi != null) {
        address = poi.name;
        longitude = poi.location.split(",")[0];
        latitude = poi.location.split(",")[1];
        cityCode = poi.citycode;
      }
      feedModel.atUsersModel = atUsersModel;
      feedModel.address = address;
      feedModel.cityCode = cityCode;
      feedModel.latitude = latitude;
      feedModel.longitude = longitude;
      feedModel.topics = topics;
      feedModel.selectedMediaFiles = selectedMediaFiles;
      postprogressModel.postFeedModel = feedModel;
      print("图片视频长度：：：：${selectedMediaFiles.list.length}");
      context.read<ReleaseFeedInputNotifier>().rules.clear();
      context.read<ReleaseFeedInputNotifier>().selectAddress = null;
      FocusScope.of(context).requestFocus(FocusNode());
      // EventBus.getDefault().post(registerName:EVENTBUS_POSTFEED_CALLBACK);
      print('--------------Navigator------Navigator-------------Navigator------');
    }
    print("postprogressModel:::${postprogressModel.toString()}");

    Navigator.of(context).popUntil(ModalRoute.withName(AppRouter.pathIfPage));
    print("5555455555");
    // 传入发布动态model
    EventBus.getDefault().post(msg: postprogressModel, registerName: EVENTBUS_POST_PORGRESS_VIEW);
  }

  @override
  Widget build(BuildContext context) {
    //TODO 应改用CustomAppBar
    return Container(
      width: ScreenUtil.instance.screenWidthDp,
      height: 44,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(width: 0.5, color: Color(0xffe5e5e5))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            width: 8,
          ),
          CustomAppBarIconButton(
            svgName: AppIcon.nav_close,
            onTap: () {
              showAppDialog(
                context,
                confirm: AppDialogButton("确定", () {
                  FocusScope.of(context).requestFocus(FocusNode());
                  Navigator.of(context).pop(true);
                  return true;
                }),
                cancel: AppDialogButton("取消", () {
                  return true;
                }),
                title: "退出编辑",
                info: "退出后动态内容将不保存，确定放弃编辑动态吗？",
              );
            },
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              // 读取输入框最新的值
              var inputText = controller.text;

              // 获取输入框内的规则
              var rules = context.read<ReleaseFeedInputNotifier>().rules;

              // 获取选择的地址
              var poi = context.read<ReleaseFeedInputNotifier>().selectAddress;

              // 获取用户Id
              var uid = context.read<ProfileNotifier>().profile.uid;
              pulishFeed(context, inputText, uid, rules, poi);
            },
            child: Container(
                height: 28,
                width: 60,
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(14)),
                    // 监听输入框的值动态改变样式
                    color: AppColor.mainRed),
                child: Center(
                  child: const Text(
                    "发布",
                    style: TextStyle(color: AppColor.white, fontSize: 14, decoration: TextDecoration.none),
                  ),
                )),
          ),
          const SizedBox(
            width: 16,
          ),
        ],
      ),
    );
  }
}
