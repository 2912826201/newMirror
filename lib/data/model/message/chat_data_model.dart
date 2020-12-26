import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

import '../media_file_model.dart';
import 'chat_voice_model.dart';

class ChatDataModel {
  Message msg;
  bool isHaveAnimation = false;
  bool isTemporary = false;
  String content;
  String type;
  int status = RCSentStatus.Sent;
  MediaFileModel mediaFileModel;
  ChatVoiceModel chatVoiceModel;
}
