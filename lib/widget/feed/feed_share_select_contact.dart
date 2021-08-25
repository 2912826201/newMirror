import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:mirror/api/message_api.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/dto/group_chat_user_information_dto.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/data/model/message/chat_group_user_model.dart';
import 'package:mirror/data/model/message/group_user_model.dart';
import 'package:mirror/data/model/profile/buddy_list_model.dart';
import 'package:mirror/im/message_manager.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../page/message/util/message_chat_page_manager.dart';
import 'package:mirror/page/profile/profile_detail_page.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/string_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:provider/provider.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

import '../custom_appbar.dart';
import '../custom_button.dart';
import '../icon.dart';
import '../smart_refressher_head_footer.dart';
import 'feed_friends_cell.dart';
import 'feed_index_bar.dart';

// 通讯录数据
class Friends {
  String imageUrl; //头像
  String name; // 用户名
  String indexLetter; //首字母大写
  int uid; // 用户Id
  int oldIndex;

  Friends({this.imageUrl, this.name, this.indexLetter, this.uid, this.oldIndex});

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["uid"] = uid;
    map["imageUrl"] = imageUrl;
    map["indexLetter"] = indexLetter;
    map["oldIndex"] = oldIndex;
    map["name"] = name;
    return map;
  }

  @override
  String toString() {
    return toJson().toString();
  }
}

// ignore: must_be_immutable
class FriendsPage extends StatefulWidget {
  final FriendsCallback friendsCallback;
  final int groupChatId; //群聊id
  int type; //0 表示原来的样式 1群成员-查看所有群成员  2移除某一个人出群 3拉人进入群 4分享群聊 其余全表示为0
  final Map<String, dynamic> shareMap;
  final String chatTypeModel;

  FriendsPage({
    Key key,
    this.friendsCallback,
    this.type = 0,
    this.groupChatId,
    this.shareMap,
    this.chatTypeModel,
  }) : super(key: key);

  @override
  _FriendsPageState createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
//  字典里面放item和高度的对应数据
  final Map _groupOffsetMap = {
//    这里因为根据实际数据变化和固定全部字母前两个值都是一样的，所以没有做动态修改，如果不一样记得要修改
    INDEX_WORDS[0]: 0.0,
    INDEX_WORDS[1]: 0.0,
  };

  bool isHaveTextLen = false;

  ScrollController _scrollController;

  // 排序字母数组
  final List<Friends> _listDatas = [];

  // 非字母#数组
  final List<Friends> nonLetterlistDatas = [];

  // 不参与排序的数组
  final List<Friends> noSortlistDatas = [];

  final textController = TextEditingController();

  //有单选模式时,选中的用户的id
  final List<int> selectUserUsIdList = [];

  //加载状态
  LoadingStatus loadingStatus = LoadingStatus.STATUS_IDEL;

  //好友列表
  BuddyListModel followListModel = new BuddyListModel();
  List<BuddyModel> userFollowList = [];

  //群聊列表
  List<Map<String, dynamic>> groupMapList = [];

  RefreshController _refreshController = RefreshController(); //

  @override
  void initState() {
    //初始化，只调用一次
    super.initState();
    //获取所有的数据
    loadingStatus = LoadingStatus.STATUS_LOADING;
    getAllData();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _scrollController = PrimaryScrollController.of(context);
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    textController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    print("type:${widget.type}");
    return Scaffold(
        appBar: getAppBar(),
        body: Container(
          color: AppColor.mainBlack,
          child: getBodyUi(),
        ));
  }

