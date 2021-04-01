import 'package:mirror/data/model/home/home_feed.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// shared_preferences
/// Created by yangjiayi on 2020/12/15.

String prefsKeyIsFirstLaunch = "isFirstLaunch";
// 发布动态本地插入数据
String publishFeedLocalInsertData = "publishFeedLocalInsertDataPrefs";

String  downLoadKeyList = "downLoadKeyList";

class AppPrefs {
  static SharedPreferences _instance;

  static init() async {
    if (_instance == null) {
      _instance = await SharedPreferences.getInstance();
    }
  }

  // 是否是第一次启动
  static bool isFirstLaunch() {
    bool value = _instance.getBool(prefsKeyIsFirstLaunch);
    if (value == null) {
      value = true;
    }
    return value;
  }

  static setIsFirstLaunch(bool isFirstLaunch) {
    return _instance.setBool(prefsKeyIsFirstLaunch, isFirstLaunch);
  }
    ///存分段下载数据
  static setDownLoadChunkData(String url,String downLoadDetailData){
    if(AppPrefs.getDownLoadKeyList()==null){
      _instance.setStringList(downLoadKeyList, []);
    }
    if(!AppPrefs.getDownLoadKeyList().contains(url)){
      List<String> keyList= AppPrefs.getDownLoadKeyList();
      keyList.add(url);
      _instance.setStringList(downLoadKeyList,keyList);
    }
    return _instance.setString(url, downLoadDetailData);
  }
  ///移除下载任务
  static removeDownLadTask(String url){
     _instance.setString(url, null);
     List<String> keyList= AppPrefs.getDownLoadKeyList();
     keyList.remove(url);
     _instance.setStringList(downLoadKeyList,keyList);
     return;
  }
  ///清空下载任务
  static clearDownLadTask(){
    print('------------------清空下载任务');
    if(AppPrefs.getDownLoadKeyList()!=null){
      print('------------------清空下载任务2');
      AppPrefs.getDownLoadKeyList().forEach((element) {
        print('------------------清空下载任务3');
          _instance.setString(element, null);
      });
    }
    print('------------------清空下载任务4');
    _instance.setStringList(downLoadKeyList, null);
    return;
  }
  ///获取下载任务队列(url)
  static List<String> getDownLoadKeyList(){
    if(_instance.getStringList(downLoadKeyList)!=null){
      return _instance.getStringList(downLoadKeyList);
    }
    return null;
  }
  ///获取分段下载数据
  static getDwonLaodChunkData(String url){
    String data = _instance.getString(url);
    if(data==null){
      return null;
    }
    return data;
  }
  // 设置发布动态本地插入数据
  static setPublishFeedLocalInsertData(String key,String releaseString) {
    return _instance.setString(key, releaseString);
  }
  // 获取发布动态本地插入数据
  static String getPublishFeedLocalInsertData(String key) {
    String value = _instance.getString(key);
    if(value == null) {
      value = null;
    }
   return  value;
  }
}