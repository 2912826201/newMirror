import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/config/config.dart';
import 'package:mirror/page/message/message_chat_page_manager.dart';
import 'package:mirror/page/profile/profile_detail_page.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/string_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:webview_flutter/platform_interface.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatefulWidget {
  final String url;

  WebViewPage(this.url);

  @override
  _WebViewPageState createState() => _WebViewPageState();

}

class _WebViewPageState extends State<WebViewPage> {
  WebViewController _webViewController;
  String title="";



  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: CustomAppBar(
          titleString: title,
          leadingOnTap: _requestPopListener,
        ),
        body: WebView(
          debuggingEnabled: true,
          javascriptMode: JavascriptMode.unrestricted,
          onPageStarted: pageStartedCallback,
          onPageFinished: pageFinishedCallback,
          onWebResourceError: webResourceErrorCallback,
          javascriptChannels: [_jumpPageJsChannel(context)].toSet(),
          onWebViewCreated: webViewCreatedCallback,
          initialUrl: StringUtil.isURL(widget.url) ? widget.url : "https://www.baidu.com",
        ),
      ),
      onWillPop: _requestPop,
    );
  }

  pageStartedCallback(String url){
    print("pageStartedCallback,url:$url");
  }

  pageFinishedCallback(String url){
    print("pageFinishedCallback,url:$url");
    if(_webViewController!=null){
      _getTitle();
    }
  }

  webResourceErrorCallback(WebResourceError error){
    print("error:${error.toString()}");
  }


  webViewCreatedCallback(WebViewController controller)async{
    this._webViewController=controller;
  }


  _getTitle()async{
    String title=await _webViewController.getTitle();
    int count=0;
    while(title==null||title.length<1){
      count++;
      await Future.delayed(Duration(milliseconds: 100),()async{
        title=await _webViewController.getTitle();
      });
      if (count > 100) {
        print("没有获取到title");
        break;
      }
      if (StringUtil.isURL(title)) {
        title = "";
      }
    }
    print("title:$title,count:$count");
    _updateBtnClickListener();
    if (title != null) {
      this.title = title;
      if (mounted) {
        setState(() {});
      }
    }
  }

  _updateBtnClickListener() async {
    String url = await _webViewController.currentUrl();
    if (!url.contains("aimymusic.com/h5/app")) {
      return;
    }
    String javascriptStringBtn1 = "var btn=document.getElementsByClassName(\"PageHeader-btn\")[0];" +
        "var btn1=btn.cloneNode(false);" +
        "btn1.innerHTML=btn.innerHTML;" +
        "document.getElementsByClassName(\"PageHeader-div\")[0].appendChild(btn1);" +
        "document.getElementsByClassName(\"PageHeader-btn\")[0].style.display=\"none\";" +
        "document.getElementsByClassName(\"PageHeader-btn\")[1].setAttribute('onclick','JumpPageIf.postMessage(window.location.href)');";
    String javascriptStringBtn2 = "window.setInterval(function(){" +
        "  if(document.getElementsByClassName(\"popup-bottom\").length>0){" +
        "    if(document.getElementsByClassName(\"popup-bottom-btn\").length==1){" +
        "      var btn=document.getElementsByClassName(\"popup-bottom-btn\")[0];" +
        "      var btn1=btn.cloneNode(false);" +
        "      btn1.innerHTML=btn.innerHTML;" +
        "      document.getElementsByClassName(\"popup-bottom\")[0].appendChild(btn1);" +
        "      document.getElementsByClassName(\"popup-bottom-btn\")[0].style.display=\"none\";" +
        "      document.getElementsByClassName(\"popup-bottom-btn\")[1].setAttribute('onclick','JumpPageIf.postMessage(window.location.href)');" +
        "    }" +
        "  }" +
        "}, 100);";

    await _webViewController.evaluateJavascript(javascriptStringBtn1);
    await _webViewController.evaluateJavascript(javascriptStringBtn2);
  }

  // 创建 JavascriptChannel
  JavascriptChannel _jumpPageJsChannel(BuildContext context) => JavascriptChannel(
      name: 'JumpPageIf',
      onMessageReceived: (JavascriptMessage message) {
        print("跳转界面解析:${message.message}");
        _analyzeJumpPageUrl(message.message);
        // ToastShow.show(msg: "跳转界面解析:${message.message}", context: context);
      });

  _requestPopListener() async {
    if (await _requestPop()) {
      Navigator.pop(context);
    }
  }

  // 监听返回事件
  Future<bool> _requestPop() async {
    if (await _webViewController.canGoBack()) {
      _webViewController.goBack();
      return new Future.value(false);
    }
    return new Future.value(true);
  }

  void _analyzeJumpPageUrl(String url) {
    if (!StringUtil.isURL(url)) {
      print("不是url:$url");
      return;
    } else if (!(url.contains(AppConfig.getApiHost()))) {
      print("不是我们的url:$url");
      return;
    }

    List<String> strs = url.split("?");
    Map<String, dynamic> params = {};
    if (strs.length > 1) {
      List<String> paramsStrs = strs.last.split("&");
      paramsStrs.forEach((str) {
        params[str.split("=").first] = str.split("=").last;
      });
    }

    if (url.contains("/topic/?")) {
      print("跳转话题详情页params:${params.toString()}");
      if (params["topicId"] != null) {
        try {
          int topicId = int.parse(params["topicId"].toString());
          Navigator.pop(context);
          AppRouter.navigateToTopicDetailPage(context, topicId);
        } catch (e) {
          print("参数有误params:${params.toString()}");
        }
      }
    } else if (url.contains("/live/?")) {
      print("跳转直播课程详情页params:${params.toString()}");

      if (params["courseId"] != null) {
        try {
          int courseId = int.parse(params["courseId"].toString());
          Navigator.pop(context);
          AppRouter.navigateToLiveDetail(context, courseId);
        } catch (e) {
          print("参数有误params:${params.toString()}");
        }
      }
    } else if (url.contains("/video/?")) {
      print("跳转视频课程详情页params:${params.toString()}");

      if (params["courseId"] != null) {
        try {
          int courseId = int.parse(params["courseId"].toString());
          Navigator.pop(context);
          AppRouter.navigateToVideoDetail(context, courseId);
        } catch (e) {
          print("参数有误params:${params.toString()}");
        }
      }
    } else if (url.contains("/feed/?")) {
      print("跳转动态详情页params:${params.toString()}");

      if (params["feedId"] != null) {
        try {
          int feedId = int.parse(params["feedId"].toString());
          Navigator.pop(context);
          getFeedDetail(feedId, context);
        } catch (e) {
          print("参数有误params:${params.toString()}");
        }
      }
    } else if (url.contains("/user/?")) {
      print("跳转用户详情页params:${params.toString()}");
      if (params["userId"] != null) {
        try {
          int userId = int.parse(params["userId"].toString());
          Navigator.pop(context);
          jumpToUserProfilePage(context, userId);
        } catch (e) {
          print("参数有误params:${params.toString()}");
        }
      }
    } else {
      print("未找到相应的类型:url:$url");
    }
  }
}
