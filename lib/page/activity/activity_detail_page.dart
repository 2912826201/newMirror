import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/activity/activity_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/activity/activity_model.dart';
import 'package:mirror/data/model/activity/avtivity_type_data.dart';
import 'package:mirror/data/model/activity/equipment_data.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/data/model/peripheral_information_entity/peripheral_information_entify.dart';
import 'package:mirror/data/notifier/token_notifier.dart';
import 'package:mirror/page/activity/detail_item/detail_activity_bottom_ui.dart';
import 'package:mirror/page/activity/detail_item/detail_member_user_ui.dart';
import 'package:mirror/page/activity/util/activity_util.dart';
import 'package:mirror/page/training/common/common_comment_page.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/event_bus.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/activity_pull_down_refresh.dart';
import 'package:mirror/widget/change_insert_user_bottom_sheet.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/dialog.dart';
import 'package:mirror/widget/feed/feed_more_popups.dart';
import 'package:mirror/widget/icon.dart';
import 'package:mirror/widget/loading.dart';
import 'package:mirror/widget/smart_refressher_head_footer.dart';
import 'package:mirror/widget/state_build_keyboard.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:provider/provider.dart';

import 'activity_change_address_page.dart';
import 'detail_item/deatil_activity_comment_ui.dart';
import 'detail_item/detail_activity_feed_ui.dart';
import 'detail_item/detail_evaluate_ui.dart';
import 'detail_item/detail_start_time_ui.dart';

class ActivityDetailPage extends StatefulWidget {
  final int activityId;
  final int inviterId;
  final ActivityModel activityModel;

  ActivityDetailPage({@required this.activityId, this.inviterId, this.activityModel});

  @override
  _ActivityDetailPageState createState() => _ActivityDetailPageState(activityModel: activityModel);
}

class _ActivityDetailPageState extends StateKeyboard<ActivityDetailPage> {
  ActivityModel activityModel;

  _ActivityDetailPageState({this.activityModel});

  LoadingStatus loadingStatus;

  //???????????????????????????
  ScrollController scrollController = ScrollController();

  GlobalKey<CommonCommentPageState> childKey = GlobalKey();

  //??????????????????
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  List<GlobalKey> globalKeyList = <GlobalKey>[];

  double offsetHeight = ScreenUtil.instance.width - (ScreenUtil.instance.width / (375 / 197));
  RefreshController refreshController = RefreshController();
  GlobalKey inputEvaluateBoxKey = GlobalKey();
  FocusNode inputEvaluateFocusNode = FocusNode();
  GlobalKey<ActivityPullDownRefreshState> pullDownKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    if (activityModel != null) {
      loadingStatus = LoadingStatus.STATUS_COMPLETED;
      _initData();
    } else if (widget.activityId != null) {
      loadingStatus = LoadingStatus.STATUS_LOADING;
      _initData();
    } else {
      loadingStatus = LoadingStatus.STATUS_IDEL;
    }

