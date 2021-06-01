

import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
          onPageStarted: pageStartedCallback,
          onPageFinished: pageFinishedCallback,
          onWebResourceError: webResourceErrorCallback,
          onWebViewCreated:webViewCreatedCallback,
          initialUrl: StringUtil.isURL(widget.url)?widget.url:"https://www.baidu.com",
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
      if(count>100){
        print("没有获取到title");
        break;
      }
      if(StringUtil.isURL(title)){
        title="";
      }
    }
    print("title:$title,count:$count");
    if(title!=null){
      this.title=title;
      if(mounted) {
        setState(() {

        });
      }
    }
  }


  _requestPopListener()async{
    if(await _requestPop()){
      Navigator.pop(context);
    }
  }

  // 监听返回事件
  Future<bool> _requestPop() async{
    if(await _webViewController.canGoBack()){
      _webViewController.goBack();
      return new Future.value(false);
    }
    return new Future.value(true);
  }

}
