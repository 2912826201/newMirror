import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'custom_appbar.dart';

class ProtocolWebView extends StatefulWidget {
  ProtocolWebView({Key key , this.type});
  int type;
  @override
  _ProtocolWebViewState createState() => _ProtocolWebViewState();
}

class _ProtocolWebViewState extends State<ProtocolWebView> {
  WebViewController _webViewController;
  String filePath = 'assets/files/PlatformServices.html';
  String filePath1 = 'assets/files/privacyClause.html';
  // privacyClause.html
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(titleString: widget.type == 0 ? '艾美平台服务协议' : "艾美隐私条款"),
        body: WebView(
          initialUrl: '',
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController webViewController) {
            _webViewController = webViewController;
            _loadHtmlFromAssets();
          },
        ));
  }

  _loadHtmlFromAssets() async {
    String fileHtmlContents = await rootBundle.loadString( widget.type == 0 ? filePath : filePath1);
    _webViewController.loadUrl(
        Uri.dataFromString(fileHtmlContents, mimeType: 'text/html', encoding: Encoding.getByName('utf-8')).toString());
  }
}
