import 'package:mirror/data/model/media_file_model.dart';
import 'package:mirror/page/profile/training_gallery/training_gallery_page.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

/// runtime_properties
/// Created by yangjiayi on 2021/6/24.

/// 这里存放运行中生成的属性 级别较低的全局变量
/// 一些值基本上是暂存 一次性使用的 所以需要注意合适的时机清空或复原为默认值

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
}