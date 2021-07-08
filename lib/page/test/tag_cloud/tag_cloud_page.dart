import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/data/notifier/profile_notifier.dart';
import 'package:mirror/page/test/tag_cloud/tag_cloud_test_widget.dart';
import 'package:mirror/util/file_util.dart';
import 'package:provider/provider.dart';

var _data = [
  {"ID": "111", "name": "这是文字飒飒", "num": "张三"},
  {"ID": "222", "name": "这是文阿斯达撒", "num": "李四"},
  {"ID": "333", "name": "撒大声地", "num": "王五"},
  {"ID": "444", "name": "大萨达", "num": "马六"},
  {"ID": "555", "name": "sad撒大所大所多", "num": "小明"},
  {"ID": "666", "name": "大叔大婶大", "num": "小红花"},
  {"ID": "777", "name": "奥术大师大所多", "num": "手术室"},
  {"ID": "888", "name": "奥术大撒大声地师大所所", "num": "阿斯达"},
  {"ID": "999", "name": "厄齐尔群翁群", "num": "阿斯达是"},
  {"ID": "101010", "name": "驱蚊器翁群翁群翁群翁群翁群翁群", "num": "手不仓储部术室"},
  // {"ID": "111111", "name": "热特润特热瑞特瑞特瑞特瑞特瑞特让他", "num": "从VB从VB"},
  // {"ID": "121212", "name": "让他一人一人头盔查看格式开放课上课的方式开福克斯福克斯的快递费开始开发开始", "num": "符合恢复恢复哈哈哈"},
  // {"ID": "131313", "name": "鱼可以看见有空余哭一哭一块  ", "num": "价格好几个"},
  // {"ID": "141414", "name": "体育有图图图与体验", "num": "黑胡椒客户机和"},
];

class TagCloudPage extends StatefulWidget {
  @override
  _TagCloudPageState createState() => _TagCloudPageState();
}

class _TagCloudPageState extends State<TagCloudPage> {
  double rpm = 4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: AppColor.white,
      appBar: AppBar(
        title: Text("标签云测试"),
      ),
      body: SingleChildScrollView(
        child:
        Column(
            mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.center, children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: LayoutBuilder(builder: (context, constraints) {
              return TagCloud(constraints.maxWidth, constraints.maxHeight, _data,
                  rpm: this.rpm);
            }),
          ),
          Container(
            child: ClipOval(
              child: CachedNetworkImage(
                height: 68,
                width: 68,
                useOldImageOnUrlChange: true,
                // 调整磁盘缓存中图像大小
                // maxHeightDiskCache: 150,
                // maxWidthDiskCache: 150,
                // 指定缓存宽高
                memCacheWidth: 150,
                memCacheHeight: 150,
                imageUrl:
                context
                    .watch<ProfileNotifier>()
                    .profile
                    .avatarUri != null
                    ? FileUtil.getSmallImage(context
                    .watch<ProfileNotifier>()
                    .profile
                    .avatarUri)
                    : "",
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Container(
                      color: AppColor.bgWhite,
                    ),
                errorWidget: (context, url, error) =>
                    Container(
                      color: AppColor.bgWhite,
                    ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 16),
            child:Text("Hi，用户${context
                .watch<ProfileNotifier>()
                .profile.nickName}",style: TextStyle(fontSize: 20,fontWeight: FontWeight.w700),),
          ),
          Container(
            margin: EdgeInsets.only(top: 6),
            child:Text("写下来IF的目标吧",style: TextStyle(color: AppColor.textSecondary),),
          ),
          Container(
            margin: EdgeInsets.only(top: 20,left: 50,right: 50),
            alignment: Alignment(1,0),
            height: 48,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(24)),
              color: AppColor.textSecondary.withOpacity(0.3),
            ),
            child: Row(
              children: [
                SizedBox(width: 16),
                Text("具体的目标更容易达成哦",style: TextStyle(color: AppColor.textSecondary)),
                Spacer(),
                Icon(Icons.wysiwyg,color: AppColor.textSecondary,),
                SizedBox(width: 16)
              ],
            ),
          )
          // Container(
          //   color: Colors.white,
          //   child: Slider(
          //       value: this.rpm,
          //       min: 0,
          //       max: 10,
          //       onChanged: (value) {
          //         setState(() {
          //           this.rpm = value;
          //         });
          //       }),
          // ),
        ]),
      ),
    );
    // return Scaffold(
    //     // appBar: AppBar(title:Text("标签云测试")),
    //     backgroundColor: AppColor.mainRed,
    //     body: Padding(
    //         padding: const EdgeInsets.all(30.0),
    //         child: TagCloud())
    //         // child: TagCloudWidget(400, _data, rpm: 3))
    // );
  }
}
