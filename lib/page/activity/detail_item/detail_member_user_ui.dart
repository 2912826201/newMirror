import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/activity/activity_api.dart';
import 'package:mirror/api/message_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/dto/conversation_dto.dart';
import 'package:mirror/data/model/activity/activity_model.dart';
import 'package:mirror/data/model/data_response_model.dart';
import 'package:mirror/data/model/message/group_chat_model.dart';
import 'package:mirror/data/model/user_model.dart';
import 'package:mirror/page/message/util/chat_message_profile_util.dart';
import 'package:mirror/page/message/util/chat_page_util.dart';
import 'package:mirror/page/message/util/message_chat_page_manager.dart';
import 'package:mirror/page/profile/profile_detail_page.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/click_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/icon.dart';
import 'package:mirror/widget/user_avatar_image.dart';

class DetailMemberUserUi extends StatefulWidget {
  final ActivityModel activityModel;

  DetailMemberUserUi(this.activityModel);

  @override
  _DetailMemberUserUiState createState() {
    return _DetailMemberUserUiState();
  }
}

class _DetailMemberUserUiState extends State<DetailMemberUserUi> {
  List<UserModel> applyUserList = [];
  DataResponseModel dataResponseModel;

  _DetailMemberUserUiState();

  @override
  void initState() {
    super.initState();
    initData();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ScreenUtil.instance.width,
      child: Column(
        children: [
          _getUserTitle(),
          _getUserList(),
          if (applyUserList.length > 0 && isMaster()) _applyUserListTitle(),
          if (applyUserList.length > 0 && isMaster()) _getApplyUserList(),
        ],
      ),
    );
  }

  Widget _getUserTitle() {
    return Container(
      width: ScreenUtil.instance.width,
      height: 45,
      child: Row(
        children: [
          Text("报名队员", style: AppStyle.whiteRegular16),
          SizedBox(width: 8),
          Container(
            padding: EdgeInsets.only(top: 2),
            child: Text("共${widget.activityModel.count}人", style: AppStyle.whiteRegular14),
          ),
          Spacer(),
          if (widget.activityModel.isJoin)
            GestureDetector(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColor.mainYellow,
                  borderRadius: BorderRadius.circular(100),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
                child: Text("群聊", style: AppStyle.textRegular12),
              ),
              onTap: () {
                _jumpChatPage(widget.activityModel.groupChatId.toString());
              },
            )
        ],
      ),
    );
  }

  Widget _getUserList() {
    List<Widget> array = [];
    for (int index = 0; index < 5; index++) {
      if (index < widget.activityModel.members.length) {
        array.add(_getItem(widget.activityModel.members[index]));
      } else if (index == widget.activityModel.members.length) {
        array.add(_addItem());
      } else {
        array.add(Container(
          width: 47,
          height: 47,
          color: AppColor.transparent,
        ));
      }
    }
    return Container(
      width: ScreenUtil.instance.width,
      height: 100,
      padding: const EdgeInsets.only(top: 12, bottom: 16),
      child: SingleChildScrollView(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: array,
        ),
      ),
    );
  }

  Widget _applyUserListTitle() {
    return Container(
      width: ScreenUtil.instance.width,
      height: 45,
      child: Text("待验证", style: AppStyle.whiteRegular16),
    );
  }

  Widget _getApplyUserList() {
    List<Widget> array = [];
    for (int index = 0; index < 5; index++) {
      if (index < applyUserList.length) {
        array.add(_getItem(applyUserList[index]));
      } else if (index == 4) {
        array.add(GestureDetector(
          onTap: () {
            AppRouter.navigateActivityUserPage(context, widget.activityModel.id, [], type: 3,
                callback: (dynamic result) {
              initData();
            });
          },
          child: Container(
            width: 47,
            color: AppColor.transparent,
            child: AppIcon.getAppIcon(
              AppIcon.arrow_right_18,
              16,
              color: AppColor.textWhite60,
            ),
          ),
        ));
      } else {
        array.add(Container(
          width: 47,
          height: 47,
          color: AppColor.transparent,
        ));
      }
    }
    return Container(
      width: ScreenUtil.instance.width,
      height: 100,
      padding: const EdgeInsets.only(top: 12, bottom: 16),
      child: SingleChildScrollView(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: array,
        ),
      ),
    );
  }

  Widget _getItem(UserModel model) {
    return GestureDetector(
      onTap: () {
        if (widget.activityModel.isJoin) {
          jumpToUserProfilePage(context, model.uid, avatarUrl: model.avatarUri, userName: model.nickName);
        }
      },
      child: Container(
        color: AppColor.transparent,
        width: 47,
        height: 100.0 - 12.0 - 16.0,
        child: Column(
          children: [
            Container(
              height: 47,
              width: 47,
              child: Stack(
                children: [
                  UserAvatarImageUtil.init().getUserImageWidget(model.avatarUri, model.uid.toString(), 47),
                  if (model.sex == 1 || model.sex == 2)
                    Positioned(
                      right: 0,
                      child: AppIconButton(
                        iconSize: 14,
                        svgName: AppIcon.trash_bucket,
                        bgColor: AppColor.mainRed,
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 6),
            Text(
              model.nickName ?? "",
              style: AppStyle.text1Regular12,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _addItem() {
    return widget.activityModel.status != 3 && widget.activityModel.status != 1 && isMaster()
        ? Container(
            width: 47,
            height: 100.0 - 12.0 - 16.0,
            child: UnconstrainedBox(
              alignment: Alignment.topCenter,
              child: Container(
                height: 47,
                width: 47,
                child: AppIconButton(
                  svgName: AppIcon.group_add,
                  iconSize: 24,
                  bgColor: AppColor.textWhite60,
                  isCircle: true,
                  buttonHeight: 47,
                  buttonWidth: 47,
                  iconColor: AppColor.mainBlack,
                  onTap: () {
                    AppRouter.navigateActivityUserPage(context, widget.activityModel.id, [], type: 4,
                        callback: (dynamic result) {
                      initData();
                    });
                  },
                ),
              ),
            ),
          )
        : Container();
  }

  bool isLoadConversationDto = false;

  _jumpChatPage(String groupChatId) async {
    if (ClickUtil.isFastClick()) {
      return;
    }
    if (widget.activityModel.groupChatId == null) {
      ToastShow.show(msg: "群聊资料不正确!1", context: context);
      return;
    }
    if (isLoadConversationDto) {
      ToastShow.show(msg: "正在获取群聊资料中", context: context);
      return;
    }
    isLoadConversationDto = true;

    ToastShow.show(msg: "正在加载中", context: context);
    ConversationDto conversation = await ChatPageUtil.init(context).getConversationDto(groupChatId);
    if (conversation != null) {
      isLoadConversationDto = false;
      jumpChatPageConversationDto(context, conversation);
    } else {
      isLoadConversationDto = false;
      ToastShow.show(msg: "群聊资料不正确!2", context: context);
    }
  }

  initData() async {
    applyUserList.clear();
    dataResponseModel = await applyList(widget.activityModel.id, 4, null);
    if (dataResponseModel != null && dataResponseModel.list != null && dataResponseModel.list.length > 0) {
      dataResponseModel.list.forEach((element) {
        UserModel model = UserModel.fromJson(element);
        if (model.dataState == 2) {
          applyUserList.add(model);
        }
      });
      setState(() {});
    }
  }

  isMaster() {
    return Application.profile != null &&
        Application.profile.uid != null &&
        Application.profile.uid == widget.activityModel.masterId;
  }
}
