
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';

class NetworkLinkFailure extends StatefulWidget {
  @override
  _NetworkLinkFailureState createState() => _NetworkLinkFailureState();
}

class _NetworkLinkFailureState extends State<NetworkLinkFailure> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("网络连接失败"),
        centerTitle: true,
      ),
      body:  getBody(),
    );
  }


  Widget getBody(){
    var textStyle16 =TextStyle(fontSize: 16,color: AppColor.textPrimary1);
    var textStyle14 =TextStyle(fontSize: 14,color: AppColor.textPrimary1);
    var textStyle14bold =TextStyle(fontSize: 14,color: AppColor.textPrimary1,fontWeight: FontWeight.bold);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            Text("您的设备未能连接到网络",style: textStyle16,),
            SizedBox(height: 50),
            Text("如果需要连接到互联网，请参考以下方法：",style: textStyle14),
            SizedBox(height: 24),

            Container(
              child: RichText(
                textAlign: TextAlign.start,
                text: TextSpan(
                  style: textStyle14,
                  children:[
                    TextSpan(text: "进入设备"),
                    TextSpan(text: "“设置”-“${Application.platform==1?"无线局域网":"WLAN"}”",style: textStyle14bold),
                    TextSpan(text: "选择一个可用的WiFi热点接入。"),
                  ]
                ),
              ),
            ),

            SizedBox(height: 24),
            Container(
              child: RichText(
                textAlign: TextAlign.start,
                text: TextSpan(
                    style: textStyle14,
                    children:[
                      TextSpan(text: "进入设备"),
                      TextSpan(text: "“设置”-${Application.platform==1?"“蜂窝移动数据”":"移动网络"}",style: textStyle14bold),
                      TextSpan(text: "点击启用${Application.platform==1?"蜂窝数据":"数据网络"}（启用后运营商可能会收取数据通信费用）"),
                    ]
                ),
              ),
            ),
            SizedBox(height: 24),
            Text("如果您已接入无线局域网或${Application.platform==1?"蜂窝移动数据":"WLAN"}：",style: textStyle14),
            SizedBox(height: 24),
            Text("请检查您所连接的WiFi热点是否接入互联网，或该热点是否允许您的设备访问互联网。",style: textStyle14),
            SizedBox(height: 24),

            Visibility(
              visible: Application.platform==1,
              child: Container(
                child: RichText(
                  textAlign: TextAlign.start,
                  text: TextSpan(
                      style: textStyle14,
                      children:[
                        TextSpan(text: "请检查您的设备是否允许“咪哒”使用数据，进入设备"),
                        TextSpan(text: "“设置”-“无线局域网”-“使用WLAN与蜂窝移动网的应用”-“咪哒”",style: textStyle14bold),
                        TextSpan(text: "允许使用数据"),
                      ]
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
