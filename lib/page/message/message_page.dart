import 'package:flutter/material.dart';
import 'package:mirror/api/message_page_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/dto/conversation_dto.dart';
import 'package:mirror/data/dto/friends_cell_dto.dart';
import 'package:mirror/data/dto/group_chat_dto.dart';
import 'package:mirror/data/notifier/rongcloud_status_notifier.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/count_badge.dart';
import 'package:mirror/widget/no_blue_effect_behavior.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../if_page.dart';
import 'delegate/callbacks.dart';

/// message_page
/// Created by yangjiayi on 2020/12/21.

class MessagePage extends StatefulWidget {
  @override
  MessageState createState() => MessageState();
}

class MessageState extends State<MessagePage> with AutomaticKeepAliveClientMixin {
  List<int> _conversationList = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];

  // List<int> _conversationList = [];
  double _screenWidth = 0.0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _screenWidth = ScreenUtil.instance.screenWidthDp;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            leading: null,
            backgroundColor: AppColor.white,
            title: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 28,
                ),
                Expanded(
                    child: Center(
                  child: Text(
                    "消息（${context.watch<RongCloudStatusNotifier>().status}）",
                    style: AppStyle.textMedium18,
                  ),
                )),
                GestureDetector(
                  onTap: (){
                    //TODO 正国之前写的方法 需要仔细研究下
                    PanelController expectedPc = SingletonForWholePages.singleton().panelController();
                    if(expectedPc.isPanelClosed() == true){
                      SingletonForWholePages.singleton().panelController().open();
                    }else{
                      SingletonForWholePages.singleton().panelController().close();
                    }
                  },
                  child: Container(
                    width: 28,
                    height: 28,
                    color: AppColor.mainBlue,
                  ),
                ),
              ],
            )),
        body: ScrollConfiguration(
            behavior: NoBlueEffectBehavior(),
            child: ListView.builder(
                itemCount: _conversationList.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _buildTopView();
                  } else {
                    return _buildConversationItem(index);
                  }
                })));
  }

  //消息列表上方的所有部分
  Widget _buildTopView() {
    return Column(
      children: [_buildConnectionView(), _buildMentionView(), _buildPermissionView(), _buildEmptyView()],
    );
  }

  Widget _buildConnectionView() {
    return Container(
      height: 36,
      color: AppColor.mainRed.withOpacity(0.1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 16,
          ),
          Icon(
            Icons.error_outline,
            size: 16,
            color: AppColor.mainRed,
          ),
          SizedBox(
            width: 6,
          ),
          Text(
            "网络连接已断开，请检查网络设置",
            style: TextStyle(fontSize: 14, color: AppColor.mainRed),
          ),
          Spacer(),
          Icon(
            Icons.chevron_right,
            size: 16,
            color: AppColor.mainRed,
          ),
          SizedBox(
            width: 16,
          )
        ],
      ),
    );
  }

  Widget _buildMentionView() {
    double size = _screenWidth / 3;
    return Container(
      height: size,
      child: Row(
        children: [
          _buildMentionItem(size, 0),
          _buildMentionItem(size, 1),
          _buildMentionItem(size, 2),
        ],
      ),
    );
  }

  //这里暂时不写枚举了 0评论 1@ 2点赞
  Widget _buildMentionItem(double size, int type) {
    var colors = [Colors.deepOrangeAccent, Colors.deepPurpleAccent, Colors.cyanAccent];
    return Container(
      height: size,
      width: size,
      color: colors[type],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            overflow: Overflow.visible,
            children: [
              Container(
                height: 45,
                width: 45,
                color: AppColor.mainBlue,
              ),
              Positioned(
                  left: 6.5,
                  top: 6.5,
                  child: Container(
                    height: 32,
                    width: 32,
                    color: AppColor.bgBlack,
                  )),
              Positioned(
                  left: 29.5,
                  child: CountBadge(
                      type == 0
                          ? 100
                          : type == 1
                              ? 1
                              : 28,
                      18,
                      12)),
            ],
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            type == 0
                ? "评论"
                : type == 1
                    ? "@我"
                    : "点赞",
            style: AppStyle.textRegular16,
          )
        ],
      ),
    );
  }

  Widget _buildPermissionView() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        color: AppColor.mainBlue,
        height: 56,
      ),
    );
  }

  Widget _buildEmptyView() {
    return _conversationList.isNotEmpty
        ? Container()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 28,
              ),
              Container(
                width: 224,
                height: 224,
                color: AppColor.mainBlue,
              ),
              SizedBox(
                height: 16,
              ),
              Text(
                "这里空空如也，去推荐看看吧",
                style: AppStyle.textSecondaryRegular14,
              ),
              SizedBox(
                height: 28,
              ),
            ],
          );
  }

  Widget _buildConversationItem(int index) {
    var colors = [Colors.greenAccent, Colors.grey];
    return Container(
      height: 69,
      color: colors[index % 2],
    );
  }
}



















