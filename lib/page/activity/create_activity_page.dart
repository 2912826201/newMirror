import 'package:flutter/material.dart';
import 'package:menu_button/menu_button.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/text_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/icon.dart';
import 'package:mirror/widget/input_formatter/expression_team_delete_formatter.dart';
import 'package:mirror/widget/text_span_field/text_span_field.dart';
import 'package:popup_window/popup_window.dart';

class CreateActivityPage extends StatefulWidget {
  @override
  _CreateActivityPageState createState() => _CreateActivityPageState();
}

class _CreateActivityPageState extends State<CreateActivityPage> {
  Map<String, List<String>> activityTypeMap = Map();
  int selectActivityType = 0;

  //选择参加权限
  String selectedPermissionsKey;
  List<String> joinPermissionsList = ["所有人", "需要验证信息由我确认", "受到邀请的人"];

  //器材
  String equipmentKey;
  List<String> equipmentList = ["参与人自带", "无需器材", "发起人准备"];

  @override
  void initState() {
    super.initState();
    activityTypeMap["篮球"] = [AppIcon.input_gallery, AppIcon.message_emotion];
    activityTypeMap["足球"] = [AppIcon.input_gallery, AppIcon.message_emotion];
    activityTypeMap["羽毛球"] = [AppIcon.input_gallery, AppIcon.message_emotion];
    activityTypeMap["乒乓球"] = [AppIcon.input_gallery, AppIcon.message_emotion];
    activityTypeMap["网球"] = [AppIcon.input_gallery, AppIcon.message_emotion];
    activityTypeMap["跑步"] = [AppIcon.input_gallery, AppIcon.message_emotion];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleString: "创建活动",
      ),
      body: Container(
        color: AppColor.mainBlack,
        height: double.infinity,
        child: getBodyUi(),
      ),
    );
  }

  //整体布局
  Widget getBodyUi() {
    return Stack(
      children: [
        Container(
          height: double.infinity,
          width: ScreenUtil.instance.width,
          child: getCustomScrollView(),
        ),
        Positioned(
          child: Container(
            color: AppColor.mainBlue,
            height: 40,
            width: ScreenUtil.instance.width - 32,
          ),
          bottom: 2,
          left: 16,
        ),
      ],
    );
  }

  //整个可滑动区域
  Widget getCustomScrollView() {
    return SingleChildScrollView(
      child: Container(
        child: Column(
          children: [
            _getActivityTypeUi(),
            _getTitleWidget("输入活动名称"),
            _getEditWidget("输入内容"),
            _getTitleWidget("活动时间"),
            _getActivityTimeUi(),
            _getSizedBox(height: 4),
            _getTitleWidget("活动地点"),
            _getEditWidget("输入地址"),
            _getSizedBox(height: 8),
            _getTitleWidget("参加人数"),
            _getJoinNumberChangeUi(),
            _getSizedBox(height: 8),
            _getTitleWidget("参加权限"),
            _getMenuUi(joinPermissionsList[0], joinPermissionsList),
            _getTitleWidget("器材"),
            _getMenuUi("发起人准备", equipmentList),
            _getAddImageUi(),
            _getSizedBox(height: 24),
            _inputBox(),
            _getSizedBox(height: 18),
            _getTitleWidget("邀请好友参加"),
          ],
        ),
      ),
    );
  }

  //选中时间的ui
  Widget _getActivityTimeUi() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(width: 0.5, color: AppColor.dividerWhite8)),
      ),
      padding: EdgeInsets.only(bottom: 10),
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: UnconstrainedBox(
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            _showSelectJoinTimePopupWindow(),
            SizedBox(width: 18),
            Container(
              height: 24,
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColor.dividerWhite8, width: 0.5),
              ),
              padding: EdgeInsets.symmetric(horizontal: 22, vertical: 4),
              child: Text("18:30~19:30", style: AppStyle.text1Regular12),
            ),
          ],
        ),
      ),
    );
  }

  ///输入框
  Widget _inputBox() {
    return Container(
      height: 104,
      width: double.infinity,
      padding: EdgeInsets.only(left: 16, right: 16, top: 8),
      decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(4)), color: AppColor.layoutBgGrey),
      child: TextField(
        cursorColor: AppColor.white,
        style: AppStyle.whiteRegular16,
        maxLines: null,
        maxLength: 500,
        decoration: InputDecoration(
          isDense: true,
          counterText: '',
          hintText: "活动说明...",
          hintStyle: AppStyle.text2Regular12,
          border: InputBorder.none,
        ),
        inputFormatters: [ExpressionTeamDeleteFormatter(maxLength: 500)],
      ),
    );
  }

  //添加图片的地方
  Widget _getAddImageUi() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      height: 90,
      color: AppColor.layoutBgGrey,
      child: Column(
        children: [
          AppIconButton(
            iconColor: AppColor.white,
            iconSize: 35,
            svgName: AppIcon.input_gallery,
          ),
          Text("添加图片", style: AppStyle.whiteRegular12),
        ],
      ),
    );
  }

  //菜单
  Widget _getMenuUi(String selectedKey, List<String> itemList) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(left: 16),
      padding: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(width: 0.5, color: AppColor.dividerWhite8)),
      ),
      alignment: Alignment.centerLeft,
      child: MenuButton(
        itemBackgroundColor: AppColor.mainBlack,
        menuButtonBackgroundColor: AppColor.mainBlack,
        child: normalChildButton(selectedKey),
        items: itemList,
        decoration: BoxDecoration(
          border: Border.all(color: AppColor.dividerWhite8),
          borderRadius: new BorderRadius.all(new Radius.circular(2.0)),
        ),
        divider: const Divider(
          height: 0,
          color: AppColor.imageBgGrey,
        ),
        itemBuilder: (String value) => Container(
          height: 28,
          color: AppColor.imageBgGrey,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 6),
          child: Text(
            value,
            style: AppStyle.whiteRegular12,
          ),
        ),
        toggledChild: Container(
          child: normalChildButton(selectedKey),
        ),
        onItemSelected: (String value) {
          setState(() {
            selectedKey = value;
          });
        },
        // onMenuButtonToggle: (bool isToggle) {
        //   print(isToggle);
        // },
      ),
    );
  }

  // 菜单打开的按钮
  Widget normalChildButton(String selectedKey) {
    return SizedBox(
        width: getTextSize("需要验证信息由我确认", AppStyle.whiteRegular12, 1).width + 12,
        height: 30,
        child: Container(
          margin: const EdgeInsets.only(left: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(selectedKey ?? "筛选",
                  style: selectedKey != null
                      ? AppStyle.whiteRegular12
                      : TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColor.textWhite60),
                  overflow: TextOverflow.ellipsis),
              RotatedBox(
                quarterTurns: 1,
                child: AppIcon.getAppIcon(
                  AppIcon.arrow_right_18,
                  18,
                  color: AppColor.textWhite60,
                ),
              ),
            ],
          ),
        ));
  }

  //选择参加人数ui
  Widget _getJoinNumberChangeUi() {
    return Container(
      margin: EdgeInsets.only(left: 16),
      padding: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(width: 0.5, color: AppColor.dividerWhite8)),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColor.white,
              borderRadius: BorderRadius.circular(4),
            ),
            height: 18,
            width: 18,
            alignment: Alignment.center,
            child: Text("-", style: AppStyle.textRegular14),
          ),
          SizedBox(width: 12),
          Text("2", style: AppStyle.whiteRegular14),
          SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColor.mainYellow,
              borderRadius: BorderRadius.circular(4),
            ),
            height: 18,
            width: 18,
            alignment: Alignment.center,
            child: Text("+", style: AppStyle.textRegular14),
          ),
        ],
      ),
    );
  }

  //头部-选择活动项目的container
  Widget _getActivityTypeUi() {
    var widgetArray = <Widget>[];
    double itemWidth = (ScreenUtil.instance.width - 21 - 21) / activityTypeMap.length;
    int index = 0;
    activityTypeMap.forEach((key, value) {
      widgetArray.add(_getActivityTypeUiItem(itemWidth, key, value[index == selectActivityType ? 0 : 1], index));
      index++;
    });
    return Container(
      height: 75,
      padding: EdgeInsets.symmetric(horizontal: 21),
      child: Row(
        children: widgetArray,
      ),
    );
  }

  //title-widget
  Widget _getTitleWidget(String title) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      height: 40,
      width: double.infinity,
      alignment: Alignment.centerLeft,
      child: Text(title == null ? "" : "$title:", style: AppStyle.whiteMedium14),
    );
  }

  //edit 输入框
  Widget _getEditWidget(String hitString) {
    return Container(
      margin: EdgeInsets.only(left: 16, right: 16),
      padding: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(width: 0.5, color: AppColor.dividerWhite8)),
      ),
      child: TextSpanField(
        // 多行展示
        keyboardType: TextInputType.multiline,
        //不限制行数
        maxLines: 1,
        enableInteractiveSelection: true,
        // 光标颜色
        cursorColor: AppColor.textWhite60,
        scrollPadding: EdgeInsets.all(0),
        style: AppStyle.whiteRegular14,
        textInputAction: TextInputAction.send,
        showCursor: true,
        // 装饰器修改外观
        decoration: InputDecoration(
          // 去除下滑线
          border: InputBorder.none,
          // 提示文本
          hintText: hitString,
          // 提示文本样式
          hintStyle: AppStyle.text1Regular14,
          // 设置为true,contentPadding才会生效，TextField会有默认高度。
          isCollapsed: true,
        ),
      ),
    );
  }

  //间距
  Widget _getSizedBox({double height = 0, double width = 0}) {
    return Container(
      height: height,
      width: width,
    );
  }

  //每一个 活动项目的 item
  Widget _getActivityTypeUiItem(double itemWidth, String typeName, String svgName, int index) {
    return GestureDetector(
      child: Container(
        width: itemWidth,
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(45 / 2),
              child: Container(
                height: 45,
                width: 45,
                // color: AppColor.white,
                child: AppIconButton(
                  onTap: () {
                    setState(() {
                      selectActivityType = index;
                    });
                  },
                  iconColor: AppColor.white,
                  iconSize: 45,
                  svgName: svgName,
                ),
              ),
            ),
            SizedBox(height: 2),
            Text(typeName, style: AppStyle.whiteRegular12),
          ],
        ),
      ),
      onTap: () {
        setState(() {
          selectActivityType = index;
        });
      },
    );
  }

  //显示选择时间的popup
  Widget _showSelectJoinTimePopupWindow() {
    return PopupWindowButton(
      offset: Offset(0, 24),
      buttonBuilder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColor.dividerWhite8, width: 0.5),
          ),
          padding: EdgeInsets.symmetric(horizontal: 6),
          width: 104,
          height: 24,
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              Text("8月18日", style: AppStyle.text1Regular12),
              Spacer(),
              RotatedBox(
                quarterTurns: 1,
                child: AppIcon.getAppIcon(
                  AppIcon.arrow_right_18,
                  16,
                  color: AppColor.textWhite60,
                ),
              ),
            ],
          ),
        );
      },
      windowBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
        return FadeTransition(
          opacity: animation,
          child: SizeTransition(
            sizeFactor: animation,
            child: Container(
              color: Colors.greenAccent,
              height: 100,
            ),
          ),
        );
      },
      onWindowShow: () {
        print('PopupWindowButton window show');
      },
      onWindowDismiss: () {
        print('PopupWindowButton window dismiss');
      },
    );
  }
}
