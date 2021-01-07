import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/message/chat_group_user_model.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/string_util.dart';

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
  final int type; //0 表示原来的样式 1群成员-查看所有群成员  2移除某一个人出群 3拉人进入群 其余全表示为0

  const FriendsPage({
    Key key,
    this.voidCallback,
    this.type = 0,
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

  @override
  void initState() {
    //初始化，只调用一次
    super.initState();
    //将所有的用户名按照拼音排序
    initUserData();
    //对用户的数据进行排序
    sortListDatas();
    //设置每一个偏移量
    setGroupOffsetMap();
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
      body: Stack(
        children: <Widget>[
          //顶部搜索框
          _getTopItemSearch(),
          //列表
          _getListView(),
          //悬浮检索控件
          getIndexBar(),
        ],
      ),
    );
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
          visible: widget.type == 2,
          child: GestureDetector(
            child: Container(
              padding: const EdgeInsets.only(right: 16, left: 8),
              alignment: Alignment.center,
              color: AppColor.transparent,
              child: Text("确认移除", style: TextStyle(fontSize: 14, color: AppColor.mainRed),),
            ),
            onTap: () {
              print("点击删除这个用户");
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
      userId: userModel.uid.toString(),
      groupTitle: _hideIndexLetter ? null : userModel.indexLetter,
      noBottomIndex: noBottomIndex,
      voidCallback: widget.type != 2 ? widget.voidCallback : (String content, BuildContext context) {
        int userId = int.parse(content);
        if (selectUserUsIdList.contains(userId)) {
          selectUserUsIdList.remove(userId);
        } else {
          selectUserUsIdList.add(userId);
        }
        setState(() {

        });
      },
      isShowTitle: !isHaveTextLen,
      isShowSingleChoice: widget.type == 2,
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
      // 测试到时替换为model
      for (int i = 0; i < names.length; i++) {
        addUserNameData(names[i], i);
      }
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
  void addUserNameData(String name, int index, {ChatGroupUserModel userModel}) {
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
      if (widget.type == 1 || widget.type == 2) {
        imageUrl = userModel.avatarUri ?? imageUrl;
      }
      pinyinString = "#";
      friendData.indexLetter = pinyinString;
      friendData.imageUrl = imageUrl;
      nonLetterlistDatas.add(friendData);
    } else {
      var imageUrl = "https://randomuser.me/api/portraits/women/27.jpg";
      if (widget.type == 1 || widget.type == 2) {
        imageUrl = userModel.avatarUri ?? imageUrl;
      }
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
  }

}


// 返回首字母大写
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}";
  }
}
