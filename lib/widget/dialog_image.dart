

import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:provider/provider.dart';
/// dialog
/// Created by shipinke 2021-4-23

const double _dialogWidth = 260;
const double _imageHeight = 260;

class _AppDialog extends StatelessWidget {
  final String imageUrl;
  final Function() onClickListener;

  final List<Widget> _viewList = [];

  _AppDialog(
      {Key key,
      this.imageUrl,
      this.onClickListener})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _dialogWidth,
      decoration: BoxDecoration(
        color: AppColor.white,
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
    _buildTopImageView(context);
    return _viewList;
  }

  _buildTopImageView(BuildContext context) {
    //如果有头部图片 上边距从头部图片下面开始算 因为每个组件都要加内上边距 所以只加个差值
    if (imageUrl != null) {
      _viewList.add(GestureDetector(
        child: Container(
          height: _imageHeight,
          color: AppColor.mainBlue,
          child: Image.network(imageUrl,fit: BoxFit.cover,),
        ),
        onTap: (){
          Navigator.pop(context);
          if(onClickListener!=null){
            onClickListener();
          }
        },
      ));
    }
  }

}


showImageDialog(BuildContext context,
    {@required String imageUrl,
      Function() onClickListener,
    bool barrierDismissible = true}) {
  showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) {
        return WillPopScope(
            onWillPop: () async => barrierDismissible, //用来屏蔽安卓返回键关弹窗
            child: Dialog(
              child: _AppDialog(imageUrl: imageUrl,
                  onClickListener:onClickListener),
            ));
      });
}

