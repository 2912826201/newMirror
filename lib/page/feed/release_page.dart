// import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mirror/api/home/home_feed_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/media_file_model.dart';
import 'package:mirror/data/model/upload/upload_result_model.dart';
import 'package:mirror/page/media_picker/media_picker_page.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/file_util.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/custom_button.dart';
import 'package:mirror/widget/feed/release_feed_input_formatter.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:text_span_field/range_style.dart';
import 'package:text_span_field/text_span_field.dart';
import 'package:toast/toast.dart';

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
  void initState() {
    //TODO 取出来判断是否为空 非空则将图片视频作为初始值 取出后需将Application中的值清空
    print("查明￥${Application.selectedMediaFiles}");
    _selectedMediaFiles = Application.selectedMediaFiles;
    Application.selectedMediaFiles = null;
    // context.read<ReleaseFeedInputNotifier>().setSelectedMediaFiles(_selectedMediaFiles);
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
                    // 中间主视图
                    Expanded(
                        child: Container(
                            margin: EdgeInsets.only(bottom: inputHeight),
                            child: CustomScrollView(
                              slivers: [
                                // 输入框
                                SliverToBoxAdapter(
                                  child: KeyboardInput(controller: _controller),
                                ),
                                SliverList(
                                  delegate: SliverChildBuilderDelegate((content, index) {
                                    return str == "@"
                                        ? AtList(index: index, controller: _controller)
                                        : str == "#"
                                            ? TopicList(index: index, controller: _controller)
                                            : ReleaseFeedMainView(selectedMediaFiles: _selectedMediaFiles);
                                  },
                                      childCount: str == "@"
                                          ? 10
                                          : str == "#"
                                              ? 10
                                              : 1),
                                )
                              ],
                            )))
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
  pulishFeed(String inputText, List<Rule> rule, BuildContext context) async {
    print("输入框文字￥$inputText");
    print("打印一下规则$rule");
    print(selectedMediaFiles.list.length);
    List<File> fileList = [];
    UploadResults results;
    List<PicUrlsModel> picUrls = [];
    List<VideosModel> videos = [];
    // 检测文本
    Map<String, dynamic> textModel = await feedTextScan(text: inputText);
    if (textModel["state"]) {
      // 上传图片
      if (selectedMediaFiles.type == mediaTypeKeyImage) {
        selectedMediaFiles.list.forEach((element) async {
          if (element.croppedImageData == null) {
            fileList.add(element.file);
          } else {
            fileList.add(await FileUtil().writeImageDataToFile(element.croppedImageData));
          }
          picUrls.add(PicUrlsModel(width: element.sizeInfo.width, height: element.sizeInfo.height));
        });
        results = await FileUtil().uploadPics(fileList, (path, percent) {});
        print(results.isSuccess);
        for (int i = 0; i < results.resultMap.length; i++) {
          print("打印一下索引值￥$i");
          UploadResultModel model = results.resultMap.values.elementAt(i);
          picUrls[i].url = model.url;
        }
      } else if (selectedMediaFiles.type == mediaTypeKeyVideo) {
        selectedMediaFiles.list.forEach((element) {
          fileList.add(element.file);
          videos.add(VideosModel(
              width: element.sizeInfo.width, height: element.sizeInfo.height, duration: element.sizeInfo.duration));
        });
        results = await FileUtil().uploadMedias(fileList, (path, percent) {});
        for (int i = 0; i < results.resultMap.length; i++) {
          print("打印一下视频索引值￥$i");
          UploadResultModel model = results.resultMap.values.elementAt(i);
          videos[i].url = model.url;
          videos[i].coverUrl = model.url + "?vframe/jpg/offset/1";
        }
      }
      // await publishFeed(type: 0, content: inputText, picUrls: jsonEncode(picUrls), videos: jsonEncode(videos));
    } else {
      ToastShow.show(msg:"你发布的动态可能存在敏感内容",context: context,gravity: Toast.CENTER);
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
                pulishFeed(inputText, rules,context);
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

  // 判断是否只是切换光标
  bool isSwitchCursor = true;

  @override
  void initState() {
    widget.controller.addListener(() {
      print("值改变了");
      print("监听文字光标${widget.controller.selection}");
      // 每次点击切换光标会进入此监听。需求邀请@和话题光标不可移入其中。
      print("::::::$isSwitchCursor");
      if (isSwitchCursor) {
        List<Rule> rules = context.read<ReleaseFeedInputNotifier>().rules;
        int atIndex = context.read<ReleaseFeedInputNotifier>().atCursorIndex;
        int topicIndex = context.read<ReleaseFeedInputNotifier>().topicCursorIndex;
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
        if (cursorIndex != atIndex || cursorIndex != topicIndex) {
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
      valueChangedCallback:
          (List<Rule> rules, String value, int atIndex, int topicIndex, String atSearchStr, String topicSearchStr) {
        rules = rules;
        print("输入框值回调：$value");
        print(rules);
        isSwitchCursor = false;
        if (atIndex > 0) {
          context.read<ReleaseFeedInputNotifier>().getAtCursorIndex(atIndex);
        }
        if (topicIndex > 0) {
          context.read<ReleaseFeedInputNotifier>().getTopicCursorIndex(topicIndex);
        }
        context.read<ReleaseFeedInputNotifier>().setAtSearchStr(atSearchStr);
        context.read<ReleaseFeedInputNotifier>().setTopicSearchStr(topicSearchStr);
        context.read<ReleaseFeedInputNotifier>().getInputText(value);
        // 实时搜索
      },
    );
    _init();
    super.initState();
  }

  /// 获得文本输入框样式
  List<RangeStyle> getTextFieldStyle(List<Rule> rules) {
    List<RangeStyle> result = [];
    for (Rule rule in rules) {
      result.add(
        RangeStyle(
          range: TextRange(start: rule.startIndex, end: rule.endIndex),
          style: TextStyle(color: Color(0xFF9C7BFF)),
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
        focusNode: FocusNode(),
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

class TopicModel {
  String topic;
  String topicSubStr;

  TopicModel({this.topic, this.topicSubStr});
}

// 话题列表
class TopicList extends StatelessWidget {
  final index;
  TextEditingController controller;

  TopicList({this.index, this.controller});

  List<TopicModel> topics = [
    TopicModel(topic: "#坚持健身的动力", topicSubStr: "哈哈1"),
    TopicModel(topic: "#坚持健身的动力啊啊", topicSubStr: "哈哈飒飒2"),
    TopicModel(topic: "#坚持健身的动力十点多", topicSubStr: "哈哈撒触发3"),
    TopicModel(topic: "#坚持健水电费身的动力", topicSubStr: "哈哈奥术大师4"),
    TopicModel(topic: "#胜多负少的的动力", topicSubStr: "哈哈撒大声地5"),
    TopicModel(topic: "#坚持健身胜多负少的的动力", topicSubStr: "哈哈梵蒂冈地方6"),
    TopicModel(topic: "#佛挡杀佛", topicSubStr: "哈哈鬼地方个地方7"),
    TopicModel(topic: "#奥术大师大所大所大所多", topicSubStr: "哈哈和官方回复8"),
    TopicModel(topic: "#萨达所大所大", topicSubStr: "哈哈价格好几个9"),
    TopicModel(topic: "#sad撒大所大所大所大所大所", topicSubStr: "哈哈讲话稿几个10"),
    TopicModel(topic: "#坚发的啥地方胜多负少的持健身的动力", topicSubStr: "哈哈半年才能保持11"),
  ];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        // 点击空白区域响应事件
        behavior: HitTestBehavior.opaque,
        onTap: () {
          // #的文字长度
          int topicLength = topics[index].topic.length - 1;
          // 获取比较规则
          var rules = context.read<ReleaseFeedInputNotifier>().rules;
          // 获取实时搜索文本
          String searchStr = context.read<ReleaseFeedInputNotifier>().topicSearchStr;
          // 检测是否添加过
          if (rules.isNotEmpty) {
            for (Rule atRule in rules) {
              if (atRule.clickIndex == index && atRule.isAt == false) {
                print("已经添加过了");
                return;
              }
            }
          }
          // 获取#的光标
          int topicIndex = context.read<ReleaseFeedInputNotifier>().topicCursorIndex;
          // #前的文字
          String topicBeforeStr = controller.text.substring(0, topicIndex);
          // #后的文字
          String topicRearStr = "";
          print(searchStr);
          print("controller.text:${controller.text}");
          print("topicBeforeStr$topicBeforeStr");
          if (searchStr != "" || searchStr.isNotEmpty) {
            print("topicIndex:$topicIndex");
            print("searchStr:$searchStr");
            print("controller.text:${controller.text}");
            topicRearStr = controller.text.substring(topicIndex + searchStr.length, controller.text.length);
            print("topicRearStr:$topicRearStr");
          } else {
            topicRearStr = controller.text.substring(topicIndex, controller.text.length);
          }
          // 点击的文本
          String topicMiddleStr = topics[index].topic.substring(1, topics[index].topic.length);
          // 拼接修改输入框的值
          controller.text = topicBeforeStr + topicMiddleStr + topicRearStr;
          print("controller.text ${controller.text}");
          // 这是替换输入的文本修改后面输入的#的规则
          if (searchStr != "" || searchStr.isNotEmpty) {
            print("话题替换");
            int oldLength = searchStr.length;
            int newLength = topics[index].topic.length - 1;
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
            if (rules[i].params != controller.text.substring(rules[i].startIndex, rules[i].endIndex)) {
              print(rules[i]);
              rules[i] = Rule(rules[i].startIndex + topicLength, rules[i].endIndex + topicLength, rules[i].params,
                  rules[i].clickIndex, rules[i].isAt);
              print(rules[i]);
            }
          }
          // 存储规则
          context
              .read<ReleaseFeedInputNotifier>()
              .addRules(Rule(topicIndex - 1, topicIndex + topicLength, topics[index].topic, index, false));
          // 设置光标
          var setCursor = TextSelection(
            baseOffset: controller.text.length,
            extentOffset: controller.text.length,
          );
          controller.selection = setCursor;
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
                topics[index].topic,
                style: AppStyle.textRegular16,
              ),
              SizedBox(
                height: 2,
              ),
              Text(
                topics[index].topicSubStr,
                style: AppStyle.textSecondaryRegular12,
              ),
              SizedBox(
                height: 6,
              ),
            ],
          ),
        ));
  }
}

// @联系人列表
class AtList extends StatelessWidget {
  AtList({this.controller, this.index});

  int index;
  TextEditingController controller;

  List<String> stings = ["换行", "是撒", "阿斯达", "奥术大师", "奥术大师多", "胜多负少", "豆腐干豆腐", "爽肤水", "出现橙", "阿斯达"];

  @override
  Widget build(BuildContext context) {
    // var atName = context.watch<ReleaseFeedInputNotifier>().getAtName( stings[index]);

    return GestureDetector(
      // 点击空白区域响应事件
      behavior: HitTestBehavior.opaque,
      onTap: () {
        // At的文字长度
        int AtLength = stings[index].length;
        // 获取输入框内的规则
        var rules = context.read<ReleaseFeedInputNotifier>().rules;
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
        int atIndex = context.read<ReleaseFeedInputNotifier>().atCursorIndex;
        // 获取实时搜索文本
        String searchStr = context.read<ReleaseFeedInputNotifier>().atSearchStr;
        // @前的文字
        String atBeforeStr = controller.text.substring(0, atIndex);
        // @后的文字
        String atRearStr = "";
        print(searchStr);
        print("controller.text:${controller.text}");
        print("atBeforeStr$atBeforeStr");
        if (searchStr != "" || searchStr.isNotEmpty) {
          print("atIndex:$atIndex");
          print("searchStr:$searchStr");
          print("controller.text:${controller.text}");
          atRearStr = controller.text.substring(atIndex + searchStr.length, controller.text.length);
          print("atRearStr:$atRearStr");
        } else {
          atRearStr = controller.text.substring(atIndex, controller.text.length);
        }

        // 拼接修改输入框的值
        controller.text = atBeforeStr + stings[index] + atRearStr;
        print("controller.text:${controller.text}");
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
          if (rules[i].params != controller.text.substring(rules[i].startIndex, rules[i].endIndex)) {
            print("进入");
            print(rules[i]);
            rules[i] = Rule(rules[i].startIndex + AtLength, rules[i].endIndex + AtLength, rules[i].params,
                rules[i].clickIndex, rules[i].isAt);
            print(rules[i]);
          }
        }
        // 存储规则
        context
            .read<ReleaseFeedInputNotifier>()
            .addRules(Rule(atIndex - 1, atIndex + AtLength, "@" + stings[index], index, true));
        // 设置光标
        var setCursor = TextSelection(
          baseOffset: controller.text.length,
          extentOffset: controller.text.length,
        );
        print("设置光标${setCursor}");
        controller.selection = setCursor;
        context.read<ReleaseFeedInputNotifier>().setAtSearchStr("");
        // 关闭视图
        context.read<ReleaseFeedInputNotifier>().changeCallback("");
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
  seletedAddress() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
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
      decoration: BoxDecoration(color: AppColor.textHint, borderRadius: BorderRadius.all(Radius.circular(3))),
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
        seletedAddress(),
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
              context, 9 - widget.selectedMediaFiles.list.length, type, true, startPageGallery, false, false,
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
                            widget.selectedMediaFiles.list.removeAt(index);
                            if (widget.selectedMediaFiles.list.length == 0) {
                              widget.selectedMediaFiles.type = null;
                            }
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

  // 发布动态选择的图片视频
  SelectedMediaFiles selectedMediaFiles;

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
}
