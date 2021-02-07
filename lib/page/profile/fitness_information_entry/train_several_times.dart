import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror/api/profile_page/profile_api.dart';
import 'package:mirror/constant/color.dart';
import 'package:mirror/constant/style.dart';
import 'package:mirror/data/model/profile/fitness_entry_model.dart';
import 'package:mirror/route/router.dart';
import 'package:mirror/util/screen_util.dart';
import 'package:mirror/widget/custom_appbar.dart';
import 'package:mirror/widget/custom_button.dart';
import 'package:mirror/widget/loading.dart';
import 'package:provider/provider.dart';

class TrainSeveralTimes extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _TrainSeveralTimesState();
  }

}
class _TrainSeveralTimesState extends State<TrainSeveralTimes>{
  bool three = false;
  bool four = false;
  bool fives = false;
  @override
  Widget build(BuildContext context) {
    double width = ScreenUtil.instance.screenWidthDp;
    double height = ScreenUtil.instance.height;
    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: CustomAppBar(),
      body: Container(
        width: width,
        height: height,
        child: Column(
          children: [
            SizedBox(
              height: height * 0.05,
            ),
            Center(
              child: Container(
                width: width * 0.78,
                child: Container(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    "你每周训练几次",
                    style: AppStyle.textMedium23,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 12,
            ),
            Center(
              child: Container(
                alignment: Alignment.centerLeft,
                width: width * 0.78,
                child: Text(
                  "我们将以此为你推荐训练计划，让你一试身手。",
                  style: AppStyle.textRegular14,
                ),),),

            SizedBox(
              height: height * 0.05,
            ),
            InkWell(
              onTap: (){

              },
              child: _button("训练3次",three,3),
            ),
            SizedBox(height: 28,),
            InkWell(
              onTap: (){

              },
              child: _button("训练4次",four,4),),
            SizedBox(height: 28,),
            InkWell(
              onTap: (){

              },
              child: _button("训练5次",fives,5),),
          ],
        ),
      ),
    );
  }
      Widget _button(String text,bool selected,int type){
        return Container(
          width: ScreenUtil.instance.screenWidthDp,
          padding: EdgeInsets.only(left: 41,right: 41),
          child: ClickLineBtn(
            title: text,
            height: 44.0,
            width: ScreenUtil.instance.screenWidthDp,
            circular:3.0,
            textColor: selected?AppColor.white:AppColor.textHint,
            fontSize: 16,
            backColor: selected?AppColor.bgBlack:AppColor.transparent,
            color: selected?AppColor.transparent:AppColor.textHint,
            onTap: (){
              Loading.showLoading(context);
              setState(() {
                switch(type){
                  case 3:
                     three = true;
                     context.read<FitnessInformationNotifier>().setTimeOfWeek(3);
                    break;
                  case 4:
                      four = true;
                      context.read<FitnessInformationNotifier>().setTimeOfWeek(4);
                    break;
                  case 5:
                      fives = true;
                      context.read<FitnessInformationNotifier>().setTimeOfWeek(5);
                    break;
                }
              });
              _fitnessEntry();
            },
          ),);
      }

      _fitnessEntry()async{
    FitnessEntryModel getModel = await userFitnessEntry(
      height: context.read<FitnessInformationNotifier>().height,
      weight: context.read<FitnessInformationNotifier>().weight,
      bodyType: context.read<FitnessInformationNotifier>().bodyType,
      target: context.read<FitnessInformationNotifier>().target,
      level: context.read<FitnessInformationNotifier>().level,
      keyPartList: context.read<FitnessInformationNotifier>().keyPartList,
      timesOfWeek: context.read<FitnessInformationNotifier>().timeOfWeek
    );
      if(getModel!=null){
        print('===============================健身信息录入成功');
        AppRouter.popToBeforeLogin(context);
    }else{
        print('================================健身信息录入失败');
    }
    Loading.hideLoading(context);
  }
}

class FitnessInformationNotifier extends ChangeNotifier{
  int height; //" : 180, 身高 cm
  int weight; //" : 55,  体重 kg
  int bodyType; //" : 1, 体型 0，1，2...
  int target; //" : 1, 目标 0:减脂 1:塑型 2：增肌 3：健康
  int level; //": 3, 难度 0：初级 1：中级 2：高级
  List<int> keyPartList; //" : [1,2], 重点部位 0：全身 1：手臂 2：肩部 ...
  int timeOfWeek;
FitnessInformationNotifier({this.weight,this.timeOfWeek,this.keyPartList,this.target,this.bodyType,this.height,this.level});

  void setHeightAndWeight(int heights,int weights){
    height = heights;
    weight = weights;
    notifyListeners();
  }
  void setBodyType(int bodyTypes){
    bodyType = bodyTypes;
    notifyListeners();
  }
  void setTarget(int targets){
    target = targets;
    notifyListeners();
  }
  void setHard(int levels){
    level = levels;
    notifyListeners();
  }
  void setKeyPartList(List<int> keyPartLists){
    keyPartList = keyPartLists;
    notifyListeners();
  }
  void setTimeOfWeek(int timeWeek){
    timeOfWeek = timeWeek;
    notifyListeners();
  }
}