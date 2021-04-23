

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mirror/api/message_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:qr_flutter/qr_flutter.dart';

class LordQRCodePage extends StatefulWidget {
  @override
  _LordQRCodePageState createState() => _LordQRCodePageState();
}

class _LordQRCodePageState extends State<LordQRCodePage> {
  String codeData;
  int uid=1002885;
  String name="大灰狼";
  String image="http://devpic.aimymusic.com/ifapp/1002885/1618397003729.jpg";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getShortUrl();
  }
  _getShortUrl() async {
    Map<String, dynamic> map = await getShortUrl(type: 3, targetId: uid);
    if (map != null) {
      codeData = map["url"];
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleString: "报名方式",
      ),
      body: Container(
        width: ScreenUtil.instance.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 30),
            GestureDetector(
              child: Container(
                height: 100.0,
                width: ScreenUtil.instance.width-64,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColor.bgWhite,width: 1),
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "欢迎参加训练营",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 28,color: AppColor.textPrimary1),
                    ),
                    Text(
                      "点击复制:复制成功发送给导师,由导师分配群聊",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 10,color: AppColor.textPrimary3),
                    ),
                  ],
                ),
              ),
              onTap: (){
                Clipboard.setData(ClipboardData(text: "参加训练营"));
                ToastShow.show(msg: "复制成功", context: context);
              },
            ),
            SizedBox(height: 30),
            Container(
              height: 100.0,
              width: ScreenUtil.instance.width-64,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColor.bgWhite,width: 1),
              ),
              alignment: Alignment.center,
              child: Text(
                "老师名字：$name",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20,color: AppColor.textPrimary1),
              ),
            ),
            SizedBox(height: 60),
            QrImage(
              data: codeData != null ? codeData : "没有数据",
              size: 100,
              padding: EdgeInsets.zero,
              backgroundColor: AppColor.white,
              version: QrVersions.auto,
            ),
            SizedBox(height: 30),
            GestureDetector(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 32,vertical: 8),
                decoration: BoxDecoration(
                  color: AppColor.textPrimary1,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "点击添加导师",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16,color: AppColor.white),
                ),
              ),
              onTap: (){
                AppRouter.navigateToMineDetail(context,uid, avatarUrl: image, userName: name);
              },
            )
          ],
        ),
      ),
    );
  }
}
