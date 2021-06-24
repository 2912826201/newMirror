import 'package:amap_location_muka/amap_location_muka.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mirror/api/amap/amap.dart';
import 'package:mirror/config/application.dart';
import 'package:mirror/config/runtime_properties.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/model/home/home_feed.dart';
import 'package:mirror/data/model/loading_status.dart';
import 'package:mirror/data/model/media_file_model.dart';
import 'package:mirror/data/model/peripheral_information_entity/peripheral_information_entify.dart';
import 'package:mirror/data/model/profile/buddy_list_model.dart';
import 'package:mirror/page/feed/release_page_item/at_list.dart';
import 'package:mirror/page/feed/release_page_item/feed_header.dart';
import 'package:mirror/page/feed/release_page_item/keyboard_input.dart';
import 'package:mirror/page/feed/release_page_item/release_feed_main_view.dart';
import 'package:mirror/page/feed/release_page_item/topic_list.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/input_formatter/release_feed_input_formatter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

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
  final int topicId;
  final int videoCourseId;

  ReleasePage({this.topicId, this.videoCourseId});

  @override
  ReleasePageState createState() => ReleasePageState();
}

class ReleasePageState extends State<ReleasePage> with WidgetsBindingObserver {
  SelectedMediaFiles _selectedMediaFiles;
  TextEditingController _controller = TextEditingController();
  FocusNode feedFocus = FocusNode();

  // 权限
  PermissionStatus permissions;

  // at的索引数组
  List<Rule> rules = [];
  Location currentAddressInfo; //当前位置的信息
  List<PeripheralInformationPoi> pois = []; //返回周边信息页面显示的数据集合

  Rule topicRule; // 传入的话题生成规则

