import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/api/topic/topic_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/data_response_model.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/data/model/media_file_model.dart';
import 'package:mirror/data/model/feed/post_feed.dart';
import 'package:mirror/data/model/profile/buddy_list_model.dart';
import 'package:mirror/data/model/profile/searchuser_model.dart';
import 'package:mirror/data/notifier/feed_notifier.dart';
import 'package:mirror/page/feed/search_location.dart';
import 'package:mirror/page/home/sub_page/recommend_page.dart';
import 'package:mirror/page/media_picker/media_picker_page.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/string_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/custom_button.dart';
import 'package:mirror/widget/feed/release_feed_input_formatter.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:text_span_field/range_style.dart';
import 'package:text_span_field/text_span_field.dart';
import 'package:toast/toast.dart';

/** 搜索关注用户和搜索全局用户比较
 * 比较两数组 取出不同的，
 * array1 数组一
 * array2 数组二
 * **/
followModelarrayDate(List<BuddyModel> array1, List<BuddyModel> array2) {
  var arr1 = array1;
  var arr2 = array2;
  List<BuddyModel> result = [];
  for (var i = 0; i < array1.length; i++) {
    var obj = array1[i].nickName;
    var isExist = false;
    for (var j = 0; j < array2.length; j++) {
      var aj = array2[j].nickName;
      if (obj == aj) {
        isExist = true;
        continue;
      }
    }
    if (!isExist) {
      result.add(array1[i]);
    }
  }
  print("result${result.toString()}");
  return result;
}

class ReleasePage extends StatefulWidget {
  @override
  ReleasePageState createState() => ReleasePageState();
}

class ReleasePageState extends State<ReleasePage> {
  SelectedMediaFiles _selectedMediaFiles;
  TextEditingController _controller = TextEditingController();
  FocusNode feedFocus = FocusNode();

  // at的索引数组
  List<Rule> rules = [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    //TODO 取出来判断是否为空 非空则将图片视频作为初始值 取出后需将Application中的值清空
    print("查明￥${Application.selectedMediaFiles}");
    _selectedMediaFiles = Application.selectedMediaFiles;
    Application.selectedMediaFiles = null;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double inputHeight = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: ChangeNotifierProvider(
            create: (_) => ReleaseFeedInputNotifier(
                  inputText: "",
                  rules: [],
                  atSearchStr: "",
                  topicSearchStr: "",
                ),
            builder: (context, _) {
              String str = context.watch<ReleaseFeedInputNotifier>().keyWord;
              return Container(
                color: AppColor.white,
                margin: EdgeInsets.only(
                  top: ScreenUtil.instance.statusBarHeight,
                ),
                child: Column(
                  children: [
                    // 头部布局
                    FeedHeader(selectedMediaFiles: _selectedMediaFiles),
                    // 输入框
                    KeyboardInput(controller: _controller),
                    // 中间主视图
                    str == "@"
                        ? Expanded(child: AtList(controller: _controller))
                        : str == "#"
                            ? Expanded(child: TopicList(controller: _controller))
                            : ReleaseFeedMainView(selectedMediaFiles: _selectedMediaFiles)
                  ],
                ),
              );
            }));
  }
}

// 头部布局
class FeedHeader extends StatelessWidget {
  FeedHeader({this.selectedMediaFiles});

  SelectedMediaFiles selectedMediaFiles;

