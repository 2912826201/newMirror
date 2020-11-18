//融云消息接收类,单例
abstract class RongCloudReceiveManager {
  static RongCloudReceiveManager _me;
  //单例构造函数
  static RongCloudReceiveManager shareInstance(){
   if (_me==null){
     _me = _RongCloudReceiveManager();
   }
   return _me;
 }
}
class _RongCloudReceiveManager extends RongCloudReceiveManager{
   _RongCloudReceiveManager(){
     _init();
   }
   //初始化工作
   _init(){

   }

}