import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
//点赞、评论点击控件
class MPIntercourseWidget extends StatefulWidget{
  final _state = _MPIntercourseWidgetState();
  //背景图片
  final String backImage;
  //下方标题
  final Text title;
  //待读数量
  final int badges;
  //背景图片的颜色
  final Color imageBackColor;
  //点击事件的绑定
  final VoidCallback onTap;
  final double width;
  final double height;
  MPIntercourseWidget({Key key,
    this.backImage,
    @required this.title,
    this.badges,
    @required this.onTap,
    this.imageBackColor,
    this.width = 45.0,
    this.height = 72.5
  }):super(key: key);
  @override
  State<StatefulWidget> createState() {
   return  _state;
  }

}
class _MPIntercourseWidgetState extends State<MPIntercourseWidget>{

  @override
  Widget build(BuildContext context) {
    bool hideBadget = true;
    if (widget.badges == 0){
      hideBadget = true;
    }else{
      hideBadget = false;
    }
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: widget.width,
        height: widget.height,
        // padding: EdgeInsets.only(top: 26.5,bottom: 26,left: 40,right: 40),
        child:Column(
          children: [
            //显示图片部分
            Container(
              width: 45.0,
              height: 45.0,
              color: Colors.grey,
              alignment: Alignment.topLeft,
              padding: EdgeInsets.only(left: 30,),
              //使用overFlow来制作未读消息数量,需要注意alinment的设置
              child: Offstage(
                offstage: hideBadget,
                child: OverflowBox(
                  maxWidth: 300,
                  minHeight: 18,
                  alignment: Alignment.topLeft,
                  child: Container(
                    height: 18,
                    //描边的设置
                    decoration: BoxDecoration(
                        color: AppColor.mainRed,
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(
                            color: AppColor.bgWhite,
                            width: 0.5
                        )
                    ),
                    //和内部文字的间距设置
                    padding: EdgeInsets.only(left: 5,right: 5,top: 2,bottom: 2),
                    child: Text("${widget.badges}+",
                      style: TextStyle(color: AppColor.white,
                          fontFamily: "PingFangSC-Regular",
                          fontSize: 12,
                          decoration: TextDecoration.none),),
                  ),
                ),
              )
            ),
            //标题显示
            Container(child: widget.title,
            margin: EdgeInsets.only(top: 5),)
          ],
        ),
      ),
    );
  }

}