  // 发布动态
  pulishFeed(String inputText, List<Rule> rules, BuildContext context) async {
    print("打印一下规则$rules");
    PostFeedModel feedModel = PostFeedModel();
    List<AtUsersModel> atUsersModel = [];
    String address;
    String cityCode;
    String latitude;
    String longitude;
    List<TopicDtoModel> topics = [];
    print("输入框文字￥$inputText");
    feedModel.content = inputText;
    // 检测文本
    Map<String, dynamic> textModel = await feedTextScan(text: inputText);
    if (textModel["state"]) {
      print("feedModel.content${feedModel.content}");
      for (Rule rule in rules) {
        if (rule.isAt) {
          AtUsersModel atModel = AtUsersModel();
          atModel.index = rule.startIndex;
          atModel.len = rule.endIndex;
          atModel.uid = rule.id;
          atUsersModel.add(atModel);
        } else {
          print("查看发布话题动态——————————————————————————————");
          print(rule.toString());
          TopicDtoModel topicDtoModel = TopicDtoModel();

          if (rule.id != -1) {
            topicDtoModel.id = rule.id;
            topicDtoModel.index = rule.startIndex;
            topicDtoModel.len = rule.endIndex;
          } else {
            topicDtoModel.name = rule.params.substring(1, rule.params.length);
            topicDtoModel.index = rule.startIndex;
            topicDtoModel.len = rule.endIndex - 1;
          }
          topics.add(topicDtoModel);
        }
      }
      feedModel.selectedMediaFiles = selectedMediaFiles;
      feedModel.atUsersModel = atUsersModel;
      feedModel.address = address;
      feedModel.cityCode = cityCode;
      feedModel.latitude = latitude;
      feedModel.longitude = longitude;
      feedModel.topics = topics;
      print("打印一下￥￥${(feedModel.selectedMediaFiles.list.length)}");
      // 传入发布动态model
      context.read<FeedMapNotifier>().setPublishFeedModel(feedModel);
      context.read<ReleaseFeedInputNotifier>().rules.clear();
      Navigator.pop(context, true);
      print("打印结束");
    } else {
      ToastShow.show(msg: "你发布的动态可能存在敏感内容", context: context, gravity: Toast.CENTER);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ScreenUtil.instance.screenWidthDp,
      height: 44,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(width: 0.5, color: Color(0xffe5e5e5))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(left: 16),
            child: MyIconBtn(
              width: 28,
              height: 28,
              iconSting: "images/resource/2.0x/shut_down@2x.png",
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ),
          Spacer(),
          GestureDetector(
              onTap: () {
                // 读取输入框最新的值
                var inputText = context.read<ReleaseFeedInputNotifier>().inputText;

                // 获取输入框内的规则
                var rules = context.read<ReleaseFeedInputNotifier>().rules;
                print("点击生效");
                pulishFeed(inputText, rules, context);
              },
              child: IgnorePointer(
                // 监听输入框的值==""使外层点击不生效。非""手势生效。
                ignoring: context.watch<ReleaseFeedInputNotifier>().inputText == "",
                child: Container(
                    // padding: EdgeInsets.only(top: 6,left: 12,bottom: 6,right: 12),
                    height: 28,
                    width: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(14)),
                      // 监听输入框的值动态改变样式
                      color: context.watch<ReleaseFeedInputNotifier>().inputText != ""
                          ? AppColor.mainRed
                          : AppColor.mainRed.withOpacity(0.65),
                    ),
                    child: Center(
                      child: Text(
                        "发布",
                        style: TextStyle(color: AppColor.white, fontSize: 14, decoration: TextDecoration.none),
                      ),
                    )),
              )),
          SizedBox(
            width: 16,
          )
        ],
      ),
    );
  }
}

// 动态输入框
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
      bool isClickTopic =  context.read<ReleaseFeedInputNotifier>().isClickTopic;

      // 在每次选择@用户后ios设置光标位置。
      if (Platform.isIOS && isClickAtUser ) {
        print("@改光标");
        // 设置光标
        var setCursor = TextSelection(
          baseOffset: widget.controller.text.length,
          extentOffset: widget.controller.text.length,
        );
        widget.controller.selection = setCursor;
      }
      context.read<ReleaseFeedInputNotifier>().setClickAtUser(false);
      if (Platform.isIOS && isClickTopic ) {
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
              if (context
                  .read<ReleaseFeedInputNotifier>()
                  .backupFollowList
                  .isNotEmpty) {
                // 使用备份的关注用户数据
                context
                    .read<ReleaseFeedInputNotifier>()
                    .setFollowList(context
                    .read<ReleaseFeedInputNotifier>()
                    .backupFollowList);
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
                    .setTopicList(context
                    .read<ReleaseFeedInputNotifier>()
                    .backupTopicList);
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
    context.read<ReleaseFeedInputNotifier>().atScrollController.jumpTo(0);
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
        if (keyWork == v.name.trimRight()) {
          isCreated = false;
        }
        v.name = "#" + v.name + " ";
      });
      if (isCreated) {
        createTopModel.name = "#" + keyWork + " ";
        createTopModel.id = -1;
        searchTopicList.insert(0, createTopModel);
      }
      if (model.hasNext == 0) {
        context.read<ReleaseFeedInputNotifier>().searchTopLoadText = "";
        context.read<ReleaseFeedInputNotifier>().searchTopLoadStatus = LoadingStatus.STATUS_COMPLETED;
      }
    } else {
      createTopModel.name = "#" + keyWork + " ";
      createTopModel.id = -1;
      searchTopicList.insert(0, createTopModel);
      context.read<ReleaseFeedInputNotifier>().searchTopLoadText = "";
      context.read<ReleaseFeedInputNotifier>().searchTopLoadStatus = LoadingStatus.STATUS_COMPLETED;
    }
    // 记录搜索状态
    context.read<ReleaseFeedInputNotifier>().searchLastScore = model.lastScore;
    context.read<ReleaseFeedInputNotifier>().searchTopHasNext = model.hasNext;
    // 列表回到顶部，不然无法上拉加载下一页
    context.read<ReleaseFeedInputNotifier>().topScrollController.jumpTo(0);
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
    widget.controller.text = "";
    // _formatter.clear();
  }
}

// 话题列表
class TopicList extends StatefulWidget {
  TextEditingController controller;

  TopicList({this.controller});

  @override
  TopicListState createState() => TopicListState();
}

class TopicListState extends State<TopicList> {
  List<TopicDtoModel> topics = [];

  // 滑动控制器
  ScrollController _scrollController = new ScrollController();

  // 是否存在下页
  int hasNext;

  // 推荐数据加载页数
  int dataPage = 1;

  // 搜索数据加载页数
  int searchDataPage = 1;

  // 加载中默认文字
  String loadText = "加载中...";

