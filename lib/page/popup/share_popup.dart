import 'package:azlistview/azlistview.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:mirror/api/message_api.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/message/group_chat_model.dart';
import 'package:mirror/data/model/profile/buddy_list_model.dart';
import '../message/util/message_chat_page_manager.dart';
import 'package:mirror/util/click_util.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/Input_method_rules/pin_yin_text_edit_controller.dart';
import 'package:mirror/widget/icon.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

/// share_popup
/// Created by Shipk on 2021/4/6.

showSharePopup(BuildContext context, Map<String, dynamic> shareMap, String chatTypeModel) {
  showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      //可不受最大高度限制
      elevation: 0,
      backgroundColor: AppColor.transparent,
      builder: (context) {
        return _SharePopup(shareMap, chatTypeModel);
      });
}

class _SharePopup extends StatefulWidget {
  final Map<String, dynamic> shareMap;
  final String chatTypeModel;

  _SharePopup(this.shareMap, this.chatTypeModel);

  @override
  _SharePopupState createState() => _SharePopupState();
}

class _SharePopupState extends State<_SharePopup> {
  final PinYinTextEditController _inputController = PinYinTextEditController();
  final FocusNode _focusNode = FocusNode();
  List<BuddyModel> _originalFriendList = [];
  List<BuddyModel> _friendList = [];

  List<GroupChatModel> _groupList = [];

  PageController _pageController = PageController();

  String _lastSearchText = "";

  bool _isSharing = false;

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

  Widget _buildFriendItem(BuildContext context, int index) {
    return GestureDetector(
      onTap: () {
        if(ClickUtil.isFastClick()){
          return;
        }
        print("点击了人名");
        _shareMessage(_friendList[index].uid, _friendList[index].nickName, RCConversationType.Private);
      },
      child: Container(
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
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int index) {
    return Container(
      color: AppColor.layoutBgGrey,
      padding: const EdgeInsets.fromLTRB(22, 0, 16, 0),
      alignment: Alignment.centerLeft,
      height: 28,
      width: ScreenUtil.instance.width,
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
              AppIcon.getAppIcon(AppIcon.input_search, 24),
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
                  style: AppStyle.textRegular16,
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
          if (_focusNode.hasFocus) {
            FocusScope.of(context).requestFocus(new FocusNode());
          }
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
        //   color: AppColor.bgWhite,
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
    String name = _groupList[index].modifiedName ?? _groupList[index].name;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      height: 48,
      margin: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if(ClickUtil.isFastClick()){
            return;
          }
          print("点击了群名");
          _shareMessage(_groupList[index].id, name, RCConversationType.Group);
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
                                shape: BoxShape.circle, border: Border.all(width: 3, color: AppColor.white)),
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
            // AppIcon.getAppIcon(
            //   AppIcon.arrow_right_18,
            //   18,
            //   color: AppColor.textHint,
            // ),
          ],
        ),
      ),
    );
  }

  void _shareMessage(int userId, String name, int type) async {
    //避免重复分享
    if (_isSharing) {
      return;
    }
    _isSharing = true;
    if (await jumpShareMessage(widget.shareMap, widget.chatTypeModel, name, userId, type, context)) {
      ToastShow.show(msg: "分享成功", context: context);
    } else {
      ToastShow.show(msg: "分享失败", context: context);
    }
    _isSharing = false;
    Navigator.of(context).pop();
  }
}
