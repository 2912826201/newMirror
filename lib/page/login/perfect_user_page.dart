import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/page/login/login_base_page_state.dart';
import 'package:mirror/util/app_style.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

void main(){
  runApp(PerfectUserPage());
}

class PerfectUserPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _PerfectUserState();
  }
}

class _PerfectUserState extends LoginBasePageState {
  var _imgPath;
  final _controller = PanelController();
  final inputCotroller = TextEditingController();
  final maxTextLength = 15;
  final _hintText = "戳这里输入昵称";
  final carryOutOriginColor = Color.fromRGBO(235, 235, 235, 1);
  final btnTitileOriginColor = Color.fromRGBO(153, 153, 153, 1);
  final btnLightColor = Color.fromRGBO(17, 17, 17, 1);
  final btntitleLightColor = Colors.white;
  final _btnText = "完成";
  int textLength = 0;
  var _carryOutBtnColor;
  var _btnTitleColors ;
  bool _canClick;
  @override
  void initState() {
    super.initState();
    _canClick = false;
    _carryOutBtnColor = carryOutOriginColor;
    _btnTitleColors = btnTitileOriginColor;
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Builder(builder: (context) {
      var _height = MediaQuery.of(context).size.height;
      return Scaffold(
        body: SlidingUpPanel(
          panel: Container(
            child: _bottomDialog(),
          ),
          maxHeight: _height * 0.24,
          backdropEnabled: true,
          controller: _controller,
          minHeight: 0,
          body: Container(
              child: InkWell(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Column(
              children: [
                Container(
                  child: navigationBar(),
                  padding: EdgeInsets.only(top: 40),
                ),
                SizedBox(
                  height: 40,
                ),
                _perfectHome(_controller)
              ],
            ),
          )),
        ),
      );
    }));
  }

  Widget _perfectHome(PanelController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ///头像
        Center(
          child:_avatarWidget(controller),
        ),
        SizedBox(height: 40),
        Center(child:Container(
          margin: EdgeInsets.only(left: 41,right: 41),
          child:Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ///输入框
            _inputWidget(),
            SizedBox(height: 32,),
            ///完成按钮
            _perfectUserBtn()
            ],
        )
        )
        )
      ],
    );
  }

  Widget _avatarWidget(PanelController controller) {
    return Container(
        width: 90,
        height: 90,
        child: InkWell(
          ///点击时出现dialog
            onTap: () {
              controller.open();
            },
            child: Stack(
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage(_imageView()),
                  maxRadius: 59,
                ),
                Positioned(
                    top: 66,
                    right: 6,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.all(Radius.circular(59)),
                          border: Border.all(width: 1, color: Colors.white)),
                      child: Center(
                        child: Text(
                          "+",
                          style: TextStyle(fontSize: 13.5, color: Colors.white),
                        ),
                      ),
                    ))
              ],
            )));
  }
    ///dialog
  Widget _bottomDialog() {
    return Container(
      child: Column(
        children: [
          InkWell(
              onTap: () {
                _takePhoto();
                _controller.close();
              },
              child: Container(
                  height: 50,
                  child: Center(
                    child: Text("拍摄", style: AppStyle.textRegular16),
                  ))),
          InkWell(
              onTap: () {
                _openPhoto();
                _controller.close();
              },
              child: Container(
                  height: 50,
                  child: Center(
                    child: Text("相册", style: AppStyle.textRegular16),
                  ))),
          Container(
            color: AppColor.bgWhite,
            height: 12,
          ),
          InkWell(
              onTap: () {
                _controller.close();
              },
              child: Container(
                  height: 50,
                  child: Center(
                    child: Text("取消",
                        style: TextStyle(
                            color: Color.fromRGBO(0xFF, 0x40, 0x59, 1.0),
                            fontSize: 16)),
                  )))
        ],
      ),
    );
  }
      ///输入框
    Widget _inputWidget(){
        var putFiled = TextField(
          maxLength: maxTextLength,
          controller: inputCotroller,
          showCursor: true,
          decoration: InputDecoration(
            hintText:_hintText,
            counterText: "",
            hintStyle: TextStyle(color: Color.fromRGBO(204, 204, 204, 1), fontFamily: 'PingFangSC', fontSize: 16),
            suffixText:"$textLength/$maxTextLength",
            suffixStyle: TextStyle(color: Color.fromRGBO(204, 204, 204, 1), fontFamily: 'PingFangSC', fontSize: 16),
          ),
          onChanged: (value){
             setState(() {
               textLength = value.length;
               if(value.isNotEmpty){
                  _canClick = true;
                 _carryOutBtnColor = btnLightColor;
                 _btnTitleColors = btntitleLightColor;
               }else{
                 _canClick = false;
                 _carryOutBtnColor = carryOutOriginColor;
                 _btnTitleColors = btnTitileOriginColor;
               }
             });

        },
        );
        return Container(
          width: 293,
          child: putFiled
        );
    }
    ///完成按钮
  Widget _perfectUserBtn() {
    var btnStyle = RoundedRectangleBorder(borderRadius: BorderRadius.circular(3));
    var carryOutBtn = FlatButton(
      minWidth: 293,
      height: 44,
      shape: btnStyle,
      onPressed:(){
          if(_canClick){

          }else{

          }
      },
      child: Text(
        _btnText,
        style: TextStyle(fontFamily: "PingFangSC", fontSize: 16, color: _btnTitleColors),
      ),
      color: _carryOutBtnColor,
    );
    var returns = Container(
      child: carryOutBtn,
    );
    return returns;
  }
  ///判断是否选择了图片，如果没有则使用默认图片
  String _imageView() {
    if (_imgPath != null) {
      return _imgPath;
    } else {
      return "images/test/avatar.png";
    }
  }
    ///打开相机
  _takePhoto() async {
    var pickedImg = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      _imgPath = pickedImg.path;
    });
  }
    ///打开相册
  _openPhoto() async {
    var pickedFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imgPath = pickedFile.path;
    });
  }
}
