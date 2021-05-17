//高德接口获取当前位置周边信息
import 'package:dio/dio.dart';
import 'package:mirror/api/location/location.api.dart';
import 'package:mirror/config/config.dart';
import 'package:mirror/data/model/peripheral_information_entity/peripheral_information_entify.dart';

//高德接口获取当前位置周边信息
Future<PeripheralInformationEntity> aroundForHttp(double longitude, double latitude , {int page = 1}) async {
  String BaseUrl = "https://restapi.amap.com/v3/place/around";
  Map<String, dynamic> map = Map();
  map["key"] = AppConfig.amapServerKey;
  map["location"] =
  "${longitude},${latitude}"; //中心点坐标 经度和纬度用","分割，经度在前，纬度在后，经纬度小数点后不得超过6位
  map["offset"] = 20; //每页记录数据
  map["page"] =  page; //每页记录数据
  map["extensions"] = "all";
  Response resp = await Http.getInstance()
      .dio
      .get(
    BaseUrl,
    queryParameters: map,
  )
      .catchError((e) {
    print(e);
  });
  if(resp!=null&&resp.data!=null) {
    PeripheralInformationEntity baseBean = PeripheralInformationEntity.fromJson(resp.data);
    return baseBean;
  }else{
    return null;
  }
}

//高德接口搜索
Future<PeripheralInformationEntity> searchForHttp(String keywords, String city, {int page = 1}) async {
  String BaseUrl = "https://restapi.amap.com/v3/place/text";
  Map<String, dynamic> map = Map();
  map["key"] = AppConfig.amapServerKey;
  map["keywords"] = keywords;
  map["city"] = city; //搜索的城市
  map["offset"] = 20; //每页记录数据
  map["page"] = page; //每页记录数据
  map["citylimit"] = true; //仅返回指定城市数据
  map["extensions"] = "all";
  Response resp = await Http.getInstance()
      .dio
      .get(
    BaseUrl,
    queryParameters: map,
  )
      .catchError((e) {
    print(e);
  });
  PeripheralInformationEntity baseBean = PeripheralInformationEntity.fromJson(resp.data);
  return baseBean;
}

// 逆地理编码
Future<PeripheralInformationEntity> reverseGeographyHttp(double longitude, double latitude) async {
  String BaseUrl = "https://restapi.amap.com/v3/geocode/regeo";
  Map<String, dynamic> map = Map();
  map["key"] = AppConfig.amapServerKey;
  map["location"] = "${longitude},${latitude}"; //中心点坐标 经度和纬度用","分割，经度在前，纬度在后，经纬度小数点后不得超过6位
  map["batch"] = false;
  Response resp = await Http.getInstance()
      .dio
      .get(
    BaseUrl,
    queryParameters: map,
  )
      .catchError((e) {
    print(e);
  });
  PeripheralInformationEntity baseBean = PeripheralInformationEntity.fromJson(resp.data);
  return baseBean;
}