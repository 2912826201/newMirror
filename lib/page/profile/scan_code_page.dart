import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/page/home/sub_page/attention_page.dart';
import 'package:mirror/util/app_style.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:r_scan/r_scan.dart';

class ScanCodePage extends StatefulWidget {
  List<RScanCameraDescription> rScanCameras;

  ScanCodePage({this.rScanCameras});

  @override
  ScanCodeState createState() {
    return ScanCodeState();
  }
}

class ScanCodeState extends State<ScanCodePage>
    with SingleTickerProviderStateMixin {
  var bgColor = Color(0xffcccccc);
  String _imgAsset = "images/test/back.png";
  RScanCameraController _controller;
  bool _isFirst = true;
  String _imgPath = "";
  var _top = 0.0;
  var _countdownTime = 2;
  Timer _timer;
  @override
  void initState() {
    super.initState();
    awitVoid();
    List<RScanCameraDescription> rScanCameras = widget.rScanCameras;
    if (rScanCameras != null && rScanCameras.length > 0) {
      _controller = RScanCameraController(
          rScanCameras[0], RScanCameraResolutionPreset.max)
        ..addListener(() {
          final result = _controller.result;
          if (result != null) {
            if (_isFirst) {
              Navigator.pop(context, result.message);
              _isFirst = false;
            }
          }
        })
        ..initialize().then((value) {
          if (!mounted) {
            return;
          } else {
            setState(() {
            });
          }
        });
    }
  }

  ///这里是用了一个倒计时来让动画更新
  Future awitVoid()async{
    const onese = const Duration(seconds: 1);
    var callback = (timer) =>{
      setState((){
        if(_countdownTime==1){
          setState(() {
            _top=300;
          });
          _timer.cancel();
        }else{
          _countdownTime = _countdownTime-1;
        }
      })
    };
    _timer = Timer.periodic(onese,callback);
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (context) {
          var width = MediaQuery.of(context).size.width;
          var height = MediaQuery.of(context).size.height;
          return Scaffold(
            body: _ScanCodeHome(width, height),
          );
        },
      ),
    );
  }

  Widget _ScanCodeHome(double width, double height) {
    return Container(
      height: height,
      width: width,
      child: Column(
        children: [
          Container(
            color: bgColor,
            width: width,
            child: SizedBox(
              height: 28,
            ),
          ),
          _ScanCodeTitle(width, height),
          Expanded(
              child: Stack(
            children: [
              _ScanCodePage(width, height),
              _OuterLayer(),
              Positioned(
                bottom: 130,
                left: 100,
                child: _BottomLayout(),
              )
            ],
          ))
        ],
      ),
    );
  }

  ///这里是底部二维码图片和文字
  Widget _BottomLayout() {
    return Container(
      child: Column(
        children: [
          Text(
            "将二维码放入框中，即可自动扫描",
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          SizedBox(
            height: 48,
          ),
          Container(
            height: 40,
            width: 40,
            child: Image.asset("images/test/scancode.png"),
          ),
          SizedBox(
            height: 9,
          ),
          Text(
            "我的二维码",
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  ///阴影部分
  Widget _OuterLayer() {
    return Expanded(
        child: Container(
      child: Column(
        children: [
          Expanded(
              child: Container(
            child: Opacity(
              opacity: 0.3,
              child: Container(
                color: Colors.blue,
              ),
            ),
          )),
          Container(
            height: 300,
            child: Row(
              children: [
                Expanded(
                  child: Opacity(
                    opacity: 0.3,
                    child: Container(
                      color: Colors.blue,
                    ),
                  ),
                ),
                Container(
                    width: 300,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Opacity(
                          opacity: 0,
                          child: InkWell(
                            onTap: (){
                              setState(() {
                                _top = 300.0;
                              });
                            },
                            child: Container(
                            color: AppColor.white,
                          ),)
                        ),
                        AnimatedPositioned(
                            top: _top,
                            onEnd: () {
                              setState(() {
                                if (_top == 0.0) {
                                  _top = 300.0;
                                }else{
                                  _top = 0.0;
                                }
                              });

                            },
                            child: Container(
                              width: 300,
                              height: 1,
                              color: AppColor.white,
                            ),
                            duration: Duration(seconds: 2)),
                        Positioned(child: verticalWidget(true),left: 0,top: 0,),
                        Positioned(child: verticalWidget(true),right: 0,top: 0,),
                        Positioned(child: verticalWidget(true),bottom: 0,left: 0,),
                        Positioned(child: verticalWidget(true),bottom: 0,right: 0,),
                        Positioned(child: verticalWidget(false),left: 0,top: 0,),
                        Positioned(child: verticalWidget(false),right: 0,top: 0,),
                        Positioned(child: verticalWidget(false),bottom: 0,left: 0,),
                        Positioned(child: verticalWidget(false),bottom: 0,right: 0,),
                      ],
                    )),
                Expanded(
                  child: Opacity(
                    opacity: 0.3,
                    child: Container(
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 280,
            child: Opacity(
              opacity: 0.3,
              child: Container(
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    ));
  }


  Widget verticalWidget(bool isVertical){
    var vertical =  Container(
      width: 4,
      height: 26,
      color: AppColor.white,
    );
    var horizantal = Container(
      width: 26,
      height: 4,
      color: AppColor.white,
    );
    if(isVertical){
      return vertical;
    }else{
      return horizantal;
    }
  }
  Widget _ScanCodePage(double width, double heigth) {
    return Expanded(
        child: Container(
      child: AspectRatio(
        ///拿到相机的aspectRatio
        aspectRatio: _controller.value.aspectRatio,
        child: RScanCamera(_controller),
      ),
    ));
  }

  Widget _ScanCodeTitle(double width, double heigth) {
    return Container(
        width: width,
        height: 40,
        padding: EdgeInsets.only(left: 20, right: 20),
        child: Row(
          children: [
            Center(
                child: InkWell(
              ///点击返回
              onTap: () {
                Navigator.pop(context);
              },
              child: Image.asset(_imgAsset),
            )),
            Expanded(
                child: Container(
              child: Center(
                child: Text(
                  "扫一扫",
                  style: AppStyle.textRegular16,
                ),
              ),
            )),
            Center(
              child: InkWell(
                onTap: () {
                  _openPhoto();
                },
                child: Text(
                  "相册",
                  style: AppStyle.textRegular16,
                ),
              ),
            )
          ],
        ));
  }

  Future _openPhoto() async {
    var pickedFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() async {
      _imgPath = pickedFile.path;
    });
    var result = await RScan.scanImagePath(_imgPath);
    if(result!=null){
      Navigator.pop(context, result);
    }else{
      ToastShow.show("$result",context);
    }

  }
}