  // 加载状态
  LoadingStatus loadStatus = LoadingStatus.STATUS_IDEL;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    requestRecommendTopic();
    context.read<ReleaseFeedInputNotifier>().setTopScrollController(_scrollController);
    _scrollController.addListener(() {
      // 搜索全局用户关键字
      String searchTopStr = context.read<ReleaseFeedInputNotifier>().topicSearchStr;
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        if (searchTopStr.isNotEmpty) {
          searchDataPage += 1;
          requestSearchTopic(searchTopStr);
        }
      }
    });
    super.initState();
  }

  // 获取推荐话题
  requestRecommendTopic() async {
    if (loadStatus == LoadingStatus.STATUS_IDEL) {
      // 先设置状态，防止下拉就直接加载
      setState(() {
        loadStatus = LoadingStatus.STATUS_LOADING;
      });
    }
    if (hasNext == 0) {
      loadText = "已加载全部话题";
      print("返回不请求数据");
      return;
    }
    DataResponseModel model = await getRecommendTopic(size: 20);
    if (dataPage == 1) {
      if (model.list.isNotEmpty) {
        model.list.forEach((v) {
          topics.add(TopicDtoModel.fromJson(v));
        });
        topics.forEach((v) {
          v.name = "#" + v.name + " ";
        });
        loadText = "";
        loadStatus = LoadingStatus.STATUS_COMPLETED;
      }
    }
    hasNext = model.hasNext;
    // 存入话题显示数据
    context.read<ReleaseFeedInputNotifier>().setTopicList(topics);
    // 搜索时会替换话题显示数据，备份一份数据
    context.read<ReleaseFeedInputNotifier>().setBackupTopicList(topics);
    setState(() {});
  }

  // 搜索话题
  // 此处调用都为第二页及以上数据第一页在输入框回调内调用
  requestSearchTopic(String keyWork) async {
    List<TopicDtoModel> searchList = [];
    if (context.read<ReleaseFeedInputNotifier>().searchTopLoadStatus == LoadingStatus.STATUS_IDEL) {
      // 先设置状态，防止下拉就直接加载
      setState(() {
        context.read<ReleaseFeedInputNotifier>().searchTopLoadStatus = LoadingStatus.STATUS_LOADING;
      });
    }
    if (context.read<ReleaseFeedInputNotifier>().searchTopHasNext == 0) {
      context.read<ReleaseFeedInputNotifier>().searchTopLoadText = "已加载全部话题";
      context.read<ReleaseFeedInputNotifier>().searchTopLoadStatus = LoadingStatus.STATUS_COMPLETED;
      setState(() {});
      print("返回不请求搜索数据");
      return;
    }
    DataResponseModel model =
        await searchTopic(key: keyWork, size: 20, lastScore: context.read<ReleaseFeedInputNotifier>().searchLastScore);
    if (searchDataPage > 1 && context.read<ReleaseFeedInputNotifier>().searchLastScore != null) {
      if (model.list.isNotEmpty) {
        model.list.forEach((v) {
          searchList.add(TopicDtoModel.fromJson(v));
        });
        searchList.forEach((v) {
          v.name = "#" + v.name + " ";
        });
        context.read<ReleaseFeedInputNotifier>().searchTopLoadStatus = LoadingStatus.STATUS_IDEL;
        context.read<ReleaseFeedInputNotifier>().searchTopLoadText = "加载中...";
      }
    }
    // 记录搜索状态
    context.read<ReleaseFeedInputNotifier>().searchLastScore = model.lastScore;
    context.read<ReleaseFeedInputNotifier>().searchTopHasNext = model.hasNext;
    setState(() {});
    // 把在输入框回调内的第一页数据插入
    searchList.insertAll(0, context.read<ReleaseFeedInputNotifier>().topicList);
    context.read<ReleaseFeedInputNotifier>().setTopicList(searchList);
  }

  @override
  Widget build(BuildContext context) {
    List<TopicDtoModel> list = context.watch<ReleaseFeedInputNotifier>().topicList;
    // 搜索全局用户关键字
    String searchTopicStr = context.watch<ReleaseFeedInputNotifier>().topicSearchStr;
    return list.isNotEmpty
        ? MediaQuery.removePadding(
            removeTop: true,
            context: context,
            child: ListView.builder(
              shrinkWrap: true,
              controller: _scrollController,
              itemBuilder: (context, index) {
                if (index == list.length) {
                  return LoadingView(
                    loadText: searchTopicStr.isNotEmpty
                        ? context.read<ReleaseFeedInputNotifier>().searchTopLoadText
                        : loadText,
                    loadStatus: searchTopicStr.isNotEmpty
                        ? context.read<ReleaseFeedInputNotifier>().searchTopLoadStatus
                        : loadStatus,
                  );
                } else if (index == list.length + 1) {
                  return Container();
                } else {
                  return GestureDetector(
                      // 点击空白区域响应事件
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        context.read<ReleaseFeedInputNotifier>().setClickTopic(true);
                        // #的文字长度
                        int topicLength = list[index].name.length - 1;
                        // 获取比较规则
                        var rules = context.read<ReleaseFeedInputNotifier>().rules;
                        // 获取实时搜索文本
                        String searchStr = context.read<ReleaseFeedInputNotifier>().topicSearchStr;
                        // 检测是否添加过
                        if (rules.isNotEmpty) {
                          for (Rule atRule in rules) {
                            print(atRule.params);
                            print(list[index].name);
                            if (atRule.id != -1 && atRule.id == list[index].id && atRule.isAt == false) {
                              ToastShow.show(msg: "已经添加过了", context: context, gravity: Toast.CENTER);
                              return;
                            } else if (atRule.id == -1 && atRule.params == list[index].name) {
                              ToastShow.show(msg: "已经添加过了", context: context, gravity: Toast.CENTER);
                              return;
                            }
                          }
                        }
                        // 获取#的光标
                        int topicIndex = context.read<ReleaseFeedInputNotifier>().topicCursorIndex;
                        // #前的文字
                        String topicBeforeStr = widget.controller.text.substring(0, topicIndex);
                        // #后的文字
                        String topicRearStr = "";
                        print(searchStr);
                        print("controller.text:${widget.controller.text}");
                        print("topicBeforeStr$topicBeforeStr");
                        if (searchStr != "" || searchStr.isNotEmpty) {
                          print("topicIndex:$topicIndex");
                          print("searchStr:$searchStr");
                          print("controller.text:${widget.controller.text}");
                          topicRearStr = widget.controller.text
                              .substring(topicIndex + searchStr.length, widget.controller.text.length);
                          print("topicRearStr:$topicRearStr");
                        } else {
                          topicRearStr = widget.controller.text.substring(topicIndex, widget.controller.text.length);
                        }
                        // 点击的文本
                        String topicMiddleStr = list[index].name.substring(1, list[index].name.length);
                        // 拼接修改输入框的值
                        widget.controller.text = topicBeforeStr + topicMiddleStr + topicRearStr;
                        context.read<ReleaseFeedInputNotifier>().getInputText(widget.controller.text);
                        print("controller.text ${widget.controller.text}");
                        // 这是替换输入的文本修改后面输入的#的规则
                        if (searchStr != "" || searchStr.isNotEmpty) {
                          print("话题替换");
                          int oldLength = searchStr.length;
                          int newLength = list[index].name.length - 1;
                          int oldStartIndex = topicIndex;
                          int diffLength = newLength - oldLength;
                          for (int i = 0; i < rules.length; i++) {
                            print(rules[i]);
                            if (rules[i].startIndex >= oldStartIndex) {
                              int newStartIndex = rules[i].startIndex + diffLength;
                              int newEndIndex = rules[i].endIndex + diffLength;
                              rules.replaceRange(i, i + 1, <Rule>[rules[i].copy(newStartIndex, newEndIndex)]);
                              print(rules[i]);
                            }
                          }
                        }
                        // 此时为了解决后输入的#切换光标到之前输入的@或者#前方，更新之前输入@和#的索引。
                        for (int i = 0; i < rules.length; i++) {
                          print("进入");
                          // 当最新输入框内的文本对应不上之前的 @或者#值时。
                          if (rules[i].params !=
                              widget.controller.text.substring(rules[i].startIndex, rules[i].endIndex)) {
                            print(rules[i]);
                            rules[i] = Rule(rules[i].startIndex + topicLength, rules[i].endIndex + topicLength,
                                rules[i].params, rules[i].clickIndex, rules[i].isAt, rules[i].id);
                            print(rules[i]);
                          }
                        }
                        // 存储规则,
                        context.read<ReleaseFeedInputNotifier>().addRules(Rule(
                            topicIndex - 1, topicIndex + topicLength, list[index].name, index, false, list[index].id));
                        // 设置光标
                        var setCursor = TextSelection(
                          baseOffset: widget.controller.text.length,
                          extentOffset: widget.controller.text.length,
                        );
                        widget.controller.selection = setCursor;
                        print(rules);
                        context.read<ReleaseFeedInputNotifier>().setTopicSearchStr("");
                        // 关闭视图
                        context.read<ReleaseFeedInputNotifier>().changeCallback("");
                      },
                      child: Container(
                        margin: EdgeInsets.only(left: 16),
                        height: 54,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 6,
                            ),
                            Text(
                              list[index].name,
                              style: AppStyle.textRegular16,
                            ),
                            SizedBox(
                              height: 2,
                            ),
                            Text(
                              list[index].id != -1 ? "${StringUtil.getNumber(list[index].feedCount)}篇动态" : "创建新话题",
                              style: AppStyle.textSecondaryRegular12,
                            ),
                            SizedBox(
                              height: 6,
                            ),
                          ],
                        ),
                      ));
                }
              },
              itemCount: list.length + 1,
            ),
          )
        : Container();
  }
}

