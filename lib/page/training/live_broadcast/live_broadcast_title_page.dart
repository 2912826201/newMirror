import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/util/date_util.dart';
import 'package:mirror/widget/no_blue_effect_behavior.dart';

///直播日程-title页
// ignore: must_be_immutable
class LiveBroadcastTitlePage extends StatefulWidget {
  final List<DateTime> dates;
  void Function(void Function(int)) setCall;
  void Function(int) itemClick;

  LiveBroadcastTitlePage(this.dates, {this.setCall, this.itemClick});

  @override
  State<StatefulWidget> createState() {
    return LiveBroadcastTitlePageState(dates,
        setCall: setCall, itemClick: itemClick);
  }
}

class LiveBroadcastTitlePageState extends State<LiveBroadcastTitlePage> {
  List<DateTime> dates;
  List<GlobalKey> keys = <GlobalKey>[];
  ScrollController _controller = ScrollController();
  void Function(void Function(int)) setCall;
  void Function(int) itemClick;
  int curItem = 0;

  LiveBroadcastTitlePageState(this.dates, {this.setCall, this.itemClick}) {
    setCall(bodyPageChange);
    for (int i = 0; i < dates.length; i++) {
      keys.add(GlobalKey(debugLabel: i.toString()));
    }
  }

  /*
  * 1,手动滑动body页面，触发这个函数
  * 2，当点击title Item时，会调用itemClick，itemClick中会滚动body内容到指定页面，然后触发这个函数
  * */
  void bodyPageChange(int pos) {
    setState(() {
      curItem = pos;
    });
    // scrollItemToCenter(pos);
  }

  //滚动Item到指定位置，这里滚动到屏幕正中间
  void scrollItemToCenter(int pos) {
    //获取item的尺寸和位置
    RenderBox box = keys[pos].currentContext.findRenderObject();
    Offset os = box.localToGlobal(Offset.zero);

//    double h=box.size.height;
    double w = box.size.width;
    double x = os.dx;
//    double y=os.dy;
//   获取屏幕宽高
    double windowW = MediaQuery.of(context).size.width;
//    double windowH=MediaQuery.of(context).size.height;

    //就算当前item距离屏幕中央的相对偏移量
    double rlOffset = windowW / 2 - (x + w / 2);

    //计算_controller应该滚动的偏移量
    double offset = _controller.offset - rlOffset;
    _controller.animateTo(offset,
        duration: Duration(milliseconds: 200), curve: Curves.easeInOut);
  }

  Widget initItemView(BuildContext context, DateTime dateTime, int pos) {
    var containerWidth =
        (MediaQuery.of(context).size.width - 32) / dates.length;
    return Container(
      //将key设置进去，后面通过key获取指定item的位置和尺寸
      key: keys[pos],
      alignment: Alignment.bottomCenter,
      child: InkWell(
        onTap: () {
          itemClick(pos);
        },
        child: Container(
          width: containerWidth,
          decoration: BoxDecoration(
            color: curItem == pos ? AppColor.textPrimary1 : null,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                DateUtil.getStringWeekDayStartZero(dateTime.weekday - 1),
                style: TextStyle(
                    color: curItem == pos ? AppColor.white : Color(0xffCCCCCC),
                    fontSize: 14),
              ),
              Text(
                DateUtil.getDateDayStringJin(dateTime),
                style: TextStyle(
                    color:
                        curItem == pos ? AppColor.white : AppColor.textPrimary2,
                    fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget initView() {
    return Container(
      height: 72,
      margin: const EdgeInsets.only(left: 16, right: 16),
      decoration: BoxDecoration(
          color: AppColor.bgWhite.withOpacity(0.45),
          borderRadius: BorderRadius.circular(3)),
      child: ScrollConfiguration(
        behavior: NoBlueEffectBehavior(),
        child: ListView.builder(
          controller: _controller,
          scrollDirection: Axis.horizontal,
          itemCount: dates.length,
          itemBuilder: (context, pos) {
            return initItemView(context, dates[pos], pos);
          },
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return initView();
  }
}
