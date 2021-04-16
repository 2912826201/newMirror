import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/api/training/live_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/config/shared_preferences.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/message/chat_type_model.dart';
import 'package:mirror/data/model/message/emoji_model.dart';
import 'package:mirror/data/model/profile/buddy_list_model.dart';
import 'package:mirror/page/message/item/emoji_manager.dart';
import 'package:mirror/util/click_util.dart';
import 'package:mirror/util/date_util.dart';
import 'package:mirror/util/event_bus.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/toast_util.dart';
import 'package:mirror/widget/dialog.dart';
import 'package:mirror/widget/icon.dart';
import 'package:mirror/widget/no_blue_effect_behavior.dart';
import 'package:mirror/widget/state_build_keyboard.dart';
import 'package:mirror/widget/text_span_field/text_span_field.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

import 'dialog/live_room_setting_dialog.dart';
import 'dialog/live_room_online_man_number_dialog.dart';
import 'live_room_page_common.dart';

class LiveRoomVideoOperationPage extends StatefulWidget {
  final int liveCourseId;
  final int coachId;
  final String coachUrl;
  final String coachName;
  final String startTime;
  final int coachRelation;
  final Function(int relation) callback;

  const LiveRoomVideoOperationPage({
    Key key,
    @required this.liveCourseId,
    @required this.coachName,
    @required this.coachUrl,
    @required this.startTime,
    @required this.coachRelation,
    @required this.callback,
    @required this.coachId,
  }) : super(key: key);

  @override
  _LiveRoomVideoOperationPageState createState() => _LiveRoomVideoOperationPageState(coachRelation);
}

class _LiveRoomVideoOperationPageState extends StateKeyboard<LiveRoomVideoOperationPage> {
  _LiveRoomVideoOperationPageState(this.coachRelation);

  //与教练的关系
  int coachRelation;

  List<UserMessageModel> messageChatList = [];

  ///输入框的监听
  TextEditingController _textController = TextEditingController();

  ///输入框的焦点
  FocusNode _focusNode = new FocusNode();

  bool isShowEditPlan = false;
  bool isShowEmojiBtn = true;

  //是否显示弹幕消息
  bool isShowMessage = true;

  //清洁模式
  bool isCleaningMode = false;

  ///表情的列表
  List<EmojiModel> emojiModelList = <EmojiModel>[];
  List<BuddyModel> onlineManList = <BuddyModel>[];
  List<int> onlineManUidList = <int>[];

  bool _emojiState = false;
  bool _emojiStateOld = false;
  bool _bottomSettingPanelState = false;

  int cursorIndexPr = -1;

  int onlineUserNumber = 2;
  Timer timer;
  Widget timeText;
  Widget onlineMenNumberText;

  List<String> urlImageList = <String>[];

  bool bottomBarHeightColorIsWhite = false;

  StreamController<int> userImageOnlineStream = StreamController.broadcast();
  StreamController<int> messageListStream = StreamController.broadcast();
  StreamController<int> messageCantSendStream = StreamController.broadcast();

  @override
  void initState() {
    super.initState();
    print("开播时间是:${widget.startTime},${widget.coachId}");

    EventBus.getDefault().registerSingleParameter(_receiveBarrageMessage, EVENTBUS_ROOM_OPERATION_PAGE,
        registerName: EVENTBUS_ROOM_RECEIVE_BARRAGE);
    EventBus.getDefault().registerSingleParameter(_receiveNoticeMessage, EVENTBUS_ROOM_OPERATION_PAGE,
        registerName: EVENTBUS_ROOM_RECEIVE_NOTICE);
    EventBus.getDefault().registerNoParameter(_onClickBodyListener, EVENTBUS_ROOM_OPERATION_PAGE,
        registerName: EVENTBUS_ON_CLICK_BODY);
    EventBus.getDefault().registerSingleParameter(_liveCourseStatus, EVENTBUS_ROOM_OPERATION_PAGE,
        registerName: LIVE_COURSE_LIVE_START_OR_END);


    urlImageList.add("");
    urlImageList.add(widget.coachUrl);
    urlImageList.add(Application.profile.avatarUri);

    timeText = LiveRoomPageCommon.init().getLiveRoomShowTimeUi(widget.startTime);
    onlineMenNumberText = LiveRoomPageCommon.init().getLiveOnlineMenNumberUi(onlineUserNumber);

    messageChatList.add(UserMessageModel(messageContent: "请遵守直播间规则" * 10));
    messageChatList.insert(
        0,
        UserMessageModel(
          name: Application.profile.nickName,
          uId: Application.profile.uid.toString(),
          messageContent: "进入了直播",
          isJoinLiveRoomMessage: true,
        ));

    _focusNode.addListener(() {
      cursorIndexPr = _textController.selection.baseOffset;
    });
    initData();
    _initTimeDuration();
  }

  void _liveCourseStatus(List list){
    if(list!=null&&list[1]==widget.liveCourseId){
      switch(list[0]){
        case 0:
        //0-直播开始
          print("直播开始");
          break;
        case 3:
        //0-直播结束
          print("直播结束");
          ToastShow.show(msg: "直播已结束", context: context);
          _exitPage();
          break;
        default:
          break;
      }
    }
  }

