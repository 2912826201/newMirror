
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/message/emoji_model.dart';
import 'package:mirror/page/message/item/emoji_manager.dart';
import 'package:mirror/util/click_util.dart';
import 'package:mirror/util/event_bus.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/feed/feed_more_popups.dart';
import 'package:mirror/widget/icon.dart';
import 'package:mirror/widget/volume_popup.dart';
import 'package:text_span_field/text_span_field.dart';


class LiveRoomTestPageDialog extends StatefulWidget {
  @override
  _LiveRoomTestPageDialogState createState() => _LiveRoomTestPageDialogState();
}

class _LiveRoomTestPageDialogState extends State<LiveRoomTestPageDialog> {

  List<String> messageChatList=[];

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

  // 监听返回
  Future<bool> _requestPop() {
    EventBus.getDefault().post("",registerName: "LiveRoomTestPage-exit");
    return new Future.value(true);
  }

  int cursorIndexPr=-1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    messageChatList.add("请你遵守直播间的规则!请你遵守直播间的规则!"
        "请你遵守直播间的规则!请你遵守直播间的规则!请你遵守直播间的规则!");
    
    _focusNode.addListener(() {
      cursorIndexPr=_textController.selection.baseOffset;
    });
    initData();
  }

  void initData()async{
    //获取表情的数据
    emojiModelList = await EmojiManager.getEmojiModelList();
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
            onTap: (){
              if(_focusNode.hasFocus){
                _focusNode.unfocus();
              }
              isShowEditPlan=false;
              if(_emojiState){
                _emojiState=!_emojiState;
                setState(() {});
              }
            },
          ),
        ),
        onWillPop: _requestPop);

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
      height: 48.0,
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
          onTap: (){
            setState(() {
              isCleaningMode=!isCleaningMode;
            });
          },
        ),
      ),
    );
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
                  child: getUserImage(null,21,21),
                  right: 0,
                ),
                Positioned(
                  child: getUserImage(null,21,21),
                  right: 12,
                ),
                Positioned(
                  child: getUserImage(null,21,21),
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
        padding: const EdgeInsets.symmetric(horizontal: 11,vertical: 4),
        decoration: BoxDecoration(
          color: AppColor.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            getUserImage(null,28,28),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("洪荒少女我FaceJu",style: TextStyle(fontSize: 11,color: AppColor.white.withOpacity(0.85))),
                Text("在线人数8524.2万",style: TextStyle(fontSize: 9,color: AppColor.white.withOpacity(0.65))),
              ],
            ),
            SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColor.mainRed,
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 11,vertical: 2),
              child: Text("关注",style: TextStyle(fontSize: 10,color: AppColor.white)),
            )
          ],
        ),
      ),
    );
  }

  //训练
  Widget trainingTimeUi(){
    return Container(
      child: Column(
        children: [
          Text("120:23",style: TextStyle(fontSize: 18,color: AppColor.white.withOpacity(0.85))),
          Text("训练时长",style: TextStyle(fontSize: 10,color: AppColor.white.withOpacity(0.35))),
        ],
      ),
    );
  }



  double getBottomHeight(){
    return (ScreenUtil.instance.height-
        ScreenUtil.instance.statusBarHeight-
        ScreenUtil.instance.bottomBarHeight-48.0)*0.25;
  }
  


  Widget getBottomPlan(){
    return Column(
      children: [
        Container(
          height: getBottomHeight(),
          child: getListView(),
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
          child: Text(
            messageChatList[index],
            maxLines: 100,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              color: AppColor.white.withOpacity(0.85),
            ),
          ),
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
  //发送按钮点击事件
  _onSubmitClick(text) {
    if(null==text||text.length<1){
      return;
    }
    setState(() {
      messageChatList.insert(0, text);
      _textController.text="";
    });
    if(!_emojiState) {
      FocusScope.of(context).requestFocus(_focusNode);
    }
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
                isShowMessage=!isShowMessage;
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
              showVolumePopup(context);
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
            onTap: (){
              setState(() {
                isCleaningMode=!isCleaningMode;
              });
            },
          ),
        ],
      ),
    );
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








  //获取用户的头像
  Widget getUserImage(String imageUrl, double height, double width) {
    if (imageUrl == null || imageUrl == "") {
      imageUrl =
      "http://pic.netbian.com/uploads/allimg/201220/220540-16084731404798.jpg";
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: CachedNetworkImage(
        height: height,
        width: width,
        imageUrl: imageUrl == null ? "" : imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Image.asset(
          "images/test/bg.png",
          fit: BoxFit.cover,
        ),
        errorWidget: (context, url, error) => Image.asset(
          "images/test/bg.png",
          fit: BoxFit.cover,
        ),
      ),
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


}

class SimpleRoute extends PageRoute {
  SimpleRoute({
    @required this.name,
    @required this.title,
    @required this.builder,
  }) : super(
    settings: RouteSettings(name: name),
  );

  final String title;
  final String name;
  final WidgetBuilder builder;

  @override
  String get barrierLabel => null;

  @override
  bool get opaque => false;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => Duration(milliseconds: 0);

  @override
  Widget buildPage(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      ) {
    return Title(
      title: title,
      color: Theme.of(context).primaryColor,
      child: builder(context),
    );
  }

  /// 页面切换动画
  @override
  Widget buildTransitions(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
      ) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }

  @override
  Color get barrierColor => null;
}