///////////////////////////////////////////创建群聊页面/////////////////////////////////
class CreateGroupChatWidget extends StatefulWidget {
  CreateGroupChatWidget({Key key}):super(key: key);
  CreatGroupChatWidgetState ptr;
  @override
  State<StatefulWidget> createState() {
    ptr = CreatGroupChatWidgetState();
    return ptr;
  }
}
class CreatGroupChatWidgetState extends State<CreateGroupChatWidget> {
  //好友选择人数组合结果放置数组
  Map<String,FriendCellDto> selectCombination = Map<String,FriendCellDto>();
  //已经选中的cell的state
  List<FriendsCellState> selectedCellList = List();
  //
  List<int> users = List<int>();
  //每个section的item的数量情况（可能包括了其header在内）
  List<int> itemsInSection = List();
  //记录每个sectionHeader所在的位置(索引)
  List<int> sectionHeaderLocates =List();
  //一个全局的计数变量
  int accumulated = 0;
  //搜索的内容检查
  TextEditingController _editController = TextEditingController();
  //搜索框删除按钮的的key
  GlobalKey inputDeleteKey = GlobalKey();
  //用于listView的key
  GlobalKey listViewKey = GlobalKey();
  //创建群聊的key
  GlobalKey createGroupChatKey = GlobalKey();

  //创建群聊是否可点击
  bool _createGroupChatEnable = false;
  //控制输入框的删除按钮的显示与否
  bool _hideDeleting = true;
  //控制显示发起聊天按钮的显示与否
  bool _hideGroupChatBtn = false;
  //发起按钮的可点击背景色


  //瀑布流的显示数据源
  FriendsDataSourceDelegate dataSource = FriendsDataSource();
  //选择群聊的人数监听函数(来自于内部的cell的选择与否)
  void selectionCheck(dynamic payload){
    Map st = payload;
    FriendCellDto theDto = st[FriendsCell.callBackPayLoadKeyForDto];
    bool friendsDtoStatus = st[FriendsCell.callBackPayLoadKeyForStatus];
    selectedCellList.add(st[FriendsCell.callbackPayLoadKeyForState]);

    if(friendsDtoStatus == true){
      selectCombination[theDto.uid] = theDto;
    }
    else{
      selectCombination.remove(theDto.uid);
    }
    CreateGroupChatButtonState creatGroupChatstate = createGroupChatKey.currentState;
    int selectedMember = selectCombination.keys.length;
    //选择人数不大于20人
    if(selectedMember>0&&selectedMember<= 20){
      _createGroupChatEnable = true;
      creatGroupChatstate.changeTitle(selectedMember);
    }else{
      print("create chat nonenable");
      _createGroupChatEnable = false;
      creatGroupChatstate.changeTitle(selectedMember);
    }
  }
  //发起群聊函数
  _createGroupChat() async{
    if(_createGroupChatEnable == false){
      return;
    }
    List<String> theKeys = List();
    theKeys.addAll(selectCombination.keys);
    print("selected persons is ${selectCombination.toString()}");
    print("thekeys :$theKeys");
    //创建请求群聊接口
    createGroupChat(theKeys).then(
            (GroupChatDto dto){
          print("创建群聊是否成功 $dto");
          ConversationDto cdto = ConversationDto.fromGroupChat(dto);
          //需要取得消息页面的State属性进行添加会话的操作
          // MessagePageState1 msgState =  SingletonForWholePages.singleton().messagePageKey.currentState;
          //创建群聊
          // msgState.createNewConversation(cdto);
        }
    );
    print("after create groupChat");
    //清除旧的选择数据
    selectedCellList.forEach((element) {
      FriendsCellState cellState = element;
      cellState._chooseStatus = false;
      cellState.setState(() {
      });
    });
    //关闭弹窗
    SingletonForWholePages.singleton().panelController().close();
  }

