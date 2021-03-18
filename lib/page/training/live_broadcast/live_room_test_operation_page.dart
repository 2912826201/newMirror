
import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/message/chat_type_model.dart';
import 'package:mirror/data/model/message/emoji_model.dart';
import 'package:mirror/page/message/item/emoji_manager.dart';
import 'package:mirror/util/click_util.dart';
import 'package:mirror/util/date_util.dart';
import 'package:mirror/util/event_bus.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/feed/feed_more_popups.dart';
import 'package:mirror/widget/icon.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:text_span_field/text_span_field.dart';

import 'dialog/live_room_setting_dialog.dart';
import 'live_room_page_common.dart';


class LiveRoomTestOperationPage extends StatefulWidget {
  final int liveCourseId;
  final int coachId;
  final String coachUrl;
  final String coachName;
  final String startTime;
  final int coachRelation;

  const LiveRoomTestOperationPage({
    Key key,
    @required this.liveCourseId,
    @required this.coachName,
    @required this.coachUrl,
    @required this.startTime,
    @required this.coachRelation,
    @required this.coachId,}) : super(key: key);

  @override
  _LiveRoomTestOperationPageState createState() => _LiveRoomTestOperationPageState(coachRelation);
}

class _LiveRoomTestOperationPageState extends State<LiveRoomTestOperationPage> {

  _LiveRoomTestOperationPageState(this.coachRelation);

  //与教练的关系
  int coachRelation;

  List<UserMessageModel> messageChatList=[];

  ///输入框的监听
  TextEditingController _textController = TextEditingController();
  ///输入框的焦点
  FocusNode _focusNode = new FocusNode();

  bool isShowEditPlan=false;
  bool isShowEmojiBtn=true;

  //是否显示弹幕消息
  bool isShowMessage=true;

  //清洁模式
  bool isCleaningMode=false;

  ///表情的列表
  List<EmojiModel> emojiModelList = <EmojiModel>[];

  bool _emojiState=false;


  int cursorIndexPr=-1;


  Timer timer;
  Widget timeText;