// @联系人列表
class AtList extends StatefulWidget {
  AtList({this.controller});

  TextEditingController controller;

  @override
  AtListState createState() => AtListState();
}

class AtListState extends State<AtList> {
  List<BuddyModel> followList = [];

  // 滑动控制器
  ScrollController _scrollController = new ScrollController();

  /*
  关注列表字段
   */
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

// /*
// 搜索全局的字段
//  */

  // 数据加载页数
  int searchDataPage = 1;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    requestBothFollowList();
    context.read<ReleaseFeedInputNotifier>().setAtScrollController(_scrollController);
    _scrollController.addListener(() {
      // 搜索全局用户关键字
      String searchUserStr = context.read<ReleaseFeedInputNotifier>().atSearchStr;
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        if (searchUserStr.isNotEmpty) {
          searchDataPage += 1;
          requestSearchFollowList(searchUserStr);
        } else {
          dataPage += 1;
          requestBothFollowList();
        }
      }
    });
    super.initState();
  }

  // 请求搜索关注用户
  // 此处调用都为第二页及以上数据第一页在输入框回调内调用
  requestSearchFollowList(String keyWork) async {
    List<BuddyModel> searchFollowList = [];
    if (context.read<ReleaseFeedInputNotifier>().searchLoadStatus == LoadingStatus.STATUS_IDEL) {
      // 先设置状态，防止下拉就直接加载
      setState(() {
        context.read<ReleaseFeedInputNotifier>().searchLoadStatus = LoadingStatus.STATUS_LOADING;
      });
    }
    if (context.read<ReleaseFeedInputNotifier>().searchHasNext == 0) {
      context.read<ReleaseFeedInputNotifier>().searchLoadText = "已加载全部好友";
      context.read<ReleaseFeedInputNotifier>().searchLoadStatus = LoadingStatus.STATUS_COMPLETED;
      setState(() {});
      print("返回不请求搜索数据");
      return;
    }
    SearchUserModel model =
        await ProfileSearchUser(keyWork, 20, lastTime: context.read<ReleaseFeedInputNotifier>().searchLastTime);
    if (searchDataPage > 1 && context.read<ReleaseFeedInputNotifier>().searchLastTime != null) {
      if (model.list.isNotEmpty) {
        model.list.forEach((v) {
          BuddyModel followModel = BuddyModel();
          followModel.nickName = v.nickName + " ";
          followModel.uid = v.uid;
          followModel.avatarUri = v.avatarUri;
          searchFollowList.add(followModel);
        });
        context.read<ReleaseFeedInputNotifier>().searchLoadStatus = LoadingStatus.STATUS_IDEL;
        context.read<ReleaseFeedInputNotifier>().searchLoadText = "加载中...";
      }
    }
    // 记录搜索状态
    context.read<ReleaseFeedInputNotifier>().searchLastTime = model.lastTime;
    context.read<ReleaseFeedInputNotifier>().searchHasNext = model.hasNext;
    setState(() {});
    // 把在输入框回调内的第一页数据插入
    searchFollowList.insertAll(0, context.read<ReleaseFeedInputNotifier>().followList);
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

  // 请求好友列表
  requestBothFollowList() async {
    if (loadStatus == LoadingStatus.STATUS_IDEL) {
      // 先设置状态，防止下拉就直接加载
      setState(() {
        loadStatus = LoadingStatus.STATUS_LOADING;
      });
    }
    if (hasNext == 0) {
      setState(() {
        loadText = "已加载全部好友";
        loadStatus = LoadingStatus.STATUS_COMPLETED;
        print("返回不请求数据");
      });
      return;
    }
    BuddyListModel model = await GetFollowList(20, lastTime: lastTime);
    if (dataPage == 1) {
      if (model.list.isNotEmpty) {
        print(model.list.length);
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
    lastTime = model.lastTime;
    hasNext = model.hasNext;
    // 存入@显示数据
    context.read<ReleaseFeedInputNotifier>().setFollowList(followList);
    // 搜索时会替换@显示数据，备份一份数据
    context.read<ReleaseFeedInputNotifier>().setBackupFollowList(followList);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    List<BuddyModel> list = context.watch<ReleaseFeedInputNotifier>().followList;
    // 搜索全局用户关键字
    String searchUserStr = context.watch<ReleaseFeedInputNotifier>().atSearchStr;
    return list.isNotEmpty
        ? MediaQuery.removePadding(
            removeTop: true,
            context: context,
            child: ListView.builder(
              shrinkWrap: true,
              controller: _scrollController,
              itemBuilder: (context, index) {
                if (index == list.length) {
                  return LoadingView(
                    loadText:
                        searchUserStr.isNotEmpty ? context.read<ReleaseFeedInputNotifier>().searchLoadText : loadText,
                    loadStatus: searchUserStr.isNotEmpty
                        ? context.read<ReleaseFeedInputNotifier>().searchLoadStatus
                        : loadStatus,
                  );
                } else if (index == list.length + 1) {
                  return Container();
                } else {
                  return GestureDetector(
                    // 点击空白区域响应事件
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      context.read<ReleaseFeedInputNotifier>().setClickAtUser(true);
                      // At的文字长度
                      int AtLength = list[index].nickName.length;
                      // 获取输入框内的规则
                      var rules = context.read<ReleaseFeedInputNotifier>().rules;
                      // 检测是否添加过
                      if (rules.isNotEmpty) {
                        for (Rule rule in rules) {
                          if (rule.id == list[index].uid && rule.isAt == true) {
                            ToastShow.show(msg: "已经添加过了", context: context, gravity: Toast.CENTER);
                            return;
                          }
                        }
                      }
                      // 获取@的光标
                      int atIndex = context.read<ReleaseFeedInputNotifier>().atCursorIndex;
                      // 获取实时搜索文本
                      String searchStr = context.read<ReleaseFeedInputNotifier>().atSearchStr;
                      // @前的文字
                      String atBeforeStr = widget.controller.text.substring(0, atIndex);
                      // @后的文字
                      String atRearStr = "";
                      print(searchStr);
                      print("controller.text:${widget.controller.text}");
                      print("atBeforeStr$atBeforeStr");
                      if (searchStr != "" || searchStr.isNotEmpty) {
                        print("atIndex:$atIndex");
                        print("searchStr:$searchStr");
                        print("controller.text:${widget.controller.text}");
                        atRearStr =
                            widget.controller.text.substring(atIndex + searchStr.length, widget.controller.text.length);
                        print("atRearStr:$atRearStr");
                      } else {
                        atRearStr = widget.controller.text.substring(atIndex, widget.controller.text.length);
                      }

                      // 拼接修改输入框的值
                      widget.controller.text = atBeforeStr + list[index].nickName + atRearStr;
                      // 设置光标
                      if (!Platform.isIOS) {
                        var setCursor = TextSelection(
                          baseOffset: widget.controller.text.length,
                          extentOffset: widget.controller.text.length,
                        );
                        print("设置光标${setCursor}");
                        widget.controller.selection = setCursor;
                      }

                      print("controller.text:${widget.controller.text}");
                      context.read<ReleaseFeedInputNotifier>().getInputText(widget.controller.text);
                      // 这是替换输入的文本修改后面输入的@的规则
                      if (searchStr != "" || searchStr.isNotEmpty) {
                        int oldLength = searchStr.length;
                        int newLength = list[index].nickName.length;
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
                            widget.controller.text.substring(rules[i].startIndex, rules[i].endIndex)) {
                          print("进入");
                          print(rules[i]);
                          rules[i] = Rule(rules[i].startIndex + AtLength, rules[i].endIndex + AtLength, rules[i].params,
                              rules[i].clickIndex, rules[i].isAt, rules[i].id);
                          print(rules[i]);
                        }
                      }
                      // 存储规则
                      context.read<ReleaseFeedInputNotifier>().addRules(Rule(
                          atIndex - 1, atIndex + AtLength, "@" + list[index].nickName, index, true, list[index].uid));

                      context.read<ReleaseFeedInputNotifier>().setAtSearchStr("");
                      // 关闭视图
                      context.read<ReleaseFeedInputNotifier>().changeCallback("");
                    },
                    child: Container(
                      height: 48,
                      width: ScreenUtil.instance.width,
                      margin: EdgeInsets.only(bottom: 10, left: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(list[index].avatarUri),
                            maxRadius: 19,
                          ),
                          SizedBox(width: 12),
                          Text(
                            list[index].nickName,
                            // followList[index].nickName,
                            style: AppStyle.textRegular16,
                          )
                        ],
                      ),
                    ),
                  );
                }
              },
              itemCount: list.length + 1,
            ))
        : Container();
  }
}

