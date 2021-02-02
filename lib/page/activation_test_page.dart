import 'package:flutter/material.dart';
import 'package:mirror/api/api.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/base_response_model.dart';
import 'package:mirror/widget/custom_appbar.dart';

/// activation_test_page
/// Created by yangjiayi on 2020/12/7.

class ActivationTestPage extends StatefulWidget {
  @override
  _ActivationTestState createState() => _ActivationTestState();
}

class _ActivationTestState extends State<ActivationTestPage> {
  String _activationUrl = "/third/web/url/";
  String _loginUrl = "/third/web/url/";
  int _mid = 0;
  Map _activationResult = {};
  Map _loginResult = {};

  TextEditingController _activationCodeController = TextEditingController();
  TextEditingController _loginCodeController = TextEditingController();
  TextEditingController _midController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    print("激活机器及扫码登录测试页");
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(
          "激活机器及扫码登录测试页",
          style: AppStyle.textMedium18,
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("先确保APP用户已登录，在我的tab页有登录入口"),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("机器ID："),
                  Expanded(
                      child: TextField(
                    keyboardType: TextInputType.number,
                    controller: _midController,
                  ))
                ],
              ),
              Text("激活机器"),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("http://ifdev.aimymusic.com/third/web/url/"),
                  Expanded(
                      child: TextField(
                    controller: _activationCodeController,
                  ))
                ],
              ),
              RaisedButton(
                onPressed: () async {
                  BaseResponseModel response =
                      await requestApi(_activationUrl + _activationCodeController.text, {}, requestMethod: METHOD_GET);
                },
                child: Text("点击模拟扫码"),
              ),
              RaisedButton(
                onPressed: () async {
                  Map<String, dynamic> map = {};
                  _mid = int.parse(_midController.text);
                  map["machineId"] = _mid;
                  BaseResponseModel response = await requestApi("/appuser/web/machine/activate", map);
                  setState(() {
                    if (response.isSuccess) {
                      _activationResult["code"] = response.code;
                      _activationResult["data"] = response.data;
                      _activationResult["message"] = response.message;
                    } else {
                      _activationResult["result"] = "请求失败";
                    }
                  });
                },
                child: Text("点击激活机器"),
              ),
              Text("激活结果：$_activationResult"),
              Text("扫码登录"),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("http://ifdev.aimymusic.com/third/web/url/"),
                  Expanded(
                      child: TextField(
                    controller: _loginCodeController,
                  ))
                ],
              ),
              RaisedButton(
                onPressed: () async {
                  BaseResponseModel response =
                      await requestApi(_loginUrl + _loginCodeController.text, {}, requestMethod: METHOD_GET);
                },
                child: Text("点击模拟扫码"),
              ),
              RaisedButton(
                onPressed: () async {
                  Map<String, dynamic> map = {};
                  _mid = int.parse(_midController.text);
                  map["machineId"] = _mid;
                  BaseResponseModel response = await requestApi("/appuser/web/machine/login", map);
                  setState(() {
                    if (response.isSuccess) {
                      _loginResult["code"] = response.code;
                      _loginResult["data"] = response.data;
                      _loginResult["message"] = response.message;
                    } else {
                      _loginResult["result"] = "请求失败";
                    }
                  });
                },
                child: Text("点击登录机器"),
              ),
              Text("登录结果：$_loginResult"),
            ],
          ),
        ),
      ),
    );
  }
}
