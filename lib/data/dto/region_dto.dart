/// region_dto
/// Created by yangjiayi on 2020/12/23.


const String TABLE_NAME_REGION = "region";
const String COLUMN_NAME_REGION_ID = 'id';
const String COLUMN_NAME_REGION_LEVEL = 'level';
const String COLUMN_NAME_REGION_REGIONCODE = 'regionCode';
const String COLUMN_NAME_REGION_REGIONNAME = 'regionName';
const String COLUMN_NAME_REGION_PARENTID = 'parentId';
const String COLUMN_NAME_REGION_LONGITUDE = 'longitude';
const String COLUMN_NAME_REGION_LATITUDE = 'latitude';
const String COLUMN_NAME_REGION_PINYIN = 'pinYin';
const String COLUMN_NAME_REGION_PINYINFIRST = 'pinYinFirst';
const String COLUMN_NAME_REGION_REGIONFULLNAME = 'regionFullName';


class RegionDto {
  int id;
  int level;
  String regionCode;
  String regionName;
  int parentId;
  double longitude;
  double latitude;
  String pinYin;
  String pinYinFirst;
  String regionFullName;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      COLUMN_NAME_REGION_ID: id,
      COLUMN_NAME_REGION_LEVEL: level,
      COLUMN_NAME_REGION_REGIONCODE: regionCode,
      COLUMN_NAME_REGION_REGIONNAME: regionName,
      COLUMN_NAME_REGION_PARENTID: parentId,
      COLUMN_NAME_REGION_LONGITUDE: longitude,
      COLUMN_NAME_REGION_LATITUDE: latitude,
      COLUMN_NAME_REGION_PINYIN: pinYin,
      COLUMN_NAME_REGION_PINYINFIRST: pinYinFirst,
      COLUMN_NAME_REGION_REGIONFULLNAME: regionFullName,
    };
    return map;
  }

  RegionDto.fromMap(Map<String, dynamic> map) {
    id = map[COLUMN_NAME_REGION_ID];
    level = map[COLUMN_NAME_REGION_LEVEL];
    regionCode = map[COLUMN_NAME_REGION_REGIONCODE];
    regionName = map[COLUMN_NAME_REGION_REGIONNAME];
    parentId = map[COLUMN_NAME_REGION_PARENTID];
    longitude = map[COLUMN_NAME_REGION_LONGITUDE];
    latitude = map[COLUMN_NAME_REGION_LATITUDE];
    pinYin = map[COLUMN_NAME_REGION_PINYIN];
    pinYinFirst = map[COLUMN_NAME_REGION_PINYINFIRST];
    regionFullName = map[COLUMN_NAME_REGION_REGIONFULLNAME];
  }
}