import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/util/toast_util.dart';

typedef VoidCallback = void Function(String content, BuildContext context);

// 通讯录数据
class Friends {
  String imageUrl; //头像
  String name; // 用户名
  String indexLetter; //首字母大写
  int uid;

  Friends({this.imageUrl, this.name, this.indexLetter, this.uid});
}

// 通讯录索引bar
class IndexBar extends StatefulWidget {
  //创建索引条回调
  final void Function(String str) indexBarCallBack;

  IndexBar({this.indexBarCallBack});

  @override
  _IndexBarState createState() => _IndexBarState();
}

int getIdex(BuildContext context, Offset globalPosition, List index_word) {
//  拿到box
  RenderBox box = context.findRenderObject();
//  拿到y值
  double y = box.globalToLocal(globalPosition).dy;
//  算出字符高度  box 的总高度 / 2 / 字符开头数组个数
  var itemHeight = ScreenUtil.instance.height / 2 / index_word.length;
  //算出第几个item，并且给一个取值范围   ~/ y除以item的高度取整  clamp 取值返回 0 -
  int index = (y ~/ itemHeight).clamp(0, index_word.length - 1);

  print('现在选中的是${index_word[index]}');
  return index;
}

class _IndexBarState extends State<IndexBar> {
  double _indicatorY = 0.0; //悬浮窗位置
  String _indicatorText = 'A'; //显示的字母
  bool _indocatorHidden = true; //是否隐藏悬浮窗

  final List<String> _index_word = [];
  List<String> indicatorTextList = [];

// 索引文字颜色
  List<Color> _index_color = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
//----------------------- 1 -------------------------------
//    1、根据实际数据显示右侧bar
//    _index_word.add('#');
//    _listDatas.addAll(datas);
//    //排序!
//    _listDatas.sort((Friends a, Friends b) {
//      return a.indexLetter.compareTo(b.indexLetter);
//    });

    // 经过循环，将每一个头的首字母放入index_word数组
//    for (int i = 0; i < _listDatas.length; i++) {
//      if (i < 1 || _listDatas[i].indexLetter != _listDatas[i - 1].indexLetter) {
//        _index_word.add(_listDatas[i].indexLetter);
//      }
//    }

    //----------------------- 2 -------------------------------
//    2、右侧bar显示全部字母
    _index_word.addAll(INDEX_WORDS);
    for (var i = 0; i < _index_word.length; i++) {
      _index_color.add(AppColor.textSecondary);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> words = [];
    for (int i = 0; i < _index_word.length; i++) {
      if (i == 0) {
        words.add(Expanded(
          child: Image.asset("images/resource/2.0x/search_icon_gray@2x.png",width: 12,height: 12,),
        ));
      } else {
        words.add(Expanded(
            child: Text(
          _index_word[i],
          style: TextStyle(fontSize: 11, color: _index_color[i]),
        )));
      }
    }

    return Positioned(
      right: 15.0,
      height: ScreenUtil.instance.height / 2,
      top: ScreenUtil.instance.height / 6,
      width: 120,
      child: Row(
        children: <Widget>[
          Container(
            alignment: Alignment(0, _indicatorY),
            width: 100,
            child: _indocatorHidden
                ? null
                : Stack(
                    alignment: Alignment(-0.2, 0), //0, 0 是中心顶部是0，-1  左边中心是-1，0
                    children: <Widget>[
                      Image(
                        image: AssetImage('images/resource/share_index_bubble@2x.png'),
                        width: 28,
                        height: 28,
                      ),
                      Text(
                        _indicatorText,
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ],
                  ), //气泡
          ),
          GestureDetector(
            child: Container(
              width: 20,
              // child: ListView.builder(
              //   scrollDirection: Axis.vertical,
              //     itemCount: _index_word.length,
              //     itemBuilder: (context,)
              // ),
              child: Column(
                children: words,
              ),
            ),
            onVerticalDragUpdate: (DragUpdateDetails details) {
              int index = getIdex(context, details.globalPosition, _index_word);
              setState(() {
                _indicatorText = _index_word[index];

                //   for (var i = 0; i < _index_color.length;i++) {
                //     if (_index_word[index] == _indicatorText) {
                //       _index_color[index] =  AppColor.bgBlack;
                //   } else {
                //       _index_color[index] =  AppColor.textSecondary;
                //     }
                // }
                //根据我们索引条的Alignment的Y值进行运算的。从 -1.1 到 1.1
                //整个的Y包含的值是2.2
                _indicatorY = 2.2 / _index_word.length * index - 1.1;
                _indocatorHidden = false;
              });
              widget.indexBarCallBack(_index_word[index]);
            }, //按住屏幕移动手指实时更新触摸的位置坐标

            onVerticalDragDown: (DragDownDetails details) {
              //globalPosition 自身坐标系
              int index = getIdex(context, details.globalPosition, _index_word);
              _indicatorText = _index_word[index];
              _indicatorY = 2.2 / _index_word.length * index - 1.1;
              _indocatorHidden = false;
              widget.indexBarCallBack(_index_word[index]);
              print('现在点击的位置是${details.globalPosition}');
              setState(() {
                // if (_index_word[index] == _indicatorText) {
                //   _index_color[index] =  AppColor.bgBlack;
                // }
              });
            }, //触摸开始

            onVerticalDragEnd: (DragEndDetails details) {
              setState(() {
                _indocatorHidden = true;
                // _index_color.clear();
                // for(var i = 0; i < _index_word.length;i++) {
                //   _index_color.add(AppColor.textSecondary);
                // }
                // _textColor =  AppColor.textSecondary;
              }); //触摸结束
            },
          ) //这个是索引条
        ],
      ),
    );
  }
}

const INDEX_WORDS = [
  '🔍',
  'A',
  'B',
  'C',
  'D',
  'E',
  'F',
  'G',
  'H',
  'I',
  'J',
  'K',
  'L',
  'M',
  'N',
  'O',
  'P',
  'Q',
  'R',
  'S',
  'T',
  'U',
  'V',
  'W',
  'X',
  'Y',
  'Z',
  '#'
];

class FriendsPage extends StatefulWidget {
  final VoidCallback voidCallback;

