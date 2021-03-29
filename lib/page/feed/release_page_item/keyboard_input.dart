// 动态输入框

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/api/topic/topic_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/data_response_model.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/data/model/profile/buddy_list_model.dart';
import 'package:mirror/data/model/profile/searchuser_model.dart';
import 'package:mirror/page/feed/release_page.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/feed/release_feed_input_formatter.dart';
import 'package:mirror/widget/text_span_field/range_style.dart';
import 'package:mirror/widget/text_span_field/text_span_field.dart';
import 'package:provider/provider.dart';
import 'dart:io';

class KeyboardInput extends StatefulWidget {
  final List<TextInputFormatter> inputFormatters;
  TextEditingController controller;

  KeyboardInput({this.inputFormatters, this.controller});

  @override
  KeyboardInputState createState() => KeyboardInputState();
}

class KeyboardInputState extends State<KeyboardInput> {
  ReleaseFeedInputFormatter _formatter;
  FocusNode commentFocus;
  bool isFirst = true;

// 判断是否只是切换光标
  bool isSwitchCursor = true;

  @override
  void initState() {
    widget.controller.addListener(() {
      print("值改变了");
      print("监听文字光标${widget.controller.selection}");
      // // 每次点击切换光标会进入此监听。需求邀请@和话题光标不可移入其中。
      // print("::::::$isSwitchCursor");
      List<Rule> rules = context.read<ReleaseFeedInputNotifier>().rules;
      int atIndex = context.read<ReleaseFeedInputNotifier>().atCursorIndex;
      int topicIndex = context.read<ReleaseFeedInputNotifier>().topicCursorIndex;
      // 是否点击了@列表
      bool isClickAtUser = context.read<ReleaseFeedInputNotifier>().isClickAtUser;
      // 是否点击了话题列表
      bool isClickTopic = context.read<ReleaseFeedInputNotifier>().isClickTopic;

      // 在每次选择@用户后ios设置光标位置。
      if (Platform.isIOS && isClickAtUser) {
        print("@改光标");
        // 设置光标
        var setCursor = TextSelection(
          baseOffset: widget.controller.text.length,
          extentOffset: widget.controller.text.length,
        );
        widget.controller.selection = setCursor;
      }
      context.read<ReleaseFeedInputNotifier>().setClickAtUser(false);
      if (Platform.isIOS && isClickTopic) {
        // 设置光标
        var setCursor = TextSelection(
          baseOffset: widget.controller.text.length,
          extentOffset: widget.controller.text.length,
        );
        widget.controller.selection = setCursor;
      }
      print("监听文字光标${widget.controller.selection}");
      context.read<ReleaseFeedInputNotifier>().setClickTopic(false);
      if (isSwitchCursor && !Platform.isIOS) {
        // 获取光标位置
        int cursorIndex = widget.controller.selection.baseOffset;
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
            widget.controller.selection = setCursor;
          }
        }
        // 唤起@#后切换光标关闭视图
        if (atIndex != null && cursorIndex != atIndex) {
          context.read<ReleaseFeedInputNotifier>().changeCallback("");
        }
        if (topicIndex != null && cursorIndex != topicIndex) {
          print('=======================话题   切换光标');
          context.read<ReleaseFeedInputNotifier>().changeCallback("");
        }
      }
      isSwitchCursor = true;
    });

    _formatter = ReleaseFeedInputFormatter(
        controller: widget.controller,
        rules: context.read<ReleaseFeedInputNotifier>().rules,
        // @回调
        triggerAtCallback: (String str) async {
          context.read<ReleaseFeedInputNotifier>().changeCallback(str);
        },
        // #回调
        triggerTopicCallback: (String str) async {
          context.read<ReleaseFeedInputNotifier>().changeCallback(str);
        },
        // 关闭@#视图回调
        shutDownCallback: () async {
          print('----------------------------关闭视图');
          context.read<ReleaseFeedInputNotifier>().changeCallback("");
        },
        valueChangedCallback: (List<Rule> rules, String value, int atIndex, int topicIndex, String atSearchStr,
            String topicSearchStr, bool isAdd) {
          rules = rules;
          // print("输入框值回调：$value");
          // print(rules);
          print("实时At搜索字段$atSearchStr");
          print("推荐搜索字段$topicSearchStr");
          isSwitchCursor = false;
          // 存储@位置
          if (atIndex > 0) {
            context.read<ReleaseFeedInputNotifier>().getAtCursorIndex(atIndex);
          }
          // 存储#位置
          if (topicIndex > 0) {
            context.read<ReleaseFeedInputNotifier>().getTopicCursorIndex(topicIndex);
          }
          // 存储@后面输入的文本
          context.read<ReleaseFeedInputNotifier>().setAtSearchStr(atSearchStr);
          // 存储#后面输入的文本
          context.read<ReleaseFeedInputNotifier>().setTopicSearchStr(topicSearchStr);
          // 存在整段文本
          context.read<ReleaseFeedInputNotifier>().getInputText(value);
          // @布局页面
          if (context.read<ReleaseFeedInputNotifier>().keyWord == "@") {
            if (atSearchStr.isNotEmpty && atSearchStr != null) {
              // 调用搜索全局用户第一页
              requestSearchFollowList(atSearchStr);
            } else {
              if (context.read<ReleaseFeedInputNotifier>().backupFollowList.isNotEmpty) {
                // 使用备份的关注用户数据
                context
                    .read<ReleaseFeedInputNotifier>()
                    .setFollowList(context.read<ReleaseFeedInputNotifier>().backupFollowList);
              }
            }
          }
          // 话题布局页面
          if (context.read<ReleaseFeedInputNotifier>().keyWord == "#") {
            if (topicSearchStr.isNotEmpty && topicSearchStr != null) {
              // 调用搜索话题第一页
              requestSearchTopicList(topicSearchStr);
            } else {
              if (context.read<ReleaseFeedInputNotifier>().backupTopicList.isNotEmpty) {
                // 使用备份的推荐话题数据
                context
                    .read<ReleaseFeedInputNotifier>()
                    .setTopicList(context.read<ReleaseFeedInputNotifier>().backupTopicList);
              }
            }
          }
        });
    _init();
    super.initState();
  }

