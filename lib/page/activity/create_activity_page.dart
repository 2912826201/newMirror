import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_service/keyboard_service.dart';
import 'package:menu_button/menu_button.dart';
import 'package:mirror/api/activity/activity_api.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/config/runtime_properties.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/activity/activity_model.dart';
import 'package:mirror/data/model/activity/auth_data.dart';
import 'package:mirror/data/model/activity/avtivity_type_data.dart';
import 'package:mirror/data/model/activity/equipment_data.dart';
import 'package:mirror/data/model/media_file_model.dart';
import 'package:mirror/data/model/upload/upload_result_model.dart';
import 'package:mirror/data/model/user_model.dart';
import 'package:mirror/page/media_picker/media_picker_page.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/click_util.dart';
import 'package:mirror/util/date_util.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/string_util.dart';
import 'package:mirror/util/text_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/activity_time_chose_bottom_sheet.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/dialog.dart';
import 'package:mirror/widget/icon.dart';
import 'package:mirror/widget/input_formatter/expression_team_delete_formatter.dart';
import 'package:mirror/widget/input_formatter/release_feed_input_formatter.dart';
import 'package:mirror/widget/state_build_keyboard.dart';
import 'package:mirror/widget/surrounding_information.dart';
import 'package:mirror/widget/text_span_field/text_span_field.dart';
import 'package:mirror/widget/user_avatar_image.dart';
import 'package:mirror/widget/week_pop_window.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:popup_window/popup_window.dart';

class CreateActivityPage extends StatefulWidget {
  @override
  _CreateActivityPageState createState() => _CreateActivityPageState();
}

class _CreateActivityPageState extends StateKeyboard {
  //活动类型
  StreamController<int> activityTypeStream = StreamController<int>();
  int selectActivityType = 0;

  //活动名称-Controller
  FocusNode titleFocusNode = FocusNode();
  TextEditingController activityTitleController = TextEditingController();

  //选择参加权限
  String selectedPermissionsKey;
  StreamController<String> joinPermissionsStream = StreamController<String>();

  //器材
  String equipmentKey;
  StreamController<String> equipmentStream = StreamController<String>();

  //活动参加人数 最少是2 最多是99
  int joinNumber = 2;
  int joinNumberMin = 2;
  int joinNumberMax = 99;
  StreamController<int> joinNumberStream = StreamController<int>();

  //活动说明
  FocusNode activityIllustrateFocusNode = FocusNode();
  TextEditingController activityIllustrateController = TextEditingController();

  GlobalKey inputBoxKey = GlobalKey();
  GlobalKey scrollKey = GlobalKey();

  ScrollController scrollController = ScrollController();

  StreamController<double> bottomStreamWidget = StreamController<double>();

  //活动时间
  DateTime activityDateTime = DateTime.now();
  DateTime startTime = DateTime.now();
  DateTime endTime = DateTime.now().add(Duration(hours: 1));
  StreamController<DateTime> activityTimeStream = StreamController<DateTime>();

  //活动地址
  String provinceCity = "";
  String cityCode;
  String longitude;
  String latitude;
  StreamController<String> provinceCityStream = StreamController<String>();

  //活动图片
  List<File> activityImageFileList = [];
  int activityImageFileListCount = 1;
  StreamController<List<File>> activityImageStream = StreamController<List<File>>();

  //推荐用户
  StreamController<List<UserModel>> recommendUserStream = StreamController<List<UserModel>>();
  List<UserModel> recommendUserList = [];
  List<int> recommendUserSelect = [];

  //是否阅读了活动说明
  bool isReadInformation = false;
  StreamController<bool> readInformationStream = StreamController<bool>();

  ReleaseFeedInputFormatter _formatter;

  @override
  void initState() {
    super.initState();
    _initData();
    _formatter = ReleaseFeedInputFormatter(
        controller: activityIllustrateController,
        maxNumberOfBytes: 300,
        context: context,
        rules: [],
        // @回调
        triggerAtCallback: (String str) {},
        // #回调
        triggerTopicCallback: (String str) {},
        // 关闭@#视图回调
        shutDownCallback: () async {},
        valueChangedCallback: (List<Rule> rules, String value, int atIndex, int topicIndex, String atSearchStr,
            String topicSearchStr, bool isAdd) {});
  }

