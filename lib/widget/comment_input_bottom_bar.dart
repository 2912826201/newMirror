import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/data/model/message/emoji_model.dart';
import 'package:mirror/data/model/profile/buddy_list_model.dart';
import 'package:mirror/data/model/profile/searchuser_model.dart';
import 'package:mirror/page/feed/release_page.dart';
import 'package:mirror/page/home/sub_page/recommend_page.dart';
import 'package:mirror/util/file_util.dart';
import '../page/message/util/emoji_manager.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/text_span_field/range_style.dart';
import 'package:mirror/widget/text_span_field/text_span_field.dart';
import 'package:provider/provider.dart';

import 'custom_button.dart';
import 'dialog.dart';
import 'input_formatter/release_feed_input_formatter.dart';
import 'icon.dart';

typedef VoidCallback = void Function(String content, List<Rule> rules);

Future openInputBottomSheet({
  @required BuildContext buildContext,
  @required VoidCallback voidCallback,
  String hintText,
  bool isShowAt = true,
  bool isShowPostBtn = true,
  // 是否点击纱布
  bool isClickGauze = false,
}) async {
  await showModalBottomSheet(
      isScrollControlled: true,
      context: buildContext,
      enableDrag: false,
      backgroundColor: AppColor.transparent,
      builder: (BuildContext context) {
        FocusNode _commentFocus = FocusNode();
        return ChangeNotifierProvider(
            create: (_) => CommentEnterNotifier(),
            builder: (providerContext, _) {
              return Container(
                child: CommentInputBottomBar(
                  hintText: hintText,
                  isShowAt: isShowAt,
                  isShowPostBtn: isShowPostBtn,
                  voidCallback: voidCallback,
                  commentFocus: _commentFocus,
                  isClickGauze: isClickGauze,
                ),
              );
            });
      }).then((value) {
    isClickGauze = true;
  });
}

class CommentInputBottomBar extends StatefulWidget {
  CommentInputBottomBar(
      {Key key,
      this.voidCallback,
      this.hintText,
      this.commentFocus,
      this.isShowPostBtn,
      this.isShowAt,
      this.isClickGauze})
      : super(key: key);
  final VoidCallback voidCallback;
  String hintText;
  final bool isShowAt;
  final bool isShowPostBtn;
  final FocusNode commentFocus;

  // 是否点击纱布退出
  bool isClickGauze;

  @override
  createState() {
    return CommentInputBottomBarState(voidCallback, hintText, commentFocus);
  }
}

class CommentInputBottomBarState extends State<CommentInputBottomBar> {
  CommentInputBottomBarState(this.voidCallback, this.hintText, this.commentFocus);

  ReleaseFeedInputFormatter _formatter;

  // 判断是否只是切换光标
  bool isSwitchCursor = true;
  final VoidCallback voidCallback;
  String hintText;
  TextEditingController _textEditingController = TextEditingController();
  final FocusNode commentFocus;
  WidgetsBinding widgetsBinding;

  // 滑动监听控制器
  ScrollController _scrollController = ScrollController();

  // 请求下一页
  int lastTime;

  // 是否存在下页
  int hasNext;

  // 加载中默认文字
  String loadText = "加载中...";

  // 加载状态
  LoadingStatus loadStatus = LoadingStatus.STATUS_IDEL;

  // 搜索请求下一页
  int searchLastTime;

  // 搜索是否存在下页
  int searchHasNext;

  // 搜索加载中默认文字
  String searchLoadText = "加载中...";

  // 搜索加载状态
  LoadingStatus searchLoadStatus = LoadingStatus.STATUS_IDEL;

  // 关注数据源
  List<BuddyModel> followList = [];

  // 关注备份数据源
  List<BuddyModel> backupFollowList = [];

  // 是否点击了弹起的@用户列表
  bool isClickAtUser = false;

  // 是否点击了@icon
  bool isClickAtIcon = false;

  ///表情的列表
  List<EmojiModel> emojiModelList = <EmojiModel>[];

  // 记录唤起表情前的光标位置
  int emojiCursorPosition;

  // 键盘底部偏移
  double keyboardMaxBottom = 0.0;
  double keyboardMinBottom = 0.0;

  // 是否渲染了第一帧
  bool isPostFrameCallback = false;

  /// 控件的key
  GlobalKey _inputBoxKey = GlobalKey();

  // 是否退出
  bool isPop = false;

  // 是否点击emoji
  bool isClickEmoji = false;

