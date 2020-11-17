import 'package:flutter/cupertino.dart';
//点赞\评论点击控件
class IntercourseWidget extends StatefulWidget{
  final String backImage;
  final Text title;
  final int badges;
  final Color imageBackColor;
  final VoidCallback onTap;
  final double width;
  final double height;
  IntercourseWidget({Key key,
    this.backImage,
    this.title,
    this.badges,
    this.onTap,
    this.imageBackColor,
    this.width = 125.0,
    this.height = 125.0
  }):super(key: key);
  @override
  State<StatefulWidget> createState() {
   return _IntercourseWidgetState();
  }

}
class _IntercourseWidgetState extends State<IntercourseWidget>{
  final _maxBadgesNum = 99;
  @override
  Widget build(BuildContext context) {
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
              padding: EdgeInsets.all(6.5),
              child: OverflowBox(
                child: Container(

                ),
              )
            ),
            //标题显示
            widget.title
          ],
        ),
      ),
    );
  }

}