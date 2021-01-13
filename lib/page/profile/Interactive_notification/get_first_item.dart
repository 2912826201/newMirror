
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class GetFristItem extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
      return _getFristItemState();
  }
}
class _getFristItemState extends State<GetFristItem>{
  GlobalKey _key = GlobalKey();
  ScrollController controller = ScrollController();
  RefreshController refreshController = RefreshController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    RenderBox box = _key.currentContext.findRenderObject();
    Offset offset = box.localToGlobal(Offset.zero);

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
       title: Text("跳转第一个Item"),
      ),
      body:Container(
        height: ScreenUtil.instance.height,
        width: ScreenUtil.instance.width,
        child: Column(
          children: [
            Container(
              height: ScreenUtil.instance.height/2,
              width: ScreenUtil.instance.width,
              color: AppColor.mainRed,
            ),
            Expanded(
              child:SmartRefresher(
                controller: refreshController,
                onRefresh: null,
                onLoading: null,
                enablePullUp: false,
                enablePullDown: false,
                child: ListView.builder(
                itemCount: 20,
                controller: controller,
                itemBuilder:(context,index){
                  return Container(
                    height: 150,
                    width: ScreenUtil.instance.width,
                    color: AppColor.black,
                  );
                } ),
              ) )
          ],
        ),
      )
    );
  }

}