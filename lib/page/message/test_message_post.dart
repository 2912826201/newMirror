import 'dart:math';

import 'package:mirror/data/model/message/chat_data_model.dart';
import 'package:mirror/data/model/message/chat_type_model.dart';

//生成字符串的model
ChatDataModel postText(String text) {
  ChatDataModel chatDataModel = new ChatDataModel();
  chatDataModel.id = Random().nextInt(10000000).toString();
  chatDataModel.nickName = "张三";
  chatDataModel.time = new DateTime.now().microsecondsSinceEpoch;
  chatDataModel.avatar =
      "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1608558159490&di=e16c52c33c6cd52559aae9829aaca4c5&imgtype=0&src=http%3A%2F%2Fcdn.duitang.com%2Fuploads%2Fitem%2F201406%2F03%2F20140603170900_MtE8Q.thumb.600_0.jpeg";
  var instanceMap = Map();
  instanceMap["type"] = ChatTypeModel.COMMENT_TEXT;
  instanceMap["text"] = text;
  chatDataModel.msg = instanceMap;
  chatDataModel.isHaveAnimation = true;
  return chatDataModel;
}