  Widget getBodyUi() {
    if (loadingStatus == LoadingStatus.STATUS_LOADING) {
      return Container(
        padding: const EdgeInsets.only(bottom: 100),
        width: double.infinity,
        height: double.infinity,
        child: UnconstrainedBox(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    } else if (widget.type == 3 && (followListModel.list == null || followListModel.list.length < 1)) {
      return Container(
        padding: const EdgeInsets.only(bottom: 100),
        width: double.infinity,
        height: double.infinity,
        child: UnconstrainedBox(
          child: Center(
            child: Column(
              children: [
                Container(
                  width: 224.0,
                  height: 224.0,
                  child: Image.asset("assets/png/default_no_data.png", fit: BoxFit.cover),
                ),
                SizedBox(height: 16),
                Text("没有可以邀请的好友了", style: TextStyle(fontSize: 14, color: AppColor.textWhite60)),
              ],
            ),
          ),
        ),
      );
    } else {
      return Stack(
        children: <Widget>[
          //顶部搜索框
          _getTopItemSearch(),
          //去分析群聊界面
          getGroupBtnUi(),
          //列表
          _getListView(),
          //悬浮检索控件
          getIndexBar(),
        ],
      );
    }
  }

  //获取群聊按钮
  Widget getGroupBtnUi() {
    return Visibility(
      visible: widget.type == 0,
      child: GestureDetector(
        child: Container(
          color: AppColor.transparent,
          alignment: Alignment.centerLeft,
          height: 40,
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.only(left: 16),
          margin: const EdgeInsets.only(top: 55),
          child: UnconstrainedBox(
            child: const Text(
              "已加入群聊",
              style: TextStyle(fontSize: 16, color: AppColor.mainBlack),
            ),
          ),
        ),
        onTap: () {
          AppRouter.navigateFriendsPage(
              context: context, type: 4, shareMap: widget.shareMap, chatTypeModel: widget.chatTypeModel);
        },
      ),
    );
  }

  //获取appbar
  Widget getAppBar() {
    return CustomAppBar(
      titleString: (widget.type == 1 || widget.type == 2)
          ? "群成员 (${_listDatas.length})"
          : widget.type == 4
              ? "选择群聊"
              : "选择联系人",
      actions: [
        Visibility(
          visible: widget.type == 1 &&
              context.watch<GroupUserProfileNotifier>().loadingStatus == LoadingStatus.STATUS_COMPLETED &&
              context.watch<GroupUserProfileNotifier>().chatGroupUserModelList.length > 0 &&
              context.watch<GroupUserProfileNotifier>().chatGroupUserModelList[0].uid == Application.profile.uid,
          child: GestureDetector(
            child: Container(
              padding: const EdgeInsets.only(right: 8, left: 8),
              alignment: Alignment.center,
              color: AppColor.transparent,
              child: const Text(
                "移除群聊",
                style: TextStyle(fontSize: 14, color: AppColor.white),
              ),
            ),
            onTap: () {
              widget.type = 2;
              setState(() {});
            },
          ),
        ),
        Visibility(
          visible: widget.type == 2,
          // visible: widget.type == 2 || (widget.type == 3 && followListModel.list.length > 0),
          child: GestureDetector(
            child: Container(
              padding: const EdgeInsets.only(right: 8, left: 8),
              alignment: Alignment.center,
              color: AppColor.transparent,
              child: Text(
                widget.type == 2 ? "确认移除" : "确认添加",
                style: TextStyle(fontSize: 14, color: AppColor.mainRed),
              ),
            ),
            onTap: () {
              String uids = "";

              if (selectUserUsIdList == null || selectUserUsIdList.length < 1) {
                ToastShow.show(msg: "没有选中的用户", context: context);
                return;
              } else {
                for (int i = 0; i < selectUserUsIdList.length; i++) {
                  if (i == selectUserUsIdList.length - 1) {
                    uids += selectUserUsIdList[i].toString();
                  } else {
                    uids += selectUserUsIdList[i].toString() + ",";
                  }
                }
              }

              if (widget.type == 2) {
                deleteUserGroup(uids);
              } else {
                addUserGroup(uids);
              }
            },
          ),
        ),
        Visibility(
          visible: (widget.type == 3 && followListModel.list.length > 0),
          child: Container(
            padding:
                const EdgeInsets.only(right: CustomAppBar.appBarIconPadding - CustomAppBar.appBarHorizontalPadding),
            child: CustomYellowButton(
              "完成",
              CustomYellowButton.buttonStateNormal,
              () {
                String uids = "";

                if (selectUserUsIdList == null || selectUserUsIdList.length < 1) {
                  ToastShow.show(msg: "没有选中的用户", context: context);
                  return;
                } else {
                  for (int i = 0; i < selectUserUsIdList.length; i++) {
                    if (i == selectUserUsIdList.length - 1) {
                      uids += selectUserUsIdList[i].toString();
                    } else {
                      uids += selectUserUsIdList[i].toString() + ",";
                    }
                  }
                }
                addUserGroup(uids);
              },
            ),
          ),
        )
      ],
    );
  }

  //搜索框
  Widget _getTopItemSearch() {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, top: 18, bottom: 10),
      decoration: BoxDecoration(color: AppColor.textWhite40, borderRadius: BorderRadius.circular(4)),
      height: 32,
      width: ScreenUtil.instance.screenWidthDp,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            width: 9,
          ),
          AppIcon.getAppIcon(
            AppIcon.input_search,
            24,
            color: AppColor.white,
          ),
          Expanded(
            child: Container(
              height: 32,
              alignment: Alignment.center,
              child: TextField(
                style: AppStyle.whiteRegular16,
                textInputAction: TextInputAction.search,
                // focusNode: FocusNode(),
                controller: textController,
                onChanged: (text) {
                  if (StringUtil.strNoEmpty(text)) {
                    isHaveTextLen = true;
                  } else {
                    isHaveTextLen = false;
                  }
                  setState(() {});
                },
                decoration: const InputDecoration(
                    isCollapsed: true,
                    contentPadding: EdgeInsets.only(top: 0, bottom: 0, left: 6),
                    hintText: '搜索用户',
                    hintStyle: AppStyle.text1Regular16,
                    border: InputBorder.none),
              ),
            ),
          ),
        ],
      ),
    );
  }

  //用户列表
  Widget _getListView() {
    // 排序字母数组
    List<Friends> _listUserDataList = [];
    if (!isHaveTextLen) {
      _listUserDataList.addAll(_listDatas);
    } else {
      for (int i = 0; i < _listDatas.length; i++) {
        if (_listDatas[i].name.toLowerCase().contains(textController.text.toLowerCase())) {
          print("_listDatas[i].name:${_listDatas[i].name}---textController.text:${textController.text}");
          _listUserDataList.add(_listDatas[i]);
        }
      }
    }
    return Container(
        color: AppColor.mainBlack,
        margin: widget.type == 0 ? const EdgeInsets.only(top: 100) : const EdgeInsets.only(top: 60),
        child: SmartRefresher(
          enablePullUp: false,
          enablePullDown: false,
          footer: SmartRefresherHeadFooter.init().getFooter(isShowNoMore: false),
          header: SmartRefresherHeadFooter.init().getHeader(),
          controller: _refreshController,
          onLoading: _onLoading,
          onRefresh: _onRefresh,
          child: ListView.builder(
              physics: ClampingScrollPhysics(),
              controller: _scrollController,
              itemCount: _listUserDataList.length,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              itemBuilder: (context, index) {
                int noBottomIndex = 0;
                if (index < _listUserDataList.length - 1 &&
                    _listUserDataList[index + 1].indexLetter != _listUserDataList[index].indexLetter) {
                  noBottomIndex = index + 1;
                }
                return itemForRow(context, index, noBottomIndex, _listUserDataList[index],
                    index == 0 ? null : _listUserDataList[index - 1]);
              }),
        ));
  }

  //每一个item
  Widget itemForRow(BuildContext context, int index, int noBottomIndex, Friends userModel, Friends oldUserModel) {
    //显示剩下的cell
    //如果当前和上一个cell的indexLetter一样，就不显示
    bool _hideIndexLetter = (index > 0 && userModel.indexLetter == oldUserModel.indexLetter);
    return FriendsCell(
      imageUrl: userModel.imageUrl,
      name: userModel.name,
      userId: userModel.uid,
      groupTitle: _hideIndexLetter ? null : userModel.indexLetter,
      noBottomIndex: noBottomIndex,
      friendsCallback: _friendsCallback,
      isShowTitle: !isHaveTextLen,
      isShowSingleChoice: widget.type == 2 || widget.type == 3,
      isSelectSingleChoice: selectUserUsIdList.contains(userModel.uid),
    );
  }

  //悬浮检索控件
  Widget getIndexBar() {
    return IndexBar(
      indexBarCallBack: (String str) {
        if (_groupOffsetMap[str] != null) {
          _scrollController.animateTo(_groupOffsetMap[str], duration: Duration(milliseconds: 1), curve: Curves.easeIn);
        }
      },
      isShow: !isHaveTextLen,
    );
  }

  //初始化用户数据
  void initUserData() {
    if (widget.type == 1 || widget.type == 2) {
      List<ChatGroupUserModel> chatGroupUserModelList = context.read<GroupUserProfileNotifier>().chatGroupUserModelList;
      for (int i = 0; i < chatGroupUserModelList.length; i++) {
        String name = getGroupMeName(widget.groupChatId.toString(), chatGroupUserModelList[i].uid.toString(),
            chatGroupUserModelList[i].groupNickName);
        addUserNameData(name, i, userModel: chatGroupUserModelList[i]);
      }
    } else if (widget.type == 4) {
      for (int i = 0; i < groupMapList.length; i++) {
        if (groupMapList[i]["modifiedName"] == null || groupMapList[i]["modifiedName"].toString().length < 1) {
          addUserNameData(groupMapList[i]["name"], i, groupMap: groupMapList[i]);
        } else {
          addUserNameData(groupMapList[i]["modifiedName"], i, groupMap: groupMapList[i]);
        }
      }
    } else {
      for (int i = 0; i < followListModel.list.length; i++) {
        addUserNameData(followListModel.list[i].nickName, i, followModel: followListModel.list[i]);
      }
    }
    // else {
    //   // 测试到时替换为model
    //   for (int i = 0; i < names.length; i++) {
    //     addUserNameData(names[i], i);
    //   }
    // }
  }

  String getGroupMeName(String chatGroupId, String uid, String name) {
    String userName = ((MessageManager.chatGroupUserInformationMap["${chatGroupId}_$uid"] ??
        Map())[GROUP_CHAT_USER_INFORMATION_GROUP_USER_NAME]);
    if (userName == null || userName.length < 1) {
      userName = (MessageManager.chatGroupUserInformationMap["${chatGroupId}_$uid"] ??
          Map())[GROUP_CHAT_USER_INFORMATION_USER_NAME];
    }
    if (userName == null || userName.length < 1) {
      return name;
    } else {
      return userName;
    }
  }

  //排序用户列表
  void sortListDatas() {
    //排序!
    _listDatas.sort((Friends a, Friends b) {
      return a.indexLetter.compareTo(b.indexLetter);
    });
    _listDatas.insertAll(0, noSortlistDatas);
    _listDatas.addAll(nonLetterlistDatas);
  }

  //对用户的名字格式化处理
  void addUserNameData(String name, int index,
      {ChatGroupUserModel userModel, BuddyModel followModel, Map<String, dynamic> groupMap}) {
    Friends friendData = Friends();
    friendData.uid = -1;
    // 转换拼音再截取搜字母转大写
    String pinyinString =
        PinyinHelper.getPinyinE(name, separator: " ", defPinyin: '#', format: PinyinFormat.WITHOUT_TONE).capitalize();
    RegExp mobile = RegExp(r"[a-zA-Z]");

    friendData.name = name;
    friendData.oldIndex = index;

    if (userModel != null) {
      friendData.uid = userModel.uid;
    }
    if (followModel != null) {
      friendData.uid = followModel.uid;
    }
    if (groupMap != null) {
      friendData.uid = groupMap["id"];
    }

    if ((widget.type == 1 || widget.type == 2) && userModel != null && userModel.isGroupLeader()) {
      var imageUrl = "https://randomuser.me/api/portraits/women/23.jpg";
      if (widget.type == 1 || widget.type == 2) {
        imageUrl = userModel.avatarUri ?? imageUrl;
      }
      friendData.indexLetter = "群主";
      friendData.imageUrl = imageUrl;
      noSortlistDatas.add(friendData);
    } else if (!mobile.hasMatch(pinyinString)) {
      var imageUrl = "https://randomuser.me/api/portraits/women/23.jpg";
      imageUrl = userModel?.avatarUri ?? followModel?.avatarUri ?? groupMap["coverUrl"] ?? imageUrl;
      pinyinString = "#";
      friendData.indexLetter = pinyinString;
      friendData.imageUrl = imageUrl;
      nonLetterlistDatas.add(friendData);
    } else {
      var imageUrl = "https://randomuser.me/api/portraits/women/27.jpg";
      imageUrl = userModel?.avatarUri ?? followModel?.avatarUri ?? groupMap["coverUrl"] ?? imageUrl;
      friendData.indexLetter = pinyinString;
      friendData.imageUrl = imageUrl;
      _listDatas.add(friendData);
    }
  }

  //设置偏移量
  void setGroupOffsetMap() {
    // 总偏移
    var _groupOffset = 0.0;
    // 间距高度
    int spacingHeight = 0;
    //经过循环计算，将每一个头的位置算出来，放入字典
    for (int i = 0; i < _listDatas.length; i++) {
      if (i < _listDatas.length - 1 && _listDatas[i + 1].indexLetter == _listDatas[i].indexLetter) {
        spacingHeight = 10;
      } else {
        spacingHeight = 0;
      }
      if (i < 1 || _listDatas[i].indexLetter != _listDatas[i - 1].indexLetter) {
        //第一个cell
        _groupOffsetMap.addAll({_listDatas[i].indexLetter: _groupOffset});
        //保存完了再加——groupOffset偏移
        _groupOffset += 76.0;
        _groupOffset += spacingHeight;
      } else {
        //此时没有头部，只需要加偏移量就好了
        _groupOffset += 48;
        _groupOffset += spacingHeight;
      }
    }
  }

  //获取所有的数据
  void getAllData() async {
    //0 表示原来的样式 1群成员-查看所有群成员  2移除某一个人出群 3拉人进入群 4分享群聊 其余全表示为0
    if (widget.type == 1 || widget.type == 2) {
      init();
    } else if (widget.type == 4) {
      getAllGroupList();
    } else {
      followListModel.list = userFollowList;
      _onRefresh();
    }
  }

  //获取所有的群聊
  void getAllGroupList() async {
    groupMapList.clear();
    Map<String, dynamic> groupChatListMap = await getGroupChatList();
    if (groupChatListMap != null && groupChatListMap["list"] != null) {
      groupChatListMap["list"].forEach((v) {
        groupMapList.add(v);
      });

      // groupMapList.addAll(groupChatListMap["list"] in Map<String, dynamic>);
    }
    init();
  }

  // 下拉刷新
  _onRefresh() async {
    followListModel.list.clear();
    followListModel.lastTime = null;
    _onLoading(isOnRefresh: true);
  }

  // 下拉刷新
  _onLoading({bool isOnRefresh = false}) async {
    BuddyListModel listModel = await getFollowBothList();
    if (listModel == null || listModel.list == null) {
      return;
    }
    followListModel.list.addAll(listModel.list);
    followListModel.lastTime = listModel.lastTime;

    // 去除本来就在群内的好友
    if (widget.type == 3) {
      for (int i = 0; i < followListModel.list.length; i++) {
        // print("111111date:${MessageManager.chatGroupUserInformationMap["${widget.groupChatId}_${followListModel.list[i].uid}"]}");
        if (MessageManager.chatGroupUserInformationMap["${widget.groupChatId}_${followListModel.list[i].uid}"] !=
            null) {
          followListModel.list.removeAt(i);
          i--;
        }
      }
    }

    noSortlistDatas.clear();
    nonLetterlistDatas.clear();
    _listDatas.clear();

    if (isOnRefresh) {
      _refreshController.refreshCompleted();
      _refreshController.loadComplete();
    } else {
      _refreshController.loadComplete();
    }
    init();
  }

  //初始化
  void init() {
    //将所有的用户名按照拼音排序
    initUserData();
    //对用户的数据进行排序
    sortListDatas();
    //设置每一个偏移量
    setState(() {
      loadingStatus = LoadingStatus.STATUS_COMPLETED;
    });
    setGroupOffsetMap();
  }

  void _friendsCallback(String name, int userId, String avatar, int type, BuildContext context) async {
    if (widget.type == 2 || widget.type == 3) {
      //----------------------------------------添加人进入群聊或者将人移除群聊------------------
      if (widget.type == 2 && userId == context.read<GroupUserProfileNotifier>().chatGroupUserModelList[0].uid) {
        return;
      }
      if (selectUserUsIdList.contains(userId)) {
        selectUserUsIdList.remove(userId);
      } else {
        selectUserUsIdList.add(userId);
      }
      setState(() {});
    } else if (widget.type == 1) {
      //-----------------------------------------------查看群成员的个人信息------------
      Navigator.of(context).pop();
      jumpToUserProfilePage(context, userId, avatarUrl: avatar, userName: name);
    } else if (widget.type == 4) {
      //--------------------------------------------分享消息到群聊---------------
      if (await jumpShareMessage(
          widget.shareMap, widget.chatTypeModel, name, userId, RCConversationType.Group, context)) {
        ToastShow.show(msg: "分享成功", context: context);
      } else {
        ToastShow.show(msg: "分享失败", context: context);
      }
    } else if (widget.type == 0) {
      //----------------------------------------------分享消息到私聊-------------
      if (await jumpShareMessage(
          widget.shareMap, widget.chatTypeModel, name, userId, RCConversationType.Private, context)) {
        ToastShow.show(msg: "分享成功", context: context);
      } else {
        ToastShow.show(msg: "分享失败", context: context);
      }
    }
  }

  //添加这些用户
  void addUserGroup(String uids) async {
    Map<String, dynamic> model = await inviteJoin(groupChatId: widget.groupChatId, uids: uids);
    selectUserUsIdList.clear();
    if (model != null) {
      if (model["NotFriendList"] != null && model["NotFriendList"].length > 0) {
        String name = "";
        for (int i = 0; i < model["NotFriendList"].length; i++) {
          if (i == 0) {
            name += model["NotFriendList"][i]["nickName"];
          } else {
            name += "," + model["NotFriendList"][i]["nickName"];
          }
        }
        ToastShow.show(msg: name, context: context);
      } else {
        ToastShow.show(msg: "邀请成功", context: context);
        getChatGroupUserModelList1(widget.groupChatId.toString(), context);
      }
    } else {
      ToastShow.show(msg: "邀请失败", context: context);
    }
    Future.delayed(Duration(milliseconds: 200), () {
      Navigator.of(context).pop();
    });
  }

  //删除这些用户
  void deleteUserGroup(String uids) async {
    print("删除这些用户");

    Map<String, dynamic> model = await kickedGroupChat(groupChatId: widget.groupChatId, uids: uids);

    selectUserUsIdList.clear();
    if (model != null && model["state"]) {
      ToastShow.show(msg: "删除成功", context: context);
      getChatGroupUserModelList1(widget.groupChatId.toString(), context);
    } else {
      ToastShow.show(msg: "删除失败", context: context);
    }
    Future.delayed(Duration(milliseconds: 200), () {
      Navigator.of(context).pop();
    });
  }
}

// 返回首字母大写
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}";
  }
}
