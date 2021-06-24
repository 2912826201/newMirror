import 'package:flutter/material.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/media_file_model.dart';
import 'package:mirror/data/notifier/machine_notifier.dart';
import 'package:mirror/data/notifier/user_interactive_notifier.dart';
import 'package:mirror/page/profile/training_gallery/training_gallery_page.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:provider/provider.dart';

import 'application.dart';

/// runtime_properties
/// Created by yangjiayi on 2021/6/24.

/// 这里存放运行中生成的属性 级别较低的全局变量
/// 一些值基本上是暂存 一次性使用的 所以需要注意合适的时机清空或复原为默认值
/// 一些是和当前用户有关的值 当用户登出时 要清空或复原为默认值
/// 用户消息相关的值移至MessageManager

class RuntimeProperties {

  //健身照片详情页返回内容
  static TrainingGalleryResult galleryResult;

  //发送验证码的全局计时
  static int smsCodeSendTime;

  //全局的记录发送验证码的手机号
  static String sendSmsPhoneNum;

  //用户分享的消息
  static Message shareMessage;

  // 用于传递所选图片视频内容，用完后需要删除
  static SelectedMediaFiles selectedMediaFiles;

  // 话题model的map
  static Map<int, TopicDtoModel> topicMap = {};

  //=====================================下面是用户相关================================================

  //是否显示新用户的dialog
  static bool isShowNewUserDialog = false;

  // 清空和用户相关的值的方法
  static clearUserRuntimeProperties(BuildContext appContext) {
    appContext.read<MachineNotifier>().setMachine(null);
    appContext.read<UserInteractiveNotifier>().clearProfileUiChangeModel();
    //TODO 其他的provider还需整理出来清掉
    isShowNewUserDialog = false;
  }
}