import 'package:mirror/data/dto/conversation_dto.dart';
import 'package:mirror/data/dto/download_dto.dart';
import 'package:mirror/data/dto/download_video_dto.dart';
import 'package:mirror/data/dto/profile_dto.dart';
import 'package:mirror/data/dto/region_dto.dart';
import 'package:mirror/data/dto/search_history_dto.dart';
import 'package:mirror/data/dto/token_dto.dart';
import 'package:sqflite/sqflite.dart';

/// db_helper
/// Created by yangjiayi on 2020/11/3.

// 数据库名 暂时只会用到一个库
const String _DB_NAME = "if.db";
// 数据库版本 从1开始
const int _DB_VERSION = 1;

//TODO 需要考虑是否需要单例，每次操作都要开关DB是否必要
class DBHelper {
  static DBHelper _instance;
  Database _db;

  static DBHelper get instance {
    if (_instance == null) {
      _instance = DBHelper();
    }
    return _instance;
  }

  Database get db => _db;

  initDB() async {
    _db = await instance._openDB();
  }

  Future<Database> _openDB() async {
    return await openDatabase(_DB_NAME, version: _DB_VERSION,
        onUpgrade: (Database db, int oldVersion, int newVersion) async {
      print("数据库$_DB_NAME需要更新：${oldVersion}=>${newVersion}");
      await _updateDB(db, oldVersion, newVersion);
    }, onCreate: (Database db, int version) async {
      print("数据库$_DB_NAME需要创建：${version}");
      await _createDB(db, version);
    });
  }

  closeDB() {
    return _closeDB(_db);
  }
}

Future<void> _closeDB(Database db) async {
  return await db.close();
}