// 搜索全局用户第一页
  requestSearchFollowList(String keyWork) async {
    print("搜索字段：：：：：：：：$keyWork");
    List<BuddyModel> searchFollowList = [];
    SearchUserModel model = await ProfileSearchUser(keyWork, 20);
    if (model.list.isNotEmpty) {
      model.list.forEach((element) {
        BuddyModel followModel = BuddyModel();
        followModel.nickName = element.nickName + " ";
        followModel.uid = element.uid;
        followModel.avatarUri = element.avatarUri;
        searchFollowList.add(followModel);
      });
      if (model.hasNext == 0) {
        context.read<ReleaseFeedInputNotifier>().searchLoadText = "";
        context.read<ReleaseFeedInputNotifier>().searchLoadStatus = LoadingStatus.STATUS_COMPLETED;
      }
    }
     // 记录搜索状态
    context.read<ReleaseFeedInputNotifier>().searchLastTime = model.lastTime;
    context.read<ReleaseFeedInputNotifier>().searchHasNext = model.hasNext;
    // 列表回到顶部，不然无法上拉加载下一页
    if (context.read<ReleaseFeedInputNotifier>().atScrollController.hasClients) {
      context.read<ReleaseFeedInputNotifier>().atScrollController.jumpTo(0);
    }
    // 获取关注@数据
    List<BuddyModel> followList = [];
    context.read<ReleaseFeedInputNotifier>().backupFollowList.forEach((v) {
      if (v.nickName.contains(keyWork)) {
        followList.add(v);
      }
    });
    // 筛选全局的@用户数据
    List<BuddyModel> filterFollowList = followModelarrayDate(searchFollowList, followList);
    filterFollowList.insertAll(0, followList);
    context.read<ReleaseFeedInputNotifier>().setFollowList(filterFollowList);
  }

  // 搜索话题第一页
  requestSearchTopicList(String keyWork) async {
    List<TopicDtoModel> searchTopicList = [];
    TopicDtoModel createTopModel = TopicDtoModel();
    DataResponseModel model = await searchTopic(key: keyWork, size: 20);
    if (model.list.isNotEmpty) {
      model.list.forEach((v) {
        searchTopicList.add(TopicDtoModel.fromJson(v));
      });

      bool isCreated = true;
      searchTopicList.forEach((v) {
        print(v.name);
        print(keyWork);
        print(v.name.codeUnits);
        print(keyWork.codeUnits);
        print(v.name.codeUnits == keyWork.codeUnits);
        print(v.name == keyWork + " ");
        // 去掉右边空格比较
        if (keyWork == v.name.trimRight()) {
          isCreated = false;
        }
        v.name = "#" + v.name;
      });
      if (isCreated) {
        createTopModel.name = "#" + keyWork + " ";
        createTopModel.id = -1;
        searchTopicList.insert(0, createTopModel);
        print("createTopModel.name ::${createTopModel.name}_____${createTopModel.name.length}");
      }
      if (model.hasNext == 0) {
        context.read<ReleaseFeedInputNotifier>().searchTopLoadText = "";
        context.read<ReleaseFeedInputNotifier>().searchTopLoadStatus = LoadingStatus.STATUS_COMPLETED;
      }
    } else {
      createTopModel.name = "#" + keyWork + " ";
      createTopModel.id = -1;
      searchTopicList.insert(0, createTopModel);
      print("createTopModel.name ::${createTopModel.name}_____${createTopModel.name.length}");
      context.read<ReleaseFeedInputNotifier>().searchTopLoadText = "";
      context.read<ReleaseFeedInputNotifier>().searchTopLoadStatus = LoadingStatus.STATUS_COMPLETED;
    }
    // 记录搜索状态
    context.read<ReleaseFeedInputNotifier>().searchLastScore = model.lastScore;
    context.read<ReleaseFeedInputNotifier>().searchTopHasNext = model.hasNext;
    // 列表回到顶部，不然无法上拉加载下一页
    if (context.read<ReleaseFeedInputNotifier>().topScrollController.hasClients) {
      context.read<ReleaseFeedInputNotifier>().topScrollController.jumpTo(0);
    }
    context.read<ReleaseFeedInputNotifier>().setTopicList(searchTopicList);
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
    List<Rule> rules = context.watch<ReleaseFeedInputNotifier>().rules;
    return Container(
      height: 129,
      width: ScreenUtil.instance.screenWidthDp,
      child: TextSpanField(
        // 管理焦点
        focusNode: commentFocus,
        controller: widget.controller,
        // 多行展示
        keyboardType: TextInputType.multiline,
        // 不限制行数
        maxLines: null,
        // 光标颜色
        cursorColor: Color.fromRGBO(253, 137, 140, 1),
        // 装饰器修改外观
        decoration: InputDecoration(
          // 去除下滑线
          border: InputBorder.none,
          // 提示文本
          hintText: "分享此刻...",
          // 提示文本样式
          hintStyle: TextStyle(fontSize: 14, color: AppColor.textHint),
          // 设置为true,contentPadding才会生效，TextField会有默认高度。
          isCollapsed: true,
          contentPadding: EdgeInsets.only(top: 14, left: 16, right: 16),
         // labelStyle:
        ),
        rangeStyles: getTextFieldStyle(rules),
        inputFormatters: widget.inputFormatters == null ? [_formatter] : (widget.inputFormatters..add(_formatter)),
      ),
// )
    );
  }

  void _init() {
// widget.controller.text = "";
// _formatter.clear();
  }
}
