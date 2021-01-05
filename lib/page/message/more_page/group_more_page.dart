import 'package:english_words/english_words.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/dto/conversation_dto.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/feed/feed_share_select_contact.dart';

class GroupMorePage extends StatefulWidget {
  ///对话用户id
  final String chatUserId;

  ///这个是什么类型的对话--中文
  ///[chatType] 会话类型，参见类型 [OFFICIAL_TYPE]
  final int chatType;

  GroupMorePage({this.chatUserId, this.chatType});

  @override
  createState() => GroupMorePageState();
}

class GroupMorePageState extends State<GroupMorePage> {
  var wordPairList = <WordPair>[];
  bool disturbTheNews = false;
  bool topChat = false;

  @override
  Widget build(BuildContext context) {
    wordPairList.clear();
    wordPairList.addAll(generateWordPairs().take(20));
    return Scaffold(
      appBar: AppBar(
        title: Text("群聊消息"),
        centerTitle: true,
      ),
      body: getBodyUi(),
    );
  }

  //获取主体
  Widget getBodyUi() {
    return Container(
      color: AppColor.white,
      child: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(
              height: 18,
            ),
          ),
          getTopAllUserImage(),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 8,
            ),
          ),
          getSeeAllUserBtn(),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 18,
            ),
          ),
          getContainer(),
          getListItem(text: "群聊名称", subtitle: "还未取名"),
          getListItem(text: "群聊二维码", isRightIcon: true),
          getContainer(height: 12, horizontal: 0),
          getListItem(text: "群昵称", subtitle: "还未取名"),
          getContainer(),
          getListItem(text: "消息免打扰", isOpen: disturbTheNews, index: 1),
          getListItem(text: "置顶聊天", isOpen: topChat, index: 2),
          getContainer(height: 12, horizontal: 0),
          getListItem(text: "删除并退出", textColor: AppColor.mainRed),
          getContainer(),
        ],
      ),
    );
  }

  //获取头部群用户的头像
  Widget getTopAllUserImage() {
    var wordPairs = <WordPair>[];
    if (wordPairList.length > 13) {
      wordPairs.addAll(wordPairList.sublist(0, 13));
    } else {
      wordPairs.addAll(wordPairList);
    }
    wordPairs.add(new WordPair.random());
    wordPairs.add(new WordPair.random());
    return SliverGrid.count(
      crossAxisCount: 5,
      childAspectRatio: 1.0,
      mainAxisSpacing: 1,
      crossAxisSpacing: 1,
      children: List.generate(wordPairs.length, (index) {
        if (index >= 13) {
          return getTopItemAddOrSubUserUi(index == 13);
        } else {
          return getItemUserImage(index, wordPairs[index]);
        }
      }).toList(),
    );
  }

  //获取查看更多用户的按钮
  Widget getSeeAllUserBtn() {
    return SliverToBoxAdapter(
      child: Container(
        child: GestureDetector(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "查看更多群成员",
                style: TextStyle(color: AppColor.textSecondary, fontSize: 12),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColor.textSecondary,
                size: 12,
              ),
            ],
          ),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) {
              return FriendsPage(voidCallback: (name, context) {
                print("点击了name：$name");
              });
            }));
          },
        ),
      ),
    );
  }

  //获取下面每一个listItem
  Widget getListItem(
      {String text,
      String subtitle,
      bool isOpen,
      bool isRightIcon,
      Color textColor,
      int index}) {
    return SliverToBoxAdapter(
        // child: getItemList(text,subtitle,isOpen,isRightIcon,textColor),
        child: Material(
            color: AppColor.white,
            child: new InkWell(
              child: getItemList(
                  text, subtitle, isOpen, isRightIcon, textColor, index),
              splashColor: AppColor.textHint,
              onTap: () {
                onClickItemList(text: text, isOpen: isOpen, index: index);
              },
            )));
  }

  //每一个item--list
  Widget getItemList(String text, String subtitle, bool isOpen,
      bool isRightIcon, Color textColor, int index) {
    var padding1 = const EdgeInsets.only(left: 16, right: 10);
    var padding2 = const EdgeInsets.symmetric(horizontal: 16);
    return Container(
      height: 48,
      padding: isOpen == null ? padding2 : padding1,
      child: Row(
        children: [
          Text(text,
              style: TextStyle(
                  fontSize: 16,
                  color: textColor ?? AppColor.textPrimary1,
                  fontWeight: FontWeight.w500)),
          Expanded(child: SizedBox()),
          subtitle != null
              ? Text(subtitle, style: AppStyle.textSecondaryMedium14)
              : Container(),
          subtitle != null ? SizedBox(width: 12) : Container(),
          isRightIcon != null || subtitle != null
              ? Icon(
                  Icons.chevron_right,
                  size: 17,
                  color: AppColor.textSecondary,
                )
              : Container(),
          isOpen != null
              ? Container(
                  child: Transform.scale(
                    scale: 0.75,
                    child: CupertinoSwitch(
                      activeColor: AppColor.mainRed,
                      value: isOpen,
                      onChanged: (bool value) {
                        onClickItemList(
                            text: text, isOpen: isOpen, index: index);
                      },
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  //间隔线
  Widget getContainer({double height, double horizontal}) {
    return SliverToBoxAdapter(
      child: Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.symmetric(horizontal: horizontal ?? 16),
        height: height ?? 0.5,
        color: AppColor.bgWhite,
      ),
    );
  }

  //获取每一个用户的头像显示
  Widget getItemUserImage(int index, WordPair wordPair) {
    return Container(
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(47 / 2.0),
            child: Image.asset(
              "images/test/bg.png",
              fit: BoxFit.cover,
              width: 47,
              height: 47,
            ),
          ),
          SizedBox(
            height: 6,
          ),
          SizedBox(
            width: 47,
            child: Text(
              wordPair.asPascalCase * 3,
              style: TextStyle(fontSize: 12, color: AppColor.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          )
        ],
      ),
    );
  }

  //显示加减群成员
  Widget getTopItemAddOrSubUserUi(bool isAdd) {
    return Container(
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(47 / 2.0),
            child: Container(
              color: AppColor.bgWhite,
              width: 47,
              height: 47,
              child: Center(
                child: Text(
                  isAdd ? "+" : "-",
                  style: TextStyle(fontSize: 20, color: AppColor.textPrimary1),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  //点击事件
  void onClickItemList({String text, bool isOpen, int index}) {
    if (isOpen != null) {
      if (index == 1) {
        disturbTheNews = !disturbTheNews;
      } else {
        topChat = !topChat;
      }
      ToastShow.show(msg: "${!isOpen ? "打开" : "关闭"}$text", context: context);
      setState(() {});
    } else {
      ToastShow.show(msg: "点击了：$text", context: context);
    }
  }
}


