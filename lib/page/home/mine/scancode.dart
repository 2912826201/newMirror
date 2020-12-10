



import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/util/app_style.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:r_scan/r_scan.dart';



void main()async{

}
class ScanCode extends StatefulWidget{
  List<RScanCameraDescription> rScanCameras;
  ScanCode({this.rScanCameras});

  @override
  State<StatefulWidget> createState() {
        return ScanCodeState();
  }


}

class ScanCodeState extends State<ScanCode>{
  var bgColor=Color(0xffcccccc);
  String _imgAseet = "images/test/back.png";
  RScanCameraController _controller;
  bool _isFirst = true;
  String _imgPath = "";
  @override
  void initState() {
    super.initState();
    List<RScanCameraDescription> rScanCameras = widget.rScanCameras;
    if(rScanCameras!=null&& rScanCameras.length>0){
      _controller = RScanCameraController(rScanCameras[0],RScanCameraResolutionPreset.max)..addListener(() {
        final result  = _controller.result;
          if(result!=null){
            if(_isFirst){
                Navigator.pop(context,result.message);
             /* Fluttertoast.showToast(
                msg: "${result.message.toString()}",
                toastLength: Toast.LENGTH_SHORT,
                fontSize: 16,
                gravity: ToastGravity.CENTER,
                backgroundColor: AppColor.textHint,
                textColor: AppColor.white);*/
              _isFirst = false;
            }
          }
      })
        ..initialize().then((value){
          if(!mounted){
            return;
          }else{
            setState(() {

            });
          }
        });
    }
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(builder: (context){
        var width = MediaQuery.of(context).size.width;
        var height = MediaQuery.of(context).size.height;
        return Scaffold(
          body: _ScanCodeHome(width,height),
        );
      },),
    );
  }

  Widget _ScanCodeHome(double width,double height){
        return Container(
          height: height-70,
          width: width,
          child: Column(
            children: [
              Container(
                color: bgColor,
                width: width,
                child: SizedBox(height: 28,),
              ),
              _ScanCodeTitle(width,height),
              _ScanCodePage(width,height),

            ],
          ),
        );
  }
  Widget _ScanCodePage(double width,double heigth){
    return Container(
      width: width*0.8,
      height: heigth/3,
      margin: EdgeInsets.only(
        top: 100
      ),
      child:AspectRatio(
        //拿到相机的aspectRatio
        aspectRatio: _controller.value.aspectRatio,
        child: RScanCamera(_controller),
      ),
    );
  }
  Widget _ScanCodeTitle(double width,double heigth){
    return Container(
      width: width,
      height: 40,
      padding: EdgeInsets.only(left: 20,right: 20),
      child:Row(
        children: [
          Center(
            child: InkWell(
              ///点击返回
              onTap: () {
                Navigator.pop(context);
              },
              child: Image.asset(_imgAseet),
            )),
          Expanded(child: Container(child: Center(child: Text("扫一扫",style: AppStyle.textRegular16,),),)),
          Center(
            child: InkWell(
              onTap: (){
                _openPhoto();
              },
              child: Text("相册",style: AppStyle.textRegular16,),
            ),
          )
        ],
      )
    );
  }
  Future _openPhoto() async {
    var pickedFile = await ImagePicker.pickImage(source: ImageSource.gallery);
      setState(() async {
      _imgPath = pickedFile.path;
     });
    var result= await RScan.scanImagePath(_imgPath);
       Navigator.pop(context,result);
  }
}