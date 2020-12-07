import 'package:flutter/material.dart';
import 'package:mirror/api/api.dart';
import 'package:mirror/data/model/base_response_model.dart';

/// activation_test_page
/// Created by yangjiayi on 2020/12/7.

class ActivationTestPage extends StatefulWidget {
  @override
  _ActivationTestState createState() => _ActivationTestState();
}

class _ActivationTestState extends State<ActivationTestPage> {
  String _activationUrl = "/third/web/url/2dd";
  String _loginUrl = "";
  int _mid = 215338;
  Map _activationResult = {};
  Map _loginResult = {};

  @override
  Widget build(BuildContext context) {
    print("激活机器及扫码登录测试页");
    return Scaffold(
      appBar: AppBar(
        title: Text("激活机器及扫码登录测试页"),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("先确保APP用户已登录，在我的tab页有登录入口"),
              Text("机器ID："),
              Text("激活机器"),
              Text("$_activationUrl"),
              RaisedButton(
                onPressed: () async {
                  BaseResponseModel response = await requestApi(_activationUrl, {}, requestMethod: METHOD_GET);
                },
                child: Text("点击模拟扫码"),
              ),
              RaisedButton(
                onPressed: () async {
                  Map<String, dynamic> map = {};
                  map["machineId"] = _mid;
                  BaseResponseModel response = await requestApi("/appuser/web/machine/activate", map);
                  setState(() {
                    if(response.isSuccess){
                      _activationResult["code"] = response.code;
                      _activationResult["data"] = response.data;
                      _activationResult["message"] = response.message;
                    }else{
                      _activationResult["result"] = "请求失败";
                    }
                  });
                },
                child: Text("点击激活机器"),
              ),
              Text("激活结果：$_activationResult"),
              Text("扫码登录"),
              Text("$_loginUrl"),
              RaisedButton(
                onPressed: null,
                child: Text("点击模拟扫码"),
              ),
              RaisedButton(
                onPressed: null,
                child: Text("点击登录机器"),
              ),
              Text("登录结果：$_loginUrl"),
            ],
          ),
        ),
      ),
    );
  }
}
