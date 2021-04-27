

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/dialog.dart';

import 'lord_qr_code_page.dart';

class NewUserPromotionPage extends StatefulWidget {
  @override
  _NewUserPromotionPageState createState() => _NewUserPromotionPageState();
}

class _NewUserPromotionPageState extends State<NewUserPromotionPage> {
  String image="https://ss1.bdstatic.com/70cFvXSh_Q1YnxGkpoWK1HF6hhy/it/u=2932957420,533255517&fm=26&gp=0.jpg";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleString: "活动界面",
      ),
      body:  Container(
        child: Column(
          children: [
            Expanded(child: SizedBox(
              child: SingleChildScrollView(
                child: Container(
                  child: Image.network(image,fit: BoxFit.cover),
                ),
              ),
            )),
            Container(
              height: 48,
              width: ScreenUtil.instance.width,
              color: Colors.white,
              child: GestureDetector(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 32,vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    "报名",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18,color: Colors.white),
                  ),
                ),
                onTap: (){
                  showAppDialog(context,
                      title: "报名",
                      info: "确定要报名参加训练营吗？",
                      barrierDismissible: false,
                      cancel: AppDialogButton("取消", () {
                        print("点了取消");
                        return true;
                      }),
                      confirm: AppDialogButton("确定", () {
                        print("点击了确定");
                        jumpPage();
                        return true;
                      }));
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  jumpPage()async{
    Navigator.of(context).pop();
    AppRouter.navigateLordQRCodePage(context);
  }
}
