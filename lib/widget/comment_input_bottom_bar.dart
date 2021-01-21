import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/data/model/profile/buddy_list_model.dart';
import 'package:mirror/data/model/profile/searchuser_model.dart';
import 'package:mirror/page/feed/release_page.dart';
import 'package:mirror/page/home/sub_page/recommend_page.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:provider/provider.dart';
import 'package:text_span_field/range_style.dart';
import 'package:text_span_field/text_span_field.dart';
import 'package:toast/toast.dart';

import 'feed/release_feed_input_formatter.dart';

typedef VoidCallback = void Function(String content, List<Rule> rules, BuildContext context);

Future openInputBottomSheet({
  @required BuildContext context,
  @required VoidCallback voidCallback,
  String hintText,
}) async {
  await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      enableDrag: false,
      backgroundColor: AppColor.transparent,
      builder: (BuildContext context) {
        FocusNode _commentFocus = FocusNode();
        return ChangeNotifierProvider(
            create: (_) => CommentEnterNotifier(),
            builder: (context, _) {
              return Container(
                // decoration: BoxDecoration(
                //   color: AppColor.white,
                // borderRadius: BorderRadius.only(
                //   topLeft: Radius.circular(15),
                //   topRight: Radius.circular(15),
                // ),
                // ),
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom), // !important
                child: CommentInputBottomBar(
                  hintText: hintText,
                  voidCallback: voidCallback,
                  commentFocus: _commentFocus,
                ),
              );
            });
      });
}

class CommentInputBottomBar extends StatefulWidget {
  CommentInputBottomBar({Key key, this.voidCallback, this.hintText, this.commentFocus}) : super(key: key);
  final VoidCallback voidCallback;
  String hintText;
  final FocusNode commentFocus;

  @override
  createState() {
    return CommentInputBottomBarState(voidCallback, hintText, commentFocus);
  }
}

class CommentInputBottomBarState extends State<CommentInputBottomBar> {
  CommentInputBottomBarState(this.voidCallback, this.hintText, this.commentFocus);

  ReleaseFeedInputFormatter _formatter;
  List<TextInputFormatter> inputFormatters;

  // 判断是否只是切换光标
  bool isSwitchCursor = true;
  final VoidCallback voidCallback;
  String hintText;
  final TextEditingController _textEditingController = TextEditingController();
  final FocusNode commentFocus;
  WidgetsBinding widgetsBinding;

  // 滑动监听控制器
  ScrollController _scrollController = ScrollController();

  // 请求下一页
  int lastTime;

  // 是否存在下页
  int hasNext;

  // 数据加载页数
  int dataPage = 1;

  // 加载中默认文字
  String loadText = "加载中...";

  // 加载状态
  LoadingStatus loadStatus = LoadingStatus.STATUS_IDEL;

  // 搜索请求下一页
  int searchLastTime;

  // 搜索是否存在下页
  int searchHasNext;

  // 搜索数据加载页数
  int searchDataPage = 1;

  // 搜索加载中默认文字
  String searchLoadText = "加载中...";

  // 搜索加载状态
  LoadingStatus searchLoadStatus = LoadingStatus.STATUS_IDEL;

  // 关注数据源
  List<BuddyModel> followList = [];

  // 关注备份数据源
  List<BuddyModel> backupFollowList = [];