// 发布动态输入框下的所有部件
class ReleaseFeedMainView extends StatelessWidget {
  ReleaseFeedMainView({this.pc, this.selectedMediaFiles});

  SelectedMediaFiles selectedMediaFiles;
  List<String> PhotoUrl = [
    "images/test/yxlm2.jpeg",
    "images/test/yxlm3.jpeg",
    "images/test/yxlm4.jpg",
    "images/test/yxlm6.jpg",
    "images/test/yxlm7.jpeg"
  ];
  List<String> addresss = ["成都市", "花样年福年广场", "牛水煮·麻辣水煮牛肉", "园林火锅", "嘉年CEO酒店公寓-(成都会展中心福年广场店)", "查看更多"];
  PanelController pc = new PanelController();

  // 选择地址
  seletedAddress(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
          return SearchLocation();
        }));
        print("跳转选择地址页面");
      },
      child: Container(
        margin: EdgeInsets.only(left: 16, right: 16, top: 12),
        height: 48,
        width: ScreenUtil.instance.screenWidthDp,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.accessible,
              size: 24,
            ),
            SizedBox(
              width: 4,
            ),
            Text(
              "你在哪儿",
              style: TextStyle(fontSize: 16, color: AppColor.textPrimary1),
            ),
            Spacer(),
            Icon(
              Icons.arrow_forward_ios_sharp,
              size: 18,
              color: AppColor.textHint,
            )
          ],
        ),
      ),
    );
  }

  // 推荐地址
  recommendAddress() {
    return Container(
      height: 48,
      padding: EdgeInsets.symmetric(vertical: 12.5),
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: addresss.length,
          itemBuilder: (context, index) {
            return addressItem(addresss[index], index);
          }),
    );
  }

  // 推荐地址Item
  addressItem(String address, int index) {
    return Container(
      // height: 23,
      margin: EdgeInsets.only(left: index == 0 ? 16 : 12, right: index == addresss.length - 1 ? 16 : 0),
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      alignment: Alignment(0, 0),
      decoration:
          BoxDecoration(color: AppColor.textHint.withOpacity(0.24), borderRadius: BorderRadius.all(Radius.circular(3))),
      child: Text(
        address,
        style: TextStyle(fontSize: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        selectedMediaFiles.list != null
            ? SeletedPhoto(
                photoUrl: PhotoUrl,
                selectedMediaFiles: selectedMediaFiles,
              )
            : Container(),
        seletedAddress(context),
        recommendAddress()
      ],
    );
  }
}

