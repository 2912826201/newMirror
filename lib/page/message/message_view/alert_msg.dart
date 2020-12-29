import 'package:flutter/cupertino.dart';
import 'package:mirror/config/application.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

import 'currency_msg.dart';

// ignore: must_be_immutable
class AlertMsg extends StatelessWidget {
  final RecallNotificationMessage recallNotificationMessage;
  final int position;
  final VoidMessageClickCallBack voidMessageClickCallBack;
  final VoidItemLongClickCallBack voidItemLongClickCallBack;
  final Map<String, dynamic> map;

  AlertMsg({
    this.recallNotificationMessage,
    this.position,
    this.voidMessageClickCallBack,
    this.voidItemLongClickCallBack,
    this.map,
  });

  bool isMyself;

  @override
  Widget build(BuildContext context) {
    isMyself = recallNotificationMessage.mOperatorId ==
        Application.profile.uid.toString();
    return getContentBoxItem(context);
  }

  Widget getContentBoxItem(BuildContext context) {
    return Container(
      height: 20,
      padding: EdgeInsets.symmetric(vertical: 12.0),
      child: Center(
        child: Text("撤回消息"),
      ),
    );
  }
}
