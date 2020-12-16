import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/message_page_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/dto/conversation_dto.dart';
import 'package:mirror/data/dto/friends_cell_dto.dart';
import 'package:mirror/data/dto/group_chat_dto.dart';
import 'package:mirror/data/notifier/rongcloud_connection_notifier.dart';
import 'package:mirror/im/rongcloud_receive_manager.dart';
import 'package:mirror/im/rongcloud_status_manager.dart';
import 'package:mirror/page/if_page.dart';
import 'package:mirror/page/message/delegate/callbacks.dart';
import 'package:mirror/page/message/delegate/system_service_events.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'delegate/hooks.dart';
import 'delegate/message_interfaces.dart';
import 'delegate/message_page_ui_provider.dart';
import 'delegate/message_types.dart';
import 'delegate/regular_events.dart';
import 'delegate/business.dart';
import 'delegate/frame.dart';
import 'delegate/message_page_datasource.dart';
import 'package:provider/provider.dart';



abstract class MessagepageLocate{
  //双击识别的函数调用
  void doubleClick();
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////
//这个消息页面的构成如下：
//本页面State对象作controller,内置两个proxy，分别提供数据和ui，页面选择性地变化ui时，向ui的这一个proxy发送消息（见UIProxy接口）
//ui部分采用其dataActionPipe属性，通过代理方式将点击等事件转给此页面state对象处理，用字符串做区分(见MPUIAction接口)
//UI的数据是通过也通过dataActionPipe属性从本页面处的controller获取(实际是间接地从数据proxy出来，经过controller处置过后)
/////////////////////////////////////////////////////////////////////////////////////////////////////////
class MessagePage extends StatefulWidget {
  MessagePage({Key key}):super(key: key);
  @override
  State<StatefulWidget> createState() {
    return MessagePageState();
  }
}

class MessagePageState extends State<MessagePage>
    implements MPBasements,
        MPBusiness,
        MPHookFunc,
        MPNetworkEvents,
        MPUIActionWithDataSource,
        MPIMDataSourceAction,
        MessageObserver ,
        MessagepageLocate,
        RCStatusObservable
{
  static const LOSE_CONNECTION_CODE = 3;
  static const CONNECTING_CODE = 1;
  static const CONNECTED_CODE = 0;
  List imData = List();
  //隐藏评论与否
  bool _commentHide = true;
  @override
  Widget build(BuildContext context) {
    this.viewWillAppear();
    this.uiProvider.context = context;
    return Container(
            child: Column(
              children: [
                //需要为状态栏留出空隙
                SizedBox(width: MediaQuery.of(context).size.width, height: 44),
                //导航栏
                uiProvider.navigationBar(),
                //主内容
                uiProvider.mainContent(),
                //评论弹出区域
              ],
            ),
          );
   }
   @override
   void initState() {
    _registrations();
     _allocations();
     //根据安排需要放在initState方法中
     this.viewWillAppear();
     super.initState();
   }

   //一些注册绑定类型的事情
   _registrations() {

    RongCloudReceiveManager.shareInstance().observeAllKindsMsgs(this);
    //class RCConnectionStatus {
    //   static const int Connected = 0; //连接成功
    //   static const int Connecting = 1; //连接中
    //   static const int KickedByOtherClient = 2; //该账号在其他设备登录，导致当前设备掉线
    //   static const int NetworkUnavailable = 3; //网络不可用
    //   static const int TokenIncorrect = 4; //token 非法，此时无法连接 im，需重新获取 token
    //   static const int UserBlocked = 5; //用户被封禁
    //   static const int DisConnected = 6; //用户主动断开
    //   static const int Suspend = 13; // 连接暂时挂起（多是由于网络问题导致），SDK 会在合适时机进行自动重连
    //   static const int Timeout =
    //       14; // 自动连接超时，SDK 将不会继续连接，用户需要做超时处理，再自行调用 connectWithToken 接口进行连接
    // }
    //请参考RCConnectionStatus
    //关心断开、连接、连接中(回调见 void statusChangeNotification（）)
    // ConnectionStatus_Connected = 0,连接成功
    //  RongCloudStatusManager.shareInstance().registerNotificationForStatus(CONNECTED_CODE, this);
    // //ConnectionStatus_Connecting = 10,连接中
    //  RongCloudStatusManager.shareInstance().registerNotificationForStatus(CONNECTING_CODE, this);
    // // ConnectionStatus_Unconnected = 11,未连接
    //  RongCloudStatusManager.shareInstance().registerNotificationForStatus(LOSE_CONNECTION_CODE, this);

     //需要传入context来使用readme.md中的ValueNotifier来进行通知
     RongCloudStatusManager.shareInstance().context = context;
   }
    @override
    MPUiProxy uiProvider;
    //需要进行振动等向controller反馈的事件
    @override
    void feedBackForSys() {
     print("有消息");
    }
   //初始化和分配资源的事情
    _allocations() {
    //UI代理和数据代理生成//
    //数据源
    dataSource = MessagePageDataSource();
    //UI
    uiProvider = MessagePageUiProvider();
    //用于交互事件的反馈以及ui显示需要数据的提供
    uiProvider.dataActionPipe = this;
    dataSource.delegate = this;
    }

   //当删除一个会话cell时调用
    @override
    // ignore: non_constant_identifier_names
    void didDelete_a_Chat(MPChatVarieties type) {
     // TODO: implement didDelete_a_Chat
    }
   //发生点赞、评论、@事件时
    @override
    void regularEventsCall(MPIntercourses type) {
      print("regularEventsCall");
    }
    //视图第一次出现时，在flutter中对应是在build中
    @override
    void viewWillAppear() {
    print("viewWillAppear");
    }

   //当转去其他视图界面时(目前暂时放在dispose方法中)
    @override
    void viewDidDisappear() {
    print("viewDidDisappear");
    }
    @override
    void dispose() {
      this.uiProvider = null;
      //存储会话的数据
      this.dataSource.saveChats();
      this.dataSource = null;
    RongCloudReceiveManager.shareInstance().removeObserver(this);
    RongCloudStatusManager.shareInstance().cancelNotifications(this);
    this.viewDidDisappear();
    super.dispose();
   }


   // 下方均为向ui发送消息来处理对应事件，虽然本质上还是
   // ui将消息代理出来本controller处理，但是可以给ui本身一次处理事件的机会，让controller内部
   // 事件处理相对清晰一些

    //当网络连接丢失时，向ui源发送对应消息使其变化，
    @override
    void loseConnection() {
      print("this.loseConnection");
     uiProvider.loseConnection();
    }
    //进行再连接时
    @override
    void reconnected() {
      print("this.reconnected");
     uiProvider.reconnected();
    }
    //连接中时
    @override
    void connecting() {
      print("this.connectting");
    uiProvider.connecting();
    }
    //检测到需要开启系统通知后调用
    @override
    void activateNotificationBanner() {
    uiProvider.activateNotificationBanner();
    }
   //检测到系统通知已经被打开，需要关闭开启通知的横幅
   @override
   void dismissNotificationBanner() {
    uiProvider.dismissNotificationBanner();
   }
   ////////////////////////////////////
   //MPBusiness内的协议（接口）
   ////////////////////////////////////
    //社交事件到来时调用（通常是调取服务器接口发现未读数不为0）
    @override
    void eventsDidCome() {
    print("event comes");
    }
    //及时通讯消息的到来
    @override
    void imArrived() {
    print("页面消息来到整页性回调");
    }
   //////////////////////////////////////
   /////////////////////////////////////

   //  -------------------代理------------------------//
   //融云消息的注册的新消息来临的回调，可以选择性去调用imArrived()去执行ui上的变化
   @override
   Future<void> msgDidCome(Set<Message> msg, bool offLine) {
      print("msgDidCome");
      //调取一下页面的消息来临的函数，让页面本身做一些处理
      this.imArrived();
      //只有一条消息的情况，一般即为及时的消息
      if (msg.length == 1){
       _manipulateRegularMsg(msg.first);
      }
      //以消息集合的方式处理，一般为离线消息的来临
      else{
      _manipulateOffLineMessage(msg);
      }
   }
   //单个在线信息来到的处理
   void _manipulateRegularMsg(Message msg){
      Set<Message> _t = Set<Message>();
      _t.add(msg);
      this.newMsgsArrive(_t);
   }
   //列表性离线信息的来临
   void _manipulateOffLineMessage(Set<Message> msgs){
    this.newMsgsArrive(msgs);
   }
   //UI源发送来的交互事件
   @override
   void action(String identifier, {payload = Map, BuildContext context}) {
      print("action");
      print("$context");
    //setState(){}方法调用事件
    if (identifier == MessagePageUiProvider.FuncOf_setState_) {
      setState(() {});
    }
    //点赞和评论等事件
    else if (identifier == MessagePageUiProvider.FuncOfinterCourses) {
      if (payload != null && payload[MessagePageUiProvider.IntercoursesKey] != null) {
        MPIntercourses t = payload[MessagePageUiProvider.IntercoursesKey];
        switch (t) {
          case MPIntercourses.Laud:
            this.regularEventsCall(MPIntercourses.Laud);
            break;
          case MPIntercourses.At:
            this.regularEventsCall(MPIntercourses.At);
            break;
          case MPIntercourses.Comment:
            this.regularEventsCall(MPIntercourses.Comment);
            break;
        }
      }
    }
    //聊天cell的点击(使用 CellTapKey 从 payload 中取值)
    else if (identifier == MessagePageUiProvider.FuncOfCellTap) {
      int index = payload[MessagePageUiProvider.CellTapKey];
      uiProvider.imFreshData(index: index,newBadgets: 0);
      //model对应的数据也要更改
      dataSource.imCellData()[index].unread = 0;
      //进行跳转
      AppRouter.navigateToChatPage(context,dataSource.imCellData()[index],);

    }
    //导航栏按钮点击
    else if (identifier == MessagePageUiProvider.FuncOfNaviBtn) {
      _commentHide = !_commentHide;
      PanelController expectedPc = SingletonForWholePages.singleton().panelController();
      if(expectedPc.isPanelClosed() == true){
        SingletonForWholePages.singleton().panelController().open();
      }else{
        SingletonForWholePages.singleton().panelController().close();
      }
    }
    //跳转去处理网络
    else if (identifier == MessagePageUiProvider.FuncOfHandleNet) {
      // TODO: implement _MessagePageUiProvider.FuncOfHandleNet
    }
    //跳转去处理通知的开启
    else if (identifier == MessagePageUiProvider.FuncOfHandleNotify) {
      // TODO: implement _MessagePageUiProvider.FuncOfHandleNotify
    }
  }
   //数据源的事件
   @override
   void signals({Map<String,dynamic> payload}) {
    //事件区分
    String thekey = payload.keys.first;
    //刷新一个cell
    if(thekey == MessagePageDataSource.REFRESH_A_CHAT){
      print("single refresh");
      int index  = payload[thekey];
      uiProvider.imFreshData(index: index,dto: dataSource.imCellData()[index]);
    }
    //刷新整个列表
    else if (thekey == MessagePageDataSource.REFRESH_ALL_LIST){
      uiProvider.imFreshData();
    }
  }
   //及时会话的高度的ui代理
   @override
   double cellHeightAtIndex(int index) {
    return dataSource.cellHeightAtIndex(index);
   }
   //社交事件未读数
   @override
   Future< Map<MPIntercourses, int>> unreadOfIntercources(MPCallbackWithValue callback) async{
      return  await dataSource.unreadOfIntercources(callback);
   }

  //数据源属性
  @override
  MPDataProxy dataSource;

  //即时消息ui 数据代理
  @override
  List<ConversationDto> imCellData() {
   return dataSource.imCellData();
  }
  //有及时消息的来临,数据交给dataSource
  @override
  void newMsgsArrive(Set<Message> msgs) {
    if(dataSource != null) {
      dataSource.newMsgsArrive(msgs);
    }
  }
  //最新的官方会话的最新消息
  @override
  Map<Authorizeds, List<ConversationDto>> latestAuthorizedMsgs() {
    return dataSource.latestAuthorizedMsgs();
  }

  @override
  saveChats() {
   dataSource.saveChats();
  }
  //识别双击之后进行定位
  @override
  void doubleClick() {
    // TODO: implement doubleClick
  }
  //增加一个新的会话
  @override
  createNewConversation(ConversationDto dto) {
   dataSource.createNewConversation(dto);
  }
  //融云的状态改变的回调
  @override
  void statusChangeNotification(int status) {
    print("statusChangeNotification $status");
    switch(status){
      case LOSE_CONNECTION_CODE:
        this.loseConnection();
        break;
      case CONNECTING_CODE:
        this.connecting();
        break;
      case CONNECTED_CODE:
        this.reconnected();
        break;
    }
  }
   //-------------------------------------------------------------------//
}
abstract class ControlComments{
  //开启键盘
  void open();
  //关闭键盘
  void close();
}
/////////////////////////////////////////////////////////////////////////////////////
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
      createNewGroupChat(theKeys).then(
          (GroupChatDto dto){
            print("创建群聊是否成功 $dto");
            ConversationDto cdto = ConversationDto.fromGroupChat(dto);
            //需要取得消息页面的State属性进行添加会话的操作
            MessagePageState msgState =  SingletonForWholePages.singleton().messagePageKey.currentState;
            //创建群聊
            msgState.createNewConversation(cdto);
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