  const FriendsPage({
    Key key,
    this.voidCallback,
  }) : super(key: key);

  @override
  _FriendsPageState createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
//  字典里面放item和高度的对应数据
  final Map _groupOffsetMap = {
//    这里因为根据实际数据变化和固定全部字母前两个值都是一样的，所以没有做动态修改，如果不一样记得要修改
    INDEX_WORDS[0]: 0.0,
    INDEX_WORDS[1]: 0.0,
  };
  List<String> names = [
    'Lina',
    '菲儿',
    '安莉',
    '阿贵',
    '鞍山市',
    "13131",
    "!#%",
    '🔍',
    '马上就到吉安',
    'aw',
    'dasda',
    '先存着',
    '茁壮成长',
    '啦啦啦',
    '密密麻麻所',
    '了杜拉拉',
    '卡顿快速反馈',
    'uuu',
    '天通苑',
    '啪啪啪',
    '二位若无',
    '不是吧',
    'oooo',
    '你忙吧表空间和',
    '库',
    'UI',
    'IPO',
    'BNM',
    '我偶偶',
    '已已',
    '哦哦哦',
    '已',
    '应用于',
    '通天塔',
    '让人',
    '嗯嗯',
    '无误',
    '请求',
    '换行',
    '公告',
    '方法',
    '单独',
    '搜索',
    '啊啊',
    '种植',
    '消息',
    '传出',
    '不不v ',
    '不不不',
    '你你你',
    '你你你',
    '买买买',
    '了劳累过度',
    'AA制',
    '阿萨斯',
    '硕大的撒',
    '大概放电饭锅',
    '回复回复',
    '讲话稿几个'
  ];
  ScrollController _scrollController;

  // 排序字母数组
  final List<Friends> _listDatas = [];

  // 非字母#数组
  final List<Friends> nonLetterlistDatas = [];

  @override
  void initState() {
    //初始化，只调用一次
    // TODO: implement initState
    super.initState();
    // 测试到时替换为model
    for (String name in names) {
      Friends friendData = Friends();
      // 转换拼音再截取搜字母转大写
      String pinyinString =
          PinyinHelper.getPinyinE(name, separator: " ", defPinyin: '#', format: PinyinFormat.WITHOUT_TONE).capitalize();
      RegExp mobile = RegExp(r"[a-zA-Z]");
      if (!mobile.hasMatch(pinyinString)) {
        pinyinString = "#";
        friendData.name = name;
        friendData.indexLetter = pinyinString;
        friendData.imageUrl = "https://randomuser.me/api/portraits/women/23.jpg";
        nonLetterlistDatas.add(friendData);
      } else {
        friendData.name = name;
        friendData.indexLetter = pinyinString;
        friendData.imageUrl = "https://randomuser.me/api/portraits/women/27.jpg";
        _listDatas.add(friendData);
      }
    }
    //排序!
    _listDatas.sort((Friends a, Friends b) {
      return a.indexLetter.compareTo(b.indexLetter);
    });
    _listDatas.addAll(nonLetterlistDatas);
    // 总偏移
    var _groupOffset = 0.0;
    // 间距高度
    int spacingHeight = 0;
    //经过循环计算，将每一个头的位置算出来，放入字典
    for (int i = 0; i < _listDatas.length; i++) {
      if (i < _listDatas.length - 1 && _listDatas[i + 1].indexLetter == _listDatas[i].indexLetter) {
        spacingHeight = 10;
      } else {
        spacingHeight = 0;
      }
      if (i < 1 || _listDatas[i].indexLetter != _listDatas[i - 1].indexLetter) {
        //第一个cell
        _groupOffsetMap.addAll({_listDatas[i].indexLetter: _groupOffset});
        //保存完了再加——groupOffset偏移
        _groupOffset += 76.5;
        _groupOffset += spacingHeight;
      } else {
        //此时没有头部，只需要加偏移量就好了
        _groupOffset += 48;
        _groupOffset += spacingHeight;
      }
    }
    _scrollController = ScrollController();
  }

