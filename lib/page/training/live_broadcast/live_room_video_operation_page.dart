import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/api/training/course_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/config/shared_preferences.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/message/chat_type_model.dart';
import 'package:mirror/data/model/message/emoji_model.dart';
import 'package:mirror/data/model/profile/buddy_list_model.dart';
import '../../message/util/emoji_manager.dart';
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

class _LiveRoomVideoOperationPageState extends StateKeyboard<LiveRoomVideoOperationPage> with WidgetsBindingObserver {
  _LiveRoomVideoOperationPageState(this.coachRelation);

  //??????????????????
  int coachRelation;

  List<UserMessageModel> messageChatList = [];

  ScrollController textScrollController = ScrollController();

  ///??????????????????
  TextEditingController _textController = TextEditingController();

  ///??????????????????
  FocusNode _focusNode = new FocusNode();

  bool isShowEditPlan = false;
  bool isShowEmojiBtn = true;

  //????????????????????????
  bool isShowMessage = true;

  //????????????
  bool isCleaningMode = false;

  ///???????????????
  List<EmojiModel> emojiModelList = <EmojiModel>[];
  List<BuddyModel> onlineManList = <BuddyModel>[];
  List<int> onlineManUidList = <int>[];

  bool _emojiState = false;
  bool _emojiStateOld = false;
  bool _bottomSettingPanelState = false;

  int cursorIndexPr = -1;

  int onlineUserNumber = 1;
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

    WidgetsBinding.instance.addObserver(this);

    print("???????????????:${widget.startTime},${widget.coachId}");

    EventBus.init().registerSingleParameter(_receiveBarrageMessage, EVENTBUS_ROOM_OPERATION_PAGE,
        registerName: EVENTBUS_ROOM_RECEIVE_BARRAGE);
    EventBus.init().registerSingleParameter(_receiveNoticeMessage, EVENTBUS_ROOM_OPERATION_PAGE,
        registerName: EVENTBUS_ROOM_RECEIVE_NOTICE);
    EventBus.init()
        .registerNoParameter(_onClickBodyListener, EVENTBUS_ROOM_OPERATION_PAGE, registerName: EVENTBUS_ON_CLICK_BODY);
    EventBus.init().registerSingleParameter(_liveCourseStatus, EVENTBUS_ROOM_OPERATION_PAGE,
        registerName: LIVE_COURSE_LIVE_START_OR_END);

    urlImageList.add("");
    urlImageList.add(widget.coachUrl);
    urlImageList.add(Application.profile.avatarUri);

    timeText = LiveRoomPageCommon.init().getLiveRoomShowTimeUi(widget.startTime);
    onlineMenNumberText = LiveRoomPageCommon.init().getLiveOnlineMenNumberUi(onlineUserNumber);

    messageChatList.add(UserMessageModel(messageContent: "????????????????????????" * 10));
    messageChatList.insert(
        0,
        UserMessageModel(
          name: Application.profile.nickName,
          uId: Application.profile.uid.toString(),
          messageContent: "???????????????",
          isJoinLiveRoomMessage: true,
        ));