//TODO 创建数据库的方法需要根据需要写好
Future<void> _createDB(Database db, int version) async {
  //profile
  await db.execute("create table $TABLE_NAME_PROFILE (" +
      "$COLUMN_NAME_PROFILE_UID bigint(20) primary key," +
      "$COLUMN_NAME_PROFILE_PHONE varchar(16)," +
      "$COLUMN_NAME_PROFILE_TYPE tinyint(1)," +
      "$COLUMN_NAME_PROFILE_PASSWORD varchar(128)," +
      "$COLUMN_NAME_PROFILE_NICKNAME varchar(64)," +
      "$COLUMN_NAME_PROFILE_AVATARURI varchar(256)," +
      "$COLUMN_NAME_PROFILE_DESCRIPTION varchar(128)," +
      "$COLUMN_NAME_PROFILE_BIRTHDAY varchar(16)," +
      "$COLUMN_NAME_PROFILE_SEX tinyint(1)," +
      "$COLUMN_NAME_PROFILE_CONSTELLATION varchar(32)," +
      "$COLUMN_NAME_PROFILE_ADDRESS varchar(64)," +
      "$COLUMN_NAME_PROFILE_SOURCE varchar(2048)," +
      "$COLUMN_NAME_PROFILE_CREATETIME bigint(20)," +
      "$COLUMN_NAME_PROFILE_UPDATETIME bigint(20)," +
      "$COLUMN_NAME_PROFILE_DELETEDTIME bigint(20)," +
      "$COLUMN_NAME_PROFILE_STATUS tinyint(1)," +
      "$COLUMN_NAME_PROFILE_AGE smallint(1)," +
      "$COLUMN_NAME_PROFILE_ISVIP tinyint(1)," +
      "$COLUMN_NAME_PROFILE_SUBTYPE tinyint(1)," +
      "$COLUMN_NAME_PROFILE_CITYCODE varchar(16)," +
      "$COLUMN_NAME_PROFILE_LONGITUDE decimal(10,6)," +
      "$COLUMN_NAME_PROFILE_LATITUDE decimal(10,6)," +
      "$COLUMN_NAME_PROFILE_ISPERFECT tinyint(1)," +
      "$COLUMN_NAME_PROFILE_ISPHONE tinyint(1)," +
      "$COLUMN_NAME_PROFILE_RELATION tinyint(1)," +
      "$COLUMN_NAME_PROFILE_MUTUALFRIENDCOUNT int" +
      ")");
  //token
  await db.execute("create table $TABLE_NAME_TOKEN (" +
      "$COLUMN_NAME_TOKEN_ACCESSTOKEN varchar(1024) primary key," +
      "$COLUMN_NAME_TOKEN_TOKENTYPE varchar(32)," +
      "$COLUMN_NAME_TOKEN_REFRESHTOKEN varchar(1024)," +
      "$COLUMN_NAME_TOKEN_EXPIRESIN bigint(20)," +
      "$COLUMN_NAME_TOKEN_SCOPE varchar(256)," +
      "$COLUMN_NAME_TOKEN_ISPERFECT tinyint(1)," +
      "$COLUMN_NAME_TOKEN_UID bigint(20)," +
      "$COLUMN_NAME_TOKEN_ANONYMOUS tinyint(1)," +
      "$COLUMN_NAME_TOKEN_ISPHONE tinyint(1)," +
      "$COLUMN_NAME_TOKEN_JTI varchar(128)," +
      "$COLUMN_NAME_TOKEN_CREATETIME bigint(20)" +
      ")");
  //conversation
  await db.execute("create table $TABLE_NAME_CONVERSATION (" +
      "$COLUMN_NAME_CONVERSATION_ID varchar(64) primary key," +
      "$COLUMN_NAME_CONVERSATION_CONVERSATIONID varchar(32)," +
      "$COLUMN_NAME_CONVERSATION_UID bigint(20)," +
      "$COLUMN_NAME_CONVERSATION_TYPE tinyint(1)," +
      "$COLUMN_NAME_CONVERSATION_AVATARURI varchar(512)," +
      "$COLUMN_NAME_CONVERSATION_NAME varchar(128)," +
      "$COLUMN_NAME_CONVERSATION_CONTENT varchar(256)," +
      "$COLUMN_NAME_CONVERSATION_UPDATETIME bigint(20)," +
      "$COLUMN_NAME_CONVERSATION_CREATETIME bigint(20)," +
      "$COLUMN_NAME_CONVERSATION_ISTOP tinyint(1)," +
      "$COLUMN_NAME_CONVERSATION_UNREADCOUNT int," +
      "$COLUMN_NAME_CONVERSATION_SENDERUID bigint(20)" +
      ")");
  //region
  await db.execute("create table $TABLE_NAME_REGION (" +
      "$COLUMN_NAME_REGION_ID int primary key," +
      "$COLUMN_NAME_REGION_LEVEL tinyint(1)," +
      "$COLUMN_NAME_REGION_REGIONCODE varchar(16)," +
      "$COLUMN_NAME_REGION_REGIONNAME varchar(64)," +
      "$COLUMN_NAME_REGION_PARENTID int," +
      "$COLUMN_NAME_REGION_LONGITUDE decimal(10, 6)," +
      "$COLUMN_NAME_REGION_LATITUDE decimal(10, 6)," +
      "$COLUMN_NAME_REGION_PINYIN varchar(256)," +
      "$COLUMN_NAME_REGION_PINYINFIRST varchar(32)," +
      "$COLUMN_NAME_REGION_REGIONFULLNAME varchar(128)" +
      ")");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (1, 0, '0086', '中国', NULL, 116.368324, 39.915085, 'zhongguo', 'ZG', '中华人民共和国');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (2, 1, '010', '北京', 1, 116.407394, 39.904211, 'beijing', 'BJ', '北京市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (4, 1, '022', '天津', 1, 117.200983, 39.084158, 'tianjin', 'TJ', '天津市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (6, 1, '13', '河北', 1, 114.530235, 38.037433, 'hebei', 'HB', '河北省');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (7, 2, '0311', '石家庄', 6, 114.514793, 38.042228, 'shijiazhuang', 'SJZ', '石家庄市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (8, 2, '0315', '唐山', 6, 118.180193, 39.630867, 'tangshan', 'TS', '唐山市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (9, 2, '0335', '秦皇岛', 6, 119.518197, 39.888701, 'qinhuangdao', 'QHD', '秦皇岛市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (10, 2, '0310', '邯郸', 6, 114.538959, 36.625594, 'handan', 'HD', '邯郸市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (11, 2, '0319', '邢台', 6, 114.504677, 37.070834, 'xingtai', 'XT', '邢台市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (12, 2, '0312', '保定', 6, 115.464589, 38.874434, 'baoding', 'BD', '保定市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (13, 2, '0313', '张家口', 6, 114.886252, 40.768493, 'zhangjiakou', 'ZJK', '张家口市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (14, 2, '0314', '承德', 6, 117.962749, 40.952942, 'chengde', 'CD', '承德市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (15, 2, '0317', '沧州', 6, 116.838834, 38.304477, 'cangzhou', 'CZ', '沧州市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (16, 2, '0316', '廊坊', 6, 116.683752, 39.538047, 'langfang', 'LF', '廊坊市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (17, 2, '0318', '衡水', 6, 115.670177, 37.738920, 'hengshui', 'HS', '衡水市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (18, 1, '14', '山西', 1, 112.562678, 37.873499, 'shanxi', 'SX', '山西省');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (19, 2, '0351', '太原', 18, 112.548879, 37.870590, 'taiyuan', 'TY', '太原市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (20, 2, '0352', '大同', 18, 113.300129, 40.076763, 'datong', 'DT', '大同市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (21, 2, '0353', '阳泉', 18, 113.580519, 37.856971, 'yangquan', 'YQ', '阳泉市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (22, 2, '0355', '长治', 18, 113.116404, 36.195409, 'zhangzhi', 'ZZ', '长治市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (23, 2, '0356', '晋城', 18, 112.851486, 35.490684, 'jincheng', 'JC', '晋城市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (24, 2, '0349', '朔州', 18, 112.432991, 39.331855, 'shuozhou', 'SZ', '朔州市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (25, 2, '0354', '晋中', 18, 112.752652, 37.687357, 'jinzhong', 'JZ', '晋中市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (26, 2, '0359', '运城', 18, 111.007460, 35.026516, 'yuncheng', 'YC', '运城市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (27, 2, '0350', '忻州', 18, 112.734174, 38.416663, 'xinzhou', 'XZ', '忻州市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (28, 2, '0357', '临汾', 18, 111.518975, 36.088005, 'linfen', 'LF', '临汾市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (29, 2, '0358', '吕梁', 18, 111.144699, 37.519126, 'lvliang', 'LL', '吕梁市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (30, 1, '15', '内蒙古', 1, 111.766290, 40.817390, 'neimenggu', 'NMG', '内蒙古自治区');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (31, 2, '0471', '呼和浩特', 30, 111.749995, 40.842356, 'huhehaote', 'HHHT', '呼和浩特市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (32, 2, '0472', '包头', 30, 109.953504, 40.621157, 'baotou', 'BT', '包头市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (33, 2, '0473', '乌海', 30, 106.794216, 39.655248, 'wuhai', 'WH', '乌海市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (34, 2, '0476', '赤峰', 30, 118.886940, 42.257843, 'chifeng', 'CF', '赤峰市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (35, 2, '0475', '通辽', 30, 122.243444, 43.652889, 'tongliao', 'TL', '通辽市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (36, 2, '0477', '鄂尔多斯', 30, 109.781327, 39.608266, 'eerduosi', 'EEDS', '鄂尔多斯市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (37, 2, '0470', '呼伦贝尔', 30, 119.765558, 49.211576, 'hulunbeier', 'HLBE', '呼伦贝尔市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (38, 2, '0478', '巴彦淖尔', 30, 107.387657, 40.743213, 'bayannaoer', 'BYNE', '巴彦淖尔市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (39, 2, '0474', '乌兰察布', 30, 113.132584, 40.994785, 'wulanchabu', 'WLCB', '乌兰察布市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (40, 2, '0482', '兴安', 30, 122.037657, 46.082462, 'xingan', 'XA', '兴安盟');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (41, 2, '0479', '锡林郭勒', 30, 116.048222, 43.933454, 'xilinguole', 'XLGL', '锡林郭勒盟');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (42, 2, '0483', '阿拉善', 30, 105.728957, 38.851921, 'alashan', 'ALS', '阿拉善盟');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (43, 1, '21', '辽宁', 1, 123.431382, 41.836175, 'liaoning', 'LN', '辽宁省');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (44, 2, '024', '沈阳', 43, 123.465035, 41.677284, 'shenyang', 'SY', '沈阳市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (45, 2, '0411', '大连', 43, 121.614848, 38.914086, 'dalian', 'DL', '大连市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (46, 2, '0412', '鞍山', 43, 122.994329, 41.108647, 'anshan', 'AS', '鞍山市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (47, 2, '0413', '抚顺', 43, 123.957208, 41.880872, 'fushun', 'FS', '抚顺市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (48, 2, '0414', '本溪', 43, 123.685142, 41.486981, 'benxi', 'BX', '本溪市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (49, 2, '0415', '丹东', 43, 124.354450, 40.000787, 'dandong', 'DD', '丹东市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (50, 2, '0416', '锦州', 43, 121.126846, 41.095685, 'jinzhou', 'JZ', '锦州市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (51, 2, '0417', '营口', 43, 122.219458, 40.625364, 'yingkou', 'YK', '营口市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (52, 2, '0418', '阜新', 43, 121.670273, 42.021602, 'fuxin', 'FX', '阜新市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (53, 2, '0419', '辽阳', 43, 123.236974, 41.267794, 'liaoyang', 'LY', '辽阳市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (54, 2, '0427', '盘锦', 43, 122.170584, 40.719847, 'panjin', 'PJ', '盘锦市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (55, 2, '0410', '铁岭', 43, 123.726035, 42.223828, 'tieling', 'TL', '铁岭市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (56, 2, '0421', '朝阳', 43, 120.450879, 41.573762, 'chaoyang', 'CY', '朝阳市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (57, 2, '0429', '葫芦岛', 43, 120.836939, 40.711040, 'huludao', 'HLD', '葫芦岛市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (58, 1, '22', '吉林', 1, 125.325680, 43.897016, 'jilin', 'JL', '吉林省');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (59, 2, '0431', '长春', 58, 125.323513, 43.817251, 'zhangchun', 'ZC', '长春市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (60, 2, '0432', '吉林', 58, 126.549572, 43.837883, 'jilin', 'JL', '吉林市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (61, 2, '0434', '四平', 58, 124.350398, 43.166419, 'siping', 'SP', '四平市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (62, 2, '0437', '辽源', 58, 125.143660, 42.887766, 'liaoyuan', 'LY', '辽源市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (63, 2, '0435', '通化', 58, 125.939697, 41.728401, 'tonghua', 'TH', '通化市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (64, 2, '0439', '白山', 58, 126.414730, 41.943972, 'baishan', 'BS', '白山市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (65, 2, '0438', '松原', 58, 124.825042, 45.141548, 'songyuan', 'SY', '松原市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (66, 2, '0436', '白城', 58, 122.838714, 45.619884, 'baicheng', 'BC', '白城市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (67, 2, '1433', '延边', 58, 129.471868, 42.909408, 'yanbianchaoxianzu', 'YBCXZ', '延边朝鲜族自治州');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (68, 1, '23', '黑龙江', 1, 126.661665, 45.742366, 'heilongjiang', 'HLJ', '黑龙江省');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (69, 2, '0451', '哈尔滨', 68, 126.534967, 45.803775, 'haerbin', 'HEB', '哈尔滨市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (70, 2, '0452', '齐齐哈尔', 68, 123.918186, 47.354348, 'qiqihaer', 'QQHE', '齐齐哈尔市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (71, 2, '0467', '鸡西', 68, 130.969333, 45.295075, 'jixi', 'JX', '鸡西市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (72, 2, '0468', '鹤岗', 68, 130.297943, 47.350189, 'hegang', 'HG', '鹤岗市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (73, 2, '0469', '双鸭山', 68, 131.141195, 46.676418, 'shuangyashan', 'SYS', '双鸭山市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (74, 2, '0459', '大庆', 68, 125.103784, 46.589309, 'daqing', 'DQ', '大庆市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (75, 2, '0458', '伊春', 68, 128.841125, 47.727535, 'yichun', 'YC', '伊春市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (76, 2, '0454', '佳木斯', 68, 130.318878, 46.799777, 'jiamusi', 'JMS', '佳木斯市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (77, 2, '0464', '七台河', 68, 131.003082, 45.771396, 'qitaihe', 'QTH', '七台河市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (78, 2, '0453', '牡丹江', 68, 129.633168, 44.551653, 'mudanjiang', 'MDJ', '牡丹江市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (79, 2, '0456', '黑河', 68, 127.528293, 50.245129, 'heihe', 'HH', '黑河市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (80, 2, '0455', '绥化', 68, 126.968887, 46.653845, 'suihua', 'SH', '绥化市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (81, 2, '0457', '大兴安岭', 68, 124.711526, 52.335262, 'daxinganling', 'DXAL', '大兴安岭地区');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (82, 1, '021', '上海', 1, 121.473662, 31.230372, 'shanghai', 'SH', '上海市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (84, 1, '32', '江苏', 1, 118.762765, 32.060875, 'jiangsu', 'JS', '江苏省');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (85, 2, '025', '南京', 84, 118.796682, 32.059570, 'nanjing', 'NJ', '南京市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (86, 2, '0510', '无锡', 84, 120.311910, 31.491169, 'wuxi', 'WX', '无锡市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (87, 2, '0516', '徐州', 84, 117.284124, 34.205768, 'xuzhou', 'XZ', '徐州市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (88, 2, '0519', '常州', 84, 119.974061, 31.811226, 'changzhou', 'CZ', '常州市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (89, 2, '0512', '苏州', 84, 120.585728, 31.297400, 'suzhou', 'SZ', '苏州市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (90, 2, '0513', '南通', 84, 120.894676, 31.981143, 'nantong', 'NT', '南通市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (91, 2, '0518', '连云港', 84, 119.221611, 34.596653, 'lianyungang', 'LYG', '连云港市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (92, 2, '0517', '淮安', 84, 119.113185, 33.551052, 'huaian', 'HA', '淮安市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (93, 2, '0515', '盐城', 84, 120.163107, 33.347708, 'yancheng', 'YC', '盐城市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (94, 2, '0514', '扬州', 84, 119.412939, 32.394209, 'yangzhou', 'YZ', '扬州市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (95, 2, '0511', '镇江', 84, 119.425836, 32.187849, 'zhenjiang', 'ZJ', '镇江市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (96, 2, '0523', '泰州', 84, 119.922933, 32.455536, 'taizhou', 'TZ', '泰州市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (97, 2, '0527', '宿迁', 84, 118.275198, 33.963232, 'suqian', 'SQ', '宿迁市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (98, 1, '33', '浙江', 1, 120.152585, 30.266597, 'zhejiang', 'ZJ', '浙江省');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (99, 2, '0571', '杭州', 98, 120.209789, 30.246920, 'hangzhou', 'HZ', '杭州市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (100, 2, '0574', '宁波', 98, 121.622485, 29.859971, 'ningbo', 'NB', '宁波市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (101, 2, '0577', '温州', 98, 120.699361, 27.993828, 'wenzhou', 'WZ', '温州市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (102, 2, '0573', '嘉兴', 98, 120.755470, 30.746191, 'jiaxing', 'JX', '嘉兴市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (103, 2, '0572', '湖州', 98, 120.086809, 30.894410, 'huzhou', 'HZ', '湖州市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (104, 2, '0575', '绍兴', 98, 120.580364, 30.030192, 'shaoxing', 'SX', '绍兴市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (105, 2, '0579', '金华', 98, 119.647229, 29.079208, 'jinhua', 'JH', '金华市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (106, 2, '0570', '衢州', 98, 118.859457, 28.970079, 'quzhou', 'QZ', '衢州市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (107, 2, '0580', '舟山', 98, 122.207106, 29.985553, 'zhoushan', 'ZS', '舟山市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (108, 2, '0576', '台州', 98, 121.420760, 28.656380, 'taizhou', 'TZ', '台州市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (109, 2, '0578', '丽水', 98, 119.922796, 28.467630, 'lishui', 'LS', '丽水市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (110, 1, '34', '安徽', 1, 117.329949, 31.733806, 'anhui', 'AH', '安徽省');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (111, 2, '0551', '合肥', 110, 117.227219, 31.820591, 'hefei', 'HF', '合肥市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (112, 2, '0553', '芜湖', 110, 118.432941, 31.352859, 'wuhu', 'WH', '芜湖市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (113, 2, '0552', '蚌埠', 110, 117.388512, 32.916630, 'bangbu', 'BB', '蚌埠市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (114, 2, '0554', '淮南', 110, 117.018399, 32.587117, 'huainan', 'HN', '淮南市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (115, 2, '0555', '马鞍山', 110, 118.507011, 31.670440, 'maanshan', 'MAS', '马鞍山市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (116, 2, '0561', '淮北', 110, 116.798265, 33.955844, 'huaibei', 'HB', '淮北市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (117, 2, '0562', '铜陵', 110, 117.811540, 30.945515, 'tongling', 'TL', '铜陵市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (118, 2, '0556', '安庆', 110, 117.115101, 30.531919, 'anqing', 'AQ', '安庆市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (119, 2, '0559', '黄山', 110, 118.338272, 29.715185, 'huangshan', 'HS', '黄山市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (120, 2, '0550', '滁州', 110, 118.327944, 32.255636, 'chuzhou', 'CZ', '滁州市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (121, 2, '1558', '阜阳', 110, 115.814504, 32.890479, 'fuyang', 'FY', '阜阳市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (122, 2, '0557', '宿州', 110, 116.964195, 33.647309, 'suzhou', 'SZ', '宿州市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (123, 2, '0564', '六安', 110, 116.520139, 31.735456, 'liuan', 'LA', '六安市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (124, 2, '0558', '亳州', 110, 115.778670, 33.844592, 'bozhou', 'BZ', '亳州市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (125, 2, '0566', '池州', 110, 117.491592, 30.664779, 'chizhou', 'CZ', '池州市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (126, 2, '0563', '宣城', 110, 118.758680, 30.940195, 'xuancheng', 'XC', '宣城市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (127, 1, '35', '福建', 1, 119.295143, 26.100779, 'fujian', 'FJ', '福建省');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (128, 2, '0591', '福州', 127, 119.296389, 26.074268, 'fuzhou', 'FZ', '福州市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (129, 2, '0592', '厦门', 127, 118.089204, 24.479664, 'shamen', 'SM', '厦门市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (130, 2, '0594', '莆田', 127, 119.007777, 25.454084, 'putian', 'PT', '莆田市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (131, 2, '0598', '三明', 127, 117.638678, 26.263406, 'sanming', 'SM', '三明市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (132, 2, '0595', '泉州', 127, 118.675676, 24.874132, 'quanzhou', 'QZ', '泉州市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (133, 2, '0596', '漳州', 127, 117.647093, 24.513025, 'zhangzhou', 'ZZ', '漳州市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (134, 2, '0599', '南平', 127, 118.177710, 26.641774, 'nanping', 'NP', '南平市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (135, 2, '0597', '龙岩', 127, 117.017295, 25.075119, 'longyan', 'LY', '龙岩市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (136, 2, '0593', '宁德', 127, 119.547932, 26.665617, 'ningde', 'ND', '宁德市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (137, 1, '36', '江西', 1, 115.816350, 28.636660, 'jiangxi', 'JX', '江西省');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (138, 2, '0791', '南昌', 137, 115.858198, 28.682892, 'nanchang', 'NC', '南昌市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (139, 2, '0798', '景德镇', 137, 117.178222, 29.268945, 'jingdezhen', 'JDZ', '景德镇市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (140, 2, '0799', '萍乡', 137, 113.887083, 27.658373, 'pingxiang', 'PX', '萍乡市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (141, 2, '0792', '九江', 137, 115.952914, 29.662117, 'jiujiang', 'JJ', '九江市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (142, 2, '0790', '新余', 137, 114.917346, 27.817808, 'xinyu', 'XY', '新余市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (143, 2, '0701', '鹰潭', 137, 117.042173, 28.272537, 'yingtan', 'YT', '鹰潭市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (144, 2, '0797', '赣州', 137, 114.933546, 25.830694, 'ganzhou', 'GZ', '赣州市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (145, 2, '0796', '吉安', 137, 114.966567, 27.090763, 'jian', 'JA', '吉安市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (146, 2, '0795', '宜春', 137, 114.416785, 27.815743, 'yichun', 'YC', '宜春市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (147, 2, '0794', '抚州', 137, 116.358181, 27.949217, 'fuzhou', 'FZ', '抚州市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (148, 2, '0793', '上饶', 137, 117.943433, 28.454863, 'shangrao', 'SR', '上饶市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (149, 1, '37', '山东', 1, 117.019915, 36.671156, 'shandong', 'SD', '山东省');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (150, 2, '0531', '济南', 149, 117.120098, 36.651200, 'jinan', 'JN', '济南市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (151, 2, '0532', '青岛', 149, 120.382621, 36.067131, 'qingdao', 'QD', '青岛市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (152, 2, '0533', '淄博', 149, 118.055019, 36.813546, 'zibo', 'ZB', '淄博市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (153, 2, '0632', '枣庄', 149, 117.323725, 34.810488, 'zaozhuang', 'ZZ', '枣庄市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (154, 2, '0546', '东营', 149, 118.674614, 37.433963, 'dongying', 'DY', '东营市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (155, 2, '0535', '烟台', 149, 121.447852, 37.464539, 'yantai', 'YT', '烟台市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (156, 2, '0536', '潍坊', 149, 119.161748, 36.706962, 'weifang', 'WF', '潍坊市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (157, 2, '0537', '济宁', 149, 116.587282, 35.414982, 'jining', 'JN', '济宁市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (158, 2, '0538', '泰安', 149, 117.087614, 36.200252, 'taian', 'TA', '泰安市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (159, 2, '0631', '威海', 149, 122.120282, 37.513412, 'weihai', 'WH', '威海市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (160, 2, '0633', '日照', 149, 119.526925, 35.416734, 'rizhao', 'RZ', '日照市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (161, 2, '0634', '莱芜', 149, 117.676723, 36.213813, 'laiwu', 'LW', '莱芜市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (162, 2, '0539', '临沂', 149, 118.356414, 35.104673, 'linyi', 'LY', '临沂市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (163, 2, '0534', '德州', 149, 116.359381, 37.436657, 'dezhou', 'DZ', '德州市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (164, 2, '0635', '聊城', 149, 115.985389, 36.456684, 'liaocheng', 'LC', '聊城市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (165, 2, '0543', '滨州', 149, 117.970699, 37.381980, 'binzhou', 'BZ', '滨州市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (166, 2, '0530', '菏泽', 149, 115.480656, 35.233750, 'heze', 'HZ', '菏泽市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (167, 1, '41', '河南', 1, 113.753394, 34.765869, 'henan', 'HN', '河南省');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (168, 2, '0371', '郑州', 167, 113.625328, 34.746611, 'zhengzhou', 'ZZ', '郑州市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (169, 2, '0378', '开封', 167, 114.307677, 34.797966, 'kaifeng', 'KF', '开封市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (170, 2, '0379', '洛阳', 167, 112.453926, 34.620202, 'luoyang', 'LY', '洛阳市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (171, 2, '0375', '平顶山', 167, 113.192661, 33.766169, 'pingdingshan', 'PDS', '平顶山市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (172, 2, '0372', '安阳', 167, 114.392392, 36.097577, 'anyang', 'AY', '安阳市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (173, 2, '0392', '鹤壁', 167, 114.297309, 35.748325, 'hebi', 'HB', '鹤壁市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (174, 2, '0373', '新乡', 167, 113.926763, 35.303704, 'xinxiang', 'XX', '新乡市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (175, 2, '0391', '焦作', 167, 113.241823, 35.215893, 'jiaozuo', 'JZ', '焦作市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (176, 2, '0393', '濮阳', 167, 115.029216, 35.761829, 'puyang', 'PY', '濮阳市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (177, 2, '0374', '许昌', 167, 113.852454, 34.035771, 'xuchang', 'XC', '许昌市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (178, 2, '0395', '漯河', 167, 114.016536, 33.580873, 'luohe', 'LH', '漯河市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (179, 2, '0398', '三门峡', 167, 111.200367, 34.772792, 'sanmenxia', 'SMX', '三门峡市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (180, 2, '0377', '南阳', 167, 112.528308, 32.990664, 'nanyang', 'NY', '南阳市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (181, 2, '0370', '商丘', 167, 115.656339, 34.414961, 'shangqiu', 'SQ', '商丘市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (182, 2, '0376', '信阳', 167, 114.091193, 32.147679, 'xinyang', 'XY', '信阳市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (183, 2, '0394', '周口', 167, 114.696950, 33.626149, 'zhoukou', 'ZK', '周口市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (184, 2, '0396', '驻马店', 167, 114.022247, 33.012885, 'zhumadian', 'ZMD', '驻马店市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (185, 2, '1391', '济源', 167, 112.602256, 35.067199, 'jiyuan', 'JY', '济源市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (186, 1, '42', '湖北', 1, 114.341745, 30.546557, 'hubei', 'HB', '湖北省');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (187, 2, '027', '武汉', 186, 114.305469, 30.593175, 'wuhan', 'WH', '武汉市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (188, 2, '0714', '黄石', 186, 115.038962, 30.201038, 'huangshi', 'HS', '黄石市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (189, 2, '0719', '十堰', 186, 110.799291, 32.629462, 'shiyan', 'SY', '十堰市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (190, 2, '0717', '宜昌', 186, 111.286445, 30.691865, 'yichang', 'YC', '宜昌市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (191, 2, '0710', '襄阳', 186, 112.122426, 32.009016, 'xiangyang', 'XY', '襄阳市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (192, 2, '0711', '鄂州', 186, 114.894935, 30.391141, 'ezhou', 'EZ', '鄂州市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (193, 2, '0724', '荆门', 186, 112.199427, 31.035395, 'jingmen', 'JM', '荆门市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (194, 2, '0712', '孝感', 186, 113.957037, 30.917766, 'xiaogan', 'XG', '孝感市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (195, 2, '0716', '荆州', 186, 112.239746, 30.335184, 'jingzhou', 'JZ', '荆州市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (196, 2, '0713', '黄冈', 186, 114.872199, 30.453667, 'huanggang', 'HG', '黄冈市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (197, 2, '0715', '咸宁', 186, 114.322616, 29.841362, 'xianning', 'XN', '咸宁市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (198, 2, '0722', '随州', 186, 113.382515, 31.690191, 'suizhou', 'SZ', '随州市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (199, 2, '0718', '恩施', 186, 109.488172, 30.272156, 'enshi', 'ES', '恩施土家族苗族自治州');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (200, 2, '2728', '潜江', 186, 112.899762, 30.402167, 'qianjiang', 'QJ', '潜江市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (201, 2, '1719', '神农架', 186, 110.675743, 31.744915, 'shennongjia', 'SNJ', '神农架林区');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (202, 2, '1728', '天门', 186, 113.166078, 30.663337, 'tianmen', 'TM', '天门市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (203, 2, '0728', '仙桃', 186, 113.423583, 30.361438, 'xiantao', 'XT', '仙桃市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (204, 1, '43', '湖南', 1, 112.983600, 28.112743, 'hunan', 'HN', '湖南省');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (205, 2, '0731', '长沙', 204, 112.938884, 28.228080, 'zhangsha', 'ZS', '长沙市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (206, 2, '0733', '株洲', 204, 113.133853, 27.827986, 'zhuzhou', 'ZZ', '株洲市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (207, 2, '0732', '湘潭', 204, 112.944026, 27.829795, 'xiangtan', 'XT', '湘潭市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (208, 2, '0734', '衡阳', 204, 112.572018, 26.893368, 'hengyang', 'HY', '衡阳市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (209, 2, '0739', '邵阳', 204, 111.467674, 27.238950, 'shaoyang', 'SY', '邵阳市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (210, 2, '0730', '岳阳', 204, 113.128730, 29.356803, 'yueyang', 'YY', '岳阳市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (211, 2, '0736', '常德', 204, 111.698784, 29.031654, 'changde', 'CD', '常德市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (212, 2, '0744', '张家界', 204, 110.479148, 29.117013, 'zhangjiajie', 'ZJJ', '张家界市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (213, 2, '0737', '益阳', 204, 112.355129, 28.554349, 'yiyang', 'YY', '益阳市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (214, 2, '0735', '郴州', 204, 113.014984, 25.770532, 'chenzhou', 'CZ', '郴州市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (215, 2, '0746', '永州', 204, 111.613418, 26.419641, 'yongzhou', 'YZ', '永州市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (216, 2, '0745', '怀化', 204, 110.001923, 27.569517, 'huaihua', 'HH', '怀化市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (217, 2, '0738', '娄底', 204, 111.994482, 27.700270, 'loudi', 'LD', '娄底市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (218, 2, '0743', '湘西', 204, 109.738906, 28.311950, 'xiangxi', 'XX', '湘西土家族苗族自治州');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (219, 1, '44', '广东', 1, 113.266410, 23.132324, 'guangdong', 'GD', '广东省');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (220, 2, '020', '广州', 219, 113.264385, 23.129110, 'guangzhou', 'GZ', '广州市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (221, 2, '0751', '韶关', 219, 113.597620, 24.810879, 'shaoguan', 'SG', '韶关市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (222, 2, '0755', '深圳', 219, 114.057939, 22.543527, 'shenzhen', 'SZ', '深圳市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (223, 2, '0756', '珠海', 219, 113.576677, 22.270978, 'zhuhai', 'ZH', '珠海市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (224, 2, '0754', '汕头', 219, 116.681972, 23.354091, 'shantou', 'ST', '汕头市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (225, 2, '0757', '佛山', 219, 113.121435, 23.021478, 'foshan', 'FS', '佛山市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (226, 2, '0750', '江门', 219, 113.081542, 22.578990, 'jiangmen', 'JM', '江门市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (227, 2, '0759', '湛江', 219, 110.356639, 21.270145, 'zhanjiang', 'ZJ', '湛江市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (228, 2, '0668', '茂名', 219, 110.925439, 21.662991, 'maoming', 'MM', '茂名市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (229, 2, '0758', '肇庆', 219, 112.465091, 23.047191, 'zhaoqing', 'ZQ', '肇庆市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (230, 2, '0752', '惠州', 219, 114.415612, 23.112381, 'huizhou', 'HZ', '惠州市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (231, 2, '0753', '梅州', 219, 116.122523, 24.288578, 'meizhou', 'MZ', '梅州市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (232, 2, '0660', '汕尾', 219, 115.375431, 22.787050, 'shanwei', 'SW', '汕尾市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (233, 2, '0762', '河源', 219, 114.700961, 23.743686, 'heyuan', 'HY', '河源市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (234, 2, '0662', '阳江', 219, 111.982589, 21.857887, 'yangjiang', 'YJ', '阳江市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (235, 2, '0763', '清远', 219, 113.056042, 23.681774, 'qingyuan', 'QY', '清远市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (236, 2, '0769', '东莞', 219, 113.751799, 23.020673, 'dongguan', 'DG', '东莞市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (237, 2, '0760', '中山', 219, 113.392770, 22.517585, 'zhongshan', 'ZS', '中山市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (238, 2, '0768', '潮州', 219, 116.622444, 23.657262, 'chaozhou', 'CZ', '潮州市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (239, 2, '0663', '揭阳', 219, 116.372708, 23.549701, 'jieyang', 'JY', '揭阳市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (240, 2, '0766', '云浮', 219, 112.044491, 22.915094, 'yunfu', 'YF', '云浮市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (242, 1, '45', '广西', 1, 108.327546, 22.815478, 'guangxi', 'GX', '广西壮族自治区');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (243, 2, '0771', '南宁', 242, 108.366543, 22.817002, 'nanning', 'NN', '南宁市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (244, 2, '0772', '柳州', 242, 109.428608, 24.326291, 'liuzhou', 'LZ', '柳州市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (245, 2, '0773', '桂林', 242, 110.179953, 25.234479, 'guilin', 'GL', '桂林市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (246, 2, '0774', '梧州', 242, 111.279115, 23.476962, 'wuzhou', 'WZ', '梧州市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (247, 2, '0779', '北海', 242, 109.120161, 21.481291, 'beihai', 'BH', '北海市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (248, 2, '0770', '防城港', 242, 108.353846, 21.686860, 'fangchenggang', 'FCG', '防城港市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (249, 2, '0777', '钦州', 242, 108.654146, 21.979933, 'qinzhou', 'QZ', '钦州市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (250, 2, '1755', '贵港', 242, 109.598926, 23.111530, 'guigang', 'GG', '贵港市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (251, 2, '0775', '玉林', 242, 110.181220, 22.654032, 'yulin', 'YL', '玉林市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (252, 2, '0776', '百色', 242, 106.618202, 23.902330, 'baise', 'BS', '百色市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (253, 2, '1774', '贺州', 242, 111.566871, 24.403528, 'hezhou', 'HZ', '贺州市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (254, 2, '0778', '河池', 242, 108.085261, 24.692931, 'hechi', 'HC', '河池市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (255, 2, '1772', '来宾', 242, 109.221465, 23.750306, 'laibin', 'LB', '来宾市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (256, 2, '1771', '崇左', 242, 107.365094, 22.377253, 'chongzuo', 'CZ', '崇左市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (257, 1, '46', '海南', 1, 110.349228, 20.017377, 'hainan', 'HN', '海南省');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (258, 2, '0802', '白沙', 257, 109.451484, 19.224823, 'baisha', 'BS', '白沙黎族自治县');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (259, 2, '0801', '保亭', 257, 109.702590, 18.639130, 'baoting', 'BT', '保亭黎族苗族自治县');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (260, 2, '0803', '昌江', 257, 109.055739, 19.298184, 'changjiang', 'CJ', '昌江黎族自治县');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (261, 2, '0804', '澄迈', 257, 110.006754, 19.738521, 'chengmai', 'CM', '澄迈县');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (262, 2, '0898', '海口', 257, 110.198286, 20.044412, 'haikou', 'HK', '海口市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (263, 2, '0899', '三亚', 257, 109.511772, 18.253135, 'sanya', 'SY', '三亚市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (264, 2, '2898', '三沙', 257, 112.338695, 16.831839, 'sansha', 'SS', '三沙市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (265, 2, '0805', '儋州', 257, 109.580811, 19.521134, 'danzhou', 'DZ', '儋州市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (266, 2, '0806', '定安', 257, 110.359339, 19.681404, 'dingan', 'DA', '定安县');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (267, 2, '0807', '东方', 257, 108.651815, 19.095351, 'dongfang', 'DF', '东方市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (268, 2, '2802', '乐东', 257, 109.173054, 18.750259, 'ledong', 'LD', '乐东黎族自治县');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (269, 2, '1896', '临高', 257, 109.690508, 19.912025, 'lingao', 'LG', '临高县');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (270, 2, '0809', '陵水', 257, 110.037503, 18.506048, 'lingshui', 'LS', '陵水黎族自治县');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (271, 2, '1894', '琼海', 257, 110.474497, 19.259134, 'qionghai', 'QH', '琼海市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (272, 2, '1899', '琼中', 257, 109.838389, 19.033369, 'qiongzhong', 'QZ', '琼中黎族苗族自治县');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (273, 2, '1892', '屯昌', 257, 110.103415, 19.351765, 'tunchang', 'TC', '屯昌县');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (274, 2, '1898', '万宁', 257, 110.391073, 18.795143, 'wanning', 'WN', '万宁市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (275, 2, '1893', '文昌', 257, 110.797717, 19.543422, 'wenchang', 'WC', '文昌市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (276, 2, '1897', '五指山', 257, 109.516925, 18.775146, 'wuzhishan', 'WZS', '五指山市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (277, 1, '023', '重庆', 1, 106.551643, 29.562849, 'chongqing', 'CQ', '重庆市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (280, 1, '51', '四川', 1, 104.075809, 30.651239, 'sichuan', 'SC', '四川省');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (281, 2, '028', '成都', 280, 104.066794, 30.572893, 'chengdou', 'CD', '成都市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (282, 2, '0813', '自贡', 280, 104.778442, 29.339030, 'zigong', 'ZG', '自贡市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (283, 2, '0812', '攀枝花', 280, 101.718637, 26.582347, 'panzhihua', 'PZH', '攀枝花市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (284, 2, '0830', '泸州', 280, 105.442285, 28.871805, 'luzhou', 'LZ', '泸州市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (285, 2, '0838', '德阳', 280, 104.397894, 31.126855, 'deyang', 'DY', '德阳市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (286, 2, '0816', '绵阳', 280, 104.679004, 31.467459, 'mianyang', 'MY', '绵阳市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (287, 2, '0839', '广元', 280, 105.843357, 32.435435, 'guangyuan', 'GY', '广元市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (288, 2, '0825', '遂宁', 280, 105.592803, 30.532920, 'suining', 'SN', '遂宁市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (289, 2, '1832', '内江', 280, 105.058432, 29.580228, 'neijiang', 'NJ', '内江市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (290, 2, '0833', '乐山', 280, 103.765678, 29.552115, 'leshan', 'LS', '乐山市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (291, 2, '0817', '南充', 280, 106.110698, 30.837793, 'nanchong', 'NC', '南充市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (292, 2, '1833', '眉山', 280, 103.848403, 30.076994, 'meishan', 'MS', '眉山市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (293, 2, '0831', '宜宾', 280, 104.642845, 28.752134, 'yibin', 'YB', '宜宾市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (294, 2, '0826', '广安', 280, 106.633088, 30.456224, 'guangan', 'GA', '广安市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (295, 2, '0818', '达州', 280, 107.467758, 31.209121, 'dazhou', 'DZ', '达州市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (296, 2, '0835', '雅安', 280, 103.042375, 30.010602, 'yaan', 'YA', '雅安市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (297, 2, '0827', '巴中', 280, 106.747477, 31.867903, 'bazhong', 'BZ', '巴中市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (298, 2, '0832', '资阳', 280, 104.627636, 30.128901, 'ziyang', 'ZY', '资阳市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (299, 2, '0837', '阿坝', 280, 102.224653, 31.899413, 'aba', 'AB', '阿坝藏族羌族自治州');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (300, 2, '0836', '甘孜', 280, 101.962310, 30.049520, 'ganzi', 'GZ', '甘孜藏族自治州');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (301, 2, '0834', '凉山', 280, 102.267712, 27.881570, 'liangshan', 'LS', '凉山彝族自治州');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (302, 1, '52', '贵州', 1, 106.705460, 26.600055, 'guizhou', 'GZ', '贵州省');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (303, 2, '0851', '贵阳', 302, 106.630153, 26.647661, 'guiyang', 'GY', '贵阳市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (304, 2, '0858', '六盘水', 302, 104.830458, 26.592707, 'liupanshui', 'LPS', '六盘水市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (305, 2, '0852', '遵义', 302, 106.927389, 27.725654, 'zunyi', 'ZY', '遵义市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (306, 2, '0853', '安顺', 302, 105.947594, 26.253088, 'anshun', 'AS', '安顺市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (307, 2, '0857', '毕节', 302, 105.291702, 27.283908, 'bijie', 'BJ', '毕节市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (308, 2, '0856', '铜仁', 302, 109.189598, 27.731514, 'tongren', 'TR', '铜仁市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (309, 2, '0859', '黔西南', 302, 104.906397, 25.087856, 'qianxinan', 'QXN', '黔西南布依族苗族自治州');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (310, 2, '0855', '黔东南', 302, 107.982874, 26.583457, 'qiandongnan', 'QDN', '黔东南苗族侗族自治州');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (311, 2, '0854', '黔南', 302, 107.522171, 26.253275, 'qiannan', 'QN', '黔南布依族苗族自治州');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (312, 1, '53', '云南', 1, 102.710002, 25.045806, 'yunnan', 'YN', '云南省');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (313, 2, '0871', '昆明', 312, 102.832891, 24.880095, 'kunming', 'KM', '昆明市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (314, 2, '0874', '曲靖', 312, 103.796167, 25.489999, 'qujing', 'QJ', '曲靖市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (315, 2, '0877', '玉溪', 312, 102.527197, 24.347324, 'yuxi', 'YX', '玉溪市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (316, 2, '0875', '保山', 312, 99.161761, 25.112046, 'baoshan', 'BS', '保山市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (317, 2, '0870', '昭通', 312, 103.717465, 27.338257, 'zhaotong', 'ZT', '昭通市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (318, 2, '0888', '丽江', 312, 100.227750, 26.855047, 'lijiang', 'LJ', '丽江市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (319, 2, '0879', '普洱', 312, 100.966156, 22.825155, 'puer', 'PE', '普洱市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (320, 2, '0883', '临沧', 312, 100.088790, 23.883955, 'lincang', 'LC', '临沧市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (321, 2, '0878', '楚雄', 312, 101.527992, 25.045513, 'chuxiong', 'CX', '楚雄彝族自治州');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (322, 2, '0873', '红河', 312, 103.374893, 23.363245, 'honghe', 'HH', '红河哈尼族彝族自治州');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (323, 2, '0876', '文山', 312, 104.216248, 23.400733, 'wenshan', 'WS', '文山壮族苗族自治州');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (324, 2, '0691', '西双版纳', 312, 100.796984, 22.009113, 'xishuangbanna', 'XSBN', '西双版纳傣族自治州');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (325, 2, '0872', '大理', 312, 100.267638, 25.606486, 'dali', 'DL', '大理白族自治州');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (326, 2, '0692', '德宏', 312, 98.584895, 24.433353, 'dehong', 'DH', '德宏傣族景颇族自治州');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (327, 2, '0886', '怒江', 312, 98.856600, 25.817555, 'nujiang', 'NJ', '怒江傈僳族自治州');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (328, 2, '0887', '迪庆', 312, 99.702583, 27.818807, 'diqing', 'DQ', '迪庆藏族自治州');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (329, 1, '54', '西藏', 1, 91.117525, 29.647535, 'xizang', 'XZ', '西藏自治区');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (330, 2, '0891', '拉萨', 329, 91.172148, 29.652341, 'lasa', 'LS', '拉萨市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (331, 2, '0892', '日喀则', 329, 88.880583, 29.266869, 'rikaze', 'RKZ', '日喀则市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (332, 2, '0895', '昌都', 329, 97.172020, 31.140969, 'changdou', 'CD', '昌都市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (333, 2, '0894', '林芝', 329, 94.361490, 29.649128, 'linzhi', 'LZ', '林芝市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (334, 2, '0893', '山南', 329, 91.773134, 29.237137, 'shannan', 'SN', '山南市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (335, 2, '0896', '那曲', 329, 92.052064, 31.476479, 'neiqu', 'NQ', '那曲地区');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (336, 2, '0897', '阿里', 329, 80.105804, 32.501111, 'ali', 'AL', '阿里地区');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (337, 1, '61', '陕西', 1, 108.954347, 34.265502, 'shanxi', 'SX', '陕西省');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (338, 2, '029', '西安', 337, 108.939770, 34.341574, 'xian', 'XA', '西安市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (339, 2, '0919', '铜川', 337, 108.945019, 34.897887, 'tongchuan', 'TC', '铜川市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (340, 2, '0917', '宝鸡', 337, 107.237743, 34.363184, 'baoji', 'BJ', '宝鸡市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (341, 2, '0910', '咸阳', 337, 108.709136, 34.329870, 'xianyang', 'XY', '咸阳市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (342, 2, '0913', '渭南', 337, 109.471094, 34.520440, 'weinan', 'WN', '渭南市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (343, 2, '0911', '延安', 337, 109.494112, 36.651381, 'yanan', 'YA', '延安市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (344, 2, '0916', '汉中', 337, 107.023050, 33.067225, 'hanzhong', 'HZ', '汉中市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (345, 2, '0912', '榆林', 337, 109.734474, 38.285369, 'yulin', 'YL', '榆林市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (346, 2, '0915', '安康', 337, 109.029113, 32.684810, 'ankang', 'AK', '安康市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (347, 2, '0914', '商洛', 337, 109.918570, 33.872726, 'shangluo', 'SL', '商洛市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (348, 1, '62', '甘肃', 1, 103.826447, 36.059560, 'gansu', 'GS', '甘肃省');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (349, 2, '0931', '兰州', 348, 103.834303, 36.061089, 'lanzhou', 'LZ', '兰州市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (350, 2, '1937', '嘉峪关', 348, 98.289419, 39.772554, 'jiayuguan', 'JYG', '嘉峪关市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (351, 2, '0935', '金昌', 348, 102.188117, 38.520717, 'jinchang', 'JC', '金昌市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (352, 2, '0943', '白银', 348, 104.138771, 36.545261, 'baiyin', 'BY', '白银市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (353, 2, '0938', '天水', 348, 105.724979, 34.580885, 'tianshui', 'TS', '天水市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (354, 2, '1935', '武威', 348, 102.638201, 37.928267, 'wuwei', 'WW', '武威市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (355, 2, '0936', '张掖', 348, 100.449913, 38.925548, 'zhangye', 'ZY', '张掖市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (356, 2, '0933', '平凉', 348, 106.665061, 35.542606, 'pingliang', 'PL', '平凉市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (357, 2, '0937', '酒泉', 348, 98.493927, 39.732795, 'jiuquan', 'JQ', '酒泉市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (358, 2, '0934', '庆阳', 348, 107.643571, 35.708980, 'qingyang', 'QY', '庆阳市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (359, 2, '0932', '定西', 348, 104.592225, 35.606978, 'dingxi', 'DX', '定西市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (360, 2, '2935', '陇南', 348, 104.960851, 33.370680, 'longnan', 'LN', '陇南市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (361, 2, '0930', '临夏', 348, 103.210655, 35.601352, 'linxia', 'LX', '临夏回族自治州');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (362, 2, '0941', '甘南', 348, 102.910995, 34.983409, 'gannan', 'GN', '甘南藏族自治州');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (363, 1, '63', '青海', 1, 101.780268, 36.620939, 'qinghai', 'QH', '青海省');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (364, 2, '0971', '西宁', 363, 101.778223, 36.617134, 'xining', 'XN', '西宁市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (365, 2, '0972', '海东', 363, 102.104287, 36.502039, 'haidong', 'HD', '海东市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (366, 2, '0970', '海北', 363, 100.900997, 36.954413, 'haibei', 'HB', '海北藏族自治州');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (367, 2, '0973', '黄南', 363, 102.015248, 35.519548, 'huangnan', 'HN', '黄南藏族自治州');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (368, 2, '0974', '海南', 363, 100.622692, 36.296529, 'hainan', 'HN', '海南藏族自治州');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (369, 2, '0975', '果洛', 363, 100.244808, 34.471431, 'guoluo', 'GL', '果洛藏族自治州');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (370, 2, '0976', '玉树', 363, 97.091934, 33.011674, 'yushu', 'YS', '玉树藏族自治州');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (371, 2, '0977', '海西', 363, 97.369751, 37.377139, 'haixi', 'HX', '海西蒙古族藏族自治州');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (372, 1, '64', '宁夏', 1, 106.259126, 38.472641, 'ningxia', 'NX', '宁夏回族自治区');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (373, 2, '0951', '银川', 372, 106.230909, 38.487193, 'yinchuan', 'YC', '银川市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (374, 2, '0952', '石嘴山', 372, 106.383303, 38.983236, 'shizuishan', 'SZS', '石嘴山市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (375, 2, '0953', '吴忠', 372, 106.198913, 37.997428, 'wuzhong', 'WZ', '吴忠市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (376, 2, '0954', '固原', 372, 106.242610, 36.015855, 'guyuan', 'GY', '固原市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (377, 2, '1953', '中卫', 372, 105.196902, 37.499972, 'zhongwei', 'ZW', '中卫市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (378, 1, '65', '新疆', 1, 87.627704, 43.793026, 'xinjiang', 'XJ', '新疆维吾尔自治区');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (379, 2, '1997', '阿拉尔', 378, 81.280527, 40.547653, 'alaer', 'ALE', '阿拉尔市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (380, 2, '1906', '北屯', 378, 87.837075, 47.332643, 'beitun', 'BT', '北屯市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (381, 2, '1999', '可克达拉', 378, 81.044542, 43.944798, 'kekedala', 'KKDL', '可克达拉市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (382, 2, '1903', '昆玉', 378, 79.291083, 37.209642, 'kunyu', 'KY', '昆玉市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (383, 2, '0993', '石河子', 378, 86.080602, 44.306097, 'shihezi', 'SHZ', '石河子市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (384, 2, '1909', '双河', 378, 82.353656, 44.840524, 'shuanghe', 'SH', '双河市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (385, 2, '0991', '乌鲁木齐', 378, 87.616848, 43.825592, 'wulumuqi', 'WLMQ', '乌鲁木齐市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (386, 2, '0990', '克拉玛依', 378, 84.889207, 45.579888, 'kelamayi', 'KLMY', '克拉玛依市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (387, 2, '0995', '吐鲁番', 378, 89.189752, 42.951303, 'tulufan', 'TLF', '吐鲁番市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (388, 2, '0902', '哈密', 378, 93.515224, 42.819541, 'hami', 'HM', '哈密市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (389, 2, '0994', '昌吉', 378, 87.308224, 44.011182, 'changji', 'CJ', '昌吉回族自治州');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (390, 2, '0909', '博尔塔拉', 378, 82.066363, 44.906039, 'boertala', 'BETL', '博尔塔拉蒙古自治州');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (391, 2, '0996', '巴音郭楞', 378, 86.145297, 41.764115, 'bayinguoleng', 'BYGL', '巴音郭楞蒙古自治州');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (392, 2, '0997', '阿克苏', 378, 80.260605, 41.168779, 'akesu', 'AKS', '阿克苏地区');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (393, 2, '0908', '克孜勒苏', 378, 76.167819, 39.714526, 'kezilesu', 'KZLS', '克孜勒苏柯尔克孜自治州');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (394, 2, '0998', '喀什', 378, 75.989741, 39.470460, 'kashen', 'KS', '喀什地区');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (395, 2, '0903', '和田', 378, 79.922211, 37.114157, 'hetian', 'HT', '和田地区');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (396, 2, '0999', '伊犁', 378, 81.324136, 43.916823, 'yili', 'YL', '伊犁哈萨克自治州');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (397, 2, '0901', '塔城', 378, 82.980316, 46.745364, 'tacheng', 'TC', '塔城地区');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (398, 2, '0906', '阿勒泰', 378, 88.141253, 47.844924, 'aletai', 'ALT', '阿勒泰地区');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (399, 2, '1996', '铁门关', 378, 85.501217, 41.827250, 'tiemenguan', 'TMG', '铁门关市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (400, 2, '1998', '图木舒克', 378, 79.073963, 39.868965, 'tumushuke', 'TMSK', '图木舒克市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (401, 2, '1994', '五家渠', 378, 87.543240, 44.166756, 'wujiaqu', 'WJQ', '五家渠市');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (402, 1, '1886', '台湾', 1, 121.509062, 25.044332, 'taiwan', 'TW', '台湾省');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (403, 1, '1852', '香港', 1, 114.171203, 22.277468, 'xianggang', 'XG', '香港特别行政区');");
  await db.execute("INSERT INTO $TABLE_NAME_REGION VALUES (422, 1, '1853', '澳门', 1, 113.543028, 22.186835, 'aomen', 'AM', '澳门特别行政区');");
  //search_history
  await db.execute("create table $TABLE_NAME_SEARCHHISTORY (" +
      "$COLUMN_NAME_SEARCHHISTORY_ID bigint(20) primary key," +
      "$COLUMN_NAME_SEARCHHISTORY_UID bigint(20) not null," +
      "$COLUMN_NAME_SEARCHHISTORY_WORD varchar(128) not null" +
      ")");
  //download
  await db.execute("create table $TABLE_NAME_DOWNLOAD (" +
      "$COLUMN_NAME_DOWNLOAD_ID integer primary key autoincrement," +
      "$COLUMN_NAME_DOWNLOAD_TASKID varchar(256) not null," +
      "$COLUMN_NAME_DOWNLOAD_URL varchar(256) not null," +
      "$COLUMN_NAME_DOWNLOAD_FILEPATH varchar(256) not null," +
      "$COLUMN_NAME_DOWNLOAD_CREATETIME bigint(20) not null" +
      ")");
  //download_course_video
  await db.execute("create table $TABLE_NAME_DOWNLOAD_COURSE_VIDEO (" +
      "$COLUMN_NAME_DOWNLOAD_COURSE_ID integer primary key autoincrement," +
      "$COLUMN_NAME_DOWNLOAD_COURSE_NAME varchar(256) not null," +
      "$COLUMN_NAME_DOWNLOAD_COURSE_URLS varchar(256) not null," +
      "$COLUMN_NAME_DOWNLOAD_COURSE_FILEPATHS varchar(256) not null," +
      "$COLUMN_NAME_DOWNLOAD_COURSE_MODEL varchar(256) not null," +
      "$COLUMN_NAME_DOWNLOAD_COURSE_DOWNLOAD_TIME bigint(20) not null" +
      ")");
}

Future<void> _updateDB(Database db, int oldVersion, int newVersion) async {}
