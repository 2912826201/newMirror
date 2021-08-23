import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/config/config.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/version_model.dart';
import 'package:mirror/page/feed/ui_Control_Page.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/icon.dart';
import 'package:mirror/widget/protocol_web_view.dart';
import 'package:mirror/widget/version_update_dialog.dart';

//关于
class AboutPage extends StatefulWidget {
  bool haveNewVersion;
  VersionModel versionModel;

  AboutPage({this.haveNewVersion, this.versionModel});

  @override
  State<StatefulWidget> createState() {
    return _AboutPageState(haveNewVersion: haveNewVersion);
  }
}

class _AboutPageState extends State<AboutPage> {
  bool haveNewVersion;

  _AboutPageState({this.haveNewVersion});

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = ScreenUtil.instance.screenWidthDp;
    double height = ScreenUtil.instance.height;
    return Scaffold(
      backgroundColor: AppColor.mainBlack,
      appBar: CustomAppBar(
        titleString: "关于iFitness",
      ),
      body: Container(
        width: width,
        height: height - ScreenUtil.instance.statusBarHeight,
        padding: EdgeInsets.only(bottom: 16),
        child: Column(
          children: [
            Container(
              height: 148,
              width: width,
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Spacer(),
                    GestureDetector(
                      onDoubleTap: () {
                        Navigator.of(context).push(new MaterialPageRoute(builder: (context) {
                          return UiControllerPage();
                        }));
                      },
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          image: DecorationImage(image: AssetImage("images/test/ic_launcher.png"), fit: BoxFit.cover),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Text(
                      "${AppConfig.version}-${AppConfig.buildNumber}",
                      style: AppStyle.textHintRegular12,
                    ),
                    Spacer(),
                  ],
                ),
              ),
            ),
            GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return ProtocolWebView(
                      type: 0,
                    );
                  }));
                },
                child: _itemRow("用户协议")),
            GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return ProtocolWebView(
                      type: 1,
                    );
                  }));
                },
                child: _itemRow("隐私权政策")),
            haveNewVersion
                ? InkWell(
                    onTap: () {
                      showVersionDialog(
                          context: context,
                          content: widget.versionModel.description,
                          url: widget.versionModel.url,
                          strong: false);
                    },
                    child: _itemRow("版本更新"),
                  )
                : Container(),
            Spacer(),
            Center(
              child: Text(
                "Copyright@2019 iFitness.All rights Reserved",
                style: AppStyle.text1Regular13,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _itemRow(String text) {
    return Container(
      height: 48,
      width: ScreenUtil.instance.width,
      padding: EdgeInsets.only(left: 16, right: 16),
      child: Center(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              text,
              style: AppStyle.whiteRegular16,
            ),
            Spacer(),
            text == "版本更新" && haveNewVersion
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 40,
                      height: 18,
                      color: AppColor.mainRed,
                      child: Center(
                        child: Text(
                          "NEW",
                          style: AppStyle.whiteRegular12,
                        ),
                      ),
                    ),
                  )
                : Container(),
            SizedBox(
              width: 12,
            ),
            AppIcon.getAppIcon(
              AppIcon.arrow_right_18,
              18,
              color: AppColor.textWhite60,
            ),
          ],
        ),
      ),
    );
  }
}