  // getTopUi(),
  // (!isCleaningMode) ? getHaveMessageBottomPlan() : getNoMessageBottomPlan(),
  @override
  Widget build(BuildContext context) {
    print("buildbuildbuildbuildbuildbuildbuild");
    return WillPopScope(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.transparent,
          body: GestureDetector(
            child: Container(
              color: AppColor.transparent,
              child: Stack(
                children: [
                  Positioned(
                    child: (!isCleaningMode) ? getHaveMessageBottomPlan() : getNoMessageBottomPlan(),
                    left: 0,
                    right: 0,
                    bottom: 0,
                  ),
                  Positioned(
                    child: getTopUi(),
                    left: 0,
                    right: 0,
                    top: 0,
                  ),
                ],
              ),
            ),
            onTap: _onClickBodyListener,
          ),
        ),
        onWillPop: _requestPop);
  }

  Widget getTopUi() {
    return Container(
      margin: EdgeInsets.only(top: ScreenUtil.instance.statusBarHeight + 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          getTopInformationUi(),
          SizedBox(height: 16),
          Visibility(
            visible: !isCleaningMode,
            child: GestureDetector(
              child: otherUserUi(),
              onTap: () {
                _onClickBodyListener();
                openBottomOnlineManNumberDialog(
                  buildContext: context,
                  liveRoomId: widget.coachId,
                  onlineManList: onlineManList,
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget getHaveMessageBottomPlan() {
    return Container(
      color: AppColor.transparent,
      alignment: Alignment.bottomCenter,
      child: getBottomPlan(),
    );
  }

  Widget getNoMessageBottomPlan() {
    return Container(
      height: 48.0 + ScreenUtil.instance.bottomBarHeight,
      padding: EdgeInsets.only(bottom: ScreenUtil.instance.bottomBarHeight),
      margin: EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerRight,
      child: UnconstrainedBox(
        child: AppIconButton(
          svgName: AppIcon.close_24,
          iconColor: AppColor.white,
          iconSize: 24,
          bgColor: AppColor.white.withOpacity(0.06),
          isCircle: true,
          buttonWidth: 32,
          buttonHeight: 32,
          onTap: _exitPageListener,
        ),
      ),
    );
  }

  //其他用户-一起运动
  Widget otherUserUi() {
    return Container(
      height: 36.0,
      width: 120.0,
      decoration: BoxDecoration(
        color: AppColor.white.withOpacity(0.06),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24), bottomLeft: Radius.circular(24)),
      ),
      child: Row(
        children: [
          Expanded(child: SizedBox()),
          Container(
            width: 21.0 * 3 - 12.0,
            height: 21.0,
            child: StreamBuilder(
              stream: userImageOnlineStream.stream,
              builder: (context, snapshot) {
                return Stack(
                  children: [
                    Positioned(
                      child: LiveRoomPageCommon.init().getUserImage(urlImageList[2], 21, 21),
                      right: 0,
                    ),
                    Positioned(
                      child: LiveRoomPageCommon.init().getUserImage(urlImageList[1], 21, 21),
                      right: 12,
                    ),
                    Positioned(
                      child: LiveRoomPageCommon.init().getUserImage(urlImageList[0], 21, 21),
                      right: 24,
                    ),
                  ],
                );
              },
            ),
          ),
          SizedBox(width: 6),
          Text("一起运动", style: TextStyle(fontSize: 10, color: AppColor.white.withOpacity(0.85))),
          SizedBox(width: 16),
        ],
      ),
    );
  }

  Widget getTopInformationUi() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          getCoachNameUi(),
          Expanded(child: SizedBox()),
          trainingTimeUi(),
        ],
      ),
    );
  }

  Widget getCoachNameUi() {
    return UnconstrainedBox(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: AppColor.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            LiveRoomPageCommon.init().getUserImage(widget.coachUrl, 28, 28),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.coachName, style: TextStyle(fontSize: 11, color: AppColor.white.withOpacity(0.85))),
                onlineMenNumberText,
              ],
            ),
            SizedBox(width: 8),
            getFollowBtn(),
          ],
        ),
      ),
    );
  }

  Widget getFollowBtn() {
    if (coachRelation == 1 || coachRelation == 3) {
      return Container();
    }
    return GestureDetector(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(100)),
          color: AppColor.mainRed,
        ),
        padding: const EdgeInsets.only(left: 11, right: 11, top: 2, bottom: 2),
        child: Text(
          coachRelation == 1 || coachRelation == 3 ? "已关注" : "关注",
          style: TextStyle(
              color: coachRelation == 1 || coachRelation == 3 ? AppColor.textHint : AppColor.white, fontSize: 11),
        ),
      ),
      onTap: _onClickAttention,
    );
  }

  //训练
  Widget trainingTimeUi() {
    return Container(
      child: Column(
        children: [
          timeText,
          Text("训练时长", style: TextStyle(fontSize: 10, color: AppColor.white.withOpacity(0.35))),
        ],
      ),
    );
  }

  Widget getBottomPlan() {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black,
                Colors.black,
                Colors.black,
                Colors.black,
                // Colors.transparent,
              ],
            ).createShader(Rect.fromLTRB(0, 0, bounds.width, bounds.height));
          },
          blendMode: BlendMode.dstIn,
          child: Container(
            height: getBottomMessageHeight(),
            child: getListView(),
          ),
        ),
        Container(
          height: 48.0,
          child: Stack(
            children: [
              getBottomBarShowTextPanel(),
              getBottomBarAnimatedContainer(),
            ],
          ),
        ),
        Container(
          color: (_focusNode.hasFocus || isShowEditPlan || _emojiState || bottomBarHeightColorIsWhite||_emojiStateOld)
              ? AppColor.white
              : AppColor.transparent,
          child: Column(
            children: [
              bottomSettingBox(),
              Container(
                height: ScreenUtil.instance.bottomBarHeight + 10,
                color: (_focusNode.hasFocus || isShowEditPlan || _emojiState || bottomBarHeightColorIsWhite)
                    ? AppColor.white
                    : AppColor.transparent,
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget getListView() {
    return Visibility(
      visible: isShowMessage,
      child: StreamBuilder(
        stream: messageListStream.stream,
        builder: (context, snapshot) {
          return ListView.builder(
            reverse: true,
            physics: BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return getListViewItem(index);
            },
            itemCount: messageChatList.length,
          );
        },
      ),
    );
  }

  Widget getListViewItem(int index) {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 28, bottom: 4, top: 4),
      child: UnconstrainedBox(
        alignment: Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: ScreenUtil.instance.width - 16 - 28,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          decoration: BoxDecoration(
            color: AppColor.bgWhite.withOpacity(0.06),
            borderRadius: BorderRadius.circular(11.5),
          ),
          child: LiveRoomPageCommon.init().getLiveRoomMessageText(messageChatList[index]),
        ),
      ),
    );
  }

  Widget getBottomBarAnimatedContainer() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 50),
      height: (_focusNode.hasFocus || isShowEditPlan || _emojiState||_emojiStateOld) ? 48.0 : 0.0,
      child: getBottomBarEditTextPanel(),
    );
  }

  Widget getBottomBarEditTextPanel() {
    return Container(
      height: (_focusNode.hasFocus || isShowEditPlan || _emojiState||_emojiStateOld) ? 48.0 : 0.0,
      // height: 48.0,
      child: SingleChildScrollView(
        child: Container(
          color: AppColor.white,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColor.bgWhite.withOpacity(0.65),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(child: SizedBox(child: edit())),
                Container(
                  height: 32.0,
                  width: 48.0,
                  padding: EdgeInsets.only(left: 10),
                  child: AppIconButton(
                    onTap: () {
                      if (ClickUtil.isFastClick()) {
                        return;
                      }
                      _emojiStateOld=_emojiState;
                      if (isShowEmojiBtn) {
                        _emojiState = isShowEmojiBtn;
                        isShowEditPlan = false;
                        isShowEmojiBtn = !isShowEmojiBtn;
                        if (_focusNode.hasFocus) {
                          _focusNode.unfocus();
                        }else{
                          setState(() {
                            print("setState-111111111111111111");
                          });
                        }
                      } else {
                        _emojiState = isShowEmojiBtn;
                        isShowEditPlan = false;
                        isShowEmojiBtn = !isShowEmojiBtn;
                        _bottomSettingPanelState=!_emojiState;
                        FocusScope.of(context).requestFocus(_focusNode);
                        // Future.delayed(Duration(milliseconds: 100),(){
                        //   if(MediaQuery.of(this.context).viewInsets.bottom<1){
                        //     _bottomSettingPanelState = false;
                        //     setState(() {});
                        //   }
                        // });
                      }
                    },
                    iconSize: 24,
                    buttonWidth: 36,
                    buttonHeight: 36,
                    svgName: isShowEmojiBtn ? AppIcon.input_emotion : AppIcon.input_keyboard,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //键盘与表情的框
  Widget bottomSettingBox() {
    List<Widget> widgetList = [];

    double keyboardHeight = 300.0;

    if (Application.keyboardHeightChatPage > 0) {
      keyboardHeight = Application.keyboardHeightChatPage;
    } else if (Application.keyboardHeightIfPage > 0) {
      Application.keyboardHeightChatPage = Application.keyboardHeightIfPage;
      keyboardHeight = Application.keyboardHeightChatPage;
    }
    if (keyboardHeight < 90) {
      keyboardHeight = 300.0;
    }

    widgetList.add(bottomSettingPanel(keyboardHeight));

    if ((_emojiState ? keyboardHeight : 0.0) > 0) {
      widgetList.add(emojiPlan(keyboardHeight));
    }

    return Container(
      child: Stack(
        children: widgetList,
      ),
    );
  }

  Widget bottomSettingPanel(double keyboardHeight) {
    print("bottomSettingPanel:$_bottomSettingPanelState,$keyboardHeight");
    return AnimatedContainer(
      duration: Duration(milliseconds: 50),
      height: _bottomSettingPanelState||_emojiState ? keyboardHeight : 0.0,
      child: Container(
        height: _bottomSettingPanelState||_emojiState ? keyboardHeight : 0.0,
        width: double.infinity,
        color: AppColor.white,
      ),
    );
  }

  //表情框
  Widget emojiPlan(double keyboardHeight) {
    print("_emojiState:$_emojiState,$keyboardHeight");
    return AnimatedContainer(
      duration: Duration(milliseconds: 50),
      height: _emojiState ? keyboardHeight : 0.0,
      child: Container(
        height: _emojiState ? keyboardHeight : 0.0,
        width: double.infinity,
        color: AppColor.white,
        child: emojiList(keyboardHeight),
      ),
    );
  }

  //emoji具体是什么界面
  Widget emojiList(double keyboardHeight) {
    if (emojiModelList == null || emojiModelList.length < 1) {
      return Center(
        child: Text("暂无表情"),
      );
    } else {
      return GestureDetector(
        child: Container(
          width: double.infinity,
          color: AppColor.white,
          child: ScrollConfiguration(
            behavior: NoBlueEffectBehavior(),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    height: 0.2,
                    color: Colors.grey,
                  ),
                ),
                SliverToBoxAdapter(
                  child: _emojiGridTop(keyboardHeight),
                ),
                SliverToBoxAdapter(
                  child: _emojiBottomBox(),
                ),
              ],
            ),
          ),
        ),
        onTap: () {},
      );
    }
  }

  //获取表情头部的 内嵌的表情
  Widget _emojiGridTop(double keyboardHeight) {
    return Container(
      height: keyboardHeight - 45.0,
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 0),
      child: GridView.builder(
        padding: const EdgeInsets.only(top: 10),
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
        color: Colors.white,
        child: new InkWell(
          child: Container(
            alignment: Alignment.center,
            child: Text(
              emojiModel.emoji,
              style: textStyle,
            ),
          ),
          onTap: () {
            addEmoji(emojiModel.code);
          },
        ));
  }

  void addEmoji(String emojiModelCode) {
    if (_textController.text == null || _textController.text.length < 1) {
      _textController.text = "";
      cursorIndexPr = 0;
    }
    if (cursorIndexPr >= 0) {
      _textController.text = _textController.text.substring(0, cursorIndexPr) +
          emojiModelCode +
          _textController.text.substring(cursorIndexPr, _textController.text.length);
    } else {
      _textController.text += emojiModelCode;
    }
    cursorIndexPr += emojiModelCode.length;
    messageCantSendStream.sink.add(0);
  }

  //表情的bar
  Widget _emojiBottomBox() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(
          top: BorderSide(color: AppColor.bgWhite, width: 1),
        ),
      ),
      padding: const EdgeInsets.only(left: 10, right: 10),
      width: double.infinity,
      height: 44,
      child: Row(
        children: [
          AppIconButton(
            iconSize: 24,
            svgName: AppIcon.message_emotion,
            buttonWidth: 44,
            buttonHeight: 44,
            onTap: () {},
          ),
          Spacer(),
          AppIconButton(
            iconSize: 24,
            svgName: AppIcon.message_delete,
            buttonWidth: 44,
            buttonHeight: 44,
            onTap: _deleteEditText,
          ),
          StreamBuilder(
            stream: messageCantSendStream.stream,
            builder: (context, snapshot) {
              return AppIconButton(
                iconSize: 24,
                svgName: _textController.text == null || _textController.text.isEmpty
                    ? AppIcon.message_cant_send
                    : AppIcon.message_send,
                buttonWidth: 44,
                buttonHeight: 44,
                onTap: () {
                  _onSubmitClick(_textController.text);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  //输入框bar内的edit
  Widget edit() {
    return TextSpanField(
      onTap: () {
        _emojiStateOld=_emojiState;
        pageHeightStopCanvas = true;
        oldKeyboardHeight = -1;
        isShowEmojiBtn = true;
        _emojiState = false;
        _bottomSettingPanelState = true;
        print("_bottomSettingPanelState:设置true");
        startOpenKeyBoardHeight();
        // Future.delayed(Duration(milliseconds: 100),(){
        //   if(MediaQuery.of(this.context).viewInsets.bottom<1){
        //     _bottomSettingPanelState = false;
        //   }else{
        //     _bottomSettingPanelState = true;
        //   }
        //   setState(() {});
        // });
        // setState(() {});
      },
      onLongTap: () {
        _emojiStateOld=_emojiState;
        pageHeightStopCanvas = true;
        oldKeyboardHeight = -1;
        isShowEmojiBtn = true;
        _emojiState = false;
        _bottomSettingPanelState = true;
        print("_bottomSettingPanelState:设置true");
        startOpenKeyBoardHeight();
        // Future.delayed(Duration(milliseconds: 100),(){
        //   if(MediaQuery.of(this.context).viewInsets.bottom<1){
        //     _bottomSettingPanelState = false;
        //   }else{
        //     _bottomSettingPanelState = true;
        //   }
        //   setState(() {});
        // });
        // setState(() {});
      },
      controller: _textController,
      focusNode: _focusNode,
      // 多行展示
      keyboardType: TextInputType.multiline,
      //不限制行数
      maxLines: 1,
      enableInteractiveSelection: true,
      // 光标颜色
      cursorColor: Color.fromRGBO(253, 137, 140, 1),
      scrollPadding: EdgeInsets.all(0),
      style: TextStyle(fontSize: 14, color: AppColor.textPrimary1),
      //内容改变的回调
      onChanged: (text) {
        messageCantSendStream.sink.add(0);
      },
      textInputAction: TextInputAction.send,
      onSubmitted: _onSubmitClick,
      // 装饰器修改外观
      decoration: InputDecoration(
        // 去除下滑线
        border: InputBorder.none,
        // 提示文本
        hintText: "说点什么吧...",
        // 提示文本样式
        hintStyle: TextStyle(fontSize: 14, color: AppColor.textHint),
        // 设置为true,contentPadding才会生效，TextField会有默认高度。
        isCollapsed: true,
        contentPadding: EdgeInsets.only(top: 6, bottom: 4, left: 16, right: 16),
      ),
    );
  }

  Widget getBottomBarShowTextPanel() {
    return Container(
      height: 48.0,
      alignment: Alignment.centerLeft,
      color: AppColor.transparent,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(child: SizedBox(child: getTextEditUi())),
          AppIconButton(
            svgName: isCleaningMode ? AppIcon.danmaku_on : AppIcon.danmaku_off,
            iconColor: AppColor.white,
            iconSize: 24,
            bgColor: AppColor.white.withOpacity(0.06),
            isCircle: true,
            buttonWidth: 32,
            buttonHeight: 32,
            onTap: () {
              setState(() {
                isCleaningMode = !isCleaningMode;
                print("setState-3333333333333333333");
              });
            },
          ),
          SizedBox(width: 12),
          AppIconButton(
            svgName: AppIcon.settings_24,
            iconColor: AppColor.white,
            iconSize: 24,
            bgColor: AppColor.white.withOpacity(0.06),
            isCircle: true,
            buttonWidth: 32,
            buttonHeight: 32,
            onTap: () {
              openBottomSetDialog(buildContext: context, voidCallback: _isCleaningMode);
            },
          ),
          SizedBox(width: 12),
          AppIconButton(
            svgName: AppIcon.close_24,
            iconColor: AppColor.white,
            iconSize: 24,
            bgColor: AppColor.white.withOpacity(0.06),
            isCircle: true,
            buttonWidth: 32,
            buttonHeight: 32,
            onTap: _exitPageListener,
          ),
        ],
      ),
    );
  }

  void _isCleaningMode(bool isCleaningMode) {
    print("isCleaningMode:$isCleaningMode");
    Future.delayed(Duration(milliseconds: 50), () {
      setState(() {
        this.isCleaningMode = isCleaningMode;
        print("setState-4444444444444444444444");
      });
    });
  }

  Widget getTextEditUi() {
    return GestureDetector(
      child: Container(
        height: 32,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.only(left: 16),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: AppColor.bgWhite.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text("说点什么吧...", style: TextStyle(color: AppColor.white.withOpacity(0.35), fontSize: 14)),
      ),
      onTap: () {
        if (ClickUtil.isFastClick()) {
          return;
        }
        if (isMuteJudge()) {
          ToastShow.show(msg: "您已被禁言请稍后再发", context: context, gravity: 1);
          return;
        }
        isShowEditPlan = true;
        setState(() {
          print("setState-55555555555555555");
        });
        Future.delayed(Duration(milliseconds: 80), () {
          pageHeightStopCanvas = true;
          oldKeyboardHeight = 0;
          isShowEmojiBtn = true;
          _emojiState = false;
          FocusScope.of(context).requestFocus(_focusNode);
        });
      },
    );
  }

  bool isMuteJudge() {
    List list = AppPrefs.getLiveRoomMute(widget.coachId.toString());
    if (list[0]) {
      int seconds = DateUtil.twoDateTimeSeconds(DateUtil.getDateTimeByMs(list[1]), DateTime.now());
      print("seconds:$seconds,list[2]:${list[2]}");
      if (list[2] < 0) {
        return !(seconds > 3600);
      } else {
        return list[2] > seconds;
      }
    }
    return false;
  }

  //获取底部评论列表的高度
  double getBottomMessageHeight() {
    return (ScreenUtil.instance.height -
            ScreenUtil.instance.statusBarHeight -
            ScreenUtil.instance.bottomBarHeight -
            48.0) *
        0.25;
  }

  void initData() async {
    //获取表情的数据
    emojiModelList = await EmojiManager.getEmojiModelList();
    Map<String, dynamic> map = await roomInfo(widget.coachId, count: 3);
    if (null != map["data"]["total"]) {
      resetOnlineUserNumber(map["data"]["total"]);
    }
    if (null != map["data"]["userList"]) {
      map["data"]["userList"].forEach((v) {
        BuddyModel buddyModel = BuddyModel.fromJson(v);
        onlineManList.add(BuddyModel.fromJson(v));
        onlineManUidList.add(buddyModel.uid);
      });
    }
    getAllOnlineUserNumber(onlineUserNumber + 1);
    resetOnlineUserImage();
  }

  //获取所有的在线人数
  void getAllOnlineUserNumber(int number) async {
    Future.delayed(Duration(seconds: 2), () async {
      print("number:$number");
      Map<String, dynamic> map = await roomInfo(widget.coachId, count: number);
      if (null != map["data"]["userList"]) {
        onlineManList.clear();
        onlineManUidList.clear();
        map["data"]["userList"].forEach((v) {
          BuddyModel buddyModel = BuddyModel.fromJson(v);
          onlineManList.add(buddyModel);
          onlineManUidList.add(buddyModel.uid);
        });
        EventBus.getDefault().post(registerName: EVENTBUS_BOTTOM_USER_PANEL_DIALOG_RESET);
      }
    });
  }

  //监听动画是否开始
  void _initTimeDuration() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        Element e = findChild(context as Element, timeText);
        if (e != null) {
          timeText = LiveRoomPageCommon.init().getLiveRoomShowTimeUi(widget.startTime);
          e.owner.lockState(() {
            e.update(timeText);
          });
        }
      }
    });
  }

  //刷新人数
  void resetOnlineUserNumber(number) {
    print("刷新人数");
    if (null == number || !(number is int) || number < 2) {
      return;
    }
    onlineUserNumber = number;
    if (mounted) {
      Element e = findChild(context as Element, onlineMenNumberText);
      if (e != null) {
        onlineMenNumberText = LiveRoomPageCommon.init().getLiveOnlineMenNumberUi(number);
        e.owner.lockState(() {
          e.update(onlineMenNumberText);
        });
      }
    }
  }

  //加入直播间
  void addLiveRoom(TextMessage textMessage) {
    BuddyModel buddyModel = new BuddyModel();
    buddyModel.uid = int.parse(textMessage.sendUserInfo.userId);
    buddyModel.avatarUri = textMessage.sendUserInfo.portraitUri;
    buddyModel.nickName = textMessage.sendUserInfo.name;
    buddyModel.time = new DateTime.now().millisecondsSinceEpoch;
    onlineManList.insert(0, buddyModel);
    onlineManUidList.insert(0, buddyModel.uid);
    EventBus.getDefault().post(registerName: EVENTBUS_BOTTOM_USER_PANEL_DIALOG_RESET);
    if (onlineManList.length < 3) {
      resetOnlineUserImage();
    }
  }

  //离开直播间
  void subLiveRoom(TextMessage textMessage, {bool isReset = true}) {
    for (int i = 0; i < onlineManList.length; i++) {
      if (onlineManList[i].uid.toString() == textMessage.sendUserInfo.userId.toString()) {
        onlineManList.removeAt(i);
        break;
      }
    }
    for (int i = 0; i < onlineManUidList.length; i++) {
      if (onlineManUidList[i].toString() == textMessage.sendUserInfo.userId.toString()) {
        onlineManUidList.removeAt(i);
        break;
      }
    }
    if (isReset) {
      EventBus.getDefault().post(registerName: EVENTBUS_BOTTOM_USER_PANEL_DIALOG_RESET);
      if (onlineManList.length < 3) {
        resetOnlineUserImage();
      }
    }
  }

  //刷新头像
  void resetOnlineUserImage() {
    if (onlineManList.length > 0) {
      urlImageList.clear();
      if (onlineManList.length > 2) {
        for (int i = 0; i < 3; i++) {
          urlImageList.add(onlineManList[i].avatarUri);
        }
      } else {
        onlineManList.forEach((element) {
          urlImageList.add(element.avatarUri);
        });
        urlImageList.add(widget.coachUrl);
        for (int i = 0; i < 3; i++) {
          urlImageList.add("");
        }
      }
      print("11111:${urlImageList.toString()}");
      if (mounted) {
        userImageOnlineStream.sink.add(0);
      }
    }
  }

  // 监听返回事件
  Future<bool> _requestPop() {
    if(_emojiState){
      _emojiStateOld=false;
      _onClickBodyListener();
      return new Future.value(false);
    }else {
      return new Future.value(true);
    }
  }

  //退出界面
  _exitPageListener() {
    showAppDialog(context,
        info: "课程还未结束,确认退出吗？",
        topImageUrl: "",
        barrierDismissible: false,
        cancel: AppDialogButton("仍要退出", () {
          _exitPage();
          return true;
        }),
        confirm: AppDialogButton("继续训练", () {
          return true;
        }));
  }

  void _exitPage(){
    Navigator.of(context).pop();
  }


  _closeData(){
    EventBus.getDefault().post(registerName: EVENTBUS_LIVEROOM_EXIT);
    EventBus.getDefault()
        .unRegister(pageName: EVENTBUS_ROOM_OPERATION_PAGE, registerName: EVENTBUS_ROOM_RECEIVE_BARRAGE);
    EventBus.getDefault()
        .unRegister(pageName: EVENTBUS_ROOM_OPERATION_PAGE, registerName: EVENTBUS_ROOM_RECEIVE_NOTICE);
    EventBus.getDefault()
        .unRegister(pageName: EVENTBUS_ROOM_OPERATION_PAGE, registerName: EVENTBUS_ON_CLICK_BODY);
    EventBus.getDefault()
        .unRegister(pageName: EVENTBUS_ROOM_OPERATION_PAGE, registerName: LIVE_COURSE_LIVE_START_OR_END);
    if (timer != null) {
      timer.cancel();
      timer = null;
    }
    userImageOnlineStream.close();
    messageListStream.close();
    messageCantSendStream.close();
  }

  @override
  void dispose() {
    _closeData();
    super.dispose();
  }

  //接收直播间系统通知消息
  void _receiveNoticeMessage(List list) {
    if (list[0] is int) {
      switch (list[0]) {
        case 2:
          //2-直播禁言
          _liveMuteMessage(list[1], list[2], list[3]);
          break;
        default:
          break;
      }
    }
  }

  void _liveMuteMessage(String liveRoomId, List list, Message msg) {
    print("liveRoomId,网络:$liveRoomId,本地:${widget.coachId}");
    if (liveRoomId != widget.coachId.toString()) {
      Application.rongCloud.quitChatRoom(msg.targetId);
      return;
    }
    bool isHaveMeUid = false;
    for (dynamic element in list) {
      if (element.toString() == Application.profile.uid.toString()) {
        isHaveMeUid = true;
        break;
      }
    }
    if (!isHaveMeUid) {
      print("有人被禁言了:${list.toString()}");
      return;
    }
    print("接收到${widget.coachId}系统通知:${msg.originContentMap}");
    Map<String, dynamic> contentMap = json.decode(msg.originContentMap["data"]);
    print("接收到${contentMap.toString()}");
    if (null != contentMap && null != contentMap["isMute"]) {
      bool isMute;
      int minutes = -1;
      if (contentMap["isMute"] == 0) {
        print("解除禁言");
        isMute = false;
      } else {
        print("禁言");
        isMute = true;
        if (null != contentMap["minutes"]) {
          print("禁言时长：${contentMap["minutes"]}");
          minutes = contentMap["minutes"];
        } else {
          print("禁言时长：-1");
        }
      }
      print("直播间${widget.coachId}：是否禁言:$isMute,时长：$minutes");
      AppPrefs.setLiveRoomMute(widget.coachId.toString(), minutes * 60, isMute);
      if (isMute && mounted) {
        ToastShow.show(msg: "您已被禁言${minutes > 0 ? "$minutes分钟" : ""}", context: context);
      } else {
        print("你已被解除禁言");
      }
    }
  }

  //接收直播间弹幕消息
  void _receiveBarrageMessage(Message msg) {
    print("message:${msg.targetId},${widget.coachId}");
    if (msg.targetId != widget.coachId.toString()) {
      Application.rongCloud.quitChatRoom(msg.targetId);
      return;
    }
    TextMessage textMessage = (msg.content as TextMessage);
    Map<String, dynamic> contentMap = json.decode(textMessage.content);
    if (null != contentMap) {
      switch (contentMap["subObjectName"]) {
        case ChatTypeModel.MESSAGE_TYPE_SYS_BARRAGE:
          print("收到了弹幕消息------");
          _judgeSysMessage(contentMap["name"], contentMap, textMessage);
          break;
        case ChatTypeModel.MESSAGE_TYPE_USER_BARRAGE:
          _onSubmitLiveRoomMessage(textMessage.sendUserInfo.name, textMessage.sendUserInfo.userId, contentMap["data"]);
          break;
        default:
          break;
      }
    }
  }

  void _judgeSysMessage(String type, Map<String, dynamic> contentMap, TextMessage textMessage) {
    print("000000000000000000");
    if (null == type) {
      return;
    }
    switch (type) {
      case "joinLiveRoom":
        print("22222222222222222:type:$type");
        //加入直播间
        if (textMessage.sendUserInfo.userId != null) {
          if (onlineManUidList.contains(int.parse(textMessage.sendUserInfo.userId))) {
            print("有这个人");
            subLiveRoom(textMessage, isReset: false);
          } else {
            print("没有这个人");
            resetOnlineUserNumber(++onlineUserNumber);
          }
        } else {
          textMessage.sendUserInfo.userId = "100";
          print("没有这个人");
          resetOnlineUserNumber(++onlineUserNumber);
          getAllOnlineUserNumber(onlineUserNumber);
        }
        print("33333333:type:$type");
        _onSubmitJoinLiveRoomMessage(textMessage.sendUserInfo.name, textMessage.sendUserInfo.userId);
        addLiveRoom(textMessage);
        break;
      case "quitLiveRoom":
      //退出直播间
        print("${textMessage.sendUserInfo.name}退出了直播间");

        resetOnlineUserNumber(--onlineUserNumber);
        subLiveRoom(textMessage);
        break;
      case "feeling":
        print("弹出训练感受！！！${contentMap["data"].toString()}");
        _showFeelingDialog(contentMap["data"]);
        break;
      default:
        break;
    }
  }

  void _onDoubleClickBodyListener(){
    print("双击");
  }

  //界面空白处点击事件
  void _onClickBodyListener() {
    if (isCleaningMode) {
      print("显示弹幕列表");
      setState(() {
        isCleaningMode = !isCleaningMode;
        print("setState-66666666666666666666");
      });
      return;
    }
    _bottomSettingPanelState = false;
    print("_bottomSettingPanelState:设置false");
    bottomBarHeightColorIsWhite = false;
    if (_focusNode.hasFocus) {
      _focusNode.unfocus();
      _bottomSettingPanelState = false;
      print("_bottomSettingPanelState:设置false");
      bottomBarHeightColorIsWhite = true;
    }
    isShowEmojiBtn = true;
    isShowEditPlan = false;
    if (_emojiState) {
      _emojiState = !_emojiState;
      bottomBarHeightColorIsWhite = true;
      setState(() {
        print("setState-7777777777777777777");
      });
      _bottomSettingPanelState = false;
      print("_bottomSettingPanelState:设置false");
    }
    if (bottomBarHeightColorIsWhite) {
      Future.delayed(Duration(milliseconds: 50), () {
        bottomBarHeightColorIsWhite = false;
        if (mounted) {
          setState(() {
            print("setState-88888888888888888888");
          });
        }
      });
    }
    if (bottomBarHeightColorIsWhite) {
      print("处理点击事件");
    } else {
      print("普通点击");
    }
  }

  ///这是关注的方法
  _onClickAttention() async {
    if (!(coachRelation == 1 || coachRelation == 3)) {
      int attntionResult = await ProfileAddFollow(widget.coachId, type: 1);
      print('关注监听=========================================$attntionResult');
      if (attntionResult == 1 || attntionResult == 3) {
        coachRelation = 1;
        if (mounted) {
          setState(() {
            print("setState-99999999999999999999999999");
          });
        }
      }
      if (widget.callback != null) {
        widget.callback(coachRelation);
      }
    }
  }

  //点击删除输入框
  _deleteEditText() {
    if (_textController.text == null || _textController.text.length < 1 || cursorIndexPr <= 0) {
      return;
    }
    String editString = _textController.text;
    List<String> listString = editString.characters.toList();
    editString = "";
    int textLength = 0;
    int deleteTextLength = 0;
    for (int i = 1; i < listString.length + 1; i++) {
      textLength += listString[i - 1].length;
      if (cursorIndexPr != textLength) {
        editString += listString[i - 1];
      } else {
        deleteTextLength = listString[i - 1].length;
      }
    }
    cursorIndexPr -= deleteTextLength;
    _textController.text = editString;
    messageCantSendStream.sink.add(0);
  }

  //发送按钮点击事件
  _onSubmitClick(text) {
    if (null == text || text.length < 1) {
      return;
    }
    if (isMuteJudge()) {
      ToastShow.show(msg: "您已被禁言请稍后再发", context: context, gravity: 1);
    } else {
      _sendChatRoomMsg(text);
      _onSubmitLiveRoomMessage(Application.profile.nickName, Application.profile.uid.toString(), text);
    }
    _textController.text = "";
    if (!_emojiState) {
      FocusScope.of(context).requestFocus(_focusNode);
    }
  }

  //加入普通消息
  _onSubmitLiveRoomMessage(String name, String userId, String content) {
    messageChatList.insert(
        0,
        UserMessageModel(
          name: name,
          uId: userId,
          messageContent: content,
        ));
    if (messageChatList.length > 100) {
      messageChatList = messageChatList.sublist(0, 99);
      messageChatList.add(UserMessageModel(messageContent: "请遵守直播间规则" * 10));
    }
    messageListStream.sink.add(0);
  }

  //加入进入直播间的消息
  _onSubmitJoinLiveRoomMessage(String name, String userId) {
    if (userId == null) {
      userId = "100";
    }
    messageChatList.insert(
        0,
        UserMessageModel(
          name: name,
          uId: userId,
          messageContent: "进入了直播",
          isJoinLiveRoomMessage: true,
        ));
    if (messageChatList.length > 100) {
      messageChatList = messageChatList.sublist(0, 99);
      messageChatList.add(UserMessageModel(messageContent: "请遵守直播间规则" * 10));
    }
    messageListStream.sink.add(0);
  }

  //发送直播聊天信息
  _sendChatRoomMsg(text) async {
    TextMessage msg = TextMessage();
    UserInfo userInfo = UserInfo();
    userInfo.userId = Application.profile.uid.toString();
    userInfo.name = Application.profile.nickName;
    userInfo.portraitUri = Application.profile.avatarUri;
    msg.sendUserInfo = userInfo;
    Map<String, dynamic> textMap = Map();
    textMap["fromUserId"] = msg.sendUserInfo.userId.toString();
    textMap["toUserId"] = widget.coachId;
    textMap["subObjectName"] = ChatTypeModel.MESSAGE_TYPE_USER_BARRAGE;
    textMap["name"] = ChatTypeModel.MESSAGE_TYPE_USER_BARRAGE_NAME;
    textMap["data"] = text;
    msg.content = jsonEncode(textMap);
    await Application.rongCloud.sendChatRoomMessage(widget.coachId.toString(), msg);
  }

  //显示dialog-训练感受
  _showFeelingDialog(dynamic mapList) {
    EventBus.getDefault().post(registerName: EVENTBUS_ON_CLICK_BODY);
    var contentMap = json.decode(mapList.toString());
    showAppDialog(context, title: "训练感受", info: "请问训练感觉怎么样呢？", barrierDismissible: false, buttonList: [
      for (Map<String, dynamic> map in contentMap)
        AppDialogButton(map["content"] ?? "", () {
          print("${map["content"]},${map["id"]}");
          if (null != map["id"]) {
            feeling(widget.liveCourseId, map["id"].toString());
          }
          return true;
        }),
    ]);
  }

  static Element findChild(Element e, Widget w) {
    Element child;
    void visit(Element element) {
      if (w == element.widget)
        child = element;
      else
        element.visitChildren(visit);
    }

    visit(e);
    return child;
  }

  @override
  void endCanvasPage() {
    print("停止改变屏幕高度");
    if (MediaQuery.of(this.context).viewInsets.bottom > 0) {
      if (Application.keyboardHeightChatPage != MediaQuery.of(this.context).viewInsets.bottom) {
        Application.keyboardHeightChatPage = MediaQuery.of(this.context).viewInsets.bottom;
        if (mounted) {
          setState(() {
            print("setState-aaaaaaaaaaaaaaaaaaaaaa");});
        }
      }
    }
  }

  @override
  void startCanvasPage(bool isOpen) {
    print("开始改变屏幕高度:${isOpen ? "打开" : "关闭"}");
    print("_bottomSettingPanelState:是$_bottomSettingPanelState");
    if(isOpen) {
      if (!_emojiStateOld) {
        if (_bottomSettingPanelState != isOpen) {
          _bottomSettingPanelState = isOpen;
          print("_bottomSettingPanelState:是$_bottomSettingPanelState");
          if (mounted) {
            setState(() {
              print("setState-bbbbbbbbbbbbbbbbbbbbbbbb");
            });
          }
        }
      }
    }else{
      _bottomSettingPanelState = false;
      print("_bottomSettingPanelState:是$_bottomSettingPanelState");
      if (mounted) {
        setState(() {
          print("setState-bbbbbbbbbbbbbbbbbbbbbbbb");
        });
      }
    }
    if(isOpen){
      _emojiStateOld=false;
    }
  }

  @override
  void keyBoardHeightThanZero() {
    // if (MediaQuery.of(this.context).viewInsets.bottom > 0 && !_bottomSettingPanelState) {
    //   _focusNode.unfocus();
    // }
  }
}