  //输入检查
  _inputChecks(){
    if(_editController.text == ""){
      _hideDeleting = true;
    }else{
      _hideDeleting = false;
    }
    setState(() {
    });
  }
  //跳转去展示加入过的群聊
  _showJoinedGroup(){
    print("_showJoinedGroup");
  }
  @override
  void initState() {

    dataSource.belonged = this;
    super.initState();
    _editController.addListener(() {
      _inputChecks();
    });
    /////////////////////////////////////////////////////////////////
    //进行区头的索引位的记录
    //找出每个section的数量情况（一个section可能存在有sectionHeader，进行+1表示进行记录
    for(int sectionIndex = 0;sectionIndex<dataSource.numOfSections();sectionIndex++){
      //如果存在有sectionheader的话，则将其所在的索引记录起来
      if(dataSource.sectionHeaderAtIndex(sectionIndex) != null){
        itemsInSection.add(dataSource.itemsCountInSectionAtIndex(sectionIndex)+1);
        int sectionSpot = 0;
        int accumulated = 0;
        //这个section区间的第一个头部。故记录前面的数量之和
        for(int j = 0;j<sectionIndex;j++){
          accumulated += itemsInSection[j];
          sectionSpot = accumulated ;
        }
        //记录下此时存在的section头部的索引位置（位于这个section区间的第一个）
        sectionHeaderLocates.add(sectionSpot);
      }else{
        //不存在sectionheader的情况
        itemsInSection.add(dataSource.itemsCountInSectionAtIndex(sectionIndex));
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    print("创建群聊 building~");
    return Stack(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //创建群聊的"把手"的ui样式
            Container(width: 32,height: 4,color: AppColor.bgWhite,margin:const EdgeInsets.only(top: 16),),
            //搜索框
            Row(
                children: [
                  Expanded(child: Container(
                    color: AppColor.bgWhite,
                    child: Container(height: 32,
                      child: TextField(key: inputDeleteKey,controller: _editController,
                        decoration: InputDecoration(prefixIcon: Image.asset("images/resource/searchGroup.png",
                          alignment:Alignment.center,),
                          //需要设置此项来使得文字和前方的图标齐平
                          contentPadding: EdgeInsets.only(bottom: 12),
                          hintText: "搜索用户",
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColor.transparent),
                            borderRadius: BorderRadius.all(Radius.circular(3)),
                          ),border: InputBorder.none,
                          suffixIcon: Offstage(child: GestureDetector(
                            onTap: (){_editController.text = "";_hideDeleting = true;setState(() {
                            });},
                            child: Container(child: Image.asset("images/resource/deleteAll.png"),
                              width: 18.4,height: 18.04,),),
                            offstage: _hideDeleting,),
                        ),
                      ),
                    ),
                    margin:const EdgeInsets.only(top: 24,left: 16,right: 16,bottom: 10),
                  ),
                  ),]),
            //FIXME:这里的是截屏的暂时使用的，需要替换
            Row(children: [
              Expanded(child: JoinedGroupChatCell(title: "已加入的群聊",
                  portait: "images/test/temp.png",
                  leftstyle: true,
                  statusChangeCall: _showJoinedGroup),
              )
            ],),
            //瀑布流列表(需要注意的是ListView不能在其builder中返回null值，若出现null值则终止于此)
            Expanded(child:
            Container(child:ListView.builder(key: listViewKey,
                // physics: ClampingScrollPhysics(),
                itemCount: _expectedItemCount(),
                padding: EdgeInsets.all(0),
                itemBuilder:(BuildContext context,int index){
                  return _cellElement(index);
                  // return _cellElement(index);
                }),
              //需要为"创建群聊"按钮留出空隙
              margin:const EdgeInsets.only(bottom: 44),
            )
            )
            //
          ],
        ),
        //发起群聊按钮
        Container(child: Offstage(
          offstage: _hideGroupChatBtn,
          child: Row(
            children: [
              Expanded(child:
              Container(child:
              Container(child: Row(children: [
                Expanded(child: GestureDetector(child:CreateGroupChatButton(key: createGroupChatKey,),
                  onTap: (){_createGroupChat();},))
              ],),
                height: 44,
                margin:const EdgeInsets.only(left: 16,right: 16),
              ),
                alignment: Alignment.bottomCenter,
              ),
              )
            ],
          ),
        )),
      ],
    );
  }
  //取得分区中的索引
  int _getIndexOfSectionFromRawIndex(int index){
    int sectionBelong = 0;
    sectionHeaderLocates.forEach((element) {
      if(index > element ){
        sectionBelong++;
      }
    });
    return sectionBelong;
  }
  //返回整个界面的cell布局
  Widget _cellElement(int index){
    /////////////
    //区头索引命中则返回区头
    if(sectionHeaderLocates.contains(index)){
      Widget rs = dataSource.sectionHeaderAtIndex(_getIndexOfSectionFromRawIndex(index)) ;
      if(rs == null){
        throw "list View 不许提供对应位置的非null的widget,否则会导致后面的元素无法显示";
      }
      return rs;
    }
    //不是区头的情况则返回内容性cell
    //获取所在分区
    int sectionBelong = -1;
    sectionHeaderLocates.forEach((element) {
      if(index > element ){
        sectionBelong++;
      }
    });
    //将index映射为在对应section中的index
    int preCells = 0;
    for(int temp = 0;temp < sectionBelong;temp++){
      preCells += sectionHeaderLocates[temp];
    }
    int expectedIndex = index - preCells -(preCells>0 ? 1:0);
    return dataSource.cell(sectionBelong, expectedIndex);
  }

  //期望的item的数量
  int _expectedItemCount(){
    int total = 0;
    int sectionCount = dataSource.numOfSections();
    if(sectionCount == 0){sectionCount = 1;}
    for(int i = 0;i<sectionCount;i++){
      total +=  dataSource.itemsCountInSectionAtIndex(i);
      if(dataSource.sectionHeaderAtIndex(i) != null){
        total += 1;
      }
    }
    print("_expectedItemCount is $total");
    return total;
  }

}
//构建创建群聊页面的接口（返回widget的函数不能返回null,否则会使得ListView的builder止步于此处）
abstract class FriendsDataSourceDelegate{
  //反向引用
  dynamic belonged;
  //每个分区里边的cell数量
  int itemsCountInSectionAtIndex(int index);
  //分区数量
  int numOfSections();
  //分区头部生成
  Widget sectionHeaderAtIndex(int index);
  //item生成
  Widget cell(int atSection,int atIndex);
}
//！！！！好友数据的数据源(返回值为widget的函数不能没有非null的返回值，否则会影响ListView的显示工作)
class FriendsDataSource implements FriendsDataSourceDelegate{
  //放置好友数据的数组
  List<int> users = List<int>();
  List<FriendCellDto> friends = List<FriendCellDto>();
  //数组添加数据
  FriendsDataSource(){
    users.addAll([1001531,1000000,1008611,1000111,1000467,1001531,1002549,1004704,1021057,1021479,1021570,1022654]);
    users.forEach((element) {
      FriendCellDto dto = FriendCellDto();
      dto.uid = "$element";
      dto.nickName = "$element";
      dto.portraitUrl = "http://tiebapic.baidu.com/forum/w%3D580%3B/sign=84189ee79526cffc692abfba893a4b90/0bd162d9f2d3572c228274a29d13632762d0c368.jpg";
      friends.add(dto);
    });
  }
  @override
  int itemsCountInSectionAtIndex(int index) {
    return 3;
  }