  @override
  void initState() {
    super.initState();
    requestBothFollowList();
    _scrollController.addListener(() {
      String atStr = context.read<CommentEnterNotifier>().atSearchStr;
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        if (atStr != null) {
          searchDataPage += 1;
          requestSearchFollowList(atStr);
        } else {
          dataPage += 1;
          requestBothFollowList();
        }
      }
    });
    widgetsBinding = WidgetsBinding.instance;
    widgetsBinding.addPostFrameCallback((callback) {
      FocusScope.of(context).requestFocus(commentFocus);
    });
    _textEditingController.addListener(() {
      // print("值改变了");
      // print("监听文字光标${_textEditingController.selection}");
      // // 每次点击切换光标会进入此监听。需求邀请@和话题光标不可移入其中。
      // print("::::::$isSwitchCursor");
      if (isSwitchCursor) {
        List<Rule> rules = context.read<CommentEnterNotifier>().rules;
        int atIndex = context.read<CommentEnterNotifier>().atCursorIndex;

        // 获取光标位置
        int cursorIndex = _textEditingController.selection.baseOffset;
        for (Rule rule in rules) {
          // 是否光标点击到了@区域
          if (cursorIndex >= rule.startIndex && cursorIndex <= rule.endIndex) {
            // 获取中间值用此方法是因为当atRule.startIndex和atRule.endIndex为负数时不会溢出。
            int median = rule.startIndex + (rule.endIndex - rule.startIndex) ~/ 2;
            TextSelection setCursor;
            if (cursorIndex > median) {
              setCursor = TextSelection(
                baseOffset: rule.endIndex,
                extentOffset: rule.endIndex,
              );
            }
            if (cursorIndex <= median) {
              setCursor = TextSelection(
                baseOffset: rule.startIndex,
                extentOffset: rule.startIndex,
              );
            }
            // 设置光标
            _textEditingController.selection = setCursor;
          }
        }
        // 唤起@#后切换光标关闭视图
        if (cursorIndex != atIndex) {
          context.read<CommentEnterNotifier>().openAtCallback("");
        }
      }
      isSwitchCursor = true;
    });
    _formatter = ReleaseFeedInputFormatter(
      controller: _textEditingController,
      rules: context.read<CommentEnterNotifier>().rules,
      // @回调
      triggerAtCallback: (String str) async {
        context.read<CommentEnterNotifier>().openAtCallback(str);
      },
      // 关闭@#视图回调
      shutDownCallback: () async {
        context.read<CommentEnterNotifier>().openAtCallback("");
      },
      valueChangedCallback:
          (List<Rule> rules, String value, int atIndex, int topicIndex, String atSearchStr, String topicSearchStr) {
        rules = rules;
        // print("输入框值回调：$value");
        // print(rules);
        print("搜索字段");
        print(atSearchStr);
        isSwitchCursor = false;
        if (atIndex > 0) {
          context.read<CommentEnterNotifier>().getAtCursorIndex(atIndex);
        }
        context.read<CommentEnterNotifier>().setAtSearchStr(atSearchStr);
        context.read<CommentEnterNotifier>().changeCallback(value);
        if (atSearchStr != null) {
          searchHasNext = null;
          searchDataPage = 1;
          requestSearchFollowList(atSearchStr);
        } else {
          setState(() {
            followList = backupFollowList;
          });
        }
        // 实时搜索
      },
    );
  }

  /// 获得文本输入框样式
  List<RangeStyle> getTextFieldStyle(List<Rule> rules) {
    List<RangeStyle> result = [];
    for (Rule rule in rules) {
      result.add(
        RangeStyle(
          range: TextRange(start: rule.startIndex, end: rule.endIndex),
          style: TextStyle(color: AppColor.mainBlue),
        ),
      );
    }
    return result.length == 0 ? null : result;
  }

  // 搜索全局用户
  requestSearchFollowList(String keyWork) async {
    print("搜索字段：：：：：：：：$keyWork");
    List<BuddyModel> searchFollowList = [];
    if (searchLoadStatus == LoadingStatus.STATUS_IDEL) {
      // 先设置状态，防止下拉就直接加载
      setState(() {
        searchLoadStatus = LoadingStatus.STATUS_LOADING;
      });
    }

    SearchUserModel model = SearchUserModel();
    if (searchHasNext != 0) {
      model = await ProfileSearchUser(keyWork, 20,lastTime: searchLastTime);
      if (model.list.isNotEmpty && searchDataPage == 1) {
        model.list.forEach((element) {
          BuddyModel followModel = BuddyModel();
          followModel.nickName = element.nickName + " ";
          followModel.uid = element.uid;
          followModel.avatarUri = element.avatarUri;
          searchFollowList.add(followModel);
        });
        if (model.hasNext == 0) {
          searchLoadText = "";
          searchLoadStatus = LoadingStatus.STATUS_COMPLETED;
        }
      }
      if (searchDataPage > 1 && searchLastTime != null) {
        if (model.list.isNotEmpty) {
          model.list.forEach((v) {
            BuddyModel followModel = BuddyModel();
            followModel.nickName = v.nickName + " ";
            followModel.uid = v.uid;
            followModel.avatarUri = v.avatarUri;
            searchFollowList.add(followModel);
          });
          searchLoadStatus = LoadingStatus.STATUS_IDEL;
          searchLoadText = "加载中...";
        }
      }
    }
    // 记录搜索状态
    searchLastTime = model.lastTime;
    searchHasNext = model.hasNext;

    // 列表回到顶部，不然无法上拉加载下一页
    if (searchDataPage == 1) {
      _scrollController.jumpTo(0);
    }
    if (searchHasNext == 0) {
      searchLoadText = "已加载全部好友";
      searchLoadStatus = LoadingStatus.STATUS_COMPLETED;
    }
    // 获取关注@数据
    List<BuddyModel> follow = [];
    backupFollowList.forEach((v) {
      if (v.nickName.contains(keyWork)) {
        follow.add(v);
      }
    });
    // 筛选全局的@用户数据
    List<BuddyModel> filterFollowList = followModelarrayDate(searchFollowList, follow);
    filterFollowList.insertAll(0, follow);
    followList = filterFollowList;
    setState(() {});
  }

  // 请求好友列表
  requestBothFollowList() async {
    if (loadStatus == LoadingStatus.STATUS_IDEL) {
      // 先设置状态，防止下拉就直接加载
      setState(() {
        loadStatus = LoadingStatus.STATUS_LOADING;
      });
    }
    BuddyListModel model = BuddyListModel();
    if (hasNext != 0) {
      model = await GetFollowList(20, lastTime: lastTime);
      if (dataPage == 1) {
        if (model.list.isNotEmpty) {
          followList = model.list;
          followList.forEach((element) {
            element.nickName = element.nickName + " ";
          });
          if (model.hasNext == 0) {
            loadText = "";
            loadStatus = LoadingStatus.STATUS_COMPLETED;
          }
        }
      } else if (dataPage > 1 && lastTime != null) {
        if (model.list.isNotEmpty) {
          model.list.forEach((v) {
            v.nickName = v.nickName + " ";
          });
          followList.addAll(model.list);
          loadStatus = LoadingStatus.STATUS_IDEL;
          loadText = "加载中...";
        }
      }
      // 备份字段赋值
      backupFollowList = followList;
    }
    lastTime = model.lastTime;
    hasNext = model.hasNext;
    if (hasNext == 0) {
      loadText = "已加载全部好友";
      loadStatus = LoadingStatus.STATUS_COMPLETED;
      print("返回不请求数据");
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    List<Rule> rules = context.watch<CommentEnterNotifier>().rules;
    String atStr = context.watch<CommentEnterNotifier>().atSearchStr;
    return Container(
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.only(
            topLeft: context.watch<CommentEnterNotifier>().keyWord != "@" ? Radius.circular(0) : Radius.circular(10),
            topRight: context.watch<CommentEnterNotifier>().keyWord != "@" ? Radius.circular(0) : Radius.circular(10),
          ),
        ),
        child: Stack(
          children: [
            Offstage(
              offstage: context.watch<CommentEnterNotifier>().keyWord != "@",
              child: Container(
                height: 232,
                decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 0.5, color: Color(0xffe5e5e5)))),
                child: ListView.builder(
                    itemCount: followList.length + 1,
                    controller: _scrollController,
                    itemBuilder: (context, index) {
                      if (index == followList.length) {
                        return LoadingView(
                          loadText: atStr != null ? searchLoadText : loadText,
                          loadStatus: atStr != null ? searchLoadStatus : loadStatus,
                        );
                      } else if (index == followList.length + 1) {
                        return Container();
                      } else {
                        return GestureDetector(
                          // 点击空白区域响应事件
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            // At的文字长度
                            int AtLength = followList[index].nickName.length;
                            // 获取输入框内的规则
                            var rules = context.read<CommentEnterNotifier>().rules;
                            // 检测是否添加过
                            if (rules.isNotEmpty) {
                              for (Rule rule in rules) {
                                if (rule.id == followList[index].uid && rule.isAt == true) {
                                  ToastShow.show(msg: "已经添加过了", context: context, gravity: Toast.CENTER);
                                  return;
                                }
                              }
                            }
                            // 获取@的光标
                            int atIndex = context.read<CommentEnterNotifier>().atCursorIndex;
                            // 获取实时搜索文本
                            String searchStr = context.read<CommentEnterNotifier>().atSearchStr;
                            // @前的文字
                            String atBeforeStr = _textEditingController.text.substring(0, atIndex);
                            // @后的文字
                            String atRearStr = "";
                            print(searchStr);
                            print("controller.text:${_textEditingController.text}");
                            print("atBeforeStr$atBeforeStr");
                            if (searchStr != "" || searchStr != null) {
                              print("atIndex:$atIndex");
                              print("searchStr:$searchStr");
                              print("controller.text:${_textEditingController.text}");
                              atRearStr = _textEditingController.text
                                  .substring(atIndex + searchStr.length, _textEditingController.text.length);
                              print("atRearStr:$atRearStr");
                            } else {
                              atRearStr =
                                  _textEditingController.text.substring(atIndex, _textEditingController.text.length);
                            }

                            // 拼接修改输入框的值
                            _textEditingController.text = atBeforeStr + followList[index].nickName + atRearStr;
                            print("controller.text:${_textEditingController.text}");
                            // 这是替换输入的文本修改后面输入的@的规则
                            if (searchStr != "" || searchStr != null) {
                              int oldLength = searchStr.length;
                              int newLength = followList[index].nickName.length;
                              int oldStartIndex = atIndex;
                              int diffLength = newLength - oldLength;
                              for (int i = 0; i < rules.length; i++) {
                                if (rules[i].startIndex >= oldStartIndex) {
                                  int newStartIndex = rules[i].startIndex + diffLength;
                                  int newEndIndex = rules[i].endIndex + diffLength;
                                  rules.replaceRange(i, i + 1, <Rule>[rules[i].copy(newStartIndex, newEndIndex)]);
                                }
                              }
                            }
                            // 此时为了解决后输入的@切换光标到之前输入的@或者#前方，更新之前输入@和#的索引。
                            for (int i = 0; i < rules.length; i++) {
                              // 当最新输入框内的文本对应不上之前的值时。
                              if (rules[i].params !=
                                  _textEditingController.text.substring(rules[i].startIndex, rules[i].endIndex)) {
                                print("进入");
                                print(rules[i]);
                                rules[i] = Rule(rules[i].startIndex + AtLength, rules[i].endIndex + AtLength,
                                    rules[i].params, rules[i].clickIndex, rules[i].isAt, rules[i].id);
                                print(rules[i]);
                              }
                            }
                            // 存储规则
                            context.read<CommentEnterNotifier>().addRules(Rule(atIndex - 1, atIndex + AtLength,
                                "@" + followList[index].nickName, index, true, followList[index].uid));
                            // 设置光标
                            var setCursor = TextSelection(
                              baseOffset: _textEditingController.text.length,
                              extentOffset: _textEditingController.text.length,
                            );
                            print("设置光标${setCursor}");
                            _textEditingController.selection = setCursor;
                            context.read<CommentEnterNotifier>().setAtSearchStr("");
                            // 关闭视图
                            context.read<CommentEnterNotifier>().openAtCallback("");
                          },
                          child: Container(
                            height: 48,
                            width: ScreenUtil.instance.screenWidthDp,
                            margin: EdgeInsets.only(top: index == 0 ? 10 : 0, bottom: 10, left: 16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  backgroundImage: NetworkImage(followList[index].avatarUri),
                                  maxRadius: 19,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  followList[index].nickName,
                                  style: AppStyle.textRegular16,
                                )
                              ],
                            ),
                          ),
                        );
                      }
                    }),
              ),
            ),
            Container(
                width: ScreenUtil.instance.screenWidthDp,
                padding:
                    EdgeInsets.only(top: context.watch<CommentEnterNotifier>().keyWord != "@" ? 12 : 244, bottom: 12),
                child: Stack(
                  children: [
                    Container(
                      width: Platform.isIOS
                          ? ScreenUtil.instance.screenWidthDp - 32
                          : ScreenUtil.instance.screenWidthDp - 32 - 52 - 12,
                      margin: EdgeInsets.only(left: 16, right: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                        color: AppColor.bgWhite.withOpacity(0.65),
                      ),
                      child: Stack(
                        children: [
                          ConstrainedBox(
                            constraints: BoxConstraints(
                                maxHeight: 80.0,
                                minHeight: 16.0,
                                maxWidth: Platform.isIOS
                                    ? ScreenUtil.instance.screenWidthDp - 32 - 32 - 64
                                    : ScreenUtil.instance.screenWidthDp - 32 - 32 - 64 - 52 - 12),
                            child: TextSpanField(
                              controller: _textEditingController,
                              focusNode: commentFocus,
                              // 多行展示
                              keyboardType: TextInputType.multiline,
                              //不限制行数
                              maxLines: null,
                             enableInteractiveSelection: true,
                              // 光标颜色
                              cursorColor: Color.fromRGBO(253, 137, 140, 1),
                              scrollPadding: EdgeInsets.all(0),
                              style: TextStyle(fontSize: 16, color: AppColor.textPrimary1),
                              //内容改变的回调
                              onChanged: (text) {
                                // 存入最新的值
                                context.read<CommentEnterNotifier>().changeCallback(text);
                              },
                              onSubmitted: (text) {
                                if (text != null) {
                                  voidCallback(
                                    text,
                                    rules,
                                    context,
                                  );
                                } else {
                                  ToastShow.show(msg: "不能发送空文本", context: context,gravity: Toast.CENTER);
                                }
                                Navigator.of(context).pop(1);
                              },
                              // onEditingComplete:() {
                              //   print("编辑完成");
                              // },
                              // 装饰器修改外观
                              decoration: InputDecoration(
                                // 去除下滑线
                                border: InputBorder.none,
                                // 提示文本
                                hintText: hintText,
                                // 提示文本样式
                                hintStyle: TextStyle(fontSize: 14, color: AppColor.textHint),
                                // 设置为true,contentPadding才会生效，TextField会有默认高度。
                                isCollapsed: true,
                                contentPadding: EdgeInsets.only(top: 8, bottom: 8, left: 16),
                              ),
                              rangeStyles: getTextFieldStyle(rules),
                              textInputAction: TextInputAction.send,
                              inputFormatters:
                                  inputFormatters == null ? [_formatter] : (inputFormatters..add(_formatter)),
                            ),
                          ),
                          Positioned(
                              right: 16,
                              bottom: 6,
                              child: Container(
                                width: 24,
                                height: 24,
                                color: Colors.redAccent,
                              )),
                          // MyIconBtn()
                        ],
                      ),
                    ),
                    Positioned(
                        right: 16,
                        bottom: 2,
                        child: Offstage(
                          offstage: Platform.isIOS,
                          child: GestureDetector(
                              onTap: () {
                                voidCallback(
                                  _textEditingController.text,
                                  rules,
                                  context,
                                );
                                Navigator.of(context).pop(1);
                              },
                              child: IgnorePointer(
                                // 监听输入框的值==""使外层点击不生效。非""手势生效。
                                ignoring: context.watch<CommentEnterNotifier>().textFieldStr == "",
                                child: Container(
                                    // padding: EdgeInsets.only(top: 6,left: 12,bottom: 6,right: 12),
                                    height: 32,
                                    width: 52,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(Radius.circular(16)),
                                      // 监听输入框的值动态改变样式
                                      color: context.watch<CommentEnterNotifier>().textFieldStr != ""
                                          ? AppColor.textPrimary1
                                          : AppColor.textSecondary,
                                    ),
                                    child: Center(
                                      child: Text(
                                        "发送",
                                        style: TextStyle(color: AppColor.white, fontSize: 14),
                                      ),
                                    )),
                              )),
                        ))
                  ],
                ))
          ],
        ));
  }
}

// 输入框输入文字的监听
class CommentEnterNotifier extends ChangeNotifier {
  CommentEnterNotifier({this.textFieldStr = ""});

  // 输入框输入文字
  String textFieldStr = "";

  // 监听输入框输入的值是否为@切换视图的
  String keyWord = "";

  // 记录@唤醒页面时光标的位置
  int atCursorIndex;

  // 记录规则
  List<Rule> rules = [];

  // @后的实时搜索文本
  String atSearchStr;

  changeCallback(String str) {
    this.textFieldStr = str;
    notifyListeners();
  }

  // 是否开启@视图
  openAtCallback(String str) {
    this.keyWord = str;
    notifyListeners();
  }

  getAtCursorIndex(int atIndex) {
    this.atCursorIndex = atIndex;
    notifyListeners();
  }

  addRules(Rule role) {
    this.rules.add(role);
    notifyListeners();
  }

  setAtSearchStr(String str) {
    this.atSearchStr = str;
    notifyListeners();
  }
}