  @override
  void dispose() {
    super.dispose();
    bottomStreamWidget.close();
    recommendUserStream.close();
    activityTypeStream.close();
    joinNumberStream.close();
    activityTimeStream.close();
    activityImageStream.close();
    equipmentStream.close();
    joinPermissionsStream.close();
    readInformationStream.close();
    provinceCityStream.close();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return KeyboardAutoDismiss(
        scaffold: Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(
        titleString: "创建活动",
      ),
      body: Container(
        color: AppColor.mainBlack,
        height: double.infinity,
        padding: EdgeInsets.only(bottom: ScreenUtil.instance.bottomBarHeight + 2),
        child: getBodyUi(),
      ),
    ));
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
        //发布活动按钮
        Positioned(
          child: _getCreateActivityBox(),
          bottom: 2,
          left: 16,
        ),
      ],
    );
  }

  //整个可滑动区域
  Widget getCustomScrollView() {
    return SingleChildScrollView(
      controller: scrollController,
      child: Container(
        constraints: BoxConstraints(minHeight: ScreenUtil.instance.height),
        child: Column(
          children: [
            //头部--活动类型
            _getActivityTypeUi(),

            //活动名称
            _getTitleWidget("输入活动名称", visible: true),
            _getEditWidget("输入内容", activityTitleController, titleFocusNode),

            //活动时间
            _getTitleWidget("活动时间"),
            _getActivityTimeUi(),
            _getSizedBox(height: 4),

            //活动地址
            _getTitleWidget("活动地点"),
            StreamBuilder<String>(
              initialData: "输入地址",
              stream: provinceCityStream.stream,
              builder: (context, data) {
                return _getSubtitleWidget(data.data, onTap: () {
                  _unfocus();
                  locationPermissions();
                });
              },
            ),


            _getSizedBox(height: 8),

            //修改参加人数
            _getTitleWidget("参加人数"),
            _getJoinNumberChangeUi(),
            _getSizedBox(height: 8),

            //参加活动的权限
            _getTitleWidget("参加权限"),
            StreamBuilder(
              initialData: selectedPermissionsKey,
              stream: joinPermissionsStream.stream,
              builder: (context, data) {
                return Container(
                  child: Stack(
                    children: [
                      _getMenuUi(selectedPermissionsKey, AuthData.init().authList, (value) {
                        selectedPermissionsKey = value;
                        joinPermissionsStream.sink.add(selectedPermissionsKey);
                      }),
                      Visibility(
                        visible: activityIllustrateFocusNode.hasFocus,
                        child: GestureDetector(
                          child: Container(
                            height: 30,
                            width: ScreenUtil.instance.width,
                            color: Colors.transparent,
                          ),
                          onTap: () {
                            _unfocus();
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            //参加活动的器材
            _getTitleWidget("器材"),
            StreamBuilder(
              initialData: equipmentKey,
              stream: equipmentStream.stream,
              builder: (context, data) {
                return Container(
                  child: Stack(
                    children: [
                      _getMenuUi(equipmentKey, EquipmentData
                          .init()
                          .equipmentList, (value) {
                        equipmentKey = value;
                        equipmentStream.sink.add(equipmentKey);
                      }),
                      Visibility(
                        visible: activityIllustrateFocusNode.hasFocus,
                        child: GestureDetector(
                          child: Container(
                            height: 30,
                            width: ScreenUtil.instance.width,
                            color: Colors.transparent,
                          ),
                          onTap: () {
                            _unfocus();
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            _getSizedBox(height: 24),

            //活动说明
            _inputBox(),

            Column(
              key: scrollKey,
              children: [
                _getSizedBox(height: 24),

                //活动图片
                _getAddImageUi(),
                _getSizedBox(height: 5),

                //推荐好友
                _getRecommendAFriendUi(),
                _getSizedBox(height: 45),
              ],
            ),

            //空白
            StreamBuilder(
                initialData: 0.0,
                stream: bottomStreamWidget.stream,
                builder: (context, snapshot) {
                  if (snapshot.data > 0) {
                    Future.delayed(Duration(milliseconds: 100), () {
                      scrollController.animateTo(scrollController.position.maxScrollExtent,
                          duration: Duration(milliseconds: 200), curve: Curves.easeInOut);
                    });
                  }
                  return Container(
                    color: AppColor.transparent,
                    height: snapshot.data,
                    width: ScreenUtil.instance.width,
                  );
                }),
          ],
        ),
      ),
    );
  }


  //获取创建活动的布局
  Widget _getCreateActivityBox() {
    return StreamBuilder(
      initialData: isReadInformation,
      stream: readInformationStream.stream,
      builder: (context, data) {
        return Container(
          height: 40,
          width: ScreenUtil.instance.width - 32,
          decoration: BoxDecoration(
            color: AppColor.layoutBgGrey,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              GestureDetector(
                child: Container(
                  width: 40,
                  height: 40,
                  padding: EdgeInsets.all(10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: data.data ? AppColor.mainRed : AppColor.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child:
                        data.data ? Image.asset("assets/png/select_icon_red.png", width: 20, height: 20) : Container(),
                  ),
                ),
                onTap: () {
                  isReadInformation = !isReadInformation;
                  readInformationStream.sink.add(isReadInformation);
                },
              ),
              Text("我已阅读并同意活动说明", style: AppStyle.whiteRegular12),
              Spacer(),
              GestureDetector(
                child: Container(
                  height: 40,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: data.data ? AppColor.mainYellow : AppColor.textWhite40,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  alignment: Alignment.centerLeft,
                  child: Text("发布活动", style: data.data ? AppStyle.textRegular15 : AppStyle.text1Regular15),
                ),
                onTap: () {
                  _createActivity();
                },
              ),
            ],
          ),
        );
      },
    );
  }


  //获取推荐好友
  Widget _getRecommendAFriendUi() {
    double imageWidth = min((ScreenUtil.instance.width - 32) / 5, 45);
    return StreamBuilder<List<UserModel>>(
        initialData: recommendUserList,
        stream: recommendUserStream.stream,
        builder: (context, snapshot) {
          if (snapshot.data == null || snapshot.data.length < 1) {
            return Container();
          } else {
            return Container(
              width: ScreenUtil.instance.width,
              child: Column(
                children: [
                  _getTitleWidget("推荐好友"),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    width: ScreenUtil.instance.width,
                    height: 120,
                    child: ListView.separated(
                        itemCount: snapshot.data.length,
                        scrollDirection: Axis.horizontal,
                        separatorBuilder: (BuildContext context, int index) => VerticalDivider(
                          width: 0.0,
                              color: AppColor.mainBlack,
                            ),
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              if (recommendUserSelect.contains(index)) {
                                recommendUserSelect.remove(index);
                              } else {
                                recommendUserSelect.add(index);
                              }
                              setState(() {});
                            },
                            child: Container(
                              width: (ScreenUtil.instance.width - 32) / 5,
                              color: AppColor.transparent,
                              child: Stack(
                                children: [
                                  Column(
                                    children: [
                                      SizedBox(height: 7),
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(color: AppColor.white, width: 1),
                                          borderRadius: BorderRadius.circular(50.0 / 2),
                                        ),
                                        child: UserAvatarImageUtil.init().getUserImageWidget(
                                            snapshot.data[index].avatarUri,
                                            snapshot.data[index].uid.toString(),
                                            imageWidth),
                                      ),
                                      SizedBox(height: 2),
                                      Text(getRelation(snapshot.data[index]), style: AppStyle.whiteRegular12),
                                    ],
                                  ),
                                  Visibility(
                                    visible: recommendUserSelect.contains(index),
                                    child: Positioned(
                                      left: imageWidth - 12.0,
                                      top: 0,
                                      child: Container(
                                        height: 18,
                                        width: 18,
                                        child: Image.asset("assets/png/select_icon_red.png", width: 18, height: 18),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                  ),
                ],
              ),
            );
          }
        });
  }

  //关系
  String getRelation(UserModel model) {
    if (model.isActivityTogether != null && model.isActivityTogether == 1) {
      return "一起活动过";
    } else if (model.relation == 1) {
      return "关注用户";
    } else if (model.relation == 2) {
      return "粉丝";
    } else if (model.relation == 3) {
      return "互关好友";
    } else {
      return "一起活动过";
    }
  }

  //选择时间的ui
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
            GestureDetector(
              child: Container(
                height: 24,
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColor.dividerWhite8, width: 0.5),
                ),
                padding: EdgeInsets.symmetric(horizontal: 22, vertical: 4),
                child: Text(
                    "${DateUtil.formatTimeString(startTime)}~"
                    "${DateUtil.formatTimeString(endTime)}",
                    style: AppStyle.text1Regular12),
              ),
              onTap: () {
                openActivityTimePickerBottomSheet(
                    context: context,
                    firstTime: activityDateTime,
                    onStartAndEndTimeChoseCallBack: (start, end) {
                      setState(() {
                        startTime = start;
                        endTime = end;
                      });
                    });
              },
            ),
          ],
        ),
      ),
    );
  }

  ///输入框
  Widget _inputBox() {
    return Stack(
      children: [
        Container(
          key: inputBoxKey,
          constraints: BoxConstraints(
            minHeight: 104,
          ),
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: 16),
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(4)), color: AppColor.layoutBgGrey),
          child: TextSpanField(
            onTap: () {
              equipmentStream.sink.add(equipmentKey);
              joinPermissionsStream.sink.add(selectedPermissionsKey);
            },
            // 多行展示
            keyboardType: TextInputType.multiline,
            //不限制行数
            maxLines: null,
            enableInteractiveSelection: true,
            controller: activityIllustrateController,
            cursorColor: AppColor.white,
            style: AppStyle.whiteRegular12,
            textInputAction: TextInputAction.send,
            maxLength: 100,
            focusNode: activityIllustrateFocusNode,
            decoration: InputDecoration(
              isDense: true,
              counterText: '',
              hintText: "活动说明...",
              hintStyle: AppStyle.text2Regular12,
              border: InputBorder.none,
            ),
            inputFormatters: [_formatter],
          ),
        )
      ],
    );
  }

  //添加图片的地方
  Widget _getAddImageUi() {
    return Stack(
      children: [
        StreamBuilder<List<File>>(
          initialData: activityImageFileList,
          stream: activityImageStream.stream,
          builder: (context, data) {
            return Container(
              width: double.infinity,
              height: 104,
              padding: EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.centerLeft,
              child: ListView.separated(
                  itemCount: data.data.length < activityImageFileListCount ? data.data.length + 1 : data.data.length,
                  scrollDirection: Axis.horizontal,
                  separatorBuilder: (BuildContext context, int index) => VerticalDivider(
                        width: 10.0,
                        color: AppColor.mainBlack,
                      ),
                  itemBuilder: (context, index) {
                    if (index != data.data.length) {
                      return _item(index, data.data[index]);
                    } else {
                      return _addImageItem();
                    }
                  }),
            );
          },
        )
      ],
    );
  }

  Widget _item(int index, File file) {
    return Container(
      height: 104,
      width: 104,
      child: Stack(
        children: [
          Positioned(
              bottom: 0,
              left: 0,
              child: Image.file(
                file,
                width: 104,
                height: 104,
                fit: BoxFit.cover,
              )),
          Positioned(
            right: 0,
            child: AppIconButton(
              svgName: AppIcon.delete,
              iconSize: 18,
              onTap: () {
                activityImageFileList.removeAt(index);
                activityImageStream.sink.add(activityImageFileList);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _addImageItem() {
    return GestureDetector(
      child: Container(
        width: 104,
        height: 104,
        decoration: BoxDecoration(
          color: AppColor.layoutBgGrey,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: AppIcon.getAppIcon(AppIcon.add_gallery, 13, color: AppColor.white),
        ),
      ),
      onTap: () {
        getStoragePermision();
      },
    );
  }

  //菜单
  Widget _getMenuUi(String selectedKey, List<String> itemList, Function(String selectValue) onItemSelected) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(width: 0.5, color: AppColor.dividerWhite8)),
      ),
      alignment: Alignment.centerLeft,
      child: MenuButton(
        itemBackgroundColor: AppColor.imageBgGrey,
        menuButtonBackgroundColor: AppColor.mainBlack,
        child: normalChildButton(selectedKey),
        items: itemList,
        decoration: BoxDecoration(
          border: Border.all(color: AppColor.dividerWhite8, width: 0.5),
          borderRadius: new BorderRadius.all(new Radius.circular(2.0)),
        ),
        divider: const Divider(
          height: 0.5,
          color: AppColor.dividerWhite8,
        ),
        itemBuilder: (String value) {
          _unfocus();
          return Container(
            height: 32,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(
              left: 6,
            ),
            child: Text(
              value,
              style: AppStyle.whiteRegular12,
            ),
          );
        },
        toggledChild: Container(
          child: normalChildButton(selectedKey),
        ),
        onItemSelected: onItemSelected,
        // onMenuButtonToggle: (bool isToggle) {
        //   print(isToggle);
        // },
      ),
    );
  }

  // 菜单打开的按钮
  Widget normalChildButton(String selectedKey) {
    return SizedBox(
        width: getTextSize("需要验证信息由我确认", AppStyle.whiteRegular12, 1).width + 30,
        height: 32,
        child: Container(
          color: AppColor.mainBlack,
          padding: const EdgeInsets.only(left: 8),
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
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(width: 0.5, color: AppColor.dividerWhite8)),
      ),
      child: Row(
        children: [
          GestureDetector(
            child: Container(
              decoration: BoxDecoration(
                color: AppColor.white,
                borderRadius: BorderRadius.circular(4),
              ),
              height: 18,
              width: 18,
              alignment: Alignment.center,
              child: Text("-", style: AppStyle.textRegular14),
            ),
            onTap: () {
              if (joinNumber - 1 >= joinNumberMin) {
                joinNumber--;
                joinNumberStream.sink.add(joinNumber);
              }
            },
          ),
          SizedBox(width: 12),
          StreamBuilder<int>(
            initialData: joinNumber,
            stream: joinNumberStream.stream,
            builder: (context, data) => Text("${data.data}", style: AppStyle.whiteRegular14),
          ),
          SizedBox(width: 12),
          GestureDetector(
            child: Container(
              decoration: BoxDecoration(
                color: AppColor.mainYellow,
                borderRadius: BorderRadius.circular(4),
              ),
              height: 18,
              width: 18,
              alignment: Alignment.center,
              child: Text("+", style: AppStyle.textRegular14),
            ),
            onTap: () {
              if (joinNumber + 1 <= joinNumberMax) {
                joinNumber++;
                joinNumberStream.sink.add(joinNumber);
              }
            },
          )
        ],
      ),
    );
  }

  //头部-选择活动项目的container
  Widget _getActivityTypeUi() {
    return StreamBuilder<int>(
      initialData: selectActivityType,
      stream: activityTypeStream.stream,
      builder: (context, data) {
        var widgetArray = <Widget>[];
        double itemWidth = (ScreenUtil.instance.width - 21 - 21) / ActivityTypeData.init().activityTypeList.length;
        int index = 0;
        ActivityTypeData.init().activityTypeMap.forEach((key, value) {
          widgetArray.add(_getActivityTypeUiItem(itemWidth, key, value[index == data.data ? 0 : 1], index));
          index++;
        });
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 21, vertical: 8),
          child: Row(
            children: widgetArray,
          ),
        );
      },
    );
  }

  //title-widget
  Widget _getTitleWidget(String title, {bool visible = false}) {
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          height: 40,
          width: double.infinity,
          alignment: Alignment.centerLeft,
          child: Text(title == null ? "" : "$title:", style: AppStyle.whiteMedium14),
        )
      ],
    );
  }

  //subtitle-widget
  Widget _getSubtitleWidget(String title, {Function() onTap}) {
    return GestureDetector(
      child: Container(
        margin: EdgeInsets.only(left: 16, right: 16),
        padding: EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(width: 0.5, color: AppColor.dividerWhite8)), color: AppColor.transparent),
        width: double.infinity,
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            Image.asset("assets/png/geographic_location_select.png", width: 16, height: 16),
            SizedBox(width: 2),
            Text(title ?? "", style: AppStyle.text1Regular14),
          ],
        ),
      ),
      onTap: onTap,
    );
  }

  //edit 输入框
  Widget _getEditWidget(String hitString, TextEditingController controller, FocusNode focusNode) {
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
        focusNode: focusNode,
        controller: controller,
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
      color: AppColor.transparent,
    );
  }

  //每一个 活动项目的 item
  Widget _getActivityTypeUiItem(double itemWidth, String typeName, String imageAssets, int index) {
    return GestureDetector(
      child: Container(
        width: itemWidth,
        child: Column(
          children: [
            Container(
              height: 45,
              width: 45,
              child: Image.asset(
                imageAssets,
                width: 45,
                height: 45,
              ),
            ),
            SizedBox(height: 2),
            Text(typeName, style: AppStyle.whiteRegular12),
          ],
        ),
      ),
      onTap: () {
        activityTypeStream.sink.add(index);
      },
    );
  }

  ///-----------获取数据-----
  ///
  /// ----------start-----

  _initData() {
    selectedPermissionsKey = AuthData.init().getDefaultString();
    equipmentKey = EquipmentData.init().getDefaultString();

    _getRecommendUserList();
  }

  //获取推荐好友
  _getRecommendUserList() async {
    recommendUserList = await getRecommendUserList();
    if (recommendUserList != null && recommendUserList.length > 0) {
      for (int i = 0; i < recommendUserList.length; i++) {
        recommendUserSelect.add(i);
      }
      recommendUserStream.sink.add(recommendUserList);
    } else {
      // recommendUserList = [];
      // recommendUserList.add(Application.profile.toUserModel());
      // recommendUserList.add(Application.profile.toUserModel());
      // recommendUserList.add(Application.profile.toUserModel());
      // recommendUserList.add(Application.profile.toUserModel());
      // recommendUserList.add(Application.profile.toUserModel());
      // recommendUserStream.sink.add(recommendUserList);
    }
  }

  ///-----------获取数据-----
  ///
  /// ----------end-----

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
              StreamBuilder<DateTime>(
                initialData: activityDateTime,
                stream: activityTimeStream.stream,
                builder: (context, data) {
                  return Text(DateUtil.formatDateNoYearString(data.data), style: AppStyle.text1Regular12);
                },
              ),
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
        _unfocus();
        return FadeTransition(
          opacity: animation,
          child: SizeTransition(
              sizeFactor: animation,
              child: Container(
                child: WeekPopWindow(
                  initDateTime: activityDateTime,
                  onTapChoseCallBack: (dateTime) {
                    activityDateTime = dateTime;
                    activityTimeStream.sink.add(activityDateTime);
                  },
                ),
                width: ScreenUtil.instance.width,
                padding: EdgeInsets.only(right: 16),
              )),
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


  _unfocus() {
    if (titleFocusNode.hasFocus) {
      titleFocusNode.unfocus();
    }
    if (activityIllustrateFocusNode.hasFocus) {
      activityIllustrateFocusNode.unfocus();
    }
  }


  //从相册获取照片
  _getImage() {
    if (activityImageFileList.length == activityImageFileListCount) {
      ToastShow.show(msg: "最多只能选择$activityImageFileListCount张图片哦~", context: context);
    }
    AppRouter.navigateToMediaPickerPage(
        context,
        activityImageFileListCount - activityImageFileList.length,
        typeImage,
        false,
        startPageGallery,
        false,
            (result) {
      SelectedMediaFiles files = RuntimeProperties.selectedMediaFiles;
      if (!result || files == null) {
        print('===============================值为空退回');
        return;
      }
      RuntimeProperties.selectedMediaFiles = null;
      List<MediaFileModel> model = files.list;
      model.forEach((element) async {
        if (element.file != null) {
          activityImageFileList.add(element.file);
          activityImageStream.sink.add(activityImageFileList);
        }
      });
    });
  }


  void getStoragePermision() async {
    var permissionStatus = await Permission.storage.status;
    switch (permissionStatus) {
      case PermissionStatus.granted:
        _getImage();
        break;
      case PermissionStatus.denied:
        var status = await Permission.storage.request();
        switch (status) {
          case PermissionStatus.granted:
            _getImage();
            break;
          case PermissionStatus.permanentlyDenied:
            showAppDialog(context,
                title: "储存权限",
                info: "由于没有储存权限，无法选择图片！",
                cancel: AppDialogButton("返回", () {
                  return true;
                }),
                confirm: AppDialogButton(
                  "去设置",
                  () {
                    AppSettings.openAppSettings();
                    return true;
                  },
                ),
                barrierDismissible: false);
            break;
        }
        break;
    }
  }

  // 获取定位权限
  locationPermissions() async {
    // 获取定位权限
    PermissionStatus permissions = await Permission.locationWhenInUse.status;
    print("下次寻问permissions：：：：$permissions");
    // 已经获取了定位权限
    if (permissions.isGranted) {
      openSurroundingInformationBottomSheet(
          context: context,
          onSeletedAddress: (provinceCity, cityCode, longitude, latitude) {
            // provinceCity 选择地址名  cityCode 城市码，
            this.provinceCity = provinceCity;
            this.cityCode = cityCode;
            this.longitude = longitude.toString();
            this.latitude = latitude.toString();
            provinceCityStream.sink.add(provinceCity);
          });
    } else {
      print("嘻嘻嘻嘻嘻");
      // 请求定位权限
      permissions = await Permission.locationWhenInUse.request();
      print("permissions::::$permissions");
      if (permissions.isGranted) {
        openSurroundingInformationBottomSheet(
            context: context,
            onSeletedAddress: (provinceCity, cityCode, longitude, latitude) {
              // provinceCity 选择地址名  cityCode 城市码，
              this.provinceCity = provinceCity;
              this.cityCode = cityCode;
              this.longitude = longitude.toString();
              this.latitude = latitude.toString();
              provinceCityStream.sink.add(provinceCity);
            });
      } else {
        _locationFailPopUps();
      }
    }
  }

  // 定位失败弹窗
  _locationFailPopUps() {
    return showAppDialog(context,
        title: "位置信息",
        info: "你没有开通位置权限，您可以通过系统\"设置\"进行权限管理",
        confirmColor: AppColor.white,
        cancel: AppDialogButton("返回", () {
          return true;
        }),
        confirm: AppDialogButton("去设置", () {
          AppSettings.openLocationSettings();
          return true;
        }));
  }

  @override
  void endChangeKeyBoardHeight(bool isOpenKeyboard) {
    if (!isOpenKeyboard) {
      bottomStreamWidget.sink.add(0.0);
      equipmentStream.sink.add(equipmentKey);
      joinPermissionsStream.sink.add(selectedPermissionsKey);
    } else {
      print("111:${activityIllustrateFocusNode.hasFocus}");
      if (activityIllustrateFocusNode.hasFocus) {
        Future.delayed(Duration(milliseconds: 100), () {
          RenderBox renderBox = inputBoxKey.currentContext.findRenderObject();
          var offset = renderBox.localToGlobal(Offset.zero);

          double value = (offset.dy + 110.0) - (ScreenUtil.instance.height - Application.keyboardHeightIfPage);

          double widgetHeight = scrollKey.currentContext.size.height;

          print("value:$value,widgetHeight:$widgetHeight,${Application.keyboardHeightIfPage}");

          if (value > 0) {
            if (widgetHeight >= Application.keyboardHeightIfPage) {
              scrollController.animateTo(scrollController.position.pixels + value,
                  duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
            } else {
              bottomStreamWidget.sink.add(value);
            }
          }
        });
      }
    }
  }

  @override
  void startChangeKeyBoardHeight(bool isOpenKeyboard) {
    // TODO: implement startChangeKeyBoardHeight
  }

  bool isCreateActivity = false;

  //创建活动
  _createActivity() async {
    if (ClickUtil.isFastClick()) {
      return;
    }
    if (!isReadInformation) {
      ToastShow.show(msg: "请阅读活动说明", context: context);
      return;
    }

    if (activityTitleController.text == null ||
        activityTitleController.text.length < 1 ||
        cityCode == null ||
        activityImageFileList.length < 1) {
      ToastShow.show(msg: "请检查参数", context: context);
      return;
    }
    // 检测文本
    Map<String, dynamic> textModel = await feedTextScan(text: activityTitleController.text);
    if (!textModel["state"]) {
      ToastShow.show(msg: "你发布的描述文字可能存在敏感内容", context: context, gravity: Toast.CENTER);
      return;
    }
    textModel = await feedTextScan(text: activityIllustrateController.text);
    if (!textModel["state"]) {
      ToastShow.show(msg: "你发布的描述文字可能存在敏感内容", context: context, gravity: Toast.CENTER);
      return;
    }

    if (isCreateActivity) {
      ToastShow.show(msg: "正在创建活动", context: context);
      return;
    }
    isCreateActivity = true;

    ToastShow.show(msg: "正在创建活动请稍等", context: context);

    ActivityModel model = await createActivity(
      title: StringUtil.textWrapMatch(activityTitleController.text),
      type: selectActivityType,
      count: joinNumber,
      startTime: getStartTime().millisecondsSinceEpoch,
      endTime: getEndTime().millisecondsSinceEpoch,
      cityCode: cityCode,
      address: provinceCity,
      longitude: longitude,
      latitude: latitude,
      equipment: EquipmentData.init().getIndex(equipmentKey),
      auth: AuthData.init().getIndex(selectedPermissionsKey),
      pic: await onPostImageFile(),
      description: StringUtil.textWrapMatch(activityIllustrateController.text),
      uids: _getRecommendUserString(),
    );

    if (model != null) {
      print("model:${model.toJson().toString()}");
      isCreateActivity = false;
      ToastShow.show(msg: "创建成功", context: context);
      Navigator.of(context).pop();
      AppRouter.navigateActivityDetailPage(context, model.id, activityModel: model);
    } else {
      isCreateActivity = false;
      ToastShow.show(msg: "创建失败", context: context);
    }
  }

  DateTime getStartTime() {
    return DateTime(
      activityDateTime.year,
      activityDateTime.month,
      activityDateTime.day,
      startTime.hour,
      startTime.minute,
      startTime.second,
    );
  }

  DateTime getEndTime() {
    return DateTime(
      activityDateTime.year,
      activityDateTime.month,
      activityDateTime.day,
      endTime.hour,
      endTime.minute,
      endTime.second,
    );
  }

  Future<String> onPostImageFile() async {
    UploadResults results = await FileUtil().uploadPics(activityImageFileList, (percent) {});
    List<UploadResultModel> uploadResultModelList = <UploadResultModel>[];
    for (int i = 0; i < results.resultMap.length; i++) {
      UploadResultModel model = results.resultMap.values.elementAt(i);
      uploadResultModelList.add(model);
      print("第${i + 1}个上传文件");
      print(model.isSuccess);
      print(model.error);
      print(model.filePath);
      print(model.url);
    }
    return uploadResultModelList[0].url;
  }

  //获取推荐好友的id
  String _getRecommendUserString() {
    if (recommendUserList.length < 1) {
      return "";
    } else {
      String uids = "";
      for (int i = 0; i < recommendUserSelect.length; i++) {
        if (i == recommendUserSelect.length - 1) {
          uids += recommendUserList[recommendUserSelect[i]].uid.toString();
        } else {
          uids += recommendUserList[recommendUserSelect[i]].uid.toString() + ",";
        }
      }
      return uids;
    }
  }


}