  @override
  void initState() {
    super.initState();

    print("开播时间是:${widget.startTime}");


    EventBus.getDefault().register(receiveBarrageMessage,EVENTBUS_ROOM_OPERATION_PAGE,
        registerName: EVENTBUS_ROOM_RECEIVE_BARRAGE);

    timeText=Text(DateUtil.getSpecifyDateTimeDifferenceMinutesAndSeconds(widget.startTime)
        ,style: TextStyle(fontSize: 18,color: AppColor.white.withOpacity(0.85)));

    messageChatList.add(UserMessageModel(messageContent: "请遵守直播间规则"*10));
    messageChatList.insert(0, UserMessageModel(
      name: Application.profile.nickName,
      uId: Application.profile.uid.toString(),
      messageContent: "进入了直播",
      isJoinLiveRoomMessage: true,
    ));


    _focusNode.addListener(() {
      cursorIndexPr=_textController.selection.baseOffset;
    });
    initData();
    _initTimeDuration();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: GestureDetector(
            child: Container(
              color: AppColor.transparent,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  getTopUi(),
                  (!isCleaningMode)?getHaveMessageBottomPlan():getNoMessageBottomPlan(),
                ],
              ),
            ),
            onTap: _onClickBodyListener,
          ),
        ),
        onWillPop: _requestPop);
  }

  Widget getTopUi(){
    return Container(
      margin: EdgeInsets.only(top: ScreenUtil.instance.statusBarHeight+8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          getTopInformationUi(),
          SizedBox(height: 16),
          Visibility(
            visible: !isCleaningMode,
            child: GestureDetector(
              child: otherUserUi(),
              onTap: getBottomDialog,
            ),
          )
        ],
      ),
    );
  }


  Widget getHaveMessageBottomPlan(){
    return Container(
      color: AppColor.transparent,
      alignment: Alignment.bottomCenter,
      child: getBottomPlan(),
    );
  }

  Widget getNoMessageBottomPlan(){
    return Container(
      height: 48.0 + ScreenUtil.instance.bottomBarHeight,
      padding: EdgeInsets.only(bottom: ScreenUtil.instance.bottomBarHeight),
      margin: EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerRight,
      child: UnconstrainedBox(
        child: GestureDetector(
          child: Container(
            width: 32.0,
            height: 32.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(16)),
              color: AppColor.white.withOpacity(0.06),
            ),
            child: Icon(Icons.close,color: AppColor.white,size: 12),
          ),
          onTap: _exitPageListener,
        ),
      ),
    );
  }


  //其他用户-一起运动
  Widget otherUserUi(){
    return Container(
      height: 36.0,
      width: 120.0,
      decoration: BoxDecoration(
        color: AppColor.white.withOpacity(0.06),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24),bottomLeft: Radius.circular(24)),
      ),
      child: Row(
        children: [
          Expanded(child: SizedBox()),
          Container(
            width: 21.0*3-12.0,
            height: 21.0,
            child: Stack(
              children: [
                Positioned(
                  child: LiveRoomPageCommon.init().getUserImage(null,21,21),
                  right: 0,
                ),
                Positioned(
                  child: LiveRoomPageCommon.init().getUserImage(null,21,21),
                  right: 12,
                ),
                Positioned(
                  child: LiveRoomPageCommon.init().getUserImage(null,21,21),
                  right: 24,
                ),
              ],
            ),
          ),
          SizedBox(width: 6),
          Text("一起运动",style: TextStyle(fontSize: 10,color: AppColor.white.withOpacity(0.85))),
          SizedBox(width: 16),
        ],
      ),
    );
  }




  Widget getTopInformationUi(){
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

  Widget getCoachNameUi(){
    return UnconstrainedBox(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6,vertical: 4),
        decoration: BoxDecoration(
          color: AppColor.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            LiveRoomPageCommon.init().getUserImage(widget.coachUrl,28,28),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.coachName,style: TextStyle(fontSize: 11,color: AppColor.white.withOpacity(0.85))),
                Text("在线人数8524.2万",style: TextStyle(fontSize: 9,color: AppColor.white.withOpacity(0.65))),
              ],
            ),
            SizedBox(width: 8),
            getFollowBtn(),
          ],
        ),
      ),
    );
  }


  Widget getFollowBtn(){
    if(coachRelation == 1 || coachRelation == 3){
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
              color: coachRelation == 1 || coachRelation == 3
                  ? AppColor.textHint
                  : AppColor.white,
              fontSize: 11),
        ),
      ),
      onTap: _onClickAttention,
    );
  }

  //训练
  Widget trainingTimeUi(){
    return Container(
      child: Column(
        children: [
          timeText,
          Text("训练时长",style: TextStyle(fontSize: 10,color: AppColor.white.withOpacity(0.35))),
        ],
      ),
    );
  }


  Widget getBottomPlan(){
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
            ).createShader(Rect.fromLTRB(0,0, bounds.width,bounds.height));
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
              getBottomBar0(),
              getBottomBarAnimatedContainer(),
            ],
          ),
        ),
        emojiPlan(),
        Container(
          height: ScreenUtil.instance.bottomBarHeight,
          color: AppColor.transparent,
        ),
      ],
    );
  }



  Widget getListView(){
    return Visibility(
      visible: isShowMessage,
      child: ListView.builder(
        reverse: true,
        physics: BouncingScrollPhysics(),
        itemBuilder: (context,index){
          return getListViewItem(index);
        },
        itemCount: messageChatList.length,
      ),
    );
  }



  Widget getListViewItem(int index){
    return Container(
      margin: const EdgeInsets.only(left: 16,right: 28,bottom: 4,top: 4),
      child: UnconstrainedBox(
        alignment: Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: ScreenUtil.instance.width-16-28,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 2),
          decoration: BoxDecoration(
            color: AppColor.bgWhite.withOpacity(0.06),
            borderRadius: BorderRadius.circular(11.5),
          ),
          child: LiveRoomPageCommon.init().getLiveRoomMessageText(messageChatList[index]),
        ),
      ),
    );
  }


  Widget getBottomBarAnimatedContainer(){
    return AnimatedContainer(
      duration: Duration(milliseconds: 50),
      height: (_focusNode.hasFocus||isShowEditPlan||_emojiState)?48.0:0.0,
      child: getBottomBar1(),
    );
  }

  Widget getBottomBar1(){
    return Container(
      height: (_focusNode.hasFocus||isShowEditPlan||_emojiState)?48.0:0.0,
      // height: 48.0,
      child: SingleChildScrollView(
        child: Container(
          color: AppColor.white,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16,vertical: 8),
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
                      if(ClickUtil.isFastClick()){
                        return;
                      }
                      if(isShowEmojiBtn){
                        if(_focusNode.hasFocus){
                          _focusNode.unfocus();
                        }
                      }else{
                        FocusScope.of(context).requestFocus(_focusNode);
                      }
                      _emojiState=isShowEmojiBtn;
                      isShowEditPlan=false;
                      isShowEmojiBtn=!isShowEmojiBtn;
                      setState(() {});
                    },
                    iconSize: 24,
                    buttonWidth: 36,
                    buttonHeight: 36,
                    svgName: isShowEmojiBtn?AppIcon.input_emotion:AppIcon.input_keyboard,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //表情框
  Widget emojiPlan() {


    //Application.keyboardHeight
    double keyboardHeight=300.0;
    if(_focusNode.hasFocus&&MediaQuery.of(this.context).viewInsets.bottom>0){
      Future.delayed(Duration(milliseconds: 200),(){
        if(Application.keyboardHeight!=MediaQuery.of(this.context).viewInsets.bottom){
          Application.keyboardHeight=MediaQuery.of(this.context).viewInsets.bottom;
          if (mounted) {
            setState(() {

            });
          }
        }
      });
    }

    if(Application.keyboardHeight>0){
      keyboardHeight=Application.keyboardHeight;
    }
    if(keyboardHeight<90){
      keyboardHeight=300.0;
    }


    return  AnimatedContainer(
      duration: Duration(milliseconds: 50),
      height: _emojiState?keyboardHeight:0.0,
      child: Container(
        height: _emojiState?keyboardHeight:0.0,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColor.white,
          border: Border(
            top: BorderSide(color: Colors.grey, width: 0.2),
          ),
        ),
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
          color: AppColor.transparent,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _emojiGridTop(keyboardHeight),
              ),
              SliverToBoxAdapter(
                child: _emojiBottomBox(),
              ),
            ],
          ),
        ),
        onTap: () {},
      );
    }
  }

  //获取表情头部的 内嵌的表情
  Widget _emojiGridTop(double keyboardHeight) {
    return Container(
      height: keyboardHeight-45.0,
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
            if( _textController.text==null|| _textController.text.length<1){
              _textController.text="";
              cursorIndexPr=0;
            }
            if(cursorIndexPr>=0) {
              _textController.text = _textController.text.substring(0, cursorIndexPr) + emojiModel.code +
                  _textController.text.substring(cursorIndexPr, _textController.text.length);
            }else{
              _textController.text += emojiModel.code;
            }
            cursorIndexPr+=emojiModel.code.length;
          },
        ));
  }


  //表情的bar
  Widget _emojiBottomBox() {
    TextStyle textStyle = const TextStyle(
      fontSize: 24,
    );
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
          Container(
            height: 44,
            width: 44,
            child: Center(
              child: Text(
                emojiModelList[64].emoji,
                style: textStyle,
              ),
            ),
          ),
          Spacer(),
          Container(
            height: 44,
            width: 44,
            child: Center(
              child: IconButton(
                icon: Icon(
                  Icons.send,
                  size: 24,
                ),
                onPressed: () => _onSubmitClick(_textController.text),
              ),
            ),
          ),
        ],
      ),
    );
  }


  //输入框bar内的edit
  Widget edit() {
    return TextSpanField(
      onTap: (){
        isShowEmojiBtn=true;
        _emojiState=false;
        setState(() {});
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
      onChanged: (text){},
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


  Widget getBottomBar0(){
    return Container(
      height: 48.0,
      alignment: Alignment.centerLeft,
      color: AppColor.transparent,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(child: SizedBox(child: getTextEditUi())),
          GestureDetector(
            child: Container(
              width: 32.0,
              height: 32.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(16)),
                color: AppColor.white.withOpacity(0.06),
              ),
              child: Icon(Icons.closed_caption_disabled_outlined,color: AppColor.white,size: 12),
            ),
            onTap: (){
              setState(() {
                isCleaningMode=!isCleaningMode;
              });
            },
          ),
          SizedBox(width: 12),
          GestureDetector(
            child: Container(
              width: 32.0,
              height: 32.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(16)),
                color: AppColor.white.withOpacity(0.06),
              ),
              child: Icon(Icons.settings,color: AppColor.white,size: 12),
            ),
            onTap:(){
              openBottomSetDialog(buildContext:context,voidCallback:_isCleaningMode);
            },
          ),
          SizedBox(width: 12),
          GestureDetector(
            child: Container(
              width: 32.0,
              height: 32.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(16)),
                color: AppColor.white.withOpacity(0.06),
              ),
              child: Icon(Icons.close,color: AppColor.white,size: 12),
            ),
            onTap: _exitPageListener,
          ),
        ],
      ),
    );
  }


  void _isCleaningMode(bool isCleaningMode){
    print("isCleaningMode:$isCleaningMode");
    Future.delayed(Duration(milliseconds: 50),(){
      setState(() {
        this.isCleaningMode=isCleaningMode;
      });
    });
  }

  Widget getTextEditUi(){
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
        child: Text("说点什么吧...",style: TextStyle(color: AppColor.white.withOpacity(0.35),fontSize: 14)),
      ),
      onTap: (){
        if(ClickUtil.isFastClick()){
          return;
        }
        isShowEditPlan=true;
        setState(() {

        });
        Future.delayed(Duration(milliseconds: 80),(){
          FocusScope.of(context).requestFocus(_focusNode);
          setState(() {});
        });
      },
    );
  }




  void getBottomDialog(){

    if(_focusNode.hasFocus){
      _focusNode.unfocus();
    }
    isShowEditPlan=false;
    if(_emojiState){
      setState(() {
        _emojiState=!_emojiState;
      });
    }
    List<String> list = [];
    list.add("回复");
    list.add("举报");
    list.add("复制");
    openMoreBottomSheet(
      context: context,
      isFillet: true,
      lists: list,
      onItemClickListener: (index) {
        print("value${list[index]}");
      },
    );
  }


  //获取底部评论列表的高度
  double getBottomMessageHeight(){
    return (ScreenUtil.instance.height-
        ScreenUtil.instance.statusBarHeight-
        ScreenUtil.instance.bottomBarHeight-48.0)*0.25;
  }


  void initData()async{
    //获取表情的数据
    emojiModelList = await EmojiManager.getEmojiModelList();
  }

  //监听动画是否开始
  void _initTimeDuration() {
    timer=Timer.periodic(Duration(seconds: 1), (timer) {
      if(mounted) {
        Element e = findChild(context as Element, timeText);
        if (e != null) {
          timeText = Text(DateUtil.getSpecifyDateTimeDifferenceMinutesAndSeconds(widget.startTime)
              , style: TextStyle(fontSize: 18, color: AppColor.white.withOpacity(0.85)));
          e.owner.lockState(() {
            e.update(timeText);
          });
        }
      }
    });
  }


  // 监听返回事件
  Future<bool> _requestPop() {
    EventBus.getDefault().post(registerName: EVENTBUS_LIVEROOM_EXIT);
    return new Future.value(true);
  }

  //退出界面
  _exitPageListener(){
    EventBus.getDefault().post(registerName: EVENTBUS_LIVEROOM_EXIT);
    EventBus.getDefault().unRegister(pageName:EVENTBUS_ROOM_OPERATION_PAGE,registerName: EVENTBUS_ROOM_RECEIVE_BARRAGE);
    if(timer!=null){
      timer.cancel();
      timer=null;
    }
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    super.dispose();
    EventBus.getDefault().unRegister(pageName:EVENTBUS_ROOM_OPERATION_PAGE,registerName: EVENTBUS_ROOM_RECEIVE_BARRAGE);
    if(timer!=null){
      timer.cancel();
      timer=null;
    }
  }

  //接收直播间弹幕消息
  void receiveBarrageMessage(message){
    Message msg=(message as Message);
    print("message:${msg.targetId},${widget.coachId}");
    if(msg.targetId!=widget.coachId.toString()){
      Application.rongCloud.quitChatRoom(msg.targetId);
      return;
    }
    TextMessage textMessage=(msg.content as TextMessage);
    Map<String, dynamic> contentMap = json.decode(textMessage.content);
    if(null!=contentMap){
      switch (contentMap["subObjectName"]) {
        case ChatTypeModel.MESSAGE_TYPE_SYS_BARRAGE:
          _onSubmitJoinLiveRoomMessage(textMessage.sendUserInfo.name,textMessage.sendUserInfo.userId);
          break;
        case ChatTypeModel.MESSAGE_TYPE_USER_BARRAGE:
          _onSubmitLiveRoomMessage(textMessage.sendUserInfo.name,textMessage.sendUserInfo.userId,contentMap["data"]);
          break;
        default:
          break;
      }
    }
  }


  //界面空白处点击事件
  void _onClickBodyListener(){
    if(isCleaningMode){
      setState(() {
        isCleaningMode=!isCleaningMode;
      });
      return;
    }
    if(_focusNode.hasFocus){
      _focusNode.unfocus();
    }
    isShowEmojiBtn=true;
    isShowEditPlan=false;
    if(_emojiState){
      _emojiState=!_emojiState;
      setState(() {});
    }
  }

  ///这是关注的方法
  _onClickAttention()async {
    if (!(coachRelation == 1 || coachRelation == 3)) {
      int attntionResult = await ProfileAddFollow(widget.coachId);
      print('关注监听=========================================$attntionResult');
      if (attntionResult == 1 || attntionResult == 3) {
        coachRelation = 1;
        if (mounted) {
          setState(() {});
        }
      }
    }
  }


  //发送按钮点击事件
  _onSubmitClick(text) {
    if(null==text||text.length<1){
      return;
    }
    _sendChatRoomMsg(text);
    _textController.text="";
    _onSubmitLiveRoomMessage(Application.profile.nickName,Application.profile.uid.toString(),text);
    if(!_emojiState) {
      FocusScope.of(context).requestFocus(_focusNode);
    }
  }


  //加入普通消息
  _onSubmitLiveRoomMessage(String name,String userId,String content){
    setState(() {
      messageChatList.insert(0, UserMessageModel(
        name: name,
        uId: userId,
        messageContent: content,
      ));
    });
  }

  //加入进入直播间的消息
  _onSubmitJoinLiveRoomMessage(String name,String userId){
    setState(() {
      messageChatList.insert(0, UserMessageModel(
        name: name,
        uId: userId,
        messageContent: "进入了直播",
        isJoinLiveRoomMessage: true,
      ));
    });
  }

  _sendChatRoomMsg(text) async {
    TextMessage msg = TextMessage();
    UserInfo userInfo = UserInfo();
    userInfo.userId = Application.profile.uid.toString();
    userInfo.name = Application.profile.nickName;
    userInfo.portraitUri = Application.profile.avatarUri;
    msg.sendUserInfo = userInfo;
    Map<String, dynamic> textMap = Map();
    textMap["fromUserId"] = msg.sendUserInfo.userId.toString();
    textMap["toUserId"] = "1";
    textMap["subObjectName"] = ChatTypeModel.MESSAGE_TYPE_USER_BARRAGE;
    textMap["name"] = ChatTypeModel.MESSAGE_TYPE_USER_BARRAGE_NAME;
    textMap["data"] = text;
    msg.content = jsonEncode(textMap);
    await Application.rongCloud.sendChatRoomMessage(widget.coachId.toString(), msg);
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
}