  @override
  int numOfSections() {
    return 3;
  }
  //每个分区的头部视图(如果没有分区，则返回高度为0的控件即可，但是和index相关的ui变化不能自动识别，需要自行计算)
  @override
  Widget sectionHeaderAtIndex(int index) {
    return SectionHeaderCell(index: index,);
  }
  //每个item的生成
  @override
  Widget cell(int atSection, int atIndex) {
    CreatGroupChatWidgetState state = this.belonged;
    if(atSection == 0){
      return  FriendsCell(fDto: friends[atIndex],
        statusChangeCall: state.selectionCheck,);
    }
    else if (atSection == 1){
      return  FriendsCell(fDto: friends[atIndex],
        statusChangeCall: state.selectionCheck,);
    }
    else if (atSection == 2){
      return  FriendsCell(fDto: friends[atIndex],
        statusChangeCall: state.selectionCheck,);
    }

  }
  //这个引用只想datasource的所属
  @override
  var belonged;

}

//已加入的群聊的cell
class JoinedGroupChatCell extends StatefulWidget{
  //事件回调
  final VoidCallback statusChangeCall;
  JoinedGroupChatCell({Key key,
    @required this.title,
    @required this.portait,
    @required this.leftstyle,
    @required this.statusChangeCall}):super(key: key);
  final String title;
  final String portait;
  final bool leftstyle;
  @override
  State<StatefulWidget> createState() {
    return _JoinedGroupChatCellState();
  }

}
class _JoinedGroupChatCellState extends State<JoinedGroupChatCell>{