    //??????????????????
    EventBus.init()
        .registerNoParameter(_loginSuccessful, EVENTBUS_ACTIVITY_DETAILS, registerName: EVENTBUS_LOGIN_SUCCESSFUL);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    //????????????
    EventBus.init().unRegister(pageName: EVENTBUS_ACTIVITY_DETAILS, registerName: EVENTBUS_LOGIN_SUCCESSFUL);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    offsetHeight = ScreenUtil.instance.width / 4;
    return Scaffold(
      resizeToAvoidBottomInset: false,
       appBar: CustomAppBar(
        titleString: "????????????",
        actions: [
          activityModel != null && activityModel.isJoin
              ? CustomAppBarIconButton(svgName: AppIcon.nav_more, iconColor: AppColor.white, onTap: _topMoreBtnClick)
              : Container(),
        ],
      ),
      body: Container(
        color: AppColor.mainBlack,
        height: ScreenUtil.instance.height,
        width: ScreenUtil.instance.width,
        child: _bodyUi(),
      ),
    );
  }

  Widget _bodyUi() {
    if (loadingStatus == LoadingStatus.STATUS_LOADING) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else if (loadingStatus == LoadingStatus.STATUS_IDEL) {
      return Center(
        child: GestureDetector(
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 224,
                  height: 224,
                  child: Image.asset(
                    "assets/png/default_no_data.png",
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(
                  height: 14,
                ),
                Text(
                  "??????????????????????????????????????????~",
                  style: AppStyle.text1Regular14,
                ),
                SizedBox(
                  height: 100,
                ),
              ],
            ),
          ),
          onTap: () {
            if (widget.activityId != null) {
              loadingStatus = LoadingStatus.STATUS_LOADING;
              _initData();
            } else {
              loadingStatus = LoadingStatus.STATUS_IDEL;
            }
          },
        ),
      );
    } else {
      return Container(
        padding: EdgeInsets.only(bottom: ScreenUtil.instance.bottomBarHeight),
        child: _getDetailWidget(),
      );
    }
  }

  Widget _appBar() {
    return Container(
      height: CustomAppBar.appBarHeight + ScreenUtil.instance.statusBarHeight,
      width: ScreenUtil.instance.width,
      color: AppColor.mainBlack,
      padding: EdgeInsets.only(left: 8, right: 8, top: ScreenUtil.instance.statusBarHeight),
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: CustomAppBarIconButton(
                svgName: AppIcon.nav_return,
                iconColor: AppColor.white,
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ),
            flex: 1,
          ),
          Text(
            "????????????",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppColor.white),
          ),
          activityModel != null && activityModel.isJoin
              ? Expanded(
                  child: Align(
                      alignment: Alignment.centerRight,
                      child:
                          CustomAppBarIconButton(svgName: AppIcon.nav_more, iconColor: AppColor.white, onTap: () {})),
                  flex: 1,
                )
              : Spacer(),
        ],
      ),
    );
  }

  Widget _getDetailWidget() {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        /*SingleChildScrollView(
          controller: scrollController,
          child: Transform.translate(
            offset: Offset(0, -offsetHeight),
            child: Container(
              child:*/
        _getSingleChildScrollView(),
        // Positioned(top: 0, child: _appBar()),
        /*    ),
          ),
        ),*/
        Container(
          height: 40,
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColor.mainBlack,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        _getBottomBtn(),
      ],
    );
  }

  Widget _getSingleChildScrollView() {
    return Transform.translate(
        offset: const Offset(0.0, -50.0),
        child: SmartRefresher(
          controller: refreshController,
          header: SmartRefresherHeadFooter.init().getActivityHeader(),
          onRefresh: () {
            Future.delayed(Duration(milliseconds: 4000),(){
              refreshController.refreshCompleted();
            });
            // refreshController.x;
          },
          child: SingleChildScrollView(
            child: Column(children: [
              CachedNetworkImage(
                height: 300,
                width: ScreenUtil.instance.width,
                imageUrl: activityModel.pic == null ? "" : FileUtil.getImageSlim(activityModel.pic),
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppColor.imageBgGrey,
                ),
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //????????????
                    DetailStartTimeUi(activityModel.times, activityModel.status),
                    SizedBox(height: 21),

                    //????????????
                    Text("???????????????${activityModel.title ?? ""}", style: AppStyle.whiteRegular16),
                    SizedBox(height: 10),

                    //????????????
                    Text("???????????????${EquipmentData.init().getString(activityModel.equipment)}",
                        style: AppStyle.text1Regular14),
                    SizedBox(height: 12),

                    //????????????
                    Container(
                      child: Row(
                        children: [
                          Container(
                            child: Image.asset(ActivityTypeData.init().getIconStringIndex(activityModel.type)[1],
                                width: 22, height: 22),
                            padding: const EdgeInsets.only(top: 1),
                          ),
                          SizedBox(width: 4),
                          Text("${ActivityTypeData.init().getString(activityModel.type)}",
                              style: AppStyle.text1Regular14),
                        ],
                      ),
                    ),
                    SizedBox(height: 12),

                    //????????????
                    Container(
                      child: Row(
                        children: [
                          Image.asset("assets/png/geographic_location.png", width: 20, height: 20),
                          SizedBox(width: 4),
                          Text("${activityModel.address}", style: AppStyle.text1Regular14),
                        ],
                      ),
                    ),
                    SizedBox(height: 38),

                    //????????????
                    _getMembersUserUI(),

                    //????????????
                    DetailActivityFeedUi(activityModel),
                    SizedBox(height: 18),

                    //????????????
                    SingleChildScrollView(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColor.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: EdgeInsets.all(10),
                        child: Text(activityModel.description, style: AppStyle.text1Regular14),
                      ),
                    ),
                    //??????
                    Container(
                      key: inputEvaluateBoxKey,
                      child: DetailEvaluateUi(activityModel, inputEvaluateFocusNode, () {
                        _initData();
                      }),
                    ),
                  ],
                ),
              ),

              //?????????
              SizedBox(height: 30),
              _getActivityCommentUi(),

              SizedBox(height: 20),

              Container(
                margin: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColor.dividerWhite8, width: 0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("????????????:", style: AppStyle.yellowRegular14),
                    Container(
                      constraints: BoxConstraints(
                        minHeight: 78,
                      ),
                      child: Text("???????????????24?????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????",
                          style: AppStyle.whiteRegular14),
                    )
                  ],
                ),
              ),
              SizedBox(height: 20),
            ]),
          ),
        ));
    //   ActivityPullDownRefresh(
    //   scrollController: scrollController,
    //   key: pullDownKey,
    //   refreshIcons: AppIcon.camera_switch,
    //   iconSize: 50,
    //   iconColor: AppColor.mainRed,
    //   imageUrl: activityModel.pic == null ? "" : FileUtil.getImageSlim(activityModel.pic),
    //   backGroundHeight: 300,
    //   needAppBar: false,
    //   needAction: activityModel != null &&
    //       activityModel.masterId != null &&
    //       Application.profile != null &&
    //       activityModel.masterId == Application.profile.uid,
    //   children: [
    //     //????????????
    //     // _getTopImage(),
    //
    //     SizedBox(height: 12),
    //
    //     Container(
    //       padding: EdgeInsets.symmetric(horizontal: 16),
    //       child: Column(
    //         crossAxisAlignment: CrossAxisAlignment.start,
    //         children: [
    //           //????????????
    //           DetailStartTimeUi(activityModel.times, activityModel.status),
    //           SizedBox(height: 21),
    //
    //           //????????????
    //           Text("???????????????${activityModel.title ?? ""}", style: AppStyle.whiteRegular16),
    //           SizedBox(height: 10),
    //
    //           //????????????
    //           Text("???????????????${EquipmentData.init().getString(activityModel.equipment)}", style: AppStyle.text1Regular14),
    //           SizedBox(height: 12),
    //
    //           //????????????
    //           Container(
    //             child: Row(
    //               children: [
    //                 Container(
    //                   child: Image.asset(ActivityTypeData.init().getIconStringIndex(activityModel.type)[1],
    //                       width: 22, height: 22),
    //                   padding: const EdgeInsets.only(top: 1),
    //                 ),
    //                 SizedBox(width: 4),
    //                 Text("${ActivityTypeData.init().getString(activityModel.type)}", style: AppStyle.text1Regular14),
    //               ],
    //             ),
    //           ),
    //           SizedBox(height: 12),
    //
    //           //????????????
    //           Container(
    //             child: Row(
    //               children: [
    //                 Image.asset("assets/png/geographic_location.png", width: 20, height: 20),
    //                 SizedBox(width: 4),
    //                 Text("${activityModel.address}", style: AppStyle.text1Regular14),
    //               ],
    //             ),
    //           ),
    //           SizedBox(height: 38),
    //
    //           //????????????
    //           _getMembersUserUI(),
    //
    //           //????????????
    //           DetailActivityFeedUi(activityModel),
    //           SizedBox(height: 18),
    //
    //           //????????????
    //           SingleChildScrollView(
    //             child: Container(
    //               width: double.infinity,
    //               decoration: BoxDecoration(
    //                 color: AppColor.white.withOpacity(0.1),
    //                 borderRadius: BorderRadius.circular(4),
    //               ),
    //               padding: EdgeInsets.all(10),
    //               child: Text(activityModel.description, style: AppStyle.text1Regular14),
    //             ),
    //           ),
    //         ],
    //       ),
    //     ),
    //
    //     //??????
    //     Container(
    //       key: inputEvaluateBoxKey,
    //       child: DetailEvaluateUi(activityModel, inputEvaluateFocusNode, () {
    //         _initData();
    //       }),
    //     ),
    //
    //     //?????????
    //     SizedBox(height: 30),
    //     _getActivityCommentUi(),
    //
    //     SizedBox(height: 20),
    //
    //     Container(
    //       margin: EdgeInsets.symmetric(horizontal: 16),
    //       decoration: BoxDecoration(
    //         border: Border.all(color: AppColor.dividerWhite8, width: 0.5),
    //         borderRadius: BorderRadius.circular(4),
    //       ),
    //       padding: const EdgeInsets.all(12),
    //       child: Column(
    //         crossAxisAlignment: CrossAxisAlignment.start,
    //         children: [
    //           Text("????????????:", style: AppStyle.yellowRegular14),
    //           Container(
    //             constraints: BoxConstraints(
    //               minHeight: 78,
    //             ),
    //             child: Text("???????????????24?????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????", style: AppStyle.whiteRegular14),
    //           )
    //         ],
    //       ),
    //     ),
    //     SizedBox(height: 20),
    //   ],
    //   onrefresh: () {
    //     _initData();
    //   },
    //   actionTap: () {},
    // );
  }

  //???????????????
  Widget _getActivityCommentUi() {
    return Visibility(
      visible: loadingStatus == LoadingStatus.STATUS_COMPLETED,
      child: CommonCommentPage(
          key: childKey,
          scrollController: scrollController,
          refreshController: _refreshController,
          fatherComment: null,
          targetId: activityModel.id,
          targetType: 4,
          pageCommentSize: 3,
          pushId: activityModel.masterId,
          pageSubCommentSize: 3,
          isShowHotOrTime: true,
          isInteractiveIn: false,
          commentDtoModel: null,
          isShowAt: false,
          isActivity: true,
          externalScrollHeight: (524 + ScreenUtil.instance.width / 4 * 3) ~/ 1,
          isVideoCoursePage: true,
          activityMoreOnTap: () {
            if (context.read<TokenNotifier>().isLoggedIn) {
              openActivityCommentBottomSheet(
                context: context,
                activityId: activityModel.id,
                pushId: activityModel.masterId,
              );
            } else {
              // ?????????
              AppRouter.navigateToLoginPage(context);
            }
          }),
    );
  }

  Widget _getBottomBtn() {
    return DetailActivityBottomUi(activityModel, widget.inviterId, () {
      _initData();
    });
  }

  //????????????
  Widget _getTopImage() {
    return CachedNetworkImage(
      height: ScreenUtil.instance.width,
      width: ScreenUtil.instance.width,
      imageUrl: activityModel.pic == null ? "" : FileUtil.getImageSlim(activityModel.pic),
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: AppColor.imageBgGrey,
      ),
      errorWidget: (context, url, error) => Container(
        color: AppColor.imageBgGrey,
      ),
    );
  }

  //???????????????ui
  Widget _getMembersUserUI() {
    if (activityModel.members == null || activityModel.members.length < 1) {
      return Container();
    }
    return DetailMemberUserUi(activityModel);
  }

  ///???????????????
  _initData() async {
    activityModel = await getActivityDetailApi(widget.activityId);
    setState(() {
      if (pullDownKey != null && pullDownKey.currentState != null) {
        pullDownKey.currentState.refreshCompleted();
      }
      if (activityModel == null) {
        loadingStatus = LoadingStatus.STATUS_IDEL;
      } else {
        loadingStatus = LoadingStatus.STATUS_COMPLETED;
      }
    });
  }

  _topMoreBtnClick() {
    List<String> list = [];
    if (Application.profile != null && Application.profile.uid == activityModel.masterId) {
      list.add("????????????");
      list.add("????????????");
      list.add("??????????????????");
      list.add("????????????");
    } else {
      list.add("????????????");
    }
    openMoreBottomSheet(
      context: context,
      lists: list,
      onItemClickListener: (index) async {
        if (list[index] == "????????????") {
          openUserNumberPickerBottomSheet(
              context: context,
              start: activityModel.count,
              end: 99,
              onChoseCallBack: (number) async {
                if (number == null || number == activityModel.count) {
                  return;
                }
                List list = await ActivityUtil.init().updateActivityUtil(activityModel, count: number);
                if (list[0]) {
                  activityModel = list[2];
                  setState(() {});
                  ToastShow.show(msg: "???????????????:$number,????????????", context: context);
                } else {
                  ToastShow.show(msg: "???????????????:$number,????????????,${list[1]}", context: context);
                }
              });
        } else if (list[index] == "????????????") {
          AppRouter.navigateActivityChangeAddressPage(context, activityModel, (result) async {
            print(result);
            if (result == null) {
              return;
            }
            PeripheralInformationPoi poi = result as PeripheralInformationPoi;
            if (poi == null) {
              return;
            }
            print("poi???????????????$poi");
            List list = await ActivityUtil.init().updateActivityUtil(activityModel,
                address: poi.name,
                cityCode: poi.citycode,
                longitude: poi.location.split(",")[0],
                latitude: poi.location.split(",")[1]);
            if (list[0]) {
              activityModel = list[2];
              setState(() {});
              ToastShow.show(msg: "??????????????????", context: context);
            } else {
              ToastShow.show(msg: "${list[1]}", context: context);
            }
          });
        } else if (list[index] == "??????????????????") {
          if (activityModel != null && activityModel.members != null && activityModel.members.length > 0) {
            // AppRouter.navigateRemoveUserPage(context, activityModel.id,activityModel.members);
            AppRouter.navigateActivityUserPage(context,
                activityId: activityModel.id, modeList: activityModel.members, type: 1, callback: (dynamic result) {
              _initData();
            });
          } else {
            ToastShow.show(msg: "???????????????????????????", context: context);
          }
        } else if (list[index] == "????????????") {
          showAppDialog(context,
              title: "????????????",
              info: "???????????????????????????????",
              cancel: AppDialogButton("??????", () {
                return true;
              }),
              confirm: AppDialogButton("??????", () {
                Future.delayed(Duration(microseconds: 100), () {
                  _deleteActivity();
                });
                return true;
              }));
        } else if (list[index] == "????????????") {
          showAppDialog(context,
              title: "????????????",
              info: "???????????????24??????????????????????????????????????????????????????????????????????????????????????????????",
              cancel: AppDialogButton("??????", () {
                return true;
              }),
              confirm: AppDialogButton("??????", () {
                Future.delayed(Duration(microseconds: 100), () {
                  _quitActivity();
                });
                return true;
              }));
        }
      },
    );
  }

  //????????????
  _deleteActivity() async {
    Loading.showLoading(context, infoText: "??????????????????");
    List list = await deleteActivity(activityModel.id);

    Loading.hideLoading(context);
    if (list[0]) {
      ToastShow.show(msg: "????????????", context: context);
      EventBus.init().post(registerName: ACTIVITY_LIST_RESET);
      Navigator.of(context).popUntil(ModalRoute.withName(AppRouter.pathIfPage));
    } else {
      ToastShow.show(msg: list[1], context: context);
    }
  }

  //????????????
  _quitActivity() async {
    Loading.showLoading(context, infoText: "??????????????????");
    bool isSuccess = await quitActivity(activityModel.id);

    Loading.hideLoading(context);
    ToastShow.show(msg: isSuccess ? "????????????" : "????????????", context: context);
    if (isSuccess) {
      Navigator.of(context).popUntil(ModalRoute.withName(AppRouter.pathIfPage));
    }
  }

  @override
  void endChangeKeyBoardHeight(bool isOpenKeyboard) {
    if (isOpenKeyboard) {
      if (inputEvaluateFocusNode.hasFocus) {
        Future.delayed(Duration(milliseconds: 100), () {
          RenderBox renderBox = inputEvaluateBoxKey.currentContext.findRenderObject();
          var offset = renderBox.localToGlobal(Offset.zero);

          double value = (offset.dy + 230) - (ScreenUtil.instance.height - Application.keyboardHeightIfPage);

          if (value > 0) {
            scrollController.animateTo(scrollController.position.pixels + value,
                duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
          }
        });
      }
    }
  }

  @override
  void startChangeKeyBoardHeight(bool isOpenKeyboard) {
    // TODO: implement startChangeKeyBoardHeight
  }

  //????????????
  _loginSuccessful() {
    _initData();
  }
}
