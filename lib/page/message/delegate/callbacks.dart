
//消息页的回调种类

//不带的参数的回调
import 'package:flutter/cupertino.dart';
typedef MPCallbackWithValueNoPara = dynamic Function();
typedef MPVoidCallback = Function ();
//带一个参数的回调
typedef MPCallbackWithValue = dynamic Function (dynamic) ;
//函数绑定派发中心
abstract class MPActionBindCenter{
  //单例
  static MPActionBindCenter shareInstance(){
    return _MPActionBindCenter();
  }
  //获取函数调用
  Function widgetAction(Widget widget,String tag);
  //调用绑定
  void actionWidgetBind(Function func,Widget widget,String tag);
}
//函数、方法和widget映射类(一般来说在flutter中widget都是局部和暂时的，使用前应考虑好)
class _MPActionBindCenter implements MPActionBindCenter{
  //映射方式为widget -> String类型标识符 ->函数调用
  Map<Widget,Map<String,Function>>_mapping = Map();
  @override
  Function widgetAction(Widget widget,String tag){
   return _mapping[widget][tag];
  }
  @override
  void actionWidgetBind(Function func,Widget widget,String tag){
   if(_mapping[widget]==null){
     _mapping[widget]=Map();
   }
     _mapping[widget][tag] = func;
  }
}