  @override
  Widget build(BuildContext context) {
    switch(widget.leftstyle){
      case true:
        return GestureDetector(
          child: Expanded(child: Container(
            color: AppColor.white,
            height: 48,
            child: Row(crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("images/test/temp.png")
                  ),
                ),margin: EdgeInsets.only(left: 28),width: 24,height: 24,),
                Container(child: Text(widget.title,
                  style: TextStyle(color: AppColor.textPrimary1,
                      fontFamily: "PingFangSC",
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      decoration: TextDecoration.none),),
                  margin: EdgeInsets.only(left: 4),),
                Spacer(),
                Container(child: Image.asset("images/test/leftNavi.png"),width: 18,height: 18,margin: EdgeInsets.only(right: 16),),
              ],),
          )),
          onTap: ()=>this.widget.statusChangeCall(),
        );
        break;
      default:
        return Expanded(child: Container(height: 48,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(width: 18,height: 18,child: null,margin: EdgeInsets.only(left: 16),),
              Spacer(),
              Container(child: Text("已加入的群聊",
                style: TextStyle(color: AppColor.textPrimary1,
                    decoration: TextDecoration.none,
                    fontFamily: "PingFangSC",
                    fontWeight: FontWeight.w400,
                    fontSize: 16
                ),
              ),)
            ],
          ),));
    }
  }

}
////////////////////////////////////////////////////
//分区头部cell
class SectionHeaderCell extends StatelessWidget{
  List<String>  alphabet = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"];
  final String title;
  final int index;
  SectionHeaderCell({Key key,@required this.title,@required this.index}):super(key: key);

  @override
  Widget build(BuildContext context) {
    String theTitle;
    int theindex;

    if(title == null){
      theindex = index > alphabet.length ? alphabet.length - 1 :index;
      theTitle = alphabet[theindex];
    }else{
      theTitle = title;
    }
    return Row(children: [
      Container(child: Text(theTitle,
        style: TextStyle(fontFamily: "PingFangSC",
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColor.textPrimary3),),
        height:28,
        margin: EdgeInsets.only(left: 22),
        alignment: Alignment.centerLeft,
      ),
      Spacer()
    ], crossAxisAlignment: CrossAxisAlignment.center,);
  }

}

