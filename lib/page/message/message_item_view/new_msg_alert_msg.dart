import 'package:flutter/cupertino.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/util/screen_util.dart';

class NewMsgAlertMsg extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: ScreenUtil.instance.width,
      padding: EdgeInsets.symmetric(vertical: 12),
      child: UnconstrainedBox(
        child: Container(
          child: Row(
            children: [
              Container(
                height: 1,
                width: 32,
                color: AppColor.textSecondary,
              ),
              SizedBox(width: 6),
              Text("以下为最新消息", style: AppStyle.text1Regular12),
              SizedBox(width: 6),
              Container(
                height: 1,
                width: 32,
                color: AppColor.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