  @override
  void dispose() {
    print("当前页面销毁了？？？？？？？？？？");
    _controller.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void initState() {
    //TODO 取出来判断是否为空 非空则将图片视频作为初始值 取出后需将Application中的值清空
    print("查明￥${RuntimeProperties.selectedMediaFiles}");
    // 获取定位权限
    locationPermissions();
    WidgetsBinding.instance.addObserver(this);
    _selectedMediaFiles = RuntimeProperties.selectedMediaFiles;
    RuntimeProperties.selectedMediaFiles = null;

    //如果topicId不为空 则取topicModel出来生成预设的插入话题
    if (widget.topicId != null) {
      TopicDtoModel topicModel = Application.topicMap[widget.topicId];
      if (topicModel != null) {
        _controller.text = "#${topicModel.name}";
        _controller.selection = TextSelection(
          baseOffset: _controller.text.length,
          extentOffset: _controller.text.length,
        );
        topicRule = Rule(0, _controller.text.length, _controller.text, null, false, topicModel.id);
      }
    }
    super.initState();
  }

  @override

  ///监听用户回到app
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      backToBack();
    }
  }

  // 前台回到后台
  backToBack() async {
    var status = await Permission.locationWhenInUse.status;
    if (permissions != null && permissions != PermissionStatus.granted && status == PermissionStatus.granted) {
      //flutter定位只能获取到经纬度信息
      currentAddressInfo = await AmapLocation.fetch(iosAccuracy: AmapLocationAccuracy.HUNDREE_METERS);
      // 调用周边
      aroundHttp();
    }
  }

  // 获取定位权限
  locationPermissions() async {
    // 获取权限状态
    permissions = await Permission.locationWhenInUse.status;
    switch (permissions) {
      // 用户拒绝访问请求的功能
      case PermissionStatus.denied:
        return 0;
      // 用户授予了对所请求功能的访问权限
      case PermissionStatus.granted:
        //flutter定位只能获取到经纬度信息
        print("flutter定位只能获取到经纬度信息");
        currentAddressInfo = await AmapLocation.fetch(iosAccuracy: AmapLocationAccuracy.HUNDREE_METERS);
        print("currentAddressInfo::::::${currentAddressInfo.toJson()}");
        // 调用周边
        aroundHttp();
        return 1;

      ///操作系统拒绝访问请求的功能。 用户无法更改
      ///此应用程序的状态，可能是由于活动限制（例如父母身份）
      ///控制就位。
      /// *仅在iOS上受支持。*
      case PermissionStatus.restricted:
        return 2;

      ///尚未请求许可。
      //fixme 权限枚举变化
      // case PermissionStatus.undetermined:
      ///部分许可 ios14
      case PermissionStatus.limited:
        return 3;

      ///用户拒绝访问请求的功能，并选择从不
      ///再次显示对此权限的请求。 用户仍然可以更改
      ///设置中的权限状态。
      /// *仅在Android上受支持。
      case PermissionStatus.permanentlyDenied:
        return 4;
      default:
        throw UnimplementedError();
    }
  }

  //高德接口获取周边数据
  aroundHttp() async {
    PeripheralInformationEntity locationInformationEntity =
        await aroundForHttp(currentAddressInfo.longitude, currentAddressInfo.latitude);
    if (locationInformationEntity != null && locationInformationEntity.status == "1") {
      print('请求成功');
      if (locationInformationEntity.pois.isNotEmpty) {
        pois = locationInformationEntity.pois;
        // 城市信息导入
        PeripheralInformationPoi poi1 = PeripheralInformationPoi();
        poi1.name = locationInformationEntity.pois.first.cityname;
        poi1.id = Application.cityId;
        poi1.citycode = locationInformationEntity.pois.first.citycode;
        // 获取城市经纬度
        Application.cityMap.forEach((key, value) {
          value.forEach((v) {
            if (v.regionCode == poi1.citycode) {
              poi1.location = v.longitude.toString() + "," + v.latitude.toString();
            }
          });
        });
        // print("高德返回￥${poi1.citycode}");
        print(" 插入城市${poi1.toString()}");
        pois.insert(0, poi1);
      }
      if (mounted) {
        setState(() {});
      }
    } else {
      // 请求失败
    }
  }

  @override
  Widget build(BuildContext context) {
    double inputHeight = MediaQuery.of(context).viewInsets.bottom;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColor.white,
        resizeToAvoidBottomInset: false,
        body: ChangeNotifierProvider(
          create: (_) => ReleaseFeedInputNotifier(
            inputText: "",
            rules: topicRule == null ? [] : [topicRule],
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
                  FeedHeader(
                    selectedMediaFiles: _selectedMediaFiles,
                    controller: _controller,
                    videoCourseId: widget.videoCourseId,
                  ),
                  // 输入框
                  KeyboardInput(controller: _controller),
                  // 中间主视图
                  str == "@"
                      ? Expanded(
                          child: Container(
                              child: AtList(controller: _controller),
                              margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom)))
                      : str == "#"
                          ? Expanded(
                              child: Container(
                                  child: TopicList(controller: _controller),
                                  margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom)))
                          : ReleaseFeedMainView(
                              selectedMediaFiles: _selectedMediaFiles,
                              permissions: permissions,
                              pois: pois,
                              currentAddressInfo: currentAddressInfo,
                            )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// 发布动态文本监听
class ReleaseFeedInputNotifier extends ChangeNotifier {
  ReleaseFeedInputNotifier({
    this.keyWord,
    this.inputText,
    this.rules,
    this.atCursorIndex,
    this.atSearchStr,
    this.topicSearchStr,
    this.selectedMediaFiles,
  });

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

  // 发布动态选择的地址详细信息
  PeripheralInformationPoi selectAddress;

  // 发布动态选择的地址文本
  String seletedAddressText = "你在哪儿";

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

  setPeripheralInformationPoi(PeripheralInformationPoi poi) {
    this.selectAddress = poi;
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
  setClickTopic(bool top) {
    this.isClickTopic = top;
  }
}
