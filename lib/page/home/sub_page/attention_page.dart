import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/course_model.dart';

enum Status {
  notLoggedIn,//未登录
  noConcern,//无关注
  concern// 关注
}
// 关注
class AttentionPage extends StatefulWidget {
  AttentionPage({Key key, this.coverUrls}) : super(key: key);
  List<CourseModel> coverUrls = [];

  AttentionPageState createState() => AttentionPageState();
}

class AttentionPageState extends State<AttentionPage> {
  @override
  void initState() {

    super.initState();
  }
  Widget pageDisplay() {
    var status = Status.notLoggedIn;
    switch (status) {
      case Status.notLoggedIn:
        return Container(
          child: Column (
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 224,
                height: 224,
                color: AppColor.color246,
                margin: EdgeInsets.only(bottom: 16,top: 150),
              ),
              Text("登录账号后查看你关注的精彩内容",style: TextStyle(
                fontSize: 14,color: AppColor.textSecondary
              ),),
              Container(
                width: 293,
                height: 44,
                color: Colors.black,
                margin: EdgeInsets.only(top: 32),
                child: Center(
                  child: Text("Login",style: TextStyle(color: Colors.white),),
                ),
              )
            ],
          ),
        );
        break;
      case Status.noConcern:
        return Container(
          child: Column (
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 224,
                height: 224,
                color: AppColor.color246,
                margin: EdgeInsets.only(bottom: 16,top: 188),
              ),
              Text("这里空空如也，去推荐看看吧",style: TextStyle(
                  fontSize: 14,color: AppColor.textSecondary
              ),),
            ],
          ),
        );
        break;
      case Status.concern:
        return Container(
          // margin: EdgeInsets.only(bottom:115),
          color: Colors.orange,
        );
        break;
    }
  }
   @override
  Widget build(BuildContext context) {
     double screen_top = MediaQuery.of(context).padding.top;
    return pageDisplay();
  }
}


