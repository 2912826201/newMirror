

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/util/screen_util.dart';
/// dialog
/// Created by shipinke 2021-4-23

// ignore: must_be_immutable
class _AppDialog extends StatelessWidget {
  final Function() onClickListener;
  final Function() onExitListener;

  final List<Widget> _viewList = [];

  String imageUrl="assets/png/new_user_event_dialog.png";
  String imageBtnUrl="assets/png/new_user_event_btn_dialog.png";
  String imageCloseBtnUrl="assets/png/new_user_event_close_btn_dialog.png";

  _AppDialog(
      {Key key,
      this.onClickListener,this.onExitListener})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 375.0/ScreenUtil.instance.width*272,
      decoration: BoxDecoration(
        color: AppColor.transparent,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: _buildDialogView(context),
      ),
    );
  }

  List<Widget> _buildDialogView(BuildContext context) {
    _viewList.clear();
    //上下的外边距交给按钮上方布局中的最上方(topImage)和最下方组件(info)控制
    //而每添加一个组件 组件需自动添加一个上方的内边距
    _buildImageView(context);
    _buildImageBtnView(context);
    _buildImageCloseBtnView(context);
    return _viewList;
  }

  _buildImageView(BuildContext context) {
    //如果有头部图片 上边距从头部图片下面开始算 因为每个组件都要加内上边距 所以只加个差值
    if (imageUrl != null) {
      _viewList.add(GestureDetector(
        child: Container(
          height: 297.0/272.0*(375.0/ScreenUtil.instance.width*272),
          color: AppColor.transparent,
          child: Image.asset(imageUrl,fit: BoxFit.cover,),
        ),
        onTap: (){
          Navigator.pop(context);
          if(onClickListener!=null){
            onClickListener();
          }
          if(onExitListener!=null){
            onExitListener();
          }
        },
      ));
    }
  }

  _buildImageBtnView(BuildContext context) {
    //如果有头部图片 上边距从头部图片下面开始算 因为每个组件都要加内上边距 所以只加个差值
    if (imageBtnUrl != null) {
      _viewList.add(GestureDetector(
        child: Container(
          width: 375.0/ScreenUtil.instance.width*130,
          color: AppColor.transparent,
          child: Image.asset(imageBtnUrl,fit: BoxFit.cover,),
        ),
        onTap: (){
          Navigator.pop(context);
          if(onClickListener!=null){
            onClickListener();
          }
          if(onExitListener!=null){
            onExitListener();
          }
        },
      ));
    }
  }

  _buildImageCloseBtnView(BuildContext context) {
    //如果有头部图片 上边距从头部图片下面开始算 因为每个组件都要加内上边距 所以只加个差值
    if (imageCloseBtnUrl != null) {
      _viewList.add(GestureDetector(
        child: Container(
          width: 40.0,
          height: 40.0,
          padding: EdgeInsets.all(6.0),
          color: AppColor.transparent,
          child: Image.asset(imageCloseBtnUrl,fit: BoxFit.cover,),
        ),
        onTap: (){
          Navigator.pop(context);
          if(onExitListener!=null){
            onExitListener();
          }
        },
      ));
    }
  }

  // _buildImageCloseBtnView(BuildContext context) {
  //   //如果有头部图片 上边距从头部图片下面开始算 因为每个组件都要加内上边距 所以只加个差值
  //   if (imageBtnUrl != null) {
  //     _viewList.add(GestureDetector(
  //       child: Container(
  //         width: 40.0,
  //         height: 40.0,
  //         margin: EdgeInsets.only(top: 30),
  //         color: AppColor.transparent,
  //         child: Icon(Icons.close_outlined,size: 28,color: AppColor.textPrimary1.withOpacity(0.35)),
  //       ),
  //       onTap: (){
  //         Navigator.pop(context);
  //       },
  //     ));
  //   }
  // }

}


showImageDialog(BuildContext context,
    {Function() onClickListener,
    Function() onExitListener,
    bool barrierDismissible = false}) {
  showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) {
        return WillPopScope(
            onWillPop: () async => barrierDismissible, //用来屏蔽安卓返回键关弹窗
            child: Dialog(
              backgroundColor: AppColor.transparent,
              elevation:0,
              child: _AppDialog(onClickListener:onClickListener,onExitListener:onExitListener),
            ));
      });
}

