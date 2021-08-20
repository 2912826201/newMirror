import 'package:azlistview/azlistview.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
import 'package:mirror/data/model/user_model.dart';
import 'package:mirror/data/notifier/conversation_notifier.dart';
import '../page/message/util/message_chat_page_manager.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/icon.dart';
import 'package:provider/provider.dart';

import 'Input_method_rules/pin_yin_text_edit_controller.dart';

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
  final int _maxSelectionCount = 20;
  final PinYinTextEditController _inputController = PinYinTextEditController();
  final FocusNode _focusNode = FocusNode();
  List<BuddyModel> _originalFriendList = [];
  List<BuddyModel> _friendList = [];
  List<int> _selectedUidList = [];
  bool _isRequesting = false;
  List<GroupChatModel> _groupList = [];

  PageController _pageController = PageController();

  String _lastSearchText = "";

  @override
  void initState() {
    super.initState();
    _getFriendList();
    _inputController.addListener(() {
      if (_lastSearchText != _inputController.completeText) {
        _lastSearchText = _inputController.completeText;
        _filterFriendList(_lastSearchText);
        setState(() {});
      }
    });
  }

  _getFriendList({int lastTime}) async {
    BuddyListModel listModel;
    if (lastTime == null) {
      listModel = await getFollowBothList(size: 100);
    } else {
      listModel = await getFollowBothList(size: 100, lastTime: lastTime);
    }
    if (listModel != null) {
      _originalFriendList.addAll(listModel.list);
      if (listModel.hasNext == 1) {
        _getFriendList(lastTime: listModel.lastTime);
      } else {
        _addFriendTagAndSort();
        _filterFriendList(_lastSearchText);
        if (mounted) {
          setState(() {});
        }
      }
    }
  }

  _addFriendTagAndSort() {
    _originalFriendList.forEach((friend) {
      String pinyin = PinyinHelper.getPinyinE(friend.nickName);
      String tag = pinyin.substring(0, 1).toUpperCase();
      if (RegExp('[A-Z]').hasMatch(tag)) {
        friend.tagIndex = tag;
      } else {
        friend.tagIndex = '#';
      }
    });
    SuspensionUtil.sortListBySuspensionTag(_originalFriendList);
  }

  _filterFriendList(String text) {
    _friendList.clear();
    if (text.isEmpty) {
      _friendList.addAll(_originalFriendList);
    } else {
      for (BuddyModel friend in _originalFriendList) {
        if (friend.nickName.contains(text)) {
          _friendList.add(friend);
        }
      }
    }

    SuspensionUtil.setShowSuspensionStatus(_friendList);
  }

  _getGroupList() {
    getGroupChatList().then((groupChatListMap) {
      if (groupChatListMap != null && groupChatListMap["list"] != null) {
        groupChatListMap["list"].forEach((v) {
          _groupList.add(GroupChatModel.fromJson(v));
        });
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
        color: AppColor.layoutBgGrey,
      ),
      height: ScreenUtil.instance.height * 0.75,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 4,
            color: AppColor.white,
            margin: const EdgeInsets.only(top: 16, bottom: 24),
          ),
          Expanded(
            child: PageView(
              physics: NeverScrollableScrollPhysics(),
              controller: _pageController,
              children: [
                _buildFriendListPage(),
                _buildGroupListPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _createGroupOrGoToChat() async {
    if (_selectedUidList.length == 1) {
      //只选中1人 私聊
      //FIXME 按理说BuddyModel就是UserModel
      for (BuddyModel friend in _friendList) {
        if (friend.uid == _selectedUidList.first) {
          UserModel user = UserModel();
          user.uid = friend.uid;
          user.avatarUri = friend.avatarUri;
          user.nickName = friend.nickName;

          Navigator.pop(context);
          jumpChatPageUser(context, user);
          break;
        }
      }
    } else if (_selectedUidList.length > 1) {
      //选中大于等于2人 群聊
      if (_isRequesting) {
        return;
      }
      _isRequesting = true;
      bool isSuccess = false;
      try {
        GroupChatModel model = await createGroupChat(_selectedUidList);

        if (model != null) {
          ConversationDto cdto = ConversationDto.fromGroupChat(model);
          cdto.content=getContent();
          bool result = await ConversationDBHelper().insertConversation(cdto);
          if (result) {
            if (cdto.isTop == 0) {
              context.read<ConversationNotifier>().insertCommonList([cdto]);
            } else {
              context.read<ConversationNotifier>().insertTopList([cdto]);
            }
          }
          isSuccess = true;
          jumpChatPageConversationDto(context, cdto);
        }
      } catch (e) {
        print(e);
      } finally {
        _isRequesting = false;
        if (isSuccess) {
          Navigator.pop(context);
        }
      }
    }
  }

  String getContent(){
    String content="你邀请了";
    for(BuddyModel model in _friendList){
      if(_selectedUidList.contains(model.uid)){
        content+=model.nickName+"、";
      }
    }
    content=content.substring(0,content.length-1);
    content+="加入群聊";
    return content;
  }

  Widget _buildFriendItem(BuildContext context, int index) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      height: 44,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipOval(
            child: CachedNetworkImage(
              height: 32,
              width: 32,
              imageUrl: _friendList[index].avatarUri,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: AppColor.imageBgGrey,
              ),
              errorWidget: (context, url, error) => Container(
                color: AppColor.imageBgGrey,
              ),
            ),
          ),
          SizedBox(
            width: 12,
          ),
          Expanded(
            child: Text(
              _friendList[index].nickName,
              style: AppStyle.whiteRegular16,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: 20,
          ),
          AppIconButton(
            iconSize: 24,
            onTap: () {
              if (_selectedUidList.contains(_friendList[index].uid)) {
                _selectedUidList.remove(_friendList[index].uid);
                setState(() {});
              } else {
                if (_selectedUidList.length >= _maxSelectionCount) {
                  ToastShow.show(msg: "一次性最多选择20名好友", context: context);
                } else {
                  _selectedUidList.add(_friendList[index].uid);
                  setState(() {});
                }
              }
            },
            svgName: _selectedUidList.contains(_friendList[index].uid)
                ? AppIcon.selection_selected
                : AppIcon.selection_not_selected,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int index) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 0, 16, 0),
      alignment: Alignment.centerLeft,
      width: ScreenUtil.instance.screenWidth,
      color: AppColor.transparent,
      height: 28,
      child: Text(
        _friendList[index].getSuspensionTag(),
        style: AppStyle.whiteRegular14,
      ),
    );
  }

  Widget _buildFriendListPage() {
    return Column(
      children: [
        Container(
          height: 32,
          color: AppColor.white.withOpacity(0.1),
          width: ScreenUtil.instance.screenWidthDp - 32,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 9,
              ),
              AppIcon.getAppIcon(AppIcon.input_search, 24, color: AppColor.white),
              Expanded(
                child: Container(
                  height: 32,
                  alignment: Alignment.center,
                  child: TextField(
                    controller: _inputController,
                    focusNode: _focusNode,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                        isCollapsed: true,
                        contentPadding: EdgeInsets.only(top: 0, bottom: 0, left: 6),
                        hintText: '搜索用户',
                        hintStyle: AppStyle.whiteRegular16,
                        border: InputBorder.none),
                    inputFormatters: [
                      // WhitelistingTextInputFormatter(RegExp("[a-zA-Z]|[\u4e00-\u9fa5]|[0-9]")), //只能输入汉字或者字母或数字
                      LengthLimitingTextInputFormatter(20),
                    ],
                  ),
                ),
              ),
              _inputController.text.isEmpty
                  ? Container(
                      width: 42,
                    )
                  : AppIconButton(
                      svgName: AppIcon.clear_circle_grey,
                      iconSize: 16,
                      buttonWidth: 40,
                      buttonHeight: 32,
                      onTap: () {
                        _inputController.text = "";
                      },
                    ),
            ],
          ),
        ),
        SizedBox(
          height: 10,
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (_groupList.isEmpty) {
              _getGroupList();
            }
            _pageController.animateToPage(1, duration: Duration(milliseconds: 250), curve: Curves.easeInOut);
          },
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            height: 48,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 12,
                ),
                AppIcon.getAppIcon(
                  AppIcon.group_chat_24,
                  24,
                  color: AppColor.white,
                ),
                SizedBox(
                  width: 4,
                ),
                Text(
                  "已加入的群聊",
                  style: AppStyle.whiteRegular16,
                ),
                Spacer(),
                AppIcon.getAppIcon(
                  AppIcon.arrow_right_18,
                  18,
                  color: AppColor.textWhite40,
                ),
              ],
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          height: 0.5,
          color: AppColor.dividerWhite8,
        ),
        Expanded(
          child: Container(
            child: getNotificationListener(),
          ),
        ),
        GestureDetector(
          onTap: _createGroupOrGoToChat,
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 6, 16, 6),
            alignment: Alignment.center,
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(3)),
              color: _selectedUidList.length > 0 ? AppColor.mainYellow : AppColor.mainYellow.withOpacity(0.6),
            ),
            child: Text(
              _selectedUidList.length > 1 ? "发起群聊(${_selectedUidList.length})" : "发起聊天",
              style: TextStyle(color: AppColor.mainBlack, fontSize: 16),
            ),
          ),
        ),
        SizedBox(
          height: ScreenUtil.instance.bottomBarHeight,
        ),
      ],
    );
  }

  Widget getNotificationListener() {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        // 注册通知回调
        if (notification is ScrollStartNotification) {
          // 滚动开始
          FocusScope.of(context).requestFocus(FocusNode());
        } else if (notification is ScrollUpdateNotification) {
          // 滚动位置更新
        } else if (notification is ScrollEndNotification) {
          // 滚动结束
        }
        return false;
      },
      child: AzListView(
        data: _friendList,
        itemCount: _friendList.length,
        padding: EdgeInsets.zero,
        itemBuilder: _buildFriendItem,
        susItemBuilder: _buildHeader,
        indexBarData: [],
      ),
    );
  }

  Widget _buildGroupListPage() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(right: 16),
          height: 48,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AppIconButton(
                iconSize: 18,
                svgName: AppIcon.arrow_left_18,
                iconColor: AppColor.white,
                buttonHeight: 48,
                buttonWidth: 50,
                onTap: () {
                  _pageController.animateToPage(0, duration: Duration(milliseconds: 250), curve: Curves.easeInOut);
                },
              ),
              Spacer(),
              Text(
                "已加入的群聊",
                style: AppStyle.whiteRegular16,
              )
            ],
          ),
        ),
        // Container(
        //   margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        //   height: 0.5,
        //   color: AppColor.dividerWhite24,
        // ),
        Expanded(
          child: ListView.builder(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            itemCount: _groupList.length,
            itemBuilder: _buildGroupItem,
          ),
        )
      ],
    );
  }

  Widget _buildGroupItem(BuildContext context, int index) {
    List<String> avatarList = _groupList[index].coverUrl.split(",");
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      height: 48,
      margin: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Navigator.pop(context);
          jumpGroupPage(context, _groupList[index].modifiedName ?? _groupList[index].name, _groupList[index].id);
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 32,
              width: 32,
              child: Stack(
                children: [
                  avatarList.length == 1
                      ? ClipOval(
                          child: CachedNetworkImage(
                            height: 32,
                            width: 32,
                            imageUrl: avatarList.first,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: AppColor.imageBgGrey,
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: AppColor.imageBgGrey,
                            ),
                          ),
                        )
                      : avatarList.length > 1
                          ? Positioned(
                              top: 0,
                              right: 0,
                              child: ClipOval(
                                child: CachedNetworkImage(
                                  height: 20,
                                  width: 20,
                                  imageUrl: avatarList.first,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: AppColor.imageBgGrey,
                                  ),
                                  errorWidget: (context, url, error) => Container(
                                    color: AppColor.imageBgGrey,
                                  ),
                                ),
                              ))
                          : Container(),
                  avatarList.length > 1
                      ? Positioned(
                          bottom: 0,
                          child: Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle, border: Border.all(width: 3, color: AppColor.layoutBgGrey)),
                            child: ClipOval(
                              child: CachedNetworkImage(
                                height: 20,
                                width: 20,
                                imageUrl: avatarList[1],
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: AppColor.imageBgGrey,
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: AppColor.imageBgGrey,
                                ),
                              ),
                            ),
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
            SizedBox(
              width: 13,
            ),
            Expanded(
              child: Text(
                _groupList[index].modifiedName ?? _groupList[index].name,
                style: TextStyle(color: AppColor.white, fontSize: 16),
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(
              width: 26,
            ),
            AppIcon.getAppIcon(
              AppIcon.arrow_right_18,
              18,
              color: AppColor.white,
            ),
          ],
        ),
      ),
    );
  }
}