//好友cell
class FriendsCell extends StatefulWidget{
  //
  static const String callBackPayLoadKeyForDto = "callBackPayloadKey";
  static const String callBackPayLoadKeyForStatus = "callBackPayLoadKeyForStatus";
  static const String callbackPayLoadKeyForState = "callbackPayLoadKeyForState";
  FriendsCell({Key key,@required this.fDto,@required this.statusChangeCall}):super(key: key);
  final FriendCellDto fDto;
  final MPVoidCallWithValue  statusChangeCall;
  @override
  State<StatefulWidget> createState() {
    return FriendsCellState();
  }

}
class FriendsCellState extends State<FriendsCell>{
  bool _chooseStatus = false;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container(
          height: 48,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //头像
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                    image: DecorationImage(
                      //fixme:需要改成由网络来进行加载
                      image:NetworkImage(widget.fDto.portraitUrl),
                      fit: BoxFit.cover,
                    ),
                    shape: BoxShape.circle
                ),margin: EdgeInsets.only(left: 16),),
              //标题
              Container(child: Text(widget.fDto.nickName,),margin: EdgeInsets.only(left: 12),),
              //
              Spacer(),
              //选择框
              //FixMe:这里貌似有点触摸不是很灵敏的感觉，可能和触控机制或者图标本身有关
              GestureDetector(
                child: _chooseWidget(),
                onTap: (){
                  _chooseStatus = !_chooseStatus;
                  Map<String,dynamic> payload = Map<String,dynamic>();
                  payload[FriendsCell.callBackPayLoadKeyForStatus] = _chooseStatus;
                  payload[FriendsCell.callBackPayLoadKeyForDto] = widget.fDto;
                  payload[FriendsCell.callbackPayLoadKeyForState] = this;
                  this.widget.statusChangeCall(payload);
                  setState(() {
                  });
                },
              )
            ],
          ),))
      ],
    );
  }
  //选中还是没选中的widget
  Widget _chooseWidget(){
    switch(_chooseStatus){
      case true:
        return Container(decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("images/resource/选中.png")
            )
        ), margin: EdgeInsets.only(right: 16),
          width: 24,
          height: 24,);
        break;
      default:
        return Container(width: 24,
          height: 24,
          padding: EdgeInsets.all(2),
          margin: EdgeInsets.only(right: 16),
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(9.5),
                border: Border.all(width: 1,
                    color: AppColor.textHint
                )
            ),),
        );
        break;
    }
  }
}
class CreateGroupChatButton extends StatefulWidget{
  CreateGroupChatButton({Key key,}):super(key: key);
  @override
  State<StatefulWidget> createState() {
    return CreateGroupChatButtonState();
  }

}
class CreateGroupChatButtonState extends State<CreateGroupChatButton>{
  //按钮的标题
  static const startChatTitle = "发起聊天";
  static const startGroupChatTitle = "发起群聊";
  Color _chatBtnBg_active = AppColor.textPrimary1;
  //发起按钮的不可点击的背景色
  Color _chatBtnBg_inActive = AppColor.textHint;
  //发起按钮的文字颜色
  Color _chatBtnTextBg_inactive = AppColor.white;
  //按钮的背景颜色
  Color btnColor;
  //发起群聊的按钮的标题颜色
  Color btnTitleColor;
  //发起聊天或群聊的标题
  String btnTitle;
  //状态标题的改变
  changeTitle(int groupCount){
    if(groupCount == 1){
      btnTitle = startChatTitle;
      btnColor = _chatBtnBg_active;
    }else if(groupCount == 0){
      btnTitle = startChatTitle;
      btnColor = _chatBtnBg_inActive;
    }
    else {
      btnTitle = startGroupChatTitle + "$groupCount";
      btnColor = _chatBtnBg_active;
    }
    setState(() {
    });
  }
  @override
  void initState() {
    btnTitle = startChatTitle;
    btnColor = _chatBtnBg_inActive;
    btnTitleColor = _chatBtnTextBg_inactive;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return  Container(
      child: Text(btnTitle,style: TextStyle(color: btnTitleColor,decoration: TextDecoration.none),),
      alignment: Alignment.center,
      decoration: BoxDecoration(color: btnColor,
          borderRadius: BorderRadius.circular(3)
      ),
    );
  }

}