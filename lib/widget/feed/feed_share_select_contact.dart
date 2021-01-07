import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:mirror/api/message_page_api.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/data/model/message/chat_group_user_model.dart';
import 'package:mirror/data/model/profile/follow_list_model.dart';
import 'package:mirror/page/message/message_chat_page_manager.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/string_util.dart';
import 'package:mirror/util/toast_util.dart';

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
}

class FriendsPage extends StatefulWidget {
  final VoidCallback voidCallback;
  final int groupChatId; //群聊id
  final int type; //0 表示原来的样式 1群成员-查看所有群成员  2移除某一个人出群 3拉人进入群 其余全表示为0

  const FriendsPage({
    Key key,
    this.voidCallback,
    this.type = 0,
    this.groupChatId,
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
  FollowListModel followListModel = new FollowListModel();
  List<FollowModel> userFollowList = [];

  @override
  void initState() {
    //初始化，只调用一次
    super.initState();
    //获取所有的数据
    loadingStatus = LoadingStatus.STATUS_LOADING;
    getAllData();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    super.dispose();
    textController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(),
      body: getBodyUi(),
    );
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
            child: Text("没有数据"),
          ),
        ),
      );
    } else {
      return Stack(
        children: <Widget>[
          //顶部搜索框
          _getTopItemSearch(),
          //列表
          _getListView(),
          //悬浮检索控件
          getIndexBar(),
        ],
      );
    }
  }


  //获取appbar
  Widget getAppBar() {
    return AppBar(
      title: Text(
        (widget.type == 1 || widget.type == 2) ? "群成员 (${_listDatas.length})" : "选择联系人",
        style: TextStyle(color: AppColor.textPrimary1, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      automaticallyImplyLeading: false,
      backgroundColor: AppColor.white,
      leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pop(true);
          },
          child: Container(
            margin: EdgeInsets.only(left: 16),
            child: Image.asset(
              "images/resource/2.0x/return2x.png",
            ),
          )),
      leadingWidth: 44.0,
      elevation: 0.5,
      actions: [
        Visibility(
          visible: widget.type == 2 || widget.type == 3,
          child: GestureDetector(
            child: Container(
              padding: const EdgeInsets.only(right: 16, left: 8),
              alignment: Alignment.center,
              color: AppColor.transparent,
              child: Text(widget.type == 2 ? "确认移除" : "确认添加", style: TextStyle(fontSize: 14, color: AppColor.mainRed),),
            ),
            onTap: () {
              String uids = "";

              if (selectUserUsIdList == null || selectUserUsIdList.length < 1) {
                ToastShow.show(msg: "没有选中的用户", context: context);
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
      ],
      // MyIconBtn(
      //   // width: 28,
      //   // height: 28,
      //   iconSting: "images/resource/2.0x/return2x.png",
      //   onPressed: () {
      //     Navigator.of(context).pop(true);
      //   },
      // ),
    );
  }

  //搜索框
  Widget _getTopItemSearch() {
    return Container(
      margin: EdgeInsets.only(left: 16, right: 16, top: 18, bottom: 10),
      height: 32,
      color: AppColor.bgWhite.withOpacity(0.65),
      width: ScreenUtil.instance.screenWidthDp,
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
                textInputAction: TextInputAction.search,
                controller: textController,
                onChanged: (text) {
                  if (StringUtil.strNoEmpty(text)) {
                    isHaveTextLen = true;
                  } else {
                    isHaveTextLen = false;
                  }
                  setState(() {});
                },
                decoration: new InputDecoration(
                    isCollapsed: true,
                    contentPadding: EdgeInsets.only(top: 0, bottom: 0, left: 6),
                    hintText: '搜索用户',
                    hintStyle: TextStyle(color: AppColor.textSecondary),
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
        if (_listDatas[i].name.toLowerCase().contains(
            textController.text.toLowerCase())) {
          print("_listDatas[i].name:${_listDatas[i]
              .name}---textController.text:${textController.text}");
          _listUserDataList.add(_listDatas[i]);
        }
      }
    }
    return Container(
        color: AppColor.white,
        margin: EdgeInsets.only(top: 60),
        child: ListView.builder(
            controller: _scrollController,
            itemCount: _listUserDataList.length,
            itemBuilder: (context, index) {
              int noBottomIndex = 0;
              if (index < _listUserDataList.length - 1 &&
                  _listUserDataList[index + 1].indexLetter !=
                      _listUserDataList[index].indexLetter) {
                noBottomIndex = index;
              }
              return itemForRow(context, index, noBottomIndex,
                  _listUserDataList[index], index == 0 ? null : _listUserDataList[index - 1]);
            }
        )
    );
  }

  //每一个item
  Widget itemForRow(BuildContext context, int index, int noBottomIndex, Friends userModel, Friends oldUserModel) {
    //显示剩下的cell
    //如果当前和上一个cell的indexLetter一样，就不显示
    bool _hideIndexLetter = (index > 0 &&
        userModel.indexLetter == oldUserModel.indexLetter);
    return FriendsCell(
      imageUrl: userModel.imageUrl,
      name: userModel.name,
      userId: userModel.uid,
      groupTitle: _hideIndexLetter ? null : userModel.indexLetter,
      noBottomIndex: noBottomIndex,
      voidCallback: !(widget.type == 2 || widget.type == 3) ? widget.voidCallback :
          (String name, int userId, BuildContext context) {
        if (selectUserUsIdList.contains(userId)) {
          selectUserUsIdList.remove(userId);
        } else {
          selectUserUsIdList.add(userId);
        }
        setState(() {

        });
      },
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
          _scrollController.animateTo(_groupOffsetMap[str],
              duration: Duration(milliseconds: 1), curve: Curves.easeIn);
        }
      },
      isShow: !isHaveTextLen,
    );
  }


  //初始化用户数据
  void initUserData() {
    if (widget.type == 1 || widget.type == 2) {
      for (int i = 0; i < Application.chatGroupUserModelList.length; i++) {
        addUserNameData(
            Application.chatGroupUserModelList[i].groupNickName, i, userModel: Application.chatGroupUserModelList[i]);
      }
    } else {
      for (int i = 0; i < followListModel.list.length; i++) {
        addUserNameData(
            followListModel.list[i].nickName, i, followModel: followListModel.list[i]);
      }
    }
    // else {
    //   // 测试到时替换为model
    //   for (int i = 0; i < names.length; i++) {
    //     addUserNameData(names[i], i);
    //   }
    // }
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
  void addUserNameData(String name, int index, {ChatGroupUserModel userModel, FollowModel followModel}) {
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

    if ((widget.type == 1 || widget.type == 2) && userModel != null && userModel.isGroupLeader()) {
      var imageUrl = "https://randomuser.me/api/portraits/women/23.jpg";
      if (widget.type == 1 || widget.type == 2) {
        imageUrl = userModel.avatarUri ?? imageUrl;
      }
      friendData.indexLetter = "群成员";
      friendData.imageUrl = imageUrl;
      noSortlistDatas.add(friendData);
    } else if (!mobile.hasMatch(pinyinString)) {
      var imageUrl = "https://randomuser.me/api/portraits/women/23.jpg";
      imageUrl = userModel?.avatarUri ?? followModel.avatarUri ?? imageUrl;
      pinyinString = "#";
      friendData.indexLetter = pinyinString;
      friendData.imageUrl = imageUrl;
      nonLetterlistDatas.add(friendData);
    } else {
      var imageUrl = "https://randomuser.me/api/portraits/women/27.jpg";
      imageUrl = userModel?.avatarUri ?? followModel.avatarUri ?? imageUrl;
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
        _groupOffset += 76.5;
        _groupOffset += spacingHeight;
      } else {
        //此时没有头部，只需要加偏移量就好了
        _groupOffset += 48;
        _groupOffset += spacingHeight;
      }
    }

    setState(() {
      loadingStatus = LoadingStatus.STATUS_COMPLETED;
    });
  }

  //初始化
  void init() {
    //将所有的用户名按照拼音排序
    initUserData();
    //对用户的数据进行排序
    sortListDatas();
    //设置每一个偏移量
    setGroupOffsetMap();
  }

  //获取所有的数据
  void getAllData() async {
    if (widget.type == 1 || widget.type == 2) {
      init();
    } else {
      followListModel.list = userFollowList;
      getNetData();
    }
  }

  //获取网络数据
  void getNetData() async {
    FollowListModel listModel = await GetFollowBothList(100, lastTime: followListModel.lastTime);
    followListModel.list.addAll(listModel.list);
    followListModel.lastTime = listModel.lastTime;

    // 去除本来就在群内的好友
    if (widget.type == 3) {
      for (int i = 0; i < followListModel.list.length; i++) {
        String userName = Application.chatGroupUserModelMap[followListModel.list[i].uid.toString()];
        if (userName != null) {
          followListModel.list.removeAt(i);
          i--;
        }
      }
    }

    init();
  }

  //添加这些用户
  void addUserGroup(String uids) async {
    print("添加这些用户");
    Map<String, dynamic> model = await inviteJoin(groupChatId: widget.groupChatId, uids: uids);

    selectUserUsIdList.clear();
    if (model != null && model["state"]) {
      ToastShow.show(msg: "添加成功", context: context);
      await getChatGroupUserModelList(widget.groupChatId.toString());
      widget.voidCallback("添加成功", 0, context);
    } else {
      ToastShow.show(msg: "添加失败", context: context);
      widget.voidCallback("添加失败", 0, context);
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
      await getChatGroupUserModelList(widget.groupChatId.toString());
      widget.voidCallback("删除成功", 0, context);
    } else {
      ToastShow.show(msg: "删除失败", context: context);
      widget.voidCallback("删除失败", 0, context);
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