// 图片
class SeletedPhoto extends StatefulWidget {
  SeletedPhoto({Key key, this.photoUrl, this.selectedMediaFiles}) : super(key: key);
  SelectedMediaFiles selectedMediaFiles;
  List<String> photoUrl;

  SeletedPhotoState createState() => SeletedPhotoState();
}

class SeletedPhotoState extends State<SeletedPhoto> {
  // 解析数据
  resolveData() async {
    for (MediaFileModel model in widget.selectedMediaFiles.list) {
      if (model.croppedImage != null) {
        ByteData byteData = await model.croppedImage.toByteData(format: ui.ImageByteFormat.png);
        Uint8List picBytes = byteData.buffer.asUint8List();
        model.croppedImageData = picBytes;
      }
      setState(() {});
    }
  }

  @override
  void initState() {
    resolveData();
  }

  // 进入相册的添加视图
  addView() {
    if ((widget.selectedMediaFiles.type == mediaTypeKeyImage && widget.selectedMediaFiles.list.length < 9) ||
        (widget.selectedMediaFiles.type == null)) {
      return GestureDetector(
        onTap: () {
          int type = typeImage;
          if (widget.selectedMediaFiles.type == null) {
            type = typeImageAndVideo;
          } else if (widget.selectedMediaFiles.type == mediaTypeKeyImage) {
            type = typeImage;
          }
          AppRouter.navigateToMediaPickerPage(
              context, 9 - widget.selectedMediaFiles.list.length, type, true, startPageGallery, false,
              (result) async {
            SelectedMediaFiles files = Application.selectedMediaFiles;
            if (true != result || files == null) {
              print("没有选择媒体文件");
              return;
            }
            if (widget.selectedMediaFiles.type == null) {
              widget.selectedMediaFiles.type = files.type;
            }
            Application.selectedMediaFiles = null;
            print(files.type + ":" + files.list.toString());
            for (MediaFileModel model in files.list) {
              if (model.croppedImage != null) {
                print("开始获取ByteData" + DateTime.now().millisecondsSinceEpoch.toString());
                ByteData byteData = await model.croppedImage.toByteData(format: ui.ImageByteFormat.png);
                print("已获取到ByteData" + DateTime.now().millisecondsSinceEpoch.toString());
                Uint8List picBytes = byteData.buffer.asUint8List();
                print("已获取到Uint8List" + DateTime.now().millisecondsSinceEpoch.toString());
                model.croppedImageData = picBytes;
              }
            }
            widget.selectedMediaFiles.list.addAll(files.list);
            context.read<ReleaseFeedInputNotifier>().setSelectedMediaFiles(widget.selectedMediaFiles);
            setState(() {});
          });
        },
        child: Container(
          margin: EdgeInsets.only(left: 10, top: 9, right: 16),
          width: 86,
          height: 86,
          decoration: BoxDecoration(
            color: AppColor.bgWhite,
            borderRadius: BorderRadius.all(Radius.circular(3.0)),
          ),
          child: Center(
            child: Icon(Icons.add, color: AppColor.textHint),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 95,
      margin: EdgeInsets.only(top: 14),
      child: ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount:
              widget.selectedMediaFiles.type == mediaTypeKeyVideo ? 1 : widget.selectedMediaFiles.list.length + 1,
          itemBuilder: (context, index) {
            if (index == widget.selectedMediaFiles.list.length) {
              return addView();
            }
            return Container(
              width: 92,
              height: 92,
              margin: EdgeInsets.only(left: index == 0 ? 16 : 10),
              child: Stack(
                // overflow: Overflow.visible,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 9),
                    width: 86,
                    height: 86,
                    decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(3.0))),
                  ),
                  Positioned(
                    top: 9,
                    left: 0,
                    child: widget.selectedMediaFiles.type == mediaTypeKeyVideo
                        ? Image.memory(
                            widget.selectedMediaFiles.list[index].thumb,
                            fit: BoxFit.cover,
                            width: 86,
                            height: 86,
                          )
                        : widget.selectedMediaFiles.list[index].croppedImageData != null
                            ? Image.memory(
                                widget.selectedMediaFiles.list[index].croppedImageData,
                                fit: BoxFit.cover,
                                width: 86,
                                height: 86,
                              )
                            : widget.selectedMediaFiles.list[index].file != null
                                ? Image.file(
                                    widget.selectedMediaFiles.list[index].file,
                                    fit: BoxFit.cover,
                                    width: 86,
                                    height: 86,
                                  )
                                : Container(),
                  ),
                  Positioned(
                      right: 0,
                      // top: ,
                      child: GestureDetector(
                        onTap: () {
                          print("关闭");
                          setState(() {
                            if (widget.selectedMediaFiles.list.length == 1) {
                              ToastShow.show(msg: "最后一个了", context: context, gravity: Toast.CENTER);
                              return;
                              // widget.selectedMediaFiles.type = null;
                            }
                            widget.selectedMediaFiles.list.removeAt(index);
                          });
                        },
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                              color: AppColor.bgBlack, borderRadius: BorderRadius.all(Radius.circular(8))),
                          child: Center(
                              child: Icon(
                            Icons.close,
                            color: AppColor.white,
                            size: 12,
                          )),
                        ),
                      ))
                ],
              ),
            );
          }),
    );
  }
}

