import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mirror/api/activity/activity_api.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/activity/activity_model.dart';
import 'package:mirror/data/model/base_response_model.dart';
import 'package:mirror/data/model/data_response_model.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/data/model/profile/buddy_list_model.dart';
import 'package:mirror/data/model/user_model.dart';
import 'package:mirror/data/notifier/user_interactive_notifier.dart';
import 'package:mirror/page/message/util/message_chat_page_manager.dart';
import 'package:mirror/page/profile/profile_detail_page.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/string_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/custom_button.dart';
import 'package:mirror/widget/dialog.dart';
import 'package:mirror/widget/icon.dart';
import 'package:mirror/widget/input_formatter/expression_team_delete_formatter.dart';
import 'package:mirror/widget/input_method_rules/pin_yin_text_edit_controller.dart';
import 'package:mirror/widget/loading.dart';
import 'package:mirror/widget/smart_refressher_head_footer.dart';
import 'package:mirror/widget/user_avatar_image.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:provider/provider.dart';

///活动成员界面type
class ActivityUserPage extends StatefulWidget {
  final int activityId;
  final int type; //0-查看活动成员 1 -移除活动成员  2-举报成员 3-待验证用户-某一个活动 4-邀请好友进入活动 5-待验证用户-用户的全部活动
  final List<UserModel> userList;

  ActivityUserPage({Key key, this.activityId, this.type = 0, @required this.userList}) : super(key: key);

  @override
  _ActivityUserPageState createState() => _ActivityUserPageState(userList);
}

class _ActivityUserPageState extends State<ActivityUserPage> {
  List<UserModel> userList;

  _ActivityUserPageState(this.userList);

  final PinYinTextEditController _inputController = PinYinTextEditController();
  final PinYinTextEditController _reasonController = PinYinTextEditController();
  final FocusNode _focusNode = FocusNode();

  ActivityModel activityModel;

  //选中的用户
  List<int> selectUserList = [];

  //待验证用户
  List<UserModel> verifyUserList = [];
  int verifyUserLastId;

  //互关好友列表
  List<UserModel> buddyModelList = [];
  int buddyModelLastTime;

  double bottomOpacity = 0.4;

  RefreshController _refreshController = RefreshController(initialRefresh: false);

  LoadingStatus loadingStatus;

