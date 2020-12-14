

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_drag_scale/core/drag_scale_widget.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/util/string_util.dart';
///这是图片详情页
class ImageDetails extends StatefulWidget{
  int index;
  List<String> ImageList;
  ImageDetails({this.index,this.ImageList});
  @override
  State<StatefulWidget> createState() {
      return _IamgeDetailsState();
  }

}

class _IamgeDetailsState extends State<ImageDetails> with SingleTickerProviderStateMixin {
  PageController _controller;
  int _backIndex = 0;
  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: widget.index);
  }
  @override
  Widget build(BuildContext context) {
              return Scaffold(
                body: Container(
                  color: AppColor.black,
                  child: Expanded(
                  child: Center(
                    child: PageView.builder(
                      controller: _controller,
                      itemCount: widget.ImageList.length,
                      itemBuilder:(context,index){
                        return _ImageItem(widget.ImageList[index]);
                      } )
                  ),
                ),)
              );
            }
  Widget  _ImageItem(String url){
    return SizedBox(
      width: 50,
      child: Container(
      child: GestureDetector(
        child: Container(
          child:DragScaleContainer(
            doubleTapStillScale: false,
            child: Image.network(url,fit: BoxFit.cover,),)
        ),
        onTap: (){
          Navigator.pop(context,_backIndex);
        },),
    ),);
  }

}