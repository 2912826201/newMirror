
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:address_picker/address_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/media_file_model.dart';
import 'package:mirror/page/media_picker/gallery_page.dart';
import 'package:mirror/page/media_picker/media_picker_page.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/date_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:intl/intl.dart';
class EditInformation extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _editInformationState();
  }

}
class _editInformationState extends State<EditInformation>{
  String userName = "这是一个十五个字的名字我我我我";
  PanelController pcController = PanelController();
  bool isBoy = true;
  DateTime _selectedDateTime = DateTime.now();
  String choseTime = "2000-07-08";
  bool isCity = true;
  String _province = "";
  String _city = "";
  String _provinceCity = "";

  //取图裁剪得到的图片数据
  Uint8List imageData;

  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    double width = ScreenUtil.instance.screenWidthDp;
    double height = ScreenUtil.instance.height;
    return Scaffold(
          body: SlidingUpPanel(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(isCity?0.0:10.0),
              topRight: Radius.circular(isCity?0.0:10.0),
            ),
            panel:isCity?_addressChose(height):_bottomDialog(),
            onPanelClosed: () {
            },
            maxHeight: isCity?height*0.31+42:height *0.19+32,
            backdropEnabled: true,
            controller: pcController,
            minHeight: 0,
            body: Container(
            color: AppColor.white,
            height: height,
            width: width,
            child: Column(
            children: [
              Container(
                height: 44,
                color: AppColor.white,
              ),
             _title(width),
              Container(
                width: width,
                height: 0.5,
                color: AppColor.bgWhite_65,
              ),
              Container(
                margin: EdgeInsets.only(top: 16),
                width: 71,
                height: 71,
                child: InkWell(
                  child: _avatar(context),
                onTap: (){
                  AppRouter.navigateToMediaPickerPage(
                    context, 1, typeImage, true, startPageGallery, true, false, (result) async {
                    SelectedMediaFiles files = Application.selectedMediaFiles;
                    print('Application.mediaFileModel=======================${files.list.first}');
                              if(result!=true||files==null){
                        return ;
                      }
                      Application.selectedMediaFiles = null;
                    MediaFileModel model = files.list.first;
                    if (model != null) {
                      print("开始获取ByteData" + DateTime.now().millisecondsSinceEpoch.toString());
                      ByteData byteData = await model.croppedImage.toByteData(format: ui.ImageByteFormat.png);
                      print("已获取到ByteData" + DateTime.now().millisecondsSinceEpoch.toString());
                      Uint8List picBytes = byteData.buffer.asUint8List();
                      print("已获取到Uint8List" + DateTime.now().millisecondsSinceEpoch.toString());
                      model.croppedImageData = picBytes;
                    }
                    print('model.croppedImageData===========================${model.croppedImageData}');
                              // context.read<InformationImageNotifier>().setImage(model.croppedImageData);
                    setState(() {
                      imageData = model.croppedImageData;
                    });
                  }

                  );
                }
                ,)
              /*  context.read<InformationImageNotifier>();*/
              ),
              SizedBox(height: 16,),
              InkWell(
                onTap: (){
                  AppRouter.navigationToEditInfomationName(context);
                },
                child: _rowChose(width,"昵称",userName),),
              Container(
                margin: EdgeInsets.only(left: 16,right: 16),
                width: width,
                height: 0.5,
                color: AppColor.bgWhite_65,
              ),
              InkWell(
                onTap: (){
                  setState(() {
                    isCity = false;
                  });
                  pcController.open();
                },
                child: _rowChose(width,"性别",isBoy?"男":"女"),),
              Container(
                margin: EdgeInsets.only(left: 16,right: 16),
                width: width,
                height: 0.5,
                color: AppColor.bgWhite_65,
              ),
              InkWell(
                onTap: (){
                  _showDatePicker();
                },
                child:_rowChose(width,"生日",choseTime) ,)
              ,
              Container(
                margin: EdgeInsets.only(left: 16,right: 16),
                width: width,
                height: 0.5,
                color: AppColor.bgWhite_65,
              ),
              InkWell(
                child: _rowChose(width,"地区",_provinceCity),
                onTap: (){
                  setState(() {
                    isCity = true;
                  });
                  pcController.open();
                },
              ),
              Container(
                margin: EdgeInsets.only(left: 16,right: 16),
                width: width,
                height: 0.5,
                color: AppColor.bgWhite_65,
              ),
              InkWell(
                child:  _rowChose(width,"简介","去编辑"),
                onTap: (){
                  AppRouter.navigationToEditInfomationIntroduction(context);
                },
              ),

              Container(
                margin: EdgeInsets.only(left: 16,right: 16),
                width: width,
                height: 0.5,
                color: AppColor.bgWhite_65,
              ),

            ],
          ),))
      );
  }


  Widget _rowChose(double width,String title,String content){
    return Container(
      height: 48,
      width: width,
      padding: EdgeInsets.only(left: 16,right: 16),
      child: Center(
        child: Row(
          children: [
              Text(title,style: AppStyle.textRegular16,),
              SizedBox(width: 28,),
              Container(
                height:23,
                width: width*0.67,
                child: Text(
                  content,
                  style: AppStyle.textRegular16,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            Expanded(child: SizedBox()),
            Text(">",style: TextStyle(fontSize: 20,color: AppColor.textSecondary),)
          ],
        ),
      ),
    );
  }
  Widget _avatar(BuildContext context){
    return Stack(
      children: [
        Container(
          height: 71,
          width:  71,
          child: ClipOval(
            child: imageData!=null?Image.memory(imageData, fit: BoxFit.cover,)
              :Image.asset("images/test/test.png")
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 23,
            height: 23,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.all(Radius.circular(59)),),
            child: Center(
              child: Image.asset(
                "images/test/user-filling1.png",
                fit: BoxFit.cover,
              )
            ),
          ))
      ],
    );
  }
  ///顶部title
  Widget _title(double width){
    return Container(
      height: 44,
      width: width,
      padding: EdgeInsets.only(left: 16,right: 16),
      child: Row(
        children: [
          InkWell(
            onTap: (){
              Navigator.pop(this.context);
            },
            child: Image.asset("images/test/back.png"),
          ),
          Expanded(child: Center(child: Text("编辑资料",style: AppStyle.textMedium18,),),),
          InkWell(
            onTap: (){
            },
            child: Container(
              height: 28,
              width: 60,
              child: Center(child: Text("确定",style: TextStyle(fontSize: 14,color: AppColor.white),),),
              decoration: BoxDecoration(
                color: AppColor.mainRed,
                borderRadius: BorderRadius.all(Radius.circular(60)),
                border: Border.all(width: 1, color: AppColor.black))),)
        ],
      ),
    );
  }
  ///性别选择dialog
  Widget _bottomDialog() {
    return Container(
      child: Column(
        children: [
          Container(
            height: 50,
            child: InkWell(
              onTap: () {
                setState(() {
                  isBoy = false;
                });
                pcController.close();
              },
              child: Center(
                child: Text("女", style: AppStyle.textRegular16),
              )),),
          InkWell(
            onTap: () {
              setState(() {
                isBoy = true;
              });
              pcController.close();
            },
            child: Container(
              height: 50,
              child: Center(
                child: Text("男", style: AppStyle.textRegular16),
              ))),
          Container(
            color: AppColor.bgWhite,
            height: 12,
          ),
          InkWell(
            onTap: () {
              pcController.close();
            },
            child: Container(
              height: 50,
              child: Center(
                child: Text(
                  "取消",
                  style: AppStyle.textRegular16,
                ))))
        ],
      ),
    );
  }
  ///时间选择器
  void _showDatePicker() {
    DatePicker.showDatePicker(
      context,
      pickerTheme: DateTimePickerTheme(
        showTitle: true,
        confirm: Text('确定', style: AppStyle.textRegular16),
        cancel: Text('取消', style: AppStyle.textRegular16),
      ),
      minDateTime: DateTime.parse("1900-01-01"), //选择器上可选择的最早时间
      maxDateTime: DateTime.parse(DateUtil.formatToDayDateString()), //选择器上可选择的最晚时间
      initialDateTime: _selectedDateTime, //选择器的当前选中时间
      dateFormat: "yyyy年,MM月,dd日", //时间格式
      locale: DateTimePickerLocale.zh_cn, //国际化配置
      onClose: (){
        setState(() {
          choseTime = DateFormat("yyyy MM dd").format(_selectedDateTime);
        });
      },
      onCancel: () => print('onCancel'),
      onChange: (dateTime, List<int> index) {
        setState(() {
          _selectedDateTime = dateTime;
        });
      },
      onConfirm: (dateTime, List<int> index) {
        setState(() {
          _selectedDateTime = dateTime;
        });
      },
    );
  }
  ///城市选择器
  Widget _addressChose(double height){
    return Container(
      height:height*0.31+42,
      child:Column(
        children: [
          Container(
            height: 42,
            padding: EdgeInsets.only(left: 16,right: 16),
            child: Row(
            children: [
              InkWell(
                child: Text("取消",style: AppStyle.textHintRegular16,),
                onTap: (){
                  pcController.close();
                },
              ),
              Expanded(child: SizedBox()),
              InkWell(
                onTap: (){
                  setState(() {
                    _provinceCity = "$_province $_city";
                  });
                  pcController.close();
                },
                child: Text("完成",style: AppStyle.textRegularRed16,),
              )
            ],
          ),),
          Container(
            height: height*0.31,
            child: AddressPicker(
            style: TextStyle(color: Colors.black, fontSize: 17),
            mode: AddressPickerMode.provinceAndCity,
            onSelectedAddressChanged: (address) {
              setState(() {
                _province = address.currentProvince.province;
                _city = address.currentCity.city;
              });
            },
          ),
          )
        ],
      )
    );
  }
}