// 发布动态文本监听
class ReleaseFeedInputNotifier extends ChangeNotifier {
  ReleaseFeedInputNotifier(
      {this.keyWord,
      this.inputText,
      this.rules,
      this.atCursorIndex,
      this.atSearchStr,
      this.topicSearchStr,
      this.selectedMediaFiles});

  // 监听输入框输入的值是否为@#切换视图的
  String keyWord = "";

  // 输入的文字用于发送按钮的可点击状态。
  String inputText = "";

  // 记录规则
  List<Rule> rules = [];

  // 记录@唤醒页面时光标的位置
  int atCursorIndex;

  // 记录#话题唤醒页面时光标的位置
  int topicCursorIndex;

  // @后的实时搜索文本
  String atSearchStr;

  // #后的实时搜索文本
  String topicSearchStr;

  // 关注用户数据源
  List<BuddyModel> followList = [];

  // 存储未搜索时关注用户数据源
  List<BuddyModel> backupFollowList = [];

  // 话题数据源
  List<TopicDtoModel> topicList = [];

  // 存储未搜索时话题数据源
  List<TopicDtoModel> backupTopicList = [];

  // 发布动态选择的图片视频
  SelectedMediaFiles selectedMediaFiles;

  // 是否点击了弹起的@用户列表
  bool isClickAtUser = false;