    _focusNode.addListener(() {
      cursorIndexPr = _textController.selection.baseOffset;
    });
    initData();
    _initTimeDuration();
  }

  void _liveCourseStatus(List list) {
    if (list != null && list[1] == widget.liveCourseId) {
      switch (list[0]) {
        case 0:
          //0-????????????
          print("????????????");
          break;
        case 3:
          //0-????????????
          print("????????????");
          ToastShow.show(msg: "???????????????", context: context, duration: Toast.LENGTH_LONG);
          _exitPage();
          break;
        default:
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
      height: 48.0 + MediaQuery.of(context).padding.bottom,
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
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

  //????????????-????????????
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
          Text("????????????", style: AppStyle.text1Regular10),
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
                Text(widget.coachName, style: AppStyle.text1Regular11),
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
          coachRelation == 1 || coachRelation == 3 ? "?????????" : "??????",
          style: TextStyle(
              color: coachRelation == 1 || coachRelation == 3 ? AppColor.textHint : AppColor.white, fontSize: 11),
        ),
      ),
      onTap: _onClickAttention,
    );
  }

  //??????
  Widget trainingTimeUi() {
    return Container(
      child: Column(
        children: [
          timeText,
          Text("????????????", style: AppStyle.text2Regular10),
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
          color: (_focusNode.hasFocus || isShowEditPlan || _emojiState || bottomBarHeightColorIsWhite || _emojiStateOld)
              ? AppColor.white
              : AppColor.transparent,
          child: Column(
            children: [
              Container(
                height: _emojiState ? 0.0 : MediaQuery.of(context).padding.bottom,
                color: (_focusNode.hasFocus || isShowEditPlan || _emojiState || bottomBarHeightColorIsWhite)
                    ? AppColor.white
                    : AppColor.transparent,
              ),
              bottomSettingBox(),
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
      height: (_focusNode.hasFocus || isShowEditPlan || _emojiState || _emojiStateOld) ? 48.0 : 0.0,
      child: getBottomBarEditTextPanel(),
    );
  }

  Widget getBottomBarEditTextPanel() {
    return Container(
      height: (_focusNode.hasFocus || isShowEditPlan || _emojiState || _emojiStateOld) ? 48.0 : 0.0,
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
                    onTap: _emojiBtnOnclickListener,
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

  //?????????????????????
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

    keyboardHeight -= MediaQuery.of(context).padding.bottom;
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
      height: _bottomSettingPanelState || _emojiState ? keyboardHeight : 0.0,
      child: Container(
        height: _bottomSettingPanelState || _emojiState ? keyboardHeight : 0.0,
        width: double.infinity,
        color: AppColor.white,
      ),
    );
  }

  //?????????
  Widget emojiPlan(double keyboardHeight) {
    keyboardHeight += MediaQuery.of(context).padding.bottom;
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

  //emoji?????????????????????
  Widget emojiList(double keyboardHeight) {
    if (emojiModelList == null || emojiModelList.length < 1) {
      return Center(
        child: Text("????????????"),
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
                SliverToBoxAdapter(
                  child: Container(
                    height: MediaQuery.of(context).padding.bottom,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        onTap: () {},
      );
    }
  }

  //????????????????????? ???????????????
  Widget _emojiGridTop(double keyboardHeight) {
    return Container(
      height: keyboardHeight - 45.0 - MediaQuery.of(context).padding.bottom,
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

  //?????????_emojiGridItem
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
    var setCursor = TextSelection(
      baseOffset: cursorIndexPr,
      extentOffset: cursorIndexPr,
    );
    _textController.selection = setCursor;
    messageCantSendStream.sink.add(0);
  }

  //?????????bar
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

  //?????????bar??????edit
  Widget edit() {
    return TextSpanField(
      onTap: () {
        _emojiStateOld = _emojiState;
        isShowEmojiBtn = true;
        _emojiState = false;
        _bottomSettingPanelState = true;
      },
      onLongTap: () {
        _emojiStateOld = _emojiState;
        isShowEmojiBtn = true;
        _emojiState = false;
        _bottomSettingPanelState = true;
      },
      readOnly: _emojiState,
      showCursor: true,
      controller: _textController,
      scrollController: textScrollController,
      focusNode: _focusNode,
      // ????????????
      keyboardType: TextInputType.multiline,
      //???????????????
      maxLines: 1,
      enableInteractiveSelection: true,
      // ????????????
      cursorColor: Color.fromRGBO(253, 137, 140, 1),
      scrollPadding: EdgeInsets.all(0),
      style: TextStyle(
        fontSize: 14,
        color: AppColor.textPrimary1,
        background: Paint()..color = AppColor.bgWhite,
      ),
      //?????????????????????
      onChanged: (text) {
        cursorIndexPr = _textController.selection.baseOffset;
        messageCantSendStream.sink.add(0);
      },
      textInputAction: TextInputAction.send,
      onSubmitted: _onSubmitClick,
      // ?????????????????????
      decoration: InputDecoration(
        // ???????????????
        border: InputBorder.none,
        // ????????????
        hintText: "???????????????...",
        // ??????????????????
        hintStyle: TextStyle(fontSize: 14, color: AppColor.textHint),
        // ?????????true,contentPadding???????????????TextField?????????????????????
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
        child: Text("???????????????...", style: AppStyle.text2Regular14),
      ),
      onTap: () {
        if (ClickUtil.isFastClick()) {
          return;
        }
        if (isMuteJudge()) {
          ToastShow.show(msg: "??????????????????????????????", context: context, gravity: 1);
          return;
        }
        isShowEditPlan = true;
        setState(() {
          print("setState-55555555555555555");
        });
        Future.delayed(Duration(milliseconds: 80), () {
          // pageHeightStopCanvas = true;
          // oldKeyboardHeight = 0;
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

  //?????????????????????????????????
  double getBottomMessageHeight() {
    return (ScreenUtil.instance.height -
            ScreenUtil.instance.statusBarHeight -
            ScreenUtil.instance.bottomBarHeight -
            48.0) *
        0.25;
  }

  void initData() async {
    //?????????????????????
    emojiModelList = await EmojiManager.getEmojiModelList();
    Map<String, dynamic> map = await roomInfo(widget.coachId, count: 3);
    if (null != map["data"] && null != map["data"]["userList"]) {
      map["data"]["userList"].forEach((v) {
        BuddyModel buddyModel = BuddyModel.fromJson(v);
        onlineManList.add(BuddyModel.fromJson(v));
        onlineManUidList.add(buddyModel.uid);
      });
    }
    if (null != onlineManList) {
      resetOnlineUserNumber(onlineManList.length);
    }
    getAllOnlineUserNumber(onlineUserNumber + 1);
    resetOnlineUserImage();
  }

  //???????????????????????????
  void getAllOnlineUserNumber(int number) async {
    Future.delayed(Duration(seconds: 2), () async {
      print("number:$number");
      Map<String, dynamic> map = await roomInfo(widget.coachId, count: number);
      if (null != map && null != map["data"] && null != map["data"]["userList"]) {
        onlineManList.clear();
        onlineManUidList.clear();
        map["data"]["userList"].forEach((v) {
          BuddyModel buddyModel = BuddyModel.fromJson(v);
          onlineManList.add(buddyModel);
          onlineManUidList.add(buddyModel.uid);
        });
        EventBus.init().post(registerName: EVENTBUS_BOTTOM_USER_PANEL_DIALOG_RESET);
      }
      if (null != onlineManList) {
        resetOnlineUserNumber(onlineManList.length);
      }
    });
  }

  //????????????????????????
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

  //????????????
  void resetOnlineUserNumber(number) {
    print("????????????");
    if (null == number || !(number is int)) {
      return;
    }
    if (number < onlineManList.length) {
      number = onlineManList.length;
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

  //???????????????
  void addLiveRoom(TextMessage textMessage) {
    BuddyModel buddyModel = new BuddyModel();
    buddyModel.uid = int.parse(textMessage.sendUserInfo.userId);
    buddyModel.avatarUri = textMessage.sendUserInfo.portraitUri;
    buddyModel.nickName = textMessage.sendUserInfo.name;
    buddyModel.time = new DateTime.now().millisecondsSinceEpoch;
    onlineManList.insert(0, buddyModel);
    onlineManUidList.insert(0, buddyModel.uid);
    EventBus.init().post(registerName: EVENTBUS_BOTTOM_USER_PANEL_DIALOG_RESET);
    if (onlineManList.length < 3) {
      resetOnlineUserImage();
    }
  }

  //???????????????
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
      EventBus.init().post(registerName: EVENTBUS_BOTTOM_USER_PANEL_DIALOG_RESET);
      if (onlineManList.length < 3) {
        resetOnlineUserImage();
      }
    }
  }

  //????????????
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

  // ??????????????????
  Future<bool> _requestPop() {
    if (_emojiState) {
      _emojiStateOld = false;
      _onClickBodyListener();
      return new Future.value(false);
    } else {
      return new Future.value(true);
    }
  }

  //????????????
  _exitPageListener() {
    showAppDialog(context,
        info: "??????????????????,??????????????????",
        topImageUrl: "assets/png/unfinished_training_png.png",
        isTransparentBack: true,
        barrierDismissible: false,
        cancel: AppDialogButton("????????????", () {
          _exitPage();
          return true;
        }),
        confirm: AppDialogButton("????????????", () {
          return true;
        }));
  }

  void _exitPage() {
    Navigator.of(context).pop();
  }

  _closeData() {
    EventBus.init().post(registerName: EVENTBUS_LIVEROOM_EXIT);
    EventBus.init().unRegister(pageName: EVENTBUS_ROOM_OPERATION_PAGE, registerName: EVENTBUS_ROOM_RECEIVE_BARRAGE);
    EventBus.init().unRegister(pageName: EVENTBUS_ROOM_OPERATION_PAGE, registerName: EVENTBUS_ROOM_RECEIVE_NOTICE);
    EventBus.init().unRegister(pageName: EVENTBUS_ROOM_OPERATION_PAGE, registerName: EVENTBUS_ON_CLICK_BODY);
    EventBus.init().unRegister(pageName: EVENTBUS_ROOM_OPERATION_PAGE, registerName: LIVE_COURSE_LIVE_START_OR_END);
    if (timer != null) {
      timer.cancel();
      timer = null;
    }
    userImageOnlineStream.close();
    messageListStream.close();
    messageCantSendStream.close();
  }

  @override
  Future didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    print("didChangeAppLifecycleState:$state");
    if (state == AppLifecycleState.paused) {
      if (_emojiState) {
        _emojiStateOld = false;
        _onClickBodyListener();
      }
    }
  }

  @override
  void dispose() {
    _closeData();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  //?????????????????????????????????
  void _receiveNoticeMessage(List list) {
    if (list[0] is int) {
      switch (list[0]) {
        case 2:
          //2-????????????
          _liveMuteMessage(list[1], list[2], list[3]);
          break;
        default:
          break;
      }
    }
  }

  void _liveMuteMessage(String liveRoomId, List list, Message msg) {
    print("liveRoomId,??????:$liveRoomId,??????:${widget.coachId}");
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
      print("??????????????????:${list.toString()}");
      return;
    }
    print("?????????${widget.coachId}????????????:${msg.originContentMap}");
    Map<String, dynamic> contentMap = json.decode(msg.originContentMap["data"]);
    print("?????????${contentMap.toString()}");
    if (null != contentMap && null != contentMap["isMute"]) {
      bool isMute;
      int minutes = -1;
      if (contentMap["isMute"] == 0) {
        print("????????????");
        isMute = false;
      } else {
        print("??????");
        isMute = true;
        if (null != contentMap["minutes"]) {
          print("???????????????${contentMap["minutes"]}");
          minutes = contentMap["minutes"];
        } else {
          print("???????????????-1");
        }
      }
      print("?????????${widget.coachId}???????????????:$isMute,?????????$minutes");
      AppPrefs.setLiveRoomMute(widget.coachId.toString(), minutes * 60, isMute);
      if (isMute && mounted) {
        ToastShow.show(msg: "???????????????${minutes > 0 ? "$minutes??????" : ""}", context: context);
      } else {
        print("?????????????????????");
      }
    }
  }

  //???????????????????????????
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
          print("?????????????????????------");
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
        print(
            "22222222222222222:type:$type???${textMessage.sendUserInfo?.portraitUri},${textMessage.sendUserInfo?.userId}");
        //???????????????

        print("33333333:type:$type");
        _onSubmitJoinLiveRoomMessage(textMessage.sendUserInfo.name, textMessage.sendUserInfo.userId);
        if (textMessage.sendUserInfo.userId != null) {
          if (onlineManUidList.contains(int.parse(textMessage.sendUserInfo.userId))) {
            print("????????????");
            // subLiveRoom(textMessage, isReset: false);
          } else {
            print("???????????????");
            addLiveRoom(textMessage);
            resetOnlineUserNumber(onlineManList.length);
          }
        } else {
          textMessage.sendUserInfo.userId = "100";
          print("???????????????");
          addLiveRoom(textMessage);
          resetOnlineUserNumber(onlineManList.length);
          getAllOnlineUserNumber(onlineUserNumber);
        }
        break;
      case "quitLiveRoom":
        //???????????????
        print("${textMessage.sendUserInfo.name}??????????????????");

        subLiveRoom(textMessage);
        resetOnlineUserNumber(onlineManList.length);
        break;
      case "feeling":
        print("???????????????????????????${contentMap["data"].toString()}");
        _showFeelingDialog(contentMap["data"]);
        break;
      default:
        break;
    }
  }

  void _onDoubleClickBodyListener() {
    print("??????");
  }

  //???????????????????????????
  void _onClickBodyListener() {
    if (isCleaningMode) {
      print("??????????????????");
      setState(() {
        isCleaningMode = !isCleaningMode;
        print("setState-66666666666666666666");
      });
      return;
    }
    _bottomSettingPanelState = false;
    print("_bottomSettingPanelState:??????false");
    bottomBarHeightColorIsWhite = false;
    if (_focusNode.hasFocus) {
      _focusNode.unfocus();
      _bottomSettingPanelState = false;
      print("_bottomSettingPanelState:??????false");
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
      print("_bottomSettingPanelState:??????false");
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
      print("??????????????????");
    } else {
      print("????????????");
    }
  }

  ///?????????????????????
  _onClickAttention() async {
    if (!(coachRelation == 1 || coachRelation == 3)) {
      int attntionResult = await ProfileAddFollow(widget.coachId, type: 1);
      print('????????????=========================================$attntionResult');
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

  //?????????????????????
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

  //???????????????????????????
  _emojiBtnOnclickListener() {
    cursorIndexPr = _textController.selection.baseOffset;
    if (ClickUtil.isFastClick()) {
      return;
    }
    _emojiStateOld = _emojiState;
    if (isShowEmojiBtn) {
      _emojiState = isShowEmojiBtn;
      isShowEditPlan = false;
      isShowEmojiBtn = !isShowEmojiBtn;
      setState(() {});
    } else {
      _emojiState = isShowEmojiBtn;
      isShowEditPlan = false;
      isShowEmojiBtn = !isShowEmojiBtn;
      _bottomSettingPanelState = !_emojiState;
      setState(() {});
    }
  }

  //????????????????????????
  _onSubmitClick(text) {
    if (null == text || text.length < 1) {
      return;
    }
    if (isMuteJudge()) {
      ToastShow.show(msg: "??????????????????????????????", context: context, gravity: 1);
    } else {
      _sendChatRoomMsg(text);
      _onSubmitLiveRoomMessage(Application.profile.nickName, Application.profile.uid.toString(), text);
    }
    _textController.text = "";
    if (!_emojiState) {
      FocusScope.of(context).requestFocus(_focusNode);
    }
  }

  //??????????????????
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
      messageChatList.add(UserMessageModel(messageContent: "????????????????????????" * 10));
    }
    messageListStream.sink.add(0);
  }

  //??????????????????????????????
  _onSubmitJoinLiveRoomMessage(String name, String userId) {
    if (userId == null) {
      userId = "100";
    }
    messageChatList.insert(
        0,
        UserMessageModel(
          name: name,
          uId: userId,
          messageContent: "???????????????",
          isJoinLiveRoomMessage: true,
        ));
    if (messageChatList.length > 100) {
      messageChatList = messageChatList.sublist(0, 99);
      messageChatList.add(UserMessageModel(messageContent: "????????????????????????" * 10));
    }
    messageListStream.sink.add(0);
  }

  //????????????????????????
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

  //??????dialog-????????????
  _showFeelingDialog(dynamic mapList) {
    EventBus.init().post(registerName: EVENTBUS_ON_CLICK_BODY);
    var contentMap = json.decode(mapList.toString());
    showAppDialog(context, title: "????????????", info: "?????????????????????????????????", barrierDismissible: false, buttonList: [
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
  void startChangeKeyBoardHeight(bool isOpenKeyboard) {
    print("????????????????????????:${isOpenKeyboard ? "??????" : "??????"}");
    if (isOpenKeyboard) {
      if (!_emojiStateOld) {
        if (_bottomSettingPanelState != isOpenKeyboard) {
          _bottomSettingPanelState = isOpenKeyboard;
          print("_bottomSettingPanelState:???$_bottomSettingPanelState");
          if (mounted) {
            setState(() {
              print("setState-bbbbbbbbbbbbbbbbbbbbbbbb");
            });
          }
        }
      }
    } else {
      if (!_emojiState) {
        _onClickBodyListener();
      }
    }
    if (isOpenKeyboard) {
      _emojiStateOld = false;
    }
  }

  @override
  void endChangeKeyBoardHeight(bool isOpenKeyboard) {
    print("????????????????????????:${isOpenKeyboard ? "??????" : "??????"}");
    if (isOpenKeyboard) {
      if (Application.keyboardHeightChatPage != MediaQuery.of(this.context).viewInsets.bottom) {
        Application.keyboardHeightChatPage = MediaQuery.of(this.context).viewInsets.bottom;
        if (mounted) {
          setState(() {
            print("setState-aaaaaaaaaaaaaaaaaaaaaa");
          });
        }
      }
    }
  }
}
