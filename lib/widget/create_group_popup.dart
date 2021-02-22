import 'package:azlistview/azlistview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:mirror/api/message_api.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/database/conversation_db_helper.dart';
import 'package:mirror/data/dto/conversation_dto.dart';
import 'package:mirror/data/model/message/group_chat_model.dart';
import 'package:mirror/data/model/profile/buddy_list_model.dart';
import 'package:mirror/data/notifier/conversation_notifier.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:provider/provider.dart';

/// create_group_popup
/// Created by yangjiayi on 2021/1/8.

showCreateGroupPopup(BuildContext context) {
  showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      //可不受最大高度限制
      elevation: 0,
      backgroundColor: AppColor.transparent,
      builder: (context) {
        return _CreateGroupPopup();
      });
}

class _CreateGroupPopup extends StatefulWidget {
  @override
  _CreateGroupPopupState createState() => _CreateGroupPopupState();
}

class _CreateGroupPopupState extends State<_CreateGroupPopup> {
  final TextEditingController controller = TextEditingController();
  final FocusNode focusNode = FocusNode();
  List<BuddyModel> _friendList = [];

  @override
  void initState() {
    super.initState();
    _getFriendList();
  }

  _getFriendList({int lastTime}) async {
    BuddyListModel listModel;
    if (lastTime == null) {
      listModel = await getFollowBothList(100);
    } else {
      listModel = await getFollowBothList(100, lastTime: lastTime);
    }
    if (listModel != null) {
      _friendList.addAll(listModel.list);
      if (listModel.hasNext == 1) {
        _getFriendList(lastTime: listModel.lastTime);
      } else {
        _sortFriendList();
        if (mounted) {
          setState(() {});
        }
      }
    }
  }

  _sortFriendList(){
    _friendList.forEach((friend) {
      String pinyin = PinyinHelper.getPinyinE(friend.nickName);
      String tag = pinyin.substring(0, 1).toUpperCase();
      if (RegExp('[A-Z]').hasMatch(tag)) {
        friend.tagIndex = tag;
      } else {
        friend.tagIndex = '#';
      }
    });
    SuspensionUtil.sortListBySuspensionTag(_friendList);
    SuspensionUtil.setShowSuspensionStatus(_friendList);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
        color: AppColor.white,
      ),
      height: ScreenUtil.instance.height * 0.75,
      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Container(
          width: 32,
          height: 4,
          color: AppColor.bgWhite,
          margin: const EdgeInsets.only(top: 16, bottom: 24),
        ),
        Container(
          height: 32,
          color: AppColor.bgWhite.withOpacity(0.65),
          width: ScreenUtil.instance.screenWidthDp - 32,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 12,
              ),
              Image.asset(
                "images/resource/2.0x/search_icon_gray@2x.png",
                width: 21,
                height: 21,
              ),
              Expanded(
                child: Container(
                  height: 32,
                  alignment: Alignment.center,
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                        isCollapsed: true,
                        contentPadding: EdgeInsets.only(top: 0, bottom: 0, left: 6),
                        hintText: '搜索用户',
                        hintStyle: AppStyle.textSecondaryRegular16,
                        border: InputBorder.none),
                    inputFormatters: [
                      WhitelistingTextInputFormatter(RegExp("[a-zA-Z]|[\u4e00-\u9fa5]|[0-9]")), //只能输入汉字或者字母或数字
                      LengthLimitingTextInputFormatter(30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Container(
          height: 48,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 12,
              ),
              Icon(
                Icons.group,
                size: 24,
                color: AppColor.textPrimary1,
              ),
              SizedBox(
                width: 4,
              ),
              Text(
                "已加入的群聊",
                style: AppStyle.textRegular16,
              ),
              Spacer(),
              Icon(
                Icons.chevron_right,
                size: 18,
                color: AppColor.textHint,
              ),
            ],
          ),
        ),
        Expanded(child: Container(
          child: AzListView(
            data: _friendList,
            itemCount: _friendList.length,
            padding: EdgeInsets.zero,
            itemBuilder: _buildItem,
            susItemBuilder: _buildHeader,
            indexBarData: [],
          ),
        )),
        GestureDetector(
          onTap: _createGroupOrGoToChat,
          child: Container(
            margin: const EdgeInsets.fromLTRB(0, 6, 0, 6),
            alignment: Alignment.center,
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(3)),
              color: AppColor.textPrimary1,
            ),
            child: Text(
              "发起群聊",
              style: TextStyle(color: AppColor.white, fontSize: 16),
            ),
          ),
        ),
        SizedBox(
          height: ScreenUtil.instance.bottomBarHeight,
        ),
      ]),
    );
  }

  _createGroupOrGoToChat() async {
    //临时测试用的 创建群聊方法
    List<String> testGroupMemberList = ["1018240", "1005740", "1007890", "1004317", "1009100"];

    GroupChatModel model = await createGroupChat(testGroupMemberList);

    if (model == null) {
      return;
    }

    ConversationDto cdto = ConversationDto.fromGroupChat(model);

    bool result = await ConversationDBHelper().insertConversation(cdto);
    if (result) {
      if (cdto.isTop == 0) {
        context.read<ConversationNotifier>().insertCommonList([cdto]);
      } else {
        context.read<ConversationNotifier>().insertTopList([cdto]);
      }
    }

    Navigator.pop(context);
  }

  Widget _buildItem(BuildContext context, int index) {
    return Text(_friendList[index].nickName, style: AppStyle.textRegular16,);
  }

  Widget _buildHeader(BuildContext context, int index) {
    return Text(_friendList[index].getSuspensionTag(), style: AppStyle.redRegular16,);
  }
}
