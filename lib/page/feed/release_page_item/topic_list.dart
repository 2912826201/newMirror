// 话题列表
import 'package:flutter/cupertino.dart';
import 'package:mirror/api/topic/topic_api.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/data_response_model.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/page/home/sub_page/recommend_page.dart';
import 'package:mirror/util/string_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';
import '../release_page.dart';
import 'package:mirror/widget/input_formatter/release_feed_input_formatter.dart';

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
    Future.delayed(Duration.zero, () {
      context.read<ReleaseFeedInputNotifier>().setTopScrollController(_scrollController);
    });
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
    DataResponseModel model = await getUserRecommendTopic(size: 20);
    if (dataPage == 1) {
      if (model!=null&&model.list.isNotEmpty) {
        model.list.forEach((v) {
          topics.add(TopicDtoModel.fromJson(v));
        });
        topics.forEach((v) {
          v.name = "#" + v.name;
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
          v.name = "#" + v.name;
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
                        // 减一是因为输入已经添加了一个#去掉文本内的#
                        int topicLength = list[index].name.length - 1; //  5
                        print("类容：${list[index].name}___${list[index].name.length}");
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
                              ToastShow.show(msg: "你已添加此话题", context: context, gravity: Toast.CENTER);
                              return;
                            } else if (atRule.id == -1 && atRule.params == list[index].name) {
                              ToastShow.show(msg: "你已添加此话题", context: context, gravity: Toast.CENTER);
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
                          print("topicRearStr:$topicRearStr");
                        }
                        // 点击的文本
                        String topicMiddleStr = list[index].name.substring(1, list[index].name.length);
                        print("点击的文本：${topicMiddleStr}");
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
                          print(rules[i].params.length);
                          print("规则内的值${widget.controller.text.substring(rules[i].startIndex, rules[i].endIndex)}");
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
                        print(rules.first.params.length);
                        context.read<ReleaseFeedInputNotifier>().setTopicSearchStr("");
                        // 关闭视图
                        context.read<ReleaseFeedInputNotifier>().changeCallback("");
                      },
                      child: Container(
                        margin: const EdgeInsets.only(left: 16),
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
                            const SizedBox(
                              height: 2,
                            ),
                            Text(
                              list[index].id != -1 ? "${StringUtil.getNumber(list[index].feedCount)}篇动态" : "创建新话题",
                              style: AppStyle.textSecondaryRegular12,
                            ),
                            const SizedBox(
                              height: 4,
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