  @override
  void initState() {
    super.initState();
    loadingStatus = LoadingStatus.STATUS_LOADING;
    initData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleString: getTitleString(),
      ),
      body: Container(
        color: AppColor.mainBlack,
        padding: EdgeInsets.only(bottom: ScreenUtil.instance.bottomBarHeight),
        child: Column(
          children: [
            Expanded(
              child: _getSmartRefresher(),
            ),
            if (widget.type != 0 && widget.type != 3) _getBottomBtn(),
          ],
        ),
      ),
    );
  }

  Widget _getSmartRefresher() {
    if (widget.type == 0 && userList.length < 1) {
      return getCommentNoData();
    }
    if (widget.type == 3 && verifyUserList.length < 1) {
      return getCommentNoData();
    }
    if (widget.type == 4 && buddyModelList.length < 1) {
      return getCommentNoData();
    }
    return SmartRefresher(
        enablePullDown: true,
        enablePullUp: widget.type == 3 || widget.type == 4,
        header: SmartRefresherHeadFooter.init().getHeader(),
        footer: SmartRefresherHeadFooter.init().getFooter(isShowNoMore: false),
        controller: _refreshController,
        onRefresh: () {
          initData();
        },
        onLoading: () {
          loadData();
        },
        child: getList());
  }

  Widget getList() {
    return ListView.builder(
      itemCount: getListLen(),
      padding: EdgeInsets.only(top: 13),
      itemBuilder: (context, index) {
        if (widget.type != 0 && widget.type != 3) {
          if (index == 0) {
            return _getEdit();
          }
          UserModel model = getUserModel(index - 1);
          if (_inputController.text == null ||
              _inputController.text.length < 1 ||
              model.nickName.contains(_inputController.text)) {
            return item(model, index - 1, () {
              selectUserOnClickListener(index - 1);
            });
          } else {
            return Container();
          }
        } else {
          UserModel model = getUserModel(index);
          return item(model, index, () {
            _jumpToUserProfilePage(model);
          });
        }
      },
    );
  }

  UserModel getUserModel(int index) {
    if (widget.type == 4) {
      return buddyModelList[index];
    } else if (widget.type == 3) {
      return verifyUserList[index];
    } else {
      return userList[index];
    }
  }

  int getListLen() {
    if (widget.type == 0) {
      return userList.length;
    } else if (widget.type == 3) {
      return verifyUserList.length;
    } else if (widget.type == 4) {
      return buddyModelList.length;
    } else {
      return userList.length + 1;
    }
  }

  Widget item(UserModel model, int index, Function() onTap) {
    if (widget.type == 1 && model.uid == Application.profile.uid) {
      return Opacity(
        opacity: 0.3,
        child: _getItem(model, index),
      );
    } else {
      return Material(
          color: AppColor.transparent,
          child: new InkWell(
            child: _getItem(model, index),
            splashColor: AppColor.layoutBgGrey,
            onTap: onTap,
          ));
    }
  }

  Widget _getItem(UserModel model, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      margin: const EdgeInsets.symmetric(vertical: 5),
      color: AppColor.transparent,
      constraints: BoxConstraints(
        minHeight: 48.0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: UserAvatarImageUtil.init()
                .getUserImageWidget(model.avatarUri, model.uid.toString(), widget.type != 0 ? 32 : 38),
            margin: EdgeInsets.only(top: 4),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Row(
              children: [
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      model.nickName ?? "",
                      style: AppStyle.whiteRegular16,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    getSubtitle(model),
                  ],
                )),
                SizedBox(width: 4),
                if (widget.type != 0 && widget.type != 3) getSingleChoiceUi(index),
                if (widget.type == 0 || widget.type == 3) getItemUserBtnUi(model, index),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget getSubtitle(UserModel model) {
    if (widget.type == 0 && model.description != null) {
      return Text(
        model.description ?? "",
        style: AppStyle.text1Regular12,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    } else if (widget.type == 3 && model.message != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "对方留言: " + "${StringUtil.breakWord(model.message)}",
            style: AppStyle.text1Regular12,
          ),
          Text(
            "活动来源: " + "${StringUtil.breakWord(model.title)}",
            style: AppStyle.text1Regular12,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    } else {
      return Container();
    }
  }

  //按钮
  Widget getItemUserBtnUi(UserModel model, int index) {
    if (widget.type == 0) {
      return FollowButton(
        id: model.uid,
        relation: model.relation,
        buttonType: FollowButtonType.COACH,
        resetDataListener: () {},
        onClickAttention: (int relation) {
          setState(() {
            model.relation = relation;
          });
        },
      );
    } else if (widget.type == 3 && model.dataState == 2) {
      return CustomYellowButton("同意", CustomYellowButton.buttonStateNormal, () {
        _auditApply(model);
      });
    } else {
      return Container();
    }
  }

  //单选按钮
  Widget getSingleChoiceUi(int index) {
    return Container(
      margin: const EdgeInsets.only(right: 14.5),
      width: 24,
      height: 24,
      child: AppIcon.getAppIcon(
          selectUserList.contains(index) ? AppIcon.selection_selected : AppIcon.selection_not_selected, 24),
    );
  }

  Widget _getBottomBtn() {
    return GestureDetector(
      child: Opacity(
        opacity: bottomOpacity,
        child: Container(
          decoration: BoxDecoration(
            color: AppColor.mainYellow,
            borderRadius: BorderRadius.circular(4),
          ),
          height: 44,
          width: ScreenUtil.instance.width - 32,
          margin: EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          child: Text("确定", style: AppStyle.textRegular16, textAlign: TextAlign.center),
        ),
      ),
      onVerticalDragDown: (details) {
        setState(() {
          bottomOpacity = 0.6;
        });
      },
      onVerticalDragEnd: (_) {
        setState(() {
          bottomOpacity = 1;
        });
      },
      onTap: () {
        if (widget.type == 1) {
          _showDialog();
        } else if (widget.type == 4) {
          _inviteActivity();
        }
      },
    );
  }

  //评论没有数据
  Widget getCommentNoData() {
    if (loadingStatus == LoadingStatus.STATUS_LOADING) {
      return Container(
        width: ScreenUtil.instance.width,
        height: ScreenUtil.instance.height,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Container(
      width: ScreenUtil.instance.width,
      height: ScreenUtil.instance.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            "assets/png/default_no_data.png",
            fit: BoxFit.cover,
            width: 224,
            height: 224,
          ),
          SizedBox(
            height: 16,
          ),
          Text(
            "暂时没有获取到${widget.type == 0 ? "群成员" : (widget.type == 3 || widget.type == 5 ? "待验证成员" : "")}信息",
            style: AppStyle.text1Regular14,
          )
        ],
      ),
    );
  }

  Widget _getEdit() {
    return Container(
      height: 32,
      margin: const EdgeInsets.only(top: 20, left: 16, right: 16),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColor.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: TextField(
        style: AppStyle.whiteRegular16,
        controller: _inputController,
        focusNode: _focusNode,
        textInputAction: TextInputAction.search,
        onChanged: (value) {
          setState(() {});
        },
        decoration: InputDecoration(
            isCollapsed: true,
            contentPadding: EdgeInsets.only(top: 0, bottom: 0, left: 6),
            hintText: '搜索用户',
            hintStyle: AppStyle.text1Regular16,
            border: InputBorder.none),
        inputFormatters: [
          // WhitelistingTextInputFormatter(RegExp("[a-zA-Z]|[\u4e00-\u9fa5]|[0-9]")), //只能输入汉字或者字母或数字
          LengthLimitingTextInputFormatter(16),
        ],
      ),
    );
  }

  //选择item
  selectUserOnClickListener(int index) {
    if (selectUserList.contains(index)) {
      selectUserList.remove(index);
      bottomOpacity = 0.4;
      setState(() {});
    } else {
      selectUserList.add(index);
      bottomOpacity = 1;
      setState(() {});
    }
  }

  //移除的说明原因的dialog
  Widget _reasonEditWidget() {
    return Container(
      height: 104,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      decoration:
          BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(4)), color: AppColor.white.withOpacity(0.1)),
      child: TextField(
        controller: _reasonController,
        cursorColor: AppColor.white,
        style: AppStyle.whiteRegular12,
        maxLines: null,
        maxLength: 50,
        decoration: InputDecoration(
          isDense: true,
          counterText: '',
          hintText: "请输入理由...",
          hintStyle: AppStyle.text2Regular12,
          border: InputBorder.none,
        ),
        inputFormatters: [ExpressionTeamDeleteFormatter(maxLength: 50)],
      ),
    );
  }


  //移除的说明原因的dialog
  _showDialog() {
    showAppDialog(context,
        title: "请说明将他踢出小队的原因",
        customizeWidget: _reasonEditWidget(),
        cancel: AppDialogButton("取消", () {
          _reasonController.text = "";
          return true;
        }),
        confirm: AppDialogButton("确定", () {
          Future.delayed(Duration(microseconds: 100), () {
            _removeMember();
          });
          return true;
        }));
  }

  _removeMember() async {
    ActivityModel model = await getActivityDetailApi(widget.activityId);
    if (model.times == null && model.times < 3 * 60 * 60 * 1000) {
      ToastShow.show(msg: "移除失败：只能在活动开始三个小时前移除成员", context: context);
      return;
    }

    Loading.showLoading(context, infoText: "正在移除活动成员");

    String uids = "";
    for (int i = 0; i < selectUserList.length; i++) {
      if (i == selectUserList.length - 1) {
        uids += userList[selectUserList[i]].uid.toString();
      } else {
        uids += userList[selectUserList[i]].uid.toString() + ",";
      }
    }

    bool isSuccess = await removeMember(widget.activityId, uids, _reasonController.text);
    _reasonController.text = "";

    ToastShow.show(msg: isSuccess ? "移除成功" : "移除失败", context: context);

    selectUserList.clear();
    Loading.hideLoading(context);

    setState(() {});
  }

  String getTitleString() {
    if (widget.type == 1) {
      return "踢出用户";
    } else if (widget.type == 2) {
      return "举报成员";
    } else if (widget.type == 3) {
      return "待验证用户";
    } else {
      return "查看活动成员";
    }
  }

  //跳转用户界面
  _jumpToUserProfilePage(UserModel model) {
    jumpToUserProfilePage(context, model.uid, avatarUrl: model.avatarUri, userName: model.nickName,
        callback: (dynamic result) {
      bool result = context.read<UserInteractiveNotifier>().value.profileUiChangeModel[model.uid].isFollow;
      if (null != result && result is bool) {
        model.relation = result ? 0 : 1;
        if (mounted) {
          setState(() {});
        }
      }
    });
  }

  //同意申请

  _auditApply(UserModel model) async {
    bool isAudit = await auditApply(model.id);
    if (isAudit) {
      model.dataState = 1;
    } else {
      model.dataState = 2;
    }
    setState(() {});
  }


  //邀请用户参加活动
  _inviteActivity() async {
    Loading.showLoading(context, infoText: "正在发送邀请中");

    String uids = "";
    for (int i = 0; i < selectUserList.length; i++) {
      if (i == selectUserList.length - 1) {
        uids += buddyModelList[selectUserList[i]].uid.toString();
      } else {
        uids += buddyModelList[selectUserList[i]].uid.toString() + ",";
      }
    }
    List<String> dataList = await inviteActivity(widget.activityId, uids);

    dataList.forEach((element) {
      for (var index in selectUserList) {
        if (buddyModelList[index].uid.toString() == element) {
          selectUserList.remove(index);
          break;
        }
      }
      postMessageManagerActivityInvite(element, activityModel, true);
    });

    if (selectUserList.length > 0) {
      String names = "";
      for (int i = 0; i < selectUserList.length; i++) {
        if (i == selectUserList.length - 1) {
          names += buddyModelList[selectUserList[i]].nickName;
        } else {
          names += buddyModelList[selectUserList[i]].nickName + ",";
        }
      }
      ToastShow.show(msg: "对 $names 邀请失败", context: context);
    }
    Loading.hideLoading(context);
    Navigator.of(context).pop();
  }

  initData() async {
    if (widget.type != 5) {
      activityModel = await getActivityDetailApi(widget.activityId);
      if (activityModel == null) {
        _refreshController.refreshCompleted();
        loadingStatus = LoadingStatus.STATUS_COMPLETED;
        setState(() {});
      }
    }
    if (widget.type == 0) {
      //查看活动成员
      userList.clear();
      userList.addAll(await getActivityMemberList(widget.activityId, 100, null));
      _refreshController.refreshCompleted();
      loadingStatus = LoadingStatus.STATUS_COMPLETED;
      setState(() {});
    } else if (widget.type == 3 || widget.type == 5) {
      //待验证用户
      verifyUserList.clear();
      DataResponseModel dataResponseModel = await getActivityApplyList(widget.activityId, 20, null);
      if (dataResponseModel != null && dataResponseModel.list != null && dataResponseModel.list.length > 0) {
        dataResponseModel.list.forEach((element) {
          verifyUserList.add(UserModel.fromJson(element));
        });
        verifyUserLastId = dataResponseModel.lastId;
      }
      _refreshController.refreshCompleted();
      loadingStatus = LoadingStatus.STATUS_COMPLETED;
      setState(() {});
    } else if (widget.type == 4) {
      //邀请好友进入活动
      userList.clear();
      userList.addAll(await getActivityMemberList(widget.activityId, 100, null));
      buddyModelList.clear();
      getBuddyModelListData();
    }
  }

  bool isHaveUser(int uid) {
    for (var model in userList) {
      if (model.uid == uid) {
        return true;
      }
    }
    return false;
  }

  loadData() async {
    if (widget.type != 3 || widget.type != 4) {
      _refreshController.loadComplete();
      return;
    }
    if (widget.type == 3 || widget.type == 5) {
      DataResponseModel dataResponseModel = await getActivityApplyList(widget.activityId, 20, verifyUserLastId);
      if (dataResponseModel != null && dataResponseModel.list != null && dataResponseModel.list.length > 0) {
        dataResponseModel.list.forEach((element) {
          verifyUserList.add(UserModel.fromJson(element));
        });
        verifyUserLastId = dataResponseModel.lastId;
      }
      _refreshController.loadComplete();
      setState(() {});
    } else if (widget.type == 4) {
      getBuddyModelListData();
    }
  }

  getBuddyModelListData() async {
    DataResponseModel buddyListModel = await getFollowBothListUserModel(size: 100, lastTime: buddyModelLastTime);
    if (buddyListModel != null && buddyListModel.list != null && buddyListModel.list.length > 0) {
      buddyListModel.list.forEach((element) {
        UserModel model = UserModel.fromJson(element);
        if (!isHaveUser(model.uid)) {
          buddyModelList.add(UserModel.fromJson(element));
        }
      });
      buddyModelLastTime = buddyListModel.lastTime;
      if (buddyListModel.hasNext == 1) {
        getBuddyModelListData();
      } else {
        if (_refreshController.isRefresh) {
          _refreshController.refreshCompleted();
        }
        if (_refreshController.isLoading) {
          _refreshController.loadComplete();
        }
        loadingStatus = LoadingStatus.STATUS_COMPLETED;
        setState(() {});
      }
    } else {
      loadingStatus = LoadingStatus.STATUS_COMPLETED;
      setState(() {});
    }
  }
}
