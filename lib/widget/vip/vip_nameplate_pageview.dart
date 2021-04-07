
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/page/profile/vip/vip_nameplate_page.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/vip/vip_nameplate_horazontal_list.dart';
import 'package:provider/provider.dart';
class VipNamePlatePageView  extends StatefulWidget{
  PageController pageController;
  ScrollController scrollController;
  List<String> namePlateList;
  VipNamePlatePageView({this.namePlateList,this.pageController,this.scrollController});
  @override
  State<StatefulWidget> createState() {
    return _VipNamePlatePageState();
  }

}
class _VipNamePlatePageState extends State<VipNamePlatePageView>{
  List<String> contentList = [
    "彰显尊贵身份",
    "量身定制个人专属计划",
    "专属饮食和营养指导",
    "提供练前练后专属建议",
    "科学指导智能纠错",
    "免费训练所有直播，视频课程",
    "专业教练实时针对性指导",
    "和好友一起视频一起练",
    "便捷查看训练结果",
    "群组内在线答疑，让训练更高效",
  ];
  List<String> imageList = [
    "https://ss1.bdstatic.com/70cFvXSh_Q1YnxGkpoWK1HF6hhy/it/u=1491622188,2856001475&fm=26&gp=0.jpg",
    "https://ss0.bdstatic.com/70cFuHSh_Q1YnxGkpoWK1HF6hhy/it/u=3345450554,3432169032&fm=26&gp=0.jpg",
    "https://ss0.bdstatic.com/70cFuHSh_Q1YnxGkpoWK1HF6hhy/it/u=3412286164,295662108&fm=26&gp=0.jpg",
    "https://ss3.bdstatic.com/70cFv8Sh_Q1YnxGkpoWK1HF6hhy/it/u=2176413831,288079380&fm=26&gp=0.jpg",
    "https://ss2.bdstatic.com/70cFvnSh_Q1YnxGkpoWK1HF6hhy/it/u=3685176780,1974427386&fm=26&gp=0.jpg",
    "https://ss0.bdstatic.com/70cFvHSh_Q1YnxGkpoWK1HF6hhy/it/u=4076357916,2563835014&fm=26&gp=0.jpg",
    "https://ss0.bdstatic.com/70cFuHSh_Q1YnxGkpoWK1HF6hhy/it/u=2194651031,1721494085&fm=26&gp=0.jpg",
    "https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=5574358,167660515&fm=26&gp=0.jpg",
    "https://ss0.bdstatic.com/70cFvHSh_Q1YnxGkpoWK1HF6hhy/it/u=2650148262,1983191614&fm=26&gp=0.jpg",
    "https://ss1.bdstatic.com/70cFvXSh_Q1YnxGkpoWK1HF6hhy/it/u=988082858,737428313&fm=26&gp=0.jpg",
  ];
  List<Widget> widgetList = [];
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    for(int i=0;i<contentList.length;i++){
      widgetList.add(_page(contentList[i],i));
    }
    return Container(
        height: ScreenUtil.instance.height-132+ScreenUtil.instance.statusBarHeight,
        width: ScreenUtil.instance.width,
        color: AppColor.white,
        child: PageView(
          controller: widget.pageController,
          children: widgetList,
          onPageChanged: (index){
                    context.read<VipMoveNotifier>().changeListOldIndex(index);
                    if(index>1&&index<contentList.length-2){
                      double i = (ScreenUtil.instance.screenWidthDp-namePlateWidth)/2;
                      double offset = namePlateWidth * index - i;
                      widget.scrollController.animateTo(offset, duration: Duration(milliseconds: 400), curve:Curves.ease);
                    }

          },
        ),
      );
  }

  Widget _page(String content,int index){
    return Container(
      padding: EdgeInsets.only(left: 16,right: 16),
      child:MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: ListView(
        shrinkWrap: true,
      children: [
        SizedBox(height: 14,),
        Text(widget.namePlateList[index],style: AppStyle.redMedium21,),
        SizedBox(height: 14,),
        Text(".${contentList[index]}",style: AppStyle.textPrimary3Regular14,),
        SizedBox(height: 32,),
        ClipRect(
          child: CachedNetworkImage(
            height: ScreenUtil.instance.width-32,
            width: ScreenUtil.instance.width-32,
            imageUrl: imageList[index],
            fit: BoxFit.cover,
            placeholder: (context, url) => Image.asset(
              "images/test.png",
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(
          height: ScreenUtil.instance.bottomBarHeight + 49,
        ),
      ],
    )));
  }
}