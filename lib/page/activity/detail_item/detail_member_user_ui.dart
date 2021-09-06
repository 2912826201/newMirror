import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/activity/activity_api.dart';
import 'package:mirror/api/message_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/dto/conversation_dto.dart';
import 'package:mirror/data/model/data_response_model.dart';
import 'package:mirror/data/model/message/group_chat_model.dart';
import 'package:mirror/data/model/user_model.dart';
import 'package:mirror/page/message/util/chat_message_profile_util.dart';
import 'package:mirror/page/message/util/chat_page_util.dart';
import 'package:mirror/page/message/util/message_chat_page_manager.dart';
import 'package:mirror/util/click_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/icon.dart';
import 'package:mirror/widget/user_avatar_image.dart';

class DetailMemberUserUi extends StatefulWidget {
  final List<UserModel> userList;
  final String groupChatId;
  final int activityId;

  DetailMemberUserUi(this.userList, this.groupChatId, this.activityId);

  @override
  _DetailMemberUserUiState createState() {
    List<UserModel> list = [];
    if (userList.length > 4) {
      list = userList.sublist(0, 4);
    } else {
      list.addAll(userList);
    }
    return _DetailMemberUserUiState(list);
  }
}

class _DetailMemberUserUiState extends State<DetailMemberUserUi> {
  List<UserModel> userList;
  List<UserModel> applyUserList = [];
  DataResponseModel dataResponseModel;

  _DetailMemberUserUiState(this.userList);

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
          if (applyUserList.length > 0) _applyUserListTitle(),
          if (applyUserList.length > 0) _getApplyUserList(),
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
            child: Text("共${userList.length}人", style: AppStyle.whiteRegular14),
          ),
          Spacer(),
          if (isHaveMe())
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
                _jumpChatPage(widget.groupChatId);
              },
            )
        ],
      ),
    );
  }

  Widget _getUserList() {
    return Container(
      width: ScreenUtil.instance.width,
      height: 100,
      padding: const EdgeInsets.only(top: 12, bottom: 16),
      child: ListView.separated(
          itemCount: userList.length + 1,
          scrollDirection: Axis.horizontal,
          separatorBuilder: (BuildContext context, int index) => VerticalDivider(
                width: 6.0,
                color: AppColor.mainBlack,
              ),
          itemBuilder: (context, index) {
            if (index != userList.length) {
              return _getItem(userList[index]);
            } else {
              return _addItem();
            }
          }),
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
    double itemWidth = (ScreenUtil.instance.width - 32 - 25) / 5;
    return Container(
      width: ScreenUtil.instance.width,
      height: 100,
      padding: const EdgeInsets.only(top: 12, bottom: 16),
      child: ListView.separated(
          itemCount: 5,
          scrollDirection: Axis.horizontal,
          separatorBuilder: (BuildContext context, int index) => VerticalDivider(
                width: 6.0,
                color: AppColor.mainBlack,
              ),
          itemBuilder: (context, index) {
            if (index == 4) {
              return Transform.translate(
                offset: Offset(36, 0),
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    color: AppColor.transparent,
                    child: AppIcon.getAppIcon(
                      AppIcon.arrow_right_18,
                      16,
                      color: AppColor.textWhite60,
                    ),
                  ),
                ),
              );
            } else if (index < applyUserList.length) {
              return _getItem(applyUserList[index]);
            } else {
              return Container(
                width: itemWidth,
              );
            }
          }),
    );
  }

  Widget _getItem(UserModel model) {
    double itemWidth = (ScreenUtil.instance.width - 32 - 25) / 5;
    return Container(
      width: itemWidth,
      height: 100.0 - 12.0 - 16.0,
      child: Column(
        children: [
          UserAvatarImageUtil.init().getUserImageWidget(model.avatarUri, model.uid.toString(), 45),
          SizedBox(height: 6),
          Text(
            model.nickName ?? "",
            style: AppStyle.text1Regular12,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _addItem() {
    double itemWidth = (ScreenUtil.instance.width - 32 - 25) / 5;
    return isHaveMe()
        ? Container(
            width: itemWidth,
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
                    print("点击了添加成员");
                  },
                ),
              ),
            ),
          )
        : Container();
  }

  bool isHaveMe() {
    if (Application.profile == null || Application.profile.uid == null) {
      return false;
    }
    for (var model in widget.userList) {
      if (model.uid == Application.profile.uid) {
        return true;
      }
    }
    return false;
  }

  bool isLoadConversationDto = false;

  _jumpChatPage(String groupChatId) async {
    if (ClickUtil.isFastClick()) {
      return;
    }
    if (widget.groupChatId == null) {
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
    dataResponseModel = await applyList(widget.activityId, 4, null);
    if (dataResponseModel != null && dataResponseModel.list != null && dataResponseModel.list.length > 0) {
      dataResponseModel.list.forEach((element) {
        applyUserList.add(UserModel.fromJson(element));
      });
      setState(() {});
    }
  }
}