  @override
  void initState() {
    super.initState();
    /*inputFormatters.add(ExpressionTeamDeleteFormatter());*/
    requestBothFollowList();
    getEmojiData();
    _scrollController.addListener(() {
      String atStr = context.read<CommentEnterNotifier>().atSearchStr;
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        if (atStr != null && atStr.isNotEmpty) {
          requestSearchFollowList(atStr);
        } else {
          requestBothFollowList();
        }
      }
    });
    widgetsBinding = WidgetsBinding.instance;
    // 在控件渲染完成后执行的回调
    widgetsBinding.addPostFrameCallback((callback) {
      print("进入");
      FocusScope.of(context).requestFocus(commentFocus);
      _findRenderObject();
      isPostFrameCallback = true;
    });
    _textEditingController.addListener(() {
      // print("值改变了");
      print("监听文字光标${_textEditingController.selection}");
      List<Rule> rules = context.read<CommentEnterNotifier>().rules;
      int atIndex = 0;
      if (context.read<CommentEnterNotifier>().atCursorIndexs.length > 0) {
        atIndex = context.read<CommentEnterNotifier>().atCursorIndexs.first.index;
      }
      print("当前值￥${_textEditingController.text}");
      print(context.read<CommentEnterNotifier>().textFieldStr);
      // 获取光标位置
      int cursorIndex = _textEditingController.selection.baseOffset;
      print("实时光标位置$cursorIndex");
      // 点击@图标
      if (isClickAtIcon) {
        var setCursor = TextSelection(
          baseOffset: atIndex,
          extentOffset: atIndex,
        );
        _textEditingController.selection = setCursor;
      }
      // 在每次选择@用户后ios设置光标位置。
      if (Platform.isIOS && isClickAtUser) {
        // 设置光标
        var setCursor = TextSelection(
          baseOffset: _textEditingController.text.length,
          extentOffset: _textEditingController.text.length,
        );
        _textEditingController.selection = setCursor;
        print("调整了光标：：：${_textEditingController.selection}");
      }
      if (Platform.isAndroid && isClickAtUser) {
        print("at位置&${atIndex}");
        var setCursor = TextSelection(
          baseOffset: atIndex,
          extentOffset: atIndex,
        );
        _textEditingController.selection = setCursor;
      }
      isClickAtUser = false;
      isClickAtIcon = false;
      // // 安卓每次点击切换光标会进入此监听。需求邀请@和话题光标不可移入其中。
      if (isSwitchCursor && !Platform.isIOS) {
        // _textEditingController.o
        for (Rule rule in rules) {
          // 是否光标点击到了@区域
          if (cursorIndex >= rule.startIndex && cursorIndex <= rule.endIndex) {
            // 获取中间值用此方法是因为当atRule.startIndex和atRule.endIndex为负数时不会溢出。
            int median = rule.startIndex + (rule.endIndex - rule.startIndex) ~/ 2;
            TextSelection setCursor;
            if (cursorIndex <= median) {
              setCursor = TextSelection(
                baseOffset: rule.startIndex,
                extentOffset: rule.startIndex,
              );
            }
            if (cursorIndex > median) {
              setCursor = TextSelection(
                baseOffset: rule.endIndex,
                extentOffset: rule.endIndex,
              );
            }
            // 设置光标
            _textEditingController.selection = setCursor;
            print("设置了光标了++++++++++++++++++++++++++++++++++++${_textEditingController.selection}");
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
      atCursorIndexs: context.read<CommentEnterNotifier>().atCursorIndexs,
      isMonitorTop: false,
      controller: _textEditingController,
      rules: context.read<CommentEnterNotifier>().rules,
      maxNumberOfBytes: 600,
      context: context,
      // @回调
      triggerAtCallback: (String str) async {
        if (widget.isShowAt) {
          context.read<CommentEnterNotifier>().openAtCallback(str);
          isClickAtUser = false;
        }
        return "";
      },
      // 关闭@#视图回调
      shutDownCallback: () async {
        print('----------------------------关闭视图');
        context.read<CommentEnterNotifier>().openAtCallback("");
      },
      valueChangedCallback: (List<Rule> rules, String value, int atIndex, int topicIndex, String atSearchStr,
          String topicSearchStr, bool add) {
        print("输入框值回调：$value  $atIndex");
        print(value.length);
        print(rules);
        print("搜索字段");
        print(atSearchStr);
        isSwitchCursor = false;
        if (atIndex > 0) {
          context.read<CommentEnterNotifier>().getAtCursorIndex(atIndex);
        }
        context.read<CommentEnterNotifier>().setAtSearchStr(atSearchStr);
        context.read<CommentEnterNotifier>().changeCallback(value);
        if (atSearchStr != null && atSearchStr.isNotEmpty) {
          searchHasNext = null;
          searchLastTime = null;
          searchLoadStatus = LoadingStatus.STATUS_IDEL;
          searchLoadText = "加载中...";
          requestSearchFollowList(atSearchStr);
        } else {
          if (backupFollowList.isNotEmpty) {
            setState(() {
              followList = backupFollowList;
            });
          }
        }
        // 实时搜索
      },
    );
  }

// 获取到最大偏移和最小偏移
  _findRenderObject() {
    RenderBox renderBox = _inputBoxKey.currentContext.findRenderObject();
    var vector3 = renderBox.getTransformTo(null)?.getTranslation();
    print("vector3:::$vector3");
    print(vector3.y);
    if (keyboardMaxBottom < vector3.y) {
      keyboardMaxBottom = vector3.y;
    }
    if (keyboardMinBottom == 0.0) {
      keyboardMinBottom = vector3.y;
    }
    if (keyboardMinBottom == keyboardMaxBottom) {
      if (keyboardMaxBottom > vector3.y) {
        keyboardMinBottom = vector3.y;
      }
    }
    print("0000000000");
    print("keyboardMaxBottom :::$keyboardMaxBottom,,,,keyboardMinBottom :: $keyboardMinBottom");
  }

  /// 获得文本输入框样式
  List<RangeStyle> getTextFieldStyle(List<Rule> rules) {
    print("展示高亮");
    print("rules:::${rules.toString()}");
    List<RangeStyle> result = [];
    for (Rule rule in rules) {
      result.add(
        RangeStyle(
          range: TextRange(start: rule.startIndex, end: rule.endIndex),
          style: AppStyle.blueRegular16,
        ),
      );
    }
    return result.length == 0 ? null : result;
  }

  // 获取表情数据
  getEmojiData() async {
    //获取表情的数据
    emojiModelList = await EmojiManager.getEmojiModelList();
    print("emojiModelList:${emojiModelList.length}");
  }

  // 搜索全局用户
  requestSearchFollowList(String keyWork) async {
    print("搜索字段：：：：：：：：$keyWork");
    List<BuddyModel> searchFollowList = [];
    // 列表回到顶部，不然无法上拉加载下一页
    if (searchHasNext == null) {
      setState(() {
        _scrollController.jumpTo(0);
      });
    }
    if (searchHasNext != 0) {
      if (searchLoadStatus == LoadingStatus.STATUS_IDEL) {
        // 先设置状态，防止下拉就直接加载
        setState(() {
          searchLoadStatus = LoadingStatus.STATUS_LOADING;
        });
      }

      SearchUserModel model = SearchUserModel();
      model = await ProfileSearchUser(keyWork, 20, lastTime: searchLastTime);
      if (model != null) {
        searchLastTime = model.lastTime;
        searchHasNext = model.hasNext;

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
    }
    if (searchHasNext == 0) {
      if (followList.length > 0) {
        searchLoadText = "已加载全部好友";
        searchLoadStatus = LoadingStatus.STATUS_COMPLETED;
      } else {
        searchLoadText = "";
        searchLoadStatus = LoadingStatus.STATUS_IDEL;
      }
    }
    if (mounted) {
      setState(() {});
    }
  }

  // 请求好友列表
  requestBothFollowList() async {
    if (hasNext != 0) {
      if (loadStatus == LoadingStatus.STATUS_IDEL) {
        // 先设置状态，防止下拉就直接加载
        setState(() {
          loadStatus = LoadingStatus.STATUS_LOADING;
        });
      }
      BuddyListModel model = BuddyListModel();

      model = await GetFollowList(20, lastTime: lastTime);
      if (model != null) {
        lastTime = model.lastTime;
        hasNext = model.hasNext;
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
    if (hasNext == 0) {
      if (followList.isNotEmpty) {
        loadText = "已加载全部好友";
        loadStatus = LoadingStatus.STATUS_COMPLETED;
      } else {
        loadText = "";
        loadStatus = LoadingStatus.STATUS_IDEL;
      }
      print("返回不请求数据");
    }

    Future.delayed(Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {});
      }
    });
  }

  // 计算输入框偏移值
  double returnInputOffset(bool _emojiState) {
    double offset = 0.0;
    if (_emojiState) {
      offset = 12 + Application.keyboardHeightIfPage;
    } else {
      if (MediaQuery.of(context).viewInsets.bottom == 0 && Platform.isIOS) {
        offset = ScreenUtil.instance.bottomBarHeight + 12;
      } else {
        offset = 12;
      }
    }
    return offset;
  }

  @override
  Widget build(BuildContext context) {
    print("111111111111111111111");
    List<Rule> rules = context.watch<CommentEnterNotifier>().rules;
    print("222222222222222222222");
    String atStr = context.watch<CommentEnterNotifier>().atSearchStr;
    print("键盘高度${MediaQuery.of(context).viewInsets.bottom}");
    print("11:${context.watch<CommentEnterNotifier>().isCloseKeyboard}");
    // 每次都获取最小的键盘偏移
    if (isPostFrameCallback) {
      if (keyboardMinBottom > _inputBoxKey.currentContext.findRenderObject().getTransformTo(null)?.getTranslation().y) {
        keyboardMinBottom = _inputBoxKey.currentContext.findRenderObject().getTransformTo(null)?.getTranslation().y;
      }
    }
    // 当偏移大于最小偏移时说明键盘是弹起中或者弹起状态设置 就需要关闭键盘
    if (isPostFrameCallback &&
        _inputBoxKey.currentContext.findRenderObject().getTransformTo(null)?.getTranslation().y > keyboardMinBottom) {
      context.watch<CommentEnterNotifier>().isCloseKeyboard = true;
    }
    // 当键盘高度为0时就是收起键盘，并且在绘制第一帧之后这是为了处理GlobalKey的绑定，在绘制第一帧内获取了键盘的最大y轴keyboardMaxBottom，使用在收起时走build在获取会比keyboardMaxBottom小，当点击的是外层纱布不能进入防止重复Pop,
    // 设置isPop是同理。
    if (MediaQuery.of(context).viewInsets.bottom == 0.0 &&
        !isPop &&
        isPostFrameCallback &&
        _inputBoxKey.currentContext.findRenderObject().getTransformTo(null)?.getTranslation().y < keyboardMaxBottom &&
        !widget.isClickGauze &&
        context.watch<CommentEnterNotifier>().isCloseKeyboard) {
      isPop = true;
      print("就退出一次啊${widget.isClickGauze}");
      Navigator.of(context).pop();
    }
    return mounted
        ? Container(
            padding: EdgeInsets.only(
                bottom:
                    context.watch<CommentEnterNotifier>().emojiState ? 0.0 : MediaQuery.of(context).viewInsets.bottom),
            decoration: BoxDecoration(
              color: AppColor.layoutBgGrey,
              borderRadius: BorderRadius.only(
                topLeft:
                    context.watch<CommentEnterNotifier>().keyWord != "@" ? Radius.circular(0) : Radius.circular(10),
                topRight:
                    context.watch<CommentEnterNotifier>().keyWord != "@" ? Radius.circular(0) : Radius.circular(10),
              ),
            ),
            child: Stack(
              children: [
                Offstage(
                  offstage: context.watch<CommentEnterNotifier>().keyWord != "@",
                  child: Container(
                    height: 232,
                    decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(width: 0.5, color: AppColor.dividerWhite8))),
                    child: ListView.builder(
                        itemCount: followList.length + 1,
                        controller: _scrollController,
                        itemBuilder: (context, index) {
                          if (index == followList.length) {
                            return LoadingView(
                              loadText: atStr != null && atStr.isNotEmpty ? searchLoadText : loadText,
                              loadStatus: atStr != null && atStr.isNotEmpty ? searchLoadStatus : loadStatus,
                            );
                          } else if (index == followList.length + 1) {
                            return Container();
                          } else {
                            return GestureDetector(
                              // 点击空白区域响应事件
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                isClickAtUser = true;
                                // At的文字长度
                                int AtLength = followList[index].nickName.length;
                                // 获取输入框内的规则
                                var rules = context.read<CommentEnterNotifier>().rules;
                                // 检测是否添加过
                                if (rules.isNotEmpty) {
                                  for (Rule rule in rules) {
                                    if (rule.id == followList[index].uid && rule.isAt == true) {
                                      ToastShow.show(msg: "你已经@过Ta啦！", context: context, gravity: Toast.CENTER);
                                      return;
                                    }
                                  }
                                }
                                // 获取@的光标
                                int atIndex = 0;
                                if (context.read<CommentEnterNotifier>().atCursorIndexs.length > 0) {
                                  atIndex = context.read<CommentEnterNotifier>().atCursorIndexs.first.index;
                                }
                                // 获取实时搜索文本
                                String searchStr = context.read<CommentEnterNotifier>().atSearchStr;
                                // @前的文字
                                String atBeforeStr = _textEditingController.text.substring(0, atIndex);
                                // @后的文字
                                String atRearStr = "";
                                print(searchStr);
                                print("controller.text:${_textEditingController.text}");
                                print("atBeforeStr$atBeforeStr");
                                // isSwitchCursor = false;
                                if (searchStr != "" && searchStr != null && searchStr.isNotEmpty) {
                                  print("atIndex:$atIndex");
                                  print("searchStr:$searchStr");
                                  // isSwitchCursor = false;
                                  print("controller.text:${_textEditingController.text}");
                                  atRearStr = _textEditingController.text
                                      .substring(atIndex + searchStr.length, _textEditingController.text.length);
                                  print("atRearStr:$atRearStr");
                                } else {
                                  atRearStr = _textEditingController.text
                                      .substring(atIndex, _textEditingController.text.length);
                                }

                                // 拼接修改输入框的值
                                _textEditingController.text = atBeforeStr + followList[index].nickName + atRearStr;
                                // ios赋值设置了光标后会走addListener监听，但是在监听内打印光标位置 获取为0，安卓不会出现此问题 所有iOS没必要在此设置光标位置。
                                if (!Platform.isIOS) {
                                  // 设置光标
                                  var setCursor = TextSelection(
                                    baseOffset: _textEditingController.text.length,
                                    extentOffset: _textEditingController.text.length,
                                  );
                                  _textEditingController.selection = setCursor;
                                }
                                context
                                    .read<CommentEnterNotifier>()
                                    .changeCallback(atBeforeStr + followList[index].nickName + atRearStr);
                                // isSwitchCursor = false;
                                print("controller.text:${_textEditingController.text}");
                                // 这是替换输入的文本修改后面输入的@的规则
                                if (searchStr != "" && searchStr != null && searchStr.isNotEmpty) {
                                  print("搜索文本searchStr：：：$searchStr");
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
                                    print("进入更新后输入的");
                                    print(rules[i]);
                                    rules[i] = Rule(rules[i].startIndex + AtLength, rules[i].endIndex + AtLength,
                                        rules[i].params, rules[i].clickIndex, rules[i].isAt, rules[i].id);
                                    print(rules[i]);
                                  }
                                }
                                // 存储规则
                                context.read<CommentEnterNotifier>().addRules(Rule(atIndex - 1, atIndex + AtLength,
                                    "@" + followList[index].nickName, index, true, followList[index].uid));

                                print("设置光标${_textEditingController.selection}");

                                // isSwitchCursor = false;
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
                                    ClipOval(
                                      child: CachedNetworkImage(
                                        width: 38,
                                        height: 38,

                                        /// imageUrl的淡入动画的持续时间。
                                        // fadeInDuration: Duration(milliseconds: 0),
                                        imageUrl: FileUtil.getSmallImage(followList[index].avatarUri) ?? "",
                                        fit: BoxFit.cover,
                                        // 调整磁盘缓存中图像大小
                                        // maxHeightDiskCache: 150,
                                        // maxWidthDiskCache: 150,
                                        // 指定缓存宽高
                                        memCacheWidth: 150,
                                        memCacheHeight: 150,
                                        placeholder: (context, url) => Container(
                                          color: AppColor.imageBgGrey,
                                        ),
                                        errorWidget: (context, url, e) {
                                          return Container(
                                            color: AppColor.imageBgGrey,
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      followList[index].nickName,
                                      style: AppStyle.whiteRegular16,
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
                    width: ScreenUtil.instance.width,
                    padding: EdgeInsets.only(
                      top: context.watch<CommentEnterNotifier>().keyWord != "@" ? 12 : 244,
                      bottom: returnInputOffset(context.watch<CommentEnterNotifier>().emojiState),
                      // MediaQuery.of(context).viewInsets.bottom == 0 && Platform.isIOS
                      //     ? ScreenUtil.instance.bottomBarHeight + 12
                      //     : 12
                    ),
                    child: Stack(
                      children: [
                        Container(
                          key: _inputBoxKey,
                          width: Platform.isIOS
                              ? ScreenUtil.instance.width - 32
                              : ScreenUtil.instance.width - 32 - (widget.isShowPostBtn ? 52 + 12 : 0),
                          margin: const EdgeInsets.only(left: 16, right: 16),
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(Radius.circular(16)),
                            color: AppColor.mainBlack,
                          ),
                          child: Stack(
                            children: [
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                    maxHeight: 80.0,
                                    minHeight: 16.0,
                                    maxWidth: Platform.isIOS
                                        ? ScreenUtil.instance.screenWidthDp - 32 - 76
                                        : ScreenUtil.instance.screenWidthDp -
                                            32 -
                                            76 -
                                            (widget.isShowPostBtn ? 52 + 12 : 0)),
                                child: TextSpanField(
                                  controller: _textEditingController,
                                  focusNode: commentFocus,
                                  // 多行展示
                                  keyboardType: TextInputType.multiline,
                                  //不限制行数
                                  maxLines: null,
                                  enableInteractiveSelection: true,
                                  // 光标颜色
                                  cursorColor: AppColor.white,
                                  readOnly: context.watch<CommentEnterNotifier>().emojiState,
                                  showCursor: true,
                                  scrollPadding: EdgeInsets.all(0),
                                  style: AppStyle.whiteRegular16,
                                  //内容改变的回调
                                  onChanged: (text) {
                                    // 存入最新的值
                                    context.read<CommentEnterNotifier>().changeCallback(text);
                                  },
                                  onSubmitted: (text) {
                                    if (text.trim().length == 0) {
                                      showAppDialog(context,
                                          title: "提示",
                                          info: "字数不能为空",
                                          confirm: AppDialogButton("我知道了", () {
                                            return true;
                                          }));
                                    } else {
                                      print("text______________________$text");
                                      voidCallback(
                                        text,
                                        rules,
                                      );
                                      Navigator.of(context).pop();
                                    }
                                    // if (text != null) {
                                    //
                                    // } else {
                                    //   ToastShow.show(msg: "不能发送空文本", context: context, gravity: Toast.CENTER);
                                    // }
                                  },
                                  onTap: () {
                                    // 开启键盘关闭表情
                                    // if (!commentFocus.hasFocus) {
                                    context.read<CommentEnterNotifier>().openEmojiCallback(false);
                                    context.read<CommentEnterNotifier>().setIsCloseKeyboard(false);
                                    // }
                                  },
                                  // 装饰器修改外观
                                  decoration: InputDecoration(
                                    // 去除下滑线
                                    border: InputBorder.none,
                                    // 提示文本
                                    hintText: hintText,
                                    // 提示文本样式
                                    hintStyle: AppStyle.text1Regular14,
                                    // 设置为true,contentPadding才会生效，TextField会有默认高度。
                                    isCollapsed: true,
                                    contentPadding: EdgeInsets.only(top: 8, bottom: 8, left: 16),
                                  ),

                                  rangeStyles: getTextFieldStyle(rules),
                                  textInputAction: TextInputAction.send,
                                  inputFormatters: [_formatter],
                                ),
                              ),
                              Positioned(
                                  right: 44,
                                  bottom: 6,
                                  child: Visibility(
                                    visible: widget.isShowAt,
                                    child: AppIconButton(
                                      onTap: () {
                                        isClickAtIcon = true;
                                        followList = backupFollowList;
                                        // 输入的文字
                                        String text = _textEditingController.text;
                                        // 获取光标位置
                                        int cursorIndex = 0;
                                        // 在点击表情时关闭了
                                        cursorIndex = _textEditingController.selection.baseOffset;
                                        if (cursorIndex >= 0) {
                                          print("cursorIndex关闭：${cursorIndex}");
                                          context.read<CommentEnterNotifier>().getAtCursorIndex(cursorIndex + 1);
                                          _textEditingController.text = text.substring(0, cursorIndex) +
                                              "@" +
                                              text.substring(cursorIndex, text.length);
                                        }
                                        // 这里文本会添加一个@,如果存在高亮和之前对不上需要加上一个@的长度
                                        if (rules.isNotEmpty) {
                                          // @符合的长度
                                          int AtLength = 1;
                                          print(rules.toString());
                                          for (int i = 0; i < rules.length; i++) {
                                            // 当最新输入框内的文本对应不上之前的值时。
                                            if (rules[i].params !=
                                                _textEditingController.text
                                                    .substring(rules[i].startIndex, rules[i].endIndex)) {
                                              print("进入更新后输入的");
                                              print(rules[i]);
                                              rules[i] = Rule(
                                                  rules[i].startIndex + AtLength,
                                                  rules[i].endIndex + AtLength,
                                                  rules[i].params,
                                                  rules[i].clickIndex,
                                                  rules[i].isAt,
                                                  rules[i].id);
                                              print(rules[i]);
                                            }
                                          }
                                          print(rules.toString());
                                        }
                                        context.read<CommentEnterNotifier>().openAtCallback("@");
                                        context
                                            .read<CommentEnterNotifier>()
                                            .changeCallback(_textEditingController.text);
                                        context.read<CommentEnterNotifier>().setAtSearchStr("");
                                      },
                                      iconSize: 24,
                                      svgName: AppIcon.input_at,
                                      iconColor: AppColor.textWhite60,
                                    ),
                                  )),
                              Positioned(
                                right: 16,
                                bottom: 6,
                                child: AppIconButton(
                                  onTap: () {
                                    // 隐藏@视图
                                    context.read<CommentEnterNotifier>().openAtCallback("");
                                    // 获取光标位置
                                    emojiCursorPosition = _textEditingController.selection.baseOffset;
                                    print("点击emojiIcon时的光标位置：：：$emojiCursorPosition");
                                    // 显示表情刷新Ui
                                    context.read<CommentEnterNotifier>().openEmojiCallback(true);
                                    context.read<CommentEnterNotifier>().setIsCloseKeyboard(false);
                                  },
                                  iconSize: 24,
                                  svgName: AppIcon.input_emotion,
                                  iconColor: AppColor.textWhite60,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Visibility(
                          visible: widget.isShowPostBtn,
                          child: Positioned(
                              right: 16,
                              bottom: 2,
                              child: Offstage(
                                  offstage: Platform.isIOS,
                                  // child: GestureDetector(
                                  // onTap: () {
                                  //   if (_textEditingController.text.trim().length == 0) {
                                  //     showAppDialog(context,
                                  //         title: "提示",
                                  //         info: "字数不能为空",
                                  //         confirm: AppDialogButton("我知道了", () {
                                  //           return true;
                                  //         }));
                                  //   } else {
                                  //     voidCallback(
                                  //       _textEditingController.text,
                                  //       rules,
                                  //     );
                                  //     Navigator.of(context).pop();
                                  //   }
                                  // voidCallback(
                                  //   _textEditingController.text,
                                  //   rules,
                                  // );
                                  // Navigator.of(context).pop(1);
                                  // },
                                  // child: IgnorePointer(
                                  //     // 监听输入框的值==""使外层点击不生效。非""手势生效。
                                  //     ignoring: context.watch<CommentEnterNotifier>().textFieldStr == "",
                                  child: CustomYellowButton(
                                    "发送",
                                    context.watch<CommentEnterNotifier>().textFieldStr != "" ? 0 : 3,
                                    () {
                                      if (_textEditingController.text.trim().length == 0) {
                                        showAppDialog(context,
                                            title: "提示",
                                            info: "字数不能为空",
                                            confirm: AppDialogButton("我知道了", () {
                                              return true;
                                            }));
                                      } else {
                                        voidCallback(
                                          _textEditingController.text,
                                          rules,
                                        );
                                        Navigator.of(context).pop();
                                      }
                                    },
                                    width: 52,
                                    height: 32,
                                  )
                                  // Container(
                                  //     // padding: EdgeInsets.only(top: 6,left: 12,bottom: 6,right: 12),
                                  //     height: 32,
                                  //     width: 52,
                                  //     decoration: BoxDecoration(
                                  //       borderRadius: const BorderRadius.all(Radius.circular(16)),
                                  //       // 监听输入框的值动态改变样式
                                  //       color: context.watch<CommentEnterNotifier>().textFieldStr != ""
                                  //           ? AppColor.mainYellow
                                  //           : AppColor.textSecondary,
                                  //     ),
                                  //     child: Center(
                                  //       child: const Text(
                                  //         "发送",
                                  //         style: TextStyle(color: AppColor.black, fontSize: 14),
                                  //       ),
                                  //     )),
                                  // )),
                                  )),
                        )
                      ],
                    )),
                Visibility(
                    visible: context.watch<CommentEnterNotifier>().emojiState,
                    child: Positioned(
                      bottom: 0,
                      child: bottomSettingBox(),
                    )),
              ],
            ))
        : Container();
    //   Container(
    //     color: AppColor.mainRed,
    //     width: ScreenUtil.instance.width,
    //     height: 20,
    //     key: _inputBoxKey,
    //   )
    // ],
    // );
  }

//键盘与表情的框
  Widget bottomSettingBox() {
    return Container(
      color: AppColor.layoutBgGrey,
      child: Stack(
        children: [
          emoji(),
        ],
      ),
    );
  }

  //表情框
  Widget emoji() {
    double emojiHeight = Application.keyboardHeightIfPage;
    return Container(
      height: emojiHeight,
      width: ScreenUtil.instance.width,
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColor.dividerWhite8, width: 0.2),
        ),
      ),
      child: emojiList(),
    );
  }

  //emoji具体是什么界面
  Widget emojiList() {
    if (emojiModelList == null || emojiModelList.length < 1) {
      return Center(
        child: const Text("暂无表情"),
      );
    } else {
      return GestureDetector(
        child: Container(
          width: double.infinity,
          // color: AppColor.transparent,
          child: Column(
            children: [
              Expanded(
                  child: SizedBox(
                child: _emojiGridTop(),
              )),
            ],
          ),
        ),
        onTap: () {},
      );
    }
  }

  //获取表情头部的 内嵌的表情
  Widget _emojiGridTop() {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
      child: GridView.builder(
        physics: BouncingScrollPhysics(),
        itemCount: emojiModelList.length,
        gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8, crossAxisSpacing: 1, mainAxisSpacing: 1),
        itemBuilder: (context, index) {
          return _emojiGridItem(emojiModelList[index], index);
        },
      ),
    );
  }

  //每一个_emojiGridItem
  Widget _emojiGridItem(EmojiModel emojiModel, int index) {
    TextStyle textStyle = const TextStyle(
      fontSize: 24,
    );
    return Material(
        color: AppColor.layoutBgGrey,
        child: new InkWell(
          child: Container(
            alignment: Alignment.center,
            child: Text(
              emojiModel.emoji,
              style: textStyle,
            ),
          ),
          onTap: () {
            // 表情光标改动前的位置
            int changeFrontPosition = emojiCursorPosition ?? 0;
            print("changeFrontPosition:1:$changeFrontPosition");
            // 获取输入框内的规则
            var rules = context.read<CommentEnterNotifier>().rules;

            if (emojiCursorPosition != null) {
              print("光标前文字：：：：${_textEditingController.text.substring(0, emojiCursorPosition)}");
              print("当前选择emoji::::${emojiModel.code}");
              print(
                  "光标后文字：：：：${_textEditingController.text.substring(emojiCursorPosition, _textEditingController.text.length)}");
              _textEditingController.text = _textEditingController.text.substring(0, emojiCursorPosition) +
                  emojiModel.code +
                  _textEditingController.text.substring(emojiCursorPosition, _textEditingController.text.length);
            } else {
              _textEditingController.text += emojiModel.code;
            }
            context.read<CommentEnterNotifier>().changeCallback(_textEditingController.text);
            // 记录新的emoji光标位置
            emojiCursorPosition = emojiCursorPosition + emojiModel.code.length;

            var setCursor = TextSelection(
              baseOffset: emojiCursorPosition,
              extentOffset: emojiCursorPosition,
            );
            _textEditingController.selection = setCursor;

            print(emojiModel.code.length);
            print("emojiCursorPosition:$emojiCursorPosition");
            // 这是替换输入的文本修改后面输入的@的规则
            if (rules.isNotEmpty) {
              print("不为空");
              print("changeFrontPosition:2:$changeFrontPosition");
              int diffLength = emojiCursorPosition - changeFrontPosition;
              print("diffLength:$diffLength");
              print(rules.toString());
              for (int i = 0; i < rules.length; i++) {
                if (rules[i].startIndex >= changeFrontPosition) {
                  print("改光标了————————————————————————");
                  int newStartIndex = rules[i].startIndex + diffLength;
                  int newEndIndex = rules[i].endIndex + diffLength;
                  rules.replaceRange(i, i + 1, <Rule>[rules[i].copy(newStartIndex, newEndIndex)]);
                }
              }
              print(rules.toString());
              print(_textEditingController.text);
            }
          },
        ));
  }
}

// 输入框输入文字的监听
class CommentEnterNotifier extends ChangeNotifier {
  CommentEnterNotifier({this.textFieldStr = ""});

  ///是否显示表情
  bool emojiState = false;

  // 输入框输入文字
  String textFieldStr = "";

  // 监听输入框输入的值是否为@切换视图的
  String keyWord = "";

  // 记录@唤醒页面时光标的位置
  List<AtIndex> atCursorIndexs = [];

  // 记录规则
  List<Rule> rules = [];

  // @后的实时搜索文本
  String atSearchStr;

  // 是否需要关闭键盘
  bool isCloseKeyboard = true;

  changeCallback(String str) {
    this.textFieldStr = str;
    notifyListeners();
  }

  // 是否开启@视图
  openAtCallback(String str) {
    this.keyWord = str;
    notifyListeners();
  }

  // getAtCursorIndex(int atIndex) {
  //   this.atCursorIndex = atIndex;
  //   print("this.atCursorIndex::￥${this.atCursorIndex}");
  //   notifyListeners();
  // }
  getAtCursorIndex(int atIndex) {
    this.atCursorIndexs.clear();
    AtIndex ind = AtIndex(atIndex);
    this.atCursorIndexs.add(ind);
    notifyListeners();
  }

  addRules(Rule role) {
    this.rules.add(role);
    notifyListeners();
  }

  replaceRules(List<Rule> roles) {
    this.rules = roles;
    notifyListeners();
  }

  setAtSearchStr(String str) {
    if (str.length == 0) {
      print("大啊大大大");
      print(str.toString());
    }
    this.atSearchStr = str;
    notifyListeners();
  }

  openEmojiCallback(bool isOpen) {
    this.emojiState = isOpen;
    notifyListeners();
  }

  setIsCloseKeyboard(bool isClose) {
    this.isCloseKeyboard = isClose;
    notifyListeners();
  }
}