  // 是否点击了弹起的话题列表
  bool isClickTopic = false;

  /*
  搜索全局用户的字段
 */
  // 请求下一页
  int searchLastTime;

  // 是否存在下页
  int searchHasNext;

  // 加载中默认文字
  String searchLoadText = "加载中...";

  // 加载状态
  LoadingStatus searchLoadStatus = LoadingStatus.STATUS_IDEL;

  // at滑动控制器
  ScrollController atScrollController;

  /*
  搜索话题的字段
 */
  // 请求下一页
  double searchLastScore;

  // 是否存在下页
  int searchTopHasNext;

  // 加载中默认文字
  String searchTopLoadText = "加载中...";

  // 加载状态
  LoadingStatus searchTopLoadStatus = LoadingStatus.STATUS_IDEL;

  // 话题滑动控制器
  ScrollController topScrollController;

  getAtCursorIndex(int atIndex) {
    this.atCursorIndex = atIndex;
    notifyListeners();
  }

  getTopicCursorIndex(int topicIndex) {
    this.topicCursorIndex = topicIndex;
    notifyListeners();
  }

  changeCallback(String str) {
    this.keyWord = str;
    notifyListeners();
  }

  getInputText(String str) {
    this.inputText = str;
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

  setTopicSearchStr(String str) {
    this.topicSearchStr = str;
    notifyListeners();
  }

  setSelectedMediaFiles(SelectedMediaFiles _selectedMediaFiles) {
    this.selectedMediaFiles = _selectedMediaFiles;
    notifyListeners();
  }

  setFollowList(List<BuddyModel> list) {
    this.followList = list;
    notifyListeners();
  }

  setBackupFollowList(List<BuddyModel> list) {
    this.backupFollowList = list;
    notifyListeners();
  }

  setTopicList(List<TopicDtoModel> list) {
    this.topicList = list;
    notifyListeners();
  }

  setBackupTopicList(List<TopicDtoModel> list) {
    this.backupTopicList = list;
    notifyListeners();
  }

  setSearchLastTime(int time) {
    this.searchLastTime = time;
    notifyListeners();
  }

  setSearchHasNext(int next) {
    this.searchHasNext = next;
    notifyListeners();
  }

  setSearchLoadText(String text) {
    this.searchLoadText = text;
    notifyListeners();
  }

  setSearchLoadStatus(LoadingStatus status) {
    this.searchLoadStatus = status;
    notifyListeners();
  }

  setAtScrollController(ScrollController controller) {
    this.atScrollController = controller;
    notifyListeners();
  }

  setSearchLastScore(double time) {
    this.searchLastScore = time;
    notifyListeners();
  }

  setSearchTopHasNext(int next) {
    this.searchTopHasNext = next;
    notifyListeners();
  }

  setSearchTopLoadText(String text) {
    this.searchTopLoadText = text;
    notifyListeners();
  }

  setSearchTopLoadStatus(LoadingStatus status) {
    this.searchTopLoadStatus = status;
    notifyListeners();
  }

  setTopScrollController(ScrollController controller) {
    this.topScrollController = controller;
    notifyListeners();
  }
  setClickAtUser(bool at) {
    this.isClickAtUser = at;
  }
  // 是否点击了弹起的话题列表
  setClickTopic (bool top) {
    this.isClickTopic = top;
  }
}
