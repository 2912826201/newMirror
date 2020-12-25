import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:provider/provider.dart';
import 'package:text_span_field/range_style.dart';
import 'package:text_span_field/text_span_field.dart';

import 'feed/release_feed_input_formatter.dart';

typedef VoidCallback = void Function(String content,List<Rule> rules, BuildContext context);

Future openInputBottomSheet({
  @required BuildContext context,
  @required VoidCallback voidCallback,
  String hintText,
}) async {
  await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      enableDrag: false,
      builder: (BuildContext context) {
        FocusNode _commentFocus = FocusNode();
        return ChangeNotifierProvider(
            create: (_) => CommentEnterNotifier(),
            builder: (context, _) {
              return Container(
                decoration: BoxDecoration(
                  color: AppColor.transparent,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                ),
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

  List<String> stings = ["换行 ", "是撒 ", "阿斯达 ", "奥术大师 ", "奥术大师多 ", "胜多负少 ", "豆腐干豆腐 ", "爽肤水 ", "出现橙 ", "阿斯达 "];

  @override
  void initState() {
    super.initState();
    widgetsBinding = WidgetsBinding.instance;
    widgetsBinding.addPostFrameCallback((callback) {
      FocusScope.of(context).requestFocus(commentFocus);
    });
    _textEditingController.addListener(() {
      print("值改变了");
      print("监听文字光标${_textEditingController.selection}");
      // 每次点击切换光标会进入此监听。需求邀请@和话题光标不可移入其中。
      print("::::::$isSwitchCursor");
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
        print("输入框值回调：$value");
        print(rules);
        isSwitchCursor = false;
        if (atIndex > 0) {
          context.read<CommentEnterNotifier>().getAtCursorIndex(atIndex);
        }
        context.read<CommentEnterNotifier>().setAtSearchStr(atSearchStr);
        context.read<CommentEnterNotifier>().changeCallback(value);
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

  @override
  Widget build(BuildContext context) {
    List<Rule> rules = context.watch<CommentEnterNotifier>().rules;
    return Container(
        child: Stack(
      children: [
        Offstage(
          offstage: context.watch<CommentEnterNotifier>().keyWord != "@",
          child: Container(
            height: 180,
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(width: 0.5, color: Color(0xffe5e5e5))),
            ),
            child: ListView.builder(
                itemCount: stings.length,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Container(
                      height: 10,
                    );
                  } else {
                    return GestureDetector(
                      // 点击空白区域响应事件
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        // At的文字长度
                        int AtLength = stings[index].length;
                        // 获取输入框内的规则
                        var rules = context.read<CommentEnterNotifier>().rules;
                        // 检测是否添加过
                        if (rules.isNotEmpty) {
                          for (Rule rule in rules) {
                            if (rule.clickIndex == index && rule.isAt == true) {
                              print("已经添加过了");
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
                        if (searchStr != "" || searchStr.isNotEmpty) {
                          print("atIndex:$atIndex");
                          print("searchStr:$searchStr");
                          print("controller.text:${_textEditingController.text}");
                          atRearStr = _textEditingController.text.substring(atIndex + searchStr.length, _textEditingController.text.length);
                          print("atRearStr:$atRearStr");
                        } else {
                          atRearStr = _textEditingController.text.substring(atIndex, _textEditingController.text.length);
                        }

                        // 拼接修改输入框的值
                        _textEditingController.text = atBeforeStr + stings[index] + atRearStr;
                        print("controller.text:${_textEditingController.text}");
                        // 这是替换输入的文本修改后面输入的@的规则
                        if (searchStr != "" || searchStr.isNotEmpty) {
                          int oldLength = searchStr.length;
                          int newLength = stings[index].length;
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
                          if (rules[i].params != _textEditingController.text.substring(rules[i].startIndex, rules[i].endIndex)) {
                            print("进入");
                            print(rules[i]);
                            rules[i] = Rule(rules[i].startIndex + AtLength, rules[i].endIndex + AtLength, rules[i].params,
                                rules[i].clickIndex, rules[i].isAt);
                            print(rules[i]);
                          }
                        }
                        // 存储规则
                        context
                            .read<CommentEnterNotifier>()
                            .addRules(Rule(atIndex - 1, atIndex + AtLength, "@" + stings[index], index, true));
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
                        margin: EdgeInsets.only(bottom: 10, left: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(""),
                              maxRadius: 19,
                            ),
                            SizedBox(width: 12),
                            Text(
                              stings[index],
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
            padding: EdgeInsets.only(top: context.watch<CommentEnterNotifier>().keyWord != "@" ? 12 : 192, bottom: 12),
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
                          maxLines: null,
                          //不限制行数
                          // 光标颜色
                          cursorColor: Color.fromRGBO(253, 137, 140, 1),
                          scrollPadding: EdgeInsets.all(0),
                          style: TextStyle(fontSize: 16, color: AppColor.textPrimary1),
                          //内容改变的回调
                          onChanged: (text) {
                            // 存入最新的值
                            context.read<CommentEnterNotifier>().changeCallback(text);
                          },
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
                          inputFormatters: inputFormatters == null ? [_formatter] : (inputFormatters..add(_formatter)),
                        ),
                      ),
                      Positioned(
                        bottom: 6,
                        right: 44,
                        child: Container(
                          width: 24,
                          height: 24,
                          color: Colors.redAccent,
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
                            voidCallback(_textEditingController.text,rules, context,);
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