  Widget itemForRow(BuildContext context, int index,int noBottomIndex) {
    //显示剩下的cell
    //如果当前和上一个cell的indexLetter一样，就不显示
    bool _hideIndexLetter = (index > 0 && _listDatas[index].indexLetter == _listDatas[index - 1].indexLetter);
    return _FriendsCell(
      imageUrl: _listDatas[index].imageUrl,
      name: _listDatas[index].name,
      groupTitle: _hideIndexLetter ? null : _listDatas[index].indexLetter,
      noBottomIndex: noBottomIndex,
      voidCallback: widget.voidCallback,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "选择联系人",
          style: TextStyle(color: AppColor.textPrimary1, fontSize: 18, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: AppColor.white,
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pop(true);
          },
          child: Image.asset(
            "images/resource/2.0x/return2x.png",
            width: 28,
            height: 28,
          ),
        ),
        leadingWidth: 28.0,
        // MyIconBtn(
        //   // width: 28,
        //   // height: 28,
        //   iconSting: "images/resource/2.0x/return2x.png",
        //   onPressed: () {
        //     Navigator.of(context).pop(true);
        //   },
        // ),
      ),
      body: Stack(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(left: 16, right: 16, top: 18, bottom: 10),
            height: 32,
            color: AppColor.bgWhite_65,
            width: ScreenUtil.instance.screenWidthDp,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 12,
                ),
                Image.asset(
                  "images/resource/2.0x/search_icon_gray@2x.png",
                  width: 21,
                  height: 21,
                ),
                Expanded(
                  child: Container(
                    height: 32,
                    alignment: Alignment.center,
                    child: TextField(
                      textInputAction: TextInputAction.search,
                      decoration: new InputDecoration(
                          isCollapsed: true,
                          contentPadding: EdgeInsets.only(top: 0, bottom: 0, left: 6),
                          hintText: '搜索用户',
                          hintStyle: TextStyle(color: AppColor.textSecondary),
                          border: InputBorder.none),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
              color: AppColor.white,
              margin: EdgeInsets.only(top: 60),
              child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _listDatas.length,
                  itemBuilder: (context, index) {
                    int noBottomIndex = 0;
                    if (index < _listDatas.length - 1 && _listDatas[index + 1].indexLetter != _listDatas[index].indexLetter) {
                      noBottomIndex = index;
                    }
                    return itemForRow(context, index,noBottomIndex);
                  })), //列表
          IndexBar(
            indexBarCallBack: (String str) {
              if (_groupOffsetMap[str] != null) {
                _scrollController.animateTo(_groupOffsetMap[str],
                    duration: Duration(milliseconds: 1), curve: Curves.easeIn);
              }
            },
          ), //悬浮检索控件
        ],
      ),
    );
  }
}

class _FriendsCell extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String groupTitle;
  final String imageAssets;
  final VoidCallback voidCallback;
  int noBottomIndex = 0;

  _FriendsCell(
      {this.imageUrl,
      this.name,
      this.imageAssets,
      this.groupTitle,
      this.noBottomIndex = 0,
      this.voidCallback}); //首字母大写

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        child: _buildUi(),
      ),
      onTap: () {
        print(name);
        if (voidCallback != null) {
          voidCallback(name, context);
        }
      },
    );
  }

  Widget _buildUi() {
    return Column(
      children: <Widget>[
        Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(left: 16),
          height: groupTitle != null ? 28.5 : 0,
          color: AppColor.bgWhite,
          child: groupTitle != null
              ? Text(
                  groupTitle,
                  style: TextStyle(fontSize: 14, color: AppColor.textPrimary3),
                )
              : null,
        ), //组头
        Container(
          color: Colors.white,
          height: 48,
          margin: EdgeInsets.only(bottom:  noBottomIndex == 0 ? 10 : 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(left: 16),
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(19.0),
                    image: DecorationImage(
                      image: imageUrl != null ? NetworkImage(imageUrl) : AssetImage(imageAssets),
                    )),
              ), //图片
              Container(
                margin: EdgeInsets.only(left: 12),
                child: Text(
                  name,
                  style: TextStyle(fontSize: 15),
                ),
              ), //昵称
            ],
          ),
        ), //通讯录组内容
      ],
    );
  }

}

// 返回搜字母大写
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}";
  }
}
