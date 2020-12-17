import 'package:flutter/cupertino.dart';

import '../bottom_sheet.dart';

typedef DeletedCallback = void Function(String content, BuildContext context); // 删除回调

typedef AttentionCallback = void Function(String content, BuildContext context); // 关注取消关注回调
typedef ReportCallback = void Function(String content, BuildContext context); // 举报回调


Future openMoreBottomSheet(
    { @required BuildContext context,
      @required bool isMe,
      DeletedCallback deletedCallback,
      AttentionCallback attentionCallback,
      ReportCallback reportCallback,
    }) async {
  await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
            child: Container(

            )
        );
      });
}
class FeedClickMore